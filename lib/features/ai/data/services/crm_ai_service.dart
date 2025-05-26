import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'universal_ai_service.dart';
import '../../domain/entities/ai_response.dart';

class CRMAIService {
  final UniversalAIService _universalAIService;
  final String _moduleName = 'crm';

  CRMAIService(this._universalAIService);

  Future<List<String>> getCustomerSentimentInsights(
      Map<String, dynamic> customerInteractionData,
      {String? userId}) async {
    // This might involve a specific capability like sentimentAnalysis if available and preferred
    final response = await _universalAIService.analyzeWithContext(
      module: _moduleName,
      action: 'analyze_sentiment',
      data: customerInteractionData,
      userId: userId,
    );
    return response.isSuccess && response.content != null
        ? response.content!
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .toList()
        : [];
  }

  Future<List<String>> suggestCommunicationStrategies(
      Map<String, dynamic> customerProfile,
      {String? userId}) async {
    return await _universalAIService.generateRecommendations(
      module: _moduleName,
      action: 'communication_strategy',
      data: customerProfile,
      userId: userId,
    );
  }

  Future<AIResponse> generatePersonalizedEmailDraft(
      Map<String, dynamic> customerInfo, String emailGoal,
      {String? userId}) async {
    return await _universalAIService.processRequest(_universalAIService.chat(
                message:
                    "Draft an email to a customer with info: $customerInfo. Goal: $emailGoal",
                module: _moduleName,
                userId: userId)
            as AIRequest // This casting is not ideal, UniversalAIService.chat should return AIRequest or this method should construct it.
        );
  }
}

final crmAIServiceProvider = Provider<CRMAIService>((ref) {
  final universalAIService = ref.watch(universalAIServiceProvider);
  return CRMAIService(universalAIService);
});
