import '../entities/inventory_item.dart';

abstract class InventoryRepository {
  // Basic CRUD operations
  Future<InventoryItem> getItem(String id);
  Future<List<InventoryItem>> getAllItems();
  Future<List<InventoryItem>> getItemsByCategory(String category);
  Future<InventoryItem> addItem(InventoryItem item);
  Future<InventoryItem> updateItem(InventoryItem item);
  Future<void> deleteItem(String id);

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

  // Analytics operations
  Future<Map<String, double>> getInventoryValueByCategory();
  Future<List<InventoryItem>> getTopMovingItems(int limit);
  Future<List<InventoryItem>> getSlowMovingItems(int limit);

  // Real-time operations
  Stream<List<InventoryItem>> watchAllItems();
  Stream<InventoryItem> watchItem(String id);
  Stream<List<InventoryItem>> watchLowStockItems();
}
