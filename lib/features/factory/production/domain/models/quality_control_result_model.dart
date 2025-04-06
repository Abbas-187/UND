import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

/// Enum representing the result of a quality control check
enum QualityCheckResult { pass, fail, conditional }

/// Immutable class representing a quality control result in production
@immutable
class QualityControlResultModel {

  const QualityControlResultModel({
    required this.id,
    required this.batchId,
    required this.executionId,
    required this.productId,
    required this.checkpointName,
    required this.parameters,
    required this.result,
    required this.measurements,
    this.deviationDetails,
    this.correctiveAction,
    required this.performedBy,
    required this.performedAt,
    this.reviewedBy,
    this.reviewedAt,
    required this.isCritical,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
  });

  /// Creates a model from a JSON map
  factory QualityControlResultModel.fromJson(Map<String, dynamic> json) {
    return QualityControlResultModel(
      id: json['id'] as String,
      batchId: json['batchId'] as String,
      executionId: json['executionId'] as String,
      productId: json['productId'] as String,
      checkpointName: json['checkpointName'] as String,
      parameters: json['parameters'] as String,
      result: QualityCheckResult.values.firstWhere(
        (e) => e.toString().split('.').last == json['result'],
        orElse: () => QualityCheckResult.fail,
      ),
      measurements: json['measurements'] as Map<String, dynamic>,
      deviationDetails: json['deviationDetails'] as String?,
      correctiveAction: json['correctiveAction'] as String?,
      performedBy: json['performedBy'] as String,
      performedAt: DateTime.parse(json['performedAt'] as String),
      reviewedBy: json['reviewedBy'] as String?,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      isCritical: json['isCritical'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String,
    );
  }

  /// Creates a model from a Firestore document
  factory QualityControlResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QualityControlResultModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }
  final String id;
  final String batchId;
  final String executionId;
  final String productId;
  final String checkpointName;
  final String parameters;
  final QualityCheckResult result;
  final Map<String, dynamic> measurements;
  final String? deviationDetails;
  final String? correctiveAction;
  final String performedBy;
  final DateTime performedAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final bool isCritical;
  final DateTime createdAt;
  final String createdBy;
  final DateTime updatedAt;
  final String updatedBy;

  /// Creates a copy with specified fields replaced
  QualityControlResultModel copyWith({
    String? id,
    String? batchId,
    String? executionId,
    String? productId,
    String? checkpointName,
    String? parameters,
    QualityCheckResult? result,
    Map<String, dynamic>? measurements,
    String? deviationDetails,
    String? correctiveAction,
    String? performedBy,
    DateTime? performedAt,
    String? reviewedBy,
    DateTime? reviewedAt,
    bool? isCritical,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return QualityControlResultModel(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      executionId: executionId ?? this.executionId,
      productId: productId ?? this.productId,
      checkpointName: checkpointName ?? this.checkpointName,
      parameters: parameters ?? this.parameters,
      result: result ?? this.result,
      measurements: measurements ?? this.measurements,
      deviationDetails: deviationDetails ?? this.deviationDetails,
      correctiveAction: correctiveAction ?? this.correctiveAction,
      performedBy: performedBy ?? this.performedBy,
      performedAt: performedAt ?? this.performedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      isCritical: isCritical ?? this.isCritical,
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
      'batchId': batchId,
      'executionId': executionId,
      'productId': productId,
      'checkpointName': checkpointName,
      'parameters': parameters,
      'result': result.toString().split('.').last,
      'measurements': measurements,
      'deviationDetails': deviationDetails,
      'correctiveAction': correctiveAction,
      'performedBy': performedBy,
      'performedAt': performedAt.toIso8601String(),
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'isCritical': isCritical,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }
}
