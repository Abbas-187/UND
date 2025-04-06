import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum representing different quality grades for milk
enum QualityGrade {
  gradeA, // Premium quality
  gradeB, // Standard quality
  gradeC, // Substandard quality
  rejected // Failed quality tests
}

/// A comprehensive model for milk quality test results linked to receptions
class MilkQualityTestModel {

  /// Creates an empty quality test record with default values
  factory MilkQualityTestModel.empty() {
    return MilkQualityTestModel(
      id: '',
      receptionId: '',
      timestamp: DateTime.now(),
      technicianId: '',
      equipmentUsed: '',
      sampleCode: '',
      fatContent: 0.0,
      proteinContent: 0.0,
      lactoseContent: 0.0,
      totalSolids: 0.0,
      somaticCellCount: 0,
      bacterialCount: 0,
      antibioticsPresent: false,
      aflatoxinLevel: 0.0,
      addedWaterPercent: 0.0,
      acidity: 0.0,
      density: 0.0,
      freezingPoint: 0.0,
    );
  }

  /// Creates a model from Firestore document
  factory MilkQualityTestModel.fromJson(Map<String, dynamic> json) {
    return MilkQualityTestModel(
      id: json['id'] as String,
      receptionId: json['receptionId'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      technicianId: json['technicianId'] as String,
      equipmentUsed: json['equipmentUsed'] as String,
      sampleCode: json['sampleCode'] as String,
      fatContent: (json['fatContent'] as num).toDouble(),
      proteinContent: (json['proteinContent'] as num).toDouble(),
      lactoseContent: (json['lactoseContent'] as num).toDouble(),
      totalSolids: (json['totalSolids'] as num).toDouble(),
      somaticCellCount: json['somaticCellCount'] as int,
      bacterialCount: json['bacterialCount'] as int,
      antibioticsPresent: json['antibioticsPresent'] as bool,
      aflatoxinLevel: (json['aflatoxinLevel'] as num).toDouble(),
      addedWaterPercent: (json['addedWaterPercent'] as num).toDouble(),
      acidity: (json['acidity'] as num).toDouble(),
      density: (json['density'] as num).toDouble(),
      freezingPoint: (json['freezingPoint'] as num).toDouble(),
      qualityGrade: json['qualityGrade'] != null
          ? QualityGrade.values.firstWhere(
              (e) => e.toString() == json['qualityGrade'],
              orElse: () => QualityGrade.rejected,
            )
          : null,
      notes: json['notes'] as String?,
      priceAdjustmentFactor: json['priceAdjustmentFactor'] != null
          ? (json['priceAdjustmentFactor'] as num).toDouble()
          : 1.0,
    );
  }
  const MilkQualityTestModel({
    required this.id,
    required this.receptionId,
    required this.timestamp,
    required this.technicianId,
    required this.equipmentUsed,
    required this.sampleCode,
    required this.fatContent,
    required this.proteinContent,
    required this.lactoseContent,
    required this.totalSolids,
    required this.somaticCellCount,
    required this.bacterialCount,
    required this.antibioticsPresent,
    required this.aflatoxinLevel,
    required this.addedWaterPercent,
    required this.acidity,
    required this.density,
    required this.freezingPoint,
    this.qualityGrade,
    this.notes,
    this.priceAdjustmentFactor = 1.0,
  });

  /// Unique identifier for this test
  final String id;

  /// Reference to the milk reception this test is for
  final String receptionId;

  /// Time when the test was conducted
  final DateTime timestamp;

  /// ID of the lab technician who performed the test
  final String technicianId;

  /// Equipment used for conducting the tests
  final String equipmentUsed;

  /// Identification code for the sample
  final String sampleCode;

  /// Fat content percentage
  final double fatContent;

  /// Protein content percentage
  final double proteinContent;

  /// Lactose content percentage
  final double lactoseContent;

  /// Total solids percentage
  final double totalSolids;

  /// Somatic cell count (cells/mL)
  final int somaticCellCount;

  /// Bacterial count (CFU/mL)
  final int bacterialCount;

  /// Presence of antibiotics
  final bool antibioticsPresent;

  /// Aflatoxin level in parts per billion (ppb)
  final double aflatoxinLevel;

  /// Percentage of added water detected
  final double addedWaterPercent;

  /// Acidity (pH value or °SH)
  final double acidity;

  /// Density in kg/m³
  final double density;

  /// Freezing point in °C
  final double freezingPoint;

  /// Quality grade calculated based on test parameters
  final QualityGrade? qualityGrade;

  /// Additional notes or observations
  final String? notes;

  /// Price adjustment factor based on quality (multiplier for base price)
  final double priceAdjustmentFactor;

  /// Converts model to a JSON map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receptionId': receptionId,
      'timestamp': Timestamp.fromDate(timestamp),
      'technicianId': technicianId,
      'equipmentUsed': equipmentUsed,
      'sampleCode': sampleCode,
      'fatContent': fatContent,
      'proteinContent': proteinContent,
      'lactoseContent': lactoseContent,
      'totalSolids': totalSolids,
      'somaticCellCount': somaticCellCount,
      'bacterialCount': bacterialCount,
      'antibioticsPresent': antibioticsPresent,
      'aflatoxinLevel': aflatoxinLevel,
      'addedWaterPercent': addedWaterPercent,
      'acidity': acidity,
      'density': density,
      'freezingPoint': freezingPoint,
      'qualityGrade': qualityGrade?.toString(),
      'notes': notes,
      'priceAdjustmentFactor': priceAdjustmentFactor,
    };
  }

  /// Creates a copy of this model with specified fields replaced
  MilkQualityTestModel copyWith({
    String? id,
    String? receptionId,
    DateTime? timestamp,
    String? technicianId,
    String? equipmentUsed,
    String? sampleCode,
    double? fatContent,
    double? proteinContent,
    double? lactoseContent,
    double? totalSolids,
    int? somaticCellCount,
    int? bacterialCount,
    bool? antibioticsPresent,
    double? aflatoxinLevel,
    double? addedWaterPercent,
    double? acidity,
    double? density,
    double? freezingPoint,
    QualityGrade? qualityGrade,
    String? notes,
    double? priceAdjustmentFactor,
  }) {
    return MilkQualityTestModel(
      id: id ?? this.id,
      receptionId: receptionId ?? this.receptionId,
      timestamp: timestamp ?? this.timestamp,
      technicianId: technicianId ?? this.technicianId,
      equipmentUsed: equipmentUsed ?? this.equipmentUsed,
      sampleCode: sampleCode ?? this.sampleCode,
      fatContent: fatContent ?? this.fatContent,
      proteinContent: proteinContent ?? this.proteinContent,
      lactoseContent: lactoseContent ?? this.lactoseContent,
      totalSolids: totalSolids ?? this.totalSolids,
      somaticCellCount: somaticCellCount ?? this.somaticCellCount,
      bacterialCount: bacterialCount ?? this.bacterialCount,
      antibioticsPresent: antibioticsPresent ?? this.antibioticsPresent,
      aflatoxinLevel: aflatoxinLevel ?? this.aflatoxinLevel,
      addedWaterPercent: addedWaterPercent ?? this.addedWaterPercent,
      acidity: acidity ?? this.acidity,
      density: density ?? this.density,
      freezingPoint: freezingPoint ?? this.freezingPoint,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      notes: notes ?? this.notes,
      priceAdjustmentFactor:
          priceAdjustmentFactor ?? this.priceAdjustmentFactor,
    );
  }

  /// Validates if fat content is within expected range (2.5-6.0%)
  bool isFatContentValid() {
    return fatContent >= 2.5 && fatContent <= 6.0;
  }

  /// Validates if protein content is within expected range (2.8-4.0%)
  bool isProteinContentValid() {
    return proteinContent >= 2.8 && proteinContent <= 4.0;
  }

  /// Validates if lactose content is within expected range (3.8-5.2%)
  bool isLactoseContentValid() {
    return lactoseContent >= 3.8 && lactoseContent <= 5.2;
  }

  /// Validates if total solids is within expected range (11-14%)
  bool isTotalSolidsValid() {
    return totalSolids >= 11.0 && totalSolids <= 14.0;
  }

  /// Validates if somatic cell count is below acceptable limit (400,000 cells/mL)
  bool isSomaticCellCountValid() {
    return somaticCellCount < 400000;
  }

  /// Validates if bacterial count is below acceptable limit (100,000 CFU/mL)
  bool isBacterialCountValid() {
    return bacterialCount < 100000;
  }

  /// Validates if aflatoxin level is below acceptable limit (0.5 ppb)
  bool isAflatoxinLevelValid() {
    return aflatoxinLevel < 0.5;
  }

  /// Validates if added water percentage is below acceptable limit (3%)
  bool isAddedWaterValid() {
    return addedWaterPercent < 3.0;
  }

  /// Validates if freezing point is within expected range (-0.550 to -0.520°C)
  bool isFreezingPointValid() {
    return freezingPoint >= -0.550 && freezingPoint <= -0.520;
  }

  /// Validates if milk is free from antibiotics
  bool isAntibioticFree() {
    return !antibioticsPresent;
  }

  /// Comprehensive validation of all test parameters
  bool areTestParametersValid() {
    return isFatContentValid() &&
        isProteinContentValid() &&
        isLactoseContentValid() &&
        isTotalSolidsValid() &&
        isSomaticCellCountValid() &&
        isBacterialCountValid() &&
        isAflatoxinLevelValid() &&
        isAddedWaterValid() &&
        isFreezingPointValid() &&
        isAntibioticFree();
  }

  /// Validates if all required fields are non-null and non-empty
  bool areRequiredFieldsValid() {
    return id.isNotEmpty &&
        receptionId.isNotEmpty &&
        technicianId.isNotEmpty &&
        equipmentUsed.isNotEmpty &&
        sampleCode.isNotEmpty;
  }

  /// Determines if the milk sample passes all acceptance criteria
  bool isAcceptable() {
    // Automatic rejection if antibiotics are present
    if (antibioticsPresent) return false;

    // Automatic rejection if aflatoxin exceeds safety limit
    if (aflatoxinLevel > 0.5) return false;

    // Automatic rejection if added water exceeds maximum allowed
    if (addedWaterPercent > 10.0) return false;

    // Check other key parameters
    bool passesBasicQuality = somaticCellCount <
            750000 && // Higher threshold for acceptance vs. Grade A
        bacterialCount <
            500000 && // Higher threshold for acceptance vs. Grade A
        fatContent > 2.5 &&
        proteinContent > 2.8;

    return passesBasicQuality;
  }

  /// Calculates quality grade based on test parameters
  QualityGrade calculateQualityGrade() {
    // Automatic rejection conditions
    if (antibioticsPresent ||
        aflatoxinLevel > 0.5 ||
        addedWaterPercent > 10.0) {
      return QualityGrade.rejected;
    }

    // Grade A criteria
    if (fatContent >= 3.5 &&
        proteinContent >= 3.2 &&
        totalSolids >= 12.5 &&
        somaticCellCount < 200000 &&
        bacterialCount < 50000 &&
        addedWaterPercent < 1.0) {
      return QualityGrade.gradeA;
    }

    // Grade B criteria
    if (fatContent >= 3.0 &&
        proteinContent >= 3.0 &&
        totalSolids >= 12.0 &&
        somaticCellCount < 350000 &&
        bacterialCount < 100000 &&
        addedWaterPercent < 2.0) {
      return QualityGrade.gradeB;
    }

    // Grade C criteria - anything that passes minimal acceptance but not A or B
    if (isAcceptable()) {
      return QualityGrade.gradeC;
    }

    // Default to rejected
    return QualityGrade.rejected;
  }

  /// Calculates price adjustment factor based on quality grade
  double calculatePriceAdjustmentFactor() {
    QualityGrade grade = qualityGrade ?? calculateQualityGrade();

    switch (grade) {
      case QualityGrade.gradeA:
        return 1.10; // 10% premium
      case QualityGrade.gradeB:
        return 1.00; // standard price
      case QualityGrade.gradeC:
        return 0.90; // 10% discount
      case QualityGrade.rejected:
        return 0.00; // no payment for rejected milk
    }
  }

  /// Returns MilkQualityTestModel with calculated quality grade and price adjustment
  MilkQualityTestModel withCalculatedQuality() {
    final calculatedGrade = calculateQualityGrade();
    final calculatedPriceAdjustment = calculatePriceAdjustmentFactor();

    return copyWith(
      qualityGrade: calculatedGrade,
      priceAdjustmentFactor: calculatedPriceAdjustment,
    );
  }
}
