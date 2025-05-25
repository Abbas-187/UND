// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InventoryItemModel _$InventoryItemModelFromJson(Map<String, dynamic> json) =>
    _InventoryItemModel(
      id: json['id'] as String?,
      appItemId: json['app_item_id'] as String,
      sapCode: json['sap_code'] as String? ?? '',
      name: json['name'] as String,
      category: json['category'] as String,
      subCategory: json['sub_category'] as String? ?? '',
      unit: json['unit'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      minimumQuantity: (json['minimum_quantity'] as num).toDouble(),
      reorderPoint: (json['reorder_point'] as num).toDouble(),
      location: json['location'] as String,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      batchNumber: json['batch_number'] as String?,
      expiryDate: json['expiry_date'] == null
          ? null
          : DateTime.parse(json['expiry_date'] as String),
      additionalAttributes:
          json['additional_attributes'] as Map<String, dynamic>?,
      cost: (json['cost'] as num?)?.toDouble(),
      lowStockThreshold: (json['low_stock_threshold'] as num?)?.toInt() ?? 5,
      supplier: json['supplier'] as String?,
      safetyStock: (json['safety_stock'] as num?)?.toDouble(),
      currentConsumption: (json['current_consumption'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$InventoryItemModelToJson(_InventoryItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'app_item_id': instance.appItemId,
      'sap_code': instance.sapCode,
      'name': instance.name,
      'category': instance.category,
      'sub_category': instance.subCategory,
      'unit': instance.unit,
      'quantity': instance.quantity,
      'minimum_quantity': instance.minimumQuantity,
      'reorder_point': instance.reorderPoint,
      'location': instance.location,
      'last_updated': instance.lastUpdated.toIso8601String(),
      'batch_number': instance.batchNumber,
      'expiry_date': instance.expiryDate?.toIso8601String(),
      'additional_attributes': instance.additionalAttributes,
      'cost': instance.cost,
      'low_stock_threshold': instance.lowStockThreshold,
      'supplier': instance.supplier,
      'safety_stock': instance.safetyStock,
      'current_consumption': instance.currentConsumption,
    };
