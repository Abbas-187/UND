// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      id: json['id'] as String,
      customerName: json['customer_name'] as String,
      date: DateTime.parse(json['date'] as String),
      items: json['items'] as List<dynamic>,
    );

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_name': instance.customerName,
      'date': instance.date.toIso8601String(),
      'items': instance.items,
    };
