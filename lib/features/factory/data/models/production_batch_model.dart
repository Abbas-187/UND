import 'package:cloud_firestore/cloud_firestore.dart';

/// Pasteurization method used in dairy processing
enum PasteurizationMethod {
  htst, // High Temperature Short Time
  ltlt, // Low Temperature Long Time
  uht, // Ultra High Temperature
  vat, // Vat Pasteurization
  other
}

/// Standardization method used for milk components
enum StandardizationMethod {
  fat_adjustment,
  protein_fortification,
  cream_separation,
  homogenization,
  none,
  other
}

/// Culture type added during dairy processing
enum CultureType {
  starter,
  probiotic,
  yogurt,
  cheese,
  kefir,
  buttermilk,
  custom,
  none
}

/// Production status tracking
enum ProductionStatus {
  scheduled,
  in_progress,
  pasteurization,
  cooling,
  culture_addition,
  fermentation,
  packaging,
  quality_check,
  completed,
  on_hold,
  rejected
}

/// Source of raw milk used in production
class RawMilkSource {
  final String farmId;
  final String? farmName;
  final DateTime collectionDate;
  final String? tankerId;
  final double quantity;
  final String quantityUnit;
  final DateTime receivedDate;
  final Map<String, double>? initialQualityParameters;
  final String? storageLocationId;

  const RawMilkSource({
    required this.farmId,
    this.farmName,
    required this.collectionDate,
    this.tankerId,
    required this.quantity,
    required this.quantityUnit,
    required this.receivedDate,
    this.initialQualityParameters,
    this.storageLocationId,
  });

