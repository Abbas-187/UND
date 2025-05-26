/// Data models for AI Dashboard
class DashboardData {
  final List<ProviderStatus> providers;
  final SystemMetrics metrics;
  final UsageAnalytics usageAnalytics;
  final List<PerformanceIndicator> performanceIndicators;
  final List<AIInteraction> recentInteractions;
  final List<SystemAlert> alerts;
  final Map<String, double> trends;

  DashboardData({
    required this.providers,
    required this.metrics,
    required this.usageAnalytics,
    required this.performanceIndicators,
    required this.recentInteractions,
    required this.alerts,
    required this.trends,
  });
}

class ProviderStatus {
  final String name;
  final bool isHealthy;
  final double healthScore;
  final int averageResponseTime;
  final double successRate;
  final DateTime lastUpdated;

  ProviderStatus({
    required this.name,
    required this.isHealthy,
    required this.healthScore,
    required this.averageResponseTime,
    required this.successRate,
    required this.lastUpdated,
  });
}

class SystemMetrics {
  final int totalQueries;
  final double systemUptime;
  final double cacheHitRate;
  final double totalCost;

  SystemMetrics({
    required this.totalQueries,
    required this.systemUptime,
    required this.cacheHitRate,
    required this.totalCost,
  });
}

class UsageAnalytics {
  final int totalQueries;
  final double successRate;
  final int averageResponseTime;
  final List<int> hourlyUsage;
  final Map<String, int> capabilityUsage;
  final Map<String, int> moduleUsage;

  UsageAnalytics({
    required this.totalQueries,
    required this.successRate,
    required this.averageResponseTime,
    required this.hourlyUsage,
    required this.capabilityUsage,
    required this.moduleUsage,
  });
}

class PerformanceIndicator {
  final String name;
  final double score;
  final String unit;

  PerformanceIndicator({
    required this.name,
    required this.score,
    required this.unit,
  });
}

class AIInteraction {
  final String query;
  final String provider;
  final String status;
  final int responseTime;
  final DateTime timestamp;

  AIInteraction({
    required this.query,
    required this.provider,
    required this.status,
    required this.responseTime,
    required this.timestamp,
  });
}

class SystemAlert {
  final String message;
  final String severity;
  final DateTime timestamp;

  SystemAlert({
    required this.message,
    required this.severity,
    required this.timestamp,
  });
}
