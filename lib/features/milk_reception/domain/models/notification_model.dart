import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum for notification priority levels
enum NotificationPriority { low, medium, high, critical }

/// Enum for notification delivery methods
enum NotificationDeliveryMethod { inApp, push, email, sms }

/// Enum for notification categories
enum NotificationCategory {
  qualityAlert,
  rejectionNotice,
  receptionCompletion,
  pendingTest,
  supplierPerformance,
  system
}

/// Base notification model
class NotificationModel {

  /// Empty notification
  factory NotificationModel.empty() => NotificationModel(
        id: '',
        title: '',
        message: '',
        category: NotificationCategory.system,
        priority: NotificationPriority.medium,
        createdAt: DateTime.now(),
      );

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      category: NotificationCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => NotificationCategory.system,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => NotificationPriority.medium,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      deliveryMethods: (json['deliveryMethods'] as List<dynamic>?)
              ?.map((e) => NotificationDeliveryMethod.values.firstWhere(
                    (method) => method.toString() == e,
                    orElse: () => NotificationDeliveryMethod.inApp,
                  ))
              .toList() ??
          [],
      isRead: json['isRead'] as bool? ?? false,
      isAcknowledged: json['isAcknowledged'] as bool? ?? false,
      targetUserId: json['targetUserId'] as String?,
      targetRoleId: json['targetRoleId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      acknowledgedAt: json['acknowledgedAt'] != null
          ? (json['acknowledgedAt'] as Timestamp).toDate()
          : null,
      acknowledgedBy: json['acknowledgedBy'] as String?,
    );
  }
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.priority,
    required this.createdAt,
    this.deliveryMethods = const [],
    this.isRead = false,
    this.isAcknowledged = false,
    this.targetUserId,
    this.targetRoleId,
    this.metadata,
    this.acknowledgedAt,
    this.acknowledgedBy,
  });

  final String id;
  final String title;
  final String message;
  final NotificationCategory category;
  final NotificationPriority priority;
  final DateTime createdAt;
  final List<NotificationDeliveryMethod> deliveryMethods;
  final bool isRead;
  final bool isAcknowledged;
  final String? targetUserId;
  final String? targetRoleId;
  final Map<String, dynamic>? metadata;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'category': category.toString(),
      'priority': priority.toString(),
      'createdAt': Timestamp.fromDate(createdAt),
      'deliveryMethods': deliveryMethods.map((e) => e.toString()).toList(),
      'isRead': isRead,
      'isAcknowledged': isAcknowledged,
      'targetUserId': targetUserId,
      'targetRoleId': targetRoleId,
      'metadata': metadata,
      'acknowledgedAt':
          acknowledgedAt != null ? Timestamp.fromDate(acknowledgedAt!) : null,
      'acknowledgedBy': acknowledgedBy,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationCategory? category,
    NotificationPriority? priority,
    DateTime? createdAt,
    List<NotificationDeliveryMethod>? deliveryMethods,
    bool? isRead,
    bool? isAcknowledged,
    String? targetUserId,
    String? targetRoleId,
    Map<String, dynamic>? metadata,
    DateTime? acknowledgedAt,
    String? acknowledgedBy,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      deliveryMethods: deliveryMethods ?? this.deliveryMethods,
      isRead: isRead ?? this.isRead,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      targetUserId: targetUserId ?? this.targetUserId,
      targetRoleId: targetRoleId ?? this.targetRoleId,
      metadata: metadata ?? this.metadata,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
    );
  }
}

/// Quality alert notification
class QualityAlertNotification extends NotificationModel {

