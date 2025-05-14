// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cost_method_setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CostMethodSetting _$CostMethodSettingFromJson(Map<String, dynamic> json) =>
    _CostMethodSetting(
      id: json['id'] as String,
      defaultCostingMethod:
          $enumDecode(_$CostingMethodEnumMap, json['default_costing_method']),
      isCompanyWide: json['is_company_wide'] as bool,
      warehouseId: json['warehouse_id'] as String?,
      warehouseName: json['warehouse_name'] as String?,
      allowWarehouseOverride: json['allow_warehouse_override'] as bool,
      effectiveFrom: DateTime.parse(json['effective_from'] as String),
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
      updatedById: json['updated_by_id'] as String?,
      updatedByName: json['updated_by_name'] as String?,
      itemSpecificMethods:
          (json['item_specific_methods'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, $enumDecode(_$CostingMethodEnumMap, e)),
      ),
    );

Map<String, dynamic> _$CostMethodSettingToJson(_CostMethodSetting instance) =>
    <String, dynamic>{
      'id': instance.id,
      'default_costing_method':
          _$CostingMethodEnumMap[instance.defaultCostingMethod]!,
      'is_company_wide': instance.isCompanyWide,
      'warehouse_id': instance.warehouseId,
      'warehouse_name': instance.warehouseName,
      'allow_warehouse_override': instance.allowWarehouseOverride,
      'effective_from': instance.effectiveFrom.toIso8601String(),
      'last_updated': instance.lastUpdated?.toIso8601String(),
      'updated_by_id': instance.updatedById,
      'updated_by_name': instance.updatedByName,
      'item_specific_methods': instance.itemSpecificMethods
          ?.map((k, e) => MapEntry(k, _$CostingMethodEnumMap[e]!)),
    };

const _$CostingMethodEnumMap = {
  CostingMethod.fifo: 'fifo',
  CostingMethod.lifo: 'lifo',
  CostingMethod.wac: 'wac',
};
