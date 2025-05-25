import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/services/inventory_analytics_service.dart';
import '../presentation/analytics/dashboard_overview_view.dart';

/// Provider for the inventory analytics dashboard
final inventoryAnalyticsDashboardProvider =
    FutureProvider.family<InventoryAnalyticsDashboard, DashboardParams>(
        (ref, params) async {
  final analyticsService = ref.watch(inventoryAnalyticsServiceProvider);

  return analyticsService.generateDashboard(
    periodStart: params.periodStart,
    periodEnd: params.periodEnd,
    categoryFilter: params.categoryFilter,
  );
});

/// Provider for category performance comparison
final categoryPerformanceProvider =
    FutureProvider.family<List<CategoryPerformanceComparison>, DashboardParams>(
        (ref, params) async {
  final analyticsService = ref.watch(inventoryAnalyticsServiceProvider);

  return analyticsService.getCategoryPerformanceComparison(
    periodStart: params.periodStart,
    periodEnd: params.periodEnd,
  );
});
