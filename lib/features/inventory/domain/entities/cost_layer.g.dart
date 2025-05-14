// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cost_layer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CostLayer _$CostLayerFromJson(Map<String, dynamic> json) => _CostLayer(
      id: json['id'] as String,
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

Map<String, dynamic> _$CostLayerToJson(_CostLayer instance) =>
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

_CostLayerConsumption _$CostLayerConsumptionFromJson(
        Map<String, dynamic> json) =>
    _CostLayerConsumption(
      id: json['id'] as String,
      costLayerId: json['cost_layer_id'] as String,
      itemId: json['item_id'] as String,
      warehouseId: json['warehouse_id'] as String,
      movementId: json['movement_id'] as String,
      movementDate: DateTime.parse(json['movement_date'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CostLayerConsumptionToJson(
        _CostLayerConsumption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cost_layer_id': instance.costLayerId,
      'item_id': instance.itemId,
      'warehouse_id': instance.warehouseId,
      'movement_id': instance.movementId,
      'movement_date': instance.movementDate.toIso8601String(),
      'quantity': instance.quantity,
      'cost': instance.cost,
      'created_at': instance.createdAt.toIso8601String(),
    };

_CompanySettings _$CompanySettingsFromJson(Map<String, dynamic> json) =>
    _CompanySettings(
      id: json['id'] as String,
      defaultCostingMethod: $enumDecodeNullable(
              _$CostingMethodEnumMap, json['default_costing_method']) ??
          CostingMethod.fifo,
      enforceBatchTracking: json['enforce_batch_tracking'] as bool? ?? false,
      trackExpirationDates: json['track_expiration_dates'] as bool? ?? false,
      defaultShelfLifeDays:
          (json['default_shelf_life_days'] as num?)?.toInt() ?? 365,
    );

Map<String, dynamic> _$CompanySettingsToJson(_CompanySettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'default_costing_method':
          _$CostingMethodEnumMap[instance.defaultCostingMethod]!,
      'enforce_batch_tracking': instance.enforceBatchTracking,
      'track_expiration_dates': instance.trackExpirationDates,
      'default_shelf_life_days': instance.defaultShelfLifeDays,
    };

const _$CostingMethodEnumMap = {
  CostingMethod.fifo: 'fifo',
  CostingMethod.lifo: 'lifo',
  CostingMethod.wac: 'wac',
};