  factory QualityAlertNotification.fromJson(Map<String, dynamic> json) {
    return QualityAlertNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      category: NotificationCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => NotificationCategory.qualityAlert,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => NotificationPriority.high,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      deliveryMethods: (json['deliveryMethods'] as List<dynamic>?)
              ?.map((e) => NotificationDeliveryMethod.values.firstWhere(
                    (method) => method.toString() == e,
                    orElse: () => NotificationDeliveryMethod.inApp,
                  ))
              .toList() ??
          [NotificationDeliveryMethod.inApp, NotificationDeliveryMethod.push],
      isRead: json['isRead'] as bool? ?? false,
      isAcknowledged: json['isAcknowledged'] as bool? ?? false,
      targetUserId: json['targetUserId'] as String?,
      targetRoleId: json['targetRoleId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      acknowledgedAt: json['acknowledgedAt'] != null
          ? (json['acknowledgedAt'] as Timestamp).toDate()
          : null,
      acknowledgedBy: json['acknowledgedBy'] as String?,
      receptionId: json['receptionId'] as String,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String,
      parameterName: json['parameterName'] as String,
      parameterValue: (json['parameterValue'] as num).toDouble(),
      thresholdValue: (json['thresholdValue'] as num).toDouble(),
      exceedsThreshold: json['exceedsThreshold'] as bool,
      recommendedAction: json['recommendedAction'] as String?,
    );
  }
  const QualityAlertNotification({
    required super.id,
    required super.title,
    required super.message,
    super.category = NotificationCategory.qualityAlert,
    super.priority = NotificationPriority.high,
    required super.createdAt,
    super.deliveryMethods = const [
      NotificationDeliveryMethod.inApp,
      NotificationDeliveryMethod.push
    ],
    super.isRead = false,
    super.isAcknowledged = false,
    super.targetUserId,
    super.targetRoleId,
    super.metadata,
    super.acknowledgedAt,
    super.acknowledgedBy,
    required this.receptionId,
    required this.supplierId,
    required this.supplierName,
    required this.parameterName,
    required this.parameterValue,
    required this.thresholdValue,
    required this.exceedsThreshold,
    this.recommendedAction,
  });

  final String receptionId;
  final String supplierId;
  final String supplierName;
  final String parameterName;
  final double parameterValue;
  final double thresholdValue;
  final bool exceedsThreshold;
  final String? recommendedAction;

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'receptionId': receptionId,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'parameterName': parameterName,
      'parameterValue': parameterValue,
      'thresholdValue': thresholdValue,
      'exceedsThreshold': exceedsThreshold,
      'recommendedAction': recommendedAction,
    };
  }

  @override
  QualityAlertNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationCategory? category,
    NotificationPriority? priority,
    DateTime? createdAt,
    List<NotificationDeliveryMethod>? deliveryMethods,
    bool? isRead,
    bool? isAcknowledged,
    String? targetUserId,
    String? targetRoleId,
    Map<String, dynamic>? metadata,
    DateTime? acknowledgedAt,
    String? acknowledgedBy,
    String? receptionId,
    String? supplierId,
    String? supplierName,
    String? parameterName,
    double? parameterValue,
    double? thresholdValue,
    bool? exceedsThreshold,
    String? recommendedAction,
  }) {
    return QualityAlertNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      deliveryMethods: deliveryMethods ?? this.deliveryMethods,
      isRead: isRead ?? this.isRead,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      targetUserId: targetUserId ?? this.targetUserId,
      targetRoleId: targetRoleId ?? this.targetRoleId,
      metadata: metadata ?? this.metadata,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      receptionId: receptionId ?? this.receptionId,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      parameterName: parameterName ?? this.parameterName,
      parameterValue: parameterValue ?? this.parameterValue,
      thresholdValue: thresholdValue ?? this.thresholdValue,
      exceedsThreshold: exceedsThreshold ?? this.exceedsThreshold,
      recommendedAction: recommendedAction ?? this.recommendedAction,
    );
  }
}

/// Reception rejection notification
class ReceptionRejectionNotification extends NotificationModel {

  factory ReceptionRejectionNotification.fromJson(Map<String, dynamic> json) {
    return ReceptionRejectionNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      category: NotificationCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => NotificationCategory.rejectionNotice,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => NotificationPriority.high,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      deliveryMethods: (json['deliveryMethods'] as List<dynamic>?)
              ?.map((e) => NotificationDeliveryMethod.values.firstWhere(
                    (method) => method.toString() == e,
                    orElse: () => NotificationDeliveryMethod.inApp,
                  ))
              .toList() ??
          [
            NotificationDeliveryMethod.inApp,
            NotificationDeliveryMethod.push,
            NotificationDeliveryMethod.email
          ],
      isRead: json['isRead'] as bool? ?? false,
      isAcknowledged: json['isAcknowledged'] as bool? ?? false,
      targetUserId: json['targetUserId'] as String?,
      targetRoleId: json['targetRoleId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      acknowledgedAt: json['acknowledgedAt'] != null
          ? (json['acknowledgedAt'] as Timestamp).toDate()
          : null,
      acknowledgedBy: json['acknowledgedBy'] as String?,
      receptionId: json['receptionId'] as String,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String,
      rejectionReason: json['rejectionReason'] as String,
      quantityRejected: (json['quantityRejected'] as num).toDouble(),
      recommendedAction: json['recommendedAction'] as String?,
    );
  }
  const ReceptionRejectionNotification({
    required super.id,
    required super.title,
    required super.message,
    super.category = NotificationCategory.rejectionNotice,
    super.priority = NotificationPriority.high,
    required super.createdAt,
    super.deliveryMethods = const [
      NotificationDeliveryMethod.inApp,
      NotificationDeliveryMethod.push,
      NotificationDeliveryMethod.email
    ],
    super.isRead = false,
    super.isAcknowledged = false,
    super.targetUserId,
    super.targetRoleId,
    super.metadata,
    super.acknowledgedAt,
    super.acknowledgedBy,
    required this.receptionId,
    required this.supplierId,
    required this.supplierName,
    required this.rejectionReason,
    required this.quantityRejected,
    this.recommendedAction,
  });

