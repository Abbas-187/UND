import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../data/models/inventory_audit_log_model.dart';
import '../../data/providers/inventory_audit_providers.dart';

/// Screen for viewing and searching inventory audit logs
class InventoryAuditLogScreen extends ConsumerStatefulWidget {
  const InventoryAuditLogScreen({super.key});

  @override
  ConsumerState<InventoryAuditLogScreen> createState() =>
      _InventoryAuditLogScreenState();
}

class _InventoryAuditLogScreenState
    extends ConsumerState<InventoryAuditLogScreen> {
  // Filter state
  String? _selectedModule;
  AuditActionType? _selectedActionType;
  AuditEntityType? _selectedEntityType;
  String? _searchQuery;
  DateTime? _startDate;
  DateTime? _endDate;

  // Controller for search
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load logs with default filters when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLogs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load logs with current filters
  void _loadLogs() {
    ref.read(auditLogsProvider.notifier).searchAuditLogs(
          module: _selectedModule,
          actionType: _selectedActionType,
          entityType: _selectedEntityType,
          entityId: _searchQuery,
          userId: _searchQuery, // Using userId instead of userEmail
          startDate: _startDate,
          endDate: _endDate,
        );
  }

  // Reset all filters
  void _resetFilters() {
    setState(() {
      _selectedModule = null;
      _selectedActionType = null;
      _selectedEntityType = null;
      _searchQuery = null;
      _searchController.clear();
      _startDate = null;
      _endDate = null;
    });
    _loadLogs();
  }

  // Export logs to CSV and share
  Future<void> _exportAndShareCSV() async {
    try {
      final csvContent = await ref.read(auditLogsProvider.notifier).exportToCSV(
            module: _selectedModule,
            actionType: _selectedActionType,
            entityType: _selectedEntityType,
            entityId: _searchQuery,
            userId: _searchQuery,
            startDate: _startDate,
            endDate: _endDate,
          );

      // Create a temporary file
      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'inventory_audit_logs_$timestamp.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvContent);

      // Share the file
      await Share.shareXFiles([XFile(file.path)],
          text: 'Inventory Audit Logs Export');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting logs: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final logsState = ref.watch(auditLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Audit Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export to CSV',
            onPressed: _exportAndShareCSV,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_hasActiveFilters()) _buildActiveFiltersChips(),
          Expanded(
            child: logsState.when(
              data: (logs) => logs.isEmpty
                  ? const Center(child: Text('No audit logs found'))
                  : _buildLogsList(logs),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Error loading logs: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Check if any filters are active
  bool _hasActiveFilters() {
    return _selectedModule != null ||
        _selectedActionType != null ||
        _selectedEntityType != null ||
        _searchQuery != null ||
        _startDate != null ||
        _endDate != null;
  }

  // Build the search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by ID, email, or entity ID',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = null);
              _loadLogs();
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onSubmitted: (value) {
          setState(() => _searchQuery = value.isNotEmpty ? value : null);
          _loadLogs();
        },
      ),
    );
  }

  // Build chips showing active filters
  Widget _buildActiveFiltersChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          if (_selectedModule != null)
            Chip(
              label: Text('Module: $_selectedModule'),
              onDeleted: () {
                setState(() => _selectedModule = null);
                _loadLogs();
              },
            ),
          if (_selectedActionType != null)
            Chip(
              label: Text(
                  'Action: ${_selectedActionType.toString().split('.').last}'),
              onDeleted: () {
                setState(() => _selectedActionType = null);
                _loadLogs();
              },
            ),
          if (_selectedEntityType != null)
            Chip(
              label: Text(
                  'Entity: ${_selectedEntityType.toString().split('.').last}'),
              onDeleted: () {
                setState(() => _selectedEntityType = null);
                _loadLogs();
              },
            ),
          if (_startDate != null)
            Chip(
              label:
                  Text('From: ${DateFormat('MMM d, y').format(_startDate!)}'),
              onDeleted: () {
                setState(() => _startDate = null);
                _loadLogs();
              },
            ),
          if (_endDate != null)
            Chip(
              label: Text('To: ${DateFormat('MMM d, y').format(_endDate!)}'),
              onDeleted: () {
                setState(() => _endDate = null);
                _loadLogs();
              },
            ),
          if (_hasActiveFilters())
            TextButton(
              onPressed: _resetFilters,
              child: const Text('Clear All'),
            ),
        ],
      ),
    );
  }

  // Build the list of audit logs
  Widget _buildLogsList(List<InventoryAuditLogModel> logs) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            title: Text(
              '${log.actionType.toString().split('.').last} ${log.entityType.toString().split('.').last}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${log.entityId}'),
                Text('User: ${log.userEmail ?? log.userId}'),
                Text(
                  'Date: ${DateFormat('MMM d, y HH:mm:ss').format(log.timestamp)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 12,
                  ),
                ),
                if (log.description != null)
                  Text(
                    log.description!,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLogDetails(log),
          ),
        );
      },
    );
  }

  // Show filter dialog
  void _showFilterDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        String? tempModule = _selectedModule;
        AuditActionType? tempActionType = _selectedActionType;
        AuditEntityType? tempEntityType = _selectedEntityType;
        DateTime? tempStartDate = _startDate;
        DateTime? tempEndDate = _endDate;

        return AlertDialog(
          title: const Text('Filter Audit Logs'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Module'),
                  value: tempModule,
                  items: const [
                    DropdownMenuItem(
                        value: 'inventory', child: Text('Inventory')),
                    DropdownMenuItem(
                        value: 'procurement', child: Text('Procurement')),
                    DropdownMenuItem(
                        value: 'order_management',
                        child: Text('Order Management')),
                    DropdownMenuItem(
                        value: 'milk_reception', child: Text('Milk Reception')),
                  ],
                  onChanged: (value) => tempModule = value,
                  hint: const Text('Select Module'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AuditActionType>(
                  decoration: const InputDecoration(labelText: 'Action Type'),
                  value: tempActionType,
                  items: AuditActionType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) => tempActionType = value,
                  hint: const Text('Select Action Type'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AuditEntityType>(
                  decoration: const InputDecoration(labelText: 'Entity Type'),
                  value: tempEntityType,
                  items: AuditEntityType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) => tempEntityType = value,
                  hint: const Text('Select Entity Type'),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Start Date'),
                  subtitle: tempStartDate != null
                      ? Text(DateFormat('MMM d, y').format(tempStartDate))
                      : const Text('Not set'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: tempStartDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      tempStartDate = date;
                    }
                  },
                ),
                ListTile(
                  title: const Text('End Date'),
                  subtitle: tempEndDate != null
                      ? Text(DateFormat('MMM d, y').format(tempEndDate))
                      : const Text('Not set'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: tempEndDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (date != null) {
                      tempEndDate = date;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedModule = tempModule;
                  _selectedActionType = tempActionType;
                  _selectedEntityType = tempEntityType;
                  _startDate = tempStartDate;
                  _endDate = tempEndDate;
                });
                Navigator.of(context).pop();
                _loadLogs();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  // Show log details dialog
  void _showLogDetails(InventoryAuditLogModel log) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Audit Log Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailItem('ID', log.id),
                _detailItem('User ID', log.userId),
                if (log.userEmail != null)
                  _detailItem('User Email', log.userEmail!),
                if (log.userName != null)
                  _detailItem('User Name', log.userName!),
                _detailItem(
                    'Action Type', log.actionType.toString().split('.').last),
                _detailItem(
                    'Entity Type', log.entityType.toString().split('.').last),
                _detailItem('Entity ID', log.entityId),
                _detailItem('Module', log.module),
                _detailItem('Timestamp',
                    DateFormat('MMM d, y HH:mm:ss').format(log.timestamp)),
                if (log.description != null)
                  _detailItem('Description', log.description!),
                if (log.deviceInfo != null)
                  _detailItem('Device', log.deviceInfo!),
                if (log.beforeState != null && log.beforeState!.isNotEmpty)
                  _expandableJsonSection('Before State', log.beforeState!),
                if (log.afterState != null && log.afterState!.isNotEmpty)
                  _expandableJsonSection('After State', log.afterState!),
                if (log.metadata != null && log.metadata!.isNotEmpty)
                  _expandableJsonSection('Metadata', log.metadata!),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Helper method to display detail items
  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
          const Divider(),
        ],
      ),
    );
  }

  // Helper method to display expandable JSON sections
  Widget _expandableJsonSection(String title, Map<String, dynamic> json) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _prettyJson(json),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }

  // Helper method to format JSON for display
  String _prettyJson(Map<String, dynamic> json) {
    String result = '';
    json.forEach((key, value) {
      result += '$key: $value\n';
    });
    return result;
  }
}
