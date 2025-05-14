import '../repositories/order_discussion_repository.dart';

class CloseDiscussionUseCase {

  CloseDiscussionUseCase(this.repository);
  final OrderDiscussionRepository repository;

  Future<void> execute(String orderId) async {
    await repository.closeDiscussion(orderId);
  }
}
