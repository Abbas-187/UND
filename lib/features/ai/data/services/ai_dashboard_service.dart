import 'dart:async';
import 'dart:math' as math;
import '../models/ai_dashboard_models.dart';

/// AI Dashboard Service
class AIDashboardService {
  AIDashboardService();

  /// Generate current dashboard data
  Future<DashboardData> generateDashboard() async {
    try {
      // Get provider statuses
      final providers = await _getProviderStatuses();

      // Calculate system metrics
      final metrics = await _calculateSystemMetrics();

      // Generate usage analytics
      final usageAnalytics = await _generateUsageAnalytics();

      // Get recent interactions
      final recentInteractions = await _getRecentInteractions();

      // Calculate performance indicators
      final performanceIndicators = await _calculatePerformanceIndicators();

      // Get current alerts
      final alerts = await _getCurrentAlerts();

      // Calculate trends
      final trends = await _calculateTrends();

      return DashboardData(
        providers: providers,
        metrics: metrics,
        usageAnalytics: usageAnalytics,
        recentInteractions: recentInteractions,
        performanceIndicators: performanceIndicators,
        alerts: alerts,
        trends: trends,
      );
    } catch (e) {
      print('Error generating dashboard data: $e');
      rethrow;
    }
  }

  /// Get provider statuses
  Future<List<ProviderStatus>> _getProviderStatuses() async {
    final random = math.Random();

    return [
      ProviderStatus(
        name: 'Google Gemini',
        isHealthy: true,
        healthScore: 0.92 + random.nextDouble() * 0.07,
        averageResponseTime: 300 + random.nextInt(200),
        successRate: 0.95 + random.nextDouble() * 0.04,
        lastUpdated:
            DateTime.now().subtract(Duration(minutes: random.nextInt(30))),
      ),
      ProviderStatus(
        name: 'OpenAI GPT',
        isHealthy: random.nextBool(),
        healthScore: 0.85 + random.nextDouble() * 0.1,
        averageResponseTime: 500 + random.nextInt(300),
        successRate: 0.90 + random.nextDouble() * 0.08,
        lastUpdated:
            DateTime.now().subtract(Duration(minutes: random.nextInt(30))),
      ),
      ProviderStatus(
        name: 'Local AI',
        isHealthy: random.nextBool(),
        healthScore: 0.78 + random.nextDouble() * 0.15,
        averageResponseTime: 200 + random.nextInt(150),
        successRate: 0.85 + random.nextDouble() * 0.12,
        lastUpdated:
            DateTime.now().subtract(Duration(minutes: random.nextInt(30))),
      ),
    ];
  }

  /// Calculate system metrics
  Future<SystemMetrics> _calculateSystemMetrics() async {
    final random = math.Random();

    return SystemMetrics(
      totalQueries: random.nextInt(5000) + 1000,
      systemUptime: 0.995 + random.nextDouble() * 0.004,
      cacheHitRate: 0.75 + random.nextDouble() * 0.2,
      totalCost: random.nextDouble() * 200 + 50,
    );
  }

  /// Generate usage analytics
  Future<UsageAnalytics> _generateUsageAnalytics() async {
    final random = math.Random();

    // Generate hourly usage for last 24 hours
    final hourlyUsage = List.generate(24, (index) => random.nextInt(200) + 50);

    return UsageAnalytics(
      totalQueries: hourlyUsage.reduce((a, b) => a + b),
      successRate: 0.92 + random.nextDouble() * 0.06,
      averageResponseTime: 400 + random.nextInt(200),
      hourlyUsage: hourlyUsage,
      capabilityUsage: {
        'text_generation': random.nextInt(500) + 200,
        'analysis': random.nextInt(300) + 100,
        'classification': random.nextInt(200) + 50,
        'summarization': random.nextInt(150) + 30,
      },
      moduleUsage: {
        'inventory': random.nextInt(400) + 150,
        'production': random.nextInt(300) + 100,
        'procurement': random.nextInt(250) + 80,
        'analytics': random.nextInt(150) + 40,
      },
    );
  }

  /// Get recent interactions
  Future<List<AIInteraction>> _getRecentInteractions() async {
    final interactions = <AIInteraction>[];
    final random = math.Random();
    final providers = ['Google Gemini', 'OpenAI GPT', 'Local AI'];
    final statuses = ['success', 'error', 'pending'];
    final queries = [
      'Analyze inventory levels',
      'Generate production report',
      'Classify supplier risk',
      'Summarize daily metrics',
      'Predict demand forecast',
    ];

    for (int i = 0; i < 15; i++) {
      interactions.add(AIInteraction(
        query: queries[random.nextInt(queries.length)],
        provider: providers[random.nextInt(providers.length)],
        status: statuses[random.nextInt(statuses.length)],
        responseTime: random.nextInt(2000) + 200,
        timestamp:
            DateTime.now().subtract(Duration(minutes: random.nextInt(1440))),
      ));
    }

    interactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return interactions;
  }

  /// Calculate performance indicators
  Future<List<PerformanceIndicator>> _calculatePerformanceIndicators() async {
    final random = math.Random();

    return [
      PerformanceIndicator(
        name: 'Reliability',
        score: 0.92 + random.nextDouble() * 0.07,
        unit: '%',
      ),
      PerformanceIndicator(
        name: 'Performance',
        score: 0.88 + random.nextDouble() * 0.1,
        unit: '%',
      ),
      PerformanceIndicator(
        name: 'Cost Efficiency',
        score: 0.85 + random.nextDouble() * 0.12,
        unit: '%',
      ),
      PerformanceIndicator(
        name: 'User Satisfaction',
        score: 0.90 + random.nextDouble() * 0.08,
        unit: '%',
      ),
    ];
  }

  /// Get current alerts
  Future<List<SystemAlert>> _getCurrentAlerts() async {
    final random = math.Random();
    final alerts = <SystemAlert>[];

    // Generate some sample alerts randomly
    if (random.nextDouble() > 0.7) {
      alerts.add(SystemAlert(
        message: 'High response time detected on OpenAI provider',
        severity: 'warning',
        timestamp:
            DateTime.now().subtract(Duration(minutes: random.nextInt(60))),
      ));
    }

    if (random.nextDouble() > 0.8) {
      alerts.add(SystemAlert(
        message: 'Daily cost threshold exceeded',
        severity: 'critical',
        timestamp:
            DateTime.now().subtract(Duration(minutes: random.nextInt(30))),
      ));
    }

    if (random.nextDouble() > 0.9) {
      alerts.add(SystemAlert(
        message: 'Cache hit rate below optimal threshold',
        severity: 'info',
        timestamp:
            DateTime.now().subtract(Duration(minutes: random.nextInt(120))),
      ));
    }

    return alerts;
  }

  /// Calculate trends
  Future<Map<String, double>> _calculateTrends() async {
    final random = math.Random();

    return {
      'Query Volume': (random.nextDouble() - 0.5) * 20, // ±10%
      'Response Time': (random.nextDouble() - 0.5) * 15, // ±7.5%
      'Success Rate': (random.nextDouble() - 0.5) * 10, // ±5%
      'Cost': (random.nextDouble() - 0.5) * 25, // ±12.5%
      'Provider Health': (random.nextDouble() - 0.5) * 8, // ±4%
    };
  }
}
