import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class UpdateOrderUseCase {

  UpdateOrderUseCase(this.repository);
  final OrderRepository repository;

  Future<OrderEntity> execute(OrderEntity order) async {
    return await repository.updateOrder(order);
  }
}
