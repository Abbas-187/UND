import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/inventory_item.dart';
import '../providers/inventory_provider.dart';
import '../widgets/inventory_analytics_card.dart';
import '../widgets/inventory_filter_bar.dart';
import '../widgets/inventory_item_card.dart';
import '../widgets/low_stock_alerts_banner.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filteredItems = ref.watch(filteredInventoryItemsProvider);
    final filter = ref.watch(inventoryFilterProvider);

    // Fetch unique values for filter dropdowns
    final uniqueCategories = ref.watch(uniqueCategoriesProvider);
    final uniqueSubCategories = ref.watch(uniqueSubCategoriesProvider);
    final uniqueLocations = ref.watch(uniqueLocationsProvider);
    final uniqueSuppliers = ref.watch(uniqueSuppliersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inventoryManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              context.go('/inventory/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.description),
            tooltip: l10n.inventoryReports,
            onPressed: () {
              context.go('/inventory/reports');
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              context.go('/inventory/analytics');
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.go('/inventory/edit');
            },
          ),
          IconButton(
            icon: const Icon(Icons.storage),
            tooltip: 'Database Management',
            onPressed: () {
              context.go('/inventory/database-management');
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Low stock alerts banner
          const LowStockAlertsBanner(),

          // Filter bar
          InventoryFilterBar(
            filter: filter,
            onFilterChanged: (newFilter) {
              ref.read(inventoryFilterProvider.notifier).state = newFilter;
            },
            availableCategories: uniqueCategories,
            availableSubCategories: uniqueSubCategories,
            availableLocations: uniqueLocations,
            availableSuppliers: uniqueSuppliers,
          ),

          // Analytics summary
          const InventoryAnalyticsCard(),

          // Inventory list
          filteredItems.when(
            data: (items) => _buildInventoryList(context, items),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(l10n.errorWithMessage(error.toString())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryList(BuildContext context, List<InventoryItem> items) {
    final l10n = AppLocalizations.of(context);

    if (items.isEmpty) {
      return Center(
        child: Text(l10n.noItemsFound),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return InventoryItemCard(
          item: item,
          onTap: () {
            context.go('/inventory/item-details/${item.id}');
          },
        );
      },
    );
  }
}
