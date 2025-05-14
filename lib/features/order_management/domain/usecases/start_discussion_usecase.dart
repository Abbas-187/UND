import '../entities/order_discussion_entity.dart';
import '../repositories/order_discussion_repository.dart';

class StartDiscussionUseCase {

  StartDiscussionUseCase(this.repository);
  final OrderDiscussionRepository repository;

  Future<OrderDiscussionEntity> execute({
    required String orderId,
    required String initialMessage,
    required List<String> participants,
  }) {
    return repository.createDiscussion(
      orderId: orderId,
      initialMessage: initialMessage,
      participants: participants,
    );
  }
}
