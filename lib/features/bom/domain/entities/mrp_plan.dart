import 'package:freezed_annotation/freezed_annotation.dart';

part 'mrp_plan.freezed.dart';
part 'mrp_plan.g.dart';

/// Enumeration for MRP plan status
enum MrpPlanStatus {
  draft,
  calculating,
  completed,
  approved,
  executed,
  cancelled,
}

/// Enumeration for MRP requirement types
enum MrpRequirementType {
  grossRequirement,
  scheduledReceipt,
  projectedOnHand,
  netRequirement,
  plannedOrderReceipt,
  plannedOrderRelease,
}

/// Enumeration for MRP action messages
enum MrpActionType {
  none,
  expedite,
  deExpedite,
  cancel,
  reschedule,
  increase,
  decrease,
}

/// Time-phased requirement for a specific material
@freezed
abstract class MrpRequirement with _$MrpRequirement {
  const factory MrpRequirement({
    required String materialId,
    required String materialCode,
    required String materialName,
    required DateTime periodStart,
    required DateTime periodEnd,
    required MrpRequirementType requirementType,
    required double quantity,
    required String unit,
    @Default(0.0) double grossRequirement,
    @Default(0.0) double scheduledReceipt,
    @Default(0.0) double projectedOnHand,
    @Default(0.0) double netRequirement,
    @Default(0.0) double plannedOrderReceipt,
    @Default(0.0) double plannedOrderRelease,
    @Default(0.0) double safetyStock,
    @Default(0) int leadTimeDays,
    String? supplierCode,
    String? bomId,
    String? parentMaterialId,
    Map<String, dynamic>? additionalData,
  }) = _MrpRequirement;

  const MrpRequirement._();

  factory MrpRequirement.fromJson(Map<String, dynamic> json) =>
      _$MrpRequirementFromJson(json);

  /// Calculate net requirement based on gross requirement and available inventory
  double calculateNetRequirement() {
    return (grossRequirement - projectedOnHand + safetyStock)
        .clamp(0.0, double.infinity);
  }

  /// Get planned order release date considering lead time
  DateTime getPlannedOrderReleaseDate() {
    return periodStart.subtract(Duration(days: leadTimeDays));
  }
}

/// MRP action message for planning recommendations
@freezed
abstract class MrpActionMessage with _$MrpActionMessage {
  const factory MrpActionMessage({
    required String id,
    required String materialId,
    required String materialCode,
    required MrpActionType actionType,
    required String message,
    required DateTime currentDate,
    required DateTime recommendedDate,
    required double quantity,
    required String unit,
    @Default('medium') String priority,
    String? orderId,
    String? supplierCode,
    Map<String, dynamic>? actionData,
    required DateTime createdAt,
  }) = _MrpActionMessage;

  factory MrpActionMessage.fromJson(Map<String, dynamic> json) =>
      _$MrpActionMessageFromJson(json);
}

/// MRP recommendations for optimization
@freezed
abstract class MrpRecommendations with _$MrpRecommendations {
  const factory MrpRecommendations({
    required String planId,
    required List<MrpActionMessage> actionMessages,
    required List<String> criticalMaterials,
    required Map<String, double> costOptimizations,
    required Map<String, int> leadTimeImprovements,
    @Default([]) List<String> supplierRecommendations,
    @Default(0.0) double totalCostSavings,
    @Default(0.0) double inventoryReduction,
    required DateTime generatedAt,
    Map<String, dynamic>? optimizationMetrics,
  }) = _MrpRecommendations;

  factory MrpRecommendations.fromJson(Map<String, dynamic> json) =>
      _$MrpRecommendationsFromJson(json);
}

/// MRP alert for critical issues
@freezed
abstract class MrpAlert with _$MrpAlert {
  const factory MrpAlert({
    required String id,
    required String planId,
    required String materialId,
    required String alertType,
    required String severity,
    required String message,
    required DateTime alertDate,
    required double impactQuantity,
    String? recommendedAction,
    Map<String, dynamic>? alertData,
    @Default(false) bool isResolved,
    DateTime? resolvedAt,
    String? resolvedBy,
  }) = _MrpAlert;

  factory MrpAlert.fromJson(Map<String, dynamic> json) =>
      _$MrpAlertFromJson(json);
}

/// Main MRP Plan entity
@freezed
abstract class MrpPlan with _$MrpPlan {
  const factory MrpPlan({
    required String id,
    required String planName,
    required String planCode,
    required DateTime planningStartDate,
    required DateTime planningEndDate,
    required int planningHorizonDays,
    required List<String> bomIds,
    required Map<String, double> productionSchedule,
    required List<MrpRequirement> requirements,
    required List<MrpActionMessage> actionMessages,
    required List<MrpAlert> alerts,
    @Default(MrpPlanStatus.draft) MrpPlanStatus status,
    @Default(0.0) double totalMaterialCost,
    @Default(0.0) double totalInventoryValue,
    @Default(0) int totalMaterials,
    @Default(0) int criticalMaterials,
    String? createdBy,
    String? approvedBy,
    DateTime? approvedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    Map<String, dynamic>? planningParameters,
    Map<String, dynamic>? optimizationResults,
  }) = _MrpPlan;

  const MrpPlan._();

  factory MrpPlan.fromJson(Map<String, dynamic> json) =>
      _$MrpPlanFromJson(json);

  /// Get requirements for a specific material
  List<MrpRequirement> getRequirementsForMaterial(String materialId) {
    return requirements.where((req) => req.materialId == materialId).toList();
  }

  /// Get critical alerts that need immediate attention
  List<MrpAlert> getCriticalAlerts() {
    return alerts
        .where((alert) => alert.severity == 'critical' && !alert.isResolved)
        .toList();
  }

  /// Get action messages by type
  List<MrpActionMessage> getActionMessagesByType(MrpActionType actionType) {
    return actionMessages.where((msg) => msg.actionType == actionType).toList();
  }

  /// Calculate plan completion percentage
  double getCompletionPercentage() {
    if (requirements.isEmpty) return 0.0;

    int completedRequirements =
        requirements.where((req) => req.netRequirement <= 0).length;

    return (completedRequirements / requirements.length) * 100;
  }

  /// Get materials with shortages
  List<String> getMaterialsWithShortages() {
    return requirements
        .where((req) => req.netRequirement > 0)
        .map((req) => req.materialId)
        .toSet()
        .toList();
  }

  /// Calculate total planned order value
  double getTotalPlannedOrderValue() {
    return requirements.fold(
        0.0,
        (sum, req) =>
            sum +
            (req.plannedOrderReceipt *
                (req.additionalData?['unitCost'] ?? 0.0)));
  }

  /// Check if plan is ready for execution
  bool get isReadyForExecution {
    return status == MrpPlanStatus.approved &&
        getCriticalAlerts().isEmpty &&
        getMaterialsWithShortages().isEmpty;
  }
}
