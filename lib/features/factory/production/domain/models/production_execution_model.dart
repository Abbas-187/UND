import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

/// Enum representing different statuses for production execution
enum ProductionExecutionStatus {
  planned,
  inProgress,
  completed,
  paused,
  cancelled,
  failed
}

/// Enum representing different quality metrics ratings
enum QualityRating {
  excellent,
  good,
  acceptable,
  belowStandard,
  poor,
  rejected
}

/// Class representing raw material usage in production
class MaterialUsage {

  const MaterialUsage({
    required this.materialId,
    required this.materialName,
    required this.plannedQuantity,
    required this.actualQuantity,
    required this.unitOfMeasure,
    this.batchNumber,
    this.expiryDate,
  });

  factory MaterialUsage.fromJson(Map<String, dynamic> json) {
    return MaterialUsage(
      materialId: json['materialId'] as String,
      materialName: json['materialName'] as String,
      plannedQuantity: (json['plannedQuantity'] as num).toDouble(),
      actualQuantity: (json['actualQuantity'] as num).toDouble(),
      unitOfMeasure: json['unitOfMeasure'] as String,
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
    );
  }
  final String materialId;
  final String materialName;
  final double plannedQuantity;
  final double actualQuantity;
  final String unitOfMeasure;
  final String? batchNumber;
  final DateTime? expiryDate;

  /// Creates a copy with specified fields replaced
  MaterialUsage copyWith({
    String? materialId,
    String? materialName,
    double? plannedQuantity,
    double? actualQuantity,
    String? unitOfMeasure,
    String? batchNumber,
    DateTime? expiryDate,
  }) {
    return MaterialUsage(
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      plannedQuantity: plannedQuantity ?? this.plannedQuantity,
      actualQuantity: actualQuantity ?? this.actualQuantity,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'materialName': materialName,
      'plannedQuantity': plannedQuantity,
      'actualQuantity': actualQuantity,
      'unitOfMeasure': unitOfMeasure,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }
}

/// Class representing assigned personnel in production
class AssignedPersonnel {

  const AssignedPersonnel({
    required this.personnelId,
    required this.personnelName,
    required this.role,
    required this.assignedStartTime,
    this.assignedEndTime,
  });

  factory AssignedPersonnel.fromJson(Map<String, dynamic> json) {
    return AssignedPersonnel(
      personnelId: json['personnelId'] as String,
      personnelName: json['personnelName'] as String,
      role: json['role'] as String,
      assignedStartTime: DateTime.parse(json['assignedStartTime'] as String),
      assignedEndTime: json['assignedEndTime'] != null
          ? DateTime.parse(json['assignedEndTime'] as String)
          : null,
    );
  }
  final String personnelId;
  final String personnelName;
  final String role;
  final DateTime assignedStartTime;
  final DateTime? assignedEndTime;

  /// Creates a copy with specified fields replaced
  AssignedPersonnel copyWith({
    String? personnelId,
    String? personnelName,
    String? role,
    DateTime? assignedStartTime,
    DateTime? assignedEndTime,
  }) {
    return AssignedPersonnel(
      personnelId: personnelId ?? this.personnelId,
      personnelName: personnelName ?? this.personnelName,
      role: role ?? this.role,
      assignedStartTime: assignedStartTime ?? this.assignedStartTime,
      assignedEndTime: assignedEndTime ?? this.assignedEndTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personnelId': personnelId,
      'personnelName': personnelName,
      'role': role,
      'assignedStartTime': assignedStartTime.toIso8601String(),
      'assignedEndTime': assignedEndTime?.toIso8601String(),
    };
  }
}

/// A comprehensive model representing a production execution/batch in a dairy factory
@immutable
class ProductionExecutionModel {

  const ProductionExecutionModel({
    required this.id,
    required this.batchNumber,
    required this.productionOrderId,
    required this.scheduledDate,
    required this.productId,
    required this.productName,
    required this.targetQuantity,
    required this.unitOfMeasure,
    required this.status,
    this.startTime,
    this.endTime,
    required this.productionLineId,
    required this.productionLineName,
    required this.assignedPersonnel,
    required this.materials,
    required this.expectedYield,
    this.actualYield,
    this.yieldEfficiency,
    this.qualityRating,
    this.qualityNotes,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    this.notes,
    this.metadata,
  });

