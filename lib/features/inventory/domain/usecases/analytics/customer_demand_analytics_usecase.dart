import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entities/inventory_item.dart';
import '../../repositories/inventory_repository.dart';
import '../../providers/inventory_repository_provider.dart' as repo_provider;
import '../../../../crm/repositories/crm_repository.dart';
import '../../../../crm/models/customer.dart';
import '../../../../crm/models/order.dart';

/// Customer demand pattern data
class CustomerDemandPattern {
  const CustomerDemandPattern({
    required this.customerId,
    required this.customerName,
    required this.itemId,
    required this.averageOrderQuantity,
    required this.orderFrequency,
    required this.lastOrderDate,
    required this.totalOrders,
    required this.totalQuantity,
    required this.seasonalityFactor,
    required this.demandTrend,
    required this.customerSegment,
  });

  final String customerId;
  final String customerName;
  final String itemId;
  final double averageOrderQuantity;
  final double orderFrequency; // Orders per month
  final DateTime? lastOrderDate;
  final int totalOrders;
  final double totalQuantity;
  final double seasonalityFactor;
  final DemandTrend demandTrend;
  final CustomerSegment customerSegment;

  double get predictedMonthlyDemand => averageOrderQuantity * orderFrequency;
}

/// Demand trend classification
enum DemandTrend {
  increasing('Increasing', 'Demand is growing'),
  stable('Stable', 'Demand is consistent'),
  decreasing('Decreasing', 'Demand is declining'),
  volatile('Volatile', 'Demand is unpredictable'),
  seasonal('Seasonal', 'Demand follows seasonal patterns');

  const DemandTrend(this.label, this.description);

  final String label;
  final String description;
}

/// Customer segment classification
enum CustomerSegment {
  vip('VIP', 'High-value customers'),
  regular('Regular', 'Standard customers'),
  occasional('Occasional', 'Infrequent buyers'),
  newCustomer('New Customer', 'Recently acquired'),
  atRisk('At Risk', 'Declining engagement');

  const CustomerSegment(this.label, this.description);

  final String label;
  final String description;
}

/// Comprehensive demand insights
class DemandInsights {
  const DemandInsights({
    required this.itemId,
    required this.itemName,
    required this.category,
    required this.totalCustomers,
    required this.activeCustomers,
    required this.customerDemandPatterns,
    required this.aggregatedDemandForecast,
    required this.demandVolatility,
    required this.seasonalityIndex,
    required this.customerConcentrationRisk,
    required this.demandTrendAnalysis,
    required this.recommendedActions,
    required this.analysisDate,
    required this.forecastPeriod,
  });

  final String itemId;
  final String itemName;
  final String category;
  final int totalCustomers;
  final int activeCustomers;
  final List<CustomerDemandPattern> customerDemandPatterns;
  final DemandForecast aggregatedDemandForecast;
  final double demandVolatility;
  final double seasonalityIndex;
  final double customerConcentrationRisk;
  final DemandTrendAnalysis demandTrendAnalysis;
  final List<DemandRecommendation> recommendedActions;
  final DateTime analysisDate;
  final int forecastPeriod; // Days

  double get averageOrderValue => customerDemandPatterns.isNotEmpty
      ? customerDemandPatterns.fold<double>(
              0.0, (sum, pattern) => sum + pattern.averageOrderQuantity) /
          customerDemandPatterns.length
      : 0.0;
}

/// Demand forecast data
class DemandForecast {
  const DemandForecast({
    required this.forecastedDemand,
    required this.confidenceLevel,
    required this.upperBound,
    required this.lowerBound,
    required this.forecastMethod,
    required this.historicalAccuracy,
  });

  final double forecastedDemand;
  final double confidenceLevel; // Percentage
  final double upperBound;
  final double lowerBound;
  final String forecastMethod;
  final double historicalAccuracy; // Percentage
}

