import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order_audit_trail_entity.dart';

part 'order_audit_trail_model.g.dart';

@JsonSerializable()
class OrderAuditTrailModel {

  OrderAuditTrailModel({
    required this.id,
    required this.orderId,
    required this.action,
    required this.userId,
    required this.timestamp,
    this.before,
    this.after,
    this.justification,
  });

  factory OrderAuditTrailModel.fromJson(Map<String, dynamic> json) =>
      _$OrderAuditTrailModelFromJson(json);

  factory OrderAuditTrailModel.fromEntity(OrderAuditTrailEntity e) =>
      OrderAuditTrailModel(
        id: e.id,
        orderId: e.orderId,
        action: e.action,
        userId: e.userId,
        timestamp: e.timestamp,
        before: e.before,
        after: e.after,
        justification: e.justification,
      );
  final String id;
  final String orderId;
  final String action;
  final String userId;
  final DateTime timestamp;
  final Map<String, dynamic>? before;
  final Map<String, dynamic>? after;
  final String? justification;
  Map<String, dynamic> toJson() => _$OrderAuditTrailModelToJson(this);

  OrderAuditTrailEntity toEntity() => OrderAuditTrailEntity(
        id: id,
        orderId: orderId,
        action: action,
        userId: userId,
        timestamp: timestamp,
        before: before,
        after: after,
        justification: justification,
      );
}
