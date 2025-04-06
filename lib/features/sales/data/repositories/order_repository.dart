import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../datasources/sales_data_source.dart';
import '../models/order_model.dart';
import 'customer_repository.dart'; // Need access to salesDataSourceProvider

part 'order_repository.g.dart';

// Interface
abstract class OrderRepository {
  Future<List<OrderModel>> getOrders({
    String? customerId,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<OrderModel> getOrderById(String id);
  Future<String> createOrder(OrderModel order);
  Future<void> updateOrder(OrderModel order);
  Future<void> updateOrderStatus(String orderId, OrderStatus status,
      {String? userId, String? notes});
  Future<void> deleteOrder(String orderId);
  Future<List<OrderModel>> searchOrders(String query);
}

// Implementation
class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._dataSource);
  final SalesDataSource _dataSource;

  @override
  Future<List<OrderModel>> getOrders({
    String? customerId,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      _dataSource.getOrders(
          customerId: customerId,
          status: status,
          startDate: startDate,
          endDate: endDate);

  @override
  Future<OrderModel> getOrderById(String id) => _dataSource.getOrderById(id);

  @override
  Future<String> createOrder(OrderModel order) =>
      _dataSource.createOrder(order);

  @override
  Future<void> updateOrder(OrderModel order) => _dataSource.updateOrder(order);

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status,
          {String? userId, String? notes}) =>
      _dataSource.updateOrderStatus(orderId, status,
          userId: userId, notes: notes);

  @override
  Future<void> deleteOrder(String orderId) => _dataSource.deleteOrder(orderId);

  @override
  Future<List<OrderModel>> searchOrders(String query) =>
      _dataSource.searchOrders(query);
}

// Provider for the repository
@riverpod
OrderRepository orderRepository(OrderRepositoryRef ref) {
  final dataSource = ref.watch(salesDataSourceProvider);
  return OrderRepositoryImpl(dataSource);
}
