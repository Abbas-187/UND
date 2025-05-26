import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/ai_provider.dart';
import '../../domain/entities/ai_request.dart';
import '../../domain/entities/ai_response.dart';
import '../../domain/entities/ai_context.dart';
import '../../domain/entities/ai_capability.dart';
import '../services/prompt_builder_service.dart';

class GeminiAIProvider implements AIProvider {
  final GoogleGenerativeAI _gemini;
  final PromptBuilderService _promptBuilder;
  final String _apiKey;
  bool _isInitialized = false;

  // Usage tracking
  int _requestCount = 0;
  double _totalCost = 0.0;
  final List<Duration> _responseTimes = [];
  final List<double> _confidenceScores = [];

  GeminiAIProvider({
    required String apiKey,
    required PromptBuilderService promptBuilder,
  })  : _apiKey = apiKey,
        _promptBuilder = promptBuilder,
        _gemini = GoogleGenerativeAI(apiKey: apiKey);

  @override
  String get name => 'Gemini Pro';

  @override
  String get version => '1.0';

  @override
  AICapabilitySet get capabilities => AICapabilitySet.geminiPro();

  @override
  bool get isAvailable => _isInitialized && _apiKey.isNotEmpty;

  @override
  Map<String, dynamic> get configuration => {
        'model': 'gemini-pro',
        'api_version': 'v1',
        'max_tokens': 4096,
        'temperature': 0.7,
        'top_p': 0.8,
        'top_k': 40,
      };

