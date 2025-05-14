import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/inventory_movement_model.dart';
import '../entities/cost_layer.dart';
import '../entities/cost_method_setting.dart';
import '../entities/inventory_item.dart';
import '../entities/inventory_movement.dart';

/// Repository interface for inventory management
abstract class InventoryRepository {
  /// Gets all inventory items
  Future<List<InventoryItem>> getItems();

  /// Gets an inventory item by ID
  Future<InventoryItem?> getItem(String id);

  /// Adds a new inventory item
  Future<InventoryItem> addItem(InventoryItem item);

  /// Updates an existing inventory item
  Future<void> updateItem(InventoryItem item);

  /// Deletes an inventory item
  Future<void> deleteItem(String id);

  /// Gets items below reorder level
  Future<List<InventoryItem>> getItemsBelowReorderLevel();

  /// Gets items at critical level
  Future<List<InventoryItem>> getItemsAtCriticalLevel();

  /// Gets inventory value by category
  Future<Map<String, double>> getInventoryValueByCategory();

  /// Gets top moving items
  Future<List<InventoryItem>> getTopMovingItems(int limit);

  /// Gets slow moving items
  Future<List<InventoryItem>> getSlowMovingItems(int limit);

  // Inventory management operations
  /// Performs quantity adjustment and records movement with employee ID
  Future<InventoryItem> adjustQuantity(
    String id,
    double adjustment,
    String reason,
    String initiatingEmployeeId,
  );
  Future<List<InventoryItem>> getLowStockItems();
  Future<List<InventoryItem>> getItemsNeedingReorder();
  Future<List<InventoryItem>> getExpiringItems(DateTime before);
  Future<List<dynamic>> getItemMovementHistory(String id);

  // Search and filter operations
  Future<List<InventoryItem>> searchItems(String query);
  Future<List<InventoryItem>> filterItems({
    String? category,
    String? subCategory, // added subCategory
    String? location,
    String? supplier, // added supplier filter
    bool? lowStock,
    bool? needsReorder,
    bool? expired,
  });

  /// Get most expensive items (by cost)
  Future<List<InventoryItem>> getMostExpensiveItems(int limit);

  /// Count how many items exist for a given supplier
  Future<int> countItemsBySupplier(String supplier);

  /// Count how many recipes reference a given inventory item
  Future<int> countRecipesUsingItem(String itemId);

  // Batch operations
  Future<void> batchUpdateItems(List<InventoryItem> items);
  Future<void> batchDeleteItems(List<String> ids);

  // Real-time operations
  Stream<List<InventoryItem>> watchAllItems();
  Stream<InventoryItem> watchItem(String id);
  Stream<List<InventoryItem>> watchLowStockItems();

  /// Add a new inventory movement
  Future<String> addMovement(InventoryMovementModel movement);

  /// Get a specific inventory movement by ID
  Future<InventoryMovementModel?> getMovement(String movementId);

  /// Get all inventory movements for a specific item
  Future<List<InventoryMovementModel>> getMovementsForItem(String itemId);

  /// Get all inbound inventory movements for a specific item (for FIFO/LIFO costing)
  Future<List<InventoryMovementModel>> getInboundMovementsForItem(
      String itemId);

  /// Get all inventory movements for a specific warehouse
  Future<List<InventoryMovementModel>> getMovementsForWarehouse(
      String warehouseId);

  /// Update an existing inventory movement
  Future<void> updateMovement(InventoryMovementModel movement);

  /// Delete an inventory movement (should have strict permissions)
  Future<void> deleteMovement(String movementId);

  /// Get current inventory item with its details
  Future<InventoryItem?> getInventoryItem(String itemId);

  /// Update inventory item details
  Future<void> updateInventoryItem(InventoryItem item);

  /// Get all inventory items for a warehouse
  Future<List<InventoryItem>> getInventoryItems(String warehouseId);

  /// Get current stock quantity for an item
  Future<double> getCurrentStockQuantity(String itemId, String warehouseId);

  /// Get all available cost layers for an item based on FIFO/LIFO
  Future<List<CostLayer>> getAvailableCostLayers(
      String itemId, String warehouseId, CostingMethod costingMethod);

  /// Get the weighted average cost for an item in a warehouse
  Future<double?> getItemWeightedAverageCost(String itemId, String warehouseId);

