// Added import
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/analytics/inventory_analytics_service.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/providers/inventory_provider.dart';
import '../../domain/usecases/adjust_quantity_usecase.dart';
import '../../domain/usecases/get_inventory_analytics_usecase.dart';
import '../../domain/usecases/get_low_stock_alerts_usecase.dart';
import '../../domain/usecases/update_inventory_quality_status_usecase.dart';

// Use case providers
final adjustQuantityUseCaseProvider = Provider<AdjustQuantityUseCase>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return AdjustQuantityUseCase(repository);
});

final getLowStockAlertsUseCaseProvider =
    Provider<GetLowStockAlertsUseCase>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return GetLowStockAlertsUseCase(repository, ref);
});

final getInventoryAnalyticsUseCaseProvider =
    Provider<GetInventoryAnalyticsUseCase>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return GetInventoryAnalyticsUseCase(repository);
});

final updateInventoryQualityStatusUseCaseProvider =
    Provider<UpdateInventoryQualityStatusUseCase>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return UpdateInventoryQualityStatusUseCase(repository);
});

// Provider for InventoryAnalyticsService
final inventoryAnalyticsServiceProvider =
    Provider<InventoryAnalyticsService>((ref) {
  return InventoryAnalyticsService();
});

// Inventory Turnover for the last 30 days
final inventoryTurnoverProvider = FutureProvider<double>((ref) async {
  final analytics = ref.watch(inventoryAnalyticsServiceProvider);
  final now = DateTime.now();
  final start = now.subtract(const Duration(days: 30));
  return analytics.getInventoryTurnover(startDate: start, endDate: now);
});

// Stock Coverage (days on hand by category)
final stockCoverageProvider = FutureProvider<Map<String, double>>((ref) async {
  final analytics = ref.watch(inventoryAnalyticsServiceProvider);
  return analytics.getDaysOnHand();
});

// Inventory Trends (value over last 12 months)
final inventoryTrendsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final analytics = ref.watch(inventoryAnalyticsServiceProvider);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month - 11, 1);
  // Map<String, List<TimeSeriesPoint>>
  final trends =
      await analytics.getInventoryLevelTrends(startDate: start, endDate: now);
  // Flatten to List<Map<String, dynamic>>
  final List<Map<String, dynamic>> result = [];
  trends.forEach((category, points) {
    for (final point in points) {
      result.add({
        'category': category,
        'date': point.date,
        'value': point.value,
      });
    }
  });
  return result;
});

// Filter class
class InventoryFilter {
  const InventoryFilter({
    this.searchQuery = '',
    this.showLowStock = false,
    this.showNeedsReorder = false,
    this.showExpiringSoon = false,
    this.selectedCategory,
    this.selectedSubCategory, // New
    this.selectedLocation,
    this.selectedSupplier, // New
    this.availableCategories = const [],
    this.availableSubCategories = const [], // New
    this.availableLocations = const [],
    this.availableSuppliers = const [], // New
  });
  final String searchQuery;
  final bool showLowStock;
  final bool showNeedsReorder;
  final bool showExpiringSoon;
  final String? selectedCategory;
  final String? selectedSubCategory; // New
  final String? selectedLocation;
  final String? selectedSupplier; // New
  final List<String> availableCategories;
  final List<String> availableSubCategories; // New
  final List<String> availableLocations;
  final List<String> availableSuppliers; // New

  InventoryFilter copyWith({
    String? searchQuery,
    bool? showLowStock,
    bool? showNeedsReorder,
    bool? showExpiringSoon,
    String? selectedCategory,
    String? selectedSubCategory, // New
    String? selectedLocation,
    String? selectedSupplier, // New
    List<String>? availableCategories,
    List<String>? availableSubCategories, // New
    List<String>? availableLocations,
    List<String>? availableSuppliers, // New
  }) {
    return InventoryFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      showLowStock: showLowStock ?? this.showLowStock,
      showNeedsReorder: showNeedsReorder ?? this.showNeedsReorder,
      showExpiringSoon: showExpiringSoon ?? this.showExpiringSoon,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedSubCategory:
          selectedSubCategory ?? this.selectedSubCategory, // New
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedSupplier: selectedSupplier ?? this.selectedSupplier, // New
      availableCategories: availableCategories ?? this.availableCategories,
      availableSubCategories:
          availableSubCategories ?? this.availableSubCategories, // New
      availableLocations: availableLocations ?? this.availableLocations,
      availableSuppliers: availableSuppliers ?? this.availableSuppliers, // New
    );
  }
}

