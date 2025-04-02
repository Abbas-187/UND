import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/inventory_item.dart';
import '../providers/inventory_provider.dart';

class InventoryAnalyticsCard extends ConsumerWidget {
  const InventoryAnalyticsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryValue = ref.watch(inventoryValueProvider);
    final topMovingItems = ref.watch(topMovingItemsProvider);
    final slowMovingItems = ref.watch(slowMovingItemsProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventory Analytics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Inventory value by category
            _buildSection(
              context,
              title: 'Value by Category',
              content: inventoryValue.when(
                data: (data) => Column(
                  children: data.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key),
                          Text(
                            '\$${entry.value.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text('Error: $error'),
              ),
            ),
            const Divider(),
            // Top moving items
            _buildSection(
              context,
              title: 'Top Moving Items',
              content: topMovingItems.when(
                data: (items) => _buildItemList(items),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text('Error: $error'),
              ),
            ),
            const Divider(),
            // Slow moving items
            _buildSection(
              context,
              title: 'Slow Moving Items',
              content: slowMovingItems.when(
                data: (items) => _buildItemList(items),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text('Error: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildItemList(List<InventoryItem> items) {
    return Column(
      children: items.map((item) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(item.name),
          subtitle: Text('${item.quantity} ${item.unit}'),
          trailing: Text(item.category),
        );
      }).toList(),
    );
  }
}
