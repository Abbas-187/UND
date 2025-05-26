import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entities/inventory_item.dart';
import '../../providers/inventory_repository_provider.dart' as repo_provider;
import '../../repositories/inventory_repository.dart';

/// Inventory turnover analysis data
class InventoryTurnoverData {
  const InventoryTurnoverData({
    required this.itemId,
    required this.itemName,
    required this.category,
    required this.turnoverRate,
    required this.averageInventoryValue,
    required this.costOfGoodsSold,
    required this.daysInPeriod,
    required this.daysOfSupply,
    required this.turnoverClassification,
  });

  final String itemId;
  final String itemName;
  final String category;
  final double turnoverRate;
  final double averageInventoryValue;
  final double costOfGoodsSold;
  final int daysInPeriod;
  final double daysOfSupply;
  final TurnoverClassification turnoverClassification;

  /// Calculate annual turnover rate
  double get annualTurnoverRate => turnoverRate * (365.0 / daysInPeriod);
}

/// Turnover classification based on rate
enum TurnoverClassification {
  fast('Fast Moving', 'High turnover rate'),
  medium('Medium Moving', 'Moderate turnover rate'),
  slow('Slow Moving', 'Low turnover rate'),
  obsolete('Obsolete', 'No movement in period');

  const TurnoverClassification(this.label, this.description);

  final String label;
  final String description;
}

/// Category turnover summary
class CategoryTurnoverSummary {
  const CategoryTurnoverSummary({
    required this.category,
    required this.totalValue,
    required this.averageTurnoverRate,
    required this.fastMovingItems,
    required this.slowMovingItems,
    required this.obsoleteItems,
    required this.totalItems,
  });

  final String category;
  final double totalValue;
  final double averageTurnoverRate;
  final int fastMovingItems;
  final int slowMovingItems;
  final int obsoleteItems;
  final int totalItems;

  double get fastMovingPercentage => (fastMovingItems / totalItems) * 100;
  double get slowMovingPercentage => (slowMovingItems / totalItems) * 100;
  double get obsoletePercentage => (obsoleteItems / totalItems) * 100;
}

/// Overall turnover analysis result
class TurnoverAnalysisResult {
  const TurnoverAnalysisResult({
    required this.overallTurnoverRate,
    required this.totalInventoryValue,
    required this.totalCOGS,
    required this.itemTurnoverData,
    required this.categoryTurnoverSummaries,
    required this.topPerformers,
    required this.bottomPerformers,
    required this.analysisDate,
    required this.periodStart,
    required this.periodEnd,
  });

  final double overallTurnoverRate;
  final double totalInventoryValue;
  final double totalCOGS;
  final List<InventoryTurnoverData> itemTurnoverData;
  final List<CategoryTurnoverSummary> categoryTurnoverSummaries;
  final List<InventoryTurnoverData> topPerformers;
  final List<InventoryTurnoverData> bottomPerformers;
  final DateTime analysisDate;
  final DateTime periodStart;
  final DateTime periodEnd;

  int get daysInPeriod => periodEnd.difference(periodStart).inDays;
  double get daysOfSupply => daysInPeriod / overallTurnoverRate;
}

/// Use case for calculating inventory turnover rates
class InventoryTurnoverUseCase {
  const InventoryTurnoverUseCase(this._repository);

  final InventoryRepository _repository;

