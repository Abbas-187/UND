import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entities/inventory_item.dart';
import '../../repositories/inventory_repository.dart';
import '../../providers/inventory_repository_provider.dart' as repo_provider;

/// Stockout event data
class StockoutEvent {
  const StockoutEvent({
    required this.itemId,
    required this.itemName,
    required this.category,
    required this.stockoutStart,
    required this.stockoutEnd,
    required this.durationInDays,
    required this.demandDuringStockout,
    required this.estimatedLostSales,
    required this.stockoutReason,
    required this.reorderPoint,
    required this.safetyStock,
    required this.leadTime,
  });

  final String itemId;
  final String itemName;
  final String category;
  final DateTime stockoutStart;
  final DateTime? stockoutEnd;
  final int durationInDays;
  final double demandDuringStockout;
  final double estimatedLostSales;
  final StockoutReason stockoutReason;
  final double reorderPoint;
  final double safetyStock;
  final int leadTime;

  bool get isOngoing => stockoutEnd == null;
  double get dailyDemandRate =>
      durationInDays > 0 ? demandDuringStockout / durationInDays : 0.0;
}

/// Reasons for stockouts
enum StockoutReason {
  forecastInaccuracy('Forecast Inaccuracy', 'Demand exceeded forecast'),
  supplierDelay('Supplier Delay', 'Supplier delivered late'),
  qualityIssues('Quality Issues', 'Stock rejected due to quality'),
  unexpectedDemand('Unexpected Demand', 'Sudden spike in demand'),
  planningError('Planning Error', 'Reorder point too low'),
  systemError('System Error', 'System or process failure'),
  unknown('Unknown', 'Reason not determined');

  const StockoutReason(this.label, this.description);

  final String label;
  final String description;
}

/// Stockout analysis by category
class CategoryStockoutAnalysis {
  const CategoryStockoutAnalysis({
    required this.category,
    required this.totalStockouts,
    required this.totalStockoutDays,
    required this.averageStockoutDuration,
    required this.stockoutRate,
    required this.totalLostSales,
    required this.mostCommonReason,
    required this.itemsAffected,
  });

  final String category;
  final int totalStockouts;
  final int totalStockoutDays;
  final double averageStockoutDuration;
  final double stockoutRate; // Percentage of time in stockout
  final double totalLostSales;
  final StockoutReason mostCommonReason;
  final int itemsAffected;
}

/// Overall stockout analysis result
class StockoutAnalysisResult {
  const StockoutAnalysisResult({
    required this.totalStockoutEvents,
    required this.totalStockoutDays,
    required this.averageStockoutDuration,
    required this.overallStockoutRate,
    required this.totalEstimatedLostSales,
    required this.stockoutEvents,
    required this.categoryAnalysis,
    required this.reasonBreakdown,
    required this.criticalItems,
    required this.ongoingStockouts,
    required this.analysisDate,
    required this.periodStart,
    required this.periodEnd,
  });

  final int totalStockoutEvents;
  final int totalStockoutDays;
  final double averageStockoutDuration;
  final double overallStockoutRate;
  final double totalEstimatedLostSales;
  final List<StockoutEvent> stockoutEvents;
  final List<CategoryStockoutAnalysis> categoryAnalysis;
  final Map<StockoutReason, int> reasonBreakdown;
  final List<StockoutEvent> criticalItems;
  final List<StockoutEvent> ongoingStockouts;
  final DateTime analysisDate;
  final DateTime periodStart;
  final DateTime periodEnd;

  int get daysInPeriod => periodEnd.difference(periodStart).inDays;
}

/// Use case for analyzing stockout events and patterns
class StockoutAnalysisUseCase {
  const StockoutAnalysisUseCase(this._repository);

  final InventoryRepository _repository;

