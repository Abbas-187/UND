import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/inventory_item.dart';

/// Status of quality parameters based on testing
enum QualityStatus { excellent, good, acceptable, warning, critical, rejected }

/// Compliance certification status
enum CertificationStatus { pending, approved, expired, revoked, notApplicable }

/// Immutable class for dairy inventory items
class InventoryItemModel {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double quantity;
  final double minimumQuantity;
  final double reorderPoint;
  final String location;
  final DateTime lastUpdated;
  final String? batchNumber;
  final DateTime? expiryDate;
  final Map<String, dynamic>? additionalAttributes;
  final List<String> searchTerms;
  final double? cost;
  final int lowStockThreshold;

  // Dairy-specific fields
  final List<TemperatureReading>? temperatureHistory;
  final Map<String, QualityParameterMeasurement>? qualityParameters;
  final BatchInformation? batchInformation;
  final Map<String, ComplianceCertification>? complianceCertifications;
  final Map<String, double>? crossContaminationRiskFactors;
  final double? currentTemperature;
  final DateTime? lastQualityCheck;
  final String? storageCondition; // e.g., "refrigerated", "frozen", "ambient"
  final Map<String, String>? allergenInfo;
  final QualityStatus? overallQualityStatus;

  InventoryItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.quantity,
    required this.minimumQuantity,
    required this.reorderPoint,
    required this.location,
    required this.lastUpdated,
    this.batchNumber,
    this.expiryDate,
    this.additionalAttributes,
    List<String>? searchTerms,
    this.cost,
    this.lowStockThreshold = 5,
    this.temperatureHistory,
    this.qualityParameters,
    this.batchInformation,
    this.complianceCertifications,
    this.crossContaminationRiskFactors,
    this.currentTemperature,
    this.lastQualityCheck,
    this.storageCondition,
    this.allergenInfo,
    this.overallQualityStatus,
  }) : searchTerms = searchTerms ?? _generateSearchTerms(name, category);

  // Convert from Firestore document
  factory InventoryItemModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    // Parse temperature history
    List<TemperatureReading>? tempHistory;
    if (data['temperatureHistory'] != null) {
      tempHistory = (data['temperatureHistory'] as List).map((reading) {
        return TemperatureReading.fromJson(reading as Map<String, dynamic>);
      }).toList();
    }

    // Parse quality parameters
    Map<String, QualityParameterMeasurement>? qualityParams;
    if (data['qualityParameters'] != null) {
      qualityParams = {};
      (data['qualityParameters'] as Map).forEach((key, value) {
        qualityParams![key.toString()] =
            QualityParameterMeasurement.fromJson(value as Map<String, dynamic>);
      });
    }

    // Parse batch information
    BatchInformation? batchInfo;
    if (data['batchInformation'] != null) {
      batchInfo = BatchInformation.fromJson(
          data['batchInformation'] as Map<String, dynamic>);
    }

    // Parse compliance certifications
    Map<String, ComplianceCertification>? certifications;
    if (data['complianceCertifications'] != null) {
      certifications = {};
      (data['complianceCertifications'] as Map).forEach((key, value) {
        certifications![key.toString()] =
            ComplianceCertification.fromJson(value as Map<String, dynamic>);
      });
    }

    // Parse quality status
    QualityStatus? qualityStatus;
    if (data['overallQualityStatus'] != null) {
      qualityStatus = QualityStatus.values.firstWhere(
        (status) =>
            status.toString().split('.').last == data['overallQualityStatus'],
        orElse: () => QualityStatus.acceptable,
      );
    }

    return InventoryItemModel(
      id: doc.id,
      name: data['name'] as String,
      category: data['category'] as String,
      unit: data['unit'] as String,
      quantity: (data['quantity'] as num).toDouble(),
      minimumQuantity: (data['minimumQuantity'] as num).toDouble(),
      reorderPoint: (data['reorderPoint'] as num).toDouble(),
      location: data['location'] as String,
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      batchNumber: data['batchNumber'] as String?,
      expiryDate: data['expiryDate'] != null
          ? (data['expiryDate'] as Timestamp).toDate()
          : null,
      additionalAttributes:
          data['additionalAttributes'] as Map<String, dynamic>?,
      searchTerms: List<String>.from(data['searchTerms'] as List? ?? []),
      cost: (data['cost'] as num?)?.toDouble(),
      lowStockThreshold: (data['lowStockThreshold'] as num?)?.toInt() ?? 5,
      temperatureHistory: tempHistory,
      qualityParameters: qualityParams,
      batchInformation: batchInfo,
      complianceCertifications: certifications,
      crossContaminationRiskFactors:
          data['crossContaminationRiskFactors'] != null
              ? Map<String, double>.from(
                  data['crossContaminationRiskFactors'] as Map)
              : null,
      currentTemperature: (data['currentTemperature'] as num?)?.toDouble(),
      lastQualityCheck: data['lastQualityCheck'] != null
          ? (data['lastQualityCheck'] as Timestamp).toDate()
          : null,
      storageCondition: data['storageCondition'] as String?,
      allergenInfo: data['allergenInfo'] != null
          ? Map<String, String>.from(data['allergenInfo'] as Map)
          : null,
      overallQualityStatus: qualityStatus,
    );
  }

  // Convert from domain entity
  factory InventoryItemModel.fromDomain(InventoryItem item) {
    return InventoryItemModel(
      id: item.id,
      name: item.name,
      category: item.category,
      unit: item.unit,
      quantity: item.quantity,
      minimumQuantity: item.minimumQuantity,
      reorderPoint: item.reorderPoint,
      location: item.location,
      lastUpdated: item.lastUpdated,
      batchNumber: item.batchNumber,
      expiryDate: item.expiryDate,
      additionalAttributes: item.additionalAttributes,
      cost: item.cost,
      lowStockThreshold: item.lowStockThreshold,
    );
  }

  // Convert to domain entity
  InventoryItem toDomain() {
    return InventoryItem(
      id: id,
      name: name,
      category: category,
      unit: unit,
      quantity: quantity,
      minimumQuantity: minimumQuantity,
      reorderPoint: reorderPoint,
      location: location,
      lastUpdated: lastUpdated,
      batchNumber: batchNumber,
      expiryDate: expiryDate,
      additionalAttributes: additionalAttributes,
      cost: cost,
      lowStockThreshold: lowStockThreshold,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toJson() {
    // Convert temperature history
    final tempHistoryJson =
        temperatureHistory?.map((reading) => reading.toJson()).toList();

    // Convert quality parameters
    Map<String, dynamic>? qualityParamsJson;
    if (qualityParameters != null) {
      qualityParamsJson = {};
      qualityParameters!.forEach((key, value) {
        qualityParamsJson![key] = value.toJson();
      });
    }

    // Convert batch information
    final batchInfoJson = batchInformation?.toJson();

    // Convert compliance certifications
    Map<String, dynamic>? certificationsJson;
    if (complianceCertifications != null) {
      certificationsJson = {};
      complianceCertifications!.forEach((key, value) {
        certificationsJson![key] = value.toJson();
      });
    }

    // Convert quality status
    final qualityStatusString =
        overallQualityStatus?.toString().split('.').last;

    return {
      'name': name,
      'category': category,
      'unit': unit,
      'quantity': quantity,
      'minimumQuantity': minimumQuantity,
      'reorderPoint': reorderPoint,
      'location': location,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'batchNumber': batchNumber,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'additionalAttributes': additionalAttributes,
      'searchTerms': searchTerms,
      'cost': cost,
      'lowStockThreshold': lowStockThreshold,
      'temperatureHistory': tempHistoryJson,
      'qualityParameters': qualityParamsJson,
      'batchInformation': batchInfoJson,
      'complianceCertifications': certificationsJson,
      'crossContaminationRiskFactors': crossContaminationRiskFactors,
      'currentTemperature': currentTemperature,
      'lastQualityCheck': lastQualityCheck != null
          ? Timestamp.fromDate(lastQualityCheck!)
          : null,
      'storageCondition': storageCondition,
      'allergenInfo': allergenInfo,
      'overallQualityStatus': qualityStatusString,
    };
  }

  InventoryItemModel copyWith({
    String? id,
    String? name,
    String? category,
    String? unit,
    double? quantity,
    double? minimumQuantity,
    double? reorderPoint,
    String? location,
    DateTime? lastUpdated,
    String? batchNumber,
    DateTime? expiryDate,
    Map<String, dynamic>? additionalAttributes,
    List<String>? searchTerms,
    double? cost,
    int? lowStockThreshold,
    List<TemperatureReading>? temperatureHistory,
    Map<String, QualityParameterMeasurement>? qualityParameters,
    BatchInformation? batchInformation,
    Map<String, ComplianceCertification>? complianceCertifications,
    Map<String, double>? crossContaminationRiskFactors,
    double? currentTemperature,
    DateTime? lastQualityCheck,
    String? storageCondition,
    Map<String, String>? allergenInfo,
    QualityStatus? overallQualityStatus,
  }) {
    return InventoryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      minimumQuantity: minimumQuantity ?? this.minimumQuantity,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      location: location ?? this.location,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      additionalAttributes: additionalAttributes ?? this.additionalAttributes,
      searchTerms: searchTerms ?? this.searchTerms,
      cost: cost ?? this.cost,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      temperatureHistory: temperatureHistory ?? this.temperatureHistory,
      qualityParameters: qualityParameters ?? this.qualityParameters,
      batchInformation: batchInformation ?? this.batchInformation,
      complianceCertifications:
          complianceCertifications ?? this.complianceCertifications,
      crossContaminationRiskFactors:
          crossContaminationRiskFactors ?? this.crossContaminationRiskFactors,
      currentTemperature: currentTemperature ?? this.currentTemperature,
      lastQualityCheck: lastQualityCheck ?? this.lastQualityCheck,
      storageCondition: storageCondition ?? this.storageCondition,
      allergenInfo: allergenInfo ?? this.allergenInfo,
      overallQualityStatus: overallQualityStatus ?? this.overallQualityStatus,
    );
  }

  // Generate search terms for better search functionality
  static List<String> _generateSearchTerms(String name, String category) {
    final terms = <String>{};

    // Add full name and category
    terms.add(name.toLowerCase());
    terms.add(category.toLowerCase());

    // Add name parts
    terms.addAll(name.toLowerCase().split(' '));

    // Add partial matches for name (minimum 3 characters)
    final words = name.toLowerCase().split(' ');
    for (final word in words) {
      for (int i = 0; i < word.length - 2; i++) {
        for (int j = i + 3; j <= word.length; j++) {
          terms.add(word.substring(i, j));
        }
      }
    }

    return terms.toList();
  }
}

