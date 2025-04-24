import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../models/user_role.dart';

/// Service for handling order-related notifications
class NotificationService {
  /// Notifies the procurement department about a new procurement request
  Future<void> notifyProcurement(
    String orderId,
    List<OrderItem> itemsNeedingProcurement,
    String location,
  ) async {
    // In a real implementation, this would:
    // 1. Format the notification message
    // 2. Identify procurement users in the given location
    // 3. Send them a notification (push, email, SMS, or in-app)

    // For mock implementation, we'll just simulate a delay
    await Future.delayed(const Duration(milliseconds: 300));

    print('Procurement notification sent for order $orderId at $location');
    print(
        'Items needed: ${itemsNeedingProcurement.map((i) => '${i.quantity} ${i.unit} of ${i.name}').join(', ')}');
  }

  /// Notifies the production department that an order is ready for production
  Future<void> notifyProduction(
    String orderId,
    String message,
  ) async {
    // In a real implementation, this would identify production users and send them notifications
    await Future.delayed(const Duration(milliseconds: 300));

    print('Production notification sent for order $orderId: $message');
  }

  /// Notifies the sales department about an order status change
  Future<void> notifySales(
    String orderId,
    OrderStatus oldStatus,
    OrderStatus newStatus,
    String salesUserId,
  ) async {
    // In a real implementation, this would send notifications to the sales person
    await Future.delayed(const Duration(milliseconds: 300));

    print(
        'Sales notification sent to $salesUserId for order $orderId: Status changed from ${oldStatus.name} to ${newStatus.name}');
  }

  /// Notifies the order creator about a status change
  Future<void> notifyOrderCreator(
    String orderId,
    String creatorId,
    String message,
  ) async {
    // In a real implementation, this would send notifications to the order creator
    await Future.delayed(const Duration(milliseconds: 300));

    print(
        'Notification sent to creator $creatorId for order $orderId: $message');
  }

  /// Sends a notification to a branch manager about a high-priority order
  Future<void> notifyBranchManager(
    String orderId,
    String branchLocation,
    String message,
  ) async {
    // In a real implementation, this would find the branch manager and send a notification
    await Future.delayed(const Duration(milliseconds: 300));

    print(
        'Branch manager at $branchLocation notified about order $orderId: $message');
  }

  /// Notifies multiple users about a new discussion message
  Future<void> notifyDiscussionParticipants(
    String orderId,
    List<String> participantIds,
    String message,
  ) async {
    // In a real implementation, this would send notifications to all participants
    await Future.delayed(const Duration(milliseconds: 300));

    print(
        'Discussion notification sent for order $orderId to ${participantIds.join(', ')}: $message');
  }
}

// Provider for the NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
