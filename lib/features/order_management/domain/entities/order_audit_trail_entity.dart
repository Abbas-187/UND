import 'package:equatable/equatable.dart';

class OrderAuditTrailEntity extends Equatable {

  const OrderAuditTrailEntity({
    required this.id,
    required this.orderId,
    required this.action,
    required this.userId,
    required this.timestamp,
    this.before,
    this.after,
    this.justification,
  });
  final String id;
  final String orderId;
  final String action;
  final String userId;
  final DateTime timestamp;
  final Map<String, dynamic>? before;
  final Map<String, dynamic>? after;
  final String? justification;

  @override
  List<Object?> get props =>
      [id, orderId, action, userId, timestamp, before, after, justification];
}
