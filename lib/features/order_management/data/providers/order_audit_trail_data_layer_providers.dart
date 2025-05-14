import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/order_audit_trail_repository.dart';
import '../repositories/order_audit_trail_repository_impl.dart';
import '../services/order_audit_trail_service.dart';

/// Provides audit trail service
final orderAuditTrailServiceProvider = Provider<OrderAuditTrailService>((ref) {
  return OrderAuditTrailService();
});

/// Provides repository implementation for audit trail
final orderAuditTrailRepositoryProvider =
    Provider<OrderAuditTrailRepository>((ref) {
  final service = ref.watch(orderAuditTrailServiceProvider);
  return OrderAuditTrailRepositoryImpl(service);
});
