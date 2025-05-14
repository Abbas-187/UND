import '../entities/inventory_item.dart';

/// Defines inventory operations: fetch stock, reserve and release
abstract class InventoryRepository {
  Future<InventoryItem> getInventory(String productId);
  Future<void> reserveInventory(String productId, double quantity);
  Future<void> releaseInventory(String productId, double quantity);
}
