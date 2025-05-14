import '../entities/order_audit_trail_entity.dart';

/// Repository interface for order audit trail
abstract class OrderAuditTrailRepository {
  /// Log creation of a new order
  Future<OrderAuditTrailEntity> logOrderCreation(OrderAuditTrailEntity entry);

  /// Log a status change for an existing order
  Future<OrderAuditTrailEntity> logOrderStatusChange(
    OrderAuditTrailEntity entry,
  );

  /// Log an update to an existing order
  Future<OrderAuditTrailEntity> logOrderUpdate(
    OrderAuditTrailEntity entry,
  );

  /// Log cancellation of an order
  Future<OrderAuditTrailEntity> logOrderCancellation(
    OrderAuditTrailEntity entry,
  );

  /// Log items change on an order
  Future<OrderAuditTrailEntity> logOrderItemsChange(
    OrderAuditTrailEntity entry,
  );

  /// Get audit trail entries for an order
  Future<List<OrderAuditTrailEntity>> getOrderAuditTrail(String orderId);

  /// Get recent changes made by a user across orders
  Future<List<OrderAuditTrailEntity>> getUserOrderChanges(String userId,
      {int limit = 10});
}
