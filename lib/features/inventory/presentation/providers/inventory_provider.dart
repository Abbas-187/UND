import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/usecases/adjust_quantity_usecase.dart';
import '../../domain/usecases/get_inventory_analytics_usecase.dart';
import '../../domain/usecases/get_low_stock_alerts_usecase.dart';
import '../../domain/analytics/inventory_analytics_service.dart';
import 'package:intl/intl.dart';
import '../../domain/providers/inventory_provider.dart';

// Use case providers
final adjustQuantityUseCaseProvider = Provider<AdjustQuantityUseCase>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return AdjustQuantityUseCase(repository);
});

final getLowStockAlertsUseCaseProvider =
    Provider<GetLowStockAlertsUseCase>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return GetLowStockAlertsUseCase(repository);
});

final getInventoryAnalyticsUseCaseProvider =
    Provider<GetInventoryAnalyticsUseCase>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return GetInventoryAnalyticsUseCase(repository);
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
    this.selectedLocation,
    this.availableCategories = const [],
    this.availableLocations = const [],
  });
  final String searchQuery;
  final bool showLowStock;
  final bool showNeedsReorder;
  final bool showExpiringSoon;
  final String? selectedCategory;
  final String? selectedLocation;
  final List<String> availableCategories;
  final List<String> availableLocations;

  InventoryFilter copyWith({
    String? searchQuery,
    bool? showLowStock,
    bool? showNeedsReorder,
    bool? showExpiringSoon,
    String? selectedCategory,
    String? selectedLocation,
    List<String>? availableCategories,
    List<String>? availableLocations,
  }) {
    return InventoryFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      showLowStock: showLowStock ?? this.showLowStock,
      showNeedsReorder: showNeedsReorder ?? this.showNeedsReorder,
      showExpiringSoon: showExpiringSoon ?? this.showExpiringSoon,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      availableCategories: availableCategories ?? this.availableCategories,
      availableLocations: availableLocations ?? this.availableLocations,
    );
  }
}

// Filter provider
final inventoryFilterProvider = StateProvider<InventoryFilter>((ref) {
  return const InventoryFilter();
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
        if (!item.name.toLowerCase().contains(searchLower) &&
            !item.category.toLowerCase().contains(searchLower) &&
            !item.location.toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      // Apply category filter
      if (filter.selectedCategory != null &&
          item.category != filter.selectedCategory) {
        return false;
      }

      // Apply location filter
      if (filter.selectedLocation != null &&
          item.location != filter.selectedLocation) {
        return false;
      }

      // Apply stock status filters
      if (filter.showLowStock && item.quantity > item.minimumQuantity) {
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
