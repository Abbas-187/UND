import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/order_model.dart';
import '../providers/order_provider.dart';
import 'responsive_builder.dart';

class BackorderManagementWidget extends ConsumerStatefulWidget {
  const BackorderManagementWidget(
      {super.key, required this.order, this.onBackorderResolved});
  final OrderModel order;
  final void Function()? onBackorderResolved;

  @override
  ConsumerState<BackorderManagementWidget> createState() =>
      _BackorderManagementWidgetState();
}

class _BackorderManagementWidgetState
    extends ConsumerState<BackorderManagementWidget> {
  final Set<int> _selectedRows = {};
  bool _isLoading = false;
  final Map<int, bool> _expandedRows = {};

  Color _statusColor(String? status) {
    switch (status) {
      case 'fulfilled':
        return Colors.green;
      case 'backordered':
        return Colors.orange;
      case 'pending':
      default:
        return Colors.grey;
    }
  }

  void _showFulfillDialog(
      BuildContext context, Map<String, dynamic> item, int idx) async {
    final controller =
        TextEditingController(text: '${item['backorderedQuantity']}');
    final availableStock = 10; // TODO: Replace with actual stock lookup
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Fulfill ${item['productName']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Available stock: $availableStock'),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Quantity to fulfill'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final qty = double.tryParse(controller.text) ?? 0;
              if (qty <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a valid quantity.')),
                );
                return;
              }
              setState(() => _isLoading = true);
              try {
                await ref
                    .read(orderProvider.notifier)
                    .fulfillOrderItem(widget.order, item, qty);
                if (widget.onBackorderResolved != null) {
                  widget.onBackorderResolved!();
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Fulfillment attempted for ${item['productName']} ($qty)')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Fulfill'),
          ),
        ],
      ),
    );
  }

  void _showProcurementDialog(
      BuildContext context, Map<String, dynamic> item) async {
    final controller =
        TextEditingController(text: '${item['backorderedQuantity']}');
    final notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request Procurement for ${item['productName']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              await Future.delayed(const Duration(seconds: 1)); // Mock
              setState(() => _isLoading = false);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Procurement requested for ${item['productName']} (Qty: ${controller.text})')),
              );
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  void _showResolutionDialog(
      BuildContext context, Map<String, dynamic> item) async {
    final notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resolve Backorder for ${item['productName']}'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(labelText: 'Resolution Note'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              await Future.delayed(const Duration(seconds: 1)); // Mock
              setState(() => _isLoading = false);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Marked as resolved: ${notesController.text}')),
              );
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemHistory(Map<String, dynamic> item) {
    // Mocked timeline/history
    final List<Map<String, String>> history = [
      {'date': '2024-06-01', 'event': 'Backordered (5 units)'},
      {'date': '2024-06-03', 'event': 'Procurement requested'},
      {'date': '2024-06-05', 'event': 'Partial fulfillment (2 units)'},
    ];
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: history
            .map((h) => Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: Colors.orange.shade300),
                    const SizedBox(width: 8),
                    Text('${h['date']}: ${h['event']}'),
                  ],
                ))
            .toList(),
      ),
    );
  }

  void _bulkAction(BuildContext context, String action,
      List<Map<String, dynamic>> selectedItems) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Mock
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Bulk "$action" performed for ${selectedItems.length} items.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backorderedItems = widget.order.items
        .where((item) =>
            (item['fulfillmentStatus'] ?? '') == 'backordered' &&
            (item['backorderedQuantity'] ?? 0) > 0)
        .toList();

    if (backorderedItems.isEmpty) {
      return const Center(child: Text('No backordered items.'));
    }

    Widget buildTable() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(
                label: Row(
                  children: [
                    Checkbox(
                      value: _selectedRows.length == backorderedItems.length &&
                          backorderedItems.isNotEmpty,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedRows.addAll(List.generate(
                                backorderedItems.length, (i) => i));
                          } else {
                            _selectedRows.clear();
                          }
                        });
                      },
                      tristate: false,
                      autofocus: true,
                      semanticLabel: 'Select all backordered items',
                    ),
                    const Text('Product'),
                  ],
                ),
              ),
              const DataColumn(label: Text('Backordered')),
              const DataColumn(label: Text('Fulfilled')),
              const DataColumn(label: Text('Status')),
              const DataColumn(label: Text('Actions')),
            ],
            rows: List.generate(backorderedItems.length, (idx) {
              final item = backorderedItems[idx];
              final status = item['fulfillmentStatus'] ?? 'backordered';
              final isSelected = _selectedRows.contains(idx);
              final isExpanded = _expandedRows[idx] == true;
              return DataRow(
                selected: isSelected,
                onSelectChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedRows.add(idx);
                    } else {
                      _selectedRows.remove(idx);
                    }
                  });
                },
                cells: [
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more),
                        tooltip: isExpanded ? 'Hide history' : 'Show history',
                        onPressed: () {
                          setState(() {
                            _expandedRows[idx] = !isExpanded;
                          });
                        },
                        focusColor: Colors.orange.shade100,
                        autofocus: false,
                        splashRadius: 18,
                      ),
                      Text(item['productName'] ?? 'Unknown'),
                    ],
                  )),
                  DataCell(Text('${item['backorderedQuantity'] ?? 0}')),
                  DataCell(Text('${item['fulfilledQuantity'] ?? 0}')),
                  DataCell(
                    Chip(
                      label:
                          Text(status[0].toUpperCase() + status.substring(1)),
                      backgroundColor: _statusColor(status).withOpacity(0.15),
                      labelStyle: TextStyle(color: _statusColor(status)),
                    ),
                  ),
                  DataCell(Row(
                    children: [
                      Tooltip(
                        message: 'Try Fulfill Now',
                        child: IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.blue),
                          onPressed: _isLoading
                              ? null
                              : () => _showFulfillDialog(context, item, idx),
                          autofocus: false,
                          focusColor: Colors.blue.shade100,
                        ),
                      ),
                      Tooltip(
                        message: 'Notify Procurement',
                        child: IconButton(
                          icon: const Icon(Icons.notifications,
                              color: Colors.orange),
                          onPressed: _isLoading
                              ? null
                              : () => _showProcurementDialog(context, item),
                          autofocus: false,
                          focusColor: Colors.orange.shade100,
                        ),
                      ),
                      Tooltip(
                        message: 'Mark as Resolved',
                        child: IconButton(
                          icon: const Icon(Icons.check_circle,
                              color: Colors.green),
                          onPressed: _isLoading
                              ? null
                              : () => _showResolutionDialog(context, item),
                          autofocus: false,
                          focusColor: Colors.green.shade100,
                        ),
                      ),
                    ],
                  )),
                ],
                // Add a row below for history/timeline if expanded
                // (Handled in the widget below the table)
              );
            }),
          ),
        );

    Widget buildExpandedRows() => Column(
          children: List.generate(backorderedItems.length, (idx) {
            if (_expandedRows[idx] == true) {
              return _buildItemHistory(backorderedItems[idx]);
            }
            return const SizedBox.shrink();
          }),
        );

    Widget buildBulkActions() {
      final selectedItems = _selectedRows
          .map((i) => backorderedItems[i] as Map<String, dynamic>)
          .toList();
      return Row(
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Bulk Fulfill'),
            onPressed: _isLoading || selectedItems.isEmpty
                ? null
                : () => _bulkAction(context, 'fulfill', selectedItems),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.notifications),
            label: const Text('Bulk Notify'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: _isLoading || selectedItems.isEmpty
                ? null
                : () => _bulkAction(context, 'notify', selectedItems),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('Bulk Resolve'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: _isLoading || selectedItems.isEmpty
                ? null
                : () => _bulkAction(context, 'resolve', selectedItems),
          ),
        ],
      );
    }

    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.orange, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2, color: Colors.orange),
                const SizedBox(width: 8),
                const Text('Backorder Management',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const Spacer(),
                Tooltip(
                  message: 'Refresh',
                  child: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() => _isLoading = true);
                            await ref
                                .read(orderProvider.notifier)
                                .fetchOrders();
                            setState(() => _isLoading = false);
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'The following items are currently backordered. You can attempt to fulfill, notify procurement, or mark as resolved.',
              style: TextStyle(color: Colors.orange.shade900, fontSize: 14),
            ),
            const SizedBox(height: 18),
            buildBulkActions(),
            const SizedBox(height: 12),
            ResponsiveBuilder(
              mobile: buildTable(),
              tablet: buildTable(),
              desktop: buildTable(),
            ),
            buildExpandedRows(),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
