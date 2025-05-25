import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/providers/batch_operations_provider.dart';
import '../providers/inventory_provider.dart'
    show filteredInventoryItemsProvider;

class BatchInventoryScreen extends ConsumerStatefulWidget {
  const BatchInventoryScreen({super.key});

  @override
  ConsumerState<BatchInventoryScreen> createState() =>
      _BatchInventoryScreenState();
}

class _BatchInventoryScreenState extends ConsumerState<BatchInventoryScreen> {
  @override
  Widget build(BuildContext context) {
    final batchSelectionState = ref.watch(batchOperationsStateProvider);
    final inventoryAsync = ref.watch(filteredInventoryItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Operations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear Selection',
            onPressed: () {
              ref.read(batchOperationsStateProvider.notifier).clearSelection();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSelectionHeader(batchSelectionState),
          Expanded(
            child: inventoryAsync.when(
              data: (inventoryItems) {
                // Filter to only show selected items
                final selectedItems = inventoryItems
                    .where((item) =>
                        item.id != null &&
                        batchSelectionState.contains(item.id!))
                    .toList();

                if (selectedItems.isEmpty) {
                  return const Center(
                    child: Text(
                      'No items selected for batch operation.\nUse the scan button to add items.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: selectedItems.length,
                  itemBuilder: (context, index) {
                    final item = selectedItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Category: ${item.category}'),
                            Text('Quantity: ${item.quantity} ${item.unit}'),
                            if (item.batchNumber != null)
                              Text('Batch: ${item.batchNumber}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            ref
                                .read(batchOperationsStateProvider.notifier)
                                .toggleItemSelection(item.id!);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/inventory/batch-scan');
        },
        tooltip: 'Scan Barcode',
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  Widget _buildSelectionHeader(List<String> selectedItems) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Row(
        children: [
          const Icon(Icons.select_all),
          const SizedBox(width: 12),
          Text(
            'Selected Items: ${selectedItems.length}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              Icons.print,
              'Print Labels',
              _printLabels,
            ),
            _buildActionButton(
              Icons.move_to_inbox,
              'Transfer',
              _transferBatch,
            ),
            _buildActionButton(
              Icons.edit,
              'Adjust',
              _adjustBatch,
            ),
            _buildActionButton(
              Icons.delete,
              'Remove',
              _removeBatch,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printLabels() async {
    final batchSelection = ref.read(batchOperationsStateProvider);
    if (batchSelection.isEmpty) {
      _showNoItemsSelected();
      return;
    }

    try {
      await ref.read(batchOperationsStateProvider.notifier).printBatchLabels();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Printing labels...'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error printing labels: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _transferBatch() async {
    final batchSelection = ref.read(batchOperationsStateProvider);
    if (batchSelection.isEmpty) {
      _showNoItemsSelected();
      return;
    }

    // Show location selection dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer Items'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select destination location:'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Location ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement transfer functionality here
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transfer operation not implemented yet'),
                ),
              );
            },
            child: const Text('TRANSFER'),
          ),
        ],
      ),
    );
  }

  Future<void> _adjustBatch() async {
    final batchSelection = ref.read(batchOperationsStateProvider);
    if (batchSelection.isEmpty) {
      _showNoItemsSelected();
      return;
    }

    // Show adjustment dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust Quantities'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter adjustment details:'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Adjustment Factor',
                border: OutlineInputBorder(),
                hintText: 'e.g., 0.9 for 10% reduction',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement adjustment functionality here
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Adjustment operation not implemented yet'),
                ),
              );
            },
            child: const Text('ADJUST'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeBatch() async {
    final batchSelection = ref.read(batchOperationsStateProvider);
    if (batchSelection.isEmpty) {
      _showNoItemsSelected();
      return;
    }

    // Show removal confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Items'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to remove these items from inventory?',
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Implement removal functionality here
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Removal operation not implemented yet'),
                ),
              );
            },
            child: const Text(
              'REMOVE',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showNoItemsSelected() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No items selected for batch operation'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