  /// Calculate comprehensive turnover analysis
  Future<TurnoverAnalysisResult> execute({
    required DateTime periodStart,
    required DateTime periodEnd,
    String? categoryFilter,
    List<String>? itemIdFilter,
    int topPerformersCount = 10,
    int bottomPerformersCount = 10,
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

      // Calculate turnover data for each item
      final itemTurnoverData = <InventoryTurnoverData>[];
      double totalCOGS = 0.0;
      double totalInventoryValue = 0.0;

      for (final item in items) {
        final turnoverData = await _calculateItemTurnover(
          item,
          periodStart,
          periodEnd,
        );

        if (turnoverData != null) {
          itemTurnoverData.add(turnoverData);
          totalCOGS += turnoverData.costOfGoodsSold;
          totalInventoryValue += turnoverData.averageInventoryValue;
        }
      }

      // Calculate overall turnover rate
      final overallTurnoverRate =
          totalInventoryValue > 0 ? totalCOGS / totalInventoryValue : 0.0;

      // Generate category summaries
      final categoryTurnoverSummaries =
          _generateCategorySummaries(itemTurnoverData);

      // Identify top and bottom performers
      final sortedByTurnover =
          List<InventoryTurnoverData>.from(itemTurnoverData)
            ..sort((a, b) => b.turnoverRate.compareTo(a.turnoverRate));

      final topPerformers = sortedByTurnover.take(topPerformersCount).toList();

      final bottomPerformers = sortedByTurnover.reversed
          .take(bottomPerformersCount)
          .toList()
          .reversed
          .toList();

      return TurnoverAnalysisResult(
        overallTurnoverRate: overallTurnoverRate,
        totalInventoryValue: totalInventoryValue,
        totalCOGS: totalCOGS,
        itemTurnoverData: itemTurnoverData,
        categoryTurnoverSummaries: categoryTurnoverSummaries,
        topPerformers: topPerformers,
        bottomPerformers: bottomPerformers,
        analysisDate: DateTime.now(),
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
    } catch (e) {
      throw Exception('Failed to calculate inventory turnover: $e');
    }
  }

  /// Calculate turnover for a specific item
  Future<InventoryTurnoverData?> _calculateItemTurnover(
    InventoryItem item,
    DateTime periodStart,
    DateTime periodEnd,
  ) async {
    try {
      // Get item movements for the period
      final movements = await _repository.getMovementsForItem(item.id);
      final periodMovements = movements
          .where((movement) =>
              movement.movementDate.isAfter(periodStart) &&
              movement.movementDate.isBefore(periodEnd))
          .toList();

      // Calculate COGS (cost of goods sold) for outbound movements
      double cogs = 0.0;
      for (final movement in periodMovements) {
        if (movement.isOutbound) {
          for (final movementItem in movement.items) {
            if (movementItem.itemId == item.id) {
              cogs += (movementItem.costAtTransaction ?? 0.0) *
                  movementItem.quantity.abs();
            }
          }
        }
      }

      // Calculate average inventory value during the period
      final averageInventoryValue = await _calculateAverageInventoryValue(
        item,
        periodStart,
        periodEnd,
      );

      // Calculate turnover rate
      final turnoverRate =
          averageInventoryValue > 0 ? cogs / averageInventoryValue : 0.0;

      // Calculate days of supply
      final daysInPeriod = periodEnd.difference(periodStart).inDays;
      final daysOfSupply =
          turnoverRate > 0 ? daysInPeriod / turnoverRate : double.infinity;

      // Classify turnover
      final classification = _classifyTurnover(turnoverRate, daysOfSupply);

      return InventoryTurnoverData(
        itemId: item.id,
        itemName: item.name,
        category: item.category,
        turnoverRate: turnoverRate,
        averageInventoryValue: averageInventoryValue,
        costOfGoodsSold: cogs,
        daysInPeriod: daysInPeriod,
        daysOfSupply: daysOfSupply,
        turnoverClassification: classification,
      );
    } catch (e) {
      // Log error and return null for this item
      print('Error calculating turnover for item ${item.id}: $e');
      return null;
    }
  }

  /// Calculate average inventory value for an item during the period
  Future<double> _calculateAverageInventoryValue(
    InventoryItem item,
    DateTime periodStart,
    DateTime periodEnd,
  ) async {
    try {
      // For simplicity, use current inventory value as approximation
      // In a more sophisticated implementation, this would calculate
      // daily inventory values and average them over the period
      final currentValue = item.quantity * (item.cost ?? 0.0);

      // TODO: Implement more accurate average calculation using daily snapshots
      // This would require storing or calculating historical inventory levels

      return currentValue;
    } catch (e) {
      return 0.0;
    }
  }

  /// Classify turnover rate
  TurnoverClassification _classifyTurnover(
      double turnoverRate, double daysOfSupply) {
    if (turnoverRate == 0.0) {
      return TurnoverClassification.obsolete;
    } else if (daysOfSupply <= 30) {
      return TurnoverClassification.fast;
    } else if (daysOfSupply <= 90) {
      return TurnoverClassification.medium;
    } else {
      return TurnoverClassification.slow;
    }
  }

  /// Generate category turnover summaries
  List<CategoryTurnoverSummary> _generateCategorySummaries(
    List<InventoryTurnoverData> itemData,
  ) {
    final categoryGroups = <String, List<InventoryTurnoverData>>{};

    // Group items by category
    for (final item in itemData) {
      categoryGroups.putIfAbsent(item.category, () => []).add(item);
    }

    // Generate summary for each category
    return categoryGroups.entries.map((entry) {
      final category = entry.key;
      final items = entry.value;

      final totalValue = items.fold<double>(
          0.0, (sum, item) => sum + item.averageInventoryValue);
      final averageTurnoverRate = items.isNotEmpty
          ? items.fold<double>(0.0, (sum, item) => sum + item.turnoverRate) /
              items.length
          : 0.0;

      final fastMovingItems = items
          .where((item) =>
              item.turnoverClassification == TurnoverClassification.fast)
          .length;
      final slowMovingItems = items
          .where((item) =>
              item.turnoverClassification == TurnoverClassification.slow)
          .length;
      final obsoleteItems = items
          .where((item) =>
              item.turnoverClassification == TurnoverClassification.obsolete)
          .length;

      return CategoryTurnoverSummary(
        category: category,
        totalValue: totalValue,
        averageTurnoverRate: averageTurnoverRate,
        fastMovingItems: fastMovingItems,
        slowMovingItems: slowMovingItems,
        obsoleteItems: obsoleteItems,
        totalItems: items.length,
      );
    }).toList();
  }

  /// Get turnover trends over multiple periods
  Future<List<TurnoverAnalysisResult>> getTurnoverTrends({
    required DateTime startDate,
    required DateTime endDate,
    required Duration periodLength,
    String? categoryFilter,
  }) async {
    final trends = <TurnoverAnalysisResult>[];
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
}

/// Provider for InventoryTurnoverUseCase
final inventoryTurnoverUseCaseProvider =
    Provider<InventoryTurnoverUseCase>((ref) {
  return InventoryTurnoverUseCase(
    ref.watch(repo_provider.inventoryRepositoryProvider),
  );
});
