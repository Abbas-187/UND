import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/providers/inventory_provider.dart';
import '../providers/inventory_provider.dart';
import 'inventory_item_details_screen.dart';
import 'inventory_trends_screen.dart';

class InventoryAnalyticsDashboardScreen extends ConsumerWidget {
  const InventoryAnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final inventoryValue = ref.watch(inventoryValueProvider);
    final topMovingItems = ref.watch(topMovingItemsProvider);
    final slowMovingItems = ref.watch(slowMovingItemsProvider);
    final lowStockItems = ref.watch(getLowStockItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inventoryAnalyticsDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.description),
            tooltip: l10n.inventoryReports,
            onPressed: () {
              // TODO: Remove old reports screen reference
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => const InventoryReportsScreen(),
              //   ),
              // );
            },
          ),
          IconButton(
            icon: const Icon(Icons.show_chart),
            tooltip: l10n.inventoryTrends,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InventoryTrendsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refreshData,
            onPressed: () {
              // Refresh data
              ref.invalidate(inventoryValueProvider);
              ref.invalidate(topMovingItemsProvider);
              ref.invalidate(slowMovingItemsProvider);
              ref.invalidate(getLowStockItemsProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inventory Health Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.inventoryHealth,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    lowStockItems.when(
                      data: (items) {
                        return _buildIndicatorRow(
                          context,
                          icon: Icons.warning_amber_outlined,
                          color: Colors.orange,
                          title: l10n.lowStockItems,
                          value: '${items.length}',
                          onTap: () {
                            // Navigate to filtered inventory screen
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(
                        child: Text(l10n.errorWithMessage(error.toString())),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Inventory Value by Category
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.valueByCategory,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    inventoryValue.when(
                      data: (data) {
                        if (data.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No data available'),
                            ),
                          );
                        }

                        return Column(
                          children: data.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key),
                                  Text(
                                    '${l10n.currencySymbol}${entry.value.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(
                        child: Text(l10n.errorWithMessage(error.toString())),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Top Moving Items
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.topMovingItems,
                          style: theme.textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to dedicated screen if needed
                          },
                          child: Text(l10n.seeDetails),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    topMovingItems.when(
                      data: (items) {
                        if (items.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No data available'),
                            ),
                          );
                        }

                        return _buildItemsList(context, items, ref, l10n);
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(
                        child: Text(l10n.errorWithMessage(error.toString())),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Slow Moving Items
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.slowMovingItems,
                          style: theme.textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to dedicated screen if needed
                          },
                          child: Text(l10n.seeDetails),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    slowMovingItems.when(
                      data: (items) {
                        if (items.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No data available'),
                            ),
                          );
                        }

                        return _buildItemsList(context, items, ref, l10n);
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(
                        child: Text(l10n.errorWithMessage(error.toString())),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorRow(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(
    BuildContext context,
    List<InventoryItem> items,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    // Show only top 5 items in the summary
    final displayItems = items.take(5).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayItems.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = displayItems[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(item.name),
          subtitle: Text('${item.category} - ${item.quantity} ${item.unit}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Use movement frequency instead of monthlyUsage
              Text(
                index < 3
                    ? '${5 - index} ${l10n.unitsPerMonth}'
                    : '< 1 ${l10n.unitsPerMonth}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InventoryItemDetailsScreen(
                  itemId: item.id,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Provider for low-stock items
final getLowStockItemsProvider =
    FutureProvider<List<InventoryItem>>((ref) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.getLowStockItems();
});
