import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of quality tests for dairy products
enum TestType {
  microbiological,
  chemical,
  physical,
  sensory,
  composition,
  antibiotics,
  contaminants,
  other
}

/// Status of test results
enum TestResultStatus { pass, fail, warning, pending, invalid, not_performed }

/// Model for representing a single test parameter within a quality test
class TestParameter {
  final String parameterName;
  final double? numericValue;
  final String? stringValue; // For qualitative results
  final String unit;
  final double? minThreshold;
  final double? maxThreshold;
  final double? targetValue;
  final TestResultStatus status;
  final String? comments;

  const TestParameter({
    required this.parameterName,
    this.numericValue,
    this.stringValue,
    required this.unit,
    this.minThreshold,
    this.maxThreshold,
    this.targetValue,
    required this.status,
    this.comments,
  });

  factory TestParameter.fromJson(Map<String, dynamic> json) {
    // Convert status
    final statusString = json['status'] as String;
    final status = TestResultStatus.values.firstWhere(
      (s) => s.toString().split('.').last == statusString,
      orElse: () => TestResultStatus.pending,
    );

    return TestParameter(
      parameterName: json['parameterName'] as String,
      numericValue: (json['numericValue'] as num?)?.toDouble(),
      stringValue: json['stringValue'] as String?,
      unit: json['unit'] as String,
      minThreshold: (json['minThreshold'] as num?)?.toDouble(),
      maxThreshold: (json['maxThreshold'] as num?)?.toDouble(),
      targetValue: (json['targetValue'] as num?)?.toDouble(),
      status: status,
      comments: json['comments'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parameterName': parameterName,
      'numericValue': numericValue,
      'stringValue': stringValue,
      'unit': unit,
      'minThreshold': minThreshold,
      'maxThreshold': maxThreshold,
      'targetValue': targetValue,
      'status': status.toString().split('.').last,
      'comments': comments,
    };
  }

  TestParameter copyWith({
    String? parameterName,
    double? numericValue,
    String? stringValue,
    String? unit,
    double? minThreshold,
    double? maxThreshold,
    double? targetValue,
    TestResultStatus? status,
    String? comments,
  }) {
    return TestParameter(
      parameterName: parameterName ?? this.parameterName,
      numericValue: numericValue ?? this.numericValue,
      stringValue: stringValue ?? this.stringValue,
      unit: unit ?? this.unit,
      minThreshold: minThreshold ?? this.minThreshold,
      maxThreshold: maxThreshold ?? this.maxThreshold,
      targetValue: targetValue ?? this.targetValue,
      status: status ?? this.status,
      comments: comments ?? this.comments,
    );
  }
}

/// Information about laboratory equipment used for testing
class EquipmentInfo {
  final String equipmentId;
  final String equipmentName;
  final String? model;
  final String? serialNumber;
  final DateTime? lastCalibrationDate;
  final DateTime? nextCalibrationDate;
  final bool calibrationCurrent;
  final String? calibrationBy;
  final Map<String, dynamic>? specifications;

  const EquipmentInfo({
    required this.equipmentId,
    required this.equipmentName,
    this.model,
    this.serialNumber,
    this.lastCalibrationDate,
    this.nextCalibrationDate,
    required this.calibrationCurrent,
    this.calibrationBy,
    this.specifications,
  });

