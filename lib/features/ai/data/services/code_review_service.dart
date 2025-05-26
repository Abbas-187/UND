import '../../domain/entities/ai_response.dart';
import '../../domain/entities/ai_request.dart';
import 'universal_ai_service.dart'; // Assuming a central AI service

class CodeReviewService {
  final UniversalAIService _aiService;

  CodeReviewService({required UniversalAIService aiService})
      : _aiService = aiService;

  /// Reviews a given code snippet for potential issues, improvements, or bugs.
  ///
  /// [codeSnippet] The code to be reviewed.
  /// [language] The programming language of the snippet (e.g., "dart", "python").
  /// Returns an [AIResponse] containing the review feedback.
  Future<AIResponse> reviewCode(String codeSnippet, String language) async {
    final request = AIRequest(
      prompt:
          'Review the following $language code for issues and improvements:\n```$language\n$codeSnippet\n```',
      data: {
        'language': language,
        'code_length': codeSnippet.length,
      },
      module: 'code_review',
      action: 'review',
    );

    return await _aiService.processRequest(request);
  }

  /// Generates code based on a description or requirements.
  ///
  /// [description] A natural language description of the desired code.
  /// [language] The target programming language.
  /// [context] Optional: existing code or context to consider.
  /// Returns an [AIResponse] containing the generated code.
  Future<AIResponse> generateCode(String description, String language,
      {String? context}) async {
    final request = AIRequest(
      prompt:
          'Generate $language code for the following requirement: "$description". ${context != null ? "Context: $context" : ""}',
      data: {'language': language},
      module: 'code_generation',
      action: 'generate',
    );
    return await _aiService.processRequest(request);
  }
}
