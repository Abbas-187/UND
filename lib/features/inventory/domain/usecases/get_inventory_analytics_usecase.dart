import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class InventoryAnalytics {

  InventoryAnalytics({
    required this.valueByCategory,
    required this.topMovingItems,
    required this.slowMovingItems,
    required this.totalItems,
    required this.lowStockItems,
    required this.expiringItems,
    required this.totalValue,
  });
  final Map<String, double> valueByCategory;
  final List<InventoryItem> topMovingItems;
  final List<InventoryItem> slowMovingItems;
  final int totalItems;
  final int lowStockItems;
  final int expiringItems;
  final double totalValue;
}

class GetInventoryAnalyticsUseCase {

  GetInventoryAnalyticsUseCase(this.repository);
  final InventoryRepository repository;

  Future<InventoryAnalytics> execute({int movingItemsLimit = 10}) async {
    // Get all required data in parallel
    final results = await Future.wait([
      repository.getInventoryValueByCategory(),
      repository.getTopMovingItems(movingItemsLimit),
      repository.getSlowMovingItems(movingItemsLimit),
      repository.getItems(),
      repository.getLowStockItems(),
      repository.getExpiringItems(DateTime.now().add(const Duration(days: 30))),
    ]);

    final valueByCategory = results[0] as Map<String, double>;
    final topMovingItems = results[1] as List<InventoryItem>;
    final slowMovingItems = results[2] as List<InventoryItem>;
    final allItems = results[3] as List<InventoryItem>;
    final lowStockItems = results[4] as List<InventoryItem>;
    final expiringItems = results[5] as List<InventoryItem>;

    // Calculate total value
    final totalValue = valueByCategory.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );

    return InventoryAnalytics(
      valueByCategory: valueByCategory,
      topMovingItems: topMovingItems,
      slowMovingItems: slowMovingItems,
      totalItems: allItems.length,
      lowStockItems: lowStockItems.length,
      expiringItems: expiringItems.length,
      totalValue: totalValue,
    );
  }

  Stream<InventoryAnalytics> watchAnalytics({int movingItemsLimit = 10}) {
    return repository.watchAllItems().map((items) {
      final lowStockItems = items.where((item) => item.isLowStock).toList();
      final expiringItems = items
          .where((item) =>
              item.expiryDate != null &&
              item.expiryDate!.isBefore(
                DateTime.now().add(const Duration(days: 30)),
              ))
          .toList();

      // Calculate value by category
      final valueByCategory = <String, double>{};
      for (final item in items) {
        final value = item.quantity *
            (item.additionalAttributes?['unitValue']?.toDouble() ?? 0.0);
        valueByCategory.update(
          item.category,
          (existing) => existing + value,
          ifAbsent: () => value,
        );
      }

      final totalValue =
          valueByCategory.values.fold<double>(0, (sum, value) => sum + value);

      // Sort items by movement (using quantity as a simple metric)
      final sortedItems = List<InventoryItem>.from(items)
        ..sort((a, b) => b.quantity.compareTo(a.quantity));

      return InventoryAnalytics(
        valueByCategory: valueByCategory,
        topMovingItems: sortedItems.take(movingItemsLimit).toList(),
        slowMovingItems: sortedItems.reversed.take(movingItemsLimit).toList(),
        totalItems: items.length,
        lowStockItems: lowStockItems.length,
        expiringItems: expiringItems.length,
        totalValue: totalValue,
      );
    });
  }
}
