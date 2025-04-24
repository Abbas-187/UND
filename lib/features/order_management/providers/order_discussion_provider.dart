import 'package:flutter/material.dart';
import '../models/order_discussion.dart';

class OrderDiscussionProvider extends ChangeNotifier {
  List<OrderDiscussion> _discussions = [];

  List<OrderDiscussion> get discussions => _discussions;

  void setDiscussions(List<OrderDiscussion> discussions) {
    _discussions = discussions;
    notifyListeners();
  }

  void addDiscussion(OrderDiscussion discussion) {
    _discussions.add(discussion);
    notifyListeners();
  }

  void addMessage(String discussionId, DiscussionMessage message) {
    final index = _discussions.indexWhere((d) => d.id == discussionId);
    if (index != -1) {
      final discussion = _discussions[index];
      final updatedMessages = List<DiscussionMessage>.from(discussion.messages)..add(message);
      _discussions[index] = OrderDiscussion(
        id: discussion.id,
        orderId: discussion.orderId,
        participants: discussion.participants,
        messages: updatedMessages,
        createdAt: discussion.createdAt,
        closedAt: discussion.closedAt,
        status: discussion.status,
      );
      notifyListeners();
    }
  }

  void closeDiscussion(String discussionId) {
    final index = _discussions.indexWhere((d) => d.id == discussionId);
    if (index != -1) {
      final discussion = _discussions[index];
      _discussions[index] = OrderDiscussion(
        id: discussion.id,
        orderId: discussion.orderId,
        participants: discussion.participants,
        messages: discussion.messages,
        createdAt: discussion.createdAt,
        closedAt: DateTime.now(),
        status: DiscussionStatus.closed,
      );
      notifyListeners();
    }
  }
}