import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../../domain/entities/order_discussion_entity.dart';

abstract class OrderDiscussionRemoteDataSource {
  Future<OrderDiscussionEntity> createDiscussion({
    required String orderId,
    required String initialMessage,
    required List<String> participants,
  });
  Future<OrderDiscussionEntity?> getDiscussion(String orderId);
  Future<void> postMessage({
    required String orderId,
    required String message,
    required String authorId,
  });
  Future<void> closeDiscussion(String orderId);
  Stream<OrderDiscussionEntity?> watchDiscussion(String orderId);
}

class OrderDiscussionRemoteDataSourceImpl
    implements OrderDiscussionRemoteDataSource {

  OrderDiscussionRemoteDataSourceImpl(
      {required this.client, required this.baseUrl});
  final http.Client client;
  final String baseUrl;

  @override
  Future<OrderDiscussionEntity> createDiscussion(
      {required String orderId,
      required String initialMessage,
      required List<String> participants}) async {
    final uri = Uri.parse(baseUrl);
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'orderId': orderId,
        'initialMessage': initialMessage,
        'participants': participants,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final msgs = (data['messages'] as List<dynamic>).map((m) {
        return DiscussionMessage(
          id: m['id'] as String,
          senderId: m['senderId'] as String,
          content: m['content'] as String,
          timestamp: DateTime.parse(m['timestamp'] as String),
        );
      }).toList();
      return OrderDiscussionEntity(
        id: data['id'] as String,
        orderId: data['orderId'] as String,
        status: DiscussionStatus.values[data['status'] as int],
        messages: msgs,
        convertedToCrm: data['convertedToCrm'] as bool? ?? false,
      );
    } else {
      throw Exception('Failed to create discussion: ${response.statusCode}');
    }
  }

  @override
  Future<OrderDiscussionEntity?> getDiscussion(String orderId) async {
    final uri = Uri.parse('$baseUrl/$orderId');
    final response =
        await client.get(uri, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final msgs = (data['messages'] as List<dynamic>).map((m) {
        return DiscussionMessage(
          id: m['id'] as String,
          senderId: m['senderId'] as String,
          content: m['content'] as String,
          timestamp: DateTime.parse(m['timestamp'] as String),
        );
      }).toList();
      return OrderDiscussionEntity(
        id: data['id'] as String,
        orderId: data['orderId'] as String,
        status: DiscussionStatus.values[data['status'] as int],
        messages: msgs,
        convertedToCrm: data['convertedToCrm'] as bool? ?? false,
      );
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch discussion: ${response.statusCode}');
    }
  }

  @override
  Future<void> postMessage(
      {required String orderId,
      required String message,
      required String authorId}) async {
    final uri = Uri.parse('$baseUrl/$orderId/messages');
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'message': message, 'authorId': authorId}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to post message: ${response.statusCode}');
    }
  }

  @override
  Future<void> closeDiscussion(String orderId) async {
    final uri = Uri.parse('$baseUrl/$orderId/close');
    final response =
        await client.post(uri, headers: {'Content-Type': 'application/json'});
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to close discussion: ${response.statusCode}');
    }
  }

  @override
  Stream<OrderDiscussionEntity?> watchDiscussion(String orderId) {
    return FirebaseFirestore.instance
        .collection('order_discussions')
        .doc(orderId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data()!;
      return OrderDiscussionEntity(
        id: snapshot.id,
        orderId: data['orderId'] as String,
        status: DiscussionStatus.values[data['status'] as int],
        messages: (data['messages'] as List<dynamic>)
            .map((m) => DiscussionMessage(
                  id: m['id'] as String,
                  senderId: m['senderId'] as String,
                  content: m['content'] as String,
                  timestamp: (m['timestamp'] as Timestamp).toDate(),
                ))
            .toList(),
        convertedToCrm: data['convertedToCrm'] as bool? ?? false,
      );
    });
  }
}
