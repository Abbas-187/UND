import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../models/inventory_item_model.dart';

class MockInventoryRepository implements InventoryRepository {
  MockInventoryRepository({required this.mockDataService});

  final MockDataService mockDataService;

  @override
  Future<List<InventoryItem>> getItems() async {
    return mockDataService.inventoryItems
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<InventoryItem?> getItem(String id) async {
    try {
      final item =
          mockDataService.inventoryItems.firstWhere((item) => item.id == id);
      return item.toDomain();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<InventoryItem> addItem(InventoryItem item) async {
    // Convert domain entity to model
    final model = InventoryItemModel.fromDomain(item);
    mockDataService.inventoryItems.add(model);
    return model.toDomain();
  }

  @override
  Future<void> updateItem(InventoryItem item) async {
    final model = InventoryItemModel.fromDomain(item);
    mockDataService.updateInventoryItem(model);
  }

  @override
  Future<void> deleteItem(String id) async {
    mockDataService.inventoryItems.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<InventoryItem>> getItemsBelowReorderLevel() async {
    return mockDataService.inventoryItems
        .where((item) => item.quantity <= item.reorderPoint)
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<List<InventoryItem>> getItemsAtCriticalLevel() async {
    return mockDataService.inventoryItems
        .where((item) => item.quantity <= item.minimumQuantity)
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<Map<String, double>> getInventoryValueByCategory() async {
    final result = <String, double>{};

    for (final item in mockDataService.inventoryItems) {
      final category = item.category;
      final value = item.quantity * (item.cost ?? 0.0);

      if (result.containsKey(category)) {
        result[category] = result[category]! + value;
      } else {
        result[category] = value;
      }
    }

    return result;
  }

  @override
  Future<List<InventoryItem>> getTopMovingItems(int limit) async {
    // In mock implementation, just return first N items
    return mockDataService.inventoryItems
        .take(limit)
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<List<InventoryItem>> getSlowMovingItems(int limit) async {
    // In mock implementation, just return last N items
    return mockDataService.inventoryItems.reversed
        .take(limit)
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<InventoryItem> adjustQuantity(
      String id, double adjustment, String reason) async {
    mockDataService.adjustQuantity(id, adjustment, reason);
    final item =
        mockDataService.inventoryItems.firstWhere((item) => item.id == id);
    if (item == null) {
      throw Exception('Item not found');
    }
    return item.toDomain();
  }

  @override
  Future<List<InventoryItem>> getLowStockItems() async {
    return mockDataService.inventoryItems
        .where((item) => item.quantity <= item.minimumQuantity)
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<List<InventoryItem>> getItemsNeedingReorder() async {
    return mockDataService.inventoryItems
        .where((item) => item.quantity <= item.reorderPoint)
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<List<InventoryItem>> getExpiringItems(DateTime before) async {
    final daysUntil = before.difference(DateTime.now()).inDays;
    return mockDataService.inventoryItems
        .where((item) =>
            item.expiryDate != null &&
            item.expiryDate!
                .isBefore(DateTime.now().add(Duration(days: daysUntil))))
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
    return mockDataService.inventoryItems
        .where((item) =>
            item.name.toLowerCase().contains(query.toLowerCase()) ||
            item.category.toLowerCase().contains(query.toLowerCase()))
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
    var items = mockDataService.inventoryItems;

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
      mockDataService.updateInventoryItem(model);
    }
  }

  @override
  Future<void> batchDeleteItems(List<String> ids) async {
    for (final id in ids) {
      mockDataService.inventoryItems.removeWhere((item) => item.id == id);
    }
  }

  @override
  Stream<List<InventoryItem>> watchAllItems() async* {
    // In mock implementation, just yield once
    yield mockDataService.inventoryItems
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Stream<InventoryItem> watchItem(String id) async* {
    // In mock implementation, just yield once if item exists
    final item =
        mockDataService.inventoryItems.firstWhere((item) => item.id == id);
    if (item != null) {
      yield item.toDomain();
    }
  }

  @override
  Stream<List<InventoryItem>> watchLowStockItems() async* {
    // In mock implementation, just yield once
    yield mockDataService.inventoryItems
        .where((item) => item.quantity <= item.minimumQuantity)
        .map((item) => item.toDomain())
        .toList();
  }
}

// Provider for MockInventoryRepository
final mockInventoryRepositoryProvider =
    Provider<MockInventoryRepository>((ref) {
  final mockDataService = ref.watch(mockDataServiceProvider);
  return MockInventoryRepository(mockDataService: mockDataService);
});
