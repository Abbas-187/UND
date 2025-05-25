import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../warehouse/presentation/screens/location_optimization_screen.dart';
import '../providers/inventory_provider.dart';
import '../widgets/inventory_filter_bar.dart';
import '../widgets/inventory_item_card.dart';

class InventoryListScreen extends ConsumerWidget {
  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filteredItemsAsyncValue = ref.watch(filteredInventoryItemsProvider);
    final filter = ref.watch(inventoryFilterProvider);

    // Fetch unique values for filter dropdowns
    final uniqueCategories = ref.watch(uniqueCategoriesProvider);
    final uniqueSubCategories = ref.watch(uniqueSubCategoriesProvider);
    final uniqueLocations = ref.watch(uniqueLocationsProvider);
    final uniqueSuppliers = ref.watch(uniqueSuppliersProvider);

    // Update the filter with available options if they haven't been set yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentFilter = ref.read(inventoryFilterProvider);
      bool needsUpdate = false;
      InventoryFilter updatedFilter = currentFilter;

      if (currentFilter.availableCategories.isEmpty &&
          uniqueCategories.isNotEmpty) {
        updatedFilter =
            updatedFilter.copyWith(availableCategories: uniqueCategories);
        needsUpdate = true;
      }
      if (currentFilter.availableSubCategories.isEmpty &&
          uniqueSubCategories.isNotEmpty) {
        updatedFilter =
            updatedFilter.copyWith(availableSubCategories: uniqueSubCategories);
        needsUpdate = true;
      }
      if (currentFilter.availableLocations.isEmpty &&
          uniqueLocations.isNotEmpty) {
        updatedFilter =
            updatedFilter.copyWith(availableLocations: uniqueLocations);
        needsUpdate = true;
      }
      if (currentFilter.availableSuppliers.isEmpty &&
          uniqueSuppliers.isNotEmpty) {
        updatedFilter =
            updatedFilter.copyWith(availableSuppliers: uniqueSuppliers);
        needsUpdate = true;
      }

      if (needsUpdate) {
        ref.read(inventoryFilterProvider.notifier).state = updatedFilter;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.apartment),
            tooltip: 'Optimize Location',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => LocationOptimizationScreen(),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Item',
            onPressed: () {
              context.go('/inventory/edit');
            },
          ),
        ],
      ),
      body: Column(
        children: [
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
          Expanded(
            child: filteredItemsAsyncValue.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(child: Text('No items found'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return InventoryItemCard(
                      item: item,
                      onTap: () {
                        context.go('/inventory/item-details/\${item.id}');
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text(
                  'Error loading items: ${error.toString()}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
