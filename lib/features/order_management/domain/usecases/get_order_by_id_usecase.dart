import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrderByIdUseCase {

  GetOrderByIdUseCase(this.repository);
  final OrderRepository repository;

  Future<OrderEntity> execute(String id) async {
    return await repository.getOrderById(id);
  }
}
