import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ai_request.dart';
import '../../domain/entities/ai_response.dart';
import '../../domain/entities/ai_context.dart';
import '../../domain/entities/ai_capability.dart';
import '../../domain/entities/ai_provider.dart';
import 'ai_provider_registry.dart';
import 'ai_context_manager.dart';
import 'ai_learning_service.dart';
import 'ai_performance_monitor.dart';
import 'ai_cache_service.dart';

class UniversalAIService {
  final AIProviderRegistry _registry;
  final AIContextManager _contextManager;
  final AILearningService _learningService;
  final AIPerformanceMonitor _performanceMonitor;
  final AICacheService _cacheService;

  UniversalAIService({
    required AIProviderRegistry registry,
    required AIContextManager contextManager,
    required AILearningService learningService,
    required AIPerformanceMonitor performanceMonitor,
    required AICacheService cacheService,
  })  : _registry = registry,
        _contextManager = contextManager,
        _learningService = learningService,
        _performanceMonitor = performanceMonitor,
        _cacheService = cacheService;

  // Universal AI request processing
  Future<AIResponse> processRequest(AIRequest request) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Check cache first
      final cachedResponse = await _cacheService.get(request);
      if (cachedResponse != null) {
        return cachedResponse;
      }

      // Select optimal provider
      final provider = await _selectOptimalProvider(request);
      if (provider == null) {
        throw Exception(
            'No suitable AI provider available for ${request.capability.name}');
      }

      // Enrich request with context
      final enrichedRequest = await _enrichWithContext(request);

      // Process request
      final response = await provider.generateText(enrichedRequest);

      // Store interaction for learning
      await _learningService.storeInteraction(enrichedRequest, response);

      // Cache successful response
      if (response.isSuccess) {
        await _cacheService.store(enrichedRequest, response);
      }

      // Update performance metrics
      stopwatch.stop();
      await _performanceMonitor.recordInteraction(
        provider: provider.name,
        capability: request.capability,
        processingTime: stopwatch.elapsed,
        success: response.isSuccess,
        confidence: response.confidence,
      );