  final String receptionId;
  final String supplierId;
  final String supplierName;
  final String rejectionReason;
  final double quantityRejected;
  final String? recommendedAction;

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'receptionId': receptionId,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'rejectionReason': rejectionReason,
      'quantityRejected': quantityRejected,
      'recommendedAction': recommendedAction,
    };
  }

  @override
  ReceptionRejectionNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationCategory? category,
    NotificationPriority? priority,
    DateTime? createdAt,
    List<NotificationDeliveryMethod>? deliveryMethods,
    bool? isRead,
    bool? isAcknowledged,
    String? targetUserId,
    String? targetRoleId,
    Map<String, dynamic>? metadata,
    DateTime? acknowledgedAt,
    String? acknowledgedBy,
    String? receptionId,
    String? supplierId,
    String? supplierName,
    String? rejectionReason,
    double? quantityRejected,
    String? recommendedAction,
  }) {
    return ReceptionRejectionNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      deliveryMethods: deliveryMethods ?? this.deliveryMethods,
      isRead: isRead ?? this.isRead,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      targetUserId: targetUserId ?? this.targetUserId,
      targetRoleId: targetRoleId ?? this.targetRoleId,
      metadata: metadata ?? this.metadata,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      receptionId: receptionId ?? this.receptionId,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      quantityRejected: quantityRejected ?? this.quantityRejected,
      recommendedAction: recommendedAction ?? this.recommendedAction,
    );
  }
}

/// Reception completion notification
class ReceptionCompletionNotification extends NotificationModel {

  factory ReceptionCompletionNotification.fromJson(Map<String, dynamic> json) {
    return ReceptionCompletionNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      category: NotificationCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => NotificationCategory.receptionCompletion,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => NotificationPriority.medium,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      deliveryMethods: (json['deliveryMethods'] as List<dynamic>?)
              ?.map((e) => NotificationDeliveryMethod.values.firstWhere(
                    (method) => method.toString() == e,
                    orElse: () => NotificationDeliveryMethod.inApp,
                  ))
              .toList() ??
          [NotificationDeliveryMethod.inApp],
      isRead: json['isRead'] as bool? ?? false,
      isAcknowledged: json['isAcknowledged'] as bool? ?? false,
      targetUserId: json['targetUserId'] as String?,
      targetRoleId: json['targetRoleId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      acknowledgedAt: json['acknowledgedAt'] != null
          ? (json['acknowledgedAt'] as Timestamp).toDate()
          : null,
      acknowledgedBy: json['acknowledgedBy'] as String?,
      receptionId: json['receptionId'] as String,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String,
      quantityAccepted: (json['quantityAccepted'] as num).toDouble(),
      qualityGrade: json['qualityGrade'] as String,
      testResults: json['testResults'] as Map<String, dynamic>?,
    );
  }
  const ReceptionCompletionNotification({
    required super.id,
    required super.title,
    required super.message,
    super.category = NotificationCategory.receptionCompletion,
    super.priority = NotificationPriority.medium,
    required super.createdAt,
    super.deliveryMethods = const [NotificationDeliveryMethod.inApp],
    super.isRead = false,
    super.isAcknowledged = false,
    super.targetUserId,
    super.targetRoleId,
    super.metadata,
    super.acknowledgedAt,
    super.acknowledgedBy,
    required this.receptionId,
    required this.supplierId,
    required this.supplierName,
    required this.quantityAccepted,
    required this.qualityGrade,
    this.testResults,
  });

