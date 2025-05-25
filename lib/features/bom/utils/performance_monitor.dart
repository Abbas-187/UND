import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../data/cache/bom_cache_manager.dart';
import 'memory_optimizer.dart';

/// Comprehensive performance monitoring for BOM module
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Logger _logger = Logger();
  final Map<String, PerformanceMetric> _metrics = {};
  final List<PerformanceEvent> _events = [];
  final StreamController<PerformanceAlert> _alertController =
      StreamController<PerformanceAlert>.broadcast();

  Timer? _monitoringTimer;
  bool _isMonitoring = false;

  /// Stream of performance alerts
  Stream<PerformanceAlert> get alertStream => _alertController.stream;

  /// Initialize performance monitoring
  void initialize() {
    _startMonitoring();
    _logger.i('Performance monitor initialized');
  }

  /// Dispose performance monitor
  void dispose() {
    _monitoringTimer?.cancel();
    _alertController.close();
    _logger.i('Performance monitor disposed');
  }

  /// Record performance metric
  void recordMetric(String name, double value,
      {String? unit, Map<String, dynamic>? metadata}) {
    final metric = _metrics[name] ?? PerformanceMetric(name: name, unit: unit);
    metric.addValue(value, metadata: metadata);
    _metrics[name] = metric;

    _recordEvent(PerformanceEventType.metricRecorded, name, value: value);
    _checkThresholds(metric);
  }

  /// Record operation timing
  Future<T> recordTiming<T>(
      String operationName, Future<T> Function() operation) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      stopwatch.stop();

      recordMetric(
          '${operationName}_duration', stopwatch.elapsedMilliseconds.toDouble(),
          unit: 'ms');
      recordMetric('${operationName}_success_count', 1);

      return result;
    } catch (e) {
      stopwatch.stop();
      recordMetric(
          '${operationName}_duration', stopwatch.elapsedMilliseconds.toDouble(),
          unit: 'ms');
      recordMetric('${operationName}_error_count', 1);
      rethrow;
    }
  }

  /// Get performance dashboard data
  PerformanceDashboard getDashboard() {
    final cacheManager = BomCacheManager();
    final memoryOptimizer = MemoryOptimizer();

    return PerformanceDashboard(
      metrics: Map.from(_metrics),
      recentEvents: _events.take(100).toList(),
      cacheStatistics: cacheManager.getStatistics(),
      memoryStats: _getMemoryStats(),
      systemHealth: _calculateSystemHealth(),
      recommendations: _generateRecommendations(),
      timestamp: DateTime.now(),
    );
  }

  /// Get specific metric
  PerformanceMetric? getMetric(String name) {
    return _metrics[name];
  }

  /// Get metrics by category
  Map<String, PerformanceMetric> getMetricsByCategory(String category) {
    return Map.fromEntries(
      _metrics.entries.where((entry) => entry.key.startsWith(category)),
    );
  }

  /// Clear old metrics and events
  void cleanup({Duration? olderThan}) {
    final cutoff = DateTime.now().subtract(olderThan ?? Duration(hours: 24));

    // Clean up old events
    _events.removeWhere((event) => event.timestamp.isBefore(cutoff));

    // Clean up old metric values
    for (final metric in _metrics.values) {
      metric.cleanupOldValues(cutoff);
    }

    _logger.d('Performance data cleanup completed');
  }

  /// BOM-specific performance tracking

  /// Track BOM operation performance
  Future<T> trackBomOperation<T>(
      String operation, String bomId, Future<T> Function() task) async {
    return await recordTiming('bom_${operation}_$bomId', task);
  }

  /// Track cache performance
  void trackCacheHit(String cacheKey) {
    recordMetric('cache_hit_rate', 1);
    recordMetric('cache_operations', 1);
  }

  void trackCacheMiss(String cacheKey) {
    recordMetric('cache_miss_rate', 1);
    recordMetric('cache_operations', 1);
  }

  /// Track database query performance
  Future<T> trackDatabaseQuery<T>(
      String queryName, Future<T> Function() query) async {
    return await recordTiming('db_query_$queryName', query);
  }

  /// Track API call performance
  Future<T> trackApiCall<T>(
      String endpoint, Future<T> Function() apiCall) async {
    return await recordTiming('api_call_$endpoint', apiCall);
  }

  /// Track user interaction performance
  void trackUserInteraction(String interaction, {double? duration}) {
    recordMetric('user_interaction_$interaction', duration ?? 1);
  }

  /// Private helper methods

  void _startMonitoring() {
    _isMonitoring = true;
    _monitoringTimer = Timer.periodic(Duration(seconds: 30), (_) {
      _collectSystemMetrics();
    });
  }

  void _collectSystemMetrics() {
    // Collect system-level metrics
    recordMetric(
        'system_timestamp', DateTime.now().millisecondsSinceEpoch.toDouble());

    // Memory metrics would be collected here in a real implementation
    _collectMemoryMetrics();

    // Cache metrics
    _collectCacheMetrics();

    // Performance health check
    _performHealthCheck();
  }

  void _collectMemoryMetrics() {
    // This would integrate with actual memory monitoring
    final memoryOptimizer = MemoryOptimizer();

    // Simulate memory collection
    recordMetric('memory_usage_mb', 150 + math.Random().nextDouble() * 100);
    recordMetric('memory_pressure', math.Random().nextDouble());
  }

  void _collectCacheMetrics() {
    final cacheManager = BomCacheManager();
    final stats = cacheManager.getStatistics();

    recordMetric('cache_total_entries', stats.totalEntries.toDouble());
    recordMetric('cache_active_entries', stats.activeEntries.toDouble());
    recordMetric('cache_hit_rate_percent', stats.hitRate * 100);
    recordMetric('cache_size_mb', stats.totalSizeBytes / (1024 * 1024));
  }

  void _performHealthCheck() {
    final health = _calculateSystemHealth();
    recordMetric('system_health_score', health.overallScore);

    if (health.overallScore < 0.7) {
      _triggerAlert(PerformanceAlertType.systemHealth,
          'System health score below threshold: ${health.overallScore.toStringAsFixed(2)}');
    }
  }

  SystemHealth _calculateSystemHealth() {
    final metrics = _metrics.values.toList();

    // Calculate health scores for different categories
    double memoryHealth = _calculateMemoryHealth();
    double cacheHealth = _calculateCacheHealth();
    double performanceHealth = _calculatePerformanceHealth();
    double errorHealth = _calculateErrorHealth();

    double overallScore =
        (memoryHealth + cacheHealth + performanceHealth + errorHealth) / 4;

    return SystemHealth(
      overallScore: overallScore,
      memoryHealth: memoryHealth,
      cacheHealth: cacheHealth,
      performanceHealth: performanceHealth,
      errorHealth: errorHealth,
      timestamp: DateTime.now(),
    );
  }

  double _calculateMemoryHealth() {
    final memoryUsage = getMetric('memory_usage_mb')?.currentValue ?? 0;
    final memoryPressure = getMetric('memory_pressure')?.currentValue ?? 0;

    // Health decreases as memory usage and pressure increase
    double usageScore =
        math.max(0, 1 - (memoryUsage / 500)); // Assume 500MB is max
    double pressureScore = math.max(0, 1 - memoryPressure);

    return (usageScore + pressureScore) / 2;
  }

  double _calculateCacheHealth() {
    final hitRate = getMetric('cache_hit_rate_percent')?.currentValue ?? 0;
    final cacheSize = getMetric('cache_size_mb')?.currentValue ?? 0;

    // Good hit rate and reasonable cache size indicate good health
    double hitRateScore = math.min(1, hitRate / 80); // 80% hit rate is good
    double sizeScore =
        cacheSize < 50 ? 1 : math.max(0, 1 - ((cacheSize - 50) / 50));

    return (hitRateScore + sizeScore) / 2;
  }

  double _calculatePerformanceHealth() {
    // Calculate based on average response times
    double totalScore = 0;
    int count = 0;

    for (final metric in _metrics.values) {
      if (metric.name.endsWith('_duration')) {
        double responseTime = metric.averageValue;
        double score = responseTime < 100
            ? 1
            : math.max(0, 1 - ((responseTime - 100) / 1000));
        totalScore += score;
        count++;
      }
    }

    return count > 0 ? totalScore / count : 1.0;
  }

  double _calculateErrorHealth() {
    double totalOperations = 0;
    double totalErrors = 0;

    for (final metric in _metrics.values) {
      if (metric.name.endsWith('_success_count')) {
        totalOperations += metric.totalValue;
      } else if (metric.name.endsWith('_error_count')) {
        totalErrors += metric.totalValue;
      }
    }

    if (totalOperations == 0) return 1.0;

    double errorRate = totalErrors / (totalOperations + totalErrors);
    return math.max(0, 1 - (errorRate * 10)); // 10% error rate = 0 health
  }

  MemoryStats _getMemoryStats() {
    // This would get actual memory stats
    return MemoryStats(
      usedMemoryMB: getMetric('memory_usage_mb')?.currentValue ?? 0,
      totalMemoryMB: 512,
      gcCount: 0,
      timestamp: DateTime.now(),
    );
  }

  List<String> _generateRecommendations() {
    final recommendations = <String>[];
    final health = _calculateSystemHealth();

    if (health.memoryHealth < 0.7) {
      recommendations.add(
          'Consider optimizing memory usage - current health: ${(health.memoryHealth * 100).toStringAsFixed(1)}%');
    }

    if (health.cacheHealth < 0.7) {
      recommendations.add(
          'Cache performance needs attention - consider adjusting cache strategies');
    }

    if (health.performanceHealth < 0.7) {
      recommendations
          .add('Response times are high - investigate slow operations');
    }

    if (health.errorHealth < 0.7) {
      recommendations
          .add('Error rate is elevated - check error logs and fix issues');
    }

    // Add general recommendations
    recommendations.addAll([
      'Monitor performance metrics regularly',
      'Set up automated alerts for critical thresholds',
      'Review and optimize slow database queries',
      'Consider implementing performance budgets',
    ]);

    return recommendations;
  }

  void _checkThresholds(PerformanceMetric metric) {
    // Define thresholds for different metrics
    final thresholds = {
      'memory_usage_mb': 400.0,
      'cache_hit_rate_percent': 70.0,
      'system_health_score': 0.7,
    };

    final threshold = thresholds[metric.name];
    if (threshold != null) {
      if ((metric.name == 'cache_hit_rate_percent' ||
              metric.name == 'system_health_score') &&
          metric.currentValue < threshold) {
        _triggerAlert(PerformanceAlertType.threshold,
            '${metric.name} below threshold: ${metric.currentValue} < $threshold');
      } else if (metric.name == 'memory_usage_mb' &&
          metric.currentValue > threshold) {
        _triggerAlert(PerformanceAlertType.threshold,
            '${metric.name} above threshold: ${metric.currentValue} > $threshold');
      }
    }
  }

  void _triggerAlert(PerformanceAlertType type, String message) {
    final alert = PerformanceAlert(
      type: type,
      message: message,
      timestamp: DateTime.now(),
      severity: _getAlertSeverity(type),
    );

    _alertController.add(alert);
    _logger.w('Performance alert: $message');
  }

  AlertSeverity _getAlertSeverity(PerformanceAlertType type) {
    switch (type) {
      case PerformanceAlertType.threshold:
        return AlertSeverity.warning;
      case PerformanceAlertType.systemHealth:
        return AlertSeverity.critical;
      case PerformanceAlertType.memoryPressure:
        return AlertSeverity.warning;
      case PerformanceAlertType.slowOperation:
        return AlertSeverity.info;
    }
  }

  void _recordEvent(PerformanceEventType type, String name, {double? value}) {
    final event = PerformanceEvent(
      type: type,
      name: name,
      value: value,
      timestamp: DateTime.now(),
    );

    _events.add(event);

    // Keep only recent events
    if (_events.length > 1000) {
      _events.removeRange(0, _events.length - 1000);
    }
  }
}