      return response;
    } catch (e) {
      stopwatch.stop();

      // Try fallback provider
      final fallbackResponse = await _handleWithFallback(request, e);
      if (fallbackResponse != null) {
        return fallbackResponse;
      }

      // Return error response
      return AIResponse.error(
        requestId: request.id,
        provider: 'system',
        error: e.toString(),
        processingTime: stopwatch.elapsed,
      );
    }
  }

  // Context-aware analysis
  Future<AIResponse> analyzeWithContext({
    required String module,
    required String action,
    required Map<String, dynamic> data,
    String? userId,
  }) async {
    final context = AIContext.forModule(
      module: module,
      action: action,
      data: data,
      userId: userId,
    );

    // Get historical context
    final historicalContext = await _contextManager.getHistoricalContext(
      module: module,
      action: action,
      userId: userId,
    );

    // Enrich context
    final enrichedContext = context.enrichWith(historicalContext);

    // Create request from context
    final request = AIRequest.fromContext(enrichedContext);

    // Process request
    return await processRequest(request);
  }

  // Generate insights for specific module
  Future<List<String>> generateInsights({
    required String module,
    required Map<String, dynamic> data,
    String? userId,
  }) async {
    final response = await analyzeWithContext(
      module: module,
      action: 'generate_insights',
      data: data,
      userId: userId,
    );

    if (response.isSuccess && response.content != null) {
      return _parseInsights(response.content!);
    }

    return [];
  }

  // Generate recommendations
  Future<List<String>> generateRecommendations({
    required String module,
    required String action,
    required Map<String, dynamic> data,
    String? userId,
  }) async {
    final response = await analyzeWithContext(
      module: module,
      action: action,
      data: data,
      userId: userId,
    );

    if (response.isSuccess && response.suggestions != null) {
      return response.suggestions!;
    }

    if (response.isSuccess && response.content != null) {
      return _parseRecommendations(response.content!);
    }
    return [];
  }

  // Predict trends
  Future<Map<String, dynamic>> predictTrends({
    required String module,
    required Map<String, dynamic> historicalData,
    required int daysAhead,
    String? userId,
  }) async {
    final response = await analyzeWithContext(
      module: module,
      action: 'predict_trends',
      data: {
        'historical_data': historicalData,
        'prediction_horizon': daysAhead,
        'analysis_type': 'trend_prediction',
      },
      userId: userId,
    );

    if (response.isSuccess && response.content != null) {
      return _parsePredictions(response.content!);
    }

    return {};
  }

  // Detect anomalies
  Future<List<Map<String, dynamic>>> detectAnomalies({
    required String module,
    required Map<String, dynamic> currentData,
    required Map<String, dynamic> baselineData,
    String? userId,
  }) async {
    final response = await analyzeWithContext(
      module: module,
      action: 'detect_anomalies',
      data: {
        'current_data': currentData,
        'baseline_data': baselineData,
        'analysis_type': 'anomaly_detection',
      },
      userId: userId,
    );

    if (response.isSuccess && response.content != null) {
      return _parseAnomalies(response.content!);
    }

    return [];
  }

  // Optimize processes
  Future<Map<String, dynamic>> optimizeProcess({
    required String module,
    required String processType,
    required Map<String, dynamic> currentState,
    required Map<String, dynamic> constraints,
    String? userId,
  }) async {
    final response = await analyzeWithContext(
      module: module,
      action: 'optimize_process',
      data: {
        'process_type': processType,
        'current_state': currentState,
        'constraints': constraints,
        'optimization_goals': _getOptimizationGoals(module, processType),
      },
      userId: userId,
    );

    if (response.isSuccess && response.content != null) {
      return _parseOptimization(response.content!);
    }

    return {};
  }

  // Simple chat interface
  Future<AIResponse> chat({
    required String message,
    required String module,
    String? userId,
    String? sessionId,
  }) async {
    final request = AIRequest.simple(
      prompt: message,
      capability: AICapability.conversationalAI,
      userId: userId,
    ).copyWith(
      sessionId: sessionId,
      context: AIContext.forModule(
        module: module,
        action: 'chat',
        data: {'message': message},
        userId: userId,
      ),
    );

    return await processRequest(request);
  }

  // Provider selection logic
  Future<AIProvider?> _selectOptimalProvider(AIRequest request) async {
    final candidates = _registry.getByCapability(request.capability);
    if (candidates.isEmpty) return null;

    // Get performance metrics for each provider
    final providerScores = <AIProvider, double>{};

    for (final provider in candidates) {
      if (!provider.isAvailable) continue;

      final metrics =
          await _performanceMonitor.getProviderMetrics(provider.name);
      final score = _calculateProviderScore(provider, request, metrics);
      providerScores[provider] = score;
    }

    if (providerScores.isEmpty) return null;

    // Return provider with highest score
    return providerScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  double _calculateProviderScore(
    AIProvider provider,
    AIRequest request,
    Map<String, dynamic> metrics,
  ) {
    final baseScore = provider.calculateScore(request);
    final performanceScore = metrics['average_confidence'] ?? 0.8;
    final speedScore = 1.0 -
        ((metrics['average_response_time_ms'] ?? 2000.0) /
            10000.0); // Assuming time in ms
    final costScore = 1.0 -
        (provider.estimateCost(request) /
            100.0); // Assuming cost is a small number, scaled

    return (baseScore * 0.4) +
        (performanceScore * 0.3) +
        (speedScore * 0.2) +
        (costScore * 0.1);
  }

  Future<AIRequest> _enrichWithContext(AIRequest request) async {
    if (request.context == null) return request;

    final historicalContext = await _contextManager.getHistoricalContext(
      module: request.context!.module,
      action: request.context!.action,
      userId: request.userId,
    );

    final enrichedContext = request.context!.enrichWith(historicalContext);

    return request.copyWith(
      context: enrichedContext,
      prompt: enrichedContext.toPrompt(),
    );
  }

  Future<AIResponse?> _handleWithFallback(
      AIRequest request, dynamic error) async {
    final fallbackProviders = _registry
        .getByCapability(request.capability)
        .where((p) => p.isAvailable)
        .toList();

    for (final provider in fallbackProviders) {
      try {
        final response = await provider.generateText(request);
        if (response.isSuccess) {
          return response;
        }
      } catch (e) {
        // Log fallback error if necessary
        continue;
      }
    }

    return null;
  }

  List<String> _parseInsights(String content) {
    // Parse AI response to extract insights
    final lines =
        content.split('\n').where((line) => line.trim().isNotEmpty).toList();

    return lines
        .where((line) =>
            line.toLowerCase().contains('insight') ||
            line.toLowerCase().contains('finding') ||
            line.toLowerCase().contains('observation'))
        .toList();
  }

  List<String> _parseRecommendations(String content) {
    // Parse AI response to extract recommendations
    final lines =
        content.split('\n').where((line) => line.trim().isNotEmpty).toList();

    return lines
        .where((line) =>
            line.toLowerCase().contains('recommend') ||
            line.toLowerCase().contains('suggest') ||
            line.toLowerCase().contains('should'))
        .toList();
  }

  Map<String, dynamic> _parsePredictions(String content) {
    // Parse AI response to extract predictions
    // This would be more sophisticated in practice
    return {
      'predictions': content,
      'confidence': 0.8, // Default confidence, could be parsed
      'timeframe': 'next_30_days', // Default, could be parsed
    };
  }

  List<Map<String, dynamic>> _parseAnomalies(String content) {
    // Parse AI response to extract anomalies
    // This would be more sophisticated in practice
    return [
      {
        'type': 'anomaly',
        'description': content,
        'severity': 'medium', // Default, could be parsed
        'confidence': 0.8, // Default, could be parsed
      }
    ];
  }

  Map<String, dynamic> _parseOptimization(String content) {
    // Parse AI response to extract optimization suggestions
    // This would be more sophisticated in practice
    return {
      'optimizations': content,
      'expected_improvement': '15%', // Default, could be parsed
      'implementation_complexity': 'medium', // Default, could be parsed
    };
  }

  Map<String, dynamic> _getOptimizationGoals(
      String module, String processType) {
    // This could be fetched from a configuration or be more dynamic
    switch (module.toLowerCase()) {
      case 'inventory':
        return {
          'minimize_stockouts': true,
          'reduce_carrying_costs': true,
          'optimize_reorder_points': true,
        };
      case 'production':
        return {
          'maximize_efficiency': true,
          'minimize_waste': true,
          'optimize_scheduling': true,
        };
      case 'procurement':
        return {
          'minimize_costs': true,
          'optimize_supplier_selection': true,
          'reduce_lead_times': true,
        };
      default:
        return {
          'general_optimization': true,
        };
    }
  }

  // Health check for all providers
  Future<Map<String, bool>> checkProviderHealth() async {
    final results = <String, bool>{};

    for (final provider in _registry.getAll()) {
      try {
        results[provider.name] = await provider.healthCheck();
      } catch (e) {
        results[provider.name] = false;
      }
    }

    return results;
  }

  // Get system performance metrics
  Future<Map<String, dynamic>> getSystemMetrics() async {
    return await _performanceMonitor.getSystemMetrics();
  }

  // Get usage statistics
  Map<String, dynamic> getUsageStats() {
    final stats = <String, dynamic>{};

    for (final provider in _registry.getAll()) {
      stats[provider.name] = provider.getUsageStats();
    }

    return stats;
  }
}

// Riverpod provider
final universalAIServiceProvider = Provider<UniversalAIService>((ref) {
  return UniversalAIService(
    registry: ref.read(aiProviderRegistryProvider),
    contextManager: ref.read(aiContextManagerProvider),
    learningService: ref.read(aiLearningServiceProvider),
    performanceMonitor: ref.read(aiPerformanceMonitorProvider),
    cacheService: ref.read(aiCacheServiceProvider),
  );
});
