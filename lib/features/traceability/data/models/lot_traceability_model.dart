import 'package:cloud_firestore/cloud_firestore.dart';

/// Quality release status for finished products
enum ReleaseStatus {
  pending,
  released,
  rejected,
  on_hold,
  quarantined,
  recalled
}

/// Component material used in a production lot
class ComponentMaterial {

  const ComponentMaterial({
    required this.materialId,
    required this.materialName,
    required this.lotId,
    required this.quantity,
    required this.unit,
    required this.addedAt,
    this.addedBy,
    this.materialAttributes,
    required this.isCritical,
  });

  factory ComponentMaterial.fromJson(Map<String, dynamic> json) {
    return ComponentMaterial(
      materialId: json['materialId'] as String,
      materialName: json['materialName'] as String,
      lotId: json['lotId'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      addedAt: json['addedAt'] is Timestamp
          ? (json['addedAt'] as Timestamp).toDate()
          : DateTime.parse(json['addedAt'] as String),
      addedBy: json['addedBy'] as String?,
      materialAttributes: json['materialAttributes'] as Map<String, dynamic>?,
      isCritical: json['isCritical'] as bool,
    );
  }
  final String materialId;
  final String materialName;
  final String lotId;
  final double quantity;
  final String unit;
  final DateTime addedAt;
  final String? addedBy;
  final Map<String, dynamic>? materialAttributes;
  final bool isCritical;

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'materialName': materialName,
      'lotId': lotId,
      'quantity': quantity,
      'unit': unit,
      'addedAt': addedAt.toIso8601String(),
      'addedBy': addedBy,
      'materialAttributes': materialAttributes,
      'isCritical': isCritical,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  ComponentMaterial copyWith({
    String? materialId,
    String? materialName,
    String? lotId,
    double? quantity,
    String? unit,
    DateTime? addedAt,
    String? addedBy,
    Map<String, dynamic>? materialAttributes,
    bool? isCritical,
  }) {
    return ComponentMaterial(
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      lotId: lotId ?? this.lotId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      addedAt: addedAt ?? this.addedAt,
      addedBy: addedBy ?? this.addedBy,
      materialAttributes: materialAttributes ?? this.materialAttributes,
      isCritical: isCritical ?? this.isCritical,
    );
  }
}

/// Equipment used in production
class ProductionEquipment {

  const ProductionEquipment({
    required this.equipmentId,
    required this.equipmentName,
    this.equipmentType,
    required this.usedFrom,
    required this.usedUntil,
    this.operatorId,
    this.operatorName,
    this.parameters,
    this.cleaningRecordId,
    this.maintenanceStatus,
    required this.validated,
  });

