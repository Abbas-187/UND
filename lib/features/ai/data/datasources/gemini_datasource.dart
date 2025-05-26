import 'package:google_generative_ai/google_generative_ai.dart' as gen_ai;
import '../../domain/entities/ai_request.dart';
import '../../domain/entities/ai_response.dart';

abstract class GeminiDataSource {
  Future<gen_ai.GenerateContentResponse> generateContent(
    String prompt, {
    double? temperature,
    int? maxOutputTokens,
  });
  // Potentially other Gemini-specific methods
}

class GeminiDataSourceImpl implements GeminiDataSource {
  final gen_ai.GoogleGenerativeAI _gemini;

  GeminiDataSourceImpl({required String apiKey})
      : _gemini = gen_ai.GoogleGenerativeAI(apiKey: apiKey);

  @override
  Future<gen_ai.GenerateContentResponse> generateContent(
    String prompt, {
    double? temperature,
    int? maxOutputTokens,
  }) async {
    final model = _gemini.generativeModel(
      modelName: 'gemini-pro', // Or make configurable
      generationConfig: gen_ai.GenerationConfig(
        temperature: temperature,
        maxOutputTokens: maxOutputTokens,
      ),
    );
    return await model.generateContent([gen_ai.Content.text(prompt)]);
  }
}

// Note: The actual AIResponse mapping would happen in the GeminiAIProvider or a repository implementation.