  /// Perform comprehensive stockout analysis
  Future<StockoutAnalysisResult> execute({
    required DateTime periodStart,
    required DateTime periodEnd,
    String? categoryFilter,
    List<String>? itemIdFilter,
  }) async {
    try {
      // Get all inventory items
      final allItems = await _repository.getItems();

      // Filter items if specified
      var items = allItems;
      if (categoryFilter != null) {
        items = items.where((item) => item.category == categoryFilter).toList();
      }
      if (itemIdFilter != null) {
        items = items.where((item) => itemIdFilter.contains(item.id)).toList();
      }

      // Analyze stockouts for each item
      final stockoutEvents = <StockoutEvent>[];

      for (final item in items) {
        final itemStockouts = await _analyzeItemStockouts(
          item,
          periodStart,
          periodEnd,
        );
        stockoutEvents.addAll(itemStockouts);
      }

      // Calculate overall metrics
      final totalStockoutEvents = stockoutEvents.length;
      final totalStockoutDays = stockoutEvents.fold<int>(
          0, (sum, event) => sum + event.durationInDays);
      final averageStockoutDuration = totalStockoutEvents > 0
          ? totalStockoutDays / totalStockoutEvents
          : 0.0;

      final daysInPeriod = periodEnd.difference(periodStart).inDays;
      final overallStockoutRate =
          daysInPeriod > 0 ? (totalStockoutDays / daysInPeriod) * 100 : 0.0;

      final totalEstimatedLostSales = stockoutEvents.fold<double>(
          0.0, (sum, event) => sum + event.estimatedLostSales);

      // Generate category analysis
      final categoryAnalysis =
          _generateCategoryAnalysis(stockoutEvents, daysInPeriod);

      // Generate reason breakdown
      final reasonBreakdown = <StockoutReason, int>{};
      for (final event in stockoutEvents) {
        reasonBreakdown[event.stockoutReason] =
            (reasonBreakdown[event.stockoutReason] ?? 0) + 1;
      }

      // Identify critical items (high impact stockouts)
      final criticalItems = stockoutEvents
          .where((event) =>
              event.estimatedLostSales > 1000 || // High lost sales
              event.durationInDays > 7) // Long duration
          .toList()
        ..sort((a, b) => b.estimatedLostSales.compareTo(a.estimatedLostSales));

      // Identify ongoing stockouts
      final ongoingStockouts =
          stockoutEvents.where((event) => event.isOngoing).toList();

      return StockoutAnalysisResult(
        totalStockoutEvents: totalStockoutEvents,
        totalStockoutDays: totalStockoutDays,
        averageStockoutDuration: averageStockoutDuration,
        overallStockoutRate: overallStockoutRate,
        totalEstimatedLostSales: totalEstimatedLostSales,
        stockoutEvents: stockoutEvents,
        categoryAnalysis: categoryAnalysis,
        reasonBreakdown: reasonBreakdown,
        criticalItems: criticalItems,
        ongoingStockouts: ongoingStockouts,
        analysisDate: DateTime.now(),
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
    } catch (e) {
      throw Exception('Failed to analyze stockouts: $e');
    }
  }

  /// Analyze stockouts for a specific item
  Future<List<StockoutEvent>> _analyzeItemStockouts(
    InventoryItem item,
    DateTime periodStart,
    DateTime periodEnd,
  ) async {
    try {
      final stockoutEvents = <StockoutEvent>[];

      // Get item movements for the period
      final movements = await _repository.getMovementsForItem(item.id);
      final periodMovements = movements
          .where((movement) =>
              movement.movementDate.isAfter(periodStart) &&
              movement.movementDate.isBefore(periodEnd))
          .toList()
        ..sort((a, b) => a.movementDate.compareTo(b.movementDate));

      // Track inventory levels over time to identify stockouts
      double runningQuantity = item.quantity;
      DateTime? stockoutStart;
      double demandDuringStockout = 0.0;

      // Work backwards from current quantity to reconstruct historical levels
      // This is a simplified approach - in practice, you'd want historical snapshots
      for (final movement in periodMovements.reversed) {
        for (final movementItem in movement.items) {
          if (movementItem.itemId == item.id) {
            // Reverse the movement to get historical quantity
            if (movement.isInbound) {
              runningQuantity -= movementItem.quantity;
            } else {
              runningQuantity += movementItem.quantity.abs();
            }

            // Check for stockout conditions
            if (runningQuantity <= 0 && stockoutStart == null) {
              // Stockout started
              stockoutStart = movement.movementDate;
            } else if (runningQuantity > 0 && stockoutStart != null) {
              // Stockout ended
              final stockoutEnd = movement.movementDate;
              final duration = stockoutEnd.difference(stockoutStart).inDays;

              final stockoutEvent = StockoutEvent(
                itemId: item.id,
                itemName: item.name,
                category: item.category,
                stockoutStart: stockoutStart,
                stockoutEnd: stockoutEnd,
                durationInDays: duration,
                demandDuringStockout: demandDuringStockout,
                estimatedLostSales:
                    _estimateLostSales(item, demandDuringStockout),
                stockoutReason: _determineStockoutReason(item, movement),
                reorderPoint: item.reorderPoint,
                safetyStock: item.minimumQuantity,
                leadTime: _getItemLeadTime(item),
              );

              stockoutEvents.add(stockoutEvent);
              stockoutStart = null;
              demandDuringStockout = 0.0;
            }

            // Track demand during stockout
            if (stockoutStart != null && movement.isOutbound) {
              demandDuringStockout += movementItem.quantity.abs();
            }
          }
        }
      }

      // Check if there's an ongoing stockout
      if (stockoutStart != null) {
        final duration = DateTime.now().difference(stockoutStart).inDays;
        final ongoingStockout = StockoutEvent(
          itemId: item.id,
          itemName: item.name,
          category: item.category,
          stockoutStart: stockoutStart,
          stockoutEnd: null,
          durationInDays: duration,
          demandDuringStockout: demandDuringStockout,
          estimatedLostSales: _estimateLostSales(item, demandDuringStockout),
          stockoutReason: _determineStockoutReason(item, null),
          reorderPoint: item.reorderPoint,
          safetyStock: item.minimumQuantity,
          leadTime: _getItemLeadTime(item),
        );
        stockoutEvents.add(ongoingStockout);
      }

      return stockoutEvents;
    } catch (e) {
      print('Error analyzing stockouts for item ${item.id}: $e');
      return [];
    }
  }

  /// Estimate lost sales during stockout
  double _estimateLostSales(InventoryItem item, double demandDuringStockout) {
    // Simple estimation: demand * unit cost
    // In practice, this could be more sophisticated using historical pricing
    return demandDuringStockout * (item.cost ?? 0.0);
  }

  /// Determine the likely reason for stockout
  StockoutReason _determineStockoutReason(
      InventoryItem item, dynamic movement) {
    // Simplified logic - in practice, this would analyze various factors
    if (item.quantity <= item.reorderPoint * 0.5) {
      return StockoutReason.planningError;
    } else if (item.additionalAttributes?['qualityIssues'] == true) {
      return StockoutReason.qualityIssues;
    } else {
      return StockoutReason.unexpectedDemand;
    }
  }

  /// Get item lead time from attributes
  int _getItemLeadTime(InventoryItem item) {
    return item.additionalAttributes?['leadTimeDays'] as int? ?? 7;
  }

  /// Generate category-level stockout analysis
  List<CategoryStockoutAnalysis> _generateCategoryAnalysis(
    List<StockoutEvent> stockoutEvents,
    int daysInPeriod,
  ) {
    final categoryGroups = <String, List<StockoutEvent>>{};

    // Group events by category
    for (final event in stockoutEvents) {
      categoryGroups.putIfAbsent(event.category, () => []).add(event);
    }

    // Generate analysis for each category
    return categoryGroups.entries.map((entry) {
      final category = entry.key;
      final events = entry.value;

      final totalStockouts = events.length;
      final totalStockoutDays =
          events.fold<int>(0, (sum, event) => sum + event.durationInDays);
      final averageStockoutDuration =
          totalStockouts > 0 ? totalStockoutDays / totalStockouts : 0.0;
      final stockoutRate =
          daysInPeriod > 0 ? (totalStockoutDays / daysInPeriod) * 100 : 0.0;
      final totalLostSales = events.fold<double>(
          0.0, (sum, event) => sum + event.estimatedLostSales);

      // Find most common reason
      final reasonCounts = <StockoutReason, int>{};
      for (final event in events) {
        reasonCounts[event.stockoutReason] =
            (reasonCounts[event.stockoutReason] ?? 0) + 1;
      }
      final mostCommonReason =
          reasonCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      final itemsAffected = events.map((e) => e.itemId).toSet().length;

      return CategoryStockoutAnalysis(
        category: category,
        totalStockouts: totalStockouts,
        totalStockoutDays: totalStockoutDays,
        averageStockoutDuration: averageStockoutDuration,
        stockoutRate: stockoutRate,
        totalLostSales: totalLostSales,
        mostCommonReason: mostCommonReason,
        itemsAffected: itemsAffected,
      );
    }).toList();
  }

  /// Get stockout trends over time
  Future<List<StockoutAnalysisResult>> getStockoutTrends({
    required DateTime startDate,
    required DateTime endDate,
    required Duration periodLength,
    String? categoryFilter,
  }) async {
    final trends = <StockoutAnalysisResult>[];
    var currentStart = startDate;

    while (currentStart.isBefore(endDate)) {
      final currentEnd = currentStart.add(periodLength);
      if (currentEnd.isAfter(endDate)) break;

      final result = await execute(
        periodStart: currentStart,
        periodEnd: currentEnd,
        categoryFilter: categoryFilter,
      );

      trends.add(result);
      currentStart = currentEnd;
    }

    return trends;
  }

  /// Get items at risk of stockout
  Future<List<InventoryItem>> getItemsAtRiskOfStockout() async {
    try {
      final items = await _repository.getItems();

      return items.where((item) {
        // Items below reorder point or with very low stock
        final isLowStock = item.quantity <= item.reorderPoint;
        final isCriticalStock = item.quantity <= item.minimumQuantity;

        return isLowStock || isCriticalStock;
      }).toList()
        ..sort((a, b) {
          // Sort by urgency (lowest stock ratio first)
          final aRatio = a.reorderPoint > 0 ? a.quantity / a.reorderPoint : 0;
          final bRatio = b.reorderPoint > 0 ? b.quantity / b.reorderPoint : 0;
          return aRatio.compareTo(bRatio);
        });
    } catch (e) {
      throw Exception('Failed to get items at risk of stockout: $e');
    }
  }
}

/// Provider for StockoutAnalysisUseCase
final stockoutAnalysisUseCaseProvider =
    Provider<StockoutAnalysisUseCase>((ref) {
  return StockoutAnalysisUseCase(
    ref.watch(repo_provider.inventoryRepositoryProvider),
  );
});
