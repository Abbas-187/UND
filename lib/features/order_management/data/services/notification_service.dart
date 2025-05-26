import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/user_role_permission.dart';

/// Service for handling order-related notifications
class NotificationService {
  NotificationService(this.client, this.baseUrl);
  final http.Client client;
  final String baseUrl;

  /// Logs all notification attempts, successes, and failures
  void logNotification({
    required String type,
    required String recipientId,
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
    bool success = true,
    String? error,
  }) {
    // For now, just print. Replace with Firestore or other logging as needed.
    final log = {
      'type': type,
      'recipientId': recipientId,
      'title': title,
      'message': message,
      'metadata': metadata,
      'success': success,
      'error': error,
      'timestamp': DateTime.now().toIso8601String(),
    };
    print('NotificationLog: $log');
    // TODO: Save to Firestore or monitoring system
  }

  /// Notifies admins of notification failures
  Future<void> notifyAdminsOfFailure(
      String error, Map<String, dynamic> context) async {
    // In a real app, fetch all admin user IDs from Firestore or config
    final adminId = 'admin';
    try {
      await sendNotification(
        recipientId: adminId,
        type: 'NOTIFICATION_FAILURE',
        title: 'Notification Failure',
        message: 'A notification failed to send: $error',
        metadata: context,
      );
    } catch (e) {
      print('Failed to alert admin: $e');
    }
  }

  /// Fetches user IDs by role from Firestore, with error handling and short-term caching.
  /// Assumes each user document in 'users' collection has a 'role' field matching RoleType.name.
  /// Caches results for 60 seconds to reduce Firestore reads.
  final Map<RoleType, List<String>> _roleUserCache = {};
  final Map<RoleType, DateTime> _roleUserCacheExpiry = {};

  Future<List<String>> _getUserIdsByRole(RoleType role) async {
    final now = DateTime.now();
    // Use cache if not expired
    if (_roleUserCache.containsKey(role) &&
        _roleUserCacheExpiry[role] != null &&
        now.isBefore(_roleUserCacheExpiry[role]!)) {
      return _roleUserCache[role]!;
    }
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: role.name)
          .get();
      final userIds = query.docs.map((doc) => doc.id).toList();
      // Cache for 60 seconds
      _roleUserCache[role] = userIds;
      _roleUserCacheExpiry[role] = now.add(const Duration(seconds: 60));
      return userIds;
    } catch (e) {
      // Log and alert admin if Firestore query fails
      print('Failed to fetch user IDs for role $role: $e');
      await notifyAdminsOfFailure(
          'Failed to fetch user IDs for role $role: $e', {'role': role.name});
      return [];
    }
  }

  /// Sends a notification to all users with a given role (e.g., procurementManager)
  Future<void> notifyRole({
    required RoleType role,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    // In a real app, fetch user IDs by role from Firestore
    final List<String> recipientIds = await _getUserIdsByRole(role);
    for (final recipientId in recipientIds) {
      try {
        await sendNotification(
          recipientId: recipientId,
          type: type,
          title: title,
          message: message,
          metadata: metadata,
        );
        logNotification(
          type: type,
          recipientId: recipientId,
          title: title,
          message: message,
          metadata: metadata,
          success: true,
        );
      } catch (e) {
        logNotification(
          type: type,
          recipientId: recipientId,
          title: title,
          message: message,
          metadata: metadata,
          success: false,
          error: e.toString(),
        );
        await notifyAdminsOfFailure(e.toString(), {
          'recipientId': recipientId,
          'type': type,
          'title': title,
          'message': message,
          'metadata': metadata,
        });
      }
    }
  }

  Future<void> sendNotification({
    required String recipientId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/notifications'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'recipientId': recipientId,
          'type': type,
          'title': title,
          'message': message,
          'metadata': metadata,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to send notification: \\${response.body}');
      }
    } catch (e) {
      logNotification(
        type: type,
        recipientId: recipientId,
        title: title,
        message: message,
        metadata: metadata,
        success: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Notifies the procurement department about needed items
  Future<void> notifyProcurement({
    required String orderId,
    required String productId,
    required double quantity,
    String? notes,
    required String location,
  }) async {
    final message =
        'Procurement requested for Product $productId ($quantity units) on Order $orderId.';
    await notifyRole(
      role: RoleType.procurementManager,
      type: 'PROCUREMENT_REQUESTED',
      title: 'Procurement Requested',
      message: message,
      metadata: {
        'orderId': orderId,
        'productId': productId,
        'quantity': quantity,
        'notes': notes,
        'location': location,
      },
    );
  }

  /// Notifies production department
  Future<void> notifyProduction(String orderId, String message) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Notifies sales or order creator about status change
  Future<void> notifyStatusChange(
    String orderId,
    String userId,
    String oldStatus,
    String newStatus,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Notifies discussion participants of new message
  Future<void> notifyDiscussionParticipants(
    String orderId,
    List<String> participantIds,
    String message,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

/// Riverpod provider for NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  // Replace with your actual base URL and http client provider
  final client = http.Client();
  const baseUrl = 'https://your-backend-url.com';
  return NotificationService(client, baseUrl);
});
