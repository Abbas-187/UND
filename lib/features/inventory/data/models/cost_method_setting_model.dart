import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/cost_layer.dart';
import '../../domain/entities/cost_method_setting.dart';

// Removed json_serializable support; use manual Firestore mapping
part 'cost_method_setting_model.freezed.dart';

@freezed
abstract class CostMethodSettingModel with _$CostMethodSettingModel {
  const factory CostMethodSettingModel({
    String? id,
    required CostingMethod defaultCostingMethod,
    required bool isCompanyWide,
    String? warehouseId,
    String? warehouseName,
    required bool allowWarehouseOverride,
    required DateTime effectiveFrom,
    DateTime? lastUpdated,
    String? updatedById,
    String? updatedByName,
    Map<String, CostingMethod>? itemSpecificMethods,
  }) = _CostMethodSettingModel;

  // Manual constructor from Firestore snapshot
  factory CostMethodSettingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime getDate(dynamic field) {
      if (field is Timestamp) return field.toDate();
      return DateTime.parse(field.toString());
    }

    return CostMethodSettingModel(
      id: doc.id,
      defaultCostingMethod: CostingMethod.values.firstWhere((e) =>
          e.toString().split('.').last ==
          data['defaultCostingMethod'] as String),
      isCompanyWide: data['isCompanyWide'] as bool,
      warehouseId: data['warehouseId'] as String?,
      warehouseName: data['warehouseName'] as String?,
      allowWarehouseOverride: data['allowWarehouseOverride'] as bool,
      effectiveFrom: getDate(data['effectiveFrom']),
      lastUpdated:
          data['lastUpdated'] != null ? getDate(data['lastUpdated']) : null,
      updatedById: data['updatedById'] as String?,
      updatedByName: data['updatedByName'] as String?,
      itemSpecificMethods:
          (data['itemSpecificMethods'] as Map<String, dynamic>?)?.map((k, v) =>
              MapEntry(
                  k,
                  CostingMethod.values.firstWhere(
                      (e) => e.toString().split('.').last == v as String))),
    );
  }
}

extension CostMethodSettingModelX on CostMethodSettingModel {
  CostMethodSetting toDomain() => CostMethodSetting(
        id: id ?? '',
        defaultCostingMethod: defaultCostingMethod,
        isCompanyWide: isCompanyWide,
        warehouseId: warehouseId,
        warehouseName: warehouseName,
        allowWarehouseOverride: allowWarehouseOverride,
        effectiveFrom: effectiveFrom,
        lastUpdated: lastUpdated,
        updatedById: updatedById,
        updatedByName: updatedByName,
        itemSpecificMethods: itemSpecificMethods,
      );

  static CostMethodSettingModel fromDomain(CostMethodSetting setting) =>
      CostMethodSettingModel(
        id: setting.id,
        defaultCostingMethod: setting.defaultCostingMethod,
        isCompanyWide: setting.isCompanyWide,
        warehouseId: setting.warehouseId,
        warehouseName: setting.warehouseName,
        allowWarehouseOverride: setting.allowWarehouseOverride,
        effectiveFrom: setting.effectiveFrom,
        lastUpdated: setting.lastUpdated,
        updatedById: setting.updatedById,
        updatedByName: setting.updatedByName,
        itemSpecificMethods: setting.itemSpecificMethods,
      );
}
