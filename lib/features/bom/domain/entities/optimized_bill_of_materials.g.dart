// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'optimized_bill_of_materials.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OptimizedBillOfMaterials _$OptimizedBillOfMaterialsFromJson(
        Map<String, dynamic> json) =>
    _OptimizedBillOfMaterials(
      id: json['id'] as String,
      bomCode: json['bom_code'] as String,
      bomName: json['bom_name'] as String,
      productId: json['product_id'] as String,
      productCode: json['product_code'] as String,
      productName: json['product_name'] as String,
      bomType: $enumDecode(_$BomTypeEnumMap, json['bom_type']),
      version: json['version'] as String,
      baseQuantity: (json['base_quantity'] as num).toDouble(),
      baseUnit: json['base_unit'] as String,
      status: $enumDecodeNullable(_$BomStatusEnumMap, json['status']) ??
          BomStatus.draft,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => BomItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0.0,
      laborCost: (json['labor_cost'] as num?)?.toDouble() ?? 0.0,
      overheadCost: (json['overhead_cost'] as num?)?.toDouble() ?? 0.0,
      setupCost: (json['setup_cost'] as num?)?.toDouble() ?? 0.0,
      yieldPercentage: (json['yield_percentage'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      approvedBy: json['approved_by'] as String?,
      approvedAt: json['approved_at'] == null
          ? null
          : DateTime.parse(json['approved_at'] as String),
      effectiveFrom: json['effective_from'] == null
          ? null
          : DateTime.parse(json['effective_from'] as String),
      effectiveTo: json['effective_to'] == null
          ? null
          : DateTime.parse(json['effective_to'] as String),
      productionInstructions:
          json['production_instructions'] as Map<String, dynamic>?,
      qualityRequirements:
          json['quality_requirements'] as Map<String, dynamic>?,
      packagingInstructions:
          json['packaging_instructions'] as Map<String, dynamic>?,
      alternativeBomIds: (json['alternative_bom_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      parentBomId: json['parent_bom_id'] as String?,
      childBomIds: (json['child_bom_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
      cachedCalculations: json['cached_calculations'] as Map<String, dynamic>?,
      calculationsLastUpdated: json['calculations_last_updated'] == null
          ? null
          : DateTime.parse(json['calculations_last_updated'] as String),
    );

Map<String, dynamic> _$OptimizedBillOfMaterialsToJson(
        _OptimizedBillOfMaterials instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bom_code': instance.bomCode,
      'bom_name': instance.bomName,
      'product_id': instance.productId,
      'product_code': instance.productCode,
      'product_name': instance.productName,
      'bom_type': _$BomTypeEnumMap[instance.bomType]!,
      'version': instance.version,
      'base_quantity': instance.baseQuantity,
      'base_unit': instance.baseUnit,
      'status': _$BomStatusEnumMap[instance.status]!,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'total_cost': instance.totalCost,
      'labor_cost': instance.laborCost,
      'overhead_cost': instance.overheadCost,
      'setup_cost': instance.setupCost,
      'yield_percentage': instance.yieldPercentage,
      'description': instance.description,
      'notes': instance.notes,
      'approved_by': instance.approvedBy,
      'approved_at': instance.approvedAt?.toIso8601String(),
      'effective_from': instance.effectiveFrom?.toIso8601String(),
      'effective_to': instance.effectiveTo?.toIso8601String(),
      'production_instructions': instance.productionInstructions,
      'quality_requirements': instance.qualityRequirements,
      'packaging_instructions': instance.packagingInstructions,
      'alternative_bom_ids': instance.alternativeBomIds,
      'parent_bom_id': instance.parentBomId,
      'child_bom_ids': instance.childBomIds,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'created_by': instance.createdBy,
      'updated_by': instance.updatedBy,
      'cached_calculations': instance.cachedCalculations,
      'calculations_last_updated':
          instance.calculationsLastUpdated?.toIso8601String(),
    };

const _$BomTypeEnumMap = {
  BomType.production: 'production',
  BomType.engineering: 'engineering',
  BomType.sales: 'sales',
  BomType.costing: 'costing',
  BomType.planning: 'planning',
};

const _$BomStatusEnumMap = {
  BomStatus.draft: 'draft',
  BomStatus.active: 'active',
  BomStatus.inactive: 'inactive',
  BomStatus.obsolete: 'obsolete',
  BomStatus.underReview: 'underReview',
  BomStatus.approved: 'approved',
  BomStatus.rejected: 'rejected',
};
