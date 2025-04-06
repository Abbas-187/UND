import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum representing different quality check types
enum QualityCheckType {
  inProcess, // During production
  finalProduct, // Final product check
  preProduction, // Raw material/setup check
  equipment // Equipment validation
}

/// Enum representing the status of a quality check
enum QualityCheckStatus { passed, failed, pending, partialPass, waived }

/// Model to define and track quality parameters and results in production
class ProductionQualityCheckModel {

  /// Creates an empty quality check record with default values
  factory ProductionQualityCheckModel.empty() {
    return ProductionQualityCheckModel(
      id: '',
      productionOrderId: '',
      productId: '',
      productName: '',
      checkType: QualityCheckType.inProcess,
      parameterName: '',
      parameterDescription: '',
      unitOfMeasure: '',
      minThreshold: 0.0,
      maxThreshold: 0.0,
      targetValue: 0.0,
      recordedValue: 0.0,
      status: QualityCheckStatus.pending,
      checkedById: '',
      checkTime: DateTime.now(),
    );
  }

  /// Creates a model from Firestore document
  factory ProductionQualityCheckModel.fromJson(Map<String, dynamic> json) {
    return ProductionQualityCheckModel(
      id: json['id'] as String,
      productionOrderId: json['productionOrderId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      checkType: QualityCheckType.values.firstWhere(
        (e) => e.toString() == json['checkType'],
        orElse: () => QualityCheckType.inProcess,
      ),
      parameterName: json['parameterName'] as String,
      parameterDescription: json['parameterDescription'] as String,
      unitOfMeasure: json['unitOfMeasure'] as String,
      minThreshold: (json['minThreshold'] as num).toDouble(),
      maxThreshold: (json['maxThreshold'] as num).toDouble(),
      targetValue: (json['targetValue'] as num).toDouble(),
      recordedValue: (json['recordedValue'] as num).toDouble(),
      status: QualityCheckStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => QualityCheckStatus.pending,
      ),
      checkedById: json['checkedById'] as String,
      checkedByName: json['checkedByName'] as String?,
      checkTime: (json['checkTime'] as Timestamp).toDate(),
      batchNumber: json['batchNumber'] as String?,
      checkPointLocation: json['checkPointLocation'] as String?,
      notes: json['notes'] as String?,
      attachmentUrls: List<String>.from(json['attachmentUrls'] ?? []),
      requiredAction: json['requiredAction'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
  const ProductionQualityCheckModel({
    required this.id,
    required this.productionOrderId,
    required this.productId,
    required this.productName,
    required this.checkType,
    required this.parameterName,
    required this.parameterDescription,
    required this.unitOfMeasure,
    required this.minThreshold,
    required this.maxThreshold,
    required this.targetValue,
    required this.recordedValue,
    required this.status,
    required this.checkedById,
    required this.checkTime,
    this.checkedByName,
    this.batchNumber,
    this.checkPointLocation,
    this.notes,
    this.attachmentUrls = const [],
    this.requiredAction,
    this.metadata = const {},
  });

  /// Unique identifier for this quality check
  final String id;

  /// Reference to the production order
  final String productionOrderId;

  /// ID of the product being checked
  final String productId;

  /// Name of the product being checked
  final String productName;

  /// Type of quality check
  final QualityCheckType checkType;

  /// Name of the parameter being checked
  final String parameterName;

  /// Description of the quality parameter
  final String parameterDescription;

  /// Unit of measurement for the parameter
  final String unitOfMeasure;

  /// Minimum acceptable value
  final double minThreshold;

  /// Maximum acceptable value
  final double maxThreshold;

  /// Target/ideal value
  final double targetValue;

  /// Actual recorded value
  final double recordedValue;

  /// Status of this quality check
  final QualityCheckStatus status;

  /// ID of the person who performed the check
  final String checkedById;

  /// Name of the person who performed the check
  final String? checkedByName;

  /// When the check was performed
  final DateTime checkTime;

  /// Batch number being tested
  final String? batchNumber;

  /// Location in the production process where check was performed
  final String? checkPointLocation;

  /// Additional notes about this check
  final String? notes;

  /// URLs to photos or documents related to this check
  final List<String> attachmentUrls;

  /// Action required if check doesn't meet criteria
  final String? requiredAction;

  /// Additional metadata for extensibility
  final Map<String, dynamic> metadata;

  /// Converts model to a JSON map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productionOrderId': productionOrderId,
      'productId': productId,
      'productName': productName,
      'checkType': checkType.toString(),
      'parameterName': parameterName,
      'parameterDescription': parameterDescription,
      'unitOfMeasure': unitOfMeasure,
      'minThreshold': minThreshold,
      'maxThreshold': maxThreshold,
      'targetValue': targetValue,
      'recordedValue': recordedValue,
      'status': status.toString(),
      'checkedById': checkedById,
      'checkedByName': checkedByName,
      'checkTime': Timestamp.fromDate(checkTime),
      'batchNumber': batchNumber,
      'checkPointLocation': checkPointLocation,
      'notes': notes,
      'attachmentUrls': attachmentUrls,
      'requiredAction': requiredAction,
      'metadata': metadata,
    };
  }

  /// Creates a copy of this model with specified fields replaced
  ProductionQualityCheckModel copyWith({
    String? id,
    String? productionOrderId,
    String? productId,
    String? productName,
    QualityCheckType? checkType,
    String? parameterName,
    String? parameterDescription,
    String? unitOfMeasure,
    double? minThreshold,
    double? maxThreshold,
    double? targetValue,
    double? recordedValue,
    QualityCheckStatus? status,
    String? checkedById,
    String? checkedByName,
    DateTime? checkTime,
    String? batchNumber,
    String? checkPointLocation,
    String? notes,
    List<String>? attachmentUrls,
    String? requiredAction,
    Map<String, dynamic>? metadata,
  }) {
    return ProductionQualityCheckModel(
      id: id ?? this.id,
      productionOrderId: productionOrderId ?? this.productionOrderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      checkType: checkType ?? this.checkType,
      parameterName: parameterName ?? this.parameterName,
      parameterDescription: parameterDescription ?? this.parameterDescription,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      minThreshold: minThreshold ?? this.minThreshold,
      maxThreshold: maxThreshold ?? this.maxThreshold,
      targetValue: targetValue ?? this.targetValue,
      recordedValue: recordedValue ?? this.recordedValue,
      status: status ?? this.status,
      checkedById: checkedById ?? this.checkedById,
      checkedByName: checkedByName ?? this.checkedByName,
      checkTime: checkTime ?? this.checkTime,
      batchNumber: batchNumber ?? this.batchNumber,
      checkPointLocation: checkPointLocation ?? this.checkPointLocation,
      notes: notes ?? this.notes,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      requiredAction: requiredAction ?? this.requiredAction,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Checks if the recorded value is within the specified thresholds
  bool isValueWithinThresholds() {
    return recordedValue >= minThreshold && recordedValue <= maxThreshold;
  }

  /// Calculates deviation from target value as a percentage
  double calculateDeviationPercentage() {
    if (targetValue == 0) return 0;
    return ((recordedValue - targetValue) / targetValue) * 100;
  }
}
