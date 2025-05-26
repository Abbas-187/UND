import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/entities/ai_provider.dart';
import '../../domain/entities/ai_request.dart';
import '../../domain/entities/ai_response.dart';
import '../../domain/entities/ai_context.dart';
import '../../domain/entities/ai_capability.dart';
import '../services/prompt_builder_service.dart';

class ClaudeAIProvider implements AIProvider {
  final String _apiKey;
  final PromptBuilderService _promptBuilder;
  final http.Client _httpClient;
  bool _isInitialized = false;

  // Usage tracking
  int _requestCount = 0;
  double _totalCost = 0.0;
  final List<Duration> _responseTimes = [];
  final List<double> _confidenceScores = [];

  ClaudeAIProvider({
    required String apiKey,
    required PromptBuilderService promptBuilder,
    http.Client? httpClient,
  })  : _apiKey = apiKey,
        _promptBuilder = promptBuilder,
        _httpClient = httpClient ?? http.Client();

  @override
  String get name => 'Claude 3';

  @override
  String get version => '3.0';

  @override
  AICapabilitySet get capabilities => AICapabilitySet({
        AICapability.textGeneration,
        AICapability.dataAnalysis,
        AICapability.conversationalAI,
        AICapability.documentProcessing,
        AICapability.codeGeneration,
        AICapability.sentimentAnalysis,
        AICapability.patternRecognition,
        AICapability.optimization,
      });

  @override
  bool get isAvailable => _isInitialized && _apiKey.isNotEmpty;

  @override
  Map<String, dynamic> get configuration => {
        'model': 'claude-3-sonnet-20240229',
        'api_version': 'v1',
        'max_tokens': 4096,
        'temperature': 0.7,
      };

  @override
  Future<bool> initialize() async {
    try {
      // Test API connection
      final response = await _makeRequest(
        'Hello, this is a test message.',
        maxTokens: 10,
      );

      _isInitialized = response.isNotEmpty;
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
    _httpClient.close();
  }

  @override
  Future<bool> healthCheck() async {
    if (!_isInitialized) return false;

    try {
      final response = await _makeRequest('Health check', maxTokens: 5);
      return response.isNotEmpty;
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
      // Build context-aware prompt
      final prompt = _promptBuilder.buildPrompt(request);

      final responseText = await _makeRequest(
        prompt,
        maxTokens: request.maxTokens ?? 2048,
        temperature: request.temperature ?? 0.7,
      );

      stopwatch.stop();

      if (responseText.isEmpty) {
        return AIResponse.error(
          requestId: request.id,
          provider: name,
          error: 'Empty response from Claude',
          processingTime: stopwatch.elapsed,
        );
      }

      final confidence = _calculateConfidence(responseText);
      final suggestions = _extractSuggestions(responseText);

      // Update metrics
      _requestCount++;
      _responseTimes.add(stopwatch.elapsed);
      _confidenceScores.add(confidence);
      _totalCost += estimateCost(request);

      return AIResponse.success(
        requestId: request.id,
        content: responseText,
        provider: name,
        confidence: confidence,
        processingTime: stopwatch.elapsed,
        suggestions: suggestions,
        metadata: {
          'model': 'claude-3-sonnet',
          'tokens_used': _estimateTokens(responseText),
          'reasoning_quality': _assessReasoningQuality(responseText),
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

  Future<String> _makeRequest(
    String prompt, {
    int maxTokens = 1000,
    double temperature = 0.7,
  }) async {
    final url = Uri.parse('https://api.anthropic.com/v1/messages');

    final headers = {
      'Content-Type': 'application/json',
      'x-api-key': _apiKey,
      'anthropic-version': '2023-06-01',
    };

    final body = json.encode({
      'model': 'claude-3-sonnet-20240229',
      'max_tokens': maxTokens,
      'temperature': temperature,
      'messages': [
        {
          'role': 'user',
          'content': prompt,
        }
      ],
    });

    final response = await _httpClient.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['content'][0]['text'] ?? '';
    } else {
      throw Exception(
          'Claude API error: ${response.statusCode} - ${response.body}');
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

    // Claude excels at reasoning and analysis
    double score = 0.85;

    // Adjust for complexity - Claude handles complex tasks well
    final complexity = request.capability.complexityScore;
    if (complexity >= 0.8) {
      score += 0.1; // Bonus for complex tasks
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
    // Claude pricing (approximate)
    final inputTokens = _estimateTokens(request.prompt);
    final outputTokens = request.maxTokens ?? 1000;

    // $0.003 per 1K input tokens, $0.015 per 1K output tokens
    final inputCost = (inputTokens / 1000) * 0.003;
    final outputCost = (outputTokens / 1000) * 0.015;

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
      'reasoning_strength': 0.95, // Claude's strong suit
    };
  }

  double _calculateConfidence(String content) {
    double confidence = 0.85; // Base confidence for Claude

    // Longer, structured responses indicate higher confidence
    if (content.length > 500) confidence += 0.05;
    if (content.contains('\n') && content.contains(':')) confidence += 0.05;

    // Reasoning indicators
    if (content.contains('because') ||
        content.contains('therefore') ||
        content.contains('analysis')) {
      confidence += 0.05;
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
    return {
      'prediction_text': content,
      'confidence': 0.85,
      'timeframe': 'next_30_days',
      'reasoning_quality': _assessReasoningQuality(content),
    };
  }

  double _assessReasoningQuality(String content) {
    double quality = 0.7;

    // Look for reasoning indicators
    final reasoningWords = [
      'because',
      'therefore',
      'analysis',
      'evidence',
      'conclusion'
    ];
    for (final word in reasoningWords) {
      if (content.toLowerCase().contains(word)) {
        quality += 0.05;
      }
    }

    return quality.clamp(0.0, 1.0);
  }

  int _estimateTokens(String text) {
    return (text.length / 4).ceil();
  }
}
