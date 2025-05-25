// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quality_entities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QualityScore _$QualityScoreFromJson(Map<String, dynamic> json) =>
    _QualityScore(
      materialId: json['material_id'] as String,
      materialCode: json['material_code'] as String,
      materialName: json['material_name'] as String,
      overallScore: (json['overall_score'] as num).toDouble(),
      parameterScores: (json['parameter_scores'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      totalTests: (json['total_tests'] as num).toInt(),
      passedTests: (json['passed_tests'] as num).toInt(),
      failedTests: (json['failed_tests'] as num).toInt(),
      defectCount: (json['defect_count'] as num?)?.toInt() ?? 0,
      defectRate: (json['defect_rate'] as num?)?.toDouble() ?? 0.0,
      calculatedAt: DateTime.parse(json['calculated_at'] as String),
      supplierId: json['supplier_id'] as String?,
      supplierName: json['supplier_name'] as String?,
      qualityMetrics: json['quality_metrics'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$QualityScoreToJson(_QualityScore instance) =>
    <String, dynamic>{
      'material_id': instance.materialId,
      'material_code': instance.materialCode,
      'material_name': instance.materialName,
      'overall_score': instance.overallScore,
      'parameter_scores': instance.parameterScores,
      'total_tests': instance.totalTests,
      'passed_tests': instance.passedTests,
      'failed_tests': instance.failedTests,
      'defect_count': instance.defectCount,
      'defect_rate': instance.defectRate,
      'calculated_at': instance.calculatedAt.toIso8601String(),
      'supplier_id': instance.supplierId,
      'supplier_name': instance.supplierName,
      'quality_metrics': instance.qualityMetrics,
    };

_QualityAlert _$QualityAlertFromJson(Map<String, dynamic> json) =>
    _QualityAlert(
      id: json['id'] as String,
      materialId: json['material_id'] as String,
      materialCode: json['material_code'] as String,
      alertType: json['alert_type'] as String,
      severity: json['severity'] as String,
      message: json['message'] as String,
      alertDate: DateTime.parse(json['alert_date'] as String),
      impactScore: (json['impact_score'] as num).toDouble(),
      supplierId: json['supplier_id'] as String?,
      bomId: json['bom_id'] as String?,
      recommendedAction: json['recommended_action'] as String?,
      alertData: json['alert_data'] as Map<String, dynamic>?,
      isResolved: json['is_resolved'] as bool? ?? false,
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      resolvedBy: json['resolved_by'] as String?,
      resolutionNotes: json['resolution_notes'] as String?,
    );

Map<String, dynamic> _$QualityAlertToJson(_QualityAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'material_id': instance.materialId,
      'material_code': instance.materialCode,
      'alert_type': instance.alertType,
      'severity': instance.severity,
      'message': instance.message,
      'alert_date': instance.alertDate.toIso8601String(),
      'impact_score': instance.impactScore,
      'supplier_id': instance.supplierId,
      'bom_id': instance.bomId,
      'recommended_action': instance.recommendedAction,
      'alert_data': instance.alertData,
      'is_resolved': instance.isResolved,
      'resolved_at': instance.resolvedAt?.toIso8601String(),
      'resolved_by': instance.resolvedBy,
      'resolution_notes': instance.resolutionNotes,
    };

_QualityOptimization _$QualityOptimizationFromJson(Map<String, dynamic> json) =>
    _QualityOptimization(
      id: json['id'] as String,
      bomId: json['bom_id'] as String,
      optimizationType: json['optimization_type'] as String,
      description: json['description'] as String,
      expectedImprovement: (json['expected_improvement'] as num).toDouble(),
      implementationCost: (json['implementation_cost'] as num).toDouble(),
      implementationDays: (json['implementation_days'] as num).toInt(),
      priority: json['priority'] as String,
      affectedMaterials: (json['affected_materials'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      optimizationData: json['optimization_data'] as Map<String, dynamic>,
      riskLevel: (json['risk_level'] as num?)?.toDouble() ?? 0.0,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String?,
    );

Map<String, dynamic> _$QualityOptimizationToJson(
        _QualityOptimization instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bom_id': instance.bomId,
      'optimization_type': instance.optimizationType,
      'description': instance.description,
      'expected_improvement': instance.expectedImprovement,
      'implementation_cost': instance.implementationCost,
      'implementation_days': instance.implementationDays,
      'priority': instance.priority,
      'affected_materials': instance.affectedMaterials,
      'optimization_data': instance.optimizationData,
      'risk_level': instance.riskLevel,
      'confidence_score': instance.confidenceScore,
      'created_at': instance.createdAt.toIso8601String(),
      'created_by': instance.createdBy,
    };

_QualityImpactAnalysis _$QualityImpactAnalysisFromJson(
        Map<String, dynamic> json) =>
    _QualityImpactAnalysis(
      bomId: json['bom_id'] as String,
      overallQualityScore: (json['overall_quality_score'] as num).toDouble(),
      materialQualityScores:
          (json['material_quality_scores'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, QualityScore.fromJson(e as Map<String, dynamic>)),
      ),
      qualityRisks: (json['quality_risks'] as List<dynamic>)
          .map((e) => QualityAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
      criticalMaterials: (json['critical_materials'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      supplierQualityScores:
          (json['supplier_quality_scores'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      qualityCostImpact:
          (json['quality_cost_impact'] as num?)?.toDouble() ?? 0.0,
      defectProbability:
          (json['defect_probability'] as num?)?.toDouble() ?? 0.0,
      analysisDate: DateTime.parse(json['analysis_date'] as String),
      analysisMetrics: json['analysis_metrics'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$QualityImpactAnalysisToJson(
        _QualityImpactAnalysis instance) =>
    <String, dynamic>{
      'bom_id': instance.bomId,
      'overall_quality_score': instance.overallQualityScore,
      'material_quality_scores':
          instance.materialQualityScores.map((k, e) => MapEntry(k, e.toJson())),
      'quality_risks': instance.qualityRisks.map((e) => e.toJson()).toList(),
      'critical_materials': instance.criticalMaterials,
      'supplier_quality_scores': instance.supplierQualityScores,
      'quality_cost_impact': instance.qualityCostImpact,
      'defect_probability': instance.defectProbability,
      'analysis_date': instance.analysisDate.toIso8601String(),
      'analysis_metrics': instance.analysisMetrics,
    };

_SupplierQualityPerformance _$SupplierQualityPerformanceFromJson(
        Map<String, dynamic> json) =>
    _SupplierQualityPerformance(
      supplierId: json['supplier_id'] as String,
      supplierName: json['supplier_name'] as String,
      overallQualityScore: (json['overall_quality_score'] as num).toDouble(),
      materialQualityScores:
          (json['material_quality_scores'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      totalDeliveries: (json['total_deliveries'] as num).toInt(),
      qualityIssues: (json['quality_issues'] as num).toInt(),
      defectRate: (json['defect_rate'] as num).toDouble(),
      onTimeDeliveryRate: (json['on_time_delivery_rate'] as num).toDouble(),
      recentIssues: (json['recent_issues'] as List<dynamic>)
          .map((e) => QualityAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
      improvementTrend: (json['improvement_trend'] as num?)?.toDouble() ?? 0.0,
      performanceTrend: json['performance_trend'] as String? ?? 'stable',
      lastEvaluationDate:
          DateTime.parse(json['last_evaluation_date'] as String),
      performanceMetrics: json['performance_metrics'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SupplierQualityPerformanceToJson(
        _SupplierQualityPerformance instance) =>
    <String, dynamic>{
      'supplier_id': instance.supplierId,
      'supplier_name': instance.supplierName,
      'overall_quality_score': instance.overallQualityScore,
      'material_quality_scores': instance.materialQualityScores,
      'total_deliveries': instance.totalDeliveries,
      'quality_issues': instance.qualityIssues,
      'defect_rate': instance.defectRate,
      'on_time_delivery_rate': instance.onTimeDeliveryRate,
      'recent_issues': instance.recentIssues.map((e) => e.toJson()).toList(),
      'improvement_trend': instance.improvementTrend,
      'performance_trend': instance.performanceTrend,
      'last_evaluation_date': instance.lastEvaluationDate.toIso8601String(),
      'performance_metrics': instance.performanceMetrics,
    };

_QualityCertification _$QualityCertificationFromJson(
        Map<String, dynamic> json) =>
    _QualityCertification(
      id: json['id'] as String,
      materialId: json['material_id'] as String,
      supplierId: json['supplier_id'] as String,
      certificationType: json['certification_type'] as String,
      certificateNumber: json['certificate_number'] as String,
      issuedDate: DateTime.parse(json['issued_date'] as String),
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      issuingAuthority: json['issuing_authority'] as String,
      status: $enumDecode(_$QualityStatusEnumMap, json['status']),
      attachmentUrls: (json['attachment_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      notes: json['notes'] as String?,
      lastVerificationDate: json['last_verification_date'] == null
          ? null
          : DateTime.parse(json['last_verification_date'] as String),
      verifiedBy: json['verified_by'] as String?,
    );

Map<String, dynamic> _$QualityCertificationToJson(
        _QualityCertification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'material_id': instance.materialId,
      'supplier_id': instance.supplierId,
      'certification_type': instance.certificationType,
      'certificate_number': instance.certificateNumber,
      'issued_date': instance.issuedDate.toIso8601String(),
      'expiry_date': instance.expiryDate.toIso8601String(),
      'issuing_authority': instance.issuingAuthority,
      'status': _$QualityStatusEnumMap[instance.status]!,
      'attachment_urls': instance.attachmentUrls,
      'notes': instance.notes,
      'last_verification_date':
          instance.lastVerificationDate?.toIso8601String(),
      'verified_by': instance.verifiedBy,
    };

const _$QualityStatusEnumMap = {
  QualityStatus.excellent: 'excellent',
  QualityStatus.good: 'good',
  QualityStatus.acceptable: 'acceptable',
  QualityStatus.belowStandard: 'belowStandard',
  QualityStatus.poor: 'poor',
  QualityStatus.rejected: 'rejected',
  QualityStatus.pending: 'pending',
  QualityStatus.approved: 'approved',
  QualityStatus.quarantine: 'quarantine',
};
