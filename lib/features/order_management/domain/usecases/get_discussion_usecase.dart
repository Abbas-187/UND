import '../entities/order_discussion_entity.dart';
import '../repositories/order_discussion_repository.dart';

class GetDiscussionUseCase {

  GetDiscussionUseCase(this.repository);
  final OrderDiscussionRepository repository;

  Future<OrderDiscussionEntity?> execute(String orderId) async {
    return await repository.getDiscussion(orderId);
  }
}
