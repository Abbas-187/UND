import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../../utils/audit_middleware.dart';
import '../../domain/models/conversation.dart';
import '../../domain/models/message.dart';
import '../../domain/repositories/messaging_repository.dart';

class FirebaseMessagingRepository implements MessagingRepository {
  FirebaseMessagingRepository({
    FirebaseFirestore? firestore,
    AuditMiddleware? auditMiddleware,
    FirebaseMessaging? messaging,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auditMiddleware = auditMiddleware ?? AuditMiddleware(),
        _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseFirestore _firestore;
  final AuditMiddleware _auditMiddleware;
  final FirebaseMessaging _messaging;

  // Collection references
  CollectionReference get _messagesCollection =>
      _firestore.collection('messages');
  CollectionReference get _conversationsCollection =>
      _firestore.collection('conversations');

  @override
  Future<void> sendMessage(Message message) async {
    if (message.content.trim().isEmpty) {
      throw ArgumentError('Message content cannot be empty');
    }
    int retryCount = 0;
    const maxRetries = 3;
    Message msgWithStatus =
        message.copyWith(deliveryStatus: DeliveryStatus.sending);
    while (retryCount < maxRetries) {
      try {
        await _messagesCollection
            .doc(msgWithStatus.id)
            .set(msgWithStatus.toJson());
        final conversationSnapshot = await _conversationsCollection
            .where('participants', arrayContains: msgWithStatus.senderId)
            .where('participants', arrayContains: msgWithStatus.receiverId)
            .get();
        String conversationId;
        if (conversationSnapshot.docs.isEmpty) {
          final conversation = Conversation.create(
            participants: [msgWithStatus.senderId, msgWithStatus.receiverId],
            lastMessage: msgWithStatus.content,
          );
          conversationId = conversation.id;
          await _conversationsCollection
              .doc(conversationId)
              .set(conversation.toJson());
        } else {
          conversationId = conversationSnapshot.docs.first.id;
          await _conversationsCollection.doc(conversationId).update({
            'lastMessage': msgWithStatus.content,
            'lastMessageTimestamp': msgWithStatus.timestamp.toIso8601String(),
            'unreadCount': FieldValue.increment(1),
          });
        }
        await _messagesCollection.doc(msgWithStatus.id).update({
          'conversationId': conversationId,
          'deliveryStatus': DeliveryStatus.sent.name,
        });
        // Audit log
        await _auditMiddleware.logAction(
          action: 'send_message',
          module: 'messaging',
          targetId: msgWithStatus.id,
          metadata: {'conversationId': conversationId},
        );
        // Push notification
        await _sendPushNotification(msgWithStatus, conversationId);
        break;
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          await _messagesCollection.doc(msgWithStatus.id).update({
            'deliveryStatus': DeliveryStatus.failed.name,
          });
          await _auditMiddleware.logAction(
            action: 'send_message_failed',
            module: 'messaging',
            targetId: msgWithStatus.id,
            metadata: {'error': e.toString()},
          );
          rethrow;
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  Future<void> _sendPushNotification(
      Message message, String conversationId) async {
    try {
      // This is a placeholder for actual push logic; in production, use tokens from user profiles
      // In real Firebase implementation, you would use Firebase Cloud Functions or a server
      // to send messages using the Firebase Admin SDK or FCM HTTP v1 API

      // Log the attempt for auditing without actually sending (proper implementation would use FCM)
      await _auditMiddleware.logAction(
        action: 'push_notification_attempt',
        module: 'messaging',
        targetId: message.id,
        metadata: {
          'conversationId': conversationId,
          'receiverId': message.receiverId,
          'content':
              message.isEncrypted ? '[Encrypted Message]' : message.content,
        },
      );

      // Note: Firebase Messaging instance on client cannot send push notifications directly
      // This comment explains that in a real implementation, you'd need to:
      // 1. Subscribe users to topics or store their FCM tokens in Firestore
      // 2. Use a Cloud Function or backend server to send the notification
    } catch (e) {
      // Log push notification failure
      await _auditMiddleware.logAction(
        action: 'push_notification_failed',
        module: 'messaging',
        targetId: message.id,
        metadata: {'error': e.toString()},
      );
    }
  }

  @override
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _messagesCollection.doc(messageId).update({
        'isRead': true,
        'deliveryStatus': DeliveryStatus.read.name,
      });
      await _auditMiddleware.logAction(
        action: 'mark_message_read',
        module: 'messaging',
        targetId: messageId,
      );
    } catch (e) {
      await _auditMiddleware.logAction(
        action: 'mark_message_read_failed',
        module: 'messaging',
        targetId: messageId,
        metadata: {'error': e.toString()},
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      await _messagesCollection.doc(messageId).delete();
      await _auditMiddleware.logAction(
        action: 'delete_message',
        module: 'messaging',
        targetId: messageId,
      );
    } catch (e) {
      await _auditMiddleware.logAction(
        action: 'delete_message_failed',
        module: 'messaging',
        targetId: messageId,
        metadata: {'error': e.toString()},
      );
      rethrow;
    }
  }

  @override
  Stream<List<Message>> getMessages(String conversationId) {
    try {
      return _messagesCollection
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map(
                  (doc) => Message.fromJson(doc.data() as Map<String, dynamic>))
              .toList());
    } catch (e) {
      return const Stream.empty();
    }
  }

  @override
  Future<void> createConversation(Conversation conversation) async {
    await _conversationsCollection
        .doc(conversation.id)
        .set(conversation.toJson());
  }

  @override
  Future<void> updateConversation(Conversation conversation) async {
    await _conversationsCollection
        .doc(conversation.id)
        .update(conversation.toJson());
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    // Delete the conversation
    await _conversationsCollection.doc(conversationId).delete();

    // Delete all messages in the conversation
    final messagesSnapshot = await _messagesCollection
        .where('conversationId', isEqualTo: conversationId)
        .get();

    for (final doc in messagesSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Stream<List<Conversation>> getConversationsForUser(String userId) {
    return _conversationsCollection
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Conversation.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Future<Conversation?> getConversationById(String conversationId) async {
    final doc = await _conversationsCollection.doc(conversationId).get();
    if (doc.exists) {
      return Conversation.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<Conversation?> getConversationByParticipants(
      List<String> participants) async {
    // For a private conversation between exactly 2 people
    if (participants.length != 2) return null;

    final query1 = await _conversationsCollection
        .where('participants', arrayContains: participants[0])
        .get();

    for (final doc in query1.docs) {
      final conversation =
          Conversation.fromJson(doc.data() as Map<String, dynamic>);
      if (conversation.participants.contains(participants[1]) &&
          conversation.participants.length == 2) {
        return conversation;
      }
    }

    return null;
  }
}
