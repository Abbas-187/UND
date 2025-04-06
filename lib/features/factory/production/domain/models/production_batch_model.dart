import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

/// Enum representing the status of a production batch
enum BatchStatus { notStarted, inProgress, completed, failed, onHold }

/// Immutable class representing a production batch in the manufacturing process
@immutable
class ProductionBatchModel {

  const ProductionBatchModel({
    required this.id,
    required this.batchNumber,
    required this.executionId,
    required this.productId,
    required this.productName,
    required this.status,
    this.startTime,
    this.endTime,
    required this.targetQuantity,
    this.actualQuantity,
    required this.unitOfMeasure,
    this.temperature,
    this.pH,
    this.processParameters,
    this.notes,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
  });

  /// Creates a model from a JSON map
  factory ProductionBatchModel.fromJson(Map<String, dynamic> json) {
    return ProductionBatchModel(
      id: json['id'] as String,
      batchNumber: json['batchNumber'] as String,
      executionId: json['executionId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      status: BatchStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => BatchStatus.notStarted,
      ),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      targetQuantity: (json['targetQuantity'] as num).toDouble(),
      actualQuantity: json['actualQuantity'] != null
          ? (json['actualQuantity'] as num).toDouble()
          : null,
      unitOfMeasure: json['unitOfMeasure'] as String,
      temperature: json['temperature'] != null
          ? (json['temperature'] as num).toDouble()
          : null,
      pH: json['pH'] != null ? (json['pH'] as num).toDouble() : null,
      processParameters: json['processParameters'] as Map<String, dynamic>?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String,
    );
  }

  /// Creates a model from a Firestore document
  factory ProductionBatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductionBatchModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }
  final String id;
  final String batchNumber;
  final String executionId;
  final String productId;
  final String productName;
  final BatchStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final double targetQuantity;
  final double? actualQuantity;
  final String unitOfMeasure;
  final double? temperature;
  final double? pH;
  final Map<String, dynamic>? processParameters;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;
  final DateTime updatedAt;
  final String updatedBy;

  /// Creates a copy with specified fields replaced
  ProductionBatchModel copyWith({
    String? id,
    String? batchNumber,
    String? executionId,
    String? productId,
    String? productName,
    BatchStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    double? targetQuantity,
    double? actualQuantity,
    String? unitOfMeasure,
    double? temperature,
    double? pH,
    Map<String, dynamic>? processParameters,
    String? notes,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return ProductionBatchModel(
      id: id ?? this.id,
      batchNumber: batchNumber ?? this.batchNumber,
      executionId: executionId ?? this.executionId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      actualQuantity: actualQuantity ?? this.actualQuantity,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      temperature: temperature ?? this.temperature,
      pH: pH ?? this.pH,
      processParameters: processParameters ?? this.processParameters,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// Converts the model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchNumber': batchNumber,
      'executionId': executionId,
      'productId': productId,
      'productName': productName,
      'status': status.toString().split('.').last,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'targetQuantity': targetQuantity,
      'actualQuantity': actualQuantity,
      'unitOfMeasure': unitOfMeasure,
      'temperature': temperature,
      'pH': pH,
      'processParameters': processParameters,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }
}
