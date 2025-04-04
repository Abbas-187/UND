import 'package:flutter/foundation.dart';

/// Enum representing the inspection result of a supplier quality log
enum InspectionResult { pass, fail }

/// Converts [InspectionResult] enum to string
String inspectionResultToString(InspectionResult result) {
  return result.toString().split('.').last;
}

/// Converts string to [InspectionResult] enum
InspectionResult inspectionResultFromString(String result) {
  return InspectionResult.values.firstWhere(
    (e) => e.toString().split('.').last == result,
    orElse: () => throw ArgumentError('Invalid inspection result: $result'),
  );
}

/// Model class for tracking supplier quality logs
class SupplierQualityLog {
  /// Unique identifier for the quality log entry
  final String id;

  /// Identifier of the supplier being tracked
  final String supplierId;

  /// Name of the supplier being tracked
  final String supplierName;

  /// Date and time when the inspection was conducted
  final DateTime inspectionDate;

  /// Lot or batch number of the inspected delivery
  final String? lotNumber;

  /// Quality parameters specific to dairy
  final double? fatContent;
  final double? proteinContent;
  final int? bacterialCount;

  /// Result of the inspection (pass or fail)
  final InspectionResult inspectionResult;

  /// Corrective actions taken, if any
  final String? correctiveActions;

  /// Identifier of the inspector who conducted the inspection
  final String inspectorId;

  /// Name of the inspector
  final String inspectorName;

  /// Additional notes about the inspection
  final String? notes;

  /// Date and time when this log was created
  final DateTime createdAt;

  /// Date and time when this log was last updated
  final DateTime updatedAt;

  /// Creates a new [SupplierQualityLog] instance
  SupplierQualityLog({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.inspectionDate,
    this.lotNumber,
    this.fatContent,
    this.proteinContent,
    this.bacterialCount,
    required this.inspectionResult,
    this.correctiveActions,
    required this.inspectorId,
    required this.inspectorName,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this [SupplierQualityLog] instance with the given fields replaced
  SupplierQualityLog copyWith({
    String? id,
    String? supplierId,
    String? supplierName,
    DateTime? inspectionDate,
    String? lotNumber,
    double? fatContent,
    double? proteinContent,
    int? bacterialCount,
    InspectionResult? inspectionResult,
    String? correctiveActions,
    String? inspectorId,
    String? inspectorName,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupplierQualityLog(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      inspectionDate: inspectionDate ?? this.inspectionDate,
      lotNumber: lotNumber ?? this.lotNumber,
      fatContent: fatContent ?? this.fatContent,
      proteinContent: proteinContent ?? this.proteinContent,
      bacterialCount: bacterialCount ?? this.bacterialCount,
      inspectionResult: inspectionResult ?? this.inspectionResult,
      correctiveActions: correctiveActions ?? this.correctiveActions,
      inspectorId: inspectorId ?? this.inspectorId,
      inspectorName: inspectorName ?? this.inspectorName,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts this [SupplierQualityLog] instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'inspection_date': inspectionDate.toIso8601String(),
      'lot_number': lotNumber,
      'fat_content': fatContent,
      'protein_content': proteinContent,
      'bacterial_count': bacterialCount,
      'inspection_result': inspectionResultToString(inspectionResult),
      'corrective_actions': correctiveActions,
      'inspector_id': inspectorId,
      'inspector_name': inspectorName,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a [SupplierQualityLog] instance from a JSON map
  factory SupplierQualityLog.fromJson(Map<String, dynamic> json) {
    return SupplierQualityLog(
      id: json['id'],
      supplierId: json['supplier_id'],
      supplierName: json['supplier_name'],
      inspectionDate: DateTime.parse(json['inspection_date']),
      lotNumber: json['lot_number'],
      fatContent: json['fat_content'],
      proteinContent: json['protein_content'],
      bacterialCount: json['bacterial_count'],
      inspectionResult: inspectionResultFromString(json['inspection_result']),
      correctiveActions: json['corrective_actions'],
      inspectorId: json['inspector_id'],
      inspectorName: json['inspector_name'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
  String toString() {
    return 'SupplierQualityLog(id: $id, supplierId: $supplierId, inspectionDate: $inspectionDate, inspectionResult: $inspectionResult)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SupplierQualityLog &&
        other.id == id &&
        other.supplierId == supplierId &&
        other.supplierName == supplierName &&
        other.inspectionDate == inspectionDate &&
        other.lotNumber == lotNumber &&
        other.fatContent == fatContent &&
        other.proteinContent == proteinContent &&
        other.bacterialCount == bacterialCount &&
        other.inspectionResult == inspectionResult &&
        other.correctiveActions == correctiveActions &&
        other.inspectorId == inspectorId &&
        other.inspectorName == inspectorName &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      supplierId,
      supplierName,
      inspectionDate,
      lotNumber,
      fatContent,
      proteinContent,
      bacterialCount,
      inspectionResult,
      correctiveActions,
      inspectorId,
      inspectorName,
      notes,
      createdAt,
      updatedAt,
    );
  }
}
