// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cost_layer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CostLayerModel _$CostLayerModelFromJson(Map<String, dynamic> json) =>
    _CostLayerModel(
      id: json['id'] as String?,
      itemId: json['item_id'] as String,
      warehouseId: json['warehouse_id'] as String,
      batchLotNumber: json['batch_lot_number'] as String,
      initialQuantity: (json['initial_quantity'] as num).toDouble(),
      remainingQuantity: (json['remaining_quantity'] as num).toDouble(),
      costAtTransaction: (json['cost_at_transaction'] as num).toDouble(),
      movementId: json['movement_id'] as String?,
      movementDate: DateTime.parse(json['movement_date'] as String),
      expirationDate: json['expiration_date'] == null
          ? null
          : DateTime.parse(json['expiration_date'] as String),
      productionDate: json['production_date'] == null
          ? null
          : DateTime.parse(json['production_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CostLayerModelToJson(_CostLayerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_id': instance.itemId,
      'warehouse_id': instance.warehouseId,
      'batch_lot_number': instance.batchLotNumber,
      'initial_quantity': instance.initialQuantity,
      'remaining_quantity': instance.remainingQuantity,
      'cost_at_transaction': instance.costAtTransaction,
      'movement_id': instance.movementId,
      'movement_date': instance.movementDate.toIso8601String(),
      'expiration_date': instance.expirationDate?.toIso8601String(),
      'production_date': instance.productionDate?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };
