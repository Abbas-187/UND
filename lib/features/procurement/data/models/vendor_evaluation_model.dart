import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum representing different evaluation status values
enum EvaluationStatus { pending, inProgress, completed, rejected }

/// Converts [EvaluationStatus] enum to string
String evaluationStatusToString(EvaluationStatus status) {
  return status.toString().split('.').last;
}

/// Converts string to [EvaluationStatus] enum
EvaluationStatus evaluationStatusFromString(String status) {
  return EvaluationStatus.values.firstWhere(
    (e) => e.toString().split('.').last == status,
    orElse: () => throw ArgumentError('Invalid evaluation status: $status'),
  );
}

/// Data model for Vendor Evaluation
@immutable
class VendorEvaluationModel {
  const VendorEvaluationModel({
    this.id,
    required this.vendorId,
    required this.vendorName,
    required this.evaluationDate,
    required this.evaluator,
    required this.qualityScore,
    required this.deliveryScore,
    required this.priceScore,
    required this.serviceScore,
    required this.overallScore,
    required this.status,
    this.comments,
    this.strengths,
    this.weaknesses,
    this.recommendations,
  });

  /// Convert from map to model
  factory VendorEvaluationModel.fromMap(Map<String, dynamic> map) {
    return VendorEvaluationModel(
      id: map['id'],
      vendorId: map['vendorId'] ?? '',
      vendorName: map['vendorName'] ?? '',
      evaluationDate:
          (map['evaluationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      evaluator: map['evaluator'] ?? '',
      qualityScore: (map['qualityScore'] ?? 0).toDouble(),
      deliveryScore: (map['deliveryScore'] ?? 0).toDouble(),
      priceScore: (map['priceScore'] ?? 0).toDouble(),
      serviceScore: (map['serviceScore'] ?? 0).toDouble(),
      overallScore: (map['overallScore'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      comments: map['comments'],
      strengths: map['strengths'],
      weaknesses: map['weaknesses'],
      recommendations: map['recommendations'],
    );
  }

  final String? id;
  final String vendorId;
  final String vendorName;
  final DateTime evaluationDate;
  final String evaluator;
  final double qualityScore;
  final double deliveryScore;
  final double priceScore;
  final double serviceScore;
  final double overallScore;
  final String status;
  final String? comments;
  final String? strengths;
  final String? weaknesses;
  final String? recommendations;

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'evaluationDate': Timestamp.fromDate(evaluationDate),
      'evaluator': evaluator,
      'qualityScore': qualityScore,
      'deliveryScore': deliveryScore,
      'priceScore': priceScore,
      'serviceScore': serviceScore,
      'overallScore': overallScore,
      'status': status,
      'comments': comments,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'recommendations': recommendations,
    };
  }
}
