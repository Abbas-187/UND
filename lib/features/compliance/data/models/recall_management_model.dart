import 'package:cloud_firestore/cloud_firestore.dart';

/// Recall risk level classification
enum RecallRiskLevel {
  class_i, // Serious health hazard (high risk)
  class_ii, // Potential temporary health issue (medium risk)
  class_iii, // Unlikely to cause health issues (low risk)
  market_withdrawal // Quality issue, not safety (voluntary)
}

/// Status of recall process
enum RecallStatus {
  draft,
  initiated,
  in_progress,
  completed,
  closed,
  terminated
}

/// Type of recall notification
enum NotificationType {
  regulatory_agency,
  customer,
  consumer,
  public,
  internal,
  supplier
}

/// Affected product in recall
class AffectedProduct {
  final String productId;
  final String productName;
  final List<String> lotNumbers;
  final String? batchIds;
  final DateTime? productionDateStart;
  final DateTime? productionDateEnd;
  final double? estimatedQuantity;
  final String? unit;
  final String? details;
  final bool criticalProduct;

  const AffectedProduct({
    required this.productId,
    required this.productName,
    required this.lotNumbers,
    this.batchIds,
    this.productionDateStart,
    this.productionDateEnd,
    this.estimatedQuantity,
    this.unit,
    this.details,
    required this.criticalProduct,
  });