  final String receptionId;
  final String supplierId;
  final String supplierName;
  final double quantityAccepted;
  final String qualityGrade;
  final Map<String, dynamic>? testResults;

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'receptionId': receptionId,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'quantityAccepted': quantityAccepted,
      'qualityGrade': qualityGrade,
      'testResults': testResults,
    };
  }

  @override
  ReceptionCompletionNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationCategory? category,
    NotificationPriority? priority,
    DateTime? createdAt,
    List<NotificationDeliveryMethod>? deliveryMethods,
    bool? isRead,
    bool? isAcknowledged,
    String? targetUserId,
    String? targetRoleId,
    Map<String, dynamic>? metadata,
    DateTime? acknowledgedAt,
    String? acknowledgedBy,
    String? receptionId,
    String? supplierId,
    String? supplierName,
    double? quantityAccepted,
    String? qualityGrade,
    Map<String, dynamic>? testResults,
  }) {
    return ReceptionCompletionNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      deliveryMethods: deliveryMethods ?? this.deliveryMethods,
      isRead: isRead ?? this.isRead,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      targetUserId: targetUserId ?? this.targetUserId,
      targetRoleId: targetRoleId ?? this.targetRoleId,
      metadata: metadata ?? this.metadata,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      receptionId: receptionId ?? this.receptionId,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      quantityAccepted: quantityAccepted ?? this.quantityAccepted,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      testResults: testResults ?? this.testResults,
    );
  }
}

/// Pending test notification
class PendingTestNotification extends NotificationModel {

  factory PendingTestNotification.fromJson(Map<String, dynamic> json) {
    return PendingTestNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      category: NotificationCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => NotificationCategory.pendingTest,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => NotificationPriority.medium,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      deliveryMethods: (json['deliveryMethods'] as List<dynamic>?)
              ?.map((e) => NotificationDeliveryMethod.values.firstWhere(
                    (method) => method.toString() == e,
                    orElse: () => NotificationDeliveryMethod.inApp,
                  ))
              .toList() ??
          [NotificationDeliveryMethod.inApp, NotificationDeliveryMethod.push],
      isRead: json['isRead'] as bool? ?? false,
      isAcknowledged: json['isAcknowledged'] as bool? ?? false,
      targetUserId: json['targetUserId'] as String?,
      targetRoleId: json['targetRoleId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      acknowledgedAt: json['acknowledgedAt'] != null
          ? (json['acknowledgedAt'] as Timestamp).toDate()
          : null,
      acknowledgedBy: json['acknowledgedBy'] as String?,
      receptionId: json['receptionId'] as String,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String,
      sampleCode: json['sampleCode'] as String,
      receptionTimestamp: (json['receptionTimestamp'] as Timestamp).toDate(),
      testsRequired: (json['testsRequired'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dueBy: (json['dueBy'] as Timestamp).toDate(),
    );
  }
  const PendingTestNotification({
    required super.id,
    required super.title,
    required super.message,
    super.category = NotificationCategory.pendingTest,
    super.priority = NotificationPriority.medium,
    required super.createdAt,
    super.deliveryMethods = const [
      NotificationDeliveryMethod.inApp,
      NotificationDeliveryMethod.push
    ],
    super.isRead = false,
    super.isAcknowledged = false,
    super.targetUserId,
    super.targetRoleId,
    super.metadata,
    super.acknowledgedAt,
    super.acknowledgedBy,
    required this.receptionId,
    required this.supplierId,
    required this.supplierName,
    required this.sampleCode,
    required this.receptionTimestamp,
    required this.testsRequired,
    required this.dueBy,
  });

  final String receptionId;
  final String supplierId;
  final String supplierName;
  final String sampleCode;
  final DateTime receptionTimestamp;
  final List<String> testsRequired;
  final DateTime dueBy;

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'receptionId': receptionId,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'sampleCode': sampleCode,
      'receptionTimestamp': Timestamp.fromDate(receptionTimestamp),
      'testsRequired': testsRequired,
      'dueBy': Timestamp.fromDate(dueBy),
    };
  }

