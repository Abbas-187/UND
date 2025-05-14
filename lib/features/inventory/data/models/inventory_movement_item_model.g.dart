// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_movement_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InventoryMovementItemModel _$InventoryMovementItemModelFromJson(
        Map<String, dynamic> json) =>
    _InventoryMovementItemModel(
      id: json['id'] as String?,
      itemId: json['item_id'] as String,
      itemCode: json['item_code'] as String,
      itemName: json['item_name'] as String,
      uom: json['uom'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      costAtTransaction: (json['cost_at_transaction'] as num?)?.toDouble(),
      batchLotNumber: json['batch_lot_number'] as String?,
      expirationDate: json['expiration_date'] == null
          ? null
          : DateTime.parse(json['expiration_date'] as String),
      productionDate: json['production_date'] == null
          ? null
          : DateTime.parse(json['production_date'] as String),
      customAttributes: json['custom_attributes'] as Map<String, dynamic>?,
      warehouseId: json['warehouse_id'] as String?,
      status: json['status'] as String?,
      qualityStatus: json['quality_status'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$InventoryMovementItemModelToJson(
        _InventoryMovementItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_id': instance.itemId,
      'item_code': instance.itemCode,
      'item_name': instance.itemName,
      'uom': instance.uom,
      'quantity': instance.quantity,
      'cost_at_transaction': instance.costAtTransaction,
      'batch_lot_number': instance.batchLotNumber,
      'expiration_date': instance.expirationDate?.toIso8601String(),
      'production_date': instance.productionDate?.toIso8601String(),
      'custom_attributes': instance.customAttributes,
      'warehouse_id': instance.warehouseId,
      'status': instance.status,
      'quality_status': instance.qualityStatus,
      'notes': instance.notes,
    };
