import '../repositories/order_repository.dart';

class HandleProcurementCompleteUseCase {

  HandleProcurementCompleteUseCase(this.repository);
  final OrderRepository repository;

  Future<void> execute(String id) async {
    await repository.handleProcurementComplete(id);
  }
}