  @override
  PendingTestNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationCategory? category,
    NotificationPriority? priority,
    DateTime? createdAt,
    List<NotificationDeliveryMethod>? deliveryMethods,
    bool? isRead,
    bool? isAcknowledged,
    String? targetUserId,
    String? targetRoleId,
    Map<String, dynamic>? metadata,
    DateTime? acknowledgedAt,
    String? acknowledgedBy,
    String? receptionId,
    String? supplierId,
    String? supplierName,
    String? sampleCode,
    DateTime? receptionTimestamp,
    List<String>? testsRequired,
    DateTime? dueBy,
  }) {
    return PendingTestNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      deliveryMethods: deliveryMethods ?? this.deliveryMethods,
      isRead: isRead ?? this.isRead,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      targetUserId: targetUserId ?? this.targetUserId,
      targetRoleId: targetRoleId ?? this.targetRoleId,
      metadata: metadata ?? this.metadata,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      receptionId: receptionId ?? this.receptionId,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      sampleCode: sampleCode ?? this.sampleCode,
      receptionTimestamp: receptionTimestamp ?? this.receptionTimestamp,
      testsRequired: testsRequired ?? this.testsRequired,
      dueBy: dueBy ?? this.dueBy,
    );
  }
}

/// Supplier performance alert
class SupplierPerformanceAlert extends NotificationModel {

  factory SupplierPerformanceAlert.fromJson(Map<String, dynamic> json) {
    return SupplierPerformanceAlert(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      category: NotificationCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => NotificationCategory.supplierPerformance,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => NotificationPriority.medium,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      deliveryMethods: (json['deliveryMethods'] as List<dynamic>?)
              ?.map((e) => NotificationDeliveryMethod.values.firstWhere(
                    (method) => method.toString() == e,
                    orElse: () => NotificationDeliveryMethod.inApp,
                  ))
              .toList() ??
          [NotificationDeliveryMethod.inApp, NotificationDeliveryMethod.email],
      isRead: json['isRead'] as bool? ?? false,
      isAcknowledged: json['isAcknowledged'] as bool? ?? false,
      targetUserId: json['targetUserId'] as String?,
      targetRoleId: json['targetRoleId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      acknowledgedAt: json['acknowledgedAt'] != null
          ? (json['acknowledgedAt'] as Timestamp).toDate()
          : null,
      acknowledgedBy: json['acknowledgedBy'] as String?,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String,
      performanceData: json['performanceData'] as Map<String, dynamic>,
      trendType: json['trendType'] as String,
      percentageChange: (json['percentageChange'] as num).toDouble(),
      recommendedAction: json['recommendedAction'] as String?,
    );
  }
  const SupplierPerformanceAlert({
    required super.id,
    required super.title,
    required super.message,
    super.category = NotificationCategory.supplierPerformance,
    super.priority = NotificationPriority.medium,
    required super.createdAt,
    super.deliveryMethods = const [
      NotificationDeliveryMethod.inApp,
      NotificationDeliveryMethod.email
    ],
    super.isRead = false,
    super.isAcknowledged = false,
    super.targetUserId,
    super.targetRoleId,
    super.metadata,
    super.acknowledgedAt,
    super.acknowledgedBy,
    required this.supplierId,
    required this.supplierName,
    required this.performanceData,
    required this.trendType,
    required this.percentageChange,
    this.recommendedAction,
  });

  final String supplierId;
  final String supplierName;
  final Map<String, dynamic> performanceData;
  final String trendType;
  final double percentageChange;
  final String? recommendedAction;

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'performanceData': performanceData,
      'trendType': trendType,
      'percentageChange': percentageChange,
      'recommendedAction': recommendedAction,
    };
  }

  @override
  SupplierPerformanceAlert copyWith({
    String? id,
    String? title,
    String? message,
    NotificationCategory? category,
    NotificationPriority? priority,
    DateTime? createdAt,
    List<NotificationDeliveryMethod>? deliveryMethods,
    bool? isRead,
    bool? isAcknowledged,
    String? targetUserId,
    String? targetRoleId,
    Map<String, dynamic>? metadata,
    DateTime? acknowledgedAt,
    String? acknowledgedBy,
    String? supplierId,
    String? supplierName,
    Map<String, dynamic>? performanceData,
    String? trendType,
    double? percentageChange,
    String? recommendedAction,
  }) {
    return SupplierPerformanceAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      deliveryMethods: deliveryMethods ?? this.deliveryMethods,
      isRead: isRead ?? this.isRead,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      targetUserId: targetUserId ?? this.targetUserId,
      targetRoleId: targetRoleId ?? this.targetRoleId,
      metadata: metadata ?? this.metadata,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      performanceData: performanceData ?? this.performanceData,
      trendType: trendType ?? this.trendType,
      percentageChange: percentageChange ?? this.percentageChange,
      recommendedAction: recommendedAction ?? this.recommendedAction,
    );
  }
}
