import 'package:freezed_annotation/freezed_annotation.dart';

import 'cost_layer.dart';

part 'cost_method_setting.freezed.dart';
part 'cost_method_setting.g.dart';

/// Settings for inventory costing methods
@freezed
abstract class CostMethodSetting with _$CostMethodSetting {
  const factory CostMethodSetting({
    required String id,
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
  }) = _CostMethodSetting;

  factory CostMethodSetting.fromJson(Map<String, dynamic> json) =>
      _$CostMethodSettingFromJson(json);
}
