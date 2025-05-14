import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/order_audit_trail_entity.dart';
import '../models/order_audit_trail_model.dart';

/// Service for tracking order changes and maintaining an audit trail
class OrderAuditTrailService {
  final Uuid _uuid = const Uuid();

  /// Logs an order creation event
  Future<OrderAuditTrailEntity> logOrderCreation(
      OrderAuditTrailModel model) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return model.toEntity();
  }

  /// Retrieves audit trail entries for an order
  Future<List<OrderAuditTrailEntity>> getAuditTrail(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: Fetch real data via repository or API
    return [];
  }
}

final orderAuditTrailServiceProvider =
    Provider<OrderAuditTrailService>((ref) => OrderAuditTrailService());
