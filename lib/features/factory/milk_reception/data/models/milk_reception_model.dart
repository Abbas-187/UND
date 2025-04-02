import 'package:cloud_firestore/cloud_firestore.dart';
import 'milk_test_result_model.dart';

class MilkReceptionModel {
  factory MilkReceptionModel.fromMap(Map<String, dynamic> map, String id) {
    return MilkReceptionModel(
      id: id,
      receptionDate: (map['receptionDate'] as Timestamp).toDate(),
      supplierId: map['supplierId'] as String,
      supplierName: map['supplierName'] as String,
      quantityLiters: (map['quantityLiters'] as num).toDouble(),
      temperatureCelsius: (map['temperatureCelsius'] as num).toDouble(),
      milkType: MilkType.values
          .firstWhere((e) => e.toString() == 'MilkType.${map['milkType']}'),
      tankId: map['tankId'] as String?,
      receivedBy: map['receivedBy'] as String,
      status: ReceptionStatus.values.firstWhere(
          (e) => e.toString() == 'ReceptionStatus.${map['status']}'),
      testResults: (map['testResults'] as List<dynamic>)
          .map((testResultMap) => MilkTestResultModel.fromMap(testResultMap))
          .toList(),
      rejectionReason: map['rejectionReason'] as String?,
      fatPercentage: (map['fatPercentage'] as num).toDouble(),
      proteinPercentage: (map['proteinPercentage'] as num).toDouble(),
      notes: map['notes'] as String,
      organicCertified: map['organicCertified'] as bool,
      batchNumber: map['batchNumber'] as String?,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }
  MilkReceptionModel({
    required this.id,
    required this.receptionDate,
    required this.supplierId,
    required this.supplierName,
    required this.quantityLiters,
    required this.temperatureCelsius,
    required this.milkType,
    this.tankId,
    required this.receivedBy,
    required this.status,
    required this.testResults,
    this.rejectionReason,
    required this.fatPercentage,
    required this.proteinPercentage,
    required this.notes,
    required this.organicCertified,
    this.batchNumber,
    required this.metadata,
  });

  final String id;
  final DateTime receptionDate;
  final String supplierId;
  final String supplierName;
  final double quantityLiters;
  final double temperatureCelsius;
  final MilkType milkType;
  final String? tankId;
  final String receivedBy;
  final ReceptionStatus status;
  final List<MilkTestResultModel> testResults;
  final String? rejectionReason;
  final double fatPercentage;
  final double proteinPercentage;
  final String notes;
  final bool organicCertified;
  final String? batchNumber;
  final Map<String, dynamic> metadata;

  MilkReceptionModel copyWith({
    String? id,
    DateTime? receptionDate,
    String? supplierId,
    String? supplierName,
    double? quantityLiters,
    double? temperatureCelsius,
    MilkType? milkType,
    String? tankId,
    String? receivedBy,
    ReceptionStatus? status,
    List<MilkTestResultModel>? testResults,
    String? rejectionReason,
    double? fatPercentage,
    double? proteinPercentage,
    String? notes,
    bool? organicCertified,
    String? batchNumber,
    Map<String, dynamic>? metadata,
  }) {
    return MilkReceptionModel(
      id: id ?? this.id,
      receptionDate: receptionDate ?? this.receptionDate,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      quantityLiters: quantityLiters ?? this.quantityLiters,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      milkType: milkType ?? this.milkType,
      tankId: tankId ?? this.tankId,
      receivedBy: receivedBy ?? this.receivedBy,
      status: status ?? this.status,
      testResults: testResults ?? this.testResults,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      fatPercentage: fatPercentage ?? this.fatPercentage,
      proteinPercentage: proteinPercentage ?? this.proteinPercentage,
      notes: notes ?? this.notes,
      organicCertified: organicCertified ?? this.organicCertified,
      batchNumber: batchNumber ?? this.batchNumber,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'receptionDate': Timestamp.fromDate(receptionDate),
      'supplierId': supplierId,
      'supplierName': supplierName,
      'quantityLiters': quantityLiters,
      'temperatureCelsius': temperatureCelsius,
      'milkType': milkType.toString().split('.').last,
      'tankId': tankId,
      'receivedBy': receivedBy,
      'status': status.toString().split('.').last,
      'testResults':
          testResults.map((testResult) => testResult.toMap()).toList(),
      'rejectionReason': rejectionReason,
      'fatPercentage': fatPercentage,
      'proteinPercentage': proteinPercentage,
      'notes': notes,
      'organicCertified': organicCertified,
      'batchNumber': batchNumber,
      'metadata': metadata,
    };
  }
}

enum MilkType { cow, goat, sheep, buffalo }

enum ReceptionStatus { received, testing, accepted, rejected }
