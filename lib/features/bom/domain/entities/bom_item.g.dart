// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bom_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BomItem _$BomItemFromJson(Map<String, dynamic> json) => _BomItem(
      id: json['id'] as String,
      bomId: json['bom_id'] as String,
      itemId: json['item_id'] as String,
      itemCode: json['item_code'] as String,
      itemName: json['item_name'] as String,
      itemDescription: json['item_description'] as String,
      itemType: $enumDecode(_$BomItemTypeEnumMap, json['item_type']),
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      consumptionType:
          $enumDecode(_$ConsumptionTypeEnumMap, json['consumption_type']),
      sequenceNumber: (json['sequence_number'] as num).toInt(),
      wastagePercentage:
          (json['wastage_percentage'] as num?)?.toDouble() ?? 0.0,
      yieldPercentage: (json['yield_percentage'] as num?)?.toDouble() ?? 0.0,
      costPerUnit: (json['cost_per_unit'] as num?)?.toDouble() ?? 0.0,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0.0,
      alternativeItemId: json['alternative_item_id'] as String?,
      supplierCode: json['supplier_code'] as String?,
      batchNumber: json['batch_number'] as String?,
      expiryDate: json['expiry_date'] == null
          ? null
          : DateTime.parse(json['expiry_date'] as String),
      qualityGrade: json['quality_grade'] as String?,
      storageLocation: json['storage_location'] as String?,
      specifications: json['specifications'] as Map<String, dynamic>?,
      qualityParameters: json['quality_parameters'] as Map<String, dynamic>?,
      status: $enumDecodeNullable(_$BomItemStatusEnumMap, json['status']) ??
          BomItemStatus.active,
      notes: json['notes'] as String?,
      effectiveFrom: json['effective_from'] == null
          ? null
          : DateTime.parse(json['effective_from'] as String),
      effectiveTo: json['effective_to'] == null
          ? null
          : DateTime.parse(json['effective_to'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
    );

Map<String, dynamic> _$BomItemToJson(_BomItem instance) => <String, dynamic>{
      'id': instance.id,
      'bom_id': instance.bomId,
      'item_id': instance.itemId,
      'item_code': instance.itemCode,
      'item_name': instance.itemName,
      'item_description': instance.itemDescription,
      'item_type': _$BomItemTypeEnumMap[instance.itemType]!,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'consumption_type': _$ConsumptionTypeEnumMap[instance.consumptionType]!,
      'sequence_number': instance.sequenceNumber,
      'wastage_percentage': instance.wastagePercentage,
      'yield_percentage': instance.yieldPercentage,
      'cost_per_unit': instance.costPerUnit,
      'total_cost': instance.totalCost,
      'alternative_item_id': instance.alternativeItemId,
      'supplier_code': instance.supplierCode,
      'batch_number': instance.batchNumber,
      'expiry_date': instance.expiryDate?.toIso8601String(),
      'quality_grade': instance.qualityGrade,
      'storage_location': instance.storageLocation,
      'specifications': instance.specifications,
      'quality_parameters': instance.qualityParameters,
      'status': _$BomItemStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'effective_from': instance.effectiveFrom?.toIso8601String(),
      'effective_to': instance.effectiveTo?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'created_by': instance.createdBy,
      'updated_by': instance.updatedBy,
    };

const _$BomItemTypeEnumMap = {
  BomItemType.rawMaterial: 'rawMaterial',
  BomItemType.semiFinished: 'semiFinished',
  BomItemType.finishedGood: 'finishedGood',
  BomItemType.packaging: 'packaging',
  BomItemType.consumable: 'consumable',
  BomItemType.byProduct: 'byProduct',
  BomItemType.coProduct: 'coProduct',
};

const _$ConsumptionTypeEnumMap = {
  ConsumptionType.fixed: 'fixed',
  ConsumptionType.variable: 'variable',
  ConsumptionType.optional: 'optional',
  ConsumptionType.alternative: 'alternative',
};

const _$BomItemStatusEnumMap = {
  BomItemStatus.active: 'active',
  BomItemStatus.inactive: 'inactive',
  BomItemStatus.obsolete: 'obsolete',
  BomItemStatus.pending: 'pending',
  BomItemStatus.approved: 'approved',
  BomItemStatus.rejected: 'rejected',
};
