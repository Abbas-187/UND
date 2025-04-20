import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/inventory_item.dart';
import '../providers/inventory_provider.dart';

class InventoryAnalyticsCard extends ConsumerWidget {
  const InventoryAnalyticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
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
              l10n.inventoryAnalytics,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Inventory value by category
            _buildSection(
              context,
              title: l10n.valueByCategory,
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
                            '${l10n.currencySymbol}${entry.value.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text(e.toString()),
              ),
            ),
            const SizedBox(height: 16),
            // Top moving items
            _buildSection(
              context,
              title: l10n.topMovingItems,
              content: topMovingItems.when(
                data: (items) => _buildItemList(items),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text(e.toString()),
              ),
            ),
            const SizedBox(height: 16),
            // Slow moving items
            _buildSection(
              context,
              title: l10n.slowMovingItems,
              content: slowMovingItems.when(
                data: (items) => _buildItemList(items),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text(e.toString()),
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
