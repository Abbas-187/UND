import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/local/order_local_datasource.dart';
import '../datasources/remote/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {

  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  final OrderRemoteDataSource remoteDataSource;
  final OrderLocalDataSource localDataSource;

  @override
  Future<List<OrderEntity>> getOrders() async {
    final orders = await remoteDataSource.getOrders();
    await localDataSource.cacheOrders(orders);
    return orders;
  }

  @override
  Future<OrderEntity> getOrderById(String id) async {
    final cached = await localDataSource.getCachedOrderById(id);
    if (cached != null) return cached;
    final order = await remoteDataSource.getOrderById(id);
    await localDataSource.cacheOrder(order);
    return order;
  }

  @override
  Future<OrderEntity> createOrder(OrderEntity order) async {
    final created = await remoteDataSource.createOrder(order);
    await localDataSource.cacheOrder(created);
    return created;
  }

  @override
  Future<OrderEntity> updateOrder(OrderEntity order) async {
    final updated = await remoteDataSource.updateOrder(order);
    await localDataSource.cacheOrder(updated);
    return updated;
  }

  @override
  Future<void> cancelOrder(String id) async {
    final cancelled = await remoteDataSource.cancelOrder(id);
    await localDataSource.cacheOrder(cancelled);
  }

  @override
  Future<void> handleProcurementComplete(String id) async {
    final updated = await remoteDataSource.handleProcurementComplete(id);
    await localDataSource.cacheOrder(updated);
  }
}
