import '../../domain/entities/ai_request.dart';
import '../../domain/entities/ai_response.dart';
import '../../domain/repositories/ai_learning_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AILearningService {
  final AILearningRepository _learningRepository;

  AILearningService({required AILearningRepository learningRepository})
      : _learningRepository = learningRepository;

  Future<void> storeInteraction(AIRequest request, AIResponse response) async {
    // Add any pre-processing or validation before storing
    await _learningRepository.storeInteraction(request, response);
  }

  Future<void> recordFeedback({
    required String interactionId, // This could be response.requestId
    required bool isPositive,
    String? comments,
  }) async {
    await _learningRepository.recordFeedback(
        interactionId: interactionId,
        isPositive: isPositive,
        comments: comments);
  }
}

final aiLearningServiceProvider = Provider<AILearningService>((ref) {
  // This assumes AIRepositoryImpl implements AILearningRepository and is provided
  final learningRepository = ref.watch(
      aiRepositoryProvider); // Placeholder, use the actual repository provider
  return AILearningService(learningRepository: learningRepository);
});
