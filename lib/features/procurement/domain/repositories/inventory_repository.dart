/// Repository interface for inventory operations.
abstract class InventoryRepository {
  /// Retrieves the current inventory level for a specific item.
  ///
  /// [itemId] - ID of the item to check
  /// Returns the current inventory quantity
  Future<double> getItemInventoryLevel(String itemId);

  /// Retrieves item details by ID.
  ///
  /// [itemId] - ID of the item
  /// Returns the item details
  Future<InventoryItem> getItemById(String itemId);
}

/// Simple model for inventory item details.
class InventoryItem {

  const InventoryItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.currentQuantity,
    required this.safetyStock,
    required this.reorderPoint,
  });
  final String id;
  final String name;
  final String unit;
  final double currentQuantity;
  final double safetyStock;
  final double reorderPoint;
}
