import 'package:cloud_firestore/cloud_firestore.dart';

/// Acceptance status enum for incoming milk
enum MilkAcceptanceStatus {
  accepted,
  rejected,
  conditionally_accepted,
  pending,
  on_hold
}

/// Organoleptic evaluation parameters
enum OrganolepticParameter {
  appearance,
  smell,
  texture,
  color,
  taste,
  viscosity,
  sediment
}

/// Organoleptic evaluation result
class OrganolepticEvaluation {

  const OrganolepticEvaluation({
    required this.scores,
    this.comments,
    this.overallComment,
    required this.passed,
    this.evaluatedBy,
    required this.evaluationTimestamp,
  });

  factory OrganolepticEvaluation.fromJson(Map<String, dynamic> json) {
    // Convert the scores map
    final scoresMap = <OrganolepticParameter, int>{};
    final jsonScores = json['scores'] as Map<String, dynamic>;

    jsonScores.forEach((key, value) {
      final parameter = OrganolepticParameter.values.firstWhere(
        (p) => p.toString().split('.').last == key,
        orElse: () => OrganolepticParameter.appearance,
      );
      scoresMap[parameter] = value as int;
    });

    // Convert the comments map if present
    Map<OrganolepticParameter, String>? commentsMap;
    if (json['comments'] != null) {
      commentsMap = <OrganolepticParameter, String>{};
      final jsonComments = json['comments'] as Map<String, dynamic>;

      jsonComments.forEach((key, value) {
        final parameter = OrganolepticParameter.values.firstWhere(
          (p) => p.toString().split('.').last == key,
          orElse: () => OrganolepticParameter.appearance,
        );
        commentsMap![parameter] = value as String;
      });
    }

    return OrganolepticEvaluation(
      scores: scoresMap,
      comments: commentsMap,
      overallComment: json['overallComment'] as String?,
      passed: json['passed'] as bool,
      evaluatedBy: json['evaluatedBy'] as String?,
      evaluationTimestamp: json['evaluationTimestamp'] is Timestamp
          ? (json['evaluationTimestamp'] as Timestamp).toDate()
          : DateTime.parse(json['evaluationTimestamp'] as String),
    );
  }
  final Map<OrganolepticParameter, int> scores; // 1-5 scoring
  final Map<OrganolepticParameter, String>? comments;
  final String? overallComment;
  final bool passed;
  final String? evaluatedBy;
  final DateTime evaluationTimestamp;

  Map<String, dynamic> toJson() {
    // Convert the scores map
    final jsonScores = <String, int>{};
    scores.forEach((key, value) {
      jsonScores[key.toString().split('.').last] = value;
    });

    // Convert the comments map if present
    Map<String, String>? jsonComments;
    if (comments != null) {
      jsonComments = <String, String>{};
      comments!.forEach((key, value) {
        jsonComments![key.toString().split('.').last] = value;
      });
    }

    return {
      'scores': jsonScores,
      'comments': jsonComments,
      'overallComment': overallComment,
      'passed': passed,
      'evaluatedBy': evaluatedBy,
      'evaluationTimestamp': evaluationTimestamp.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'evaluationTimestamp': Timestamp.fromDate(evaluationTimestamp),
    };
  }

  OrganolepticEvaluation copyWith({
    Map<OrganolepticParameter, int>? scores,
    Map<OrganolepticParameter, String>? comments,
    String? overallComment,
    bool? passed,
    String? evaluatedBy,
    DateTime? evaluationTimestamp,
  }) {
    return OrganolepticEvaluation(
      scores: scores ?? this.scores,
      comments: comments ?? this.comments,
      overallComment: overallComment ?? this.overallComment,
      passed: passed ?? this.passed,
      evaluatedBy: evaluatedBy ?? this.evaluatedBy,
      evaluationTimestamp: evaluationTimestamp ?? this.evaluationTimestamp,
    );
  }
}

/// Quality test result for received milk
class MilkQualityTest {

  const MilkQualityTest({
    required this.testName,
    required this.value,
    required this.unit,
    this.minThreshold,
    this.maxThreshold,
    required this.passed,
    this.testedBy,
    required this.testTimestamp,
    this.testMethod,
    this.testEquipment,
    this.comments,
  });