// Filter provider
final inventoryFilterProvider = StateProvider<InventoryFilter>((ref) {
  return const InventoryFilter();
});

// Provider to get all inventory items without any filters
// This is useful for deriving filter options like unique categories, locations etc.
final allInventoryItemsStreamProvider =
    StreamProvider<List<InventoryItem>>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.watchAllItems();
});

// Providers for unique filter options
final uniqueCategoriesProvider = Provider<List<String>>((ref) {
  final allItemsAsyncValue = ref.watch(allInventoryItemsStreamProvider);
  return allItemsAsyncValue.when(
    data: (items) =>
        items.map((item) => item.category).toSet().toList()..sort(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final uniqueSubCategoriesProvider = Provider<List<String>>((ref) {
  final allItemsAsyncValue = ref.watch(allInventoryItemsStreamProvider);
  return allItemsAsyncValue.when(
    data: (items) => items
        .where((item) => item.subCategory.isNotEmpty) // Removed null check
        .map((item) => item.subCategory) // Removed null assertion
        .toSet()
        .toList()
      ..sort(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final uniqueLocationsProvider = Provider<List<String>>((ref) {
  final allItemsAsyncValue = ref.watch(allInventoryItemsStreamProvider);
  return allItemsAsyncValue.when(
    data: (items) =>
        items.map((item) => item.location).toSet().toList()..sort(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final uniqueSuppliersProvider = Provider<List<String>>((ref) {
  final allItemsAsyncValue = ref.watch(allInventoryItemsStreamProvider);
  return allItemsAsyncValue.when(
    data: (items) => items
        .where((item) => item.supplier != null && item.supplier!.isNotEmpty)
        .map((item) => item.supplier!)
        .toSet()
        .toList()
      ..sort(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Filtered items provider
final filteredInventoryItemsProvider =
    StreamProvider<List<InventoryItem>>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  final filter = ref.watch(inventoryFilterProvider);

  return repository.watchAllItems().map((items) {
    return items.where((item) {
      // Apply search filter
      if (filter.searchQuery.isNotEmpty) {
        final searchLower = filter.searchQuery.toLowerCase();
        bool matchesSearch = item.name.toLowerCase().contains(searchLower) ||
            item.category.toLowerCase().contains(searchLower) ||
            item.subCategory
                .toLowerCase()
                .contains(searchLower) || // Removed null-aware operator
            item.location.toLowerCase().contains(searchLower) ||
            (item.supplier?.toLowerCase().contains(searchLower) ?? false) ||
            (item.batchNumber?.toLowerCase().contains(searchLower) ?? false) ||
            (item.additionalAttributes?.entries.any((e) =>
                    e.value.toString().toLowerCase().contains(searchLower)) ??
                false);
        if (!matchesSearch) return false;
      }

      // Apply category filter
      if (filter.selectedCategory != null &&
          item.category != filter.selectedCategory) {
        return false;
      }

      // Apply subCategory filter
      if (filter.selectedSubCategory != null &&
          item.subCategory != filter.selectedSubCategory) {
        return false;
      }

      // Apply location filter
      if (filter.selectedLocation != null &&
          item.location != filter.selectedLocation) {
        return false;
      }

      // Apply supplier filter
      if (filter.selectedSupplier != null &&
          item.supplier != filter.selectedSupplier) {
        return false;
      }

      // Apply stock status filters
      if (filter.showLowStock &&
          (item.quantity > item.minimumQuantity &&
              item.quantity > item.lowStockThreshold)) {
        return false;
      }

      if (filter.showNeedsReorder && item.quantity > item.reorderPoint) {
        return false;
      }

      if (filter.showExpiringSoon && item.expiryDate != null) {
        final daysUntilExpiry =
            item.expiryDate!.difference(DateTime.now()).inDays;
        if (daysUntilExpiry > 30) {
          return false;
        }
      }

      return true;
    }).toList();
  });
});

// Analytics providers
final inventoryValueProvider = FutureProvider<Map<String, double>>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.getInventoryValueByCategory();
});

final topMovingItemsProvider = FutureProvider<List<InventoryItem>>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.getTopMovingItems(10);
});

final slowMovingItemsProvider = FutureProvider<List<InventoryItem>>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.getSlowMovingItems(10);
});
