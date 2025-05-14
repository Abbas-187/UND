import '../../domain/entities/order_audit_trail_entity.dart';
import '../../domain/repositories/order_audit_trail_repository.dart';
import '../models/order_audit_trail_model.dart';
import '../services/order_audit_trail_service.dart';

class OrderAuditTrailRepositoryImpl implements OrderAuditTrailRepository {

  OrderAuditTrailRepositoryImpl(this._service);
  final OrderAuditTrailService _service;

  @override
  Future<OrderAuditTrailEntity> logOrderCreation(
      OrderAuditTrailEntity entry) async {
    final model = OrderAuditTrailModel.fromEntity(entry);
    final logged = await _service.logOrderCreation(model);
    return logged;
  }

  @override
  Future<List<OrderAuditTrailEntity>> getOrderAuditTrail(String orderId) async {
    return _service.getAuditTrail(orderId);
  }

  @override
  Future<OrderAuditTrailEntity> logOrderStatusChange(
      OrderAuditTrailEntity entry) {
    throw UnimplementedError('logOrderStatusChange is not implemented');
  }

  @override
  Future<OrderAuditTrailEntity> logOrderUpdate(OrderAuditTrailEntity entry) {
    throw UnimplementedError('logOrderUpdate is not implemented');
  }

  @override
  Future<OrderAuditTrailEntity> logOrderCancellation(
      OrderAuditTrailEntity entry) {
    throw UnimplementedError('logOrderCancellation is not implemented');
  }

  @override
  Future<OrderAuditTrailEntity> logOrderItemsChange(
      OrderAuditTrailEntity entry) {
    throw UnimplementedError('logOrderItemsChange is not implemented');
  }

  @override
  Future<List<OrderAuditTrailEntity>> getUserOrderChanges(String userId,
      {int limit = 10}) {
    throw UnimplementedError('getUserOrderChanges is not implemented');
  }
}
