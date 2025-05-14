import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getOrders();
  Future<OrderEntity> getOrderById(String id);
  Future<OrderEntity> createOrder(OrderEntity order);
  Future<OrderEntity> updateOrder(OrderEntity order);
  Future<void> cancelOrder(String id);

  /// Handles marking an order as procurement complete.
  Future<void> handleProcurementComplete(String id);
}
