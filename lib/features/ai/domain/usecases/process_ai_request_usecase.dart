import '../entities/ai_request.dart';
import '../entities/ai_response.dart';
import '../repositories/ai_provider_repository.dart'; // Or a more encompassing service

class ProcessAIRequestUsecase {
  // This use case would typically interact with a higher-level service
  // that orchestrates provider selection, context enrichment, etc.
  // For now, let's assume it can directly use a repository or a simplified service.
  final AIProviderRepository
      _repository; // Placeholder for a more complex service interaction

  ProcessAIRequestUsecase(this._repository);

  Future<AIResponse> call(AIRequest request) async {
    throw UnimplementedError(
        "This use case would typically call a UniversalAIService or similar.");
  }
}
