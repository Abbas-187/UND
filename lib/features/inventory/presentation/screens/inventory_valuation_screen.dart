import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/cost_layer.dart';
import '../../domain/usecases/generate_inventory_valuation_report_usecase.dart';
import '../providers/inventory_movement_provider.dart';
import '../providers/inventory_valuation_provider.dart';
import '../widgets/inventory_item_valuation_card.dart';

/// Screen for displaying inventory valuation with FIFO/LIFO costing
class InventoryValuationScreen extends ConsumerStatefulWidget {
  const InventoryValuationScreen({super.key});

  @override
  ConsumerState<InventoryValuationScreen> createState() =>
      _InventoryValuationScreenState();
}

class _InventoryValuationScreenState
    extends ConsumerState<InventoryValuationScreen> {
  String? _selectedWarehouseId;
  CostingMethod _selectedCostingMethod = CostingMethod.fifo;
  bool _showCostLayers = true;
  bool _isLoading = false;
  DateTime _reportDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadValuationReport();
    });
  }

  Future<void> _loadValuationReport() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await ref
          .read(inventoryValuationProvider.notifier)
          .generateValuationReport();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildWarehouseDropdown(List<Warehouse> warehouses) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Warehouse',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      value: _selectedWarehouseId,
      items: warehouses.map((warehouse) {
        return DropdownMenuItem<String>(
          value: warehouse.id,
          child: Text(warehouse.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedWarehouseId = value;
        });
        ref
            .read(inventoryValuationProvider.notifier)
            .updateWarehouseFilter(value);
        _loadValuationReport();
      },
    );
  }

  Widget _buildCostingMethodDropdown() {
    return DropdownButtonFormField<CostingMethod>(
      decoration: const InputDecoration(
        labelText: 'Costing Method',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      value: _selectedCostingMethod,
      items: CostingMethod.values.map((method) {
        return DropdownMenuItem<CostingMethod>(
          value: method,
          child: Text(_getCostingMethodLabel(method)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCostingMethod = value;
          });
          ref
              .read(inventoryValuationProvider.notifier)
              .updateCostingMethod(value);
          _loadValuationReport();
        }
      },
    );
  }

  Widget _buildShowCostLayersCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _showCostLayers,
          onChanged: (value) {
            setState(() {
              _showCostLayers = value!;
            });
            ref
                .read(inventoryValuationProvider.notifier)
                .toggleLayerBreakdown();
            _loadValuationReport();
          },
        ),
        const Text('Show Cost Layers'),
      ],
    );
  }

  Widget _buildReportContent(InventoryValuationReport? report) {
    if (report == null) {
      return const Center(
        child: Text(
            'No valuation data available. Select filters and generate a report.'),
      );
    }
    if (report.entries.isEmpty) {
      return const Center(
        child: Text('No inventory items found for the selected criteria.'),
      );
    }
    return Column(
      children: [
        _buildReportHeader(report),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: report.entries.length,
            itemBuilder: (context, index) {
              final entry = report.entries[index];
              return InventoryItemValuationCard(
                entry: entry,
                showCostLayers: _showCostLayers,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportHeader(InventoryValuationReport report) {
    final theme = Theme.of(context);
    final numberFormat = NumberFormat('#,##0.00');
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Valuation Report', style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('Warehouse: ${report.warehouseName ?? 'All Warehouses'}',
                    style: theme.textTheme.bodyMedium),
                Text('Method: ${_getCostingMethodLabel(report.costingMethod)}',
                    style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Total Value:', style: theme.textTheme.titleMedium),
              Text('\$${numberFormat.format(report.totalValue)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  String _getCostingMethodLabel(CostingMethod method) {
    switch (method) {
      case CostingMethod.fifo:
        return 'FIFO (First In, First Out)';
      case CostingMethod.lifo:
        return 'LIFO (Last In, First Out)';
      case CostingMethod.wac:
        return 'WAC (Weighted Average Cost)';
    }
  }

  Future<void> _selectReportDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _reportDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (pickedDate != null && pickedDate != _reportDate) {
      setState(() {
        _reportDate = pickedDate;
      });
      _loadValuationReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    final valuationData = ref.watch(inventoryValuationProvider);
    final warehousesAsync = ref.watch(warehousesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Valuation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadValuationReport,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {},
            tooltip: 'Print Report',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectReportDate,
            tooltip: 'Select Report Date',
          ),
        ],
      ),
      body: Column(
        children: [
          warehousesAsync.when(
            data: (warehouses) => _buildFilterBar(context, warehouses),
            loading: () => const LinearProgressIndicator(),
            error: (err, stack) => Text('Error loading warehouses: $err'),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildReportContent(valuationData.report),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, List<Warehouse> warehouses) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildWarehouseDropdown(warehouses)),
              const SizedBox(width: 16),
              Expanded(child: _buildCostingMethodDropdown()),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildShowCostLayersCheckbox(),
              const Spacer(),
              Text('As of: ${DateFormat('MMM dd, yyyy').format(_reportDate)}',
                  style: theme.textTheme.bodyLarge),
            ],
          ),
        ],
      ),
    );
  }
}
