import '../../../features/messaging/domain/models/message.dart';
import '../../messaging/domain/repositories/messaging_repository.dart';

import '../models/customer.dart';

class CrmMessagingService {

  CrmMessagingService({required this.messagingRepository});
  final MessagingRepository messagingRepository;

  Future<void> sendMessageToCustomer({
    required Customer customer,
    required String content,
  }) async {
    final message = Message.create(
      senderId: 'crm', // or current user id
      receiverId: customer.id,
      content: content,
    );
    await messagingRepository.sendMessage(message);
  }
}
