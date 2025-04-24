import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/order_discussion.dart';
import '../services/notification_service.dart';

/// Service for managing order discussions
class OrderDiscussionService {
  final NotificationService? _notificationService;

  OrderDiscussionService({NotificationService? notificationService})
      : _notificationService = notificationService;

  /// Creates a new discussion room for an order
  Future<OrderDiscussion> createDiscussionRoom({
    required String orderId,
    required String initialMessage,
    required List<String> participants,
  }) async {
    // In a real implementation, this would create a discussion in the database
    await Future.delayed(const Duration(milliseconds: 500));

    // Create the first message (system message)
    final firstMessage = DiscussionMessage(
      senderId: 'system',
      content: initialMessage,
      timestamp: DateTime.now(),
    );

    // Create the discussion
    final discussion = OrderDiscussion(
      id: const Uuid().v4(),
      orderId: orderId,
      participants: participants,
      messages: [firstMessage],
      createdAt: DateTime.now(),
      status: DiscussionStatus.open,
    );

    // Notify participants
    if (_notificationService != null) {
      await _notificationService.notifyDiscussionParticipants(
          orderId,
          participants,
          'A new discussion has been created for Order #$orderId');
    }

    return discussion;
  }

  /// Adds a message to an existing discussion
  Future<OrderDiscussion> addMessage({
    required String discussionId,
    required String senderId,
    required String content,
    bool isTemplatedMessage = false,
    String? templateId,
  }) async {
    // In a real implementation, this would fetch the discussion first

    // For mock purposes
    final discussion = OrderDiscussion(
      id: discussionId,
      orderId: 'order_123',
      participants: ['user_1', 'user_2'],
      messages: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      status: DiscussionStatus.open,
    );

    // Check if discussion is open
    if (discussion.status != DiscussionStatus.open) {
      throw Exception('Cannot add message to a closed or locked discussion');
    }

    // Check if sender is a participant
    if (!discussion.participants.contains(senderId)) {
      throw Exception('User is not a participant in this discussion');
    }

    // Create the new message
    final newMessage = DiscussionMessage(
      senderId: senderId,
      content: content,
      timestamp: DateTime.now(),
      isTemplatedMessage: isTemplatedMessage,
      templateId: templateId,
    );

    // Add message to discussion
    final updatedDiscussion = discussion.copyWith(
      messages: [...discussion.messages, newMessage],
    );

    // In a real implementation, this would save to the database
    await Future.delayed(const Duration(milliseconds: 300));

    // Notify other participants
    if (_notificationService != null) {
      final otherParticipants =
          updatedDiscussion.participants.where((id) => id != senderId).toList();

      if (otherParticipants.isNotEmpty) {
        await _notificationService.notifyDiscussionParticipants(
            updatedDiscussion.orderId,
            otherParticipants,
            'New message in discussion for Order #${updatedDiscussion.orderId}');
      }
    }

    return updatedDiscussion;
  }

  /// Adds a system message to the discussion
  Future<OrderDiscussion> addSystemMessage({
    required String orderId,
    required String message,
  }) async {
    // In a real implementation, this would fetch the discussion by orderId

    // For mock purposes
    final discussionId = 'disc_${orderId}_123';
    final discussion = OrderDiscussion(
      id: discussionId,
      orderId: orderId,
      participants: ['user_1', 'user_2'],
      messages: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      status: DiscussionStatus.open,
    );

    // Add the system message
    final systemMessage = DiscussionMessage(
      senderId: 'system',
      content: message,
      timestamp: DateTime.now(),
    );

    // Add message to discussion
    final updatedDiscussion = discussion.copyWith(
      messages: [...discussion.messages, systemMessage],
    );

    // In a real implementation, this would save to the database
    await Future.delayed(const Duration(milliseconds: 300));

    // Notify all participants
    if (_notificationService != null) {
      await _notificationService.notifyDiscussionParticipants(
          orderId, updatedDiscussion.participants, 'System update: $message');
    }

    return updatedDiscussion;
  }