  factory EquipmentInfo.fromJson(Map<String, dynamic> json) {
    // Parse DateTime fields
    DateTime? lastCalibrationDate;
    if (json['lastCalibrationDate'] != null) {
      lastCalibrationDate = json['lastCalibrationDate'] is Timestamp
          ? (json['lastCalibrationDate'] as Timestamp).toDate()
          : DateTime.parse(json['lastCalibrationDate'] as String);
    }

    DateTime? nextCalibrationDate;
    if (json['nextCalibrationDate'] != null) {
      nextCalibrationDate = json['nextCalibrationDate'] is Timestamp
          ? (json['nextCalibrationDate'] as Timestamp).toDate()
          : DateTime.parse(json['nextCalibrationDate'] as String);
    }

    return EquipmentInfo(
      equipmentId: json['equipmentId'] as String,
      equipmentName: json['equipmentName'] as String,
      model: json['model'] as String?,
      serialNumber: json['serialNumber'] as String?,
      lastCalibrationDate: lastCalibrationDate,
      nextCalibrationDate: nextCalibrationDate,
      calibrationCurrent: json['calibrationCurrent'] as bool,
      calibrationBy: json['calibrationBy'] as String?,
      specifications: json['specifications'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipmentId': equipmentId,
      'equipmentName': equipmentName,
      'model': model,
      'serialNumber': serialNumber,
      'lastCalibrationDate': lastCalibrationDate?.toIso8601String(),
      'nextCalibrationDate': nextCalibrationDate?.toIso8601String(),
      'calibrationCurrent': calibrationCurrent,
      'calibrationBy': calibrationBy,
      'specifications': specifications,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();

    // Convert DateTime to Timestamp
    final lastCalibrationTimestamp = lastCalibrationDate != null
        ? Timestamp.fromDate(lastCalibrationDate!)
        : null;
    final nextCalibrationTimestamp = nextCalibrationDate != null
        ? Timestamp.fromDate(nextCalibrationDate!)
        : null;

    return {
      ...json,
      'lastCalibrationDate': lastCalibrationTimestamp,
      'nextCalibrationDate': nextCalibrationTimestamp,
    };
  }

  EquipmentInfo copyWith({
    String? equipmentId,
    String? equipmentName,
    String? model,
    String? serialNumber,
    DateTime? lastCalibrationDate,
    DateTime? nextCalibrationDate,
    bool? calibrationCurrent,
    String? calibrationBy,
    Map<String, dynamic>? specifications,
  }) {
    return EquipmentInfo(
      equipmentId: equipmentId ?? this.equipmentId,
      equipmentName: equipmentName ?? this.equipmentName,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      lastCalibrationDate: lastCalibrationDate ?? this.lastCalibrationDate,
      nextCalibrationDate: nextCalibrationDate ?? this.nextCalibrationDate,
      calibrationCurrent: calibrationCurrent ?? this.calibrationCurrent,
      calibrationBy: calibrationBy ?? this.calibrationBy,
      specifications: specifications ?? this.specifications,
    );
  }
}

/// Information about laboratory technician who performed testing
class TechnicianInfo {
  final String technicianId;
  final String technicianName;
  final String? qualification;
  final String? certification;
  final String? department;
  final String? position;
  final String? contactEmail;
  final String? contactPhone;

  const TechnicianInfo({
    required this.technicianId,
    required this.technicianName,
    this.qualification,
    this.certification,
    this.department,
    this.position,
    this.contactEmail,
    this.contactPhone,
  });

  factory TechnicianInfo.fromJson(Map<String, dynamic> json) {
    return TechnicianInfo(
      technicianId: json['technicianId'] as String,
      technicianName: json['technicianName'] as String,
      qualification: json['qualification'] as String?,
      certification: json['certification'] as String?,
      department: json['department'] as String?,
      position: json['position'] as String?,
      contactEmail: json['contactEmail'] as String?,
      contactPhone: json['contactPhone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'technicianId': technicianId,
      'technicianName': technicianName,
      'qualification': qualification,
      'certification': certification,
      'department': department,
      'position': position,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
    };
  }

  TechnicianInfo copyWith({
    String? technicianId,
    String? technicianName,
    String? qualification,
    String? certification,
    String? department,
    String? position,
    String? contactEmail,
    String? contactPhone,
  }) {
    return TechnicianInfo(
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      qualification: qualification ?? this.qualification,
      certification: certification ?? this.certification,
      department: department ?? this.department,
      position: position ?? this.position,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
    );
  }
}

/// Main model for quality test results
class QualityTestResultModel {
  final String? id;
  final String testCode;
  final TestType testType;
  final String testName;
  final String testMethod;
  final String? standardReference;
  final DateTime testDateTime;
  final Map<String, TestParameter> parameters;
  final TestResultStatus overallStatus;
  final EquipmentInfo? equipmentInfo;
  final TechnicianInfo? technicianInfo;
  final String? sampleId;
  final String? lotNumber;
  final String? batchId;
  final String? productionOrderId;
  final String? materialId;
  final String? inventoryItemId;
  final String? milkReceptionId;
  final Map<String, dynamic>? sampleInfo;
  final String? testLocation; // Laboratory, production floor, etc.
  final DateTime sampleCollectionTime;
  final String? sampleCollectedBy;
  final String? verifiedBy;
  final DateTime? verificationTime;
  final String? rejectionReason;
  final List<String>? attachments;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;

  const QualityTestResultModel({
    this.id,
    required this.testCode,
    required this.testType,
    required this.testName,
    required this.testMethod,
    this.standardReference,
    required this.testDateTime,
    required this.parameters,
    required this.overallStatus,
    this.equipmentInfo,
    this.technicianInfo,
    this.sampleId,
    this.lotNumber,
    this.batchId,
    this.productionOrderId,
    this.materialId,
    this.inventoryItemId,
    this.milkReceptionId,
    this.sampleInfo,
    this.testLocation,
    required this.sampleCollectionTime,
    this.sampleCollectedBy,
    this.verifiedBy,
    this.verificationTime,
    this.rejectionReason,
    this.attachments,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  factory QualityTestResultModel.fromJson(Map<String, dynamic> json) {
    // Parse TestType enum
    final testTypeString = json['testType'] as String;
    final testType = TestType.values.firstWhere(
      (t) => t.toString().split('.').last == testTypeString,
      orElse: () => TestType.other,
    );

    // Parse TestResultStatus enum
    final statusString = json['overallStatus'] as String;
    final overallStatus = TestResultStatus.values.firstWhere(
      (s) => s.toString().split('.').last == statusString,
      orElse: () => TestResultStatus.pending,
    );

    // Parse test parameters map
    final parametersMap = <String, TestParameter>{};
    final jsonParameters = json['parameters'] as Map<String, dynamic>;

    jsonParameters.forEach((key, value) {
      parametersMap[key] =
          TestParameter.fromJson(value as Map<String, dynamic>);
    });

    // Parse equipment info if present
    EquipmentInfo? equipmentInfo;
    if (json['equipmentInfo'] != null) {
      equipmentInfo =
          EquipmentInfo.fromJson(json['equipmentInfo'] as Map<String, dynamic>);
    }

    // Parse technician info if present
    TechnicianInfo? technicianInfo;
    if (json['technicianInfo'] != null) {
      technicianInfo = TechnicianInfo.fromJson(
          json['technicianInfo'] as Map<String, dynamic>);
    }

    // Parse DateTime fields
    final testDateTime = json['testDateTime'] is Timestamp
        ? (json['testDateTime'] as Timestamp).toDate()
        : DateTime.parse(json['testDateTime'] as String);

    final sampleCollectionTime = json['sampleCollectionTime'] is Timestamp
        ? (json['sampleCollectionTime'] as Timestamp).toDate()
        : DateTime.parse(json['sampleCollectionTime'] as String);

    DateTime? verificationTime;
    if (json['verificationTime'] != null) {
      verificationTime = json['verificationTime'] is Timestamp
          ? (json['verificationTime'] as Timestamp).toDate()
          : DateTime.parse(json['verificationTime'] as String);
    }

    final createdAt = json['createdAt'] is Timestamp
        ? (json['createdAt'] as Timestamp).toDate()
        : DateTime.parse(json['createdAt'] as String);

    DateTime? updatedAt;
    if (json['updatedAt'] != null) {
      updatedAt = json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt'] as String);
    }

    return QualityTestResultModel(
      id: json['id'] as String?,
      testCode: json['testCode'] as String,
      testType: testType,
      testName: json['testName'] as String,
      testMethod: json['testMethod'] as String,
      standardReference: json['standardReference'] as String?,
      testDateTime: testDateTime,
      parameters: parametersMap,
      overallStatus: overallStatus,
      equipmentInfo: equipmentInfo,
      technicianInfo: technicianInfo,
      sampleId: json['sampleId'] as String?,
      lotNumber: json['lotNumber'] as String?,
      batchId: json['batchId'] as String?,
      productionOrderId: json['productionOrderId'] as String?,
      materialId: json['materialId'] as String?,
      inventoryItemId: json['inventoryItemId'] as String?,
      milkReceptionId: json['milkReceptionId'] as String?,
      sampleInfo: json['sampleInfo'] as Map<String, dynamic>?,
      testLocation: json['testLocation'] as String?,
      sampleCollectionTime: sampleCollectionTime,
      sampleCollectedBy: json['sampleCollectedBy'] as String?,
      verifiedBy: json['verifiedBy'] as String?,
      verificationTime: verificationTime,
      rejectionReason: json['rejectionReason'] as String?,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'] as List)
          : null,
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String,
      createdAt: createdAt,
      updatedBy: json['updatedBy'] as String?,
      updatedAt: updatedAt,
    );
  }

  /// Factory method to convert from Firestore document
  factory QualityTestResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Add the document ID to the data
    final jsonWithId = {
      ...data,
      'id': doc.id,
    };

    return QualityTestResultModel.fromJson(jsonWithId);
  }

  Map<String, dynamic> toJson() {
    // Convert test parameters map
    final parametersJson = <String, dynamic>{};
    parameters.forEach((key, value) {
      parametersJson[key] = value.toJson();
    });

    // Convert equipment info if present
    final equipmentInfoJson = equipmentInfo?.toJson();

    // Convert technician info if present
    final technicianInfoJson = technicianInfo?.toJson();

    return {
      'id': id,
      'testCode': testCode,
      'testType': testType.toString().split('.').last,
      'testName': testName,
      'testMethod': testMethod,
      'standardReference': standardReference,
      'testDateTime': testDateTime.toIso8601String(),
      'parameters': parametersJson,
      'overallStatus': overallStatus.toString().split('.').last,
      'equipmentInfo': equipmentInfoJson,
      'technicianInfo': technicianInfoJson,
      'sampleId': sampleId,
      'lotNumber': lotNumber,
      'batchId': batchId,
      'productionOrderId': productionOrderId,
      'materialId': materialId,
      'inventoryItemId': inventoryItemId,
      'milkReceptionId': milkReceptionId,
      'sampleInfo': sampleInfo,
      'testLocation': testLocation,
      'sampleCollectionTime': sampleCollectionTime.toIso8601String(),
      'sampleCollectedBy': sampleCollectedBy,
      'verifiedBy': verifiedBy,
      'verificationTime': verificationTime?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'attachments': attachments,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedBy': updatedBy,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    final json = toJson();

    // Convert DateTime fields to Timestamp
    final testDateTimeTimestamp = Timestamp.fromDate(testDateTime);
    final sampleCollectionTimeTimestamp =
        Timestamp.fromDate(sampleCollectionTime);
    final verificationTimeTimestamp =
        verificationTime != null ? Timestamp.fromDate(verificationTime!) : null;
    final createdAtTimestamp = Timestamp.fromDate(createdAt);
    final updatedAtTimestamp =
        updatedAt != null ? Timestamp.fromDate(updatedAt!) : null;

    // Convert nested objects
    final equipmentInfoFirestore = equipmentInfo?.toFirestore();

    // Convert parameters
    final parametersFirestore = <String, dynamic>{};
    parameters.forEach((key, value) {
      parametersFirestore[key] =
          value.toJson(); // No Firestore conversion needed for TestParameter
    });

    return {
      ...json,
      'testDateTime': testDateTimeTimestamp,
      'sampleCollectionTime': sampleCollectionTimeTimestamp,
      'verificationTime': verificationTimeTimestamp,
      'createdAt': createdAtTimestamp,
      'updatedAt': updatedAtTimestamp,
      'equipmentInfo': equipmentInfoFirestore,
      'parameters': parametersFirestore,
    };
  }

  QualityTestResultModel copyWith({
    String? id,
    String? testCode,
    TestType? testType,
    String? testName,
    String? testMethod,
    String? standardReference,
    DateTime? testDateTime,
    Map<String, TestParameter>? parameters,
    TestResultStatus? overallStatus,
    EquipmentInfo? equipmentInfo,
    TechnicianInfo? technicianInfo,
    String? sampleId,
    String? lotNumber,
    String? batchId,
    String? productionOrderId,
    String? materialId,
    String? inventoryItemId,
    String? milkReceptionId,
    Map<String, dynamic>? sampleInfo,
    String? testLocation,
    DateTime? sampleCollectionTime,
    String? sampleCollectedBy,
    String? verifiedBy,
    DateTime? verificationTime,
    String? rejectionReason,
    List<String>? attachments,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return QualityTestResultModel(
      id: id ?? this.id,
      testCode: testCode ?? this.testCode,
      testType: testType ?? this.testType,
      testName: testName ?? this.testName,
      testMethod: testMethod ?? this.testMethod,
      standardReference: standardReference ?? this.standardReference,
      testDateTime: testDateTime ?? this.testDateTime,
      parameters: parameters ?? this.parameters,
      overallStatus: overallStatus ?? this.overallStatus,
      equipmentInfo: equipmentInfo ?? this.equipmentInfo,
      technicianInfo: technicianInfo ?? this.technicianInfo,
      sampleId: sampleId ?? this.sampleId,
      lotNumber: lotNumber ?? this.lotNumber,
      batchId: batchId ?? this.batchId,
      productionOrderId: productionOrderId ?? this.productionOrderId,
      materialId: materialId ?? this.materialId,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      milkReceptionId: milkReceptionId ?? this.milkReceptionId,
      sampleInfo: sampleInfo ?? this.sampleInfo,
      testLocation: testLocation ?? this.testLocation,
      sampleCollectionTime: sampleCollectionTime ?? this.sampleCollectionTime,
      sampleCollectedBy: sampleCollectedBy ?? this.sampleCollectedBy,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verificationTime: verificationTime ?? this.verificationTime,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      attachments: attachments ?? this.attachments,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QualityTestResultModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          testCode == other.testCode;

  @override
  int get hashCode => id.hashCode ^ testCode.hashCode;
}
