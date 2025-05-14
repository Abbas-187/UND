import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase {

  GetOrdersUseCase(this.repository);
  final OrderRepository repository;

  Future<List<OrderEntity>> execute() async {
    return await repository.getOrders();
  }
}
