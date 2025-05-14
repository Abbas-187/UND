import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/cost_layer.dart';
import '../../domain/providers/inventory_costing_provider.dart';
import '../../domain/usecases/generate_inventory_valuation_report_usecase.dart';

class InventoryValuationReportScreen extends ConsumerStatefulWidget {
  const InventoryValuationReportScreen({super.key});

  @override
  ConsumerState<InventoryValuationReportScreen> createState() =>
      _InventoryValuationReportScreenState();
}

class _InventoryValuationReportScreenState
    extends ConsumerState<InventoryValuationReportScreen> {
  CostingMethod _selectedMethod = CostingMethod.fifo;
  String? _selectedWarehouseId;
  bool _includeLayerBreakdown = false;
  final List<String> _warehouses =
      []; // This would be populated from a provider

  @override
  void initState() {
    super.initState();
    // Get the current costing method from provider
    _selectedMethod = ref.read(costingMethodProvider).selectedCostingMethod;

    // TODO: Fetch warehouses - implement as needed
    _warehouses.add('All Warehouses');
    _warehouses.add('Warehouse A');
    _warehouses.add('Warehouse B');
  }

  @override
  Widget build(BuildContext context) {
    // Watch valuation report based on selected method
    final reportAsyncValue =
        ref.watch(inventoryValuationReportProvider(_selectedMethod));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Valuation Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              // TODO: Implement report printing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Printing not implemented yet')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement report sharing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing not implemented yet')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildReportFilters(),
          Expanded(
            child: reportAsyncValue.when(
              data: (report) => _buildReportContent(report),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text('Error loading report: $err',
                    style: TextStyle(color: Colors.red.shade700)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportFilters() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Filters',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<CostingMethod>(
                    decoration: const InputDecoration(
                      labelText: 'Costing Method',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedMethod,
                    items: CostingMethod.values.map((method) {
                      String label;
                      switch (method) {
                        case CostingMethod.fifo:
                          label = 'FIFO';
                          break;
                        case CostingMethod.lifo:
                          label = 'LIFO';
                          break;
                        case CostingMethod.wac:
                          label = 'Weighted Average';
                          break;
                      }
                      return DropdownMenuItem<CostingMethod>(
                        value: method,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMethod = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Warehouse',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedWarehouseId ?? 'All Warehouses',
                    items: _warehouses.map((warehouse) {
                      return DropdownMenuItem<String>(
                        value: warehouse,
                        child: Text(warehouse),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedWarehouseId =
                            value == 'All Warehouses' ? null : value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _includeLayerBreakdown,
                  onChanged: (value) {
                    setState(() {
                      _includeLayerBreakdown = value ?? false;
                    });
                  },
                ),
                const Text('Include Cost Layer Breakdown'),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Generate Report'),
                  onPressed: () {
                    // Refresh the report
                    ref.refresh(
                        inventoryValuationReportProvider(_selectedMethod));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent(InventoryValuationReport report) {
    // Format for currency display
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report header
          _buildReportHeader(report),

          const SizedBox(height: 16),

          // Report summary
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Total Inventory Value:',
                    currencyFormat.format(report.totalValue),
                    true,
                  ),
                  _buildSummaryRow(
                    'Costing Method:',
                    _getCostingMethodLabel(report.costingMethod),
                    false,
                  ),
                  _buildSummaryRow(
                    'Report Date:',
                    DateFormat('MMMM d, yyyy').format(report.reportDate),
                    false,
                  ),
                  _buildSummaryRow(
                    'Total Items:',
                    report.entries.length.toString(),
                    false,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Detailed report table
          Card(
            margin: EdgeInsets.zero,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Item Code')),
                  DataColumn(label: Text('Item Name')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Quantity')),
                  DataColumn(label: Text('Avg. Cost')),
                  DataColumn(label: Text('Total Value')),
                ],
                rows: report.entries.map((entry) {
                  return DataRow(
                    cells: [
                      DataCell(Text(entry.itemCode)),
                      DataCell(Text(entry.itemName)),
                      DataCell(Text(entry.category ?? '')),
                      DataCell(Text(entry.totalQuantity.toStringAsFixed(2))),
                      DataCell(Text(currencyFormat.format(entry.averageCost))),
                      DataCell(Text(currencyFormat.format(entry.totalValue))),
                    ],
                    onSelectChanged: _includeLayerBreakdown
                        ? (selected) {
                            if (selected != null &&
                                selected &&
                                entry.costLayerBreakdown != null) {
                              _showCostLayerBreakdown(context, entry);
                            }
                          }
                        : null,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportHeader(InventoryValuationReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inventory Valuation Report',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Generated on ${DateFormat('MMMM d, yyyy').format(DateTime.now())}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          'Valuation Method: ${_getCostingMethodLabel(report.costingMethod)}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        if (report.warehouseName != null)
          Text(
            'Warehouse: ${report.warehouseName}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isHighlighted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              fontSize: isHighlighted ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getCostingMethodLabel(CostingMethod method) {
    switch (method) {
      case CostingMethod.fifo:
        return 'First-In-First-Out (FIFO)';
      case CostingMethod.lifo:
        return 'Last-In-First-Out (LIFO)';
      case CostingMethod.wac:
        return 'Weighted Average Cost (WAC)';
    }
  }

  void _showCostLayerBreakdown(
      BuildContext context, InventoryValuationEntry entry) {
    if (entry.costLayerBreakdown == null || entry.costLayerBreakdown!.isEmpty) {
      return;
    }

    final currencyFormat = NumberFormat.currency(symbol: '\$');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cost Layers: ${entry.itemName}'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('Batch/Lot')),
                      DataColumn(label: Text('Quantity')),
                      DataColumn(label: Text('Cost')),
                      DataColumn(label: Text('Value')),
                    ],
                    rows: entry.costLayerBreakdown!.map((layer) {
                      return DataRow(
                        cells: [
                          DataCell(Text(layer.batchLotNumber)),
                          DataCell(Text(layer.quantity.toStringAsFixed(2))),
                          DataCell(
                              Text(currencyFormat.format(layer.costPerUnit))),
                          DataCell(
                              Text(currencyFormat.format(layer.totalValue))),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
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
}
