import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/order_discussion_data_layer_providers.dart';
import '../usecases/close_discussion_usecase.dart';
import '../usecases/get_discussion_stream_usecase.dart';
import '../usecases/get_discussion_usecase.dart';
import '../usecases/post_discussion_message_usecase.dart';
// Discussion use-cases
import '../usecases/start_discussion_usecase.dart';

final startDiscussionUseCaseProvider = Provider<StartDiscussionUseCase>((ref) {
  final repo = ref.watch(orderDiscussionRepositoryProvider);
  return StartDiscussionUseCase(repo);
});

final getDiscussionUseCaseProvider = Provider<GetDiscussionUseCase>((ref) {
  final repo = ref.watch(orderDiscussionRepositoryProvider);
  return GetDiscussionUseCase(repo);
});

final postDiscussionMessageUseCaseProvider =
    Provider<PostDiscussionMessageUseCase>((ref) {
  final repo = ref.watch(orderDiscussionRepositoryProvider);
  return PostDiscussionMessageUseCase(repo);
});

final closeDiscussionUseCaseProvider = Provider<CloseDiscussionUseCase>((ref) {
  final repo = ref.watch(orderDiscussionRepositoryProvider);
  return CloseDiscussionUseCase(repo);
});

final getDiscussionStreamUseCaseProvider =
    Provider<GetDiscussionStreamUseCase>((ref) {
  final repo = ref.watch(orderDiscussionRepositoryProvider);
  return GetDiscussionStreamUseCase(repo);
});
