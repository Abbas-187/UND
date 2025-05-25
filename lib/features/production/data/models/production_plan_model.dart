import 'package:freezed_annotation/freezed_annotation.dart';

part 'production_plan_model.freezed.dart';
part 'production_plan_model.g.dart';

@freezed
abstract class ProductionPlanItem with _$ProductionPlanItem {
  const factory ProductionPlanItem({
    required String productId,
    required String productName,
    required int requiredQuantity,
    required int availableStock,
    required int productionQuantity,
    required DateTime deadline,
  }) = _ProductionPlanItem;

  factory ProductionPlanItem.fromJson(Map<String, dynamic> json) =>
      _$ProductionPlanItemFromJson(json);
}

@freezed
abstract class ProductionPlan with _$ProductionPlan {
  const factory ProductionPlan({
    required String id,
    required DateTime startDate,
    required DateTime endDate,
    required List<ProductionPlanItem> items,
    required String status,
  }) = _ProductionPlan;

  factory ProductionPlan.fromJson(Map<String, dynamic> json) =>
      _$ProductionPlanFromJson(json);
}
