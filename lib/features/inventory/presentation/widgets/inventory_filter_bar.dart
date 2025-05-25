import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/inventory_provider.dart';

class InventoryFilterBar extends ConsumerWidget {
  const InventoryFilterBar({
    super.key,
    required this.filter,
    required this.onFilterChanged,
    required this.availableCategories,
    required this.availableSubCategories,
    required this.availableLocations,
    required this.availableSuppliers,
  });

  final InventoryFilter filter;
  final ValueChanged<InventoryFilter> onFilterChanged;
  final List<String> availableCategories;
  final List<String> availableSubCategories;
  final List<String> availableLocations;
  final List<String> availableSuppliers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: l10n?.searchInventory ?? 'Search inventory',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              isDense: true,
            ),
            onChanged: (value) {
              onFilterChanged(filter.copyWith(searchQuery: value));
            },
          ),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: [
              _buildDropdown(
                  context: context,
                  hintText: l10n?.filterByCategory ?? 'Filter by category',
                  value: filter.selectedCategory,
                  items: availableCategories,
                  onChanged: (value) {
                    onFilterChanged(filter.copyWith(
                        selectedCategory: value,
                        selectedSubCategory:
                            null)); // Reset subcategory when category changes
                  },
                  onClear: () {
                    onFilterChanged(filter.copyWith(
                        selectedCategory: null,
                        selectedSubCategory: null)); // Also clear subcategory
                  }),
              if (filter.selectedCategory != null &&
                  availableSubCategories.isNotEmpty)
                _buildDropdown(
                    context: context,
                    hintText:
                        l10n?.filterBySubCategory ?? 'Filter by sub-category',
                    value: filter.selectedSubCategory,
                    items: availableSubCategories,
                    onChanged: (value) {
                      onFilterChanged(
                          filter.copyWith(selectedSubCategory: value));
                    },
                    onClear: () {
                      onFilterChanged(
                          filter.copyWith(selectedSubCategory: null));
                    }),
              _buildDropdown(
                  context: context,
                  hintText: l10n?.filterByLocation ?? 'Filter by location',
                  value: filter.selectedLocation,
                  items: availableLocations,
                  onChanged: (value) {
                    onFilterChanged(filter.copyWith(selectedLocation: value));
                  },
                  onClear: () {
                    onFilterChanged(filter.copyWith(selectedLocation: null));
                  }),
              _buildDropdown(
                  context: context,
                  hintText: l10n?.filterBySupplier ?? 'Filter by supplier',
                  value: filter.selectedSupplier,
                  items: availableSuppliers,
                  onChanged: (value) {
                    onFilterChanged(filter.copyWith(selectedSupplier: value));
                  },
                  onClear: () {
                    onFilterChanged(filter.copyWith(selectedSupplier: null));
                  }),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n?.filterOptions ?? 'Filter options',
                  style: theme.textTheme.titleSmall),
              TextButton(
                onPressed: () {
                  // Reset all filters, but keep available options
                  onFilterChanged(InventoryFilter(
                    availableCategories: filter.availableCategories,
                    availableSubCategories: filter.availableSubCategories,
                    availableLocations: filter.availableLocations,
                    availableSuppliers: filter.availableSuppliers,
                  ));
                },
                child: Text(l10n?.clearAllFilters ?? 'Clear all filters'),
              )
            ],
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 0,
            children: [
              FilterChip(
                label: Text(l10n?.lowStock ?? 'Low stock'),
                selected: filter.showLowStock,
                onSelected: (selected) {
                  onFilterChanged(filter.copyWith(showLowStock: selected));
                },
              ),
              FilterChip(
                label: Text(l10n?.needsReorder ?? 'Needs reorder'),
                selected: filter.showNeedsReorder,
                onSelected: (selected) {
                  onFilterChanged(filter.copyWith(showNeedsReorder: selected));
                },
              ),
              FilterChip(
                label: Text(l10n?.expiringSoonShort ?? 'Expiring soon'),
                selected: filter.showExpiringSoon,
                onSelected: (selected) {
                  onFilterChanged(filter.copyWith(showExpiringSoon: selected));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String hintText,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required VoidCallback onClear,
  }) {
    final l10n = AppLocalizations.of(context);
    final uniqueItems = items.toSet().toList();

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 200),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          suffixIcon: value != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: onClear,
                  tooltip: l10n?.clearSelection ?? 'Clear selection',
                )
              : null,
        ),
        value: value,
        items: uniqueItems.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
      ),
    );
  }
}
