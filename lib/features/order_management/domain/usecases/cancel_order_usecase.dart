import '../repositories/inventory_repository.dart';
import '../repositories/order_repository.dart';

class CancelOrderUseCase {

  CancelOrderUseCase(this.orderRepository, this.inventoryRepository);
  final OrderRepository orderRepository;
  final InventoryRepository inventoryRepository;

  /// Cancels an order and releases reserved inventory for its items.
  Future<void> execute(String id) async {
    // Fetch existing order to know items
    final order = await orderRepository.getOrderById(id);
    // Cancel the order in backend
    await orderRepository.cancelOrder(id);
    // Release inventory for each item
    for (var item in order.items) {
      final productId = item['productId'] as String;
      final quantity = (item['quantity'] as num).toDouble();
      await inventoryRepository.releaseInventory(productId, quantity);
    }
  }
}
