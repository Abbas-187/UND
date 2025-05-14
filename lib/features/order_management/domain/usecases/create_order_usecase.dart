import '../entities/order_entity.dart';
import '../repositories/inventory_repository.dart';
import '../repositories/order_repository.dart';

class CreateOrderUseCase {

  CreateOrderUseCase(this.orderRepository, this.inventoryRepository);
  final OrderRepository orderRepository;
  final InventoryRepository inventoryRepository;

  Future<OrderEntity> execute(OrderEntity order) async {
    // Reserve inventory for each item
    for (var item in order.items) {
      final productId = item['productId'] as String;
      final quantity = (item['quantity'] as num).toDouble();
      final inv = await inventoryRepository.getInventory(productId);
      if (inv.availableQuantity < quantity) {
        throw Exception('Insufficient stock for product $productId');
      }
      await inventoryRepository.reserveInventory(productId, quantity);
    }
    // Create the order after successful reservation
    final created = await orderRepository.createOrder(order);
    return created;
  }
}
