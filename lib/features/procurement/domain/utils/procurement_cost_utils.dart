import '../../data/models/purchase_order_model.dart';
import '../repositories/purchase_order_repository.dart';

/// Utility to fetch the latest delivered/completed PO unit price for an item
Future<double?> getLatestProcurementCost({
  required PurchaseOrderRepository purchaseOrderRepository,
  required String itemId,
}) async {
  final allOrders = await purchaseOrderRepository.getAllPurchaseOrders();
  final relevantOrders = allOrders
      .where((po) =>
          (po.status == 'delivered' || po.status == 'completed') &&
          po.items.any((i) => i.itemId == itemId))
      .toList();
  relevantOrders.sort((a, b) => (b.deliveryDate ?? DateTime(1970))
      .compareTo(a.deliveryDate ?? DateTime(1970)));
  for (final po in relevantOrders) {
    PurchaseOrderItemModel? item;
    try {
      item = po.items.firstWhere((i) => i.itemId == itemId);
    } catch (_) {
      item = null;
    }
    if (item != null && item.unitPrice > 0) {
      return item.unitPrice;
    }
  }
  return null;
}