  /// Get the current quantity of an item in a warehouse
  Future<double> getItemCurrentQuantity(String itemId, String warehouseId);

  /// Update or create cost layers for a movement
  Future<void> updateCostLayers(
    InventoryMovementModel movement,
    CostingMethod costingMethod,
  );

  /// Get the costing method for a warehouse or company
  Future<CostMethodSetting> getCostingMethodSetting(String? warehouseId);

  /// Update the costing method for a warehouse or company
  Future<void> updateCostingMethodSetting(CostMethodSetting setting);

  /// Get inventory valuation based on cost layers
  Future<Map<String, InventoryValuation>> getInventoryValuation({
    required String warehouseId,
    required CostingMethod costingMethod,
    List<String>? itemIds,
    String? categoryId,
  });

  /// Get picking suggestions for an item based on the specified strategy
  Future<List<PickingSuggestion>> getPickingSuggestions({
    required String itemId,
    required String warehouseId,
    required double quantity,
    required PickingStrategy strategy,
  });

  /// Get a warehouse by ID
  Future<Warehouse?> getWarehouse(String id);

  /// Get all warehouses
  Future<List<Warehouse>> getWarehouses();

  /// Get company settings
  Future<CompanySettings?> getCompanySettings();

  /// Save company settings
  Future<void> saveCompanySettings(CompanySettings settings);

  /// Save an inventory movement
  Future<InventoryMovementModel> saveMovement(InventoryMovementModel movement);

  /// Update inventory quantity for an item in a warehouse
  Future<void> updateInventoryQuantity(
      String itemId, String warehouseId, double quantityChange);

  /// Save a cost layer
  Future<void> saveCostLayer(CostLayer layer);

  /// Delete a cost layer
  Future<void> deleteCostLayer(String id);

  /// Save a cost layer consumption record
  Future<void> saveCostLayerConsumption(CostLayerConsumption consumption);

  /// Get cost layer consumption history for an item
  Future<List<CostLayerConsumption>> getCostLayerConsumptions(String itemId);

  /// Get a list of item cost history
  /// Returns a time series of costs for an item
  Future<List<ItemCostHistoryEntry>> getItemCostHistory(
    String itemId,
    DateTime startDate,
    DateTime endDate,
  );
}

/// Inventory valuation for a single item
class InventoryValuation {

  InventoryValuation({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.quantity,
    required this.totalValue,
    required this.averageCost,
    required this.costLayers,
  });
  final String itemId;
  final String itemCode;
  final String itemName;
  final double quantity;
  final double totalValue;
  final double averageCost;
  final List<CostLayer> costLayers;
}

/// Strategy for picking inventory items
enum PickingStrategy {
  fefo, // First Expired, First Out
  fifo, // First In, First Out
  lifo, // Last In, First Out
  custom, // Custom picking logic
}

/// A suggestion for picking inventory
class PickingSuggestion {

  PickingSuggestion({
    required this.itemId,
    this.batchLotNumber,
    required this.receivedDate,
    this.expirationDate,
    required this.availableQuantity,
    required this.suggestedQuantity,
    required this.locationId,
    required this.locationName,
    required this.daysInStock,
    required this.originalMovementId,
    required this.layerId,
  });
  final String itemId;
  final String? batchLotNumber;
  final DateTime receivedDate;
  final DateTime? expirationDate;
  final double availableQuantity;
  final double suggestedQuantity;
  final String locationId;
  final String locationName;
  final double daysInStock;
  final String originalMovementId;
  final String layerId;
}

/// Simple warehouse model for the repository
class Warehouse {

  const Warehouse({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
  });
  final String id;
  final String name;
  final String? description;
  final bool isActive;
}

/// Model for item cost history entries
class ItemCostHistoryEntry {

  const ItemCostHistoryEntry({
    required this.itemId,
    required this.date,
    required this.quantity,
    required this.cost,
    required this.totalValue,
    this.movementId,
    required this.costingMethod,
  });
  final String itemId;
  final DateTime date;
  final double quantity;
  final double cost;
  final double totalValue;
  final String? movementId;
  final CostingMethod costingMethod;
}

// Provider for the repository
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  throw UnimplementedError('Implement this in the data layer');
});