/// Performance metric with statistical tracking
class PerformanceMetric {
  final String name;
  final String? unit;
  final List<MetricValue> _values = [];

  PerformanceMetric({required this.name, this.unit});

  void addValue(double value, {Map<String, dynamic>? metadata}) {
    _values.add(MetricValue(
      value: value,
      timestamp: DateTime.now(),
      metadata: metadata,
    ));

    // Keep only recent values
    if (_values.length > 1000) {
      _values.removeRange(0, _values.length - 1000);
    }
  }

  double get currentValue => _values.isNotEmpty ? _values.last.value : 0;
  double get averageValue => _values.isNotEmpty
      ? _values.map((v) => v.value).reduce((a, b) => a + b) / _values.length
      : 0;
  double get maxValue =>
      _values.isNotEmpty ? _values.map((v) => v.value).reduce(math.max) : 0;
  double get minValue =>
      _values.isNotEmpty ? _values.map((v) => v.value).reduce(math.min) : 0;
  double get totalValue => _values.map((v) => v.value).fold(0, (a, b) => a + b);

  int get sampleCount => _values.length;

  List<MetricValue> getValuesInRange(DateTime start, DateTime end) {
    return _values
        .where((v) => v.timestamp.isAfter(start) && v.timestamp.isBefore(end))
        .toList();
  }

