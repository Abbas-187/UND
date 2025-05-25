import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cost_layer.dart';
import '../../domain/entities/cost_method_setting.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../models/inventory_item_model.dart';
import '../models/inventory_movement_model.dart';
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
      appItemId: item.appItemId,
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
    final items = dairyProvider.getAllItems();

    // Group items by category and calculate total value
    final result = <String, double>{};
    for (final item in items) {
      final category = item.category;
      final value = (item.quantity * (item.cost ?? 0));

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
    // Get all items and sort by a movement metric
    // For this implementation, we'll use items with the greatest difference
    // between current quantity and reorder point as a proxy for movement
    final items = dairyProvider.getAllItems();

    // Sort by movement activity (using the gap between current and reorder)
    // A smaller gap means the item is moving faster (being consumed)
    items.sort((a, b) {
      final gapA = a.quantity - a.reorderPoint;
      final gapB = b.quantity - b.reorderPoint;
      return gapA.compareTo(gapB); // Ascending (smallest gaps first)
    });

    // Return top moving items (limited)
    return items.take(limit).map((item) => item.toDomain()).toList();
  }

  @override
  Future<List<InventoryItem>> getSlowMovingItems(int limit) async {
    // Get all items and sort by a movement metric (opposite of top moving)
    final items = dairyProvider.getAllItems();

    // Sort by lack of movement - items with the largest gap between
    // current quantity and reorder point are moving slower
    items.sort((a, b) {
      final gapA = a.quantity - a.reorderPoint;
      final gapB = b.quantity - b.reorderPoint;
      return gapB.compareTo(gapA); // Descending (largest gaps first)
    });

    // Return slow moving items (limited)
    return items.take(limit).map((item) => item.toDomain()).toList();
  }

  @override
  Future<InventoryItem> adjustQuantity(String id, double adjustment,
      String reason, String initiatingEmployeeId) async {
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
    String? subCategory,
    String? location,
    String? supplier,
    bool? lowStock,
    bool? needsReorder,
    bool? expired,
  }) async {
    var items = dairyProvider.getAllItems();

    if (category != null) {
      items = items.where((item) => item.category == category).toList();
    }

    if (subCategory != null) {
      items = items.where((item) => item.subCategory == subCategory).toList();
    }

    if (supplier != null) {
      items = items
          .where((item) => item.additionalAttributes?['supplier'] == supplier)
          .toList();
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

  @override
  Future<List<InventoryItem>> getMostExpensiveItems(int limit) async {
    final items = await getItems();
    items.sort((a, b) => (b.cost ?? 0).compareTo(a.cost ?? 0));
    return items.take(limit).toList();
  }

  @override
  Future<int> countItemsBySupplier(String supplier) async {
    final items = await getItems();
    return items.where((item) => item.supplier == supplier).length;
  }

  @override
  Future<int> countRecipesUsingItem(String itemId) async {
    // TODO: implement real query to count recipes
    return 0;
  }

  @override
  Future<bool> allocateInventoryForRecipe(
      String recipeId, double quantity) async {
    // Validate inputs
    if (recipeId.isEmpty || quantity <= 0) {
      return false;
    }

    // Check inventory availability
    final requiredItems = dairyProvider.getRecipeIngredients(recipeId);
    if (requiredItems == null || requiredItems.isEmpty) {
      return false;
    }

    for (final ingredient in requiredItems) {
      final inventoryItem = dairyProvider.getItemById(ingredient.id);
      if (inventoryItem == null ||
          inventoryItem.quantity < ingredient.quantity * quantity) {
        return false; // Not enough inventory
      }
    }

    // Deduct inventory
    for (final ingredient in requiredItems) {
      final inventoryItem = dairyProvider.getItemById(ingredient.id);
      if (inventoryItem != null) {
        dairyProvider.adjustQuantity(
          ingredient.id,
          -(ingredient.quantity * quantity),
          'Allocated for recipe $recipeId',
        );
      }
    }

    return true; // Allocation successful
  }

  // --- BEGIN: InventoryRepository required stubs ---
  @override
  Future<String> addMovement(InventoryMovementModel movement) {
    throw UnimplementedError(
        'addMovement is not implemented in DairyInventoryRepository');
  }

  @override
  Future<InventoryMovementModel?> getMovement(String movementId) {
    throw UnimplementedError(
        'getMovement is not implemented in DairyInventoryRepository');
  }

  @override
  Future<List<InventoryMovementModel>> getMovementsForItem(String itemId) {
    throw UnimplementedError(
        'getMovementsForItem is not implemented in DairyInventoryRepository');
  }

  @override
  Future<List<InventoryMovementModel>> getInboundMovementsForItem(
      String itemId) {
    throw UnimplementedError(
        'getInboundMovementsForItem is not implemented in DairyInventoryRepository');
  }

  @override
  Future<List<InventoryMovementModel>> getMovementsForWarehouse(
      String warehouseId) {
    throw UnimplementedError(
        'getMovementsForWarehouse is not implemented in DairyInventoryRepository');
  }

  @override
  Future<void> updateMovement(InventoryMovementModel movement) {
    throw UnimplementedError(
        'updateMovement is not implemented in DairyInventoryRepository');
  }

  @override
  Future<void> deleteMovement(String movementId) {
    throw UnimplementedError(
        'deleteMovement is not implemented in DairyInventoryRepository');
  }

  @override
  Future<InventoryItem?> getInventoryItem(String itemId) {
    throw UnimplementedError(
        'getInventoryItem is not implemented in DairyInventoryRepository');
  }

  @override
  Future<void> updateInventoryItem(InventoryItem item) {
    throw UnimplementedError(
        'updateInventoryItem is not implemented in DairyInventoryRepository');
  }

  @override
  Future<List<InventoryItem>> getInventoryItems(String warehouseId) {
    throw UnimplementedError(
        'getInventoryItems is not implemented in DairyInventoryRepository');
  }

  @override
  Future<double> getCurrentStockQuantity(String itemId, String warehouseId) {
    throw UnimplementedError(
        'getCurrentStockQuantity is not implemented in DairyInventoryRepository');
  }

  @override
  Future<List<CostLayer>> getAvailableCostLayers(
      String itemId, String warehouseId, CostingMethod costingMethod) {
    throw UnimplementedError(
        'getAvailableCostLayers is not implemented in DairyInventoryRepository');
  }

  @override
  Future<double?> getItemWeightedAverageCost(
      String itemId, String warehouseId) {
    throw UnimplementedError(
        'getItemWeightedAverageCost is not implemented in DairyInventoryRepository');
  }

  @override
  Future<double> getItemCurrentQuantity(String itemId, String warehouseId) {
    throw UnimplementedError(
        'getItemCurrentQuantity is not implemented in DairyInventoryRepository');
  }

  @override
  Future<void> updateCostLayers(
      InventoryMovementModel movement, CostingMethod costingMethod) {
    throw UnimplementedError(
        'updateCostLayers is not implemented in DairyInventoryRepository');
  }

  @override
  Future<CostMethodSetting> getCostingMethodSetting(String? warehouseId) {
    throw UnimplementedError(
        'getCostingMethodSetting is not implemented in DairyInventoryRepository');
  }

  @override
  Future<void> updateCostingMethodSetting(CostMethodSetting setting) {
    throw UnimplementedError(
        'updateCostingMethodSetting is not implemented in DairyInventoryRepository');
  }

  @override
  Future<Map<String, InventoryValuation>> getInventoryValuation(
      {required String warehouseId,
      required CostingMethod costingMethod,
      List<String>? itemIds,
      String? categoryId}) {
    throw UnimplementedError(
        'getInventoryValuation is not implemented in DairyInventoryRepository');
  }

  @override
  Future<List<PickingSuggestion>> getPickingSuggestions(
      {required String itemId,
      required String warehouseId,
      required double quantity,
      required PickingStrategy strategy}) {
    throw UnimplementedError(
        'getPickingSuggestions is not implemented in DairyInventoryRepository');
  }

  @override
  Future<Warehouse?> getWarehouse(String id) {
    throw UnimplementedError(
        'getWarehouse is not implemented in DairyInventoryRepository');
  }

  @override
  Future<List<Warehouse>> getWarehouses() {
    throw UnimplementedError(
        'getWarehouses is not implemented in DairyInventoryRepository');
  }

  @override
  Future<CompanySettings?> getCompanySettings() {
    throw UnimplementedError(
        'getCompanySettings is not implemented in DairyInventoryRepository');
  }

  @override
  Future<void> saveCompanySettings(CompanySettings settings) {
    throw UnimplementedError(
        'saveCompanySettings is not implemented in DairyInventoryRepository');
  }

  @override
  Future<InventoryMovementModel> saveMovement(InventoryMovementModel movement) {
    throw UnimplementedError(
        'saveMovement is not implemented in DairyInventoryRepository');
  }

  @override
  Future<void> updateInventoryQuantity(
      String itemId, String warehouseId, double quantityChange) {
    throw UnimplementedError(
        'updateInventoryQuantity is not implemented in DairyInventoryRepository');
  }

  @override
  Future<void> saveCostLayer(CostLayer layer) {
    throw UnimplementedError(
        'saveCostLayer is not implemented in DairyInventoryRepository');
  }

  @override
  Future<void> deleteCostLayer(String id) {
    throw UnimplementedError(
        'deleteCostLayer is not implemented in DairyInventoryRepository');
  }

  @override
  Future<void> saveCostLayerConsumption(CostLayerConsumption consumption) {
    throw UnimplementedError(
        'saveCostLayerConsumption is not implemented in DairyInventoryRepository');
  }

  @override
  Future<List<CostLayerConsumption>> getCostLayerConsumptions(String itemId) {
    throw UnimplementedError(
        'getCostLayerConsumptions is not implemented in DairyInventoryRepository');
  }

  @override
  Future<List<ItemCostHistoryEntry>> getItemCostHistory(
      String itemId, DateTime startDate, DateTime endDate) {
    throw UnimplementedError(
        'getItemCostHistory is not implemented in DairyInventoryRepository');
  }
  // --- END: InventoryRepository required stubs ---
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