  @override
  Future<bool> initialize() async {
    try {
      // Test API connection
      final model = _gemini.generativeModel(modelName: 'gemini-pro');
      final testResponse = await model
          .generateContent([Content.text('Hello, this is a test message.')]);

      _isInitialized = testResponse.text != null;
      return _isInitialized;
    } catch (e) {
      _isInitialized = false;
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
    _requestCount = 0;
    _totalCost = 0.0;
    _responseTimes.clear();
    _confidenceScores.clear();
  }

  @override
  Future<bool> healthCheck() async {
    if (!_isInitialized) return false;

    try {
      final model = _gemini.generativeModel(modelName: 'gemini-pro');
      final response =
          await model.generateContent([Content.text('Health check')]);

      return response.text != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AIResponse> generateText(AIRequest request) async {
    if (!isAvailable) {
      return AIResponse.error(
        requestId: request.id,
        provider: name,
        error: 'Provider not available',
      );
    }

    final stopwatch = Stopwatch()..start();

    try {
      final model = _gemini.generativeModel(
        modelName: 'gemini-pro',
        generationConfig: GenerationConfig(
          temperature: request.temperature ?? 0.7,
          topK: 40,
          topP: 0.8,
          maxOutputTokens: request.maxTokens ?? 2048,
        ),
      );

      // Build context-aware prompt
      final prompt = _promptBuilder.buildPrompt(request);

      final response = await model.generateContent([Content.text(prompt)]);

      stopwatch.stop();

      if (response.text == null) {
        return AIResponse.error(
          requestId: request.id,
          provider: name,
          error: 'Empty response from Gemini',
          processingTime: stopwatch.elapsed,
        );
      }

      final confidence = _calculateConfidence(response);
      final suggestions = _extractSuggestions(response.text!);

      // Update metrics
      _requestCount++;
      _responseTimes.add(stopwatch.elapsed);
      _confidenceScores.add(confidence);
      _totalCost += estimateCost(request);

      return AIResponse.success(
        requestId: request.id,
        content: response.text!,
        provider: name,
        confidence: confidence,
        processingTime: stopwatch.elapsed,
        suggestions: suggestions,
        metadata: {
          'model': 'gemini-pro',
          'tokens_used': _estimateTokens(response.text!),
          'safety_ratings': response.candidates?.first.safetyRatings
              ?.map((rating) => {
                    'category': rating.category.name,
                    'probability': rating.probability.name,
                  })
              .toList(),
        },
      );
    } catch (e) {
      stopwatch.stop();

      return AIResponse.error(
        requestId: request.id,
        provider: name,
        error: e.toString(),
        processingTime: stopwatch.elapsed,
      );
    }
  }

  @override
  Future<AIResponse> analyzeData(Map<String, dynamic> data) async {
    final context = AIContext.fromData(data);
    return await generateInsights(context);
  }

  @override
  Future<AIResponse> generateInsights(AIContext context) async {
    final request = AIRequest.fromContext(context);
    return await generateText(request);
  }

  @override
  Future<List<String>> generateRecommendations(AIContext context) async {
    final request = AIRequest.fromContext(context).copyWith(
      prompt: _promptBuilder.buildRecommendationPrompt(context),
    );

    final response = await generateText(request);

    if (response.isSuccess) {
      return _parseRecommendations(response.content);
    }

    return [];
  }

  @override
  Future<Map<String, dynamic>> predictTrends(AIContext context) async {
    final request = AIRequest.fromContext(context).copyWith(
      prompt: _promptBuilder.buildPredictionPrompt(context),
      capability: AICapability.predictiveAnalytics,
    );

    final response = await generateText(request);

    if (response.isSuccess) {
      return _parsePredictions(response.content);
    }

    return {};
  }

  @override
  double calculateScore(AIRequest request) {
    if (!capabilities.supports(request.capability)) return 0.0;

    // Base score based on capability match
    double score = 0.8;

    // Adjust for complexity
    final complexity = request.capability.complexityScore;
    if (complexity <= 0.8) {
      score += 0.1; // Gemini excels at medium complexity tasks
    }

    // Adjust for context richness
    if (request.context != null) {
      score += 0.05;
    }

    // Adjust for recent performance
    if (_confidenceScores.isNotEmpty) {
      final avgConfidence =
          _confidenceScores.reduce((a, b) => a + b) / _confidenceScores.length;
      score = (score + avgConfidence) / 2;
    }

    return score.clamp(0.0, 1.0);
  }

  @override
  double estimateCost(AIRequest request) {
    // Gemini Pro pricing (approximate)
    final inputTokens = _estimateTokens(request.prompt);
    final outputTokens = request.maxTokens ?? 1000;

    // $0.00025 per 1K input tokens, $0.0005 per 1K output tokens
    final inputCost = (inputTokens / 1000) * 0.00025;
    final outputCost = (outputTokens / 1000) * 0.0005;

    return inputCost + outputCost;
  }

  @override
  Map<String, dynamic> getUsageStats() {
    return {
      'total_requests': _requestCount,
      'total_cost': _totalCost,
      'average_response_time': _responseTimes.isNotEmpty
          ? _responseTimes
                  .map((d) => d.inMilliseconds)
                  .reduce((a, b) => a + b) /
              _responseTimes.length
          : 0,
      'average_confidence': _confidenceScores.isNotEmpty
          ? _confidenceScores.reduce((a, b) => a + b) / _confidenceScores.length
          : 0,
      'success_rate':
          _requestCount > 0 ? (_confidenceScores.length / _requestCount) : 0,
    };
  }

  @override
  Future<Map<String, dynamic>> getPerformanceMetrics() async {
    return {
      'provider': name,
      'availability': isAvailable,
      'total_requests': _requestCount,
      'average_response_time': _responseTimes.isNotEmpty
          ? _responseTimes
                  .map((d) => d.inMilliseconds)
                  .reduce((a, b) => a + b) /
              _responseTimes.length
          : 0,
      'average_confidence': _confidenceScores.isNotEmpty
          ? _confidenceScores.reduce((a, b) => a + b) / _confidenceScores.length
          : 0,
      'cost_efficiency': _totalCost / (_requestCount > 0 ? _requestCount : 1),
      'capabilities': capabilities.capabilities.map((c) => c.name).toList(),
    };
  }

  double _calculateConfidence(GenerateContentResponse response) {
    // Calculate confidence based on response quality indicators
    double confidence = 0.8; // Base confidence

    if (response.text != null) {
      final text = response.text!;

      // Longer responses tend to be more confident
      if (text.length > 500) confidence += 0.05;
      if (text.length > 1000) confidence += 0.05;

      // Structured responses are more confident
      if (text.contains('\n') && text.contains(':')) confidence += 0.05;

      // Specific numbers and data indicate confidence
      if (RegExp(r'\d+').hasMatch(text)) confidence += 0.05;
    }

    // Safety ratings affect confidence
    final safetyRatings = response.candidates?.first.safetyRatings;
    if (safetyRatings != null) {
      final hasHighRiskRatings = safetyRatings
          .any((rating) => rating.probability == HarmProbability.high);
      if (hasHighRiskRatings) confidence -= 0.2;
    }

    return confidence.clamp(0.0, 1.0);
  }

  List<String> _extractSuggestions(String content) {
    final suggestions = <String>[];
    final lines = content.split('\n');

    for (final line in lines) {
      if (line.trim().toLowerCase().startsWith('suggestion:') ||
          line.trim().toLowerCase().startsWith('recommend:') ||
          line.trim().toLowerCase().startsWith('consider:')) {
        suggestions.add(line.trim());
      }
    }

    return suggestions;
  }

  List<String> _parseRecommendations(String content) {
    final recommendations = <String>[];
    final lines = content.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty &&
          (trimmed.contains('recommend') ||
              trimmed.contains('suggest') ||
              trimmed.startsWith('•') ||
              trimmed.startsWith('-'))) {
        recommendations.add(trimmed);
      }
    }

    return recommendations;
  }

  Map<String, dynamic> _parsePredictions(String content) {
    // Simple prediction parsing - would be more sophisticated in practice
    return {
      'prediction_text': content,
      'confidence': 0.8,
      'timeframe': 'next_30_days',
      'factors': _extractFactors(content),
    };
  }

  List<String> _extractFactors(String content) {
    final factors = <String>[];
    final words = content.toLowerCase().split(' ');

    final keyFactors = [
      'seasonal',
      'trend',
      'demand',
      'supply',
      'price',
      'quality',
      'weather'
    ];

    for (final factor in keyFactors) {
      if (words.contains(factor)) {
        factors.add(factor);
      }
    }

    return factors;
  }

  int _estimateTokens(String text) {
    // Rough estimation: 1 token ≈ 4 characters
    return (text.length / 4).ceil();
  }
}
