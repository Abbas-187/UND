import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class UpdateOrderUseCase {
  UpdateOrderUseCase(this.repository);
  final OrderRepository repository;

  Future<OrderEntity> execute(OrderEntity order) async {
    return await repository.updateOrder(order);
  }

  Future<OrderEntity> partialFulfillment(
      OrderEntity order, List<Map<String, dynamic>> fulfillmentUpdates) async {
    // fulfillmentUpdates: [{productId, fulfilledQuantity, backorderedQuantity, fulfillmentStatus}]
    final updatedItems = order.items.map((item) {
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
    }).toList();
    final backorderedItems = updatedItems
        .where((item) => item['fulfillmentStatus'] == 'backordered')
        .toList();
    final updatedOrder = order.copyWith(
      items: updatedItems,
      partialFulfillment: true,
      backorderedItems: backorderedItems,
    );
    return await repository.updateOrder(updatedOrder);
  }
}
