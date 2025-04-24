import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/order.dart';
import '../models/order_audit_trail.dart';

/// Service for tracking order changes and maintaining an audit trail
class OrderAuditTrailService {
  /// Logs an order creation event
  Future<OrderAuditTrail> logOrderCreation(Order order) async {
    // Create an audit trail entry
    final auditTrail = OrderAuditTrail(
      id: const Uuid().v4(),
      orderId: order.id,
      action: AuditAction.created,
      userId: order.createdBy,
      timestamp: DateTime.now(),
      before: null,
      after: order.toJson(),
      justification: null,
    );

    // In a real implementation, this would save to the database
    await Future.delayed(const Duration(milliseconds: 300));

    return auditTrail;
  }

  /// Logs an order status change event
  Future<OrderAuditTrail> logOrderStatusChange(String orderId, String userId,
      OrderStatus oldStatus, OrderStatus newStatus,
      {String? justification}) async {
    // Create an audit trail entry
    final auditTrail = OrderAuditTrail(
      id: const Uuid().v4(),
      orderId: orderId,
      action: AuditAction.statusChanged,
      userId: userId,
      timestamp: DateTime.now(),
      before: {'status': oldStatus.name},
      after: {'status': newStatus.name},
      justification: justification,
    );

    // In a real implementation, this would save to the database
    await Future.delayed(const Duration(milliseconds: 300));

    return auditTrail;
  }

  /// Logs an order update event
  Future<OrderAuditTrail> logOrderUpdate(
      String userId, Order oldOrder, Order newOrder,
      {String? justification}) async {
    // Create an audit trail entry
    final auditTrail = OrderAuditTrail(
      id: const Uuid().v4(),
      orderId: oldOrder.id,
      action: AuditAction.updated,
      userId: userId,
      timestamp: DateTime.now(),
      before: oldOrder.toJson(),
      after: newOrder.toJson(),
      justification: justification,
    );

    // In a real implementation, this would save to the database
    await Future.delayed(const Duration(milliseconds: 300));

    return auditTrail;
  }

  /// Logs an order cancellation event
  Future<OrderAuditTrail> logOrderCancellation(
    String orderId,
    String userId,
    String reason,
  ) async {
    // Create an audit trail entry
    final auditTrail = OrderAuditTrail(
      id: const Uuid().v4(),
      orderId: orderId,
      action: AuditAction.cancelled,
      userId: userId,
      timestamp: DateTime.now(),
      before: {'status': OrderStatus.approved.name},
      after: {
        'status': OrderStatus.cancelled.name,
        'cancellationReason': reason
      },
      justification: reason,
    );

    // In a real implementation, this would save to the database
    await Future.delayed(const Duration(milliseconds: 300));

    return auditTrail;
  }

  /// Logs an order item change
  Future<OrderAuditTrail> logOrderItemsChange(String orderId, String userId,
      List<OrderItem> oldItems, List<OrderItem> newItems,
      {String? justification}) async {
    // Create an audit trail entry
    final auditTrail = OrderAuditTrail(
      id: const Uuid().v4(),
      orderId: orderId,
      action: AuditAction.itemsChanged,
      userId: userId,
      timestamp: DateTime.now(),
      before: {'items': oldItems.map((item) => item.toJson()).toList()},
      after: {'items': newItems.map((item) => item.toJson()).toList()},
      justification: justification,
    );

    // In a real implementation, this would save to the database
    await Future.delayed(const Duration(milliseconds: 300));

    return auditTrail;
  }

  /// Gets the audit trail for an order
  Future<List<OrderAuditTrail>> getOrderAuditTrail(String orderId) async {
    // In a real implementation, this would fetch from the database
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock data
    return [
      OrderAuditTrail(
        id: 'audit_1',
        orderId: orderId,
        action: AuditAction.created,
        userId: 'user_1',
        timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
        before: null,
        after: {'status': 'draft'},
        justification: null,
      ),
      OrderAuditTrail(
        id: 'audit_2',
        orderId: orderId,
        action: AuditAction.statusChanged,
        userId: 'user_1',
        timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
        before: {'status': 'draft'},
        after: {'status': 'pending'},
        justification: null,
      ),
      OrderAuditTrail(
        id: 'audit_3',
        orderId: orderId,
        action: AuditAction.statusChanged,
        userId: 'user_2',
        timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
        before: {'status': 'pending'},
        after: {'status': 'approved'},
        justification: null,
      ),
      OrderAuditTrail(
        id: 'audit_4',
        orderId: orderId,
        action: AuditAction.itemsChanged,
        userId: 'user_1',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
        before: {
          'items': [
            {'name': 'Whole Milk', 'quantity': 5, 'unit': 'liter'}
          ]
        },
        after: {
          'items': [
            {'name': 'Whole Milk', 'quantity': 10, 'unit': 'liter'}
          ]
        },
        justification: 'Customer requested to double the quantity',
      ),
    ];
  }

  /// Gets a summary of recent order changes for a specific user
  Future<List<OrderAuditTrail>> getUserOrderChanges(String userId,
      {int limit = 10}) async {
    // In a real implementation, this would fetch from the database
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock data
    return [
      OrderAuditTrail(
        id: 'audit_5',
        orderId: 'ord_123456',
        action: AuditAction.created,
        userId: userId,
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        before: null,
        after: {'status': 'draft'},
        justification: null,
      ),
      OrderAuditTrail(
        id: 'audit_6',
        orderId: 'ord_123456',
        action: AuditAction.statusChanged,
        userId: userId,
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        before: {'status': 'draft'},
        after: {'status': 'pending'},
        justification: null,
      ),
      OrderAuditTrail(
        id: 'audit_7',
        orderId: 'ord_789012',
        action: AuditAction.updated,
        userId: userId,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        before: {'deliveryDate': null},
        after: {
          'deliveryDate':
              DateTime.now().add(const Duration(days: 3)).toIso8601String()
        },
        justification: 'Customer requested a specific delivery date',
      ),
    ];
  }
}

// Provider for the OrderAuditTrailService
final orderAuditTrailServiceProvider = Provider<OrderAuditTrailService>((ref) {
  return OrderAuditTrailService();
});
