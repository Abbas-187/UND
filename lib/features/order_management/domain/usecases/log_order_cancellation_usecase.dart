import '../entities/order_audit_trail_entity.dart';
import '../repositories/order_audit_trail_repository.dart';

class LogOrderCancellationUseCase {

  LogOrderCancellationUseCase(this.repository);
  final OrderAuditTrailRepository repository;

  Future<OrderAuditTrailEntity> execute(OrderAuditTrailEntity entry) {
    return repository.logOrderCancellation(entry);
  }
}
