import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../models/inventory_item_model.dart';
import '../providers/mock_inventory_provider.dart';

class MockInventoryRepository implements InventoryRepository {
  MockInventoryRepository({required this.mockProvider});

  final MockInventoryProvider mockProvider;

  @override
  Future<List<InventoryItem>> getItems() async {
    return mockProvider.getAllItems().map((item) => item.toDomain()).toList();
  }

  @override
  Future<InventoryItem?> getItem(String id) async {
    final item = mockProvider.getItemById(id);
    return item?.toDomain();
  }

  @override
  Future<InventoryItem> addItem(InventoryItem item) async {
    // Convert domain entity to model
    final model = InventoryItemModel.fromDomain(item);
    mockProvider.addItem(model);
    return model.toDomain();
  }

  @override
  Future<void> updateItem(InventoryItem item) async {
    final model = InventoryItemModel.fromDomain(item);
    mockProvider.updateItem(model);
  }

  @override
  Future<void> deleteItem(String id) async {
    mockProvider.deleteItem(id);
  }

  @override
  Future<List<InventoryItem>> getItemsBelowReorderLevel() async {
    return mockProvider
        .getItemsNeedingReorder()
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<List<InventoryItem>> getItemsAtCriticalLevel() async {
    return mockProvider
        .getLowStockItems()
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<Map<String, double>> getInventoryValueByCategory() async {
    return mockProvider.getInventoryValueByCategory();
  }

  @override
  Future<List<InventoryItem>> getTopMovingItems(int limit) async {
    // In mock implementation, just return first N items
    return mockProvider
        .getAllItems()
        .take(limit)
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<List<InventoryItem>> getSlowMovingItems(int limit) async {
    // In mock implementation, just return last N items
    return mockProvider
        .getAllItems()
        .reversed
        .take(limit)
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<InventoryItem> adjustQuantity(
      String id, double adjustment, String reason) async {
    mockProvider.adjustQuantity(id, adjustment, reason);
    final item = mockProvider.getItemById(id);
    if (item == null) {
      throw Exception('Item not found');
    }
    return item.toDomain();
  }

  @override
  Future<List<InventoryItem>> getLowStockItems() async {
    return mockProvider
        .getLowStockItems()
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<List<InventoryItem>> getItemsNeedingReorder() async {
    return mockProvider
        .getItemsNeedingReorder()
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<List<InventoryItem>> getExpiringItems(DateTime before) async {
    final daysUntil = before.difference(DateTime.now()).inDays;
    return mockProvider
        .getExpiringItems(days: daysUntil)
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<List<dynamic>> getItemMovementHistory(String id) async {
    // Mock implementation - return empty list
    return [];
  }

  @override
  Future<List<InventoryItem>> searchItems(String query) async {
    return mockProvider
        .searchItems(query)
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<List<InventoryItem>> filterItems({
    String? category,
    String? location,
    bool? lowStock,
    bool? needsReorder,
    bool? expired,
  }) async {
    var items = mockProvider.getAllItems();

    if (category != null) {
      items = items.where((item) => item.category == category).toList();
    }

    if (location != null) {
      items = items.where((item) => item.location == location).toList();
    }

    if (lowStock == true) {
      items =
          items.where((item) => item.quantity <= item.minimumQuantity).toList();
    }

    if (needsReorder == true) {
      items =
          items.where((item) => item.quantity <= item.reorderPoint).toList();
    }

    if (expired == true) {
      items = items
          .where((item) =>
              item.expiryDate != null &&
              item.expiryDate!.isBefore(DateTime.now()))
          .toList();
    }

    return items.map((item) => item.toDomain()).toList();
  }

  @override
  Future<void> batchUpdateItems(List<InventoryItem> items) async {
    for (final item in items) {
      final model = InventoryItemModel.fromDomain(item);
      mockProvider.updateItem(model);
    }
  }

  @override
  Future<void> batchDeleteItems(List<String> ids) async {
    for (final id in ids) {
      mockProvider.deleteItem(id);
    }
  }

  @override
  Stream<List<InventoryItem>> watchAllItems() async* {
    // In mock implementation, just yield once
    yield mockProvider.getAllItems().map((item) => item.toDomain()).toList();
  }

  @override
  Stream<InventoryItem> watchItem(String id) async* {
    // In mock implementation, just yield once if item exists
    final item = mockProvider.getItemById(id);
    if (item != null) {
      yield item.toDomain();
    }
  }

  @override
  Stream<List<InventoryItem>> watchLowStockItems() async* {
    // In mock implementation, just yield once
    yield mockProvider
        .getLowStockItems()
        .map((item) => item.toDomain())
        .toList();
  }
}
