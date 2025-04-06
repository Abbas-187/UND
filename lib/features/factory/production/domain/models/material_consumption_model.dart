import 'package:cloud_firestore/cloud_firestore.dart';

/// Model to track raw materials used in production processes
class MaterialConsumptionModel {

  /// Creates an empty consumption record with default values
  factory MaterialConsumptionModel.empty() {
    return MaterialConsumptionModel(
      id: '',
      productionOrderId: '',
      materialId: '',
      materialName: '',
      unitOfMeasure: '',
      plannedQuantity: 0.0,
      actualQuantity: 0.0,
      variance: 0.0,
      batchLotNumber: '',
      consumptionTime: DateTime.now(),
      consumedById: '',
    );
  }

  /// Creates a model from Firestore document
  factory MaterialConsumptionModel.fromJson(Map<String, dynamic> json) {
    return MaterialConsumptionModel(
      id: json['id'] as String,
      productionOrderId: json['productionOrderId'] as String,
      materialId: json['materialId'] as String,
      materialName: json['materialName'] as String,
      unitOfMeasure: json['unitOfMeasure'] as String,
      plannedQuantity: (json['plannedQuantity'] as num).toDouble(),
      actualQuantity: (json['actualQuantity'] as num).toDouble(),
      variance: (json['variance'] as num).toDouble(),
      batchLotNumber: json['batchLotNumber'] as String,
      consumptionTime: (json['consumptionTime'] as Timestamp).toDate(),
      consumedById: json['consumedById'] as String,
      consumedByName: json['consumedByName'] as String?,
      notes: json['notes'] as String?,
      qualityIssues: json['qualityIssues'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
  const MaterialConsumptionModel({
    required this.id,
    required this.productionOrderId,
    required this.materialId,
    required this.materialName,
    required this.unitOfMeasure,
    required this.plannedQuantity,
    required this.actualQuantity,
    required this.variance,
    required this.batchLotNumber,
    required this.consumptionTime,
    required this.consumedById,
    this.consumedByName,
    this.notes,
    this.qualityIssues = false,
    this.metadata = const {},
  });

  /// Unique identifier for this consumption record
  final String id;

  /// Reference to the production order
  final String productionOrderId;

  /// ID of the consumed material
  final String materialId;

  /// Name of the consumed material
  final String materialName;

  /// Unit of measure (kg, liters, etc.)
  final String unitOfMeasure;

  /// Planned quantity to be used
  final double plannedQuantity;

  /// Actual quantity used
  final double actualQuantity;

  /// Difference between planned and actual (can be positive or negative)
  final double variance;

  /// Batch or lot number for traceability
  final String batchLotNumber;

  /// When the material was consumed
  final DateTime consumptionTime;

  /// ID of the person who recorded the consumption
  final String consumedById;

  /// Name of the person who recorded the consumption
  final String? consumedByName;

  /// Additional notes about this consumption
  final String? notes;

  /// Flag indicating if there were quality issues with this material
  final bool qualityIssues;

  /// Additional metadata for extensibility
  final Map<String, dynamic> metadata;

  /// Converts model to a JSON map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productionOrderId': productionOrderId,
      'materialId': materialId,
      'materialName': materialName,
      'unitOfMeasure': unitOfMeasure,
      'plannedQuantity': plannedQuantity,
      'actualQuantity': actualQuantity,
      'variance': variance,
      'batchLotNumber': batchLotNumber,
      'consumptionTime': Timestamp.fromDate(consumptionTime),
      'consumedById': consumedById,
      'consumedByName': consumedByName,
      'notes': notes,
      'qualityIssues': qualityIssues,
      'metadata': metadata,
    };
  }

  /// Creates a copy of this model with specified fields replaced
  MaterialConsumptionModel copyWith({
    String? id,
    String? productionOrderId,
    String? materialId,
    String? materialName,
    String? unitOfMeasure,
    double? plannedQuantity,
    double? actualQuantity,
    double? variance,
    String? batchLotNumber,
    DateTime? consumptionTime,
    String? consumedById,
    String? consumedByName,
    String? notes,
    bool? qualityIssues,
    Map<String, dynamic>? metadata,
  }) {
    return MaterialConsumptionModel(
      id: id ?? this.id,
      productionOrderId: productionOrderId ?? this.productionOrderId,
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      plannedQuantity: plannedQuantity ?? this.plannedQuantity,
      actualQuantity: actualQuantity ?? this.actualQuantity,
      variance: variance ?? this.variance,
      batchLotNumber: batchLotNumber ?? this.batchLotNumber,
      consumptionTime: consumptionTime ?? this.consumptionTime,
      consumedById: consumedById ?? this.consumedById,
      consumedByName: consumedByName ?? this.consumedByName,
      notes: notes ?? this.notes,
      qualityIssues: qualityIssues ?? this.qualityIssues,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Calculate whether the consumption is within acceptable variance limits
  bool isWithinVarianceLimit(double maxAllowedVariancePercent) {
    final variancePercent = (variance.abs() / plannedQuantity) * 100;
    return variancePercent <= maxAllowedVariancePercent;
  }
}
