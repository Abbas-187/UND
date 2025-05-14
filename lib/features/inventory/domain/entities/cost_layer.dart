import 'package:freezed_annotation/freezed_annotation.dart';

part 'cost_layer.freezed.dart';
part 'cost_layer.g.dart';

/// Enumeration of available costing methods
enum CostingMethod {
  fifo, // First In, First Out
  lifo, // Last In, First Out
  wac, // Weighted Average Cost
}

/// Model representing a cost layer for inventory
@freezed
abstract class CostLayer with _$CostLayer {
  const factory CostLayer({
    required String id,
    required String itemId,
    required String warehouseId,
    required String batchLotNumber,
    required double initialQuantity,
    required double remainingQuantity,
    required double costAtTransaction,
    String? movementId,
    required DateTime movementDate,
    DateTime? expirationDate,
    DateTime? productionDate,
    required DateTime createdAt,
  }) = _CostLayer;

  factory CostLayer.fromJson(Map<String, dynamic> json) =>
      _$CostLayerFromJson(json);
}

/// Model representing consumption of a cost layer
@freezed
abstract class CostLayerConsumption with _$CostLayerConsumption {
  const factory CostLayerConsumption({
    required String id,
    required String costLayerId,
    required String itemId,
    required String warehouseId,
    required String movementId,
    required DateTime movementDate,
    required double quantity,
    required double cost,
    required DateTime createdAt,
  }) = _CostLayerConsumption;

  factory CostLayerConsumption.fromJson(Map<String, dynamic> json) =>
      _$CostLayerConsumptionFromJson(json);
}

/// Model representing company settings for inventory costing
@freezed
abstract class CompanySettings with _$CompanySettings {
  const factory CompanySettings({
    required String id,
    @Default(CostingMethod.fifo) CostingMethod defaultCostingMethod,
    @Default(false) bool enforceBatchTracking,
    @Default(false) bool trackExpirationDates,
    @Default(365) int defaultShelfLifeDays,
  }) = _CompanySettings;

  factory CompanySettings.fromJson(Map<String, dynamic> json) =>
      _$CompanySettingsFromJson(json);
}