/// Temperature reading for tracking inventory item storage conditions
class TemperatureReading {
  final DateTime timestamp;
  final double temperature;
  final String? recordedBy;
  final String? deviceId;
  final String? location;
  final bool isCompliant;
  final String? notes;

  const TemperatureReading({
    required this.timestamp,
    required this.temperature,
    this.recordedBy,
    this.deviceId,
    this.location,
    required this.isCompliant,
    this.notes,
  });

  factory TemperatureReading.fromJson(Map<String, dynamic> json) {
    return TemperatureReading(
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      temperature: (json['temperature'] as num).toDouble(),
      recordedBy: json['recordedBy'] as String?,
      deviceId: json['deviceId'] as String?,
      location: json['location'] as String?,
      isCompliant: json['isCompliant'] as bool,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'temperature': temperature,
      'recordedBy': recordedBy,
      'deviceId': deviceId,
      'location': location,
      'isCompliant': isCompliant,
      'notes': notes,
    };
  }

  TemperatureReading copyWith({
    DateTime? timestamp,
    double? temperature,
    String? recordedBy,
    String? deviceId,
    String? location,
    bool? isCompliant,
    String? notes,
  }) {
    return TemperatureReading(
      timestamp: timestamp ?? this.timestamp,
      temperature: temperature ?? this.temperature,
      recordedBy: recordedBy ?? this.recordedBy,
      deviceId: deviceId ?? this.deviceId,
      location: location ?? this.location,
      isCompliant: isCompliant ?? this.isCompliant,
      notes: notes ?? this.notes,
    );
  }
}

