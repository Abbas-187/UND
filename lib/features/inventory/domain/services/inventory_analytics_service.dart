import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../usecases/analytics/inventory_turnover_usecase.dart';
import '../usecases/analytics/stockout_analysis_usecase.dart';
import '../usecases/analytics/excess_obsolete_analysis_usecase.dart'
    hide RiskLevel;
import '../usecases/analytics/customer_demand_analytics_usecase.dart';
import '../usecases/analytics/continuous_improvement_usecase.dart';
import '../repositories/inventory_repository.dart';
import '../providers/inventory_repository_provider.dart' as repo_provider;

/// Comprehensive inventory analytics dashboard data
class InventoryAnalyticsDashboard {
  const InventoryAnalyticsDashboard({
    required this.overviewMetrics,
    required this.turnoverAnalysis,
    required this.stockoutAnalysis,
    required this.excessObsoleteAnalysis,
    required this.demandInsights,
    required this.feedbackLoopAnalysis,
    required this.criticalAlerts,
    required this.performanceIndicators,
    required this.trends,
    required this.generatedAt,
  });

  final InventoryOverviewMetrics overviewMetrics;
  final TurnoverAnalysisResult turnoverAnalysis;
  final StockoutAnalysisResult stockoutAnalysis;
  final ExcessObsoleteAnalysisResult excessObsoleteAnalysis;
  final Map<String, DemandInsights>
      demandInsights; // Item ID -> Demand Insights
  final FeedbackLoopAnalysis feedbackLoopAnalysis;
  final List<CriticalAlert> criticalAlerts;
  final PerformanceIndicators performanceIndicators;
  final AnalyticsTrends trends;
  final DateTime generatedAt;
}

/// Overview metrics for the dashboard
class InventoryOverviewMetrics {
  const InventoryOverviewMetrics({
    required this.totalInventoryValue,
    required this.totalItems,
    required this.totalCategories,
    required this.averageTurnoverRate,
    required this.stockoutRate,
    required this.excessObsoletePercentage,
    required this.qualityIssuesPercentage,
    required this.lowStockItems,
    required this.criticalStockItems,
  });

  final double totalInventoryValue;
  final int totalItems;
  final int totalCategories;
  final double averageTurnoverRate;
  final double stockoutRate;
  final double excessObsoletePercentage;
  final double qualityIssuesPercentage;
  final int lowStockItems;
  final int criticalStockItems;
}

/// Critical alerts requiring immediate attention
class CriticalAlert {
  const CriticalAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.itemId,
    required this.itemName,
    required this.category,
    required this.value,
    required this.createdAt,
    this.actionRequired,
    this.dueDate,
  });

  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String title;
  final String description;
  final String itemId;
  final String itemName;
  final String category;
  final double value;
  final DateTime createdAt;
  final String? actionRequired;
  final DateTime? dueDate;
}

/// Types of critical alerts
enum AlertType {
  stockout,
  lowStock,
  excessStock,
  obsoleteStock,
  expiredStock,
  qualityIssue,
  costVariance,
  turnoverIssue,
}

/// Alert severity levels
enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

/// Key performance indicators
class PerformanceIndicators {
  const PerformanceIndicators({
    required this.inventoryAccuracy,
    required this.fillRate,
    required this.cycleCountAccuracy,
    required this.warehouseUtilization,
    required this.averageLeadTime,
    required this.supplierPerformance,
    required this.costVariance,
    required this.qualityRate,
  });

  final double inventoryAccuracy; // Percentage
  final double fillRate; // Percentage
  final double cycleCountAccuracy; // Percentage
  final double warehouseUtilization; // Percentage
  final double averageLeadTime; // Days
  final double supplierPerformance; // Percentage
  final double costVariance; // Percentage
  final double qualityRate; // Percentage
}

/// Analytics trends over time
class AnalyticsTrends {
  const AnalyticsTrends({
    required this.turnoverTrends,
    required this.stockoutTrends,
    required this.inventoryValueTrends,
    required this.excessObsoleteTrends,
    required this.qualityTrends,
  });

  final List<TrendDataPoint> turnoverTrends;
  final List<TrendDataPoint> stockoutTrends;
  final List<TrendDataPoint> inventoryValueTrends;
  final List<TrendDataPoint> excessObsoleteTrends;
  final List<TrendDataPoint> qualityTrends;
}

