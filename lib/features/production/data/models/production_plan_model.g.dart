// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductionPlanItem _$ProductionPlanItemFromJson(Map<String, dynamic> json) =>
    _ProductionPlanItem(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      requiredQuantity: (json['required_quantity'] as num).toInt(),
      availableStock: (json['available_stock'] as num).toInt(),
      productionQuantity: (json['production_quantity'] as num).toInt(),
      deadline: DateTime.parse(json['deadline'] as String),
    );

Map<String, dynamic> _$ProductionPlanItemToJson(_ProductionPlanItem instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'product_name': instance.productName,
      'required_quantity': instance.requiredQuantity,
      'available_stock': instance.availableStock,
      'production_quantity': instance.productionQuantity,
      'deadline': instance.deadline.toIso8601String(),
    };

_ProductionPlan _$ProductionPlanFromJson(Map<String, dynamic> json) =>
    _ProductionPlan(
      id: json['id'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => ProductionPlanItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$ProductionPlanToJson(_ProductionPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'items': instance.items.map((e) => e.toJson()).toList(),
      'status': instance.status,
    };
