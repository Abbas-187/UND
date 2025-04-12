import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/inventory_item.dart';
import '../providers/inventory_provider.dart';
import '../widgets/inventory_analytics_card.dart';
import '../widgets/inventory_filter_bar.dart';
import '../widgets/inventory_item_card.dart';
import '../widgets/low_stock_alerts_banner.dart';
import 'inventory_analytics_dashboard_screen.dart';
import 'inventory_edit_screen.dart';
import 'inventory_item_details_screen.dart';
import 'inventory_reports_screen.dart';
import 'inventory_settings_screen.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filteredItems = ref.watch(filteredInventoryItemsProvider);
    final filter = ref.watch(inventoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inventoryManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InventorySettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.description),
            tooltip: l10n.inventoryReports,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InventoryReportsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InventoryAnalyticsDashboardScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InventoryEditScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Low stock alerts banner
          const LowStockAlertsBanner(),

          // Filter bar
          InventoryFilterBar(
            filter: filter,
            onFilterChanged: (newFilter) {
              ref.read(inventoryFilterProvider.notifier).state = newFilter;
            },
          ),

          // Analytics summary
          const InventoryAnalyticsCard(),

          // Inventory list
          Expanded(
            child: filteredItems.when(
              data: (items) => _buildInventoryList(context, items),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(l10n.errorWithMessage(error.toString())),
              ),
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
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return InventoryItemCard(
          item: item,
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