/// Individual trend data point
class TrendDataPoint {
  const TrendDataPoint({
    required this.date,
    required this.value,
    this.label,
  });

  final DateTime date;
  final double value;
  final String? label;
}

/// Comprehensive inventory analytics service
class InventoryAnalyticsService {
  const InventoryAnalyticsService(
    this._repository,
    this._turnoverUseCase,
    this._stockoutUseCase,
    this._excessObsoleteUseCase,
    this._customerDemandAnalyticsUseCase,
    this._continuousImprovementUseCase,
  );

  final InventoryRepository _repository;
  final InventoryTurnoverUseCase _turnoverUseCase;
  final StockoutAnalysisUseCase _stockoutUseCase;
  final ExcessObsoleteAnalysisUseCase _excessObsoleteUseCase;
  final CustomerDemandAnalyticsUseCase _customerDemandAnalyticsUseCase;
  final ContinuousImprovementUseCase _continuousImprovementUseCase;

  /// Generate comprehensive analytics dashboard
  Future<InventoryAnalyticsDashboard> generateDashboard({
    DateTime? periodStart,
    DateTime? periodEnd,
    String? categoryFilter,
  }) async {
    try {
      // Default to last 30 days if no period specified
      final endDate = periodEnd ?? DateTime.now();
      final startDate =
          periodStart ?? endDate.subtract(const Duration(days: 30));

      // Run all analytics in parallel for better performance
      final results = await Future.wait([
        _turnoverUseCase.execute(
          periodStart: startDate,
          periodEnd: endDate,
          categoryFilter: categoryFilter,
        ),
        _stockoutUseCase.execute(
          periodStart: startDate,
          periodEnd: endDate,
          categoryFilter: categoryFilter,
        ),
        _excessObsoleteUseCase.execute(
          categoryFilter: categoryFilter,
        ),
        _generateDemandInsights(startDate, endDate, categoryFilter),
        _continuousImprovementUseCase.performFeedbackLoopAnalysis(
          periodStart: startDate,
          periodEnd: endDate,
        ),
        _generateOverviewMetrics(categoryFilter),
        _generatePerformanceIndicators(startDate, endDate, categoryFilter),
        _generateTrends(startDate, endDate, categoryFilter),
      ]);

      final turnoverAnalysis = results[0] as TurnoverAnalysisResult;
      final stockoutAnalysis = results[1] as StockoutAnalysisResult;
      final excessObsoleteAnalysis = results[2] as ExcessObsoleteAnalysisResult;
      final customerDemandAnalytics = results[3] as Map<String, DemandInsights>;
      final feedbackLoopAnalysis = results[4] as FeedbackLoopAnalysis;
      final overviewMetrics = results[5] as InventoryOverviewMetrics;
      final performanceIndicators = results[6] as PerformanceIndicators;
      final trends = results[7] as AnalyticsTrends;

      // Generate critical alerts
      final criticalAlerts = await _generateCriticalAlerts(
        turnoverAnalysis,
        stockoutAnalysis,
        excessObsoleteAnalysis,
        feedbackLoopAnalysis,
      );

      return InventoryAnalyticsDashboard(
        overviewMetrics: overviewMetrics,
        turnoverAnalysis: turnoverAnalysis,
        stockoutAnalysis: stockoutAnalysis,
        excessObsoleteAnalysis: excessObsoleteAnalysis,
        demandInsights: customerDemandAnalytics,
        feedbackLoopAnalysis: feedbackLoopAnalysis,
        criticalAlerts: criticalAlerts,
        performanceIndicators: performanceIndicators,
        trends: trends,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to generate analytics dashboard: $e');
    }
  }

  /// Generate demand insights for key items
  Future<Map<String, DemandInsights>> _generateDemandInsights(
    DateTime startDate,
    DateTime endDate,
    String? categoryFilter,
  ) async {
    try {
      final items = await _repository.getItems();
      final filteredItems = categoryFilter != null
          ? items.where((item) => item.category == categoryFilter).toList()
          : items;

      // Analyze top 10 items by value for demand insights
      final topItems = filteredItems
        ..sort((a, b) => ((b.quantity * (b.cost ?? 0.0))
            .compareTo(a.quantity * (a.cost ?? 0.0))))
        ..take(10);

      final demandInsights = <String, DemandInsights>{};

      for (final item in topItems) {
        try {
          final insights =
              await _customerDemandAnalyticsUseCase.analyzeDemandForItem(
            itemId: item.id,
            periodStart: startDate,
            periodEnd: endDate,
          );
          demandInsights[item.id] = insights;
        } catch (e) {
          // Continue with other items if one fails
          print('Failed to analyze demand for item ${item.id}: $e');
        }
      }

      return demandInsights;
    } catch (e) {
      throw Exception('Failed to generate demand insights: $e');
    }
  }

  /// Generate overview metrics
  Future<InventoryOverviewMetrics> _generateOverviewMetrics(
      String? categoryFilter) async {
    try {
      final items = await _repository.getItems();
      final filteredItems = categoryFilter != null
          ? items.where((item) => item.category == categoryFilter).toList()
          : items;

      final totalInventoryValue = filteredItems.fold<double>(
          0.0, (sum, item) => sum + (item.quantity * (item.cost ?? 0.0)));

      final categories = filteredItems.map((item) => item.category).toSet();

      final lowStockItems = filteredItems
          .where((item) => item.quantity <= item.reorderPoint)
          .length;

      final criticalStockItems = filteredItems
          .where((item) => item.quantity <= item.minimumQuantity)
          .length;

      // Calculate quality issues percentage
      final qualityIssueItems = filteredItems.where((item) {
        final qualityStatus =
            item.additionalAttributes?['qualityStatus'] as String?;
        return qualityStatus != null &&
            !['AVAILABLE', 'EXCELLENT', 'GOOD', 'ACCEPTABLE']
                .contains(qualityStatus.toUpperCase());
      }).length;

      final qualityIssuesPercentage = filteredItems.isNotEmpty
          ? (qualityIssueItems / filteredItems.length) * 100
          : 0.0;

      return InventoryOverviewMetrics(
        totalInventoryValue: totalInventoryValue,
        totalItems: filteredItems.length,
        totalCategories: categories.length,
        averageTurnoverRate: 0.0, // Will be updated from turnover analysis
        stockoutRate: 0.0, // Will be updated from stockout analysis
        excessObsoletePercentage: 0.0, // Will be updated from E&O analysis
        qualityIssuesPercentage: qualityIssuesPercentage,
        lowStockItems: lowStockItems,
        criticalStockItems: criticalStockItems,
      );
    } catch (e) {
      throw Exception('Failed to generate overview metrics: $e');
    }
  }

  /// Generate performance indicators
  Future<PerformanceIndicators> _generatePerformanceIndicators(
    DateTime startDate,
    DateTime endDate,
    String? categoryFilter,
  ) async {
    try {
      // These would typically be calculated from various data sources
      // For now, providing placeholder calculations

      return const PerformanceIndicators(
        inventoryAccuracy: 98.5,
        fillRate: 94.2,
        cycleCountAccuracy: 99.1,
        warehouseUtilization: 78.3,
        averageLeadTime: 12.5,
        supplierPerformance: 91.7,
        costVariance: 2.3,
        qualityRate: 96.8,
      );
    } catch (e) {
      throw Exception('Failed to generate performance indicators: $e');
    }
  }

  /// Generate analytics trends
  Future<AnalyticsTrends> _generateTrends(
    DateTime startDate,
    DateTime endDate,
    String? categoryFilter,
  ) async {
    try {
      // Generate monthly trends for the past year
      final trendStartDate = startDate.subtract(const Duration(days: 365));
      final monthlyPeriods = <DateTime>[];

      var currentDate = trendStartDate;
      while (currentDate.isBefore(endDate)) {
        monthlyPeriods.add(currentDate);
        currentDate =
            DateTime(currentDate.year, currentDate.month + 1, currentDate.day);
      }

      // For demonstration, creating sample trend data
      // In practice, this would calculate actual historical trends
      final turnoverTrends = monthlyPeriods
          .map((date) => TrendDataPoint(
                date: date,
                value: 2.5 + (date.month * 0.1), // Sample calculation
              ))
          .toList();

      final stockoutTrends = monthlyPeriods
          .map((date) => TrendDataPoint(
                date: date,
                value: 5.0 - (date.month * 0.2), // Sample calculation
              ))
          .toList();

      final inventoryValueTrends = monthlyPeriods
          .map((date) => TrendDataPoint(
                date: date,
                value: 1000000 + (date.month * 50000), // Sample calculation
              ))
          .toList();

      final excessObsoleteTrends = monthlyPeriods
          .map((date) => TrendDataPoint(
                date: date,
                value: 8.0 + (date.month * 0.3), // Sample calculation
              ))
          .toList();

      final qualityTrends = monthlyPeriods
          .map((date) => TrendDataPoint(
                date: date,
                value: 95.0 + (date.month * 0.2), // Sample calculation
              ))
          .toList();

      return AnalyticsTrends(
        turnoverTrends: turnoverTrends,
        stockoutTrends: stockoutTrends,
        inventoryValueTrends: inventoryValueTrends,
        excessObsoleteTrends: excessObsoleteTrends,
        qualityTrends: qualityTrends,
      );
    } catch (e) {
      throw Exception('Failed to generate trends: $e');
    }
  }

  /// Generate critical alerts
  Future<List<CriticalAlert>> _generateCriticalAlerts(
    TurnoverAnalysisResult turnoverAnalysis,
    StockoutAnalysisResult stockoutAnalysis,
    ExcessObsoleteAnalysisResult excessObsoleteAnalysis,
    FeedbackLoopAnalysis feedbackLoopAnalysis,
  ) async {
    try {
      final alerts = <CriticalAlert>[];

      // Stockout alerts
      for (final stockout in stockoutAnalysis.ongoingStockouts) {
        alerts.add(CriticalAlert(
          id: 'stockout-${stockout.itemId}',
          type: AlertType.stockout,
          severity: AlertSeverity.critical,
          title: 'Ongoing Stockout',
          description:
              'Item ${stockout.itemName} has been out of stock for ${stockout.durationInDays} days',
          itemId: stockout.itemId,
          itemName: stockout.itemName,
          category: stockout.category,
          value: stockout.estimatedLostSales,
          createdAt: stockout.stockoutStart,
          actionRequired: 'Expedite procurement or find alternative supplier',
        ));
      }

      // Critical E&O alerts
      for (final item in excessObsoleteAnalysis.criticalItems.take(10)) {
        alerts.add(CriticalAlert(
          id: 'eo-${item.itemId}',
          type: _getAlertTypeFromEOClassification(item.classification),
          severity: _getAlertSeverityFromEORiskLevel(item.riskLevel),
          title: '${item.classification.label} Item',
          description:
              '${item.itemName} is ${item.classification.label.toLowerCase()} with value ${item.currentValue.toStringAsFixed(2)}',
          itemId: item.itemId,
          itemName: item.itemName,
          category: item.category,
          value: item.currentValue,
          createdAt: DateTime.now(),
          actionRequired: item.recommendedAction.description,
          dueDate: item.expiryDate,
        ));
      }

      // Low turnover alerts
      for (final item in turnoverAnalysis.bottomPerformers.take(5)) {
        if (item.turnoverClassification == TurnoverClassification.obsolete) {
          alerts.add(CriticalAlert(
            id: 'turnover-${item.itemId}',
            type: AlertType.turnoverIssue,
            severity: AlertSeverity.high,
            title: 'Poor Turnover Performance',
            description:
                '${item.itemName} has no turnover with ${item.daysOfSupply.toStringAsFixed(0)} days of supply',
            itemId: item.itemId,
            itemName: item.itemName,
            category: item.category,
            value: item.averageInventoryValue,
            createdAt: DateTime.now(),
            actionRequired: 'Review demand forecast and consider liquidation',
          ));
        }
      }

      // Critical issues from feedback loop analysis
      for (final issue in feedbackLoopAnalysis.criticalIssues) {
        alerts.add(CriticalAlert(
          id: 'feedback-${issue.issueId}',
          type: AlertType.qualityIssue,
          severity: _getAlertSeverityFromIssueSeverity(issue.severity),
          title: issue.title,
          description: issue.description,
          itemId: 'system',
          itemName: 'System Performance',
          category: 'Analytics',
          value: 0.0,
          createdAt: issue.detectedAt,
          actionRequired: issue.recommendedActions.join(', '),
        ));
      }

      // Sort alerts by severity and value
      alerts.sort((a, b) {
        final severityComparison = b.severity.index.compareTo(a.severity.index);
        if (severityComparison != 0) return severityComparison;
        return b.value.compareTo(a.value);
      });

      return alerts.take(20).toList(); // Limit to top 20 alerts
    } catch (e) {
      throw Exception('Failed to generate critical alerts: $e');
    }
  }

  /// Convert E&O classification to alert type
  AlertType _getAlertTypeFromEOClassification(EOClassification classification) {
    switch (classification) {
      case EOClassification.expired:
        return AlertType.expiredStock;
      case EOClassification.obsolete:
        return AlertType.obsoleteStock;
      case EOClassification.excess:
        return AlertType.excessStock;
      default:
        return AlertType.excessStock;
    }
  }

  /// Convert E&O risk level to alert severity
  AlertSeverity _getAlertSeverityFromEORiskLevel(dynamic riskLevel) {
    // Handle the E&O RiskLevel enum
    final riskLevelString = riskLevel.toString().split('.').last;
    switch (riskLevelString) {
      case 'critical':
        return AlertSeverity.critical;
      case 'high':
        return AlertSeverity.high;
      case 'medium':
        return AlertSeverity.medium;
      case 'low':
        return AlertSeverity.low;
      default:
        return AlertSeverity.medium;
    }
  }

  /// Convert issue severity to alert severity
  AlertSeverity _getAlertSeverityFromIssueSeverity(IssueSeverity severity) {
    switch (severity) {
      case IssueSeverity.critical:
        return AlertSeverity.critical;
      case IssueSeverity.high:
        return AlertSeverity.high;
      case IssueSeverity.medium:
        return AlertSeverity.medium;
      case IssueSeverity.low:
        return AlertSeverity.low;
    }
  }

  /// Get category performance comparison
  Future<List<CategoryPerformanceComparison>> getCategoryPerformanceComparison({
    DateTime? periodStart,
    DateTime? periodEnd,
  }) async {
    try {
      final endDate = periodEnd ?? DateTime.now();
      final startDate =
          periodStart ?? endDate.subtract(const Duration(days: 30));

      final items = await _repository.getItems();
      final categories = items.map((item) => item.category).toSet();

      final comparisons = <CategoryPerformanceComparison>[];

      for (final category in categories) {
        final turnoverResult = await _turnoverUseCase.execute(
          periodStart: startDate,
          periodEnd: endDate,
          categoryFilter: category,
        );

        final stockoutResult = await _stockoutUseCase.execute(
          periodStart: startDate,
          periodEnd: endDate,
          categoryFilter: category,
        );

        final eoResult = await _excessObsoleteUseCase.execute(
          categoryFilter: category,
        );

        comparisons.add(CategoryPerformanceComparison(
          category: category,
          turnoverRate: turnoverResult.overallTurnoverRate,
          stockoutRate: stockoutResult.overallStockoutRate,
          excessObsoletePercentage: eoResult.eoPercentage,
          totalValue: turnoverResult.totalInventoryValue,
        ));
      }

      return comparisons..sort((a, b) => b.totalValue.compareTo(a.totalValue));
    } catch (e) {
      throw Exception('Failed to get category performance comparison: $e');
    }
  }
}

/// Category performance comparison data
class CategoryPerformanceComparison {
  const CategoryPerformanceComparison({
    required this.category,
    required this.turnoverRate,
    required this.stockoutRate,
    required this.excessObsoletePercentage,
    required this.totalValue,
  });

  final String category;
  final double turnoverRate;
  final double stockoutRate;
  final double excessObsoletePercentage;
  final double totalValue;
}

/// Provider for InventoryAnalyticsService
final inventoryAnalyticsServiceProvider =
    Provider<InventoryAnalyticsService>((ref) {
  return InventoryAnalyticsService(
    ref.watch(repo_provider.inventoryRepositoryProvider),
    ref.watch(inventoryTurnoverUseCaseProvider),
    ref.watch(stockoutAnalysisUseCaseProvider),
    ref.watch(excessObsoleteAnalysisUseCaseProvider),
    ref.watch(customerDemandAnalyticsUseCaseProvider),
    ref.watch(continuousImprovementUseCaseProvider),
  );
});