  factory MilkQualityTest.fromJson(Map<String, dynamic> json) {
    return MilkQualityTest(
      testName: json['testName'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      minThreshold: (json['minThreshold'] as num?)?.toDouble(),
      maxThreshold: (json['maxThreshold'] as num?)?.toDouble(),
      passed: json['passed'] as bool,
      testedBy: json['testedBy'] as String?,
      testTimestamp: json['testTimestamp'] is Timestamp
          ? (json['testTimestamp'] as Timestamp).toDate()
          : DateTime.parse(json['testTimestamp'] as String),
      testMethod: json['testMethod'] as String?,
      testEquipment: json['testEquipment'] as String?,
      comments: json['comments'] as String?,
    );
  }
  final String testName;
  final double value;
  final String unit;
  final double? minThreshold;
  final double? maxThreshold;
  final bool passed;
  final String? testedBy;
  final DateTime testTimestamp;
  final String? testMethod;
  final String? testEquipment;
  final String? comments;

  Map<String, dynamic> toJson() {
    return {
      'testName': testName,
      'value': value,
      'unit': unit,
      'minThreshold': minThreshold,
      'maxThreshold': maxThreshold,
      'passed': passed,
      'testedBy': testedBy,
      'testTimestamp': testTimestamp.toIso8601String(),
      'testMethod': testMethod,
      'testEquipment': testEquipment,
      'comments': comments,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'testTimestamp': Timestamp.fromDate(testTimestamp),
    };
  }

  MilkQualityTest copyWith({
    String? testName,
    double? value,
    String? unit,
    double? minThreshold,
    double? maxThreshold,
    bool? passed,
    String? testedBy,
    DateTime? testTimestamp,
    String? testMethod,
    String? testEquipment,
    String? comments,
  }) {
    return MilkQualityTest(
      testName: testName ?? this.testName,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      minThreshold: minThreshold ?? this.minThreshold,
      maxThreshold: maxThreshold ?? this.maxThreshold,
      passed: passed ?? this.passed,
      testedBy: testedBy ?? this.testedBy,
      testTimestamp: testTimestamp ?? this.testTimestamp,
      testMethod: testMethod ?? this.testMethod,
      testEquipment: testEquipment ?? this.testEquipment,
      comments: comments ?? this.comments,
    );
  }
}

/// Supplier information for milk reception
class SupplierInfo {

  const SupplierInfo({
    required this.supplierId,
    required this.supplierName,
    this.contactPerson,
    this.contactPhone,
    this.supplierCode,
    required this.certified,
    this.certifications,
    this.farmType,
    this.supplierCategory,
    this.supplierNotes,
  });

  factory SupplierInfo.fromJson(Map<String, dynamic> json) {
    return SupplierInfo(
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String,
      contactPerson: json['contactPerson'] as String?,
      contactPhone: json['contactPhone'] as String?,
      supplierCode: json['supplierCode'] as String?,
      certified: json['certified'] as bool,
      certifications: json['certifications'] as Map<String, dynamic>?,
      farmType: json['farmType'] as String?,
      supplierCategory: json['supplierCategory'] as String?,
      supplierNotes: json['supplierNotes'] as String?,
    );
  }
  final String supplierId;
  final String supplierName;
  final String? contactPerson;
  final String? contactPhone;
  final String? supplierCode;
  final bool certified;
  final Map<String, dynamic>? certifications;
  final String? farmType; // Organic, conventional, etc.
  final String? supplierCategory; // Quality tier, etc.
  final String? supplierNotes;

  Map<String, dynamic> toJson() {
    return {
      'supplierId': supplierId,
      'supplierName': supplierName,
      'contactPerson': contactPerson,
      'contactPhone': contactPhone,
      'supplierCode': supplierCode,
      'certified': certified,
      'certifications': certifications,
      'farmType': farmType,
      'supplierCategory': supplierCategory,
      'supplierNotes': supplierNotes,
    };
  }

  SupplierInfo copyWith({
    String? supplierId,
    String? supplierName,
    String? contactPerson,
    String? contactPhone,
    String? supplierCode,
    bool? certified,
    Map<String, dynamic>? certifications,
    String? farmType,
    String? supplierCategory,
    String? supplierNotes,
  }) {
    return SupplierInfo(
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      contactPerson: contactPerson ?? this.contactPerson,
      contactPhone: contactPhone ?? this.contactPhone,
      supplierCode: supplierCode ?? this.supplierCode,
      certified: certified ?? this.certified,
      certifications: certifications ?? this.certifications,
      farmType: farmType ?? this.farmType,
      supplierCategory: supplierCategory ?? this.supplierCategory,
      supplierNotes: supplierNotes ?? this.supplierNotes,
    );
  }
}

/// Main model for milk reception at the dairy factory
class MilkReceptionModel {

