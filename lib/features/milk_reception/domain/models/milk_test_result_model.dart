import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

@immutable
class MilkTestResultModel {
  factory MilkTestResultModel.fromMap(Map<String, dynamic> map) {
    return MilkTestResultModel(
      testedBy: map['testedBy'] as String,
      testDate: (map['testDate'] as Timestamp).toDate(),
      fatContent: (map['fatContent'] as num).toDouble(),
      proteinContent: (map['proteinContent'] as num).toDouble(),
      lactoseContent: (map['lactoseContent'] as num).toDouble(),
      snf: (map['snf'] as num).toDouble(),
      density: (map['density'] as num).toDouble(),
      freezingPoint: (map['freezingPoint'] as num).toDouble(),
      addedWater: (map['addedWater'] as num?)?.toDouble(),
      phLevel: (map['phLevel'] as num).toDouble(),
      saltContent: (map['saltContent'] as num).toDouble(),
      antibiotics: map['antibiotics'] as bool,
      somaticCellCount: (map['somaticCellCount'] as num?)?.toInt(),
      coliformCount: (map['coliformCount'] as num?)?.toInt(),
      totalPlateCount: (map['totalPlateCount'] as num?)?.toInt(),
      comments: map['comments'] as String?,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }
  const MilkTestResultModel({
    required this.testedBy,
    required this.testDate,
    required this.fatContent,
    required this.proteinContent,
    required this.lactoseContent,
    required this.snf,
    required this.density,
    required this.freezingPoint,
    this.addedWater,
    required this.phLevel,
    required this.saltContent,
    required this.antibiotics,
    this.somaticCellCount,
    this.coliformCount,
    this.totalPlateCount,
    this.comments,
    required this.metadata,
  });

  final String testedBy;
  final DateTime testDate;
  final double fatContent;
  final double proteinContent;
  final double lactoseContent;
  final double snf; // Solids-not-fat
  final double density;
  final double freezingPoint;
  final double? addedWater;
  final double phLevel;
  final double saltContent;
  final bool antibiotics;
  final int? somaticCellCount;
  final int? coliformCount;
  final int? totalPlateCount;
  final String? comments;
  final Map<String, dynamic> metadata;

  MilkTestResultModel copyWith({
    String? testedBy,
    DateTime? testDate,
    double? fatContent,
    double? proteinContent,
    double? lactoseContent,
    double? snf,
    double? density,
    double? freezingPoint,
    double? addedWater,
    double? phLevel,
    double? saltContent,
    bool? antibiotics,
    int? somaticCellCount,
    int? coliformCount,
    int? totalPlateCount,
    String? comments,
    Map<String, dynamic>? metadata,
  }) {
    return MilkTestResultModel(
      testedBy: testedBy ?? this.testedBy,
      testDate: testDate ?? this.testDate,
      fatContent: fatContent ?? this.fatContent,
      proteinContent: proteinContent ?? this.proteinContent,
      lactoseContent: lactoseContent ?? this.lactoseContent,
      snf: snf ?? this.snf,
      density: density ?? this.density,
      freezingPoint: freezingPoint ?? this.freezingPoint,
      addedWater: addedWater ?? this.addedWater,
      phLevel: phLevel ?? this.phLevel,
      saltContent: saltContent ?? this.saltContent,
      antibiotics: antibiotics ?? this.antibiotics,
      somaticCellCount: somaticCellCount ?? this.somaticCellCount,
      coliformCount: coliformCount ?? this.coliformCount,
      totalPlateCount: totalPlateCount ?? this.totalPlateCount,
      comments: comments ?? this.comments,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'testedBy': testedBy,
      'testDate': Timestamp.fromDate(testDate),
      'fatContent': fatContent,
      'proteinContent': proteinContent,
      'lactoseContent': lactoseContent,
      'snf': snf,
      'density': density,
      'freezingPoint': freezingPoint,
      'addedWater': addedWater,
      'phLevel': phLevel,
      'saltContent': saltContent,
      'antibiotics': antibiotics,
      'somaticCellCount': somaticCellCount,
      'coliformCount': coliformCount,
      'totalPlateCount': totalPlateCount,
      'comments': comments,
      'metadata': metadata,
    };
  }

  // Helper method to determine if test results pass quality standards
  bool get isPassing {
    // Default implementation - can be enhanced with actual quality standards
    return antibiotics == false &&
        (somaticCellCount == null || somaticCellCount! < 400000) &&
        (coliformCount == null || coliformCount! < 100);
  }
}
