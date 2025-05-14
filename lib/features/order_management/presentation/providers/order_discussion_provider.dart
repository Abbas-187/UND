import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/order_discussion_mapper.dart';
import '../../data/models/order_discussion_model.dart';
import '../../domain/providers/order_discussion_usecase_providers.dart';

class OrderDiscussionNotifier
    extends StateNotifier<AsyncValue<List<OrderDiscussionModel>>> {

  OrderDiscussionNotifier(this.ref) : super(const AsyncValue.loading());
  final Ref ref;
  StreamSubscription? _discussionSub;
  String? _currentOrderId;

  // Subscribe to real-time updates for a discussion
  void subscribeToDiscussion(String orderId) {
    if (_currentOrderId == orderId && _discussionSub != null) return;
    unsubscribeFromDiscussion(_currentOrderId);
    _currentOrderId = orderId;
    final usecase = ref.read(
        getDiscussionStreamUseCaseProvider); // You must implement this usecase
    _discussionSub = usecase.execute(orderId).listen((entity) {
      final list = entity != null
          ? [OrderDiscussionMapper.fromEntity(entity)]
          : <OrderDiscussionModel>[];
      state = AsyncValue.data(list);
    }, onError: (e, st) {
      state = AsyncValue.error(e, st);
    });
  }

  // Unsubscribe from real-time updates
  void unsubscribeFromDiscussion(String? orderId) {
    _discussionSub?.cancel();
    _discussionSub = null;
    _currentOrderId = null;
  }

  Future<void> fetchDiscussion(String orderId) async {
    state = const AsyncValue.loading();
    try {
      final usecase = ref.read(getDiscussionUseCaseProvider);
      final entity = await usecase.execute(orderId);
      final list = entity != null
          ? [OrderDiscussionMapper.fromEntity(entity)]
          : <OrderDiscussionModel>[];
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> postMessage(
    String orderId,
    String message,
    String authorId,
  ) async {
    try {
      final usecase = ref.read(postDiscussionMessageUseCaseProvider);
      await usecase.execute(
        orderId: orderId,
        message: message,
        authorId: authorId,
      );
      // No need to call fetchDiscussion if using real-time
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editMessage(
      String orderId, String messageId, String newContent) async {
    // Implement this method in your usecase and call it here
    // await ref.read(editDiscussionMessageUseCaseProvider).execute(...);
  }

  Future<void> deleteMessage(String orderId, String messageId) async {
    // Implement this method in your usecase and call it here
    // await ref.read(deleteDiscussionMessageUseCaseProvider).execute(...);
  }

  Future<void> closeDiscussion(String orderId) async {
    try {
      final usecase = ref.read(closeDiscussionUseCaseProvider);
      await usecase.execute(orderId);
      // No need to call fetchDiscussion if using real-time
    } catch (e) {
      rethrow;
    }
  }
}

final orderDiscussionProvider = StateNotifierProvider<OrderDiscussionNotifier,
    AsyncValue<List<OrderDiscussionModel>>>(
  (ref) => OrderDiscussionNotifier(ref),
);
