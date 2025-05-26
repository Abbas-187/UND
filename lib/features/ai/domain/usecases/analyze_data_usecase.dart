import '../entities/ai_response.dart';
import '../repositories/ai_provider_repository.dart';
import '../entities/ai_request.dart';
import '../entities/ai_capability.dart';
import '../entities/ai_context.dart';

class AnalyzeDataUsecase {
  final AIProviderRepository
      _repository; // Or a more specific service/repository

  AnalyzeDataUsecase(this._repository);

  Future<AIResponse> call({
    required Map<String, dynamic> data,
    String? userId,
    String module = 'general',
    String action = 'analyze_data',
  }) async {
    final context = AIContext.forModule(
        module: module, action: action, data: data, userId: userId);
    final request = AIRequest.fromContext(context)
        .copyWith(capability: AICapability.dataAnalysis);

    throw UnimplementedError(
        "This use case would typically call a service that processes the AIRequest.");
  }
}
