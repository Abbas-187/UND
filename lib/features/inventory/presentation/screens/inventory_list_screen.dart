import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../warehouse/presentation/screens/location_optimization_screen.dart';
import '../../../shared/presentation/widgets/optimized_list_view.dart';
import '../../../../core/data/optimized_repository.dart';
import '../../domain/providers/inventory_repository_provider.dart';
import '../providers/inventory_provider.dart';
import '../widgets/inventory_filter_bar.dart';
import '../widgets/inventory_item_card.dart';
import '../../domain/entities/inventory_item.dart';

class InventoryListScreen extends ConsumerWidget {
  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(inventoryFilterProvider);

    // Fetch unique values for filter dropdowns
    final uniqueCategories = ref.watch(uniqueCategoriesProvider);
    final uniqueSubCategories = ref.watch(uniqueSubCategoriesProvider);
    final uniqueLocations = ref.watch(uniqueLocationsProvider);
    final uniqueSuppliers = ref.watch(uniqueSuppliersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.inventory ?? 'Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationOptimizationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
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

          // Optimized list view
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final filteredItemsAsync =
                    ref.watch(filteredInventoryItemsProvider);

                return filteredItemsAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inventory_2,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              l10n?.noItemsFound ?? 'No items found',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters or add new inventory items',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(filteredInventoryItemsProvider);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
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
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading items',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(filteredInventoryItemsProvider);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/inventory/edit');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
