import '../../../inventory/domain/entities/inventory_item.dart' as inv;
import '../entities/inventory_item.dart' as proc;

/// Maps an inventory feature InventoryItem to a procurement feature InventoryItem.
proc.InventoryItem mapInventoryToProcurement(inv.InventoryItem item) {
  return proc.InventoryItem(
    id: item.id,
    name: item.name,
    category: item.category,
    quantity: item.quantity,
    unit: item.unit,
    price: item.cost ?? 0,
    reorderPoint: item.reorderPoint,
    minimumQuantity: item.minimumQuantity,
    supplierIds: item.supplier != null ? [item.supplier!] : [],
  );
}
