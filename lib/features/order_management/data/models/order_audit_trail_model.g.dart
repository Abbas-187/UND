// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_audit_trail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderAuditTrailModel _$OrderAuditTrailModelFromJson(
        Map<String, dynamic> json) =>
    OrderAuditTrailModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      action: json['action'] as String,
      userId: json['user_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      before: json['before'] as Map<String, dynamic>?,
      after: json['after'] as Map<String, dynamic>?,
      justification: json['justification'] as String?,
    );

Map<String, dynamic> _$OrderAuditTrailModelToJson(
        OrderAuditTrailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'action': instance.action,
      'user_id': instance.userId,
      'timestamp': instance.timestamp.toIso8601String(),
      'before': instance.before,
      'after': instance.after,
      'justification': instance.justification,
    };
