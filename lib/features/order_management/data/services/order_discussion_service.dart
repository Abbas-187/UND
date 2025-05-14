import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/order_discussion_entity.dart';
import '../services/notification_service.dart';

/// Service for managing order discussions
class OrderDiscussionService {

  OrderDiscussionService({NotificationService? notificationService})
      : _notificationService = notificationService;
  final NotificationService? _notificationService;
  final Uuid _uuid = const Uuid();

  /// Creates a new discussion room for an order
  Future<OrderDiscussionEntity> createDiscussionRoom({
    required String orderId,
    required String initialMessage,
    required List<String> participants,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final discussion = OrderDiscussionEntity(
      id: _uuid.v4(),
      orderId: orderId,
      status: DiscussionStatus.open,
      messages: [
        DiscussionMessage(
          id: _uuid.v4(),
          senderId: 'system',
          content: initialMessage,
          timestamp: DateTime.now(),
        )
      ],
    );
    if (_notificationService != null) {
      await _notificationService.notifyDiscussionParticipants(
          orderId, participants, 'New discussion created for order #$orderId');
    }
    return discussion;
  }

  /// Adds a new message to the discussion
  Future<OrderDiscussionEntity> addMessage({
    required OrderDiscussionEntity discussion,
    required String senderId,
    required String content,
  }) async {
    if (discussion.status != DiscussionStatus.open) {
      throw Exception('Cannot add messages to a closed or locked discussion');
    }
    final newMessage = DiscussionMessage(
      id: _uuid.v4(),
      senderId: senderId,
      content: content,
      timestamp: DateTime.now(),
    );
    final updated = OrderDiscussionEntity(
      id: discussion.id,
      orderId: discussion.orderId,
      status: discussion.status,
      messages: [...discussion.messages, newMessage],
      convertedToCrm: discussion.convertedToCrm,
    );
    if (_notificationService != null) {
      final others = discussion.messages
          .map((m) => m.senderId)
          .where((id) => id != senderId)
          .toList();
      if (others.isNotEmpty) {
        await _notificationService.notifyDiscussionParticipants(
            discussion.orderId,
            others,
            'New message in discussion for order #${discussion.orderId}');
      }
    }
    return updated;
  }

  /// Locks a discussion room
  Future<OrderDiscussionEntity> lockDiscussion(
      OrderDiscussionEntity discussion) async {
    final lockMsg = DiscussionMessage(
      id: _uuid.v4(),
      senderId: 'system',
      content: 'Discussion locked due to order status change.',
      timestamp: DateTime.now(),
    );
    return OrderDiscussionEntity(
      id: discussion.id,
      orderId: discussion.orderId,
      status: DiscussionStatus.locked,
      messages: [...discussion.messages, lockMsg],
      convertedToCrm: discussion.convertedToCrm,
    );
  }

  /// Closes a discussion room
  Future<OrderDiscussionEntity> closeDiscussion(
      OrderDiscussionEntity discussion) async {
    final closeMsg = DiscussionMessage(
      id: _uuid.v4(),
      senderId: 'system',
      content: 'Discussion closed.',
      timestamp: DateTime.now(),
    );
    return OrderDiscussionEntity(
      id: discussion.id,
      orderId: discussion.orderId,
      status: DiscussionStatus.closed,
      messages: [...discussion.messages, closeMsg],
      convertedToCrm: discussion.convertedToCrm,
    );
  }
}

/// Provider for OrderDiscussionService
final orderDiscussionServiceProvider = Provider<OrderDiscussionService>((ref) {
  final notify = ref.watch(notificationServiceProvider);
  return OrderDiscussionService(notificationService: notify);
});
