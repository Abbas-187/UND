// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      date: DateTime.parse(json['date'] as String),
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'date': instance.date.toIso8601String(),
      'total_amount': instance.totalAmount,
      'status': instance.status,
    };