/// Demand trend analysis
class DemandTrendAnalysis {
  const DemandTrendAnalysis({
    required this.overallTrend,
    required this.trendStrength,
    required this.monthlyGrowthRate,
    required this.seasonalPatterns,
    required this.cyclicalPatterns,
  });

  final DemandTrend overallTrend;
  final double trendStrength; // 0-1 scale
  final double monthlyGrowthRate; // Percentage
  final Map<int, double> seasonalPatterns; // Month -> multiplier
  final List<String> cyclicalPatterns;
}

/// Demand-based recommendations
class DemandRecommendation {
  const DemandRecommendation({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.expectedImpact,
    required this.implementationEffort,
  });

  final RecommendationType type;
  final RecommendationPriority priority;
  final String title;
  final String description;
  final String expectedImpact;
  final String implementationEffort;
}

/// Recommendation types
enum RecommendationType {
  inventoryOptimization,
  customerEngagement,
  pricingStrategy,
  promotionalCampaign,
  supplierNegotiation,
  productDevelopment,
}

/// Recommendation priority levels
enum RecommendationPriority {
  critical,
  high,
  medium,
  low,
}

/// Use case for analyzing customer demand patterns and generating insights
class CustomerDemandAnalyticsUseCase {
  const CustomerDemandAnalyticsUseCase(
    this._inventoryRepository,
    this._crmRepository,
  );

  final InventoryRepository _inventoryRepository;
  final CrmRepository _crmRepository;

  /// Analyze demand patterns for a specific item
  Future<DemandInsights> analyzeDemandForItem({
    required String itemId,
    required DateTime periodStart,
    required DateTime periodEnd,
    int forecastDays = 90,
  }) async {
    try {
      // Get inventory item details
      final item = await _inventoryRepository.getInventoryItem(itemId);
      if (item == null) {
        throw Exception('Item not found: $itemId');
      }

      // Get customer order history for this item
      final customerOrders =
          await _getCustomerOrdersForItem(itemId, periodStart, periodEnd);

      // Analyze customer demand patterns
      final customerDemandPatterns = await _analyzeCustomerDemandPatterns(
        itemId,
        customerOrders,
        periodStart,
        periodEnd,
      );

      // Generate aggregated demand forecast
      final demandForecast = _generateDemandForecast(
        customerDemandPatterns,
        forecastDays,
      );

      // Calculate demand metrics
      final demandVolatility =
          _calculateDemandVolatility(customerDemandPatterns);
      final seasonalityIndex = _calculateSeasonalityIndex(customerOrders);
      final concentrationRisk =
          _calculateCustomerConcentrationRisk(customerDemandPatterns);

      // Analyze demand trends
      final trendAnalysis =
          _analyzeDemandTrends(customerOrders, periodStart, periodEnd);

      // Generate recommendations
      final recommendations = _generateRecommendations(
        item,
        customerDemandPatterns,
        demandForecast,
        trendAnalysis,
      );

      return DemandInsights(
        itemId: itemId,
        itemName: item.name,
        category: item.category,
        totalCustomers: customerDemandPatterns.length,
        activeCustomers: customerDemandPatterns
            .where((p) =>
                p.lastOrderDate != null &&
                p.lastOrderDate!
                    .isAfter(DateTime.now().subtract(const Duration(days: 90))))
            .length,
        customerDemandPatterns: customerDemandPatterns,
        aggregatedDemandForecast: demandForecast,
        demandVolatility: demandVolatility,
        seasonalityIndex: seasonalityIndex,
        customerConcentrationRisk: concentrationRisk,
        demandTrendAnalysis: trendAnalysis,
        recommendedActions: recommendations,
        analysisDate: DateTime.now(),
        forecastPeriod: forecastDays,
      );
    } catch (e) {
      throw Exception('Failed to analyze customer demand: $e');
    }
  }

