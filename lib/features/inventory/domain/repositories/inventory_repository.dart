import '../entities/inventory_item.dart';

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
  Future<InventoryItem> adjustQuantity(
      String id, double adjustment, String reason);
  Future<List<InventoryItem>> getLowStockItems();
  Future<List<InventoryItem>> getItemsNeedingReorder();
  Future<List<InventoryItem>> getExpiringItems(DateTime before);
  Future<List<dynamic>> getItemMovementHistory(String id);

  // Search and filter operations
  Future<List<InventoryItem>> searchItems(String query);
  Future<List<InventoryItem>> filterItems({
    String? category,
    String? location,
    bool? lowStock,
    bool? needsReorder,
    bool? expired,
  });

  // Batch operations
  Future<void> batchUpdateItems(List<InventoryItem> items);
  Future<void> batchDeleteItems(List<String> ids);

  // Real-time operations
  Stream<List<InventoryItem>> watchAllItems();
  Stream<InventoryItem> watchItem(String id);
  Stream<List<InventoryItem>> watchLowStockItems();
}
