import '../../domain/entities/ai_response.dart';
import '../../domain/entities/ai_request.dart';
import '../../domain/entities/ai_context.dart';
import 'universal_ai_service.dart'; // Assuming a central AI service

class ReasoningService {
  final UniversalAIService _aiService;

  ReasoningService({required UniversalAIService aiService})
      : _aiService = aiService;

  /// Performs complex reasoning based on a given problem description and context.
  ///
  /// [problemDescription] A clear description of the problem to solve or question to answer.
  /// [context] An [AIContext] object providing relevant data and background information.
  /// [reasoningType] Optional: specifies the type of reasoning (e.g., "deductive", "inductive", "abductive").
  /// Returns an [AIResponse] containing the reasoning outcome and explanation.
  Future<AIResponse> performReasoning({
    required String problemDescription,
    required AIContext context,
    String? reasoningType,
  }) async {
    final request = AIRequest(
      prompt:
          'Problem: $problemDescription\nReasoning Type: ${reasoningType ?? "general"}\nPerform reasoning based on the provided context.',
      context: context,
      data: {
        'reasoning_type': reasoningType ?? 'general',
      },
      module: 'reasoning',
      action: 'perform_reasoning',
    );

    return await _aiService.processRequest(request);
  }

  /// Solves a problem given a description and relevant data.
  Future<AIResponse> solveProblem(
      String problemDescription, Map<String, dynamic> problemData) async {
    final request = AIRequest(
        prompt: 'Solve the following problem: $problemDescription',
        data: problemData,
        module: 'problem_solving',
        action: 'solve');
    return await _aiService.processRequest(request);
  }
}
