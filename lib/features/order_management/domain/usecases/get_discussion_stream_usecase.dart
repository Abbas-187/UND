import '../entities/order_discussion_entity.dart';
import '../repositories/order_discussion_repository.dart';

class GetDiscussionStreamUseCase {
  GetDiscussionStreamUseCase(this.repository);
  final OrderDiscussionRepository repository;

  Stream<OrderDiscussionEntity?> execute(String orderId) {
    return repository.watchDiscussion(orderId);
  }
}