  const MilkReceptionModel({
    this.id,
    required this.receptionCode,
    required this.receptionTimestamp,
    required this.supplierInfo,
    required this.tankerId,
    this.driverName,
    this.transportCompany,
    required this.volume,
    required this.volumeUnit,
    this.weight,
    this.weightUnit,
    required this.temperatureAtReception,
    required this.qualityTests,
    this.organolepticEvaluation,
    required this.acceptanceStatus,
    this.acceptanceDecisionBy,
    this.acceptanceTimestamp,
    this.conditionalParameters,
    this.storageLocationId,
    this.storageLocationName,
    this.batchAssignment,
    this.images,
    this.notes,
    required this.receivedBy,
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  factory MilkReceptionModel.fromJson(Map<String, dynamic> json) {
    // Parse supplier info
    final supplierInfo =
        SupplierInfo.fromJson(json['supplierInfo'] as Map<String, dynamic>);

    // Parse quality tests
    final qualityTestsMap = <String, MilkQualityTest>{};
    final jsonQualityTests = json['qualityTests'] as Map<String, dynamic>;

    jsonQualityTests.forEach((key, value) {
      qualityTestsMap[key] =
          MilkQualityTest.fromJson(value as Map<String, dynamic>);
    });

    // Parse organoleptic evaluation if present
    OrganolepticEvaluation? organolepticEvaluation;
    if (json['organolepticEvaluation'] != null) {
      organolepticEvaluation = OrganolepticEvaluation.fromJson(
          json['organolepticEvaluation'] as Map<String, dynamic>);
    }

    // Parse acceptance status
    final acceptanceStatusValue = json['acceptanceStatus'] as String;
    final acceptanceStatus = MilkAcceptanceStatus.values.firstWhere(
      (s) => s.toString().split('.').last == acceptanceStatusValue,
      orElse: () => MilkAcceptanceStatus.pending,
    );

    // Parse DateTime fields
    final receptionTimestamp = json['receptionTimestamp'] is Timestamp
        ? (json['receptionTimestamp'] as Timestamp).toDate()
        : DateTime.parse(json['receptionTimestamp'] as String);

    DateTime? acceptanceTimestamp;
    if (json['acceptanceTimestamp'] != null) {
      acceptanceTimestamp = json['acceptanceTimestamp'] is Timestamp
          ? (json['acceptanceTimestamp'] as Timestamp).toDate()
          : DateTime.parse(json['acceptanceTimestamp'] as String);
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

    return MilkReceptionModel(
      id: json['id'] as String?,
      receptionCode: json['receptionCode'] as String,
      receptionTimestamp: receptionTimestamp,
      supplierInfo: supplierInfo,
      tankerId: json['tankerId'] as String,
      driverName: json['driverName'] as String?,
      transportCompany: json['transportCompany'] as String?,
      volume: (json['volume'] as num).toDouble(),
      volumeUnit: json['volumeUnit'] as String,
      weight: (json['weight'] as num?)?.toDouble(),
      weightUnit: json['weightUnit'] as String?,
      temperatureAtReception:
          (json['temperatureAtReception'] as num).toDouble(),
      qualityTests: qualityTestsMap,
      organolepticEvaluation: organolepticEvaluation,
      acceptanceStatus: acceptanceStatus,
      acceptanceDecisionBy: json['acceptanceDecisionBy'] as String?,
      acceptanceTimestamp: acceptanceTimestamp,
      conditionalParameters:
          json['conditionalParameters'] as Map<String, dynamic>?,
      storageLocationId: json['storageLocationId'] as String?,
      storageLocationName: json['storageLocationName'] as String?,
      batchAssignment: json['batchAssignment'] as String?,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : null,
      notes: json['notes'] as String?,
      receivedBy: json['receivedBy'] as String,
      createdAt: createdAt,
      updatedBy: json['updatedBy'] as String?,
      updatedAt: updatedAt,
    );
  }

  /// Factory method to convert from Firestore document
  factory MilkReceptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Add the document ID to the data
    final jsonWithId = {
      ...data,
      'id': doc.id,
    };

    return MilkReceptionModel.fromJson(jsonWithId);
  }
  final String? id;
  final String receptionCode;
  final DateTime receptionTimestamp;
  final SupplierInfo supplierInfo;
  final String tankerId;
  final String? driverName;
  final String? transportCompany;
  final double volume;
  final String volumeUnit;
  final double? weight;
  final String? weightUnit;
  final double temperatureAtReception;
  final Map<String, MilkQualityTest> qualityTests;
  final OrganolepticEvaluation? organolepticEvaluation;
  final MilkAcceptanceStatus acceptanceStatus;
  final String? acceptanceDecisionBy;
  final DateTime? acceptanceTimestamp;
  final Map<String, dynamic>? conditionalParameters;
  final String? storageLocationId;
  final String? storageLocationName;
  final String? batchAssignment;
  final List<String>? images;
  final String? notes;
  final String receivedBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    // Convert complex objects
    final supplierInfoJson = supplierInfo.toJson();

    // Convert quality tests map
    final qualityTestsJson = <String, dynamic>{};
    qualityTests.forEach((key, value) {
      qualityTestsJson[key] = value.toJson();
    });

    // Convert organoleptic evaluation if present
    final organolepticEvaluationJson = organolepticEvaluation?.toJson();

    return {
      'id': id,
      'receptionCode': receptionCode,
      'receptionTimestamp': receptionTimestamp.toIso8601String(),
      'supplierInfo': supplierInfoJson,
      'tankerId': tankerId,
      'driverName': driverName,
      'transportCompany': transportCompany,
      'volume': volume,
      'volumeUnit': volumeUnit,
      'weight': weight,
      'weightUnit': weightUnit,
      'temperatureAtReception': temperatureAtReception,
      'qualityTests': qualityTestsJson,
      'organolepticEvaluation': organolepticEvaluationJson,
      'acceptanceStatus': acceptanceStatus.toString().split('.').last,
      'acceptanceDecisionBy': acceptanceDecisionBy,
      'acceptanceTimestamp': acceptanceTimestamp?.toIso8601String(),
      'conditionalParameters': conditionalParameters,
      'storageLocationId': storageLocationId,
      'storageLocationName': storageLocationName,
      'batchAssignment': batchAssignment,
      'images': images,
      'notes': notes,
      'receivedBy': receivedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedBy': updatedBy,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    final json = toJson();

    // Convert DateTime fields to Timestamp
    final receptionTimestampFirestore = Timestamp.fromDate(receptionTimestamp);
    final acceptanceTimestampFirestore = acceptanceTimestamp != null
        ? Timestamp.fromDate(acceptanceTimestamp!)
        : null;
    final createdAtFirestore = Timestamp.fromDate(createdAt);
    final updatedAtFirestore =
        updatedAt != null ? Timestamp.fromDate(updatedAt!) : null;

    // Convert complex nested objects
    final qualityTestsFirestore = <String, dynamic>{};
    qualityTests.forEach((key, value) {
      qualityTestsFirestore[key] = value.toFirestore();
    });

    final organolepticEvaluationFirestore =
        organolepticEvaluation?.toFirestore();

    return {
      ...json,
      'receptionTimestamp': receptionTimestampFirestore,
      'acceptanceTimestamp': acceptanceTimestampFirestore,
      'createdAt': createdAtFirestore,
      'updatedAt': updatedAtFirestore,
      'qualityTests': qualityTestsFirestore,
      'organolepticEvaluation': organolepticEvaluationFirestore,
    };
  }

  MilkReceptionModel copyWith({
    String? id,
    String? receptionCode,
    DateTime? receptionTimestamp,
    SupplierInfo? supplierInfo,
    String? tankerId,
    String? driverName,
    String? transportCompany,
    double? volume,
    String? volumeUnit,
    double? weight,
    String? weightUnit,
    double? temperatureAtReception,
    Map<String, MilkQualityTest>? qualityTests,
    OrganolepticEvaluation? organolepticEvaluation,
    MilkAcceptanceStatus? acceptanceStatus,
    String? acceptanceDecisionBy,
    DateTime? acceptanceTimestamp,
    Map<String, dynamic>? conditionalParameters,
    String? storageLocationId,
    String? storageLocationName,
    String? batchAssignment,
    List<String>? images,
    String? notes,
    String? receivedBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return MilkReceptionModel(
      id: id ?? this.id,
      receptionCode: receptionCode ?? this.receptionCode,
      receptionTimestamp: receptionTimestamp ?? this.receptionTimestamp,
      supplierInfo: supplierInfo ?? this.supplierInfo,
      tankerId: tankerId ?? this.tankerId,
      driverName: driverName ?? this.driverName,
      transportCompany: transportCompany ?? this.transportCompany,
      volume: volume ?? this.volume,
      volumeUnit: volumeUnit ?? this.volumeUnit,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      temperatureAtReception:
          temperatureAtReception ?? this.temperatureAtReception,
      qualityTests: qualityTests ?? this.qualityTests,
      organolepticEvaluation:
          organolepticEvaluation ?? this.organolepticEvaluation,
      acceptanceStatus: acceptanceStatus ?? this.acceptanceStatus,
      acceptanceDecisionBy: acceptanceDecisionBy ?? this.acceptanceDecisionBy,
      acceptanceTimestamp: acceptanceTimestamp ?? this.acceptanceTimestamp,
      conditionalParameters:
          conditionalParameters ?? this.conditionalParameters,
      storageLocationId: storageLocationId ?? this.storageLocationId,
      storageLocationName: storageLocationName ?? this.storageLocationName,
      batchAssignment: batchAssignment ?? this.batchAssignment,
      images: images ?? this.images,
      notes: notes ?? this.notes,
      receivedBy: receivedBy ?? this.receivedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MilkReceptionModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          receptionCode == other.receptionCode;

  @override
  int get hashCode => id.hashCode ^ receptionCode.hashCode;
}