  /// Locks a discussion room (e.g., when order enters production)
  Future<OrderDiscussion> lockDiscussionRoom(String orderId) async {
    // In a real implementation, this would fetch the discussion by orderId

    // For mock purposes
    final discussionId = 'disc_${orderId}_123';
    final discussion = OrderDiscussion(
      id: discussionId,
      orderId: orderId,
      participants: ['user_1', 'user_2'],
      messages: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      status: DiscussionStatus.open,
    );

    // Add a system message about locking
    final lockMessage = DiscussionMessage(
      senderId: 'system',
      content:
          'This discussion has been locked because the order has moved to production.',
      timestamp: DateTime.now(),
    );

    // Update discussion status
    final updatedDiscussion = discussion.copyWith(
      status: DiscussionStatus.locked,
      messages: [...discussion.messages, lockMessage],
    );

    // In a real implementation, this would save to the database
    await Future.delayed(const Duration(milliseconds: 300));

    return updatedDiscussion;
  }

  /// Closes a discussion room
  Future<OrderDiscussion> closeDiscussionRoom(String discussionId) async {
    // In a real implementation, this would fetch the discussion

    // For mock purposes
    final discussion = OrderDiscussion(
      id: discussionId,
      orderId: 'order_123',
      participants: ['user_1', 'user_2'],
      messages: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      status: DiscussionStatus.open,
    );

    // Add a system message about closing
    final closeMessage = DiscussionMessage(
      senderId: 'system',
      content: 'This discussion has been closed.',
      timestamp: DateTime.now(),
    );

    // Update discussion status
    final updatedDiscussion = discussion.copyWith(
      status: DiscussionStatus.closed,
      closedAt: DateTime.now(),
      messages: [...discussion.messages, closeMessage],
    );

    // In a real implementation, this would save to the database
    await Future.delayed(const Duration(milliseconds: 300));

    return updatedDiscussion;
  }

  /// Adds a participant to a discussion
  Future<OrderDiscussion> addParticipant(
      String discussionId, String userId) async {
    // In a real implementation, this would fetch the discussion

    // For mock purposes
    final discussion = OrderDiscussion(
      id: discussionId,
      orderId: 'order_123',
      participants: ['user_1', 'user_2'],
      messages: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      status: DiscussionStatus.open,
    );

    // Check if user is already a participant
    if (discussion.participants.contains(userId)) {
      return discussion; // Already a participant, no change needed
    }

    // Add the user to participants
    final updatedDiscussion = discussion.copyWith(
      participants: [...discussion.participants, userId],
    );

    // Add a system message
    final systemMessage = DiscussionMessage(
      senderId: 'system',
      content: 'User $userId has been added to the discussion.',
      timestamp: DateTime.now(),
    );

    final finalDiscussion = updatedDiscussion.copyWith(
      messages: [...updatedDiscussion.messages, systemMessage],
    );

    // In a real implementation, this would save to the database
    await Future.delayed(const Duration(milliseconds: 300));

    return finalDiscussion;
  }

  /// Gets a list of available message templates
  Future<List<MessageTemplate>> getMessageTemplates() async {
    // In a real implementation, this would fetch templates from the database
    await Future.delayed(const Duration(milliseconds: 300));

    // Return mock templates
    return [
      MessageTemplate(
        id: 'template_1',
        title: 'Request More Information',
        content: 'Could you please provide more details about this order?',
        tags: ['inquiry'],
        isDefault: true,
      ),
      MessageTemplate(
        id: 'template_2',
        title: 'Procurement Status',
        content:
            'The materials for this order are being procured and should be available by [DATE].',
        tags: ['procurement'],
      ),
      MessageTemplate(
        id: 'template_3',
        title: 'Production Delay',
        content:
            'We are experiencing a slight delay in production. The new estimated completion date is [DATE].',
        tags: ['production', 'delay'],
      ),
      MessageTemplate(
        id: 'template_4',
        title: 'Customer Preference Confirmation',
        content:
            'We noticed this customer has specific preferences. Can we confirm if they still require [PREFERENCE]?',
        tags: ['customer'],
      ),
    ];
  }
}

// Provider for the OrderDiscussionService
final orderDiscussionServiceProvider = Provider<OrderDiscussionService>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return OrderDiscussionService(notificationService: notificationService);
});
