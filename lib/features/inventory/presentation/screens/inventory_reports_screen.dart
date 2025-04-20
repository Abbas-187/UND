import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/inventory_movement_type.dart';
import '../../providers/inventory_movement_providers.dart';

class InventoryReportsScreen extends ConsumerStatefulWidget {
  const InventoryReportsScreen({super.key});

  @override
  ConsumerState<InventoryReportsScreen> createState() =>
      _InventoryReportsScreenState();
}

class _InventoryReportsScreenState
    extends ConsumerState<InventoryReportsScreen> {
  final _dateFormat = DateFormat('yyyy-MM-dd');
  String _selectedReportType = 'movement';
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedFormat = 'pdf';
  bool _includeImages = false;
  bool _includeCharts = true;
  bool _includeDetails = true;

  final List<String> _selectedLocations = [];
  final List<String> _selectedCategories = [];
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();

    // Set default date range to last 30 days
    _endDate = DateTime.now();
    _startDate = DateTime.now().subtract(const Duration(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inventoryReports),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report type selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reportType,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildReportTypeSelection(l10n),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Date range selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dateRange,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateSelector(
                            context,
                            label: l10n.selectStartDate,
                            value: _startDate != null
                                ? _dateFormat.format(_startDate!)
                                : '--',
                            onPressed: () =>
                                _selectDate(context, isStartDate: true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDateSelector(
                            context,
                            label: l10n.selectEndDate,
                            value: _endDate != null
                                ? _dateFormat.format(_endDate!)
                                : '--',
                            onPressed: () =>
                                _selectDate(context, isStartDate: false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Report format selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reportFormat,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildReportFormatSelection(l10n),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Report options
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reportOptions,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      value: _includeImages,
                      title: Text(l10n.includeImages),
                      onChanged: (value) {
                        setState(() {
                          _includeImages = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      value: _includeCharts,
                      title: Text(l10n.includeCharts),
                      onChanged: (value) {
                        setState(() {
                          _includeCharts = value ?? true;
                        });
                      },
                    ),
                    CheckboxListTile(
                      value: _includeDetails,
                      title: Text(l10n.includeDetails),
                      onChanged: (value) {
                        setState(() {
                          _includeDetails = value ?? true;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Generate report button
            Center(
              child: ElevatedButton.icon(
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.description),
                label: Text(l10n.generateReport),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: _isGenerating ? null : _generateReport,
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeSelection(AppLocalizations l10n) {
    return Column(
      children: [
        _buildReportTypeOption(
          value: 'movement',
          title: l10n.movementReport,
          icon: Icons.swap_horiz,
        ),
        _buildReportTypeOption(
          value: 'valuation',
          title: l10n.valuationReport,
          icon: Icons.attach_money,
        ),
        _buildReportTypeOption(
          value: 'stock',
          title: l10n.stockLevelReport,
          icon: Icons.inventory_2,
        ),
        _buildReportTypeOption(
          value: 'expiry',
          title: l10n.expiryReport,
          icon: Icons.access_time,
        ),
        _buildReportTypeOption(
          value: 'location',
          title: l10n.locationReport,
          icon: Icons.place,
        ),
      ],
    );
  }

  Widget _buildReportTypeOption({
    required String value,
    required String title,
    required IconData icon,
  }) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedReportType,
      title: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      onChanged: (newValue) {
        if (newValue != null) {
          setState(() {
            _selectedReportType = newValue;
          });
        }
      },
    );
  }

  Widget _buildDateSelector(
    BuildContext context, {
    required String label,
    required String value,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(value),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportFormatSelection(AppLocalizations l10n) {
    return Column(
      children: [
        RadioListTile<String>(
          value: 'pdf',
          groupValue: _selectedFormat,
          title: Row(
            children: [
              const Icon(Icons.picture_as_pdf),
              const SizedBox(width: 12),
              Text(l10n.downloadAsPdf),
            ],
          ),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _selectedFormat = newValue;
              });
            }
          },
        ),
        RadioListTile<String>(
          value: 'excel',
          groupValue: _selectedFormat,
          title: Row(
            children: [
              const Icon(Icons.table_chart),
              const SizedBox(width: 12),
              Text(l10n.downloadAsExcel),
            ],
          ),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _selectedFormat = newValue;
              });
            }
          },
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isStartDate}) async {
    final initialDate =
        isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now();
    final firstDate =
        isStartDate ? DateTime(2020) : _startDate ?? DateTime(2020);
    final lastDate = isStartDate
        ? (_endDate ?? DateTime.now().add(const Duration(days: 365)))
        : DateTime.now().add(const Duration(days: 1));

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = selectedDate;
        } else {
          _endDate = selectedDate;
        }
      });
    }
  }

  Future<void> _generateReport() async {
    if (_startDate == null || _endDate == null) {
      // Show error - date range is required
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date range')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // Simulate report generation
      await Future.delayed(const Duration(seconds: 2));

      // Different report types would call different service methods
      if (_selectedReportType == 'movement') {
        // For demonstration, we'll use the date range to generate a simulated report
        // In a real app, we'd use a repository or service to fetch and process data
        final startDate = _startDate;
        final endDate = _endDate;

        // Simulate data processing
        await Future.delayed(const Duration(seconds: 1));

        // Here we would generate the actual report based on the movements
        // For demonstration, we'll just show a success message
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).reportCreated),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
}
