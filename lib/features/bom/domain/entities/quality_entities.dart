import 'package:freezed_annotation/freezed_annotation.dart';

part 'quality_entities.freezed.dart';
part 'quality_entities.g.dart';

/// Enumeration for quality status
enum QualityStatus {
  excellent,
  good,
  acceptable,
  belowStandard,
  poor,
  rejected,
  pending,
  approved,
  quarantine,
}

/// Enumeration for quality test types
enum QualityTestType {
  incoming,
  inProcess,
  final_,
  supplier,
  customer,
  regulatory,
}

/// Quality score for materials and suppliers
@freezed
abstract class QualityScore with _$QualityScore {
  const factory QualityScore({
    required String materialId,
    required String materialCode,
    required String materialName,
    required double overallScore,
    required Map<String, double> parameterScores,
    required int totalTests,
    required int passedTests,
    required int failedTests,
    @Default(0) int defectCount,
    @Default(0.0) double defectRate,
    required DateTime calculatedAt,
    String? supplierId,
    String? supplierName,
    Map<String, dynamic>? qualityMetrics,
  }) = _QualityScore;

  const QualityScore._();

  factory QualityScore.fromJson(Map<String, dynamic> json) =>
      _$QualityScoreFromJson(json);

  /// Calculate pass rate percentage
  double get passRate {
    if (totalTests == 0) return 0.0;
    return (passedTests / totalTests) * 100;
  }

  /// Get quality grade based on score
  String get qualityGrade {
    if (overallScore >= 95) return 'A+';
    if (overallScore >= 90) return 'A';
    if (overallScore >= 85) return 'B+';
    if (overallScore >= 80) return 'B';
    if (overallScore >= 75) return 'C+';
    if (overallScore >= 70) return 'C';
    return 'D';
  }

  /// Check if quality is acceptable
  bool get isAcceptable => overallScore >= 70.0;
}

/// Quality alert for issues and risks
@freezed
abstract class QualityAlert with _$QualityAlert {
  const factory QualityAlert({
    required String id,
    required String materialId,
    required String materialCode,
    required String alertType,
    required String severity,
    required String message,
    required DateTime alertDate,
    required double impactScore,
    String? supplierId,
    String? bomId,
    String? recommendedAction,
    Map<String, dynamic>? alertData,
    @Default(false) bool isResolved,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? resolutionNotes,
  }) = _QualityAlert;

  factory QualityAlert.fromJson(Map<String, dynamic> json) =>
      _$QualityAlertFromJson(json);
}

/// Quality optimization recommendation
@freezed
abstract class QualityOptimization with _$QualityOptimization {
  const factory QualityOptimization({
    required String id,
    required String bomId,
    required String optimizationType,
    required String description,
    required double expectedImprovement,
    required double implementationCost,
    required int implementationDays,
    required String priority,
    required List<String> affectedMaterials,
    required Map<String, dynamic> optimizationData,
    @Default(0.0) double riskLevel,
    @Default(0.0) double confidenceScore,
    required DateTime createdAt,
    String? createdBy,
  }) = _QualityOptimization;

  const QualityOptimization._();

  factory QualityOptimization.fromJson(Map<String, dynamic> json) =>
      _$QualityOptimizationFromJson(json);

  /// Calculate ROI for the optimization
  double get roi {
    if (implementationCost == 0) return 0.0;
    return (expectedImprovement / implementationCost) * 100;
  }

  /// Get implementation complexity level
  String get complexityLevel {
    if (implementationDays <= 7) return 'Low';
    if (implementationDays <= 30) return 'Medium';
    return 'High';
  }
}

/// Quality impact analysis result
@freezed
abstract class QualityImpactAnalysis with _$QualityImpactAnalysis {
  const factory QualityImpactAnalysis({
    required String bomId,
    required double overallQualityScore,
    required Map<String, QualityScore> materialQualityScores,
    required List<QualityAlert> qualityRisks,
    required List<String> criticalMaterials,
    required Map<String, double> supplierQualityScores,
    @Default(0.0) double qualityCostImpact,
    @Default(0.0) double defectProbability,
    required DateTime analysisDate,
    Map<String, dynamic>? analysisMetrics,
  }) = _QualityImpactAnalysis;

  const QualityImpactAnalysis._();

  factory QualityImpactAnalysis.fromJson(Map<String, dynamic> json) =>
      _$QualityImpactAnalysisFromJson(json);

  /// Get quality risk level
  String get riskLevel {
    if (defectProbability > 0.1) return 'High';
    if (defectProbability > 0.05) return 'Medium';
    return 'Low';
  }

  /// Get materials below quality threshold
  List<String> getMaterialsBelowThreshold(double threshold) {
    return materialQualityScores.entries
        .where((entry) => entry.value.overallScore < threshold)
        .map((entry) => entry.key)
        .toList();
  }
}

/// Supplier quality performance
@freezed
abstract class SupplierQualityPerformance with _$SupplierQualityPerformance {
  const factory SupplierQualityPerformance({
    required String supplierId,
    required String supplierName,
    required double overallQualityScore,
    required Map<String, double> materialQualityScores,
    required int totalDeliveries,
    required int qualityIssues,
    required double defectRate,
    required double onTimeDeliveryRate,
    required List<QualityAlert> recentIssues,
    @Default(0.0) double improvementTrend,
    @Default('stable') String performanceTrend,
    required DateTime lastEvaluationDate,
    Map<String, dynamic>? performanceMetrics,
  }) = _SupplierQualityPerformance;

  const SupplierQualityPerformance._();

  factory SupplierQualityPerformance.fromJson(Map<String, dynamic> json) =>
      _$SupplierQualityPerformanceFromJson(json);

  /// Calculate quality reliability score
  double get reliabilityScore {
    final qualityWeight = 0.6;
    final deliveryWeight = 0.4;
    return (overallQualityScore * qualityWeight) +
        (onTimeDeliveryRate * deliveryWeight);
  }

  /// Get supplier rating
  String get supplierRating {
    if (reliabilityScore >= 95) return 'Preferred';
    if (reliabilityScore >= 85) return 'Approved';
    if (reliabilityScore >= 75) return 'Conditional';
    return 'Under Review';
  }

  /// Check if supplier needs attention
  bool get needsAttention {
    return defectRate > 0.05 ||
        onTimeDeliveryRate < 0.9 ||
        recentIssues.length > 3;
  }
}

/// Quality certification tracking
@freezed
abstract class QualityCertification with _$QualityCertification {
  const factory QualityCertification({
    required String id,
    required String materialId,
    required String supplierId,
    required String certificationType,
    required String certificateNumber,
    required DateTime issuedDate,
    required DateTime expiryDate,
    required String issuingAuthority,
    required QualityStatus status,
    @Default([]) List<String> attachmentUrls,
    String? notes,
    DateTime? lastVerificationDate,
    String? verifiedBy,
  }) = _QualityCertification;

  const QualityCertification._();

  factory QualityCertification.fromJson(Map<String, dynamic> json) =>
      _$QualityCertificationFromJson(json);

  /// Check if certification is valid
  bool get isValid {
    return status == QualityStatus.approved &&
        DateTime.now().isBefore(expiryDate);
  }

  /// Get days until expiry
  int get daysUntilExpiry {
    return expiryDate.difference(DateTime.now()).inDays;
  }

  /// Check if certification is expiring soon
  bool get isExpiringSoon {
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }
}
