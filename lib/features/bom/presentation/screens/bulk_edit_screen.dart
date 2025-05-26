import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/bulk_import_service.dart';
import '../../domain/entities/bill_of_materials.dart';
import '../../domain/usecases/bulk_operations_usecase.dart';
import '../widgets/bulk_action_bar.dart';

/// Comprehensive bulk edit screen for BOM management
class BulkEditScreen extends ConsumerStatefulWidget {

  const BulkEditScreen({
    super.key,
    this.initialBoms,
  });
  final List<BillOfMaterials>? initialBoms;

  @override
  ConsumerState<BulkEditScreen> createState() => _BulkEditScreenState();
}

class _BulkEditScreenState extends ConsumerState<BulkEditScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Selection state
  final Set<String> _selectedBomIds = <String>{};
  List<BillOfMaterials> _allBoms = [];
  List<BillOfMaterials> _filteredBoms = [];

  // Search and filter state
  final TextEditingController _searchController = TextEditingController();
  BomStatus? _statusFilter;
  BomType? _typeFilter;

  // Bulk operation state
  bool _isOperationInProgress = false;
  BulkProgress? _currentProgress;
  String? _operationMessage;

  // Import state
  bool _isImporting = false;
  ImportProgress? _importProgress;
  String? _importMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _allBoms = widget.initialBoms ?? [];
    _filteredBoms = List.from(_allBoms);
    _searchController.addListener(_filterBoms);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk BOM Operations'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.edit_note), text: 'Bulk Edit'),
            Tab(icon: Icon(Icons.upload_file), text: 'Import'),
            Tab(icon: Icon(Icons.download), text: 'Export'),
          ],
        ),
        actions: [
          if (_selectedBomIds.isNotEmpty)
            Chip(
              label: Text('${_selectedBomIds.length} selected'),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          if (_isOperationInProgress || _isImporting) _buildProgressIndicator(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBulkEditTab(),
                _buildImportTab(),
                _buildExportTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedBomIds.isNotEmpty
          ? BulkActionBar(
              selectedCount: _selectedBomIds.length,
              onBulkUpdate: _showBulkUpdateDialog,
              onBulkDelete: _showBulkDeleteDialog,
              onBulkCopy: _showBulkCopyDialog,
              onBulkStatusChange: _showBulkStatusChangeDialog,
              onBulkCostRecalculation: _performBulkCostRecalculation,
              onClearSelection: _clearSelection,
            )
          : null,
    );
  }

  Widget _buildProgressIndicator() {
    final message = _operationMessage ?? _importMessage ?? 'Processing...';
    double? progressPercentage;

    if (_currentProgress != null) {
      progressPercentage = _currentProgress!.percentage;
    } else if (_importProgress != null) {
      progressPercentage = _importProgress!.percentage;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
              if (progressPercentage != null)
                Text('${progressPercentage.toStringAsFixed(1)}%'),
            ],
          ),
          if (progressPercentage != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressPercentage / 100,
              backgroundColor: Colors.grey[300],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBulkEditTab() {
    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(child: _buildBomList()),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search BOMs...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterBoms();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<BomStatus>(
                  value: _statusFilter,
                  decoration: const InputDecoration(
                    labelText: 'Status Filter',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<BomStatus>(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    ...BomStatus.values.map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.toString().split('.').last),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _statusFilter = value;
                      _filterBoms();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<BomType>(
                  value: _typeFilter,
                  decoration: const InputDecoration(
                    labelText: 'Type Filter',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<BomType>(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...BomType.values.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _typeFilter = value;
                      _filterBoms();
                    });
                  },
                ),
              ),
            ],
          ),

          // Selection actions
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: _selectAll,
                icon: const Icon(Icons.select_all),
                label: const Text('Select All'),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: _clearSelection,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Selection'),
              ),
              const Spacer(),
              Text('${_filteredBoms.length} BOMs'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBomList() {
    if (_filteredBoms.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No BOMs found', style: TextStyle(fontSize: 18)),
            Text('Try adjusting your search or filters'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredBoms.length,
      itemBuilder: (context, index) {
        final bom = _filteredBoms[index];
        final isSelected = _selectedBomIds.contains(bom.id);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (selected) =>
                _toggleBomSelection(bom.id, selected ?? false),
            title: Text(
              bom.bomName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Code: ${bom.bomCode}'),
                Text('Product: ${bom.productName}'),
                Row(
                  children: [
                    Chip(
                      label: Text(bom.status.toString().split('.').last),
                      backgroundColor: _getStatusColor(bom.status),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(bom.bomType.toString().split('.').last),
                      backgroundColor: Colors.blue.withOpacity(0.1),
                    ),
                  ],
                ),
              ],
            ),
            secondary: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$${bom.totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text('${bom.items.length} items'),
              ],
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        );
      },
    );
  }

  Widget _buildImportTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Import BOMs',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Import options
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Import from File',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isImporting
                              ? null
                              : () => _importFromFile('csv'),
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Import CSV'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isImporting
                              ? null
                              : () => _importFromFile('excel'),
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Import Excel'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Download Templates',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _downloadCsvTemplate,
                          icon: const Icon(Icons.download),
                          label: const Text('CSV Template'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _downloadExcelTemplate,
                          icon: const Icon(Icons.download),
                          label: const Text('Excel Template'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Import instructions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Import Instructions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text('1. Download the appropriate template'),
                  const Text('2. Fill in your BOM data'),
                  const Text('3. Ensure all required fields are completed'),
                  const Text(
                      '4. Upload the file using the import buttons above'),
                  const SizedBox(height: 12),
                  const Text(
                    'Required Fields:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('• BOM Code (must be unique)'),
                  const Text('• BOM Name'),
                  const Text('• Product ID'),
                  const Text('• Base Quantity'),
                  const Text('• Base Unit'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export BOMs',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_selectedBomIds.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Select BOMs from the Bulk Edit tab to export them.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export ${_selectedBomIds.length} Selected BOMs',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _exportBoms('csv'),
                            icon: const Icon(Icons.download),
                            label: const Text('Export as CSV'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _exportBoms('excel'),
                            icon: const Icon(Icons.download),
                            label: const Text('Export as Excel'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Export options
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Export Options',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('Include BOM Items'),
                      subtitle: const Text('Export detailed item information'),
                      value: true, // This would be a state variable
                      onChanged: (value) {
                        // Handle option change
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Include Cost Information'),
                      subtitle:
                          const Text('Export cost calculations and pricing'),
                      value: true, // This would be a state variable
                      onChanged: (value) {
                        // Handle option change
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Include Charts (Excel only)'),
                      subtitle: const Text('Generate cost breakdown charts'),
                      value: false, // This would be a state variable
                      onChanged: (value) {
                        // Handle option change
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Event handlers

  void _filterBoms() {
    setState(() {
      _filteredBoms = _allBoms.where((bom) {
        // Search filter
        final searchTerm = _searchController.text.toLowerCase();
        final matchesSearch = searchTerm.isEmpty ||
            bom.bomName.toLowerCase().contains(searchTerm) ||
            bom.bomCode.toLowerCase().contains(searchTerm) ||
            bom.productName.toLowerCase().contains(searchTerm);

        // Status filter
        final matchesStatus =
            _statusFilter == null || bom.status == _statusFilter;

        // Type filter
        final matchesType = _typeFilter == null || bom.bomType == _typeFilter;

        return matchesSearch && matchesStatus && matchesType;
      }).toList();
    });
  }

  void _toggleBomSelection(String bomId, bool selected) {
    setState(() {
      if (selected) {
        _selectedBomIds.add(bomId);
      } else {
        _selectedBomIds.remove(bomId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedBomIds.addAll(_filteredBoms.map((bom) => bom.id));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedBomIds.clear();
    });
  }

  Color _getStatusColor(BomStatus status) {
    switch (status) {
      case BomStatus.active:
        return Colors.green.withOpacity(0.1);
      case BomStatus.draft:
        return Colors.orange.withOpacity(0.1);
      case BomStatus.inactive:
        return Colors.grey.withOpacity(0.1);
      case BomStatus.obsolete:
        return Colors.red.withOpacity(0.1);
      case BomStatus.underReview:
        return Colors.blue.withOpacity(0.1);
      case BomStatus.approved:
        return Colors.green.withOpacity(0.2);
      case BomStatus.rejected:
        return Colors.red.withOpacity(0.2);
    }
  }

  // Bulk operation methods

  void _showBulkUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => BulkUpdateDialog(
        selectedBomIds: _selectedBomIds.toList(),
        onUpdate: _performBulkUpdate,
      ),
    );
  }

  void _showBulkDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Bulk Delete'),
        content: Text(
          'Are you sure you want to delete ${_selectedBomIds.length} BOMs? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performBulkDelete();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showBulkCopyDialog() {
    showDialog(
      context: context,
      builder: (context) => BulkCopyDialog(
        selectedBomIds: _selectedBomIds.toList(),
        onCopy: _performBulkCopy,
      ),
    );
  }

  void _showBulkStatusChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => BulkStatusChangeDialog(
        selectedBomIds: _selectedBomIds.toList(),
        onStatusChange: _performBulkStatusChange,
      ),
    );
  }

  Future<void> _performBulkUpdate(Map<String, dynamic> updates) async {
    setState(() {
      _isOperationInProgress = true;
      _operationMessage = 'Updating BOMs...';
    });

    try {
      final bulkOperationsUseCase = ref.read(bulkOperationsUseCaseProvider);
      final result = await bulkOperationsUseCase.bulkUpdateBoms(
        bomIds: _selectedBomIds.toList(),
        updates: updates,
        userId: 'current_user', // This would come from auth
        onProgress: (progress) {
          setState(() {
            _currentProgress = progress;
            _operationMessage = progress.status;
          });
        },
      );

      _showOperationResult('Bulk Update', result);
    } catch (e) {
      _showErrorDialog('Bulk Update Failed', e.toString());
    } finally {
      setState(() {
        _isOperationInProgress = false;
        _currentProgress = null;
        _operationMessage = null;
      });
    }
  }

  Future<void> _performBulkDelete() async {
    setState(() {
      _isOperationInProgress = true;
      _operationMessage = 'Deleting BOMs...';
    });

    try {
      final bulkOperationsUseCase = ref.read(bulkOperationsUseCaseProvider);
      final result = await bulkOperationsUseCase.bulkDeleteBoms(
        bomIds: _selectedBomIds.toList(),
        userId: 'current_user',
        onProgress: (progress) {
          setState(() {
            _currentProgress = progress;
            _operationMessage = progress.status;
          });
        },
      );

      _showOperationResult('Bulk Delete', result);
      _clearSelection();
    } catch (e) {
      _showErrorDialog('Bulk Delete Failed', e.toString());
    } finally {
      setState(() {
        _isOperationInProgress = false;
        _currentProgress = null;
        _operationMessage = null;
      });
    }
  }

  Future<void> _performBulkCopy(String namePrefix, bool copyItems) async {
    setState(() {
      _isOperationInProgress = true;
      _operationMessage = 'Copying BOMs...';
    });

    try {
      final bulkOperationsUseCase = ref.read(bulkOperationsUseCaseProvider);
      final result = await bulkOperationsUseCase.bulkCopyBoms(
        bomIds: _selectedBomIds.toList(),
        userId: 'current_user',
        namePrefix: namePrefix,
        copyItems: copyItems,
        onProgress: (progress) {
          setState(() {
            _currentProgress = progress;
            _operationMessage = progress.status;
          });
        },
      );

      _showOperationResult('Bulk Copy', result);
    } catch (e) {
      _showErrorDialog('Bulk Copy Failed', e.toString());
    } finally {
      setState(() {
        _isOperationInProgress = false;
        _currentProgress = null;
        _operationMessage = null;
      });
    }
  }

  Future<void> _performBulkStatusChange(
      BomStatus newStatus, String? reason) async {
    setState(() {
      _isOperationInProgress = true;
      _operationMessage = 'Changing BOM status...';
    });

    try {
      final bulkOperationsUseCase = ref.read(bulkOperationsUseCaseProvider);
      final result = await bulkOperationsUseCase.bulkChangeStatus(
        bomIds: _selectedBomIds.toList(),
        newStatus: newStatus,
        userId: 'current_user',
        reason: reason,
        onProgress: (progress) {
          setState(() {
            _currentProgress = progress;
            _operationMessage = progress.status;
          });
        },
      );

      _showOperationResult('Bulk Status Change', result);
    } catch (e) {
      _showErrorDialog('Bulk Status Change Failed', e.toString());
    } finally {
      setState(() {
        _isOperationInProgress = false;
        _currentProgress = null;
        _operationMessage = null;
      });
    }
  }

  Future<void> _performBulkCostRecalculation() async {
    setState(() {
      _isOperationInProgress = true;
      _operationMessage = 'Recalculating costs...';
    });

    try {
      final bulkOperationsUseCase = ref.read(bulkOperationsUseCaseProvider);
      final result = await bulkOperationsUseCase.bulkRecalculateCosts(
        bomIds: _selectedBomIds.toList(),
        onProgress: (progress) {
          setState(() {
            _currentProgress = progress;
            _operationMessage = progress.status;
          });
        },
      );

      _showOperationResult('Bulk Cost Recalculation', result);
    } catch (e) {
      _showErrorDialog('Bulk Cost Recalculation Failed', e.toString());
    } finally {
      setState(() {
        _isOperationInProgress = false;
        _currentProgress = null;
        _operationMessage = null;
      });
    }
  }

  // Import/Export methods

  Future<void> _importFromFile(String format) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: format == 'csv' ? ['csv'] : ['xlsx', 'xls'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);

        setState(() {
          _isImporting = true;
          _importMessage = 'Importing from $format file...';
        });

        final bulkImportService = ref.read(bulkImportServiceProvider);

        ImportResult importResult;
        if (format == 'csv') {
          importResult = await bulkImportService.importFromCsvFile(
            csvFile: file,
            userId: 'current_user',
            onProgress: (progress) {
              setState(() {
                _importProgress = progress;
                _importMessage = progress.status;
              });
            },
          );
        } else {
          importResult = await bulkImportService.importFromExcelFile(
            excelFile: file,
            userId: 'current_user',
            onProgress: (progress) {
              setState(() {
                _importProgress = progress;
                _importMessage = progress.status;
              });
            },
          );
        }

        _showImportResult(importResult);
      }
    } catch (e) {
      _showErrorDialog('Import Failed', e.toString());
    } finally {
      setState(() {
        _isImporting = false;
        _importProgress = null;
        _importMessage = null;
      });
    }
  }

  void _downloadCsvTemplate() {
    final bulkImportService = ref.read(bulkImportServiceProvider);
    final template = bulkImportService.getCsvTemplate(includeItems: true);

    // In a real app, this would trigger a file download
    _showInfoDialog('CSV Template', 'Template downloaded successfully');
  }

  void _downloadExcelTemplate() {
    final bulkImportService = ref.read(bulkImportServiceProvider);
    final template = bulkImportService.getExcelTemplate(includeItems: true);

    // In a real app, this would trigger a file download
    _showInfoDialog('Excel Template', 'Template downloaded successfully');
  }

  Future<void> _exportBoms(String format) async {
    try {
      final bulkOperationsUseCase = ref.read(bulkOperationsUseCaseProvider);

      ExportResult result;
      if (format == 'csv') {
        result = await bulkOperationsUseCase.exportBomsToCSV(
          bomIds: _selectedBomIds.toList(),
          includeItems: true,
          includeCosts: true,
        );
      } else {
        result = await bulkOperationsUseCase.exportBomsToExcel(
          bomIds: _selectedBomIds.toList(),
          includeItems: true,
          includeCosts: true,
          includeCharts: false,
        );
      }

      _showExportResult(result);
    } catch (e) {
      _showErrorDialog('Export Failed', e.toString());
    }
  }

  // Dialog methods

  void _showOperationResult(String operation, BulkOperationResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$operation Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${result.status.toString().split('.').last}'),
            Text('Successful: ${result.successCount}'),
            Text('Errors: ${result.errorCount}'),
            if (result.duration != null)
              Text('Duration: ${result.duration!.inSeconds}s'),
            if (result.hasErrors) ...[
              const SizedBox(height: 8),
              const Text('Errors:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...result.errors.entries.take(5).map(
                    (entry) => Text('${entry.key}: ${entry.value}'),
                  ),
              if (result.errors.length > 5)
                Text('... and ${result.errors.length - 5} more'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showImportResult(ImportResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Rows: ${result.totalRows}'),
            Text('Valid Rows: ${result.validRowCount}'),
            Text('Error Rows: ${result.errorRowCount}'),
            Text('Imported: ${result.successCount}'),
            if (result.errors.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Errors:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...result.errors.entries.take(5).map(
                    (entry) =>
                        Text('Row ${entry.key}: ${entry.value.join(', ')}'),
                  ),
              if (result.errors.length > 5)
                Text('... and ${result.errors.length - 5} more errors'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showExportResult(ExportResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Format: ${result.format.toString().split('.').last.toUpperCase()}'),
            Text('Exported: ${result.successCount}'),
            Text('Errors: ${result.errorCount}'),
            if (result.fileName != null) Text('File: ${result.fileName}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Supporting dialog widgets

class BulkUpdateDialog extends StatefulWidget {

  const BulkUpdateDialog({
    super.key,
    required this.selectedBomIds,
    required this.onUpdate,
  });
  final List<String> selectedBomIds;
  final Function(Map<String, dynamic>) onUpdate;

  @override
  State<BulkUpdateDialog> createState() => _BulkUpdateDialogState();
}

class _BulkUpdateDialogState extends State<BulkUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  BomStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Bulk Update ${widget.selectedBomIds.length} BOMs'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'BOM Name (leave empty to keep current)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BomStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status (leave empty to keep current)',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<BomStatus>(
                  value: null,
                  child: Text('Keep Current Status'),
                ),
                ...BomStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.toString().split('.').last),
                    )),
              ],
              onChanged: (value) => setState(() => _selectedStatus = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (leave empty to keep current)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updates = <String, dynamic>{};
            if (_nameController.text.isNotEmpty) {
              updates['bomName'] = _nameController.text;
            }
            if (_selectedStatus != null) {
              updates['status'] = _selectedStatus.toString().split('.').last;
            }
            if (_descriptionController.text.isNotEmpty) {
              updates['description'] = _descriptionController.text;
            }

            Navigator.of(context).pop();
            widget.onUpdate(updates);
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}

class BulkCopyDialog extends StatefulWidget {

  const BulkCopyDialog({
    super.key,
    required this.selectedBomIds,
    required this.onCopy,
  });
  final List<String> selectedBomIds;
  final Function(String, bool) onCopy;

  @override
  State<BulkCopyDialog> createState() => _BulkCopyDialogState();
}

class _BulkCopyDialogState extends State<BulkCopyDialog> {
  final _prefixController = TextEditingController(text: 'Copy of ');
  bool _copyItems = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Copy ${widget.selectedBomIds.length} BOMs'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _prefixController,
            decoration: const InputDecoration(
              labelText: 'Name Prefix',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Copy BOM Items'),
            subtitle: const Text('Include all items in the copied BOMs'),
            value: _copyItems,
            onChanged: (value) => setState(() => _copyItems = value ?? true),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onCopy(_prefixController.text, _copyItems);
          },
          child: const Text('Copy'),
        ),
      ],
    );
  }
}

class BulkStatusChangeDialog extends StatefulWidget {

  const BulkStatusChangeDialog({
    super.key,
    required this.selectedBomIds,
    required this.onStatusChange,
  });
  final List<String> selectedBomIds;
  final Function(BomStatus, String?) onStatusChange;

  @override
  State<BulkStatusChangeDialog> createState() => _BulkStatusChangeDialogState();
}

class _BulkStatusChangeDialogState extends State<BulkStatusChangeDialog> {
  BomStatus? _selectedStatus;
  final _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Change Status for ${widget.selectedBomIds.length} BOMs'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<BomStatus>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'New Status',
              border: OutlineInputBorder(),
            ),
            items: BomStatus.values
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.toString().split('.').last),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedStatus = value),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'Reason (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedStatus == null
              ? null
              : () {
                  Navigator.of(context).pop();
                  widget.onStatusChange(
                    _selectedStatus!,
                    _reasonController.text.isNotEmpty
                        ? _reasonController.text
                        : null,
                  );
                },
          child: const Text('Change Status'),
        ),
      ],
    );
  }
}