  void cleanupOldValues(DateTime cutoff) {
    _values.removeWhere((v) => v.timestamp.isBefore(cutoff));
  }
}

/// Individual metric value with timestamp
class MetricValue {
  final double value;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  MetricValue({
    required this.value,
    required this.timestamp,
    this.metadata,
  });
}

/// Performance dashboard data
class PerformanceDashboard {
  final Map<String, PerformanceMetric> metrics;
  final List<PerformanceEvent> recentEvents;
  final CacheStatistics cacheStatistics;
  final MemoryStats memoryStats;
  final SystemHealth systemHealth;
  final List<String> recommendations;
  final DateTime timestamp;

  PerformanceDashboard({
    required this.metrics,
    required this.recentEvents,
    required this.cacheStatistics,
    required this.memoryStats,
    required this.systemHealth,
    required this.recommendations,
    required this.timestamp,
  });
}

/// System health metrics
class SystemHealth {
  final double overallScore;
  final double memoryHealth;
  final double cacheHealth;
  final double performanceHealth;
  final double errorHealth;
  final DateTime timestamp;

  SystemHealth({
    required this.overallScore,
    required this.memoryHealth,
    required this.cacheHealth,
    required this.performanceHealth,
    required this.errorHealth,
    required this.timestamp,
  });

