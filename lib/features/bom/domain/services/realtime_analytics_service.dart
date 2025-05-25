import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../inventory/domain/repositories/inventory_repository.dart';
import '../../../suppliers/domain/repositories/supplier_repository.dart';
import '../entities/bill_of_materials.dart';
import '../repositories/bom_repository.dart';
import '../../presentation/providers/bom_providers.dart';
import '../../../inventory/domain/providers/inventory_repository_provider.dart'
    as inventory_provider;
import '../../../suppliers/presentation/providers/supplier_provider.dart'
    as supplier_provider;

/// BOM performance metrics for real-time monitoring
class BomPerformanceMetrics {
  const BomPerformanceMetrics({
    required this.bomId,
    required this.bomCode,
    required this.bomName,
    required this.overallEfficiency,
    required this.costVariance,
    required this.qualityScore,
    required this.materialAvailability,
    required this.supplierPerformance,
    required this.leadTimePerformance,
    required this.lastUpdated,
    this.alerts = const [],
    this.trends = const {},
    this.kpis = const {},
  });

  final String bomId;
  final String bomCode;
  final String bomName;
  final double overallEfficiency;
  final double costVariance;
  final double qualityScore;
  final double materialAvailability;
  final double supplierPerformance;
  final double leadTimePerformance;
  final DateTime lastUpdated;
  final List<String> alerts;
  final Map<String, double> trends;
  final Map<String, dynamic> kpis;

  /// Get overall health score
  double get healthScore {
    return (overallEfficiency +
            (100 - costVariance.abs()) +
            qualityScore +
            materialAvailability +
            supplierPerformance +
            leadTimePerformance) /
        6;
  }

  /// Get performance status
  String get performanceStatus {
    if (healthScore >= 90) return 'Excellent';
    if (healthScore >= 80) return 'Good';
    if (healthScore >= 70) return 'Fair';
    if (healthScore >= 60) return 'Poor';
    return 'Critical';
  }
}

/// Critical alert for immediate attention
class CriticalAlert {
  const CriticalAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.bomId,
    required this.timestamp,
    required this.impactLevel,
    this.actionRequired,
    this.estimatedResolutionTime,
    this.affectedMetrics = const [],
  });

  final String id;
  final String type;
  final String severity;
  final String title;
  final String message;
  final String bomId;
  final DateTime timestamp;
  final String impactLevel;
  final String? actionRequired;
  final Duration? estimatedResolutionTime;
  final List<String> affectedMetrics;

  /// Check if alert is critical
  bool get isCritical => severity == 'critical';

  /// Get priority score for sorting
  int get priorityScore {
    switch (severity) {
      case 'critical':
        return 4;
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 0;
    }
  }
}

/// Analytics dashboard data
class AnalyticsDashboard {
  const AnalyticsDashboard({
    required this.overallMetrics,
    required this.bomMetrics,
    required this.criticalAlerts,
    required this.trends,
    required this.kpis,
    required this.generatedAt,
    this.recommendations = const [],
    this.insights = const [],
  });

  final Map<String, double> overallMetrics;
  final List<BomPerformanceMetrics> bomMetrics;
  final List<CriticalAlert> criticalAlerts;
  final Map<String, List<double>> trends;
  final Map<String, dynamic> kpis;
  final DateTime generatedAt;
  final List<String> recommendations;
  final List<String> insights;

  /// Get critical alerts count
  int get criticalAlertsCount {
    return criticalAlerts.where((alert) => alert.isCritical).length;
  }

  /// Get average performance score
  double get averagePerformanceScore {
    if (bomMetrics.isEmpty) return 0.0;
    return bomMetrics.map((m) => m.healthScore).reduce((a, b) => a + b) /
        bomMetrics.length;
  }
}

/// Real-Time Analytics Service for BOM operations
class RealtimeAnalyticsService {
  RealtimeAnalyticsService({
    required this.bomRepository,
    required this.inventoryRepository,
    required this.supplierRepository,
    required this.logger,
  });

  final BomRepository bomRepository;
  final InventoryRepository inventoryRepository;
  final SupplierRepository supplierRepository;
  final Logger logger;