  /// Creates an empty production execution record with default values
  factory ProductionExecutionModel.empty() {
    final now = DateTime.now();
    return ProductionExecutionModel(
      id: '',
      batchNumber: '',
      productionOrderId: '',
      scheduledDate: now,
      productId: '',
      productName: '',
      targetQuantity: 0.0,
      unitOfMeasure: 'kg',
      status: ProductionExecutionStatus.planned,
      productionLineId: '',
      productionLineName: '',
      assignedPersonnel: const [],
      materials: const [],
      expectedYield: 0.0,
      createdAt: now,
      createdBy: '',
      updatedAt: now,
      updatedBy: '',
    );
  }

  /// Creates a model from Firestore document
  factory ProductionExecutionModel.fromJson(Map<String, dynamic> json) {
    return ProductionExecutionModel(
      id: json['id'] as String,
      batchNumber: json['batchNumber'] as String,
      productionOrderId: json['productionOrderId'] as String,
      scheduledDate: (json['scheduledDate'] as Timestamp).toDate(),
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      targetQuantity: (json['targetQuantity'] as num).toDouble(),
      unitOfMeasure: json['unitOfMeasure'] as String,
      status: ProductionExecutionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ProductionExecutionStatus.planned,
      ),
      startTime: json['startTime'] != null
          ? (json['startTime'] as Timestamp).toDate()
          : null,
      endTime: json['endTime'] != null
          ? (json['endTime'] as Timestamp).toDate()
          : null,
      productionLineId: json['productionLineId'] as String,
      productionLineName: json['productionLineName'] as String,
      assignedPersonnel: (json['assignedPersonnel'] as List<dynamic>)
          .map((e) => AssignedPersonnel.fromJson(e as Map<String, dynamic>))
          .toList(),
      materials: (json['materials'] as List<dynamic>)
          .map((e) => MaterialUsage.fromJson(e as Map<String, dynamic>))
          .toList(),
      expectedYield: (json['expectedYield'] as num).toDouble(),
      actualYield: json['actualYield'] != null
          ? (json['actualYield'] as num).toDouble()
          : null,
      yieldEfficiency: json['yieldEfficiency'] != null
          ? (json['yieldEfficiency'] as num).toDouble()
          : null,
      qualityRating: json['qualityRating'] != null
          ? QualityRating.values.firstWhere(
              (e) => e.toString() == json['qualityRating'],
              orElse: () => QualityRating.acceptable,
            )
          : null,
      qualityNotes: json['qualityNotes'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      createdBy: json['createdBy'] as String,
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      updatedBy: json['updatedBy'] as String,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
  /// Unique identifier for this production execution
  final String id;

  /// Batch number for tracking purposes
  final String batchNumber;

  /// Reference to the associated production order
  final String productionOrderId;

  /// Scheduled production date
  final DateTime scheduledDate;

  /// ID of the product being produced
  final String productId;

  /// Name of the product being produced
  final String productName;

  /// Target quantity to produce
  final double targetQuantity;

  /// Unit of measure for the target quantity
  final String unitOfMeasure;

  /// Current status of the production execution
  final ProductionExecutionStatus status;

  /// Time when production started
  final DateTime? startTime;

  /// Time when production ended
  final DateTime? endTime;

  /// ID of the production line/equipment used
  final String productionLineId;

  /// Name of the production line/equipment used
  final String productionLineName;

  /// List of personnel assigned to this production execution
  final List<AssignedPersonnel> assignedPersonnel;

  /// List of raw materials used in production
  final List<MaterialUsage> materials;

  /// Expected production yield
  final double expectedYield;

  /// Actual production yield
  final double? actualYield;

  /// Yield efficiency percentage (actual/expected)
  final double? yieldEfficiency;

  /// Quality rating of the produced product
  final QualityRating? qualityRating;

  /// Quality notes or details
  final String? qualityNotes;

  /// Time when the record was created
  final DateTime createdAt;

  /// User ID who created the record
  final String createdBy;

  /// Time when the record was last updated
  final DateTime updatedAt;

  /// User ID who last updated the record
  final String updatedBy;

  /// Additional notes or comments
  final String? notes;

  /// Additional metadata as key-value pairs
  final Map<String, dynamic>? metadata;

  /// Creates a copy of this model with specified fields replaced
  ProductionExecutionModel copyWith({
    String? id,
    String? batchNumber,
    String? productionOrderId,
    DateTime? scheduledDate,
    String? productId,
    String? productName,
    double? targetQuantity,
    String? unitOfMeasure,
    ProductionExecutionStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    String? productionLineId,
    String? productionLineName,
    List<AssignedPersonnel>? assignedPersonnel,
    List<MaterialUsage>? materials,
    double? expectedYield,
    double? actualYield,
    double? yieldEfficiency,
    QualityRating? qualityRating,
    String? qualityNotes,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    String? updatedBy,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return ProductionExecutionModel(
      id: id ?? this.id,
      batchNumber: batchNumber ?? this.batchNumber,
      productionOrderId: productionOrderId ?? this.productionOrderId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      productionLineId: productionLineId ?? this.productionLineId,
      productionLineName: productionLineName ?? this.productionLineName,
      assignedPersonnel: assignedPersonnel ?? this.assignedPersonnel,
      materials: materials ?? this.materials,
      expectedYield: expectedYield ?? this.expectedYield,
      actualYield: actualYield ?? this.actualYield,
      yieldEfficiency: yieldEfficiency ?? this.yieldEfficiency,
      qualityRating: qualityRating ?? this.qualityRating,
      qualityNotes: qualityNotes ?? this.qualityNotes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Converts model to a JSON map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchNumber': batchNumber,
      'productionOrderId': productionOrderId,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'productId': productId,
      'productName': productName,
      'targetQuantity': targetQuantity,
      'unitOfMeasure': unitOfMeasure,
      'status': status.toString(),
      'startTime': startTime != null ? Timestamp.fromDate(startTime!) : null,
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'productionLineId': productionLineId,
      'productionLineName': productionLineName,
      'assignedPersonnel': assignedPersonnel.map((p) => p.toJson()).toList(),
      'materials': materials.map((m) => m.toJson()).toList(),
      'expectedYield': expectedYield,
      'actualYield': actualYield,
      'yieldEfficiency': yieldEfficiency,
      'qualityRating': qualityRating?.toString(),
      'qualityNotes': qualityNotes,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'updatedBy': updatedBy,
      'notes': notes,
      'metadata': metadata,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductionExecutionModel &&
        other.id == id &&
        other.batchNumber == batchNumber &&
        other.productionOrderId == productionOrderId &&
        other.scheduledDate.isAtSameMomentAs(scheduledDate) &&
        other.productId == productId &&
        other.productName == productName &&
        other.targetQuantity == targetQuantity &&
        other.unitOfMeasure == unitOfMeasure &&
        other.status == status &&
        (other.startTime == null && startTime == null ||
            other.startTime != null &&
                startTime != null &&
                other.startTime!.isAtSameMomentAs(startTime!)) &&
        (other.endTime == null && endTime == null ||
            other.endTime != null &&
                endTime != null &&
                other.endTime!.isAtSameMomentAs(endTime!)) &&
        other.productionLineId == productionLineId &&
        other.productionLineName == productionLineName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        batchNumber.hashCode ^
        productionOrderId.hashCode ^
        scheduledDate.hashCode ^
        productId.hashCode ^
        productName.hashCode ^
        targetQuantity.hashCode ^
        unitOfMeasure.hashCode ^
        status.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        productionLineId.hashCode ^
        productionLineName.hashCode;
  }

  @override
  String toString() {
    return 'ProductionExecutionModel(id: $id, batchNumber: $batchNumber, productName: $productName, status: $status)';
  }
}
