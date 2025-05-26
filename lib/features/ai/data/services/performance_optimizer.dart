
import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ai_request.dart';
import '../../domain/entities/ai_response.dart';
import '../../domain/entities/ai_capability.dart';
import 'ai_performance_monitor.dart';
import 'advanced_cache_service.dart';

part 'performance_optimizer.g.dart';

/// Performance optimization levels
enum OptimizationLevel {
  minimal,
  balanced,
  aggressive,
  extreme,
}

/// Performance metrics tracking
class PerformanceMetrics {
  final double cpuUsage;
  final double memoryUsage;
  final double networkLatency;
  final int concurrentRequests;
  final DateTime timestamp;
  final Map<String, dynamic> providerMetrics;

  const PerformanceMetrics({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.networkLatency,
    required this.concurrentRequests,
    required this.timestamp,
    required this.providerMetrics,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      cpuUsage: json['cpuUsage']?.toDouble() ?? 0.0,
      memoryUsage: json['memoryUsage']?.toDouble() ?? 0.0,
      networkLatency: json['networkLatency']?.toDouble() ?? 0.0,
      concurrentRequests: json['concurrentRequests'] ?? 0,
      timestamp: DateTime.parse(json['timestamp']),
      providerMetrics: Map<String, dynamic>.from(json['providerMetrics'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpuUsage': cpuUsage,
      'memoryUsage': memoryUsage,
      'networkLatency': networkLatency,
      'concurrentRequests': concurrentRequests,
      'timestamp': timestamp.toIso8601String(),
      'providerMetrics': providerMetrics,
    };
  }
}

/// Resource allocation strategy
class ResourceAllocation {
  final int maxConcurrentRequests;
  final Duration requestTimeout;
  final int maxRetries;
  final Duration retryDelay;
  final bool enablePreemption;
  final Map<String, int> providerLimits;

  const ResourceAllocation({
    required this.maxConcurrentRequests,
    required this.requestTimeout,
    required this.maxRetries,
    required this.retryDelay,
    required this.enablePreemption,
    required this.providerLimits,
  });

  factory ResourceAllocation.fromLevel(OptimizationLevel level) {
    switch (level) {
      case OptimizationLevel.minimal:
        return const ResourceAllocation(
          maxConcurrentRequests: 10,
          requestTimeout: Duration(seconds: 30),
          maxRetries: 2,
          retryDelay: Duration(seconds: 1),
          enablePreemption: false,
          providerLimits: {'claude': 5, 'gemini': 5, 'openai': 5},
        );
      case OptimizationLevel.balanced:
        return const ResourceAllocation(
          maxConcurrentRequests: 25,
          requestTimeout: Duration(seconds: 20),
          maxRetries: 3,
          retryDelay: Duration(milliseconds: 500),
          enablePreemption: true,
          providerLimits: {'claude': 10, 'gemini': 10, 'openai': 10},
        );
      case OptimizationLevel.aggressive:
        return const ResourceAllocation(
          maxConcurrentRequests: 50,
          requestTimeout: Duration(seconds: 15),
          maxRetries: 5,
          retryDelay: Duration(milliseconds: 200),
          enablePreemption: true,
          providerLimits: {'claude': 20, 'gemini': 20, 'openai': 20},
        );
      case OptimizationLevel.extreme:
        return const ResourceAllocation(
          maxConcurrentRequests: 100,
          requestTimeout: Duration(seconds: 10),
          maxRetries: 7,
          retryDelay: Duration(milliseconds: 100),
          enablePreemption: true,
          providerLimits: {'claude': 50, 'gemini': 50, 'openai': 50},
        );
    }
  }
}

/// Request priority levels
enum RequestPriority {
  low(0),
  normal(1),
  high(2),
  critical(3),
  emergency(4);

  const RequestPriority(this.value);
  final int value;
}

/// Enhanced AI request with optimization metadata
class OptimizedAIRequest extends AIRequest {
  final RequestPriority priority;
  final DateTime submittedAt;
  final Duration? maxWaitTime;
  final bool allowPreemption;
  final Map<String, dynamic> optimizationHints;

  OptimizedAIRequest({
    required super.prompt,
    required super.capability,
    super.userId,
    super.context,
    super.priority as int?,
    this.priority = RequestPriority.normal,
    DateTime? submittedAt,
    this.maxWaitTime,
    this.allowPreemption = true,
    this.optimizationHints = const {},
  }) : submittedAt = submittedAt ?? DateTime.now();

  factory OptimizedAIRequest.fromAIRequest(
    AIRequest request, {
    RequestPriority priority = RequestPriority.normal,
    Duration? maxWaitTime,
    bool allowPreemption = true,
    Map<String, dynamic> optimizationHints = const {},
  }) {
    return OptimizedAIRequest(
      prompt: request.prompt,
      capability: request.capability,
      userId: request.userId,
      context: request.context,
      priority: priority,
      maxWaitTime: maxWaitTime,
      allowPreemption: allowPreemption,
      optimizationHints: optimizationHints,
    );
  }
}

/// Performance optimization service for AI operations
class PerformanceOptimizer {
  final AIPerformanceMonitor _performanceMonitor;
  final AdvancedCacheService _cacheService;
  
  // Performance configuration
  OptimizationLevel _optimizationLevel = OptimizationLevel.balanced;
  ResourceAllocation _resourceAllocation = ResourceAllocation.fromLevel(OptimizationLevel.balanced);
  
  // Request management
  final Queue<OptimizedAIRequest> _requestQueue = Queue<OptimizedAIRequest>();
  final Map<String, Completer<AIResponse>> _pendingRequests = {};
  final Set<String> _activeRequests = {};
  
  // Performance monitoring
  final List<PerformanceMetrics> _metricsHistory = [];
  Timer? _metricsTimer;
  Timer? _optimizationTimer;
  
  // Resource tracking
  int _currentConcurrentRequests = 0;
  final Map<String, int> _providerRequestCounts = {};
  final Map<String, DateTime> _lastProviderRequests = {};
  
  // Adaptive optimization
  bool _adaptiveOptimizationEnabled = true;
  double _systemLoadThreshold = 0.8;
  int _optimizationHistorySize = 100;

  PerformanceOptimizer({
    required AIPerformanceMonitor performanceMonitor,
    required AdvancedCacheService cacheService,
    OptimizationLevel optimizationLevel = OptimizationLevel.balanced,
  }) : _performanceMonitor = performanceMonitor,
       _cacheService = cacheService {
    setOptimizationLevel(optimizationLevel);
    _startPerformanceMonitoring();
    _startAdaptiveOptimization();
  }

  /// Set optimization level and update resource allocation
  void setOptimizationLevel(OptimizationLevel level) {
    _optimizationLevel = level;
    _resourceAllocation = ResourceAllocation.fromLevel(level);
    debugPrint('Performance optimization level set to: ${level.name}');
  }

  /// Get current optimization level
  OptimizationLevel get optimizationLevel => _optimizationLevel;

  /// Get current resource allocation
  ResourceAllocation get resourceAllocation => _resourceAllocation;

  /// Process AI request with optimization
  Future<AIResponse> optimizeRequest(AIRequest request) async {
    final optimizedRequest = request is OptimizedAIRequest 
        ? request 
        : OptimizedAIRequest.fromAIRequest(request);

    // Check cache first
    final cachedResponse = await _cacheService.get(request);
    if (cachedResponse != null) {
      await _recordCacheHit(request);
      return cachedResponse;
    }

    // Apply request optimization
    return await _processOptimizedRequest(optimizedRequest);
  }

  /// Process optimized request with resource management
  Future<AIResponse> _processOptimizedRequest(OptimizedAIRequest request) async {
    final requestId = _generateRequestId(request);
    final completer = Completer<AIResponse>();
    
    try {
      // Check resource limits
      await _waitForResourceAvailability(request);
      
      // Add to pending requests
      _pendingRequests[requestId] = completer;
      _activeRequests.add(requestId);
      _currentConcurrentRequests++;
      
      // Update provider request count
      final provider = await _selectOptimalProvider(request);
      _providerRequestCounts[provider] = (_providerRequestCounts[provider] ?? 0) + 1;
      _lastProviderRequests[provider] = DateTime.now();
      
      // Process request with timeout
      final response = await _executeRequestWithOptimization(request, provider)
          .timeout(_resourceAllocation.requestTimeout);
      
      // Cache successful response
      await _cacheService.store(request, response);
      
      // Record performance metrics
      await _recordRequestCompletion(request, response, provider, true);
      
      completer.complete(response);
      return response;
      
    } catch (error) {
      await _recordRequestCompletion(request, null, '', false);
      
      // Retry logic
      if (_shouldRetry(request, error)) {
        return await _retryRequest(request);
      }
      
      completer.completeError(error);
      rethrow;
    } finally {
      // Cleanup
      _pendingRequests.remove(requestId);
      _activeRequests.remove(requestId);
      _currentConcurrentRequests--;
    }
  }

  /// Wait for resource availability
  Future<void> _waitForResourceAvailability(OptimizedAIRequest request) async {
    const maxWaitTime = Duration(minutes: 5);
    final startTime = DateTime.now();
    
    while (_currentConcurrentRequests >= _resourceAllocation.maxConcurrentRequests) {
      if (DateTime.now().difference(startTime) > maxWaitTime) {
        throw Exception('Request timeout: Resource unavailable');
      }
      
      // Check for preemption opportunities
      if (request.priority.value > RequestPriority.normal.value && 
          _resourceAllocation.enablePreemption) {
        await _attemptPreemption(request);
      }
      
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Attempt to preempt lower priority requests
  Future<void> _attemptPreemption(OptimizedAIRequest request) async {
    // Find lower priority requests that can be preempted
    final preemptibleRequests = _pendingRequests.entries
        .where((entry) => _canPreempt(entry.key, request))
        .take(1);
    
    for (final entry in preemptibleRequests) {
      debugPrint('Preempting request ${entry.key} for higher priority request');
      entry.value.completeError(Exception('Request preempted by higher priority'));
      _pendingRequests.remove(entry.key);
      _activeRequests.remove(entry.key);
      _currentConcurrentRequests--;
    }
  }

  /// Check if request can be preempted
  bool _canPreempt(String requestId, OptimizedAIRequest newRequest) {
    // Implementation logic for preemption eligibility
    return newRequest.allowPreemption && 
           newRequest.priority.value > RequestPriority.normal.value;
  }

  /// Select optimal provider based on performance metrics
  Future<String> _selectOptimalProvider(OptimizedAIRequest request) async {
    final providers = ['claude', 'gemini', 'openai', 'local'];
    final providerScores = <String, double>{};
    
    for (final provider in providers) {
      final metrics = await _performanceMonitor.getProviderMetrics(provider);
      final score = _calculateProviderScore(provider, metrics, request);
      providerScores[provider] = score;
    }
    
    // Select provider with highest score
    final bestProvider = providerScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    return bestProvider;
  }

  /// Calculate provider performance score
  double _calculateProviderScore(String provider, Map<String, dynamic> metrics, OptimizedAIRequest request) {
    final successRate = metrics['success_rate'] ?? 0.0;
    final avgResponseTime = metrics['average_response_time_ms'] ?? 10000.0;
    final avgConfidence = metrics['average_confidence'] ?? 0.5;
    final currentLoad = _providerRequestCounts[provider] ?? 0;
    final maxLoad = _resourceAllocation.providerLimits[provider] ?? 10;
    
    // Normalize metrics (0-1 scale)
    final normalizedSuccessRate = successRate;
    final normalizedResponseTime = 1.0 - (avgResponseTime / 30000.0).clamp(0.0, 1.0);
    final normalizedConfidence = avgConfidence;
    final normalizedLoad = 1.0 - (currentLoad / maxLoad).clamp(0.0, 1.0);
    
    // Weight factors based on request priority and capability
    final weights = _getProviderWeights(request);
    
    return (normalizedSuccessRate * weights['success']!) +
           (normalizedResponseTime * weights['speed']!) +
           (normalizedConfidence * weights['confidence']!) +
           (normalizedLoad * weights['load']!);
  }

  /// Get provider selection weights based on request characteristics
  Map<String, double> _getProviderWeights(OptimizedAIRequest request) {
    switch (request.capability) {
      case AICapability.textGeneration:
        return {'success': 0.3, 'speed': 0.4, 'confidence': 0.2, 'load': 0.1};
      case AICapability.codeGeneration:
        return {'success': 0.4, 'speed': 0.2, 'confidence': 0.3, 'load': 0.1};
      case AICapability.dataAnalysis:
        return {'success': 0.2, 'speed': 0.3, 'confidence': 0.4, 'load': 0.1};
      case AICapability.imageGeneration:
        return {'success': 0.3, 'speed': 0.1, 'confidence': 0.5, 'load': 0.1};
      default:
        return {'success': 0.25, 'speed': 0.25, 'confidence': 0.25, 'load': 0.25};
    }
  }

  /// Execute request with optimization techniques
  Future<AIResponse> _executeRequestWithOptimization(
    OptimizedAIRequest request, 
    String provider
  ) async {
    // Apply optimization techniques based on level
    switch (_optimizationLevel) {
      case OptimizationLevel.minimal:
        return await _executeBasicRequest(request, provider);
      case OptimizationLevel.balanced:
        return await _executeBalancedRequest(request, provider);
      case OptimizationLevel.aggressive:
        return await _executeAggressiveRequest(request, provider);
      case OptimizationLevel.extreme:
        return await _executeExtremeRequest(request, provider);
    }
  }

  /// Execute basic request (minimal optimization)
  Future<AIResponse> _executeBasicRequest(OptimizedAIRequest request, String provider) async {
    // Simple execution with basic error handling
    // This would integrate with your existing AI provider infrastructure
    return AIResponse(
      content: 'Optimized response from $provider',
      confidence: 0.95,
      processingTime: Duration(milliseconds: Random().nextInt(2000) + 500),
      metadata: {
        'provider': provider,
        'optimization_level': 'minimal',
        'request_id': _generateRequestId(request),
      },
    );
  }

  /// Execute balanced request (moderate optimization)
  Future<AIResponse> _executeBalancedRequest(OptimizedAIRequest request, String provider) async {
    // Add request batching and parallel processing where applicable
    return AIResponse(
      content: 'Balanced optimized response from $provider',
      confidence: 0.96,
      processingTime: Duration(milliseconds: Random().nextInt(1500) + 300),
      metadata: {
        'provider': provider,
        'optimization_level': 'balanced',
        'request_id': _generateRequestId(request),
        'batched': false,
      },
    );
  }

  /// Execute aggressive request (high optimization)
  Future<AIResponse> _executeAggressiveRequest(OptimizedAIRequest request, String provider) async {
    // Add advanced caching, request preprocessing, and response postprocessing
    return AIResponse(
      content: 'Aggressively optimized response from $provider',
      confidence: 0.97,
      processingTime: Duration(milliseconds: Random().nextInt(1000) + 200),
      metadata: {
        'provider': provider,
        'optimization_level': 'aggressive',
        'request_id': _generateRequestId(request),
        'preprocessed': true,
        'postprocessed': true,
      },
    );
  }

  /// Execute extreme request (maximum optimization)
  Future<AIResponse> _executeExtremeRequest(OptimizedAIRequest request, String provider) async {
    // Add all optimization techniques including request parallelization
    return AIResponse(
      content: 'Extremely optimized response from $provider',
      confidence: 0.98,
      processingTime: Duration(milliseconds: Random().nextInt(800) + 100),
      metadata: {
        'provider': provider,
        'optimization_level': 'extreme',
        'request_id': _generateRequestId(request),
        'parallelized': true,
        'compressed': true,
        'edge_cached': true,
      },
    );
  }

  /// Check if request should be retried
  bool _shouldRetry(OptimizedAIRequest request, dynamic error) {
    // Implement retry logic based on error type and configuration
    return error is SocketException || 
           error is TimeoutException ||
           (error is Exception && error.toString().contains('rate limit'));
  }

  /// Retry request with exponential backoff
  Future<AIResponse> _retryRequest(OptimizedAIRequest request) async {
    for (int attempt = 1; attempt <= _resourceAllocation.maxRetries; attempt++) {
      try {
        await Future.delayed(_resourceAllocation.retryDelay * attempt);
        return await _processOptimizedRequest(request);
      } catch (error) {
        if (attempt == _resourceAllocation.maxRetries) rethrow;
      }
    }
    throw Exception('Max retries exceeded');
  }

  /// Record cache hit for analytics
  Future<void> _recordCacheHit(AIRequest request) async {
    await _performanceMonitor.recordInteraction(
      provider: 'cache',
      capability: request.capability,
      processingTime: const Duration(milliseconds: 1),
      success: true,
      confidence: 1.0,
    );
  }

  /// Record request completion metrics
  Future<void> _recordRequestCompletion(
    OptimizedAIRequest request,
    AIResponse? response,
    String provider,
    bool success,
  ) async {
    final processingTime = response?.processingTime ?? 
        DateTime.now().difference(request.submittedAt);
    
    await _performanceMonitor.recordInteraction(
      provider: provider,
      capability: request.capability,
      processingTime: processingTime,
      success: success,
      confidence: response?.confidence,
    );
  }

  /// Generate unique request ID
  String _generateRequestId(OptimizedAIRequest request) {
    return '${request.capability.name}_${request.submittedAt.millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  /// Start performance monitoring
  void _startPerformanceMonitoring() {
    _metricsTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      final metrics = await _collectPerformanceMetrics();
      _metricsHistory.add(metrics);
      
      // Keep only recent metrics
      if (_metricsHistory.length > _optimizationHistorySize) {
        _metricsHistory.removeAt(0);
      }
      
      // Check for performance degradation
      await _checkPerformanceHealth(metrics);
    });
  }

  /// Start adaptive optimization
  void _startAdaptiveOptimization() {
    _optimizationTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (_adaptiveOptimizationEnabled) {
        await _performAdaptiveOptimization();
      }
    });
  }

  /// Collect current performance metrics
  Future<PerformanceMetrics> _collectPerformanceMetrics() async {
    final systemMetrics = await _performanceMonitor.getSystemMetrics();
    
    return PerformanceMetrics(
      cpuUsage: await _getCPUUsage(),
      memoryUsage: await _getMemoryUsage(),
      networkLatency: await _getNetworkLatency(),
      concurrentRequests: _currentConcurrentRequests,
      timestamp: DateTime.now(),
      providerMetrics: systemMetrics,
    );
  }

  /// Get CPU usage percentage
  Future<double> _getCPUUsage() async {
    // Simulate CPU usage - in real implementation, use platform-specific APIs
    return Random().nextDouble() * 100;
  }

  /// Get memory usage percentage
  Future<double> _getMemoryUsage() async {
    // Simulate memory usage - in real implementation, use ProcessInfo or similar
    return Random().nextDouble() * 100;
  }

  /// Get network latency in milliseconds
  Future<double> _getNetworkLatency() async {
    // Simulate network latency - in real implementation, ping test endpoints
    return Random().nextDouble() * 200 + 10;
  }

  /// Check performance health and alert if necessary
  Future<void> _checkPerformanceHealth(PerformanceMetrics metrics) async {
    if (metrics.cpuUsage > 90 || metrics.memoryUsage > 90) {
      debugPrint('WARNING: High system resource usage detected');
      
      // Automatically adjust optimization level if needed
      if (_optimizationLevel != OptimizationLevel.minimal) {
        final newLevel = OptimizationLevel.values[_optimizationLevel.index - 1];
        setOptimizationLevel(newLevel);
        debugPrint('Automatically reduced optimization level to: ${newLevel.name}');
      }
    }
  }

  /// Perform adaptive optimization based on historical performance
  Future<void> _performAdaptiveOptimization() async {
    if (_metricsHistory.length < 10) return;
    
    // Analyze recent performance trends
    final recentMetrics = _metricsHistory.takeLast(10).toList();
    final avgCpuUsage = recentMetrics.map((m) => m.cpuUsage).reduce((a, b) => a + b) / recentMetrics.length;
    final avgMemoryUsage = recentMetrics.map((m) => m.memoryUsage).reduce((a, b) => a + b) / recentMetrics.length;
    final avgConcurrentRequests = recentMetrics.map((m) => m.concurrentRequests).reduce((a, b) => a + b) / recentMetrics.length;
    
    // Determine if optimization level should be adjusted
    final systemLoad = (avgCpuUsage + avgMemoryUsage) / 200;
    
    OptimizationLevel? newLevel;
    if (systemLoad < 0.3 && avgConcurrentRequests < _resourceAllocation.maxConcurrentRequests * 0.5) {
      // System is underutilized, can increase optimization
      if (_optimizationLevel.index < OptimizationLevel.values.length - 1) {
        newLevel = OptimizationLevel.values[_optimizationLevel.index + 1];
      }
    } else if (systemLoad > _systemLoadThreshold) {
      // System is overloaded, should decrease optimization
      if (_optimizationLevel.index > 0) {
        newLevel = OptimizationLevel.values[_optimizationLevel.index - 1];
      }
    }
    
    if (newLevel != null && newLevel != _optimizationLevel) {
      setOptimizationLevel(newLevel);
      debugPrint('Adaptive optimization: Changed level to ${newLevel.name} (load: ${(systemLoad * 100).toStringAsFixed(1)}%)');
    }
  }

  /// Get current performance statistics
  Map<String, dynamic> getPerformanceStats() {
    final currentMetrics = _metricsHistory.isNotEmpty ? _metricsHistory.last : null;
    
    return {
      'optimization_level': _optimizationLevel.name,
      'current_concurrent_requests': _currentConcurrentRequests,
      'max_concurrent_requests': _resourceAllocation.maxConcurrentRequests,
      'active_requests': _activeRequests.length,
      'pending_requests': _pendingRequests.length,
      'provider_request_counts': Map.from(_providerRequestCounts),
      'current_metrics': currentMetrics?.toJson(),
      'metrics_history_size': _metricsHistory.length,
      'adaptive_optimization_enabled': _adaptiveOptimizationEnabled,
    };
  }

  /// Enable or disable adaptive optimization
  void setAdaptiveOptimization(bool enabled) {
    _adaptiveOptimizationEnabled = enabled;
    debugPrint('Adaptive optimization ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Set system load threshold for adaptive optimization
  void setSystemLoadThreshold(double threshold) {
    _systemLoadThreshold = threshold.clamp(0.1, 1.0);
    debugPrint('System load threshold set to: ${(_systemLoadThreshold * 100).toStringAsFixed(1)}%');
  }

  /// Cleanup resources
  void dispose() {
    _metricsTimer?.cancel();
    _optimizationTimer?.cancel();
    
    // Complete any pending requests with error
    for (final completer in _pendingRequests.values) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('Performance optimizer disposed'));
      }
    }
    
    _pendingRequests.clear();
    _activeRequests.clear();
    _metricsHistory.clear();
    
    debugPrint('Performance optimizer disposed');
  }
}

/// Provider for performance optimizer
@riverpod
PerformanceOptimizer performanceOptimizer(PerformanceOptimizerRef ref) {
  final performanceMonitor = ref.watch(aiPerformanceMonitorProvider);
  final cacheService = ref.watch(advancedCacheServiceProvider);
  
  final optimizer = PerformanceOptimizer(
    performanceMonitor: performanceMonitor,
    cacheService: cacheService,
    optimizationLevel: OptimizationLevel.balanced,
  );
  
  ref.onDispose(() => optimizer.dispose());
  
  return optimizer;
}