  String get healthStatus {
    if (overallScore >= 0.8) return 'Excellent';
    if (overallScore >= 0.6) return 'Good';
    if (overallScore >= 0.4) return 'Fair';
    return 'Poor';
  }
}

/// Performance event
class PerformanceEvent {
  final PerformanceEventType type;
  final String name;
  final double? value;
  final DateTime timestamp;

  PerformanceEvent({
    required this.type,
    required this.name,
    this.value,
    required this.timestamp,
  });
}

/// Performance event types
enum PerformanceEventType {
  metricRecorded,
  alertTriggered,
  thresholdExceeded,
  operationCompleted,
  errorOccurred,
}

/// Performance alert
class PerformanceAlert {
  final PerformanceAlertType type;
  final String message;
  final DateTime timestamp;
  final AlertSeverity severity;

  PerformanceAlert({
    required this.type,
    required this.message,
    required this.timestamp,
    required this.severity,
  });
}

/// Performance alert types
enum PerformanceAlertType {
  threshold,
  systemHealth,
  memoryPressure,
  slowOperation,
}

/// Alert severity levels
enum AlertSeverity {
  info,
  warning,
  critical,
}

/// Provider for performance monitor
final performanceMonitorProvider = Provider<PerformanceMonitor>((ref) {
  return PerformanceMonitor();
});