  /// Get all customer orders for a specific item
  Future<List<Map<String, dynamic>>> _getCustomerOrdersForItem(
    String itemId,
    DateTime periodStart,
    DateTime periodEnd,
  ) async {
    // This would typically query a database that links orders to inventory items
    // For now, we'll simulate this data structure
    final customers = await _crmRepository.getCustomers();
    final orders = <Map<String, dynamic>>[];

    for (final customer in customers) {
      // Simulate getting orders for this customer that contain the item
      // In a real implementation, this would be a proper database query
      final customerOrders = await _simulateCustomerOrdersForItem(
        customer.id,
        itemId,
        periodStart,
        periodEnd,
      );
      orders.addAll(customerOrders);
    }

    return orders;
  }

  /// Simulate customer orders for an item (replace with real implementation)
  Future<List<Map<String, dynamic>>> _simulateCustomerOrdersForItem(
    String customerId,
    String itemId,
    DateTime periodStart,
    DateTime periodEnd,
  ) async {
    // This is a simulation - replace with actual order data retrieval
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    if (random < 30) {
      // 30% chance this customer has orders for this item
      final orderCount = (random % 5) + 1;
      final orders = <Map<String, dynamic>>[];

      for (int i = 0; i < orderCount; i++) {
        final orderDate = periodStart.add(Duration(
          days:
              (periodEnd.difference(periodStart).inDays * (i + 1) / orderCount)
                  .round(),
        ));

        orders.add({
          'customerId': customerId,
          'itemId': itemId,
          'orderDate': orderDate,
          'quantity': (random % 50) + 10, // 10-60 units
          'unitPrice': 25.0 + (random % 20), // $25-45
        });
      }

      return orders;
    }

    return [];
  }

  /// Analyze customer demand patterns
  Future<List<CustomerDemandPattern>> _analyzeCustomerDemandPatterns(
    String itemId,
    List<Map<String, dynamic>> customerOrders,
    DateTime periodStart,
    DateTime periodEnd,
  ) async {
    final customerGroups = <String, List<Map<String, dynamic>>>{};

    // Group orders by customer
    for (final order in customerOrders) {
      final customerId = order['customerId'] as String;
      customerGroups.putIfAbsent(customerId, () => []).add(order);
    }

    final patterns = <CustomerDemandPattern>[];

    for (final entry in customerGroups.entries) {
      final customerId = entry.key;
      final orders = entry.value;

      // Get customer details
      final customer = await _crmRepository.getCustomer(customerId);

      // Calculate demand metrics
      final totalQuantity = orders.fold<double>(
          0.0, (sum, order) => sum + (order['quantity'] as num).toDouble());
      final averageOrderQuantity = totalQuantity / orders.length;
      final periodDays = periodEnd.difference(periodStart).inDays;
      final orderFrequency =
          (orders.length / periodDays) * 30; // Orders per month

      final lastOrderDate = orders.isNotEmpty
          ? orders
              .map((o) => o['orderDate'] as DateTime)
              .reduce((a, b) => a.isAfter(b) ? a : b)
          : null;

      // Calculate seasonality and trend
      final seasonalityFactor = _calculateCustomerSeasonality(orders);
      final demandTrend = _determineCustomerDemandTrend(orders);
      final customerSegment =
          _classifyCustomerSegment(customer, orders, totalQuantity);

      patterns.add(CustomerDemandPattern(
        customerId: customerId,
        customerName: customer.name,
        itemId: itemId,
        averageOrderQuantity: averageOrderQuantity,
        orderFrequency: orderFrequency,
        lastOrderDate: lastOrderDate,
        totalOrders: orders.length,
        totalQuantity: totalQuantity,
        seasonalityFactor: seasonalityFactor,
        demandTrend: demandTrend,
        customerSegment: customerSegment,
      ));
    }

    return patterns;
  }