  factory ProductionEquipment.fromJson(Map<String, dynamic> json) {
    return ProductionEquipment(
      equipmentId: json['equipmentId'] as String,
      equipmentName: json['equipmentName'] as String,
      equipmentType: json['equipmentType'] as String?,
      usedFrom: json['usedFrom'] is Timestamp
          ? (json['usedFrom'] as Timestamp).toDate()
          : DateTime.parse(json['usedFrom'] as String),
      usedUntil: json['usedUntil'] is Timestamp
          ? (json['usedUntil'] as Timestamp).toDate()
          : DateTime.parse(json['usedUntil'] as String),
      operatorId: json['operatorId'] as String?,
      operatorName: json['operatorName'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>?,
      cleaningRecordId: json['cleaningRecordId'] as String?,
      maintenanceStatus: json['maintenanceStatus'] as String?,
      validated: json['validated'] as bool,
    );
  }
  final String equipmentId;
  final String equipmentName;
  final String? equipmentType;
  final DateTime usedFrom;
  final DateTime usedUntil;
  final String? operatorId;
  final String? operatorName;
  final Map<String, dynamic>? parameters;
  final String? cleaningRecordId;
  final String? maintenanceStatus;
  final bool validated;

  Map<String, dynamic> toJson() {
    return {
      'equipmentId': equipmentId,
      'equipmentName': equipmentName,
      'equipmentType': equipmentType,
      'usedFrom': usedFrom.toIso8601String(),
      'usedUntil': usedUntil.toIso8601String(),
      'operatorId': operatorId,
      'operatorName': operatorName,
      'parameters': parameters,
      'cleaningRecordId': cleaningRecordId,
      'maintenanceStatus': maintenanceStatus,
      'validated': validated,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'usedFrom': Timestamp.fromDate(usedFrom),
      'usedUntil': Timestamp.fromDate(usedUntil),
    };
  }

  ProductionEquipment copyWith({
    String? equipmentId,
    String? equipmentName,
    String? equipmentType,
    DateTime? usedFrom,
    DateTime? usedUntil,
    String? operatorId,
    String? operatorName,
    Map<String, dynamic>? parameters,
    String? cleaningRecordId,
    String? maintenanceStatus,
    bool? validated,
  }) {
    return ProductionEquipment(
      equipmentId: equipmentId ?? this.equipmentId,
      equipmentName: equipmentName ?? this.equipmentName,
      equipmentType: equipmentType ?? this.equipmentType,
      usedFrom: usedFrom ?? this.usedFrom,
      usedUntil: usedUntil ?? this.usedUntil,
      operatorId: operatorId ?? this.operatorId,
      operatorName: operatorName ?? this.operatorName,
      parameters: parameters ?? this.parameters,
      cleaningRecordId: cleaningRecordId ?? this.cleaningRecordId,
      maintenanceStatus: maintenanceStatus ?? this.maintenanceStatus,
      validated: validated ?? this.validated,
    );
  }
}

/// Personnel involved in production
class ProductionPersonnel {

  const ProductionPersonnel({
    required this.personnelId,
    required this.name,
    required this.role,
    this.certification,
    required this.timestamp,
    this.activity,
    this.responsibilities,
    this.verifiedBy,
  });

