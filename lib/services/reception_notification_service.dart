import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';

import '../core/firebase/firebase_module.dart';
import '../features/milk_reception/domain/models/notification_model.dart';
import '../models/user_model.dart';

/// Notification service responsible for handling notifications related to milk reception
class ReceptionNotificationService {
  ReceptionNotificationService({
    required dynamic firestore,
    required dynamic messaging,
    required FlutterLocalNotificationsPlugin localNotifications,
  })  : _firestore = firestore,
        _messaging = messaging,
        _localNotifications = localNotifications;

  final dynamic _firestore;
  final dynamic _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final String _notificationsCollection = 'notifications';
  final String _userSettingsCollection = 'userNotificationSettings';
  final _uuid = const Uuid();

  /// Initialize the notification service
  Future<void> initialize() async {
    // Skip initialization if using mock implementation
    if (useMockFirebase) {
      debugPrint(
          'Using mock implementation - skipping real Firebase initialization');
      return;
    }

    // Request permission for notifications
    final settings = await (_messaging as FirebaseMessaging).requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission for notifications');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission for notifications');
    } else {
      print('User declined or has not accepted permission for notifications');
    }

    // Initialize local notifications
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        // Handle notification tap
        _handleNotificationTap(notificationResponse);
      },
    );

    // Set up foreground notification presentation options
    await (_messaging as FirebaseMessaging)
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Handle notification tap/selection
  void _handleNotificationTap(NotificationResponse response) {
    // This will be implemented to navigate to the appropriate screen
    // based on the notification type and data
    print('Notification tapped: ${response.payload}');
  }

  /// Create a quality alert notification
  Future<void> createQualityAlert({
    required String receptionId,
    required String supplierId,
    required String supplierName,
    required String parameterName,
    required double parameterValue,
    required double thresholdValue,
    required bool exceedsThreshold,
    String? recommendedAction,
    List<String>? targetUserIds,
    String? targetRoleId,
  }) async {
    final notificationId = _uuid.v4();
    final isHigh = exceedsThreshold && (parameterValue / thresholdValue > 1.25);

    // Create notification title and message
    final title =
        'Quality Alert: $parameterName ${exceedsThreshold ? "Exceeds" : "Below"} Threshold';
    final message =
        '$supplierName milk reception has $parameterName of $parameterValue '
        '${exceedsThreshold ? "exceeding" : "below"} the threshold of $thresholdValue.';

    // Create notification model
    final notification = QualityAlertNotification(
      id: notificationId,
      title: title,
      message: message,
      priority:
          isHigh ? NotificationPriority.high : NotificationPriority.medium,
      category: NotificationCategory.qualityAlert,
      createdAt: DateTime.now(),
      deliveryMethods: isHigh
          ? [
              NotificationDeliveryMethod.inApp,
              NotificationDeliveryMethod.push,
              NotificationDeliveryMethod.email
            ]
          : [NotificationDeliveryMethod.inApp, NotificationDeliveryMethod.push],
      targetRoleId: targetRoleId,
      receptionId: receptionId,
      supplierId: supplierId,
      supplierName: supplierName,
      parameterName: parameterName,
      parameterValue: parameterValue,
      thresholdValue: thresholdValue,
      exceedsThreshold: exceedsThreshold,
      recommendedAction: recommendedAction,
    );

    // Save notification to Firestore
    await _saveNotification(notification);

    // Send push and other notifications as needed
    if (notification.deliveryMethods
        .contains(NotificationDeliveryMethod.push)) {
      await _sendPushNotification(notification, targetUserIds);
    }

    if (notification.deliveryMethods
        .contains(NotificationDeliveryMethod.email)) {
      await _sendEmailNotification(notification, targetUserIds);
    }

    if (notification.deliveryMethods.contains(NotificationDeliveryMethod.sms) &&
        isHigh) {
      await _sendSmsNotification(notification, targetUserIds);
    }
  }

  /// Create reception rejection notification
  Future<void> createRejectionNotification({
    required String receptionId,
    required String supplierId,
    required String supplierName,
    required String rejectionReason,
    required double quantityRejected,
    String? recommendedAction,
    List<String>? targetUserIds,
    String? targetRoleId,
  }) async {
    final notificationId = _uuid.v4();

    // Create notification title and message
    final title = 'Milk Reception Rejected';
    final message =
        '$quantityRejected liters from $supplierName rejected. Reason: $rejectionReason';

    // Create notification model
    final notification = ReceptionRejectionNotification(
      id: notificationId,
      title: title,
      message: message,
      priority: NotificationPriority.high,
      category: NotificationCategory.rejectionNotice,
      createdAt: DateTime.now(),
      deliveryMethods: [
        NotificationDeliveryMethod.inApp,
        NotificationDeliveryMethod.push,
        NotificationDeliveryMethod.email
      ],
      targetRoleId: targetRoleId,
      receptionId: receptionId,
      supplierId: supplierId,
      supplierName: supplierName,
      rejectionReason: rejectionReason,
      quantityRejected: quantityRejected,
      recommendedAction: recommendedAction,
    );

    // Save notification to Firestore
    await _saveNotification(notification);

    // Send push and other notifications as needed
    await _sendPushNotification(notification, targetUserIds);
    await _sendEmailNotification(notification, targetUserIds);
  }

  /// Create reception completion notification
  Future<void> createCompletionNotification({
    required String receptionId,
    required String supplierId,
    required String supplierName,
    required double quantityAccepted,
    required String qualityGrade,
    Map<String, dynamic>? testResults,
    List<String>? targetUserIds,
    String? targetRoleId,
  }) async {
    final notificationId = _uuid.v4();

    // Create notification title and message
    final title = 'Milk Reception Completed';
    final message =
        '$quantityAccepted liters from $supplierName received. Quality Grade: $qualityGrade';

    // Create notification model
    final notification = ReceptionCompletionNotification(
      id: notificationId,
      title: title,
      message: message,
      priority: NotificationPriority.medium,
      category: NotificationCategory.receptionCompletion,
      createdAt: DateTime.now(),
      targetRoleId: targetRoleId,
      receptionId: receptionId,
      supplierId: supplierId,
      supplierName: supplierName,
      quantityAccepted: quantityAccepted,
      qualityGrade: qualityGrade,
      testResults: testResults,
    );

    // Save notification to Firestore
    await _saveNotification(notification);

    // For completion notifications, we typically only use in-app notifications
    // but if specific users need to be notified via push, we can do that
    if (targetUserIds != null && targetUserIds.isNotEmpty) {
      await _sendPushNotification(notification, targetUserIds);
    }
  }

  /// Create pending test notification
  Future<void> createPendingTestNotification({
    required String receptionId,
    required String supplierId,
    required String supplierName,
    required String sampleCode,
    required DateTime receptionTimestamp,
    required List<String> testsRequired,
    required DateTime dueBy,
    List<String>? targetUserIds,
    String? targetRoleId,
  }) async {
    final notificationId = _uuid.v4();

    // Calculate urgency based on due date
    final now = DateTime.now();
    final difference = dueBy.difference(now).inHours;
    final bool isUrgent = difference <= 4; // If due in 4 hours or less

    // Create notification title and message
    final title = '${isUrgent ? 'URGENT: ' : ''}Pending Milk Tests';
    final message =
        'Sample $sampleCode from $supplierName requires ${testsRequired.join(', ')} '
        'tests. Due ${isUrgent ? 'in $difference hours' : 'by ${dueBy.toIso8601String()}'}';

    // Create notification model
    final notification = PendingTestNotification(
      id: notificationId,
      title: title,
      message: message,
      priority:
          isUrgent ? NotificationPriority.high : NotificationPriority.medium,
      category: NotificationCategory.pendingTest,
      createdAt: DateTime.now(),
      deliveryMethods: isUrgent
          ? [
              NotificationDeliveryMethod.inApp,
              NotificationDeliveryMethod.push,
              NotificationDeliveryMethod.sms
            ]
          : [NotificationDeliveryMethod.inApp, NotificationDeliveryMethod.push],
      targetRoleId: targetRoleId,
      receptionId: receptionId,
      supplierId: supplierId,
      supplierName: supplierName,
      sampleCode: sampleCode,
      receptionTimestamp: receptionTimestamp,
      testsRequired: testsRequired,
      dueBy: dueBy,
    );

    // Save notification to Firestore
    await _saveNotification(notification);

    // Send push notification
    await _sendPushNotification(notification, targetUserIds);

    // Send SMS for urgent notifications
    if (isUrgent) {
      await _sendSmsNotification(notification, targetUserIds);
    }
  }

  /// Create supplier performance alert
  Future<void> createSupplierPerformanceAlert({
    required String supplierId,
    required String supplierName,
    required Map<String, dynamic> performanceData,
    required String trendType,
    required double percentageChange,
    String? recommendedAction,
    List<String>? targetUserIds,
    String? targetRoleId,
  }) async {
    final notificationId = _uuid.v4();

    // Determine if this is a positive or negative trend
    final bool isNegative = percentageChange < 0 ||
        trendType.toLowerCase().contains('decline') ||
        trendType.toLowerCase().contains('decrease');

    // Create notification title and message
    final title = 'Supplier Performance ${isNegative ? 'Alert' : 'Update'}';
    final message =
        '$supplierName shows a ${percentageChange.abs().toStringAsFixed(1)}% '
        '${isNegative ? 'decline' : 'improvement'} in $trendType.';

    // Create notification model
    final notification = SupplierPerformanceAlert(
      id: notificationId,
      title: title,
      message: message,
      priority:
          isNegative ? NotificationPriority.high : NotificationPriority.medium,
      category: NotificationCategory.supplierPerformance,
      createdAt: DateTime.now(),
      deliveryMethods: isNegative
          ? [
              NotificationDeliveryMethod.inApp,
              NotificationDeliveryMethod.email,
              NotificationDeliveryMethod.push
            ]
          : [
              NotificationDeliveryMethod.inApp,
              NotificationDeliveryMethod.email
            ],
      targetRoleId: targetRoleId,
      supplierId: supplierId,
      supplierName: supplierName,
      performanceData: performanceData,
      trendType: trendType,
      percentageChange: percentageChange,
      recommendedAction: recommendedAction,
    );

    // Save notification to Firestore
    await _saveNotification(notification);

    // Send email notification
    await _sendEmailNotification(notification, targetUserIds);

    // Send push notification for negative trends
    if (isNegative) {
      await _sendPushNotification(notification, targetUserIds);
    }
  }

  /// Save notification to Firestore
  Future<void> _saveNotification(NotificationModel notification) async {
    await (_firestore as FirebaseFirestore)
        .collection(_notificationsCollection)
        .doc(notification.id)
        .set(
          notification.toJson(),
        );
  }

  /// Send push notification
  Future<void> _sendPushNotification(
      NotificationModel notification, List<String>? targetUserIds) async {
    // If specific users are targeted, send to their tokens
    if (targetUserIds != null && targetUserIds.isNotEmpty) {
      // Get FCM tokens for the target users
      final tokenDocs = await (_firestore as FirebaseFirestore)
          .collection('userTokens')
          .where('userId', whereIn: targetUserIds)
          .get();

      final tokens =
          tokenDocs.docs.map((doc) => doc['token'] as String).toList();

      // Send to each token
      for (final token in tokens) {
        try {
          await (_messaging as FirebaseMessaging).sendMessage(
            to: token,
            data: {
              'notificationId': notification.id,
              'title': notification.title,
              'body': notification.message,
              'category': notification.category.toString(),
              'priority': notification.priority.toString(),
            },
          );
        } catch (e) {
          print('Error sending push notification to token $token: $e');
        }
      }
    } else if (notification.targetRoleId != null) {
      // If a role is targeted, create a notification topic and send to it
      final topic = 'role_${notification.targetRoleId}';

      try {
        // Note: Firebase Cloud Messaging from the client SDK doesn't support direct sendToTopic
        // In a real app, this would be done through Firebase Functions or a server backend
        print(
            'Would send push notification to topic $topic with title: ${notification.title}');

        // For demonstration purposes, we'll log the intended notification
        // In production, use FCM HTTP v1 API via your server or Cloud Functions
      } catch (e) {
        print('Error sending push notification to topic $topic: $e');
      }
    }

    // Also show local notification
    await _showLocalNotification(notification);
  }

  /// Show local notification
  Future<void> _showLocalNotification(NotificationModel notification) async {
    // Define channel
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'milk_reception_channel',
      'Milk Reception Notifications',
      channelDescription: 'Notifications for milk reception events',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    // Show notification
    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.message,
      notificationDetails,
      payload: notification.id,
    );
  }

  /// Send email notification (placeholder - would connect to email service)
  Future<void> _sendEmailNotification(
      NotificationModel notification, List<String>? targetUserIds) async {
    // This would connect to your email service
    print('Sending email notification: ${notification.title}');

    // Example implementation would get user emails and send via a service like SendGrid
    if (targetUserIds != null && targetUserIds.isNotEmpty) {
      final userDocs = await (_firestore as FirebaseFirestore)
          .collection('users')
          .where(FieldPath.documentId, whereIn: targetUserIds)
          .get();

      final emails = userDocs.docs
          .map((doc) => doc['email'] as String?)
          .where((email) => email != null && email.isNotEmpty)
          .toList();

      // Here you would send the emails using your email service
      for (final email in emails) {
        print('Would send email to $email: ${notification.title}');
      }
    } else if (notification.targetRoleId != null) {
      // Send to users with the specific role
      final userDocs = await (_firestore as FirebaseFirestore)
          .collection('users')
          .where('role', isEqualTo: notification.targetRoleId)
          .get();

      final emails = userDocs.docs
          .map((doc) => doc['email'] as String?)
          .where((email) => email != null && email.isNotEmpty)
          .toList();

      // Here you would send the emails using your email service
      for (final email in emails) {
        print('Would send email to $email: ${notification.title}');
      }
    }
  }

  /// Send SMS notification (placeholder - would connect to SMS service)
  Future<void> _sendSmsNotification(
      NotificationModel notification, List<String>? targetUserIds) async {
    // This would connect to your SMS service
    print('Sending SMS notification: ${notification.title}');

    // Example implementation would get user phone numbers and send via a service like Twilio
    if (targetUserIds != null && targetUserIds.isNotEmpty) {
      final userDocs = await (_firestore as FirebaseFirestore)
          .collection('users')
          .where(FieldPath.documentId, whereIn: targetUserIds)
          .get();

      final phoneNumbers = userDocs.docs
          .map((doc) => doc['phoneNumber'] as String?)
          .where((phone) => phone != null && phone.isNotEmpty)
          .toList();

      // Here you would send the SMS using your SMS service
      for (final phone in phoneNumbers) {
        print('Would send SMS to $phone: ${notification.title}');
      }
    } else if (notification.targetRoleId != null) {
      // Send to users with the specific role
      final userDocs = await (_firestore as FirebaseFirestore)
          .collection('users')
          .where('role', isEqualTo: notification.targetRoleId)
          .get();

      final phoneNumbers = userDocs.docs
          .map((doc) => doc['phoneNumber'] as String?)
          .where((phone) => phone != null && phone.isNotEmpty)
          .toList();

      // Here you would send the SMS using your SMS service
      for (final phone in phoneNumbers) {
        print('Would send SMS to $phone: ${notification.title}');
      }
    }
  }

  /// Get notifications for a user
  Future<List<NotificationModel>> getNotificationsForUser(String userId) async {
    // Get user's role
    final userDoc = await (_firestore as FirebaseFirestore)
        .collection('users')
        .doc(userId)
        .get();
    final userRole = userDoc.data()?['role'] as String?;

    // Query notifications for this user or their role
    final notificationDocs = await (_firestore as FirebaseFirestore)
        .collection(_notificationsCollection)
        .where(Filter.or(
          Filter('targetUserId', isEqualTo: userId),
          Filter('targetRoleId', isEqualTo: userRole),
        ))
        .orderBy('createdAt', descending: true)
        .get();

    // Convert to notification models
    return notificationDocs.docs.map((doc) {
      final data = doc.data();
      final category = NotificationCategory.values.firstWhere(
        (e) => e.toString() == data['category'],
        orElse: () => NotificationCategory.system,
      );

      // Create the appropriate notification type based on the category
      switch (category) {
        case NotificationCategory.qualityAlert:
          return QualityAlertNotification.fromJson(data);
        case NotificationCategory.rejectionNotice:
          return ReceptionRejectionNotification.fromJson(data);
        case NotificationCategory.receptionCompletion:
          return ReceptionCompletionNotification.fromJson(data);
        case NotificationCategory.pendingTest:
          return PendingTestNotification.fromJson(data);
        case NotificationCategory.supplierPerformance:
          return SupplierPerformanceAlert.fromJson(data);
        case NotificationCategory.system:
        default:
          return NotificationModel.fromJson(data);
      }
    }).toList();
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await (_firestore as FirebaseFirestore)
        .collection(_notificationsCollection)
        .doc(notificationId)
        .update({
      'isRead': true,
    });
  }

  /// Mark notification as acknowledged
  Future<void> acknowledgeNotification(
      String notificationId, String userId) async {
    await (_firestore as FirebaseFirestore)
        .collection(_notificationsCollection)
        .doc(notificationId)
        .update({
      'isAcknowledged': true,
      'acknowledgedAt': Timestamp.now(),
      'acknowledgedBy': userId,
    });
  }

  /// Get user notification settings
  Future<Map<String, dynamic>> getUserNotificationSettings(
      String userId) async {
    final doc = await (_firestore as FirebaseFirestore)
        .collection(_userSettingsCollection)
        .doc(userId)
        .get();

    if (doc.exists) {
      return doc.data() ?? {};
    } else {
      // Default settings
      return {
        'inAppEnabled': true,
        'pushEnabled': true,
        'emailEnabled': true,
        'smsEnabled': true,
        'lowPriorityEnabled': true,
        'mediumPriorityEnabled': true,
        'highPriorityEnabled': true,
        'criticalPriorityEnabled': true,
        'doNotDisturbFrom': null,
        'doNotDisturbTo': null,
        'categorySettings': {
          'qualityAlert': true,
          'rejectionNotice': true,
          'receptionCompletion': true,
          'pendingTest': true,
          'supplierPerformance': true,
          'system': true,
        },
      };
    }
  }

  /// Update user notification settings
  Future<void> updateUserNotificationSettings(
      String userId, Map<String, dynamic> settings) async {
    await (_firestore as FirebaseFirestore)
        .collection(_userSettingsCollection)
        .doc(userId)
        .set(
          settings,
          SetOptions(merge: true),
        );
  }

  /// Register user for role-based notifications
  Future<void> subscribeToRoleTopics(UserRole role) async {
    final roleStr = role.toString().split('.').last;
    await (_messaging as FirebaseMessaging).subscribeToTopic('role_$roleStr');

    // Subscribe to other relevant topics based on role
    switch (role) {
      case UserRole.admin:
        await (_messaging as FirebaseMessaging)
            .subscribeToTopic('critical_alerts');
        break;
      case UserRole.factory:
        await (_messaging as FirebaseMessaging)
            .subscribeToTopic('reception_alerts');
        await (_messaging as FirebaseMessaging)
            .subscribeToTopic('quality_alerts');
        break;
      default:
        break;
    }
  }

  /// Unregister user from role-based notifications
  Future<void> unsubscribeFromRoleTopics(UserRole role) async {
    final roleStr = role.toString().split('.').last;
    await (_messaging as FirebaseMessaging)
        .unsubscribeFromTopic('role_$roleStr');

    // Unsubscribe from other relevant topics
    switch (role) {
      case UserRole.admin:
        await (_messaging as FirebaseMessaging)
            .unsubscribeFromTopic('critical_alerts');
        break;
      case UserRole.factory:
        await (_messaging as FirebaseMessaging)
            .unsubscribeFromTopic('reception_alerts');
        await (_messaging as FirebaseMessaging)
            .unsubscribeFromTopic('quality_alerts');
        break;
      default:
        break;
    }
  }

  /// Handle escalation for unacknowledged notifications
  Future<void> checkAndEscalateNotifications() async {
    // Get high priority notifications that are unacknowledged and older than a certain threshold
    final cutoffTime = DateTime.now().subtract(const Duration(hours: 4));

    final unacknowledgedDocs = await (_firestore as FirebaseFirestore)
        .collection(_notificationsCollection)
        .where('priority', whereIn: [
          NotificationPriority.high.toString(),
          NotificationPriority.critical.toString(),
        ])
        .where('isAcknowledged', isEqualTo: false)
        .where('createdAt', isLessThan: Timestamp.fromDate(cutoffTime))
        .get();

    // Process each unacknowledged notification
    for (final doc in unacknowledgedDocs.docs) {
      final data = doc.data();
      final notificationId = doc.id;

      // Create an escalation notification
      final escalationNotification = NotificationModel(
        id: _uuid.v4(),
        title: 'ESCALATION: ${data['title']}',
        message: 'Unacknowledged high priority alert: ${data['message']}',
        category: NotificationCategory.system,
        priority: NotificationPriority.critical,
        createdAt: DateTime.now(),
        deliveryMethods: [
          NotificationDeliveryMethod.push,
          NotificationDeliveryMethod.email,
          NotificationDeliveryMethod.sms,
        ],
        targetRoleId: 'admin', // Escalate to admins
        metadata: {
          'originalNotificationId': notificationId,
          'escalatedAt': Timestamp.now(),
          'originalCategory': data['category'],
        },
      );

      // Save the escalation notification
      await _saveNotification(escalationNotification);

      // Send via all channels
      await _sendPushNotification(escalationNotification, null);
      await _sendEmailNotification(escalationNotification, null);
      await _sendSmsNotification(escalationNotification, null);

      // Update the original notification to mark it as escalated
      await (_firestore as FirebaseFirestore)
          .collection(_notificationsCollection)
          .doc(notificationId)
          .update({
        'metadata.escalated': true,
        'metadata.escalatedAt': Timestamp.now(),
        'metadata.escalationNotificationId': escalationNotification.id,
      });
    }
  }
}
