import '../entities/order_discussion_entity.dart';

abstract class OrderDiscussionRepository {
  /// Creates a new discussion room for an order.
  Future<OrderDiscussionEntity> createDiscussion({
    required String orderId,
    required String initialMessage,
    required List<String> participants,
  });

  /// Retrieves an existing discussion for the given order ID.
  Future<OrderDiscussionEntity?> getDiscussion(String orderId);

  /// Streams real-time updates for the discussion of the given order ID.
  Stream<OrderDiscussionEntity?> watchDiscussion(String orderId);

  /// Posts a new message to the discussion.
  Future<void> postMessage({
    required String orderId,
    required String message,
    required String authorId,
  });

  /// Closes the discussion room for the order.
  Future<void> closeDiscussion(String orderId);
}