  factory AffectedProduct.fromJson(Map<String, dynamic> json) {
    // Parse DateTime fields
    DateTime? productionDateStart;
    if (json['productionDateStart'] != null) {
      productionDateStart = json['productionDateStart'] is Timestamp
          ? (json['productionDateStart'] as Timestamp).toDate()
          : DateTime.parse(json['productionDateStart'] as String);
    }

    DateTime? productionDateEnd;
    if (json['productionDateEnd'] != null) {
      productionDateEnd = json['productionDateEnd'] is Timestamp
          ? (json['productionDateEnd'] as Timestamp).toDate()
          : DateTime.parse(json['productionDateEnd'] as String);
    }

    // Parse lot numbers
    final lotNumbers = List<String>.from(json['lotNumbers'] as List);

    return AffectedProduct(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      lotNumbers: lotNumbers,
      batchIds: json['batchIds'] as String?,
      productionDateStart: productionDateStart,
      productionDateEnd: productionDateEnd,
      estimatedQuantity: json['estimatedQuantity'] != null
          ? (json['estimatedQuantity'] as num).toDouble()
          : null,
      unit: json['unit'] as String?,
      details: json['details'] as String?,
      criticalProduct: json['criticalProduct'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'lotNumbers': lotNumbers,
      'batchIds': batchIds,
      'productionDateStart': productionDateStart?.toIso8601String(),
      'productionDateEnd': productionDateEnd?.toIso8601String(),
      'estimatedQuantity': estimatedQuantity,
      'unit': unit,
      'details': details,
      'criticalProduct': criticalProduct,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();

    // Convert DateTime fields to Timestamp
    final productionDateStartTimestamp = productionDateStart != null
        ? Timestamp.fromDate(productionDateStart!)
        : null;
    final productionDateEndTimestamp = productionDateEnd != null
        ? Timestamp.fromDate(productionDateEnd!)
        : null;

    return {
      ...json,
      'productionDateStart': productionDateStartTimestamp,
      'productionDateEnd': productionDateEndTimestamp,
    };
  }
}

/// Customer distribution information for recall
class CustomerDistribution {
  final String customerId;
  final String customerName;
  final String? contactPerson;
  final String? contactInfo;
  final List<String> distributedLotNumbers;
  final DateTime? distributionDate;
  final double? quantity;
  final String? unit;
  final bool notified;
  final DateTime? notificationDate;
  final NotificationType? notificationType;
  final bool responseReceived;
  final DateTime? responseDate;
  final String? responseDetails;

  const CustomerDistribution({
    required this.customerId,
    required this.customerName,
    this.contactPerson,
    this.contactInfo,
    required this.distributedLotNumbers,
    this.distributionDate,
    this.quantity,
    this.unit,
    required this.notified,
    this.notificationDate,
    this.notificationType,
    required this.responseReceived,
    this.responseDate,
    this.responseDetails,
  });

  factory CustomerDistribution.fromJson(Map<String, dynamic> json) {
    // Parse DateTime fields
    DateTime? distributionDate;
    if (json['distributionDate'] != null) {
      distributionDate = json['distributionDate'] is Timestamp
          ? (json['distributionDate'] as Timestamp).toDate()
          : DateTime.parse(json['distributionDate'] as String);
    }

    DateTime? notificationDate;
    if (json['notificationDate'] != null) {
      notificationDate = json['notificationDate'] is Timestamp
          ? (json['notificationDate'] as Timestamp).toDate()
          : DateTime.parse(json['notificationDate'] as String);
    }

    DateTime? responseDate;
    if (json['responseDate'] != null) {
      responseDate = json['responseDate'] is Timestamp
          ? (json['responseDate'] as Timestamp).toDate()
          : DateTime.parse(json['responseDate'] as String);
    }

    // Parse notification type enum
    NotificationType? notificationType;
    if (json['notificationType'] != null) {
      final notificationTypeValue = json['notificationType'] as String;
      notificationType = NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == notificationTypeValue,
        orElse: () => NotificationType.customer,
      );
    }

    // Parse lot numbers
    final distributedLotNumbers =
        List<String>.from(json['distributedLotNumbers'] as List);

    return CustomerDistribution(
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      contactPerson: json['contactPerson'] as String?,
      contactInfo: json['contactInfo'] as String?,
      distributedLotNumbers: distributedLotNumbers,
      distributionDate: distributionDate,
      quantity: json['quantity'] != null
          ? (json['quantity'] as num).toDouble()
          : null,
      unit: json['unit'] as String?,
      notified: json['notified'] as bool,
      notificationDate: notificationDate,
      notificationType: notificationType,
      responseReceived: json['responseReceived'] as bool,
      responseDate: responseDate,
      responseDetails: json['responseDetails'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'contactPerson': contactPerson,
      'contactInfo': contactInfo,
      'distributedLotNumbers': distributedLotNumbers,
      'distributionDate': distributionDate?.toIso8601String(),
      'quantity': quantity,
      'unit': unit,
      'notified': notified,
      'notificationDate': notificationDate?.toIso8601String(),
      'notificationType': notificationType?.toString().split('.').last,
      'responseReceived': responseReceived,
      'responseDate': responseDate?.toIso8601String(),
      'responseDetails': responseDetails,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();

    // Convert DateTime fields to Timestamp
    final distributionDateTimestamp =
        distributionDate != null ? Timestamp.fromDate(distributionDate!) : null;
    final notificationDateTimestamp =
        notificationDate != null ? Timestamp.fromDate(notificationDate!) : null;
    final responseDateTimestamp =
        responseDate != null ? Timestamp.fromDate(responseDate!) : null;

    return {
      ...json,
      'distributionDate': distributionDateTimestamp,
      'notificationDate': notificationDateTimestamp,
      'responseDate': responseDateTimestamp,
    };
  }
}

/// Regulatory notification for recall
class RegulatoryNotification {
  final String authorityName;
  final String? authorityCode;
  final String? contactPerson;
  final String? contactInfo;
  final DateTime notificationDate;
  final String? notificationMethod;
  final String? notificationContent;
  final String? reportNumber;
  final bool responseRequired;
  final DateTime? responseDeadline;
  final bool responseSubmitted;
  final DateTime? responseDate;
  final String? responseDetails;

  const RegulatoryNotification({
    required this.authorityName,
    this.authorityCode,
    this.contactPerson,
    this.contactInfo,
    required this.notificationDate,
    this.notificationMethod,
    this.notificationContent,
    this.reportNumber,
    required this.responseRequired,
    this.responseDeadline,
    required this.responseSubmitted,
    this.responseDate,
    this.responseDetails,
  });

  factory RegulatoryNotification.fromJson(Map<String, dynamic> json) {
    // Parse DateTime fields
    final notificationDate = json['notificationDate'] is Timestamp
        ? (json['notificationDate'] as Timestamp).toDate()
        : DateTime.parse(json['notificationDate'] as String);

    DateTime? responseDeadline;
    if (json['responseDeadline'] != null) {
      responseDeadline = json['responseDeadline'] is Timestamp
          ? (json['responseDeadline'] as Timestamp).toDate()
          : DateTime.parse(json['responseDeadline'] as String);
    }

    DateTime? responseDate;
    if (json['responseDate'] != null) {
      responseDate = json['responseDate'] is Timestamp
          ? (json['responseDate'] as Timestamp).toDate()
          : DateTime.parse(json['responseDate'] as String);
    }

    return RegulatoryNotification(
      authorityName: json['authorityName'] as String,
      authorityCode: json['authorityCode'] as String?,
      contactPerson: json['contactPerson'] as String?,
      contactInfo: json['contactInfo'] as String?,
      notificationDate: notificationDate,
      notificationMethod: json['notificationMethod'] as String?,
      notificationContent: json['notificationContent'] as String?,
      reportNumber: json['reportNumber'] as String?,
      responseRequired: json['responseRequired'] as bool,
      responseDeadline: responseDeadline,
      responseSubmitted: json['responseSubmitted'] as bool,
      responseDate: responseDate,
      responseDetails: json['responseDetails'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorityName': authorityName,
      'authorityCode': authorityCode,
      'contactPerson': contactPerson,
      'contactInfo': contactInfo,
      'notificationDate': notificationDate.toIso8601String(),
      'notificationMethod': notificationMethod,
      'notificationContent': notificationContent,
      'reportNumber': reportNumber,
      'responseRequired': responseRequired,
      'responseDeadline': responseDeadline?.toIso8601String(),
      'responseSubmitted': responseSubmitted,
      'responseDate': responseDate?.toIso8601String(),
      'responseDetails': responseDetails,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();

    // Convert DateTime fields to Timestamp
    final notificationDateTimestamp = Timestamp.fromDate(notificationDate);
    final responseDeadlineTimestamp =
        responseDeadline != null ? Timestamp.fromDate(responseDeadline!) : null;
    final responseDateTimestamp =
        responseDate != null ? Timestamp.fromDate(responseDate!) : null;

    return {
      ...json,
      'notificationDate': notificationDateTimestamp,
      'responseDeadline': responseDeadlineTimestamp,
      'responseDate': responseDateTimestamp,
    };
  }
}

/// Main recall management model
class RecallManagementModel {
  final String? id;
  final String recallNumber;
  final String title;
  final String description;
  final RecallRiskLevel riskLevel;
  final String? reason;
  final DateTime initiationDate;
  final String initiatedBy;
  final String? approvedBy;
  final RecallStatus status;
  final DateTime? closedDate;
  final List<AffectedProduct> affectedProducts;
  final List<CustomerDistribution>? customerDistributions;
  final List<RegulatoryNotification>? regulatoryNotifications;
  final double? totalProductQuantity;
  final double? recoveredQuantity;
  final double? disposedQuantity;
  final String? rootCause;
  final String? rootCauseAnalysis;
  final List<String>? correctiveActions;
  final List<String>? preventiveActions;
  final String? correctiveActionStatus;
  final bool publicNotification;
  final String? publicNotificationDetails;
  final List<String>? documentIds;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  const RecallManagementModel({
    this.id,
    required this.recallNumber,
    required this.title,
    required this.description,
    required this.riskLevel,
    this.reason,
    required this.initiationDate,
    required this.initiatedBy,
    this.approvedBy,
    required this.status,
    this.closedDate,
    required this.affectedProducts,
    this.customerDistributions,
    this.regulatoryNotifications,
    this.totalProductQuantity,
    this.recoveredQuantity,
    this.disposedQuantity,
    this.rootCause,
    this.rootCauseAnalysis,
    this.correctiveActions,
    this.preventiveActions,
    this.correctiveActionStatus,
    required this.publicNotification,
    this.publicNotificationDetails,
    this.documentIds,
    this.notes,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  factory RecallManagementModel.fromJson(Map<String, dynamic> json) {
    // Parse enums
    final riskLevelValue = json['riskLevel'] as String;
    final riskLevel = RecallRiskLevel.values.firstWhere(
      (e) => e.toString().split('.').last == riskLevelValue,
      orElse: () => RecallRiskLevel.class_ii,
    );

    final statusValue = json['status'] as String;
    final status = RecallStatus.values.firstWhere(
      (e) => e.toString().split('.').last == statusValue,
      orElse: () => RecallStatus.draft,
    );

    // Parse complex objects
    final affectedProducts = (json['affectedProducts'] as List)
        .map((product) =>
            AffectedProduct.fromJson(product as Map<String, dynamic>))
        .toList();

    List<CustomerDistribution>? customerDistributions;
    if (json['customerDistributions'] != null) {
      customerDistributions = (json['customerDistributions'] as List)
          .map((distribution) => CustomerDistribution.fromJson(
              distribution as Map<String, dynamic>))
          .toList();
    }

    List<RegulatoryNotification>? regulatoryNotifications;
    if (json['regulatoryNotifications'] != null) {
      regulatoryNotifications = (json['regulatoryNotifications'] as List)
          .map((notification) => RegulatoryNotification.fromJson(
              notification as Map<String, dynamic>))
          .toList();
    }

    // Parse List<String> fields
    List<String>? correctiveActions;
    if (json['correctiveActions'] != null) {
      correctiveActions = List<String>.from(json['correctiveActions'] as List);
    }

    List<String>? preventiveActions;
    if (json['preventiveActions'] != null) {
      preventiveActions = List<String>.from(json['preventiveActions'] as List);
    }

    List<String>? documentIds;
    if (json['documentIds'] != null) {
      documentIds = List<String>.from(json['documentIds'] as List);
    }

    // Parse DateTime fields
    final initiationDate = json['initiationDate'] is Timestamp
        ? (json['initiationDate'] as Timestamp).toDate()
        : DateTime.parse(json['initiationDate'] as String);

    DateTime? closedDate;
    if (json['closedDate'] != null) {
      closedDate = json['closedDate'] is Timestamp
          ? (json['closedDate'] as Timestamp).toDate()
          : DateTime.parse(json['closedDate'] as String);
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

    return RecallManagementModel(
      id: json['id'] as String?,
      recallNumber: json['recallNumber'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      riskLevel: riskLevel,
      reason: json['reason'] as String?,
      initiationDate: initiationDate,
      initiatedBy: json['initiatedBy'] as String,
      approvedBy: json['approvedBy'] as String?,
      status: status,
      closedDate: closedDate,
      affectedProducts: affectedProducts,
      customerDistributions: customerDistributions,
      regulatoryNotifications: regulatoryNotifications,
      totalProductQuantity: json['totalProductQuantity'] != null
          ? (json['totalProductQuantity'] as num).toDouble()
          : null,
      recoveredQuantity: json['recoveredQuantity'] != null
          ? (json['recoveredQuantity'] as num).toDouble()
          : null,
      disposedQuantity: json['disposedQuantity'] != null
          ? (json['disposedQuantity'] as num).toDouble()
          : null,
      rootCause: json['rootCause'] as String?,
      rootCauseAnalysis: json['rootCauseAnalysis'] as String?,
      correctiveActions: correctiveActions,
      preventiveActions: preventiveActions,
      correctiveActionStatus: json['correctiveActionStatus'] as String?,
      publicNotification: json['publicNotification'] as bool,
      publicNotificationDetails: json['publicNotificationDetails'] as String?,
      documentIds: documentIds,
      notes: json['notes'] as String?,
      createdAt: createdAt,
      createdBy: json['createdBy'] as String,
      updatedAt: updatedAt,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  /// Factory method to convert from Firestore document
  factory RecallManagementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Add the document ID to the data
    final jsonWithId = {
      ...data,
      'id': doc.id,
    };

    return RecallManagementModel.fromJson(jsonWithId);
  }

  Map<String, dynamic> toJson() {
    // Convert affected products
    final affectedProductsJson =
        affectedProducts.map((p) => p.toJson()).toList();

    // Convert customer distributions if present
    List<Map<String, dynamic>>? customerDistributionsJson;
    if (customerDistributions != null) {
      customerDistributionsJson =
          customerDistributions!.map((d) => d.toJson()).toList();
    }

    // Convert regulatory notifications if present
    List<Map<String, dynamic>>? regulatoryNotificationsJson;
    if (regulatoryNotifications != null) {
      regulatoryNotificationsJson =
          regulatoryNotifications!.map((n) => n.toJson()).toList();
    }

    return {
      'id': id,
      'recallNumber': recallNumber,
      'title': title,
      'description': description,
      'riskLevel': riskLevel.toString().split('.').last,
      'reason': reason,
      'initiationDate': initiationDate.toIso8601String(),
      'initiatedBy': initiatedBy,
      'approvedBy': approvedBy,
      'status': status.toString().split('.').last,
      'closedDate': closedDate?.toIso8601String(),
      'affectedProducts': affectedProductsJson,
      'customerDistributions': customerDistributionsJson,
      'regulatoryNotifications': regulatoryNotificationsJson,
      'totalProductQuantity': totalProductQuantity,
      'recoveredQuantity': recoveredQuantity,
      'disposedQuantity': disposedQuantity,
      'rootCause': rootCause,
      'rootCauseAnalysis': rootCauseAnalysis,
      'correctiveActions': correctiveActions,
      'preventiveActions': preventiveActions,
      'correctiveActionStatus': correctiveActionStatus,
      'publicNotification': publicNotification,
      'publicNotificationDetails': publicNotificationDetails,
      'documentIds': documentIds,
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
    final initiationDateTimestamp = Timestamp.fromDate(initiationDate);
    final closedDateTimestamp =
        closedDate != null ? Timestamp.fromDate(closedDate!) : null;
    final createdAtTimestamp = Timestamp.fromDate(createdAt);
    final updatedAtTimestamp =
        updatedAt != null ? Timestamp.fromDate(updatedAt!) : null;

    // Convert complex objects to Firestore format
    final affectedProductsFirestore =
        affectedProducts.map((p) => p.toFirestore()).toList();

    List<Map<String, dynamic>>? customerDistributionsFirestore;
    if (customerDistributions != null) {
      customerDistributionsFirestore =
          customerDistributions!.map((d) => d.toFirestore()).toList();
    }

    List<Map<String, dynamic>>? regulatoryNotificationsFirestore;
    if (regulatoryNotifications != null) {
      regulatoryNotificationsFirestore =
          regulatoryNotifications!.map((n) => n.toFirestore()).toList();
    }

    return {
      ...json,
      'initiationDate': initiationDateTimestamp,
      'closedDate': closedDateTimestamp,
      'createdAt': createdAtTimestamp,
      'updatedAt': updatedAtTimestamp,
      'affectedProducts': affectedProductsFirestore,
      'customerDistributions': customerDistributionsFirestore,
      'regulatoryNotifications': regulatoryNotificationsFirestore,
    };
  }

  RecallManagementModel copyWith({
    String? id,
    String? recallNumber,
    String? title,
    String? description,
    RecallRiskLevel? riskLevel,
    String? reason,
    DateTime? initiationDate,
    String? initiatedBy,
    String? approvedBy,
    RecallStatus? status,
    DateTime? closedDate,
    List<AffectedProduct>? affectedProducts,
    List<CustomerDistribution>? customerDistributions,
    List<RegulatoryNotification>? regulatoryNotifications,
    double? totalProductQuantity,
    double? recoveredQuantity,
    double? disposedQuantity,
    String? rootCause,
    String? rootCauseAnalysis,
    List<String>? correctiveActions,
    List<String>? preventiveActions,
    String? correctiveActionStatus,
    bool? publicNotification,
    String? publicNotificationDetails,
    List<String>? documentIds,
    String? notes,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return RecallManagementModel(
      id: id ?? this.id,
      recallNumber: recallNumber ?? this.recallNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      riskLevel: riskLevel ?? this.riskLevel,
      reason: reason ?? this.reason,
      initiationDate: initiationDate ?? this.initiationDate,
      initiatedBy: initiatedBy ?? this.initiatedBy,
      approvedBy: approvedBy ?? this.approvedBy,
      status: status ?? this.status,
      closedDate: closedDate ?? this.closedDate,
      affectedProducts: affectedProducts ?? this.affectedProducts,
      customerDistributions:
          customerDistributions ?? this.customerDistributions,
      regulatoryNotifications:
          regulatoryNotifications ?? this.regulatoryNotifications,
      totalProductQuantity: totalProductQuantity ?? this.totalProductQuantity,
      recoveredQuantity: recoveredQuantity ?? this.recoveredQuantity,
      disposedQuantity: disposedQuantity ?? this.disposedQuantity,
      rootCause: rootCause ?? this.rootCause,
      rootCauseAnalysis: rootCauseAnalysis ?? this.rootCauseAnalysis,
      correctiveActions: correctiveActions ?? this.correctiveActions,
      preventiveActions: preventiveActions ?? this.preventiveActions,
      correctiveActionStatus:
          correctiveActionStatus ?? this.correctiveActionStatus,
      publicNotification: publicNotification ?? this.publicNotification,
      publicNotificationDetails:
          publicNotificationDetails ?? this.publicNotificationDetails,
      documentIds: documentIds ?? this.documentIds,
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
      other is RecallManagementModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          recallNumber == other.recallNumber;

  @override
  int get hashCode => id.hashCode ^ recallNumber.hashCode;
}

/// Extension methods for recall functionality
extension RecallManagementExtension on RecallManagementModel {
  /// Calculate recovery percentage
  double getRecoveryPercentage() {
    if (totalProductQuantity == null ||
        recoveredQuantity == null ||
        totalProductQuantity == 0) {
      return 0.0;
    }
    return (recoveredQuantity! / totalProductQuantity!) * 100;
  }

  /// Check if recall is complete
  bool isComplete() {
    return status == RecallStatus.completed || status == RecallStatus.closed;
  }

  /// Get all lot numbers affected in this recall
  List<String> getAllAffectedLotNumbers() {
    final allLots = <String>[];
    for (final product in affectedProducts) {
      allLots.addAll(product.lotNumbers);
    }
    return allLots.toSet().toList(); // Remove duplicates
  }

  /// Get all customers affected by this recall
  List<String> getAffectedCustomerIds() {
    if (customerDistributions == null) return [];
    return customerDistributions!
        .map((distribution) => distribution.customerId)
        .toSet()
        .toList();
  }

  /// Get unnotified customers
  List<CustomerDistribution> getUnnotifiedCustomers() {
    if (customerDistributions == null) return [];
    return customerDistributions!
        .where((distribution) => !distribution.notified)
        .toList();
  }

  /// Get all public facing documentation IDs
  List<String> getPublicDocuments() {
    if (!publicNotification || documentIds == null) return [];
    return documentIds!;
  }

  /// Check if root cause analysis is complete
  bool isRootCauseComplete() {
    return rootCause != null && rootCause!.isNotEmpty;
  }

  /// Calculate total number of affected lots
  int getTotalAffectedLots() {
    return getAllAffectedLotNumbers().length;
  }
}
