import '../repositories/order_discussion_repository.dart';

class PostDiscussionMessageUseCase {

  PostDiscussionMessageUseCase(this.repository);
  final OrderDiscussionRepository repository;

  Future<void> execute({
    required String orderId,
    required String message,
    required String authorId,
  }) async {
    await repository.postMessage(
      orderId: orderId,
      message: message,
      authorId: authorId,
    );
  }
}
