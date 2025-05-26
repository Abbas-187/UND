import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/inventory_analytics_service.dart';
import '../../domain/usecases/analytics/continuous_improvement_usecase.dart';
import '../../domain/usecases/analytics/customer_demand_analytics_usecase.dart';

/// Provider for demand insights
final demandInsightsProvider =
    FutureProvider<Map<String, DemandInsights>>((ref) async {
  final analyticsService = ref.watch(inventoryAnalyticsServiceProvider);
  final dashboard = await analyticsService.generateDashboard();
  return dashboard.demandInsights;
});

/// Provider for feedback loop analysis
final feedbackLoopAnalysisProvider =
    FutureProvider<FeedbackLoopAnalysis>((ref) async {
  final analyticsService = ref.watch(inventoryAnalyticsServiceProvider);
  final dashboard = await analyticsService.generateDashboard();
  return dashboard.feedbackLoopAnalysis;
});

/// Provider for complete analytics dashboard
final analyticsDashboardProvider =
    FutureProvider<InventoryAnalyticsDashboard>((ref) async {
  final analyticsService = ref.watch(inventoryAnalyticsServiceProvider);
  return await analyticsService.generateDashboard();
});