  // Stream controllers for real-time data
  final _performanceController =
      StreamController<BomPerformanceMetrics>.broadcast();
  final _alertsController = StreamController<List<CriticalAlert>>.broadcast();
  final _dashboardController = StreamController<AnalyticsDashboard>.broadcast();

  Timer? _metricsTimer;
  Timer? _alertsTimer;

  /// Initialize real-time monitoring
  void initialize() {
    logger.i('Initializing real-time analytics service');

    // Start periodic updates
    _metricsTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updatePerformanceMetrics();
    });

    _alertsTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateCriticalAlerts();
    });

    // Initial data load
    _updatePerformanceMetrics();
    _updateCriticalAlerts();
    _updateDashboard();
  }

  /// Dispose resources
  void dispose() {
    logger.i('Disposing real-time analytics service');
    _metricsTimer?.cancel();
    _alertsTimer?.cancel();
    _performanceController.close();
    _alertsController.close();
    _dashboardController.close();
  }

  /// Get real-time performance metrics stream for a specific BOM
  Stream<BomPerformanceMetrics> getBomPerformanceStream(String bomId) {
    return _performanceController.stream
        .where((metrics) => metrics.bomId == bomId);
  }

  /// Get critical alerts stream
  Stream<List<CriticalAlert>> getCriticalAlertsStream() {
    return _alertsController.stream;
  }

  /// Get analytics dashboard stream
  Stream<AnalyticsDashboard> getAnalyticsDashboardStream() {
    return _dashboardController.stream;
  }

  /// Generate current analytics dashboard
  Future<AnalyticsDashboard> generateAnalyticsDashboard() async {
    try {
      logger.i('Generating analytics dashboard');

      // Get all active BOMs
      final boms = await bomRepository.getAllBoms();
      final activeBoms =
          boms.where((bom) => bom.status == BomStatus.active).toList();

      // Calculate metrics for each BOM
      final bomMetrics = <BomPerformanceMetrics>[];
      for (final bom in activeBoms) {
        final metrics = await _calculateBomMetrics(bom);
        bomMetrics.add(metrics);
      }

      // Calculate overall metrics
      final overallMetrics = _calculateOverallMetrics(bomMetrics);

      // Get critical alerts
      final criticalAlerts = await _getAllCriticalAlerts();

      // Calculate trends
      final trends = await _calculateTrends();

      // Calculate KPIs
      final kpis = _calculateKPIs(bomMetrics, criticalAlerts);

      // Generate recommendations
      final recommendations =
          _generateRecommendations(bomMetrics, criticalAlerts);

      // Generate insights
      final insights = _generateInsights(bomMetrics, trends);

      final dashboard = AnalyticsDashboard(
        overallMetrics: overallMetrics,
        bomMetrics: bomMetrics,
        criticalAlerts: criticalAlerts,
        trends: trends,
        kpis: kpis,
        generatedAt: DateTime.now(),
        recommendations: recommendations,
        insights: insights,
      );

      logger.i('Analytics dashboard generated successfully');
      return dashboard;
    } catch (e, stackTrace) {
      logger.e('Error generating analytics dashboard',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get predictive insights for a BOM
  Future<List<String>> getPredictiveInsights(String bomId) async {
    try {
      logger.i('Generating predictive insights for BOM: $bomId');

      final bom = await bomRepository.getBomById(bomId);
      if (bom == null) {
        throw Exception('BOM not found: $bomId');
      }

      final metrics = await _calculateBomMetrics(bom);
      final insights = <String>[];

      // Cost trend prediction
      if (metrics.costVariance > 10) {
        insights.add(
            'Cost variance trending upward - consider supplier renegotiation');
      }

      // Quality prediction
      if (metrics.qualityScore < 80) {
        insights.add(
            'Quality score declining - implement additional quality controls');
      }

      // Material availability prediction
      if (metrics.materialAvailability < 90) {
        insights.add('Material shortages predicted - expedite procurement');
      }

      // Supplier performance prediction
      if (metrics.supplierPerformance < 85) {
        insights.add(
            'Supplier performance issues detected - review supplier contracts');
      }

      // Lead time prediction
      if (metrics.leadTimePerformance < 80) {
        insights.add('Lead time delays expected - adjust production schedule');
      }

      logger.i(
          'Generated ${insights.length} predictive insights for BOM: $bomId');
      return insights;
    } catch (e, stackTrace) {
      logger.e('Error generating predictive insights',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Private methods

  Future<void> _updatePerformanceMetrics() async {
    try {
      final boms = await bomRepository.getAllBoms();
      final activeBoms =
          boms.where((bom) => bom.status == BomStatus.active).toList();

      for (final bom in activeBoms) {
        final metrics = await _calculateBomMetrics(bom);
        _performanceController.add(metrics);
      }
    } catch (e) {
      logger.e('Error updating performance metrics', error: e);
    }
  }

  Future<void> _updateCriticalAlerts() async {
    try {
      final alerts = await _getAllCriticalAlerts();
      _alertsController.add(alerts);
    } catch (e) {
      logger.e('Error updating critical alerts', error: e);
    }
  }

  Future<void> _updateDashboard() async {
    try {
      final dashboard = await generateAnalyticsDashboard();
      _dashboardController.add(dashboard);
    } catch (e) {
      logger.e('Error updating dashboard', error: e);
    }
  }

  Future<BomPerformanceMetrics> _calculateBomMetrics(
      BillOfMaterials bom) async {
    // Simplified metrics calculation
    final now = DateTime.now();
    final baseEfficiency = 85.0;
    final variation = (now.millisecondsSinceEpoch % 20) - 10; // -10 to +10

    return BomPerformanceMetrics(
      bomId: bom.id,
      bomCode: bom.bomCode,
      bomName: bom.bomName,
      overallEfficiency: (baseEfficiency + variation).clamp(0.0, 100.0),
      costVariance: (variation.abs().toDouble() * 2).clamp(0.0, 50.0),
      qualityScore: (90.0 + variation / 2).clamp(0.0, 100.0),
      materialAvailability: (95.0 + variation / 3).clamp(0.0, 100.0),
      supplierPerformance: (88.0 + variation / 1.5).clamp(0.0, 100.0),
      leadTimePerformance: (82.0 + variation).clamp(0.0, 100.0),
      lastUpdated: now,
      alerts: _generateAlertMessages(bom),
      trends: {
        'efficiency': baseEfficiency + variation,
        'cost': variation.abs() * 2,
        'quality': 90.0 + variation / 2,
      },
      kpis: {
        'totalItems': bom.items.length,
        'activeItems': bom.items.where((item) => item.isActive).length,
        'totalCost': bom.totalCost,
        'complexity': bom.complexityLevel,
      },
    );
  }

  Map<String, double> _calculateOverallMetrics(
      List<BomPerformanceMetrics> bomMetrics) {
    if (bomMetrics.isEmpty) {
      return {
        'averageEfficiency': 0.0,
        'averageCostVariance': 0.0,
        'averageQualityScore': 0.0,
        'averageMaterialAvailability': 0.0,
        'averageSupplierPerformance': 0.0,
        'averageLeadTimePerformance': 0.0,
      };
    }

    return {
      'averageEfficiency':
          bomMetrics.map((m) => m.overallEfficiency).reduce((a, b) => a + b) /
              bomMetrics.length,
      'averageCostVariance':
          bomMetrics.map((m) => m.costVariance).reduce((a, b) => a + b) /
              bomMetrics.length,
      'averageQualityScore':
          bomMetrics.map((m) => m.qualityScore).reduce((a, b) => a + b) /
              bomMetrics.length,
      'averageMaterialAvailability': bomMetrics
              .map((m) => m.materialAvailability)
              .reduce((a, b) => a + b) /
          bomMetrics.length,
      'averageSupplierPerformance':
          bomMetrics.map((m) => m.supplierPerformance).reduce((a, b) => a + b) /
              bomMetrics.length,
      'averageLeadTimePerformance':
          bomMetrics.map((m) => m.leadTimePerformance).reduce((a, b) => a + b) /
              bomMetrics.length,
    };
  }

  Future<List<CriticalAlert>> _getAllCriticalAlerts() async {
    final alerts = <CriticalAlert>[];
    final boms = await bomRepository.getAllBoms();

    for (final bom in boms) {
      final bomAlerts = await _generateCriticalAlerts(bom);
      alerts.addAll(bomAlerts);
    }

    // Sort by priority and timestamp
    alerts.sort((a, b) {
      final priorityComparison = b.priorityScore.compareTo(a.priorityScore);
      if (priorityComparison != 0) return priorityComparison;
      return b.timestamp.compareTo(a.timestamp);
    });

    return alerts.take(20).toList(); // Limit to top 20 alerts
  }

  Future<List<CriticalAlert>> _generateCriticalAlerts(
      BillOfMaterials bom) async {
    final alerts = <CriticalAlert>[];
    final metrics = await _calculateBomMetrics(bom);

    // Cost variance alert
    if (metrics.costVariance > 15) {
      alerts.add(CriticalAlert(
        id: 'cost_variance_${bom.id}_${DateTime.now().millisecondsSinceEpoch}',
        type: 'cost_variance',
        severity: metrics.costVariance > 25 ? 'critical' : 'high',
        title: 'High Cost Variance',
        message:
            'BOM ${bom.bomCode} has cost variance of ${metrics.costVariance.toStringAsFixed(1)}%',
        bomId: bom.id,
        timestamp: DateTime.now(),
        impactLevel: metrics.costVariance > 25 ? 'high' : 'medium',
        actionRequired: 'Review supplier contracts and material costs',
        estimatedResolutionTime: const Duration(days: 7),
        affectedMetrics: ['cost', 'efficiency'],
      ));
    }

    // Quality score alert
    if (metrics.qualityScore < 75) {
      alerts.add(CriticalAlert(
        id: 'quality_score_${bom.id}_${DateTime.now().millisecondsSinceEpoch}',
        type: 'quality_issue',
        severity: metrics.qualityScore < 60 ? 'critical' : 'high',
        title: 'Low Quality Score',
        message:
            'BOM ${bom.bomCode} has quality score of ${metrics.qualityScore.toStringAsFixed(1)}%',
        bomId: bom.id,
        timestamp: DateTime.now(),
        impactLevel: metrics.qualityScore < 60 ? 'high' : 'medium',
        actionRequired: 'Implement quality improvement measures',
        estimatedResolutionTime: const Duration(days: 14),
        affectedMetrics: ['quality', 'efficiency'],
      ));
    }

    // Material availability alert
    if (metrics.materialAvailability < 85) {
      alerts.add(CriticalAlert(
        id: 'material_availability_${bom.id}_${DateTime.now().millisecondsSinceEpoch}',
        type: 'material_shortage',
        severity: metrics.materialAvailability < 70 ? 'critical' : 'medium',
        title: 'Material Shortage Risk',
        message:
            'BOM ${bom.bomCode} has material availability of ${metrics.materialAvailability.toStringAsFixed(1)}%',
        bomId: bom.id,
        timestamp: DateTime.now(),
        impactLevel: metrics.materialAvailability < 70 ? 'high' : 'medium',
        actionRequired: 'Expedite material procurement',
        estimatedResolutionTime: const Duration(days: 3),
        affectedMetrics: ['availability', 'efficiency'],
      ));
    }

    return alerts;
  }

  Future<Map<String, List<double>>> _calculateTrends() async {
    // Simplified trend calculation
    // In real implementation, this would analyze historical data
    return {
      'efficiency': [85, 87, 86, 88, 90, 89, 91],
      'cost': [5, 7, 6, 8, 10, 9, 8],
      'quality': [88, 89, 87, 90, 92, 91, 93],
      'availability': [92, 94, 93, 95, 96, 94, 97],
    };
  }

  Map<String, dynamic> _calculateKPIs(
    List<BomPerformanceMetrics> bomMetrics,
    List<CriticalAlert> alerts,
  ) {
    return {
      'totalBoms': bomMetrics.length,
      'averageHealthScore': bomMetrics.isNotEmpty
          ? bomMetrics.map((m) => m.healthScore).reduce((a, b) => a + b) /
              bomMetrics.length
          : 0.0,
      'criticalAlerts': alerts.where((a) => a.isCritical).length,
      'totalAlerts': alerts.length,
      'bomsAboveThreshold': bomMetrics.where((m) => m.healthScore >= 80).length,
      'bomsBelowThreshold': bomMetrics.where((m) => m.healthScore < 80).length,
      'averageEfficiency': bomMetrics.isNotEmpty
          ? bomMetrics.map((m) => m.overallEfficiency).reduce((a, b) => a + b) /
              bomMetrics.length
          : 0.0,
      'averageQuality': bomMetrics.isNotEmpty
          ? bomMetrics.map((m) => m.qualityScore).reduce((a, b) => a + b) /
              bomMetrics.length
          : 0.0,
    };
  }

  List<String> _generateRecommendations(
    List<BomPerformanceMetrics> bomMetrics,
    List<CriticalAlert> alerts,
  ) {
    final recommendations = <String>[];

    // Cost optimization recommendations
    final highCostVarianceBoms =
        bomMetrics.where((m) => m.costVariance > 15).length;
    if (highCostVarianceBoms > 0) {
      recommendations.add(
          'Review supplier contracts for $highCostVarianceBoms BOMs with high cost variance');
    }

    // Quality improvement recommendations
    final lowQualityBoms = bomMetrics.where((m) => m.qualityScore < 80).length;
    if (lowQualityBoms > 0) {
      recommendations.add(
          'Implement quality improvement measures for $lowQualityBoms BOMs');
    }

    // Material availability recommendations
    final lowAvailabilityBoms =
        bomMetrics.where((m) => m.materialAvailability < 90).length;
    if (lowAvailabilityBoms > 0) {
      recommendations.add(
          'Expedite procurement for $lowAvailabilityBoms BOMs with material shortages');
    }

    // Critical alerts recommendations
    if (alerts.where((a) => a.isCritical).length > 5) {
      recommendations.add(
          'Address critical alerts immediately to prevent production disruptions');
    }

    return recommendations;
  }

  List<String> _generateInsights(
    List<BomPerformanceMetrics> bomMetrics,
    Map<String, List<double>> trends,
  ) {
    final insights = <String>[];

    // Efficiency trend insight
    final efficiencyTrend = trends['efficiency'] ?? [];
    if (efficiencyTrend.length >= 2) {
      final recentEfficiency = efficiencyTrend.last;
      final previousEfficiency = efficiencyTrend[efficiencyTrend.length - 2];
      if (recentEfficiency > previousEfficiency) {
        insights.add(
            'Overall efficiency is trending upward (+${(recentEfficiency - previousEfficiency).toStringAsFixed(1)}%)');
      } else if (recentEfficiency < previousEfficiency) {
        insights.add(
            'Overall efficiency is declining (-${(previousEfficiency - recentEfficiency).toStringAsFixed(1)}%)');
      }
    }

    // Quality trend insight
    final qualityTrend = trends['quality'] ?? [];
    if (qualityTrend.length >= 2) {
      final recentQuality = qualityTrend.last;
      final previousQuality = qualityTrend[qualityTrend.length - 2];
      if (recentQuality > previousQuality) {
        insights.add(
            'Quality scores are improving (+${(recentQuality - previousQuality).toStringAsFixed(1)}%)');
      }
    }

    // Performance distribution insight
    final excellentBoms = bomMetrics.where((m) => m.healthScore >= 90).length;
    final totalBoms = bomMetrics.length;
    if (totalBoms > 0) {
      final excellentPercentage = (excellentBoms / totalBoms) * 100;
      insights.add(
          '${excellentPercentage.toStringAsFixed(1)}% of BOMs are performing excellently');
    }

    return insights;
  }

  List<String> _generateAlertMessages(BillOfMaterials bom) {
    final messages = <String>[];

    if (bom.items.any((item) => !item.isActive)) {
      messages.add('Some materials are inactive');
    }

    if (bom.totalCost > 10000) {
      messages.add('High-cost BOM requires monitoring');
    }

    if (bom.complexityLevel == 'Complex') {
      messages.add('Complex BOM may need additional oversight');
    }

    return messages;
  }
}

/// Provider for Real-Time Analytics Service
final realtimeAnalyticsServiceProvider =
    Provider<RealtimeAnalyticsService>((ref) {
  final service = RealtimeAnalyticsService(
    bomRepository: ref.watch(bomRepositoryProvider),
    inventoryRepository:
        ref.watch(inventory_provider.inventoryRepositoryProvider),
    supplierRepository: ref.watch(supplier_provider.supplierRepositoryProvider),
    logger: Logger(),
  );

  // Initialize the service
  service.initialize();

  // Dispose when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
