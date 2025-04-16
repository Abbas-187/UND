import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../models/inventory_item_model.dart';
import '../providers/dairy_inventory_provider.dart';

/// Repository implementation for dairy inventory using mock data
class DairyInventoryRepository implements InventoryRepository {
  DairyInventoryRepository({required this.dairyProvider});

  final DairyInventoryProvider dairyProvider;

  @override
  Future<List<InventoryItem>> getItems() async {
    return dairyProvider.getAllItems().map((item) => item.toDomain()).toList();
  }

  @override
  Future<InventoryItem?> getItem(String id) async {
    final item = dairyProvider.getItemById(id);
    return item?.toDomain();
  }

  @override
  Future<InventoryItem> addItem(InventoryItem item) async {
    // Convert domain entity to model - creating a basic model with essential info
    final model = InventoryItemModel(
      id: item.id,
      name: item.name,
      category: item.category,
      unit: item.unit,
      quantity: item.quantity,
      minimumQuantity: item.minimumQuantity,
      reorderPoint: item.reorderPoint,
      location: item.location,
      lastUpdated: item.lastUpdated,
      batchNumber: item.batchNumber,
      expiryDate: item.expiryDate,
      additionalAttributes: item.additionalAttributes,
      cost: item.cost,
      lowStockThreshold: item.lowStockThreshold,
    );

    dairyProvider.addItem(model);
    return model.toDomain();
  }

  @override
  Future<void> updateItem(InventoryItem item) async {
    // We need to preserve dairy-specific fields when updating
    final existingModel = dairyProvider.getItemById(item.id);
    if (existingModel == null) {
      throw Exception('Item not found');
    }

    // Update only basic fields, preserve dairy-specific ones
    final updatedModel = existingModel.copyWith(
      name: item.name,
      category: item.category,
      unit: item.unit,
      quantity: item.quantity,
      minimumQuantity: item.minimumQuantity,
      reorderPoint: item.reorderPoint,
      location: item.location,
      lastUpdated: DateTime.now(),
      batchNumber: item.batchNumber,
      expiryDate: item.expiryDate,
      additionalAttributes: item.additionalAttributes,
      cost: item.cost,
      lowStockThreshold: item.lowStockThreshold,
    );

    dairyProvider.updateItem(updatedModel);
  }

  @override
  Future<void> deleteItem(String id) async {
    dairyProvider.deleteItem(id);
  }

  @override
  Future<List<InventoryItem>> getItemsBelowReorderLevel() async {
    return dairyProvider
        .getItemsNeedingReorder()
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<List<InventoryItem>> getItemsAtCriticalLevel() async {
    return dairyProvider
        .getLowStockItems()
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<Map<String, double>> getInventoryValueByCategory() async {
    return dairyProvider.getInventoryValueByCategory();
  }

  @override
  Future<List<InventoryItem>> getTopMovingItems(int limit) async {
    // In mock implementation, just return first N items
    return dairyProvider
        .getAllItems()
        .take(limit)
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<List<InventoryItem>> getSlowMovingItems(int limit) async {
    // In mock implementation, just return last N items
    return dairyProvider
        .getAllItems()
        .reversed
        .take(limit)
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<InventoryItem> adjustQuantity(
      String id, double adjustment, String reason) async {
    dairyProvider.adjustQuantity(id, adjustment, reason);
    final item = dairyProvider.getItemById(id);
    if (item == null) {
      throw Exception('Item not found');
    }
    return item.toDomain();
  }

  @override
  Future<List<InventoryItem>> getLowStockItems() async {
    return dairyProvider
        .getLowStockItems()
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<List<InventoryItem>> getItemsNeedingReorder() async {
    return dairyProvider
        .getItemsNeedingReorder()
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<List<InventoryItem>> getExpiringItems(DateTime before) async {
    final daysUntil = before.difference(DateTime.now()).inDays;
    return dairyProvider
        .getExpiringItems(days: daysUntil)
        .map((item) => item.toDomain())
        .toList();
  }

  @override
  Future<List<dynamic>> getItemMovementHistory(String id) async {
    // Mock implementation - return empty list for now
    return [];
  }

  @override
  Future<List<InventoryItem>> searchItems(String query) async {
    return dairyProvider
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
    var items = dairyProvider.getAllItems();

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
      final existingModel = dairyProvider.getItemById(item.id);
      if (existingModel != null) {
        final updatedModel = existingModel.copyWith(
          name: item.name,
          category: item.category,
          unit: item.unit,
          quantity: item.quantity,
          minimumQuantity: item.minimumQuantity,
          reorderPoint: item.reorderPoint,
          location: item.location,
          lastUpdated: DateTime.now(),
          batchNumber: item.batchNumber,
          expiryDate: item.expiryDate,
          additionalAttributes: item.additionalAttributes,
          cost: item.cost,
          lowStockThreshold: item.lowStockThreshold,
        );
        dairyProvider.updateItem(updatedModel);
      }
    }
  }

  @override
  Future<void> batchDeleteItems(List<String> ids) async {
    for (final id in ids) {
      dairyProvider.deleteItem(id);
    }
  }

  @override
  Stream<List<InventoryItem>> watchAllItems() async* {
    // In mock implementation, just yield once
    yield dairyProvider.getAllItems().map((item) => item.toDomain()).toList();
  }

  @override
  Stream<InventoryItem> watchItem(String id) async* {
    // In mock implementation, just yield once if item exists
    final item = dairyProvider.getItemById(id);
    if (item != null) {
      yield item.toDomain();
    }
  }

  @override
  Stream<List<InventoryItem>> watchLowStockItems() async* {
    // In mock implementation, just yield once
    yield dairyProvider
        .getLowStockItems()
        .map((item) => item.toDomain())
        .toList();
  }

  /// Reset inventory to default state
  Future<void> resetInventory() async {
    await dairyProvider.resetInventory();
  }
}

/// Provider for dairy inventory repository
final dairyInventoryRepositoryProvider =
    Provider<DairyInventoryRepository>((ref) {
  final provider = ref.watch(dairyInventoryProvider);
  return DairyInventoryRepository(dairyProvider: provider);
});

/// Provider that exposes the dairy inventory repository as the general inventory repository
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return ref.watch(dairyInventoryRepositoryProvider);
});
