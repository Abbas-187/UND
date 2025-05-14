import '../../domain/entities/order_discussion_entity.dart';
import '../../domain/repositories/order_discussion_repository.dart';
import '../datasources/local/order_discussion_local_datasource.dart';
import '../datasources/remote/order_discussion_remote_datasource.dart';

class OrderDiscussionRepositoryImpl implements OrderDiscussionRepository {

  OrderDiscussionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  final OrderDiscussionRemoteDataSource remoteDataSource;
  final OrderDiscussionLocalDataSource localDataSource;

  @override
  Future<OrderDiscussionEntity> createDiscussion(
      {required String orderId,
      required String initialMessage,
      required List<String> participants}) async {
    final discussion = await remoteDataSource.createDiscussion(
      orderId: orderId,
      initialMessage: initialMessage,
      participants: participants,
    );
    await localDataSource.cacheDiscussion(discussion);
    return discussion;
  }

  @override
  Future<OrderDiscussionEntity?> getDiscussion(String orderId) async {
    final cached = await localDataSource.getCachedDiscussion(orderId);
    if (cached != null) return cached;
    final discussion = await remoteDataSource.getDiscussion(orderId);
    if (discussion != null) {
      await localDataSource.cacheDiscussion(discussion);
    }
    return discussion;
  }

  @override
  Future<void> postMessage(
      {required String orderId,
      required String message,
      required String authorId}) async {
    await remoteDataSource.postMessage(
      orderId: orderId,
      message: message,
      authorId: authorId,
    );
    // Optionally refresh cache
    final updated = await remoteDataSource.getDiscussion(orderId);
    if (updated != null) {
      await localDataSource.cacheDiscussion(updated);
    }
  }

  @override
  Future<void> closeDiscussion(String orderId) async {
    await remoteDataSource.closeDiscussion(orderId);
    // Update cache status
    final cached = await localDataSource.getCachedDiscussion(orderId);
    if (cached != null) {
      final closed = OrderDiscussionEntity(
        id: cached.id,
        orderId: cached.orderId,
        status: DiscussionStatus.closed,
        messages: cached.messages,
        convertedToCrm: cached.convertedToCrm,
      );
      await localDataSource.cacheDiscussion(closed);
    }
  }

  @override
  Stream<OrderDiscussionEntity?> watchDiscussion(String orderId) {
    return remoteDataSource.watchDiscussion(orderId);
  }
}
