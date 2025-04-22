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
import 'inventory_settings_screen.dart';
import '../../../reports/screens/report_screen.dart';
import '../../../reports/utils/report_aggregators.dart';
import '../../../../core/services/mock_data_service.dart';

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
              // Best Practice: Use a provider or service locator for dataService in production.
              // Now using Riverpod provider for MockDataService.
              final mockDataService = ref.watch(mockDataServiceProvider);
              final aggregators = ReportAggregators(mockDataService);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReportScreen(aggregators: aggregators),
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
