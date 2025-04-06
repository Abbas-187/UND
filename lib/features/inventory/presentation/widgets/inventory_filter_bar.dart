import 'package:flutter/material.dart';
import '../providers/inventory_provider.dart';

class InventoryFilterBar extends StatelessWidget {

  const InventoryFilterBar({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });
  final InventoryFilter filter;
  final ValueChanged<InventoryFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search inventory...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              onFilterChanged(filter.copyWith(searchQuery: value));
            },
          ),
          const SizedBox(height: 16),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Low Stock'),
                  selected: filter.showLowStock,
                  onSelected: (value) {
                    onFilterChanged(filter.copyWith(showLowStock: value));
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Needs Reorder'),
                  selected: filter.showNeedsReorder,
                  onSelected: (value) {
                    onFilterChanged(filter.copyWith(showNeedsReorder: value));
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Expiring Soon'),
                  selected: filter.showExpiringSoon,
                  onSelected: (value) {
                    onFilterChanged(filter.copyWith(showExpiringSoon: value));
                  },
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String?>(
                  initialValue: filter.selectedCategory,
                  onSelected: (category) {
                    onFilterChanged(
                        filter.copyWith(selectedCategory: category));
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...filter.availableCategories.map(
                      (category) => PopupMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    ),
                  ],
                  child: Chip(
                    label: Text(
                      filter.selectedCategory ?? 'All Categories',
                    ),
                    deleteIcon: filter.selectedCategory != null
                        ? const Icon(Icons.close, size: 18)
                        : null,
                    onDeleted: filter.selectedCategory != null
                        ? () {
                            onFilterChanged(
                                filter.copyWith(selectedCategory: null));
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String?>(
                  initialValue: filter.selectedLocation,
                  onSelected: (location) {
                    onFilterChanged(
                        filter.copyWith(selectedLocation: location));
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: null,
                      child: Text('All Locations'),
                    ),
                    ...filter.availableLocations.map(
                      (location) => PopupMenuItem(
                        value: location,
                        child: Text(location),
                      ),
                    ),
                  ],
                  child: Chip(
                    label: Text(
                      filter.selectedLocation ?? 'All Locations',
                    ),
                    deleteIcon: filter.selectedLocation != null
                        ? const Icon(Icons.close, size: 18)
                        : null,
                    onDeleted: filter.selectedLocation != null
                        ? () {
                            onFilterChanged(
                                filter.copyWith(selectedLocation: null));
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
