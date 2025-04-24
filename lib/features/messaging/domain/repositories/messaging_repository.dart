import '../models/conversation.dart';
import '../models/message.dart';

abstract class MessagingRepository {
  // Message operations
  Future<void> sendMessage(Message message);
  Future<void> markMessageAsRead(String messageId);
  Future<void> deleteMessage(String messageId);
  Stream<List<Message>> getMessages(String conversationId);

  // Conversation operations
  Future<void> createConversation(Conversation conversation);
  Future<void> updateConversation(Conversation conversation);
  Future<void> deleteConversation(String conversationId);
  Stream<List<Conversation>> getConversationsForUser(String userId);
  Future<Conversation?> getConversationById(String conversationId);
  Future<Conversation?> getConversationByParticipants(
      List<String> participants);
}
