import '../entities/order_audit_trail_entity.dart';
import '../repositories/order_audit_trail_repository.dart';

class GetOrderAuditTrailUseCase {

  GetOrderAuditTrailUseCase(this.repository);
  final OrderAuditTrailRepository repository;

  Future<List<OrderAuditTrailEntity>> execute(String orderId) async {
    return repository.getOrderAuditTrail(orderId);
  }
}