/// Quality parameter measurement for dairy products
class QualityParameterMeasurement {
  final String parameterName;
  final double value;
  final String unit;
  final double? minThreshold;
  final double? maxThreshold;
  final DateTime timestamp;
  final String? recordedBy;
  final QualityStatus status;
  final String? notes;

  const QualityParameterMeasurement({
    required this.parameterName,
    required this.value,
    required this.unit,
    this.minThreshold,
    this.maxThreshold,
    required this.timestamp,
    this.recordedBy,
    required this.status,
    this.notes,
  });

  factory QualityParameterMeasurement.fromJson(Map<String, dynamic> json) {
    final statusString = json['status'] as String;
    final status = QualityStatus.values.firstWhere(
      (s) => s.toString().split('.').last == statusString,
      orElse: () => QualityStatus.acceptable,
    );

    return QualityParameterMeasurement(
      parameterName: json['parameterName'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      minThreshold: (json['minThreshold'] as num?)?.toDouble(),
      maxThreshold: (json['maxThreshold'] as num?)?.toDouble(),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      recordedBy: json['recordedBy'] as String?,
      status: status,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parameterName': parameterName,
      'value': value,
      'unit': unit,
      'minThreshold': minThreshold,
      'maxThreshold': maxThreshold,
      'timestamp': Timestamp.fromDate(timestamp),
      'recordedBy': recordedBy,
      'status': status.toString().split('.').last,
      'notes': notes,
    };
  }

  QualityParameterMeasurement copyWith({
    String? parameterName,
    double? value,
    String? unit,
    double? minThreshold,
    double? maxThreshold,
    DateTime? timestamp,
    String? recordedBy,
    QualityStatus? status,
    String? notes,
  }) {
    return QualityParameterMeasurement(
      parameterName: parameterName ?? this.parameterName,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      minThreshold: minThreshold ?? this.minThreshold,
      maxThreshold: maxThreshold ?? this.maxThreshold,
      timestamp: timestamp ?? this.timestamp,
      recordedBy: recordedBy ?? this.recordedBy,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

/// Detailed batch information for dairy products
class BatchInformation {
  final String batchId;
  final DateTime productionDate;
  final String sourceId; // Farm ID or supplier ID
  final Map<String, dynamic>? sourceDetails;
  final Map<String, dynamic>? processingDetails;
  final List<String>? testResults;
  final bool isApproved;
  final String? approvedBy;
  final DateTime? approvalDate;
  final String? notes;

  const BatchInformation({
    required this.batchId,
    required this.productionDate,
    required this.sourceId,
    this.sourceDetails,
    this.processingDetails,
    this.testResults,
    required this.isApproved,
    this.approvedBy,
    this.approvalDate,
    this.notes,
  });

  factory BatchInformation.fromJson(Map<String, dynamic> json) {
    return BatchInformation(
      batchId: json['batchId'] as String,
      productionDate: (json['productionDate'] as Timestamp).toDate(),
      sourceId: json['sourceId'] as String,
      sourceDetails: json['sourceDetails'] as Map<String, dynamic>?,
      processingDetails: json['processingDetails'] as Map<String, dynamic>?,
      testResults: json['testResults'] != null
          ? List<String>.from(json['testResults'] as List)
          : null,
      isApproved: json['isApproved'] as bool,
      approvedBy: json['approvedBy'] as String?,
      approvalDate: json['approvalDate'] != null
          ? (json['approvalDate'] as Timestamp).toDate()
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batchId': batchId,
      'productionDate': Timestamp.fromDate(productionDate),
      'sourceId': sourceId,
      'sourceDetails': sourceDetails,
      'processingDetails': processingDetails,
      'testResults': testResults,
      'isApproved': isApproved,
      'approvedBy': approvedBy,
      'approvalDate':
          approvalDate != null ? Timestamp.fromDate(approvalDate!) : null,
      'notes': notes,
    };
  }

  BatchInformation copyWith({
    String? batchId,
    DateTime? productionDate,
    String? sourceId,
    Map<String, dynamic>? sourceDetails,
    Map<String, dynamic>? processingDetails,
    List<String>? testResults,
    bool? isApproved,
    String? approvedBy,
    DateTime? approvalDate,
    String? notes,
  }) {
    return BatchInformation(
      batchId: batchId ?? this.batchId,
      productionDate: productionDate ?? this.productionDate,
      sourceId: sourceId ?? this.sourceId,
      sourceDetails: sourceDetails ?? this.sourceDetails,
      processingDetails: processingDetails ?? this.processingDetails,
      testResults: testResults ?? this.testResults,
      isApproved: isApproved ?? this.isApproved,
      approvedBy: approvedBy ?? this.approvedBy,
      approvalDate: approvalDate ?? this.approvalDate,
      notes: notes ?? this.notes,
    );
  }
}

/// Compliance certification for dairy products
class ComplianceCertification {
  final String certificationName;
  final String issuingAuthority;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String? certificateNumber;
  final CertificationStatus status;
  final String? documents;
  final List<String>? conditions;
  final String? notes;

  const ComplianceCertification({
    required this.certificationName,
    required this.issuingAuthority,
    required this.issueDate,
    required this.expiryDate,
    this.certificateNumber,
    required this.status,
    this.documents,
    this.conditions,
    this.notes,
  });

  factory ComplianceCertification.fromJson(Map<String, dynamic> json) {
    final statusString = json['status'] as String;
    final status = CertificationStatus.values.firstWhere(
      (s) => s.toString().split('.').last == statusString,
      orElse: () => CertificationStatus.pending,
    );

    return ComplianceCertification(
      certificationName: json['certificationName'] as String,
      issuingAuthority: json['issuingAuthority'] as String,
      issueDate: (json['issueDate'] as Timestamp).toDate(),
      expiryDate: (json['expiryDate'] as Timestamp).toDate(),
      certificateNumber: json['certificateNumber'] as String?,
      status: status,
      documents: json['documents'] as String?,
      conditions: json['conditions'] != null
          ? List<String>.from(json['conditions'] as List)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'certificationName': certificationName,
      'issuingAuthority': issuingAuthority,
      'issueDate': Timestamp.fromDate(issueDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'certificateNumber': certificateNumber,
      'status': status.toString().split('.').last,
      'documents': documents,
      'conditions': conditions,
      'notes': notes,
    };
  }

  ComplianceCertification copyWith({
    String? certificationName,
    String? issuingAuthority,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? certificateNumber,
    CertificationStatus? status,
    String? documents,
    List<String>? conditions,
    String? notes,
  }) {
    return ComplianceCertification(
      certificationName: certificationName ?? this.certificationName,
      issuingAuthority: issuingAuthority ?? this.issuingAuthority,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      status: status ?? this.status,
      documents: documents ?? this.documents,
      conditions: conditions ?? this.conditions,
      notes: notes ?? this.notes,
    );
  }
}