  factory ProductionPersonnel.fromJson(Map<String, dynamic> json) {
    return ProductionPersonnel(
      personnelId: json['personnelId'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      certification: json['certification'] as String?,
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp'] as String),
      activity: json['activity'] as String?,
      responsibilities: json['responsibilities'] as Map<String, dynamic>?,
      verifiedBy: json['verifiedBy'] as String?,
    );
  }
  final String personnelId;
  final String name;
  final String role;
  final String? certification;
  final DateTime timestamp;
  final String? activity;
  final Map<String, dynamic>? responsibilities;
  final String? verifiedBy;

  Map<String, dynamic> toJson() {
    return {
      'personnelId': personnelId,
      'name': name,
      'role': role,
      'certification': certification,
      'timestamp': timestamp.toIso8601String(),
      'activity': activity,
      'responsibilities': responsibilities,
      'verifiedBy': verifiedBy,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  ProductionPersonnel copyWith({
    String? personnelId,
    String? name,
    String? role,
    String? certification,
    DateTime? timestamp,
    String? activity,
    Map<String, dynamic>? responsibilities,
    String? verifiedBy,
  }) {
    return ProductionPersonnel(
      personnelId: personnelId ?? this.personnelId,
      name: name ?? this.name,
      role: role ?? this.role,
      certification: certification ?? this.certification,
      timestamp: timestamp ?? this.timestamp,
      activity: activity ?? this.activity,
      responsibilities: responsibilities ?? this.responsibilities,
      verifiedBy: verifiedBy ?? this.verifiedBy,
    );
  }
}

/// Distribution information for lot tracking
class DistributionInfo {

  const DistributionInfo({
    this.shipmentId,
    this.shipmentDate,
    required this.customerId,
    required this.customerName,
    required this.quantity,
    required this.unit,
    this.transporterId,
    this.carrierInfo,
    this.deliveryAddress,
    this.invoiceNumber,
    required this.delivered,
    this.deliveryDate,
    this.deliveryConfirmation,
    this.notes,
  });

  factory DistributionInfo.fromJson(Map<String, dynamic> json) {
    DateTime? shipmentDate;
    if (json['shipmentDate'] != null) {
      shipmentDate = json['shipmentDate'] is Timestamp
          ? (json['shipmentDate'] as Timestamp).toDate()
          : DateTime.parse(json['shipmentDate'] as String);
    }

    DateTime? deliveryDate;
    if (json['deliveryDate'] != null) {
      deliveryDate = json['deliveryDate'] is Timestamp
          ? (json['deliveryDate'] as Timestamp).toDate()
          : DateTime.parse(json['deliveryDate'] as String);
    }

    return DistributionInfo(
      shipmentId: json['shipmentId'] as String?,
      shipmentDate: shipmentDate,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      transporterId: json['transporterId'] as String?,
      carrierInfo: json['carrierInfo'] as String?,
      deliveryAddress: json['deliveryAddress'] as String?,
      invoiceNumber: json['invoiceNumber'] as String?,
      delivered: json['delivered'] as bool,
      deliveryDate: deliveryDate,
      deliveryConfirmation: json['deliveryConfirmation'] as String?,
      notes: json['notes'] as String?,
    );
  }
  final String? shipmentId;
  final DateTime? shipmentDate;
  final String customerId;
  final String customerName;
  final double quantity;
  final String unit;
  final String? transporterId;
  final String? carrierInfo;
  final String? deliveryAddress;
  final String? invoiceNumber;
  final bool delivered;
  final DateTime? deliveryDate;
  final String? deliveryConfirmation;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'shipmentId': shipmentId,
      'shipmentDate': shipmentDate?.toIso8601String(),
      'customerId': customerId,
      'customerName': customerName,
      'quantity': quantity,
      'unit': unit,
      'transporterId': transporterId,
      'carrierInfo': carrierInfo,
      'deliveryAddress': deliveryAddress,
      'invoiceNumber': invoiceNumber,
      'delivered': delivered,
      'deliveryDate': deliveryDate?.toIso8601String(),
      'deliveryConfirmation': deliveryConfirmation,
      'notes': notes,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();

    // Convert DateTime fields to Timestamp
    final shipmentDateTimestamp =
        shipmentDate != null ? Timestamp.fromDate(shipmentDate!) : null;
    final deliveryDateTimestamp =
        deliveryDate != null ? Timestamp.fromDate(deliveryDate!) : null;

    return {
      ...json,
      'shipmentDate': shipmentDateTimestamp,
      'deliveryDate': deliveryDateTimestamp,
    };
  }

  DistributionInfo copyWith({
    String? shipmentId,
    DateTime? shipmentDate,
    String? customerId,
    String? customerName,
    double? quantity,
    String? unit,
    String? transporterId,
    String? carrierInfo,
    String? deliveryAddress,
    String? invoiceNumber,
    bool? delivered,
    DateTime? deliveryDate,
    String? deliveryConfirmation,
    String? notes,
  }) {
    return DistributionInfo(
      shipmentId: shipmentId ?? this.shipmentId,
      shipmentDate: shipmentDate ?? this.shipmentDate,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      transporterId: transporterId ?? this.transporterId,
      carrierInfo: carrierInfo ?? this.carrierInfo,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      delivered: delivered ?? this.delivered,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryConfirmation: deliveryConfirmation ?? this.deliveryConfirmation,
      notes: notes ?? this.notes,
    );
  }
}

/// Main lot traceability model for dairy production
class LotTraceabilityModel {

  const LotTraceabilityModel({
    this.id,
    required this.lotNumber,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.creationDate,
    required this.expiryDate,
    this.batchId,
    required this.quantity,
    required this.unit,
    this.parentLotId,
    this.childLotIds,
    this.productAttributes,
    required this.componentMaterials,
    this.equipmentUsed,
    this.personnelInvolved,
    this.qualityTestIds,
    this.productionRecordId,
    required this.releaseStatus,
    this.releaseApprovedBy,
    this.releaseApprovalDate,
    this.distributionRecords,
    required this.allergenControlled,
    required this.criticalControl,
    this.storageLocation,
    this.storageConditions,
    this.processingParameters,
    this.notes,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  factory LotTraceabilityModel.fromJson(Map<String, dynamic> json) {
    // Parse enum
    final releaseStatusValue = json['releaseStatus'] as String;
    final releaseStatus = ReleaseStatus.values.firstWhere(
      (e) => e.toString().split('.').last == releaseStatusValue,
      orElse: () => ReleaseStatus.pending,
    );

    // Parse component materials
    List<ComponentMaterial> componentMaterials = [];
    if (json['componentMaterials'] != null) {
      componentMaterials = (json['componentMaterials'] as List)
          .map((material) =>
              ComponentMaterial.fromJson(material as Map<String, dynamic>))
          .toList();
    }

    // Parse equipment used
    List<ProductionEquipment>? equipmentUsed;
    if (json['equipmentUsed'] != null) {
      equipmentUsed = (json['equipmentUsed'] as List)
          .map((equipment) =>
              ProductionEquipment.fromJson(equipment as Map<String, dynamic>))
          .toList();
    }

    // Parse personnel involved
    List<ProductionPersonnel>? personnelInvolved;
    if (json['personnelInvolved'] != null) {
      personnelInvolved = (json['personnelInvolved'] as List)
          .map((personnel) =>
              ProductionPersonnel.fromJson(personnel as Map<String, dynamic>))
          .toList();
    }

    // Parse distribution records
    List<DistributionInfo>? distributionRecords;
    if (json['distributionRecords'] != null) {
      distributionRecords = (json['distributionRecords'] as List)
          .map((record) =>
              DistributionInfo.fromJson(record as Map<String, dynamic>))
          .toList();
    }

    // Parse DateTime fields
    final creationDate = json['creationDate'] is Timestamp
        ? (json['creationDate'] as Timestamp).toDate()
        : DateTime.parse(json['creationDate'] as String);

    final expiryDate = json['expiryDate'] is Timestamp
        ? (json['expiryDate'] as Timestamp).toDate()
        : DateTime.parse(json['expiryDate'] as String);

    DateTime? releaseApprovalDate;
    if (json['releaseApprovalDate'] != null) {
      releaseApprovalDate = json['releaseApprovalDate'] is Timestamp
          ? (json['releaseApprovalDate'] as Timestamp).toDate()
          : DateTime.parse(json['releaseApprovalDate'] as String);
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

    // Parse string lists
    List<String>? childLotIds;
    if (json['childLotIds'] != null) {
      childLotIds = List<String>.from(json['childLotIds'] as List);
    }

    List<String>? qualityTestIds;
    if (json['qualityTestIds'] != null) {
      qualityTestIds = List<String>.from(json['qualityTestIds'] as List);
    }

    return LotTraceabilityModel(
      id: json['id'] as String?,
      lotNumber: json['lotNumber'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productCode: json['productCode'] as String,
      creationDate: creationDate,
      expiryDate: expiryDate,
      batchId: json['batchId'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      parentLotId: json['parentLotId'] as String?,
      childLotIds: childLotIds,
      productAttributes: json['productAttributes'] as Map<String, dynamic>?,
      componentMaterials: componentMaterials,
      equipmentUsed: equipmentUsed,
      personnelInvolved: personnelInvolved,
      qualityTestIds: qualityTestIds,
      productionRecordId: json['productionRecordId'] as String?,
      releaseStatus: releaseStatus,
      releaseApprovedBy: json['releaseApprovedBy'] as String?,
      releaseApprovalDate: releaseApprovalDate,
      distributionRecords: distributionRecords,
      allergenControlled: json['allergenControlled'] as bool,
      criticalControl: json['criticalControl'] as bool,
      storageLocation: json['storageLocation'] as String?,
      storageConditions: json['storageConditions'] as String?,
      processingParameters:
          json['processingParameters'] as Map<String, dynamic>?,
      notes: json['notes'] as String?,
      createdAt: createdAt,
      createdBy: json['createdBy'] as String,
      updatedAt: updatedAt,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// Factory method to convert from Firestore document
  factory LotTraceabilityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Add the document ID to the data
    final jsonWithId = {
      ...data,
      'id': doc.id,
    };

    return LotTraceabilityModel.fromJson(jsonWithId);
  }
  final String? id;
  final String lotNumber;
  final String productId;
  final String productName;
  final String productCode;
  final DateTime creationDate;
  final DateTime expiryDate;
  final String? batchId;
  final double quantity;
  final String unit;
  final String? parentLotId;
  final List<String>? childLotIds;
  final Map<String, dynamic>? productAttributes;
  final List<ComponentMaterial> componentMaterials;
  final List<ProductionEquipment>? equipmentUsed;
  final List<ProductionPersonnel>? personnelInvolved;
  final List<String>? qualityTestIds;
  final String? productionRecordId;
  final ReleaseStatus releaseStatus;
  final String? releaseApprovedBy;
  final DateTime? releaseApprovalDate;
  final List<DistributionInfo>? distributionRecords;
  final bool allergenControlled;
  final bool criticalControl;
  final String? storageLocation;
  final String? storageConditions;
  final Map<String, dynamic>? processingParameters;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  Map<String, dynamic> toJson() {
    // Convert component materials
    final componentMaterialsJson =
        componentMaterials.map((m) => m.toJson()).toList();

    // Convert equipment used if present
    List<Map<String, dynamic>>? equipmentUsedJson;
    if (equipmentUsed != null) {
      equipmentUsedJson = equipmentUsed!.map((e) => e.toJson()).toList();
    }

    // Convert personnel involved if present
    List<Map<String, dynamic>>? personnelInvolvedJson;
    if (personnelInvolved != null) {
      personnelInvolvedJson =
          personnelInvolved!.map((p) => p.toJson()).toList();
    }

    // Convert distribution records if present
    List<Map<String, dynamic>>? distributionRecordsJson;
    if (distributionRecords != null) {
      distributionRecordsJson =
          distributionRecords!.map((d) => d.toJson()).toList();
    }

    return {
      'id': id,
      'lotNumber': lotNumber,
      'productId': productId,
      'productName': productName,
      'productCode': productCode,
      'creationDate': creationDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'batchId': batchId,
      'quantity': quantity,
      'unit': unit,
      'parentLotId': parentLotId,
      'childLotIds': childLotIds,
      'productAttributes': productAttributes,
      'componentMaterials': componentMaterialsJson,
      'equipmentUsed': equipmentUsedJson,
      'personnelInvolved': personnelInvolvedJson,
      'qualityTestIds': qualityTestIds,
      'productionRecordId': productionRecordId,
      'releaseStatus': releaseStatus.toString().split('.').last,
      'releaseApprovedBy': releaseApprovedBy,
      'releaseApprovalDate': releaseApprovalDate?.toIso8601String(),
      'distributionRecords': distributionRecordsJson,
      'allergenControlled': allergenControlled,
      'criticalControl': criticalControl,
      'storageLocation': storageLocation,
      'storageConditions': storageConditions,
      'processingParameters': processingParameters,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    final json = toJson();

    // Convert DateTime fields to Timestamp
    final creationDateTimestamp = Timestamp.fromDate(creationDate);
    final expiryDateTimestamp = Timestamp.fromDate(expiryDate);
    final releaseApprovalDateTimestamp = releaseApprovalDate != null
        ? Timestamp.fromDate(releaseApprovalDate!)
        : null;
    final createdAtTimestamp = Timestamp.fromDate(createdAt);
    final updatedAtTimestamp =
        updatedAt != null ? Timestamp.fromDate(updatedAt!) : null;

    // Convert complex objects to Firestore format
    final componentMaterialsFirestore =
        componentMaterials.map((m) => m.toFirestore()).toList();

    List<Map<String, dynamic>>? equipmentUsedFirestore;
    if (equipmentUsed != null) {
      equipmentUsedFirestore =
          equipmentUsed!.map((e) => e.toFirestore()).toList();
    }

    List<Map<String, dynamic>>? personnelInvolvedFirestore;
    if (personnelInvolved != null) {
      personnelInvolvedFirestore =
          personnelInvolved!.map((p) => p.toFirestore()).toList();
    }

    List<Map<String, dynamic>>? distributionRecordsFirestore;
    if (distributionRecords != null) {
      distributionRecordsFirestore =
          distributionRecords!.map((d) => d.toFirestore()).toList();
    }

    return {
      ...json,
      'creationDate': creationDateTimestamp,
      'expiryDate': expiryDateTimestamp,
      'releaseApprovalDate': releaseApprovalDateTimestamp,
      'createdAt': createdAtTimestamp,
      'updatedAt': updatedAtTimestamp,
      'componentMaterials': componentMaterialsFirestore,
      'equipmentUsed': equipmentUsedFirestore,
      'personnelInvolved': personnelInvolvedFirestore,
      'distributionRecords': distributionRecordsFirestore,
    };
  }

  LotTraceabilityModel copyWith({
    String? id,
    String? lotNumber,
    String? productId,
    String? productName,
    String? productCode,
    DateTime? creationDate,
    DateTime? expiryDate,
    String? batchId,
    double? quantity,
    String? unit,
    String? parentLotId,
    List<String>? childLotIds,
    Map<String, dynamic>? productAttributes,
    List<ComponentMaterial>? componentMaterials,
    List<ProductionEquipment>? equipmentUsed,
    List<ProductionPersonnel>? personnelInvolved,
    List<String>? qualityTestIds,
    String? productionRecordId,
    ReleaseStatus? releaseStatus,
    String? releaseApprovedBy,
    DateTime? releaseApprovalDate,
    List<DistributionInfo>? distributionRecords,
    bool? allergenControlled,
    bool? criticalControl,
    String? storageLocation,
    String? storageConditions,
    Map<String, dynamic>? processingParameters,
    String? notes,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return LotTraceabilityModel(
      id: id ?? this.id,
      lotNumber: lotNumber ?? this.lotNumber,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productCode: productCode ?? this.productCode,
      creationDate: creationDate ?? this.creationDate,
      expiryDate: expiryDate ?? this.expiryDate,
      batchId: batchId ?? this.batchId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      parentLotId: parentLotId ?? this.parentLotId,
      childLotIds: childLotIds ?? this.childLotIds,
      productAttributes: productAttributes ?? this.productAttributes,
      componentMaterials: componentMaterials ?? this.componentMaterials,
      equipmentUsed: equipmentUsed ?? this.equipmentUsed,
      personnelInvolved: personnelInvolved ?? this.personnelInvolved,
      qualityTestIds: qualityTestIds ?? this.qualityTestIds,
      productionRecordId: productionRecordId ?? this.productionRecordId,
      releaseStatus: releaseStatus ?? this.releaseStatus,
      releaseApprovedBy: releaseApprovedBy ?? this.releaseApprovedBy,
      releaseApprovalDate: releaseApprovalDate ?? this.releaseApprovalDate,
      distributionRecords: distributionRecords ?? this.distributionRecords,
      allergenControlled: allergenControlled ?? this.allergenControlled,
      criticalControl: criticalControl ?? this.criticalControl,
      storageLocation: storageLocation ?? this.storageLocation,
      storageConditions: storageConditions ?? this.storageConditions,
      processingParameters: processingParameters ?? this.processingParameters,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LotTraceabilityModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          lotNumber == other.lotNumber;

  @override
  int get hashCode => id.hashCode ^ lotNumber.hashCode;
}

/// Extension methods for lot traceability functionality
extension LotTraceabilityExtension on LotTraceabilityModel {
  /// Checks if this lot contains a specific component lot
  bool containsComponentLot(String componentLotId) {
    return componentMaterials
        .any((component) => component.lotId == componentLotId);
  }

  /// Gets all critical component lots
  List<String> getCriticalComponentLots() {
    return componentMaterials
        .where((component) => component.isCritical)
        .map((component) => component.lotId)
        .toList();
  }

  /// Checks if this lot has been distributed to a specific customer
  bool isDistributedToCustomer(String customerId) {
    if (distributionRecords == null) return false;
    return distributionRecords!
        .any((record) => record.customerId == customerId);
  }

  /// Gets total distributed quantity
  double getTotalDistributedQuantity() {
    if (distributionRecords == null || distributionRecords!.isEmpty) return 0;
    return distributionRecords!.fold(0, (sum, record) => sum + record.quantity);
  }

  /// Gets remaining quantity (not distributed)
  double getRemainingQuantity() {
    final distributed = getTotalDistributedQuantity();
    return quantity - distributed;
  }

  /// Checks if the lot is fully distributed
  bool isFullyDistributed() {
    return getRemainingQuantity() <= 0;
  }

  /// Checks if the lot is expired
  bool isExpired() {
    final now = DateTime.now();
    return expiryDate.isBefore(now);
  }

  /// Checks if the lot is releasable (has all requirements for release)
  bool isReleasable() {
    // A lot is releasable if it has quality tests, production record,
    // and all required information
    if (qualityTestIds == null || qualityTestIds!.isEmpty) return false;
    if (productionRecordId == null) return false;

    // Check if there are critical components without lot traceability
    if (componentMaterials.any((m) => m.isCritical && m.lotId.isEmpty)) {
      return false;
    }

    return true;
  }

  /// Gets all customer IDs that received this lot
  List<String> getCustomerDistribution() {
    if (distributionRecords == null) return [];
    return distributionRecords!
        .map((record) => record.customerId)
        .toSet() // Remove duplicates
        .toList();
  }
}

/// Documentation for integration with inventory and production systems:
/// 
/// # Integration with Inventory and Production Systems
/// 
/// The LotTraceabilityModel is designed to integrate with the inventory and production 
/// systems to provide complete traceability from suppliers to customers.
/// 
/// ## Inventory System Integration
/// 
/// - When materials are received via MilkReceptionModel, component lots are created
/// - Inventory movements update the lot location in the storageLocation field
/// - The parentLotId and childLotIds support lot splitting and merging operations
/// - Lot quantity should be synchronized with inventory quantity
/// 
/// ## Production System Integration
/// 
/// - The batchId links to ProductionBatchModel for process details
/// - Component materials track raw materials used in production
/// - Equipment and personnel tracking ensure complete process traceability
/// - productionRecordId links to detailed production records
/// 
/// ## Quality System Integration
/// 
/// - qualityTestIds links to QualityTestResultModel for test results
/// - The releaseStatus controls inventory availability
/// - Integration with compliance documents through the compliance system
/// 
/// ## "One-up, One-down" Traceability
/// 
/// - "One-up" traceability: distributionRecords track where product went
/// - "One-down" traceability: componentMaterials track where materials came from
/// - This supports both tracking and tracing operations:
///   * Tracking: Following the product forward to the customer
///   * Tracing: Following the product backward to the source
/// 
/// ## Batch Genealogy
/// 
/// - parentLotId and childLotIds create a hierarchical relationship between lots
/// - This supports multi-level traceability through processing stages
/// - Enables visualization of complete product flow through the supply chain
/// 
/// ## Usage Example
/// 
/// 1. Create lot for received raw milk using MilkReceptionModel data
/// 2. When milk is processed, create new lot with parentLotId referencing the raw milk lot
/// 3. Record equipment, personnel, and processing parameters during production
/// 4. Link quality tests to ensure safety and compliance
/// 5. When product is distributed, record in distributionRecords
/// 6. If recall needed, trace through the entire chain using lot relationships 