import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:und_app/features/messaging/data/repositories/firebase_messaging_repository.dart';
import 'package:und_app/features/messaging/domain/models/conversation.dart';
import 'package:und_app/features/messaging/domain/models/message.dart';
import 'package:und_app/features/messaging/domain/repositories/messaging_repository.dart';

// Repository provider
final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  return FirebaseMessagingRepository();
});

// Current conversation provider
final currentConversationIdProvider = StateProvider<String?>((ref) => null);

// Conversations stream provider
final conversationsStreamProvider =
    StreamProvider.family<List<Conversation>, String>((ref, userId) {
  final repository = ref.watch(messagingRepositoryProvider);
  return repository.getConversationsForUser(userId);
});

// Messages stream provider for a specific conversation
final messagesStreamProvider =
    StreamProvider.family<List<Message>, String>((ref, conversationId) {
  final repository = ref.watch(messagingRepositoryProvider);
  return repository.getMessages(conversationId);
});

// Conversation provider for a specific ID
final conversationProvider =
    FutureProvider.family<Conversation?, String>((ref, conversationId) {
  final repository = ref.watch(messagingRepositoryProvider);
  return repository.getConversationById(conversationId);
});

// Conversation provider by participants
final conversationByParticipantsProvider =
    FutureProvider.family<Conversation?, List<String>>((ref, participants) {
  final repository = ref.watch(messagingRepositoryProvider);
  return repository.getConversationByParticipants(participants);
});