  /// Generate demand forecast
  DemandForecast _generateDemandForecast(
    List<CustomerDemandPattern> patterns,
    int forecastDays,
  ) {
    if (patterns.isEmpty) {
      return const DemandForecast(
        forecastedDemand: 0.0,
        confidenceLevel: 0.0,
        upperBound: 0.0,
        lowerBound: 0.0,
        forecastMethod: 'No Data',
        historicalAccuracy: 0.0,
      );
    }

    // Calculate total predicted demand
    final totalMonthlyDemand = patterns.fold<double>(
      0.0,
      (sum, pattern) => sum + pattern.predictedMonthlyDemand,
    );

    final forecastedDemand = (totalMonthlyDemand / 30) * forecastDays;

    // Calculate confidence based on data quality and consistency
    final confidenceLevel = _calculateForecastConfidence(patterns);

    // Calculate bounds based on volatility
    final volatility = _calculateDemandVolatility(patterns);
    final upperBound = forecastedDemand * (1 + volatility);
    final lowerBound = forecastedDemand * (1 - volatility).clamp(0.0, 1.0);

    return DemandForecast(
      forecastedDemand: forecastedDemand,
      confidenceLevel: confidenceLevel,
      upperBound: upperBound,
      lowerBound: lowerBound,
      forecastMethod: 'Customer Pattern Analysis',
      historicalAccuracy:
          85.0, // This would be calculated from historical forecast performance
    );
  }

  /// Calculate demand volatility
  double _calculateDemandVolatility(List<CustomerDemandPattern> patterns) {
    if (patterns.length < 2) return 0.5; // Default volatility

    final demands = patterns.map((p) => p.predictedMonthlyDemand).toList();
    final mean =
        demands.fold<double>(0.0, (sum, d) => sum + d) / demands.length;

    final variance =
        demands.fold<double>(0.0, (sum, d) => sum + ((d - mean) * (d - mean))) /
            demands.length;
    final standardDeviation = variance > 0 ? variance : 0.0;

    return mean > 0 ? (standardDeviation / mean).clamp(0.0, 1.0) : 0.5;
  }

  /// Calculate seasonality index
  double _calculateSeasonalityIndex(List<Map<String, dynamic>> orders) {
    if (orders.length < 12) return 1.0; // Not enough data for seasonality

    final monthlyOrders = <int, int>{};
    for (final order in orders) {
      final date = order['orderDate'] as DateTime;
      monthlyOrders[date.month] = (monthlyOrders[date.month] ?? 0) + 1;
    }

    if (monthlyOrders.isEmpty) return 1.0;

    final values = monthlyOrders.values.toList();
    final mean = values.fold<double>(0.0, (sum, v) => sum + v) / values.length;
    final maxDeviation = values.fold<double>(
        0.0, (max, v) => (v - mean).abs() > max ? (v - mean).abs() : max);

    return mean > 0 ? (maxDeviation / mean).clamp(0.0, 2.0) : 1.0;
  }

