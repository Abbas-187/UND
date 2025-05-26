import '../entities/ai_request.dart';
import '../entities/ai_response.dart';

abstract class AILearningRepository {
  Future<void> storeInteraction(AIRequest request, AIResponse response);
  Future<void> recordFeedback({
    required String
        interactionId, // Could be AIResponse.requestId or a dedicated ID
    required bool isPositive,
    String? comments,
  });
  // Potentially methods to retrieve learned patterns or update models
}
