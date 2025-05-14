// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryModel _$InventoryModelFromJson(Map<String, dynamic> json) =>
    InventoryModel(
      productId: json['product_id'] as String,
      availableQuantity: (json['available_quantity'] as num).toDouble(),
      reservedQuantity: (json['reserved_quantity'] as num).toDouble(),
    );

Map<String, dynamic> _$InventoryModelToJson(InventoryModel instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'available_quantity': instance.availableQuantity,
      'reserved_quantity': instance.reservedQuantity,
    };
