import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/order_discussion_entity.dart';

abstract class OrderDiscussionLocalDataSource {
  Future<void> cacheDiscussion(OrderDiscussionEntity discussion);
  Future<OrderDiscussionEntity?> getCachedDiscussion(String orderId);
}

class OrderDiscussionLocalDataSourceImpl
    implements OrderDiscussionLocalDataSource {

  OrderDiscussionLocalDataSourceImpl({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;
  static const _cacheKey = 'order_discussion_';

  @override
  Future<void> cacheDiscussion(OrderDiscussionEntity discussion) async {
    final data = json.encode({
      'id': discussion.id,
      'orderId': discussion.orderId,
      'status': discussion.status.index,
      'messages': discussion.messages
          .map((m) => {
                'id': m.id,
                'senderId': m.senderId,
                'content': m.content,
                'timestamp': m.timestamp.toIso8601String(),
              })
          .toList(),
      'convertedToCrm': discussion.convertedToCrm,
    });
    await sharedPreferences.setString('$_cacheKey${discussion.orderId}', data);
  }

  @override
  Future<OrderDiscussionEntity?> getCachedDiscussion(String orderId) async {
    final str = sharedPreferences.getString('$_cacheKey$orderId');
    if (str == null) return null;
    final map = json.decode(str) as Map<String, dynamic>;
    final messages = (map['messages'] as List).map((m) {
      return DiscussionMessage(
        id: m['id'] as String,
        senderId: m['senderId'] as String,
        content: m['content'] as String,
        timestamp: DateTime.parse(m['timestamp'] as String),
      );
    }).toList();
    return OrderDiscussionEntity(
      id: map['id'] as String,
      orderId: map['orderId'] as String,
      status: DiscussionStatus.values[map['status'] as int],
      messages: messages,
      convertedToCrm: map['convertedToCrm'] as bool,
    );
  }
}
