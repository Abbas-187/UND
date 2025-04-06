import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/inventory_item.dart';
import '../providers/inventory_provider.dart';

class InventoryMovementHistoryScreen extends ConsumerStatefulWidget {

  const InventoryMovementHistoryScreen({
    super.key,
    required this.itemId,
  });
  final String itemId;

  @override
  ConsumerState<InventoryMovementHistoryScreen> createState() =>
      _InventoryMovementHistoryScreenState();
}

class _InventoryMovementHistoryScreenState
    extends ConsumerState<InventoryMovementHistoryScreen> {
  late Future<List<dynamic>> _movementsFuture;
  InventoryItem? _item;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(inventoryRepositoryProvider);

      // Load the item and its movement history in parallel
      final results = await Future.wait([
        repository.getItem(widget.itemId),
        repository.getItemMovementHistory(widget.itemId),
      ]);

      _item = results[0] as InventoryItem;
      _movementsFuture = Future.value(results[1] as List<dynamic>);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
      _movementsFuture = Future.error(e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_item != null
            ? '${_item!.name} - Movement History'
            : 'Movement History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<dynamic>>(
              future: _movementsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final movements = snapshot.data ?? [];

                if (movements.isEmpty) {
                  return const Center(
                    child: Text('No movement history available'),
                  );
                }

                return Column(
                  children: [
                    // Summary card
                    if (_item != null)
                      _buildSummaryCard(context, _item!, movements),

                    // Movements list
                    Expanded(
                      child: ListView.builder(
                        itemCount: movements.length,
                        itemBuilder: (context, index) {
                          return _buildMovementCard(context, movements[index]);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, InventoryItem item, List<dynamic> movements) {
    // Calculate total incoming and outgoing
    double totalIncoming = 0;
    double totalOutgoing = 0;

    for (final movement in movements) {
      final quantity = movement['quantity'] as double;
      if (quantity > 0) {
        totalIncoming += quantity;
      } else {
        totalOutgoing += quantity.abs();
      }
    }

    final netChange = totalIncoming - totalOutgoing;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text('Category: ${item.category}'),
            Text('Location: ${item.location}'),
            Text('Current Stock: ${item.quantity} ${item.unit}'),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryItem(
                  'Total In',
                  '+${totalIncoming.toString()} ${item.unit}',
                  Colors.green,
                ),
                _summaryItem(
                  'Total Out',
                  '-${totalOutgoing.toString()} ${item.unit}',
                  Colors.red,
                ),
                _summaryItem(
                  'Net Change',
                  '${netChange >= 0 ? '+' : ''}${netChange.toString()} ${item.unit}',
                  netChange >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${movements.length} movements recorded',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMovementCard(BuildContext context, dynamic movement) {
    final quantity = movement['quantity'] as double;
    final isAddition = quantity > 0;
    final timestamp = movement['timestamp'] as DateTime;
    final reason = movement['reason'] as String;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isAddition ? Icons.add_circle : Icons.remove_circle,
                      color: isAddition ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAddition ? 'Stock Added' : 'Stock Removed',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${isAddition ? '+' : ''}$quantity ${_item?.unit ?? ''}',
                  style: TextStyle(
                    color: isAddition ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            Text('Reason: $reason'),
            const SizedBox(height: 4),
            Text(
              'Date: ${_formatDateTime(timestamp)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