  factory RawMilkSource.fromJson(Map<String, dynamic> json) {
    return RawMilkSource(
      farmId: json['farmId'] as String,
      farmName: json['farmName'] as String?,
      collectionDate: json['collectionDate'] is Timestamp
          ? (json['collectionDate'] as Timestamp).toDate()
          : DateTime.parse(json['collectionDate'] as String),
      tankerId: json['tankerId'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      quantityUnit: json['quantityUnit'] as String,
      receivedDate: json['receivedDate'] is Timestamp
          ? (json['receivedDate'] as Timestamp).toDate()
          : DateTime.parse(json['receivedDate'] as String),
      initialQualityParameters: json['initialQualityParameters'] != null
          ? Map<String, double>.from(json['initialQualityParameters'] as Map)
          : null,
      storageLocationId: json['storageLocationId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'farmId': farmId,
      'farmName': farmName,
      'collectionDate': collectionDate.toIso8601String(),
      'tankerId': tankerId,
      'quantity': quantity,
      'quantityUnit': quantityUnit,
      'receivedDate': receivedDate.toIso8601String(),
      'initialQualityParameters': initialQualityParameters,
      'storageLocationId': storageLocationId,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'collectionDate': Timestamp.fromDate(collectionDate),
      'receivedDate': Timestamp.fromDate(receivedDate),
    };
  }

  RawMilkSource copyWith({
    String? farmId,
    String? farmName,
    DateTime? collectionDate,
    String? tankerId,
    double? quantity,
    String? quantityUnit,
    DateTime? receivedDate,
    Map<String, double>? initialQualityParameters,
    String? storageLocationId,
  }) {
    return RawMilkSource(
      farmId: farmId ?? this.farmId,
      farmName: farmName ?? this.farmName,
      collectionDate: collectionDate ?? this.collectionDate,
      tankerId: tankerId ?? this.tankerId,
      quantity: quantity ?? this.quantity,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      receivedDate: receivedDate ?? this.receivedDate,
      initialQualityParameters:
          initialQualityParameters ?? this.initialQualityParameters,
      storageLocationId: storageLocationId ?? this.storageLocationId,
    );
  }
}

/// Pasteurization details for dairy processing
class PasteurizationDetails {
  final PasteurizationMethod method;
  final DateTime startTime;
  final DateTime endTime;
  final double temperature;
  final double holdingTime; // in seconds
  final String? equipmentId;
  final String? operatorId;
  final Map<String, dynamic>? processParameters;
  final bool isVerified;
  final String? verificationNote;

  const PasteurizationDetails({
    required this.method,
    required this.startTime,
    required this.endTime,
    required this.temperature,
    required this.holdingTime,
    this.equipmentId,
    this.operatorId,
    this.processParameters,
    required this.isVerified,
    this.verificationNote,
  });

  factory PasteurizationDetails.fromJson(Map<String, dynamic> json) {
    final methodValue = json['method'] as String;
    final method = PasteurizationMethod.values.firstWhere(
      (m) => m.toString().split('.').last == methodValue,
      orElse: () => PasteurizationMethod.other,
    );

    return PasteurizationDetails(
      method: method,
      startTime: json['startTime'] is Timestamp
          ? (json['startTime'] as Timestamp).toDate()
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] is Timestamp
          ? (json['endTime'] as Timestamp).toDate()
          : DateTime.parse(json['endTime'] as String),
      temperature: (json['temperature'] as num).toDouble(),
      holdingTime: (json['holdingTime'] as num).toDouble(),
      equipmentId: json['equipmentId'] as String?,
      operatorId: json['operatorId'] as String?,
      processParameters: json['processParameters'] as Map<String, dynamic>?,
      isVerified: json['isVerified'] as bool,
      verificationNote: json['verificationNote'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method.toString().split('.').last,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'temperature': temperature,
      'holdingTime': holdingTime,
      'equipmentId': equipmentId,
      'operatorId': operatorId,
      'processParameters': processParameters,
      'isVerified': isVerified,
      'verificationNote': verificationNote,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
    };
  }

  PasteurizationDetails copyWith({
    PasteurizationMethod? method,
    DateTime? startTime,
    DateTime? endTime,
    double? temperature,
    double? holdingTime,
    String? equipmentId,
    String? operatorId,
    Map<String, dynamic>? processParameters,
    bool? isVerified,
    String? verificationNote,
  }) {
    return PasteurizationDetails(
      method: method ?? this.method,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      temperature: temperature ?? this.temperature,
      holdingTime: holdingTime ?? this.holdingTime,
      equipmentId: equipmentId ?? this.equipmentId,
      operatorId: operatorId ?? this.operatorId,
      processParameters: processParameters ?? this.processParameters,
      isVerified: isVerified ?? this.isVerified,
      verificationNote: verificationNote ?? this.verificationNote,
    );
  }
}

/// Standardization parameters for milk components
class StandardizationParameters {
  final StandardizationMethod method;
  final double targetFatPercentage;
  final double? actualFatPercentage;
  final double? targetProteinPercentage;
  final double? actualProteinPercentage;
  final double? targetTotalSolids;
  final double? actualTotalSolids;
  final bool homogenized;
  final double? homogenizationPressure;
  final Map<String, dynamic>? additionalParameters;
  final String? equipmentId;
  final String? operatorId;

  const StandardizationParameters({
    required this.method,
    required this.targetFatPercentage,
    this.actualFatPercentage,
    this.targetProteinPercentage,
    this.actualProteinPercentage,
    this.targetTotalSolids,
    this.actualTotalSolids,
    required this.homogenized,
    this.homogenizationPressure,
    this.additionalParameters,
    this.equipmentId,
    this.operatorId,
  });

  factory StandardizationParameters.fromJson(Map<String, dynamic> json) {
    final methodValue = json['method'] as String;
    final method = StandardizationMethod.values.firstWhere(
      (m) => m.toString().split('.').last == methodValue,
      orElse: () => StandardizationMethod.other,
    );

    return StandardizationParameters(
      method: method,
      targetFatPercentage: (json['targetFatPercentage'] as num).toDouble(),
      actualFatPercentage: (json['actualFatPercentage'] as num?)?.toDouble(),
      targetProteinPercentage:
          (json['targetProteinPercentage'] as num?)?.toDouble(),
      actualProteinPercentage:
          (json['actualProteinPercentage'] as num?)?.toDouble(),
      targetTotalSolids: (json['targetTotalSolids'] as num?)?.toDouble(),
      actualTotalSolids: (json['actualTotalSolids'] as num?)?.toDouble(),
      homogenized: json['homogenized'] as bool,
      homogenizationPressure:
          (json['homogenizationPressure'] as num?)?.toDouble(),
      additionalParameters:
          json['additionalParameters'] as Map<String, dynamic>?,
      equipmentId: json['equipmentId'] as String?,
      operatorId: json['operatorId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method.toString().split('.').last,
      'targetFatPercentage': targetFatPercentage,
      'actualFatPercentage': actualFatPercentage,
      'targetProteinPercentage': targetProteinPercentage,
      'actualProteinPercentage': actualProteinPercentage,
      'targetTotalSolids': targetTotalSolids,
      'actualTotalSolids': actualTotalSolids,
      'homogenized': homogenized,
      'homogenizationPressure': homogenizationPressure,
      'additionalParameters': additionalParameters,
      'equipmentId': equipmentId,
      'operatorId': operatorId,
    };
  }

  StandardizationParameters copyWith({
    StandardizationMethod? method,
    double? targetFatPercentage,
    double? actualFatPercentage,
    double? targetProteinPercentage,
    double? actualProteinPercentage,
    double? targetTotalSolids,
    double? actualTotalSolids,
    bool? homogenized,
    double? homogenizationPressure,
    Map<String, dynamic>? additionalParameters,
    String? equipmentId,
    String? operatorId,
  }) {
    return StandardizationParameters(
      method: method ?? this.method,
      targetFatPercentage: targetFatPercentage ?? this.targetFatPercentage,
      actualFatPercentage: actualFatPercentage ?? this.actualFatPercentage,
      targetProteinPercentage:
          targetProteinPercentage ?? this.targetProteinPercentage,
      actualProteinPercentage:
          actualProteinPercentage ?? this.actualProteinPercentage,
      targetTotalSolids: targetTotalSolids ?? this.targetTotalSolids,
      actualTotalSolids: actualTotalSolids ?? this.actualTotalSolids,
      homogenized: homogenized ?? this.homogenized,
      homogenizationPressure:
          homogenizationPressure ?? this.homogenizationPressure,
      additionalParameters: additionalParameters ?? this.additionalParameters,
      equipmentId: equipmentId ?? this.equipmentId,
      operatorId: operatorId ?? this.operatorId,
    );
  }
}

/// Culture addition details for fermented dairy products
class CultureAdditionDetails {
  final CultureType cultureType;
  final String cultureName;
  final String? supplierCode;
  final String? lotNumber;
  final double amount;
  final String amountUnit;
  final DateTime additionTime;
  final double milkTemperature;
  final double? targetpH;
  final double? initialMilkpH;
  final String? operatorId;
  final Map<String, dynamic>? additionalParameters;

  const CultureAdditionDetails({
    required this.cultureType,
    required this.cultureName,
    this.supplierCode,
    this.lotNumber,
    required this.amount,
    required this.amountUnit,
    required this.additionTime,
    required this.milkTemperature,
    this.targetpH,
    this.initialMilkpH,
    this.operatorId,
    this.additionalParameters,
  });

  factory CultureAdditionDetails.fromJson(Map<String, dynamic> json) {
    final cultureTypeValue = json['cultureType'] as String;
    final cultureType = CultureType.values.firstWhere(
      (t) => t.toString().split('.').last == cultureTypeValue,
      orElse: () => CultureType.custom,
    );

    return CultureAdditionDetails(
      cultureType: cultureType,
      cultureName: json['cultureName'] as String,
      supplierCode: json['supplierCode'] as String?,
      lotNumber: json['lotNumber'] as String?,
      amount: (json['amount'] as num).toDouble(),
      amountUnit: json['amountUnit'] as String,
      additionTime: json['additionTime'] is Timestamp
          ? (json['additionTime'] as Timestamp).toDate()
          : DateTime.parse(json['additionTime'] as String),
      milkTemperature: (json['milkTemperature'] as num).toDouble(),
      targetpH: (json['targetpH'] as num?)?.toDouble(),
      initialMilkpH: (json['initialMilkpH'] as num?)?.toDouble(),
      operatorId: json['operatorId'] as String?,
      additionalParameters:
          json['additionalParameters'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cultureType': cultureType.toString().split('.').last,
      'cultureName': cultureName,
      'supplierCode': supplierCode,
      'lotNumber': lotNumber,
      'amount': amount,
      'amountUnit': amountUnit,
      'additionTime': additionTime.toIso8601String(),
      'milkTemperature': milkTemperature,
      'targetpH': targetpH,
      'initialMilkpH': initialMilkpH,
      'operatorId': operatorId,
      'additionalParameters': additionalParameters,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'additionTime': Timestamp.fromDate(additionTime),
    };
  }

  CultureAdditionDetails copyWith({
    CultureType? cultureType,
    String? cultureName,
    String? supplierCode,
    String? lotNumber,
    double? amount,
    String? amountUnit,
    DateTime? additionTime,
    double? milkTemperature,
    double? targetpH,
    double? initialMilkpH,
    String? operatorId,
    Map<String, dynamic>? additionalParameters,
  }) {
    return CultureAdditionDetails(
      cultureType: cultureType ?? this.cultureType,
      cultureName: cultureName ?? this.cultureName,
      supplierCode: supplierCode ?? this.supplierCode,
      lotNumber: lotNumber ?? this.lotNumber,
      amount: amount ?? this.amount,
      amountUnit: amountUnit ?? this.amountUnit,
      additionTime: additionTime ?? this.additionTime,
      milkTemperature: milkTemperature ?? this.milkTemperature,
      targetpH: targetpH ?? this.targetpH,
      initialMilkpH: initialMilkpH ?? this.initialMilkpH,
      operatorId: operatorId ?? this.operatorId,
      additionalParameters: additionalParameters ?? this.additionalParameters,
    );
  }
}

/// pH and acidity measurements during production
class AcidityMeasurement {
  final DateTime timestamp;
  final double pHValue;
  final double? titratable; // Titratable acidity
  final double? lacticAcid; // Lactic acid percentage
  final String? stage; // Production stage when measured
  final String? measuredBy;
  final String? comments;

  const AcidityMeasurement({
    required this.timestamp,
    required this.pHValue,
    this.titratable,
    this.lacticAcid,
    this.stage,
    this.measuredBy,
    this.comments,
  });

  factory AcidityMeasurement.fromJson(Map<String, dynamic> json) {
    return AcidityMeasurement(
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp'] as String),
      pHValue: (json['pHValue'] as num).toDouble(),
      titratable: (json['titratable'] as num?)?.toDouble(),
      lacticAcid: (json['lacticAcid'] as num?)?.toDouble(),
      stage: json['stage'] as String?,
      measuredBy: json['measuredBy'] as String?,
      comments: json['comments'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'pHValue': pHValue,
      'titratable': titratable,
      'lacticAcid': lacticAcid,
      'stage': stage,
      'measuredBy': measuredBy,
      'comments': comments,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  AcidityMeasurement copyWith({
    DateTime? timestamp,
    double? pHValue,
    double? titratable,
    double? lacticAcid,
    String? stage,
    String? measuredBy,
    String? comments,
  }) {
    return AcidityMeasurement(
      timestamp: timestamp ?? this.timestamp,
      pHValue: pHValue ?? this.pHValue,
      titratable: titratable ?? this.titratable,
      lacticAcid: lacticAcid ?? this.lacticAcid,
      stage: stage ?? this.stage,
      measuredBy: measuredBy ?? this.measuredBy,
      comments: comments ?? this.comments,
    );
  }
}

/// Temperature reading during cooling process
class CoolingCurvePoint {
  final DateTime timestamp;
  final double temperature;
  final String? stage;
  final String? equipmentId;
  final bool isCompliant;
  final String? comments;

  const CoolingCurvePoint({
    required this.timestamp,
    required this.temperature,
    this.stage,
    this.equipmentId,
    required this.isCompliant,
    this.comments,
  });

  factory CoolingCurvePoint.fromJson(Map<String, dynamic> json) {
    return CoolingCurvePoint(
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp'] as String),
      temperature: (json['temperature'] as num).toDouble(),
      stage: json['stage'] as String?,
      equipmentId: json['equipmentId'] as String?,
      isCompliant: json['isCompliant'] as bool,
      comments: json['comments'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'temperature': temperature,
      'stage': stage,
      'equipmentId': equipmentId,
      'isCompliant': isCompliant,
      'comments': comments,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  CoolingCurvePoint copyWith({
    DateTime? timestamp,
    double? temperature,
    String? stage,
    String? equipmentId,
    bool? isCompliant,
    String? comments,
  }) {
    return CoolingCurvePoint(
      timestamp: timestamp ?? this.timestamp,
      temperature: temperature ?? this.temperature,
      stage: stage ?? this.stage,
      equipmentId: equipmentId ?? this.equipmentId,
      isCompliant: isCompliant ?? this.isCompliant,
      comments: comments ?? this.comments,
    );
  }
}

/// Main production batch model for dairy processing
class ProductionBatchModel {
  final String? id;
  final String batchCode;
  final String productId;
  final String productName;
  final double batchSize;
  final String batchUnit;
  final ProductionStatus status;
  final DateTime scheduledStartTime;
  final DateTime? actualStartTime;
  final DateTime? completionTime;
  final String? productionLineId;
  final String? responsibleUserId;
  final String? supervisorId;

  // Dairy-specific fields
  final List<RawMilkSource> rawMilkSources;
  final Map<String, double>? prePasteurizationQualityParams;
  final PasteurizationDetails? pasteurizationDetails;
  final StandardizationParameters? standardizationParameters;
  final CultureAdditionDetails? cultureAdditionDetails;
  final List<AcidityMeasurement>? acidityMeasurements;
  final List<CoolingCurvePoint>? coolingCurvePoints;
  final Map<String, double>? finalQualityParameters;
  final String? qualityGrade;
  final bool isApproved;
  final String? approvedBy;
  final DateTime? approvalTime;
  final String? notes;

  const ProductionBatchModel({
    this.id,
    required this.batchCode,
    required this.productId,
    required this.productName,
    required this.batchSize,
    required this.batchUnit,
    required this.status,
    required this.scheduledStartTime,
    this.actualStartTime,
    this.completionTime,
    this.productionLineId,
    this.responsibleUserId,
    this.supervisorId,
    required this.rawMilkSources,
    this.prePasteurizationQualityParams,
    this.pasteurizationDetails,
    this.standardizationParameters,
    this.cultureAdditionDetails,
    this.acidityMeasurements,
    this.coolingCurvePoints,
    this.finalQualityParameters,
    this.qualityGrade,
    required this.isApproved,
    this.approvedBy,
    this.approvalTime,
    this.notes,
  });

  factory ProductionBatchModel.fromJson(Map<String, dynamic> json) {
    // Handle enum conversion
    final statusValue = json['status'] as String;
    final status = ProductionStatus.values.firstWhere(
      (s) => s.toString().split('.').last == statusValue,
      orElse: () => ProductionStatus.scheduled,
    );

    // Parse raw milk sources
    List<RawMilkSource> rawMilkSources = [];
    if (json['rawMilkSources'] != null) {
      rawMilkSources = (json['rawMilkSources'] as List)
          .map((source) =>
              RawMilkSource.fromJson(source as Map<String, dynamic>))
          .toList();
    }

    // Parse pasteurization details
    PasteurizationDetails? pasteurizationDetails;
    if (json['pasteurizationDetails'] != null) {
      pasteurizationDetails = PasteurizationDetails.fromJson(
          json['pasteurizationDetails'] as Map<String, dynamic>);
    }

    // Parse standardization parameters
    StandardizationParameters? standardizationParameters;
    if (json['standardizationParameters'] != null) {
      standardizationParameters = StandardizationParameters.fromJson(
          json['standardizationParameters'] as Map<String, dynamic>);
    }

    // Parse culture addition details
    CultureAdditionDetails? cultureAdditionDetails;
    if (json['cultureAdditionDetails'] != null) {
      cultureAdditionDetails = CultureAdditionDetails.fromJson(
          json['cultureAdditionDetails'] as Map<String, dynamic>);
    }

    // Parse acidity measurements
    List<AcidityMeasurement>? acidityMeasurements;
    if (json['acidityMeasurements'] != null) {
      acidityMeasurements = (json['acidityMeasurements'] as List)
          .map((measurement) =>
              AcidityMeasurement.fromJson(measurement as Map<String, dynamic>))
          .toList();
    }

    // Parse cooling curve points
    List<CoolingCurvePoint>? coolingCurvePoints;
    if (json['coolingCurvePoints'] != null) {
      coolingCurvePoints = (json['coolingCurvePoints'] as List)
          .map((point) =>
              CoolingCurvePoint.fromJson(point as Map<String, dynamic>))
          .toList();
    }

    // Handle DateTime conversions
    final scheduledStartTime = json['scheduledStartTime'] is Timestamp
        ? (json['scheduledStartTime'] as Timestamp).toDate()
        : DateTime.parse(json['scheduledStartTime'] as String);

    DateTime? actualStartTime;
    if (json['actualStartTime'] != null) {
      actualStartTime = json['actualStartTime'] is Timestamp
          ? (json['actualStartTime'] as Timestamp).toDate()
          : DateTime.parse(json['actualStartTime'] as String);
    }

    DateTime? completionTime;
    if (json['completionTime'] != null) {
      completionTime = json['completionTime'] is Timestamp
          ? (json['completionTime'] as Timestamp).toDate()
          : DateTime.parse(json['completionTime'] as String);
    }

    DateTime? approvalTime;
    if (json['approvalTime'] != null) {
      approvalTime = json['approvalTime'] is Timestamp
          ? (json['approvalTime'] as Timestamp).toDate()
          : DateTime.parse(json['approvalTime'] as String);
    }

    return ProductionBatchModel(
      id: json['id'] as String?,
      batchCode: json['batchCode'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      batchSize: (json['batchSize'] as num).toDouble(),
      batchUnit: json['batchUnit'] as String,
      status: status,
      scheduledStartTime: scheduledStartTime,
      actualStartTime: actualStartTime,
      completionTime: completionTime,
      productionLineId: json['productionLineId'] as String?,
      responsibleUserId: json['responsibleUserId'] as String?,
      supervisorId: json['supervisorId'] as String?,
      rawMilkSources: rawMilkSources,
      prePasteurizationQualityParams:
          json['prePasteurizationQualityParams'] != null
              ? Map<String, double>.from(
                  json['prePasteurizationQualityParams'] as Map)
              : null,
      pasteurizationDetails: pasteurizationDetails,
      standardizationParameters: standardizationParameters,
      cultureAdditionDetails: cultureAdditionDetails,
      acidityMeasurements: acidityMeasurements,
      coolingCurvePoints: coolingCurvePoints,
      finalQualityParameters: json['finalQualityParameters'] != null
          ? Map<String, double>.from(json['finalQualityParameters'] as Map)
          : null,
      qualityGrade: json['qualityGrade'] as String?,
      isApproved: json['isApproved'] as bool? ?? false,
      approvedBy: json['approvedBy'] as String?,
      approvalTime: approvalTime,
      notes: json['notes'] as String?,
    );
  }

  /// Factory method to convert from Firestore document
  factory ProductionBatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Add the document ID to the data
    final jsonWithId = {
      ...data,
      'id': doc.id,
    };

    return ProductionBatchModel.fromJson(jsonWithId);
  }

  Map<String, dynamic> toJson() {
    // Convert raw milk sources list
    final rawMilkSourcesJson =
        rawMilkSources.map((source) => source.toJson()).toList();

    // Convert acidity measurements list
    List<Map<String, dynamic>>? acidityMeasurementsJson;
    if (acidityMeasurements != null) {
      acidityMeasurementsJson = acidityMeasurements!
          .map((measurement) => measurement.toJson())
          .toList();
    }

    // Convert cooling curve points list
    List<Map<String, dynamic>>? coolingCurvePointsJson;
    if (coolingCurvePoints != null) {
      coolingCurvePointsJson =
          coolingCurvePoints!.map((point) => point.toJson()).toList();
    }

    return {
      'id': id,
      'batchCode': batchCode,
      'productId': productId,
      'productName': productName,
      'batchSize': batchSize,
      'batchUnit': batchUnit,
      'status': status.toString().split('.').last,
      'scheduledStartTime': scheduledStartTime.toIso8601String(),
      'actualStartTime': actualStartTime?.toIso8601String(),
      'completionTime': completionTime?.toIso8601String(),
      'productionLineId': productionLineId,
      'responsibleUserId': responsibleUserId,
      'supervisorId': supervisorId,
      'rawMilkSources': rawMilkSourcesJson,
      'prePasteurizationQualityParams': prePasteurizationQualityParams,
      'pasteurizationDetails': pasteurizationDetails?.toJson(),
      'standardizationParameters': standardizationParameters?.toJson(),
      'cultureAdditionDetails': cultureAdditionDetails?.toJson(),
      'acidityMeasurements': acidityMeasurementsJson,
      'coolingCurvePoints': coolingCurvePointsJson,
      'finalQualityParameters': finalQualityParameters,
      'qualityGrade': qualityGrade,
      'isApproved': isApproved,
      'approvedBy': approvedBy,
      'approvalTime': approvalTime?.toIso8601String(),
      'notes': notes,
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    final json = toJson();

    // Convert DateTime fields to Timestamp
    final scheduledStartTimeTimestamp = Timestamp.fromDate(scheduledStartTime);
    final actualStartTimeTimestamp =
        actualStartTime != null ? Timestamp.fromDate(actualStartTime!) : null;
    final completionTimeTimestamp =
        completionTime != null ? Timestamp.fromDate(completionTime!) : null;
    final approvalTimeTimestamp =
        approvalTime != null ? Timestamp.fromDate(approvalTime!) : null;

    // Process complex objects
    // Convert raw milk sources
    final rawMilkSourcesFirestore =
        rawMilkSources.map((source) => source.toFirestore()).toList();

    // Convert pasteurization details
    final pasteurizationDetailsFirestore = pasteurizationDetails?.toFirestore();

    // Convert culture addition details
    final cultureAdditionDetailsFirestore =
        cultureAdditionDetails?.toFirestore();

    // Convert acidity measurements
    List<Map<String, dynamic>>? acidityMeasurementsFirestore;
    if (acidityMeasurements != null) {
      acidityMeasurementsFirestore = acidityMeasurements!
          .map((measurement) => measurement.toFirestore())
          .toList();
    }

    // Convert cooling curve points
    List<Map<String, dynamic>>? coolingCurvePointsFirestore;
    if (coolingCurvePoints != null) {
      coolingCurvePointsFirestore =
          coolingCurvePoints!.map((point) => point.toFirestore()).toList();
    }

    return {
      ...json,
      'scheduledStartTime': scheduledStartTimeTimestamp,
      'actualStartTime': actualStartTimeTimestamp,
      'completionTime': completionTimeTimestamp,
      'approvalTime': approvalTimeTimestamp,
      'rawMilkSources': rawMilkSourcesFirestore,
      'pasteurizationDetails': pasteurizationDetailsFirestore,
      'cultureAdditionDetails': cultureAdditionDetailsFirestore,
      'acidityMeasurements': acidityMeasurementsFirestore,
      'coolingCurvePoints': coolingCurvePointsFirestore,
    };
  }

  ProductionBatchModel copyWith({
    String? id,
    String? batchCode,
    String? productId,
    String? productName,
    double? batchSize,
    String? batchUnit,
    ProductionStatus? status,
    DateTime? scheduledStartTime,
    DateTime? actualStartTime,
    DateTime? completionTime,
    String? productionLineId,
    String? responsibleUserId,
    String? supervisorId,
    List<RawMilkSource>? rawMilkSources,
    Map<String, double>? prePasteurizationQualityParams,
    PasteurizationDetails? pasteurizationDetails,
    StandardizationParameters? standardizationParameters,
    CultureAdditionDetails? cultureAdditionDetails,
    List<AcidityMeasurement>? acidityMeasurements,
    List<CoolingCurvePoint>? coolingCurvePoints,
    Map<String, double>? finalQualityParameters,
    String? qualityGrade,
    bool? isApproved,
    String? approvedBy,
    DateTime? approvalTime,
    String? notes,
  }) {
    return ProductionBatchModel(
      id: id ?? this.id,
      batchCode: batchCode ?? this.batchCode,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      batchSize: batchSize ?? this.batchSize,
      batchUnit: batchUnit ?? this.batchUnit,
      status: status ?? this.status,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      completionTime: completionTime ?? this.completionTime,
      productionLineId: productionLineId ?? this.productionLineId,
      responsibleUserId: responsibleUserId ?? this.responsibleUserId,
      supervisorId: supervisorId ?? this.supervisorId,
      rawMilkSources: rawMilkSources ?? this.rawMilkSources,
      prePasteurizationQualityParams:
          prePasteurizationQualityParams ?? this.prePasteurizationQualityParams,
      pasteurizationDetails:
          pasteurizationDetails ?? this.pasteurizationDetails,
      standardizationParameters:
          standardizationParameters ?? this.standardizationParameters,
      cultureAdditionDetails:
          cultureAdditionDetails ?? this.cultureAdditionDetails,
      acidityMeasurements: acidityMeasurements ?? this.acidityMeasurements,
      coolingCurvePoints: coolingCurvePoints ?? this.coolingCurvePoints,
      finalQualityParameters:
          finalQualityParameters ?? this.finalQualityParameters,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      isApproved: isApproved ?? this.isApproved,
      approvedBy: approvedBy ?? this.approvedBy,
      approvalTime: approvalTime ?? this.approvalTime,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductionBatchModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          batchCode == other.batchCode;

  @override
  int get hashCode => id.hashCode ^ batchCode.hashCode;
}
