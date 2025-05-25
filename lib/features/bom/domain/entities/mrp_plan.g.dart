// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mrp_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MrpRequirement _$MrpRequirementFromJson(Map<String, dynamic> json) =>
    _MrpRequirement(
      materialId: json['material_id'] as String,
      materialCode: json['material_code'] as String,
      materialName: json['material_name'] as String,
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      requirementType:
          $enumDecode(_$MrpRequirementTypeEnumMap, json['requirement_type']),
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      grossRequirement: (json['gross_requirement'] as num?)?.toDouble() ?? 0.0,
      scheduledReceipt: (json['scheduled_receipt'] as num?)?.toDouble() ?? 0.0,
      projectedOnHand: (json['projected_on_hand'] as num?)?.toDouble() ?? 0.0,
      netRequirement: (json['net_requirement'] as num?)?.toDouble() ?? 0.0,
      plannedOrderReceipt:
          (json['planned_order_receipt'] as num?)?.toDouble() ?? 0.0,
      plannedOrderRelease:
          (json['planned_order_release'] as num?)?.toDouble() ?? 0.0,
      safetyStock: (json['safety_stock'] as num?)?.toDouble() ?? 0.0,
      leadTimeDays: (json['lead_time_days'] as num?)?.toInt() ?? 0,
      supplierCode: json['supplier_code'] as String?,
      bomId: json['bom_id'] as String?,
      parentMaterialId: json['parent_material_id'] as String?,
      additionalData: json['additional_data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MrpRequirementToJson(_MrpRequirement instance) =>
    <String, dynamic>{
      'material_id': instance.materialId,
      'material_code': instance.materialCode,
      'material_name': instance.materialName,
      'period_start': instance.periodStart.toIso8601String(),
      'period_end': instance.periodEnd.toIso8601String(),
      'requirement_type':
          _$MrpRequirementTypeEnumMap[instance.requirementType]!,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'gross_requirement': instance.grossRequirement,
      'scheduled_receipt': instance.scheduledReceipt,
      'projected_on_hand': instance.projectedOnHand,
      'net_requirement': instance.netRequirement,
      'planned_order_receipt': instance.plannedOrderReceipt,
      'planned_order_release': instance.plannedOrderRelease,
      'safety_stock': instance.safetyStock,
      'lead_time_days': instance.leadTimeDays,
      'supplier_code': instance.supplierCode,
      'bom_id': instance.bomId,
      'parent_material_id': instance.parentMaterialId,
      'additional_data': instance.additionalData,
    };

const _$MrpRequirementTypeEnumMap = {
  MrpRequirementType.grossRequirement: 'grossRequirement',
  MrpRequirementType.scheduledReceipt: 'scheduledReceipt',
  MrpRequirementType.projectedOnHand: 'projectedOnHand',
  MrpRequirementType.netRequirement: 'netRequirement',
  MrpRequirementType.plannedOrderReceipt: 'plannedOrderReceipt',
  MrpRequirementType.plannedOrderRelease: 'plannedOrderRelease',
};

_MrpActionMessage _$MrpActionMessageFromJson(Map<String, dynamic> json) =>
    _MrpActionMessage(
      id: json['id'] as String,
      materialId: json['material_id'] as String,
      materialCode: json['material_code'] as String,
      actionType: $enumDecode(_$MrpActionTypeEnumMap, json['action_type']),
      message: json['message'] as String,
      currentDate: DateTime.parse(json['current_date'] as String),
      recommendedDate: DateTime.parse(json['recommended_date'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      priority: json['priority'] as String? ?? 'medium',
      orderId: json['order_id'] as String?,
      supplierCode: json['supplier_code'] as String?,
      actionData: json['action_data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$MrpActionMessageToJson(_MrpActionMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'material_id': instance.materialId,
      'material_code': instance.materialCode,
      'action_type': _$MrpActionTypeEnumMap[instance.actionType]!,
      'message': instance.message,
      'current_date': instance.currentDate.toIso8601String(),
      'recommended_date': instance.recommendedDate.toIso8601String(),
      'quantity': instance.quantity,
      'unit': instance.unit,
      'priority': instance.priority,
      'order_id': instance.orderId,
      'supplier_code': instance.supplierCode,
      'action_data': instance.actionData,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$MrpActionTypeEnumMap = {
  MrpActionType.none: 'none',
  MrpActionType.expedite: 'expedite',
  MrpActionType.deExpedite: 'deExpedite',
  MrpActionType.cancel: 'cancel',
  MrpActionType.reschedule: 'reschedule',
  MrpActionType.increase: 'increase',
  MrpActionType.decrease: 'decrease',
};

_MrpRecommendations _$MrpRecommendationsFromJson(Map<String, dynamic> json) =>
    _MrpRecommendations(
      planId: json['plan_id'] as String,
      actionMessages: (json['action_messages'] as List<dynamic>)
          .map((e) => MrpActionMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      criticalMaterials: (json['critical_materials'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      costOptimizations:
          (json['cost_optimizations'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      leadTimeImprovements:
          Map<String, int>.from(json['lead_time_improvements'] as Map),
      supplierRecommendations:
          (json['supplier_recommendations'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
      totalCostSavings: (json['total_cost_savings'] as num?)?.toDouble() ?? 0.0,
      inventoryReduction:
          (json['inventory_reduction'] as num?)?.toDouble() ?? 0.0,
      generatedAt: DateTime.parse(json['generated_at'] as String),
      optimizationMetrics:
          json['optimization_metrics'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MrpRecommendationsToJson(_MrpRecommendations instance) =>
    <String, dynamic>{
      'plan_id': instance.planId,
      'action_messages':
          instance.actionMessages.map((e) => e.toJson()).toList(),
      'critical_materials': instance.criticalMaterials,
      'cost_optimizations': instance.costOptimizations,
      'lead_time_improvements': instance.leadTimeImprovements,
      'supplier_recommendations': instance.supplierRecommendations,
      'total_cost_savings': instance.totalCostSavings,
      'inventory_reduction': instance.inventoryReduction,
      'generated_at': instance.generatedAt.toIso8601String(),
      'optimization_metrics': instance.optimizationMetrics,
    };

_MrpAlert _$MrpAlertFromJson(Map<String, dynamic> json) => _MrpAlert(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      materialId: json['material_id'] as String,
      alertType: json['alert_type'] as String,
      severity: json['severity'] as String,
      message: json['message'] as String,
      alertDate: DateTime.parse(json['alert_date'] as String),
      impactQuantity: (json['impact_quantity'] as num).toDouble(),
      recommendedAction: json['recommended_action'] as String?,
      alertData: json['alert_data'] as Map<String, dynamic>?,
      isResolved: json['is_resolved'] as bool? ?? false,
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      resolvedBy: json['resolved_by'] as String?,
    );

Map<String, dynamic> _$MrpAlertToJson(_MrpAlert instance) => <String, dynamic>{
      'id': instance.id,
      'plan_id': instance.planId,
      'material_id': instance.materialId,
      'alert_type': instance.alertType,
      'severity': instance.severity,
      'message': instance.message,
      'alert_date': instance.alertDate.toIso8601String(),
      'impact_quantity': instance.impactQuantity,
      'recommended_action': instance.recommendedAction,
      'alert_data': instance.alertData,
      'is_resolved': instance.isResolved,
      'resolved_at': instance.resolvedAt?.toIso8601String(),
      'resolved_by': instance.resolvedBy,
    };

_MrpPlan _$MrpPlanFromJson(Map<String, dynamic> json) => _MrpPlan(
      id: json['id'] as String,
      planName: json['plan_name'] as String,
      planCode: json['plan_code'] as String,
      planningStartDate: DateTime.parse(json['planning_start_date'] as String),
      planningEndDate: DateTime.parse(json['planning_end_date'] as String),
      planningHorizonDays: (json['planning_horizon_days'] as num).toInt(),
      bomIds:
          (json['bom_ids'] as List<dynamic>).map((e) => e as String).toList(),
      productionSchedule:
          (json['production_schedule'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      requirements: (json['requirements'] as List<dynamic>)
          .map((e) => MrpRequirement.fromJson(e as Map<String, dynamic>))
          .toList(),
      actionMessages: (json['action_messages'] as List<dynamic>)
          .map((e) => MrpActionMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => MrpAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: $enumDecodeNullable(_$MrpPlanStatusEnumMap, json['status']) ??
          MrpPlanStatus.draft,
      totalMaterialCost:
          (json['total_material_cost'] as num?)?.toDouble() ?? 0.0,
      totalInventoryValue:
          (json['total_inventory_value'] as num?)?.toDouble() ?? 0.0,
      totalMaterials: (json['total_materials'] as num?)?.toInt() ?? 0,
      criticalMaterials: (json['critical_materials'] as num?)?.toInt() ?? 0,
      createdBy: json['created_by'] as String?,
      approvedBy: json['approved_by'] as String?,
      approvedAt: json['approved_at'] == null
          ? null
          : DateTime.parse(json['approved_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      planningParameters: json['planning_parameters'] as Map<String, dynamic>?,
      optimizationResults:
          json['optimization_results'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MrpPlanToJson(_MrpPlan instance) => <String, dynamic>{
      'id': instance.id,
      'plan_name': instance.planName,
      'plan_code': instance.planCode,
      'planning_start_date': instance.planningStartDate.toIso8601String(),
      'planning_end_date': instance.planningEndDate.toIso8601String(),
      'planning_horizon_days': instance.planningHorizonDays,
      'bom_ids': instance.bomIds,
      'production_schedule': instance.productionSchedule,
      'requirements': instance.requirements.map((e) => e.toJson()).toList(),
      'action_messages':
          instance.actionMessages.map((e) => e.toJson()).toList(),
      'alerts': instance.alerts.map((e) => e.toJson()).toList(),
      'status': _$MrpPlanStatusEnumMap[instance.status]!,
      'total_material_cost': instance.totalMaterialCost,
      'total_inventory_value': instance.totalInventoryValue,
      'total_materials': instance.totalMaterials,
      'critical_materials': instance.criticalMaterials,
      'created_by': instance.createdBy,
      'approved_by': instance.approvedBy,
      'approved_at': instance.approvedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'planning_parameters': instance.planningParameters,
      'optimization_results': instance.optimizationResults,
    };

const _$MrpPlanStatusEnumMap = {
  MrpPlanStatus.draft: 'draft',
  MrpPlanStatus.calculating: 'calculating',
  MrpPlanStatus.completed: 'completed',
  MrpPlanStatus.approved: 'approved',
  MrpPlanStatus.executed: 'executed',
  MrpPlanStatus.cancelled: 'cancelled',
};
