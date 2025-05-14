// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interaction_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InteractionLog _$InteractionLogFromJson(Map<String, dynamic> json) =>
    _InteractionLog(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String,
    );

Map<String, dynamic> _$InteractionLogToJson(_InteractionLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'type': instance.type,
      'date': instance.date.toIso8601String(),
      'notes': instance.notes,
    };
