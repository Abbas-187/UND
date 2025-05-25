import '../entities/order_entity.dart';
import '../repositories/inventory_repository.dart';
import '../repositories/order_repository.dart';

class FulfillOrderUseCase {
  FulfillOrderUseCase(this.orderRepository, this.inventoryRepository);
  final OrderRepository orderRepository;
  final InventoryRepository inventoryRepository;

  Future<OrderEntity> execute(OrderEntity order) async {
    final reserved = <Map<String, dynamic>>[];
    final fulfillmentUpdates = <Map<String, dynamic>>[];
    bool partial = false;
    try {
      for (var item in order.items) {
        final productId = item['productId'] as String;
        final quantity = (item['quantity'] as num).toDouble();
        final inv = await inventoryRepository.getInventory(productId);
        if (inv.availableQuantity >= quantity) {
          await inventoryRepository.reserveInventory(productId, quantity);
          reserved.add({'productId': productId, 'quantity': quantity});
          fulfillmentUpdates.add({
            'productId': productId,
            'fulfilledQuantity': quantity,
            'backorderedQuantity': 0.0,
            'fulfillmentStatus': 'fulfilled',
          });
        } else if (inv.availableQuantity > 0) {
          // Partial fulfillment
          await inventoryRepository.reserveInventory(
              productId, inv.availableQuantity);
          reserved
              .add({'productId': productId, 'quantity': inv.availableQuantity});
          fulfillmentUpdates.add({
            'productId': productId,
            'fulfilledQuantity': inv.availableQuantity,
            'backorderedQuantity': quantity - inv.availableQuantity,
            'fulfillmentStatus': 'backordered',
          });
          partial = true;
        } else {
          // No stock
          fulfillmentUpdates.add({
            'productId': productId,
            'fulfilledQuantity': 0.0,
            'backorderedQuantity': quantity,
            'fulfillmentStatus': 'backordered',
          });
          partial = true;
        }
      }
      // Update order with fulfillment/backorder info
      final updatedOrder = order.copyWith(
        partialFulfillment: partial,
        backorderedItems: fulfillmentUpdates
            .where((u) => u['fulfillmentStatus'] == 'backordered')
            .toList(),
        items: order.items.map((item) {
          final update = fulfillmentUpdates.firstWhere(
            (u) => u['productId'] == item['productId'],
            orElse: () => <String, dynamic>{},
          );
          if (update.isNotEmpty) {
            return {
              ...item,
              'fulfilledQuantity': update['fulfilledQuantity'],
              'backorderedQuantity': update['backorderedQuantity'],
              'fulfillmentStatus': update['fulfillmentStatus'],
            };
          }
          return item;
        }).toList(),
      );
      return await orderRepository.updateOrder(updatedOrder);
    } catch (e) {
      // Rollback: release all reserved items
      for (final r in reserved) {
        await inventoryRepository.releaseInventory(
            r['productId'] as String, r['quantity'] as double);
      }
      rethrow;
    }
  }
}