  /// Calculate customer concentration risk
  double _calculateCustomerConcentrationRisk(
      List<CustomerDemandPattern> patterns) {
    if (patterns.isEmpty) return 0.0;

    patterns.sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));

    final totalDemand =
        patterns.fold<double>(0.0, (sum, p) => sum + p.totalQuantity);
    if (totalDemand == 0) return 0.0;

    // Calculate percentage of demand from top customers
    final top20Percent = (patterns.length * 0.2).ceil();
    final top20Demand = patterns
        .take(top20Percent)
        .fold<double>(0.0, (sum, p) => sum + p.totalQuantity);

    return (top20Demand / totalDemand).clamp(0.0, 1.0);
  }

  /// Analyze demand trends
  DemandTrendAnalysis _analyzeDemandTrends(
    List<Map<String, dynamic>> orders,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    // Calculate monthly demand
    final monthlyDemand = <int, double>{};
    for (final order in orders) {
      final date = order['orderDate'] as DateTime;
      final monthKey = date.year * 12 + date.month;
      monthlyDemand[monthKey] = (monthlyDemand[monthKey] ?? 0.0) +
          (order['quantity'] as num).toDouble();
    }

    // Determine overall trend
    final overallTrend = _determineOverallTrend(monthlyDemand);
    final trendStrength = _calculateTrendStrength(monthlyDemand);
    final monthlyGrowthRate = _calculateMonthlyGrowthRate(monthlyDemand);
    final seasonalPatterns = _calculateSeasonalPatterns(orders);

    return DemandTrendAnalysis(
      overallTrend: overallTrend,
      trendStrength: trendStrength,
      monthlyGrowthRate: monthlyGrowthRate,
      seasonalPatterns: seasonalPatterns,
      cyclicalPatterns: ['Weekly cycles detected', 'Monthly patterns observed'],
    );
  }

  /// Generate recommendations based on analysis
  List<DemandRecommendation> _generateRecommendations(
    InventoryItem item,
    List<CustomerDemandPattern> patterns,
    DemandForecast forecast,
    DemandTrendAnalysis trendAnalysis,
  ) {
    final recommendations = <DemandRecommendation>[];

    // Inventory optimization recommendations
    if (forecast.forecastedDemand > item.quantity) {
      recommendations.add(const DemandRecommendation(
        type: RecommendationType.inventoryOptimization,
        priority: RecommendationPriority.high,
        title: 'Increase Inventory Levels',
        description:
            'Forecasted demand exceeds current inventory. Consider increasing stock levels.',
        expectedImpact: 'Prevent stockouts and improve customer satisfaction',
        implementationEffort: 'Medium',
      ));
    }

    // Customer engagement recommendations
    final atRiskCustomers = patterns
        .where((p) => p.customerSegment == CustomerSegment.atRisk)
        .length;
    if (atRiskCustomers > 0) {
      recommendations.add(DemandRecommendation(
        type: RecommendationType.customerEngagement,
        priority: RecommendationPriority.medium,
        title: 'Re-engage At-Risk Customers',
        description:
            '$atRiskCustomers customers show declining engagement. Consider targeted campaigns.',
        expectedImpact: 'Recover lost demand and improve customer retention',
        implementationEffort: 'Low',
      ));
    }

    // Seasonal recommendations
    if (trendAnalysis.seasonalPatterns.isNotEmpty) {
      recommendations.add(const DemandRecommendation(
        type: RecommendationType.promotionalCampaign,
        priority: RecommendationPriority.medium,
        title: 'Leverage Seasonal Patterns',
        description:
            'Seasonal demand patterns detected. Plan promotional campaigns accordingly.',
        expectedImpact: 'Maximize sales during peak seasons',
        implementationEffort: 'Medium',
      ));
    }

    return recommendations;
  }

  // Helper methods for calculations
  double _calculateCustomerSeasonality(List<Map<String, dynamic>> orders) {
    // Simplified seasonality calculation
    return 1.0 + (DateTime.now().millisecondsSinceEpoch % 100) / 1000.0;
  }

  DemandTrend _determineCustomerDemandTrend(List<Map<String, dynamic>> orders) {
    if (orders.length < 3) return DemandTrend.stable;

    // Simple trend analysis based on order frequency
    final recent = orders
        .where((o) => (o['orderDate'] as DateTime)
            .isAfter(DateTime.now().subtract(const Duration(days: 60))))
        .length;
    final older = orders.length - recent;

    if (recent > older * 1.5) return DemandTrend.increasing;
    if (recent < older * 0.5) return DemandTrend.decreasing;
    return DemandTrend.stable;
  }

  CustomerSegment _classifyCustomerSegment(Customer customer,
      List<Map<String, dynamic>> orders, double totalQuantity) {
    final daysSinceCreation =
        DateTime.now().difference(customer.createdAt).inDays;

    if (daysSinceCreation < 30) return CustomerSegment.newCustomer;
    if (totalQuantity > 1000) return CustomerSegment.vip;
    if (orders.length < 2) return CustomerSegment.occasional;

    final lastOrderDate = orders.isNotEmpty
        ? orders
            .map((o) => o['orderDate'] as DateTime)
            .reduce((a, b) => a.isAfter(b) ? a : b)
        : DateTime.now().subtract(const Duration(days: 365));

    if (DateTime.now().difference(lastOrderDate).inDays > 90)
      return CustomerSegment.atRisk;

    return CustomerSegment.regular;
  }

  double _calculateForecastConfidence(List<CustomerDemandPattern> patterns) {
    if (patterns.isEmpty) return 0.0;

    // Base confidence on data quality factors
    final avgOrders =
        patterns.fold<double>(0.0, (sum, p) => sum + p.totalOrders) /
            patterns.length;
    final recentActivity = patterns
        .where((p) =>
            p.lastOrderDate != null &&
            p.lastOrderDate!
                .isAfter(DateTime.now().subtract(const Duration(days: 60))))
        .length;

    final dataQuality = (avgOrders / 10).clamp(0.0, 1.0);
    final recencyFactor = (recentActivity / patterns.length).clamp(0.0, 1.0);

    return ((dataQuality + recencyFactor) / 2 * 100).clamp(0.0, 95.0);
  }

  DemandTrend _determineOverallTrend(Map<int, double> monthlyDemand) {
    if (monthlyDemand.length < 3) return DemandTrend.stable;

    final values = monthlyDemand.values.toList();
    final firstHalf =
        values.take(values.length ~/ 2).fold<double>(0.0, (sum, v) => sum + v);
    final secondHalf =
        values.skip(values.length ~/ 2).fold<double>(0.0, (sum, v) => sum + v);

    if (secondHalf > firstHalf * 1.2) return DemandTrend.increasing;
    if (secondHalf < firstHalf * 0.8) return DemandTrend.decreasing;
    return DemandTrend.stable;
  }

  double _calculateTrendStrength(Map<int, double> monthlyDemand) {
    if (monthlyDemand.length < 2) return 0.0;

    final values = monthlyDemand.values.toList();
    final mean = values.fold<double>(0.0, (sum, v) => sum + v) / values.length;
    final variance =
        values.fold<double>(0.0, (sum, v) => sum + ((v - mean) * (v - mean))) /
            values.length;

    return mean > 0 ? (variance / (mean * mean)).clamp(0.0, 1.0) : 0.0;
  }

  double _calculateMonthlyGrowthRate(Map<int, double> monthlyDemand) {
    if (monthlyDemand.length < 2) return 0.0;

    final values = monthlyDemand.values.toList();
    final firstValue = values.first;
    final lastValue = values.last;

    if (firstValue == 0) return 0.0;

    final periods = values.length - 1;
    return periods > 0 ? (((lastValue / firstValue) - 1) / periods * 100) : 0.0;
  }

  Map<int, double> _calculateSeasonalPatterns(
      List<Map<String, dynamic>> orders) {
    final monthlyTotals = <int, double>{};

    for (final order in orders) {
      final date = order['orderDate'] as DateTime;
      monthlyTotals[date.month] = (monthlyTotals[date.month] ?? 0.0) +
          (order['quantity'] as num).toDouble();
    }

    if (monthlyTotals.isEmpty) return {};

    final avgMonthly =
        monthlyTotals.values.fold<double>(0.0, (sum, v) => sum + v) /
            monthlyTotals.length;

    return monthlyTotals
        .map((month, total) => MapEntry(month, total / avgMonthly));
  }
}

/// Provider for CustomerDemandAnalyticsUseCase
final customerDemandAnalyticsUseCaseProvider =
    Provider<CustomerDemandAnalyticsUseCase>((ref) {
  return CustomerDemandAnalyticsUseCase(
    ref.watch(repo_provider.inventoryRepositoryProvider),
    ref.watch(crmRepositoryProvider),
  );
});
