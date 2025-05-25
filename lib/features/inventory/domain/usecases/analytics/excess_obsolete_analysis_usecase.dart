import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entities/inventory_item.dart';
import '../../repositories/inventory_repository.dart';
import '../../providers/inventory_repository_provider.dart' as repo_provider;

/// Excess and obsolete stock item data
class ExcessObsoleteItem {
  const ExcessObsoleteItem({
    required this.itemId,
    required this.itemName,
    required this.category,
    required this.currentQuantity,
    required this.currentValue,
    required this.lastMovementDate,
    required this.daysSinceLastMovement,
    required this.classification,
    required this.excessQuantity,
    required this.excessValue,
    required this.recommendedAction,
    required this.riskLevel,
    this.expiryDate,
    this.daysUntilExpiry,
  });

  final String itemId;
  final String itemName;
  final String category;
  final double currentQuantity;
  final double currentValue;
  final DateTime? lastMovementDate;
  final int daysSinceLastMovement;
  final EOClassification classification;
  final double excessQuantity;
  final double excessValue;
  final RecommendedAction recommendedAction;
  final RiskLevel riskLevel;
  final DateTime? expiryDate;
  final int? daysUntilExpiry;

  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());
  bool get isNearExpiry => daysUntilExpiry != null && daysUntilExpiry! <= 30;
}

/// E&O classification levels
enum EOClassification {
  slowMoving('Slow Moving', 'Low turnover but still moving'),
  excess('Excess', 'Quantity above optimal levels'),
  obsolete('Obsolete', 'No movement for extended period'),
  expired('Expired', 'Past expiration date'),
  nearExpiry('Near Expiry', 'Approaching expiration');

  const EOClassification(this.label, this.description);

  final String label;
  final String description;
}

/// Recommended actions for E&O items
enum RecommendedAction {
  monitor('Monitor', 'Continue monitoring movement'),
  reduce('Reduce Stock', 'Reduce future orders'),
  promote('Promote Sales', 'Marketing/sales promotion'),
  discount('Discount', 'Offer at reduced price'),
  liquidate('Liquidate', 'Sell at significant discount'),
  dispose('Dispose', 'Write off and dispose'),
  returnToSupplier('Return to Supplier', 'Return if possible'),
  rework('Rework', 'Rework or repackage');

  const RecommendedAction(this.label, this.description);

  final String label;
  final String description;
}

/// Risk levels for E&O items
enum RiskLevel {
  low('Low', 'Minimal financial impact'),
  medium('Medium', 'Moderate financial impact'),
  high('High', 'Significant financial impact'),
  critical('Critical', 'Major financial impact');

  const RiskLevel(this.label, this.description);

  final String label;
  final String description;
}

/// Category E&O analysis
class CategoryEOAnalysis {
  const CategoryEOAnalysis({
    required this.category,
    required this.totalValue,
    required this.excessValue,
    required this.obsoleteValue,
    required this.expiredValue,
    required this.totalItems,
    required this.excessItems,
    required this.obsoleteItems,
    required this.expiredItems,
    required this.averageDaysSinceMovement,
  });

  final String category;
  final double totalValue;
  final double excessValue;
  final double obsoleteValue;
  final double expiredValue;
  final int totalItems;
  final int excessItems;
  final int obsoleteItems;
  final int expiredItems;
  final double averageDaysSinceMovement;

  double get excessPercentage =>
      totalValue > 0 ? (excessValue / totalValue) * 100 : 0;
  double get obsoletePercentage =>
      totalValue > 0 ? (obsoleteValue / totalValue) * 100 : 0;
  double get expiredPercentage =>
      totalValue > 0 ? (expiredValue / totalValue) * 100 : 0;
}

/// Overall E&O analysis result
class ExcessObsoleteAnalysisResult {
  const ExcessObsoleteAnalysisResult({
    required this.totalInventoryValue,
    required this.totalExcessValue,
    required this.totalObsoleteValue,
    required this.totalExpiredValue,
    required this.excessObsoleteItems,
    required this.categoryAnalysis,
    required this.classificationBreakdown,
    required this.riskBreakdown,
    required this.criticalItems,
    required this.nearExpiryItems,
    required this.analysisDate,
    required this.agingThresholds,
  });

  final double totalInventoryValue;
  final double totalExcessValue;
  final double totalObsoleteValue;
  final double totalExpiredValue;
  final List<ExcessObsoleteItem> excessObsoleteItems;
  final List<CategoryEOAnalysis> categoryAnalysis;
  final Map<EOClassification, int> classificationBreakdown;
  final Map<RiskLevel, double> riskBreakdown;
  final List<ExcessObsoleteItem> criticalItems;
  final List<ExcessObsoleteItem> nearExpiryItems;
  final DateTime analysisDate;
  final AgingThresholds agingThresholds;

  double get totalEOValue =>
      totalExcessValue + totalObsoleteValue + totalExpiredValue;
  double get eoPercentage =>
      totalInventoryValue > 0 ? (totalEOValue / totalInventoryValue) * 100 : 0;
}

/// Aging thresholds for classification
class AgingThresholds {
  const AgingThresholds({
    this.slowMovingDays = 90,
    this.excessDays = 180,
    this.obsoleteDays = 365,
    this.nearExpiryDays = 30,
  });

  final int slowMovingDays;
  final int excessDays;
  final int obsoleteDays;
  final int nearExpiryDays;
}

/// Use case for analyzing excess and obsolete inventory
class ExcessObsoleteAnalysisUseCase {
  const ExcessObsoleteAnalysisUseCase(this._repository);

  final InventoryRepository _repository;

  /// Perform comprehensive E&O analysis
  Future<ExcessObsoleteAnalysisResult> execute({
    String? categoryFilter,
    List<String>? itemIdFilter,
    AgingThresholds? customThresholds,
  }) async {
    try {
      final thresholds = customThresholds ?? const AgingThresholds();

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

      // Analyze each item for E&O status
      final excessObsoleteItems = <ExcessObsoleteItem>[];
      double totalInventoryValue = 0.0;
      double totalExcessValue = 0.0;
      double totalObsoleteValue = 0.0;
      double totalExpiredValue = 0.0;

      for (final item in items) {
        final itemValue = item.quantity * (item.cost ?? 0.0);
        totalInventoryValue += itemValue;

        final eoItem = await _analyzeItemEO(item, thresholds);
        if (eoItem != null) {
          excessObsoleteItems.add(eoItem);

          switch (eoItem.classification) {
            case EOClassification.excess:
              totalExcessValue += eoItem.excessValue;
              break;
            case EOClassification.obsolete:
              totalObsoleteValue += eoItem.currentValue;
              break;
            case EOClassification.expired:
              totalExpiredValue += eoItem.currentValue;
              break;
            default:
              break;
          }
        }
      }

      // Generate category analysis
      final categoryAnalysis =
          _generateCategoryAnalysis(excessObsoleteItems, items);

      // Generate classification breakdown
      final classificationBreakdown = <EOClassification, int>{};
      for (final item in excessObsoleteItems) {
        classificationBreakdown[item.classification] =
            (classificationBreakdown[item.classification] ?? 0) + 1;
      }

      // Generate risk breakdown
      final riskBreakdown = <RiskLevel, double>{};
      for (final item in excessObsoleteItems) {
        riskBreakdown[item.riskLevel] =
            (riskBreakdown[item.riskLevel] ?? 0) + item.currentValue;
      }

      // Identify critical items (high value or high risk)
      final criticalItems = excessObsoleteItems
          .where((item) =>
              item.riskLevel == RiskLevel.critical ||
              item.currentValue > 10000) // High value threshold
          .toList()
        ..sort((a, b) => b.currentValue.compareTo(a.currentValue));

      // Identify near expiry items
      final nearExpiryItems = excessObsoleteItems
          .where((item) => item.isNearExpiry)
          .toList()
        ..sort((a, b) =>
            (a.daysUntilExpiry ?? 999).compareTo(b.daysUntilExpiry ?? 999));

      return ExcessObsoleteAnalysisResult(
        totalInventoryValue: totalInventoryValue,
        totalExcessValue: totalExcessValue,
        totalObsoleteValue: totalObsoleteValue,
        totalExpiredValue: totalExpiredValue,
        excessObsoleteItems: excessObsoleteItems,
        categoryAnalysis: categoryAnalysis,
        classificationBreakdown: classificationBreakdown,
        riskBreakdown: riskBreakdown,
        criticalItems: criticalItems,
        nearExpiryItems: nearExpiryItems,
        analysisDate: DateTime.now(),
        agingThresholds: thresholds,
      );
    } catch (e) {
      throw Exception('Failed to analyze excess and obsolete inventory: $e');
    }
  }

  /// Analyze a specific item for E&O status
  Future<ExcessObsoleteItem?> _analyzeItemEO(
    InventoryItem item,
    AgingThresholds thresholds,
  ) async {
    try {
      // Get last movement date
      final movements = await _repository.getMovementsForItem(item.id);
      final lastMovement = movements.isNotEmpty
          ? movements
              .reduce((a, b) => a.movementDate.isAfter(b.movementDate) ? a : b)
          : null;

      final lastMovementDate = lastMovement?.movementDate;
      final daysSinceLastMovement = lastMovementDate != null
          ? DateTime.now().difference(lastMovementDate).inDays
          : 999; // Very high number for items with no movements

      // Check expiry status
      final daysUntilExpiry = item.expiryDate != null
          ? item.expiryDate!.difference(DateTime.now()).inDays
          : null;

      // Determine classification
      final classification = _classifyItem(
        daysSinceLastMovement,
        daysUntilExpiry,
        thresholds,
      );

      // Only include items that are classified as E&O
      if (classification == null) return null;

      final currentValue = item.quantity * (item.cost ?? 0.0);

      // Calculate excess quantity and value
      final (excessQuantity, excessValue) =
          _calculateExcess(item, classification);

      // Determine recommended action
      final recommendedAction = _determineRecommendedAction(
        classification,
        currentValue,
        daysUntilExpiry,
        daysSinceLastMovement,
      );

      // Determine risk level
      final riskLevel =
          _determineRiskLevel(currentValue, classification, daysUntilExpiry);

      return ExcessObsoleteItem(
        itemId: item.id,
        itemName: item.name,
        category: item.category,
        currentQuantity: item.quantity,
        currentValue: currentValue,
        lastMovementDate: lastMovementDate,
        daysSinceLastMovement: daysSinceLastMovement,
        classification: classification,
        excessQuantity: excessQuantity,
        excessValue: excessValue,
        recommendedAction: recommendedAction,
        riskLevel: riskLevel,
        expiryDate: item.expiryDate,
        daysUntilExpiry: daysUntilExpiry,
      );
    } catch (e) {
      print('Error analyzing E&O for item ${item.id}: $e');
      return null;
    }
  }

  /// Classify item based on aging and expiry
  EOClassification? _classifyItem(
    int daysSinceLastMovement,
    int? daysUntilExpiry,
    AgingThresholds thresholds,
  ) {
    // Check expiry first (highest priority)
    if (daysUntilExpiry != null) {
      if (daysUntilExpiry <= 0) {
        return EOClassification.expired;
      } else if (daysUntilExpiry <= thresholds.nearExpiryDays) {
        return EOClassification.nearExpiry;
      }
    }

    // Check aging
    if (daysSinceLastMovement >= thresholds.obsoleteDays) {
      return EOClassification.obsolete;
    } else if (daysSinceLastMovement >= thresholds.excessDays) {
      return EOClassification.excess;
    } else if (daysSinceLastMovement >= thresholds.slowMovingDays) {
      return EOClassification.slowMoving;
    }

    return null; // Not classified as E&O
  }

  /// Calculate excess quantity and value
  (double, double) _calculateExcess(
      InventoryItem item, EOClassification classification) {
    switch (classification) {
      case EOClassification.excess:
      case EOClassification.obsolete:
      case EOClassification.expired:
        // For these classifications, consider all quantity as excess
        return (item.quantity, item.quantity * (item.cost ?? 0.0));
      case EOClassification.slowMoving:
        // For slow moving, consider quantity above reorder point as excess
        final excessQty =
            (item.quantity - item.reorderPoint).clamp(0.0, item.quantity);
        return (excessQty, excessQty * (item.cost ?? 0.0));
      case EOClassification.nearExpiry:
        // For near expiry, all quantity is at risk
        return (item.quantity, item.quantity * (item.cost ?? 0.0));
    }
  }

  /// Determine recommended action
  RecommendedAction _determineRecommendedAction(
    EOClassification classification,
    double currentValue,
    int? daysUntilExpiry,
    int daysSinceLastMovement,
  ) {
    switch (classification) {
      case EOClassification.expired:
        return RecommendedAction.dispose;
      case EOClassification.nearExpiry:
        return daysUntilExpiry != null && daysUntilExpiry <= 7
            ? RecommendedAction.discount
            : RecommendedAction.promote;
      case EOClassification.obsolete:
        return currentValue > 5000
            ? RecommendedAction.liquidate
            : RecommendedAction.dispose;
      case EOClassification.excess:
        return daysSinceLastMovement > 270
            ? RecommendedAction.discount
            : RecommendedAction.reduce;
      case EOClassification.slowMoving:
        return RecommendedAction.monitor;
    }
  }

  /// Determine risk level
  RiskLevel _determineRiskLevel(
    double currentValue,
    EOClassification classification,
    int? daysUntilExpiry,
  ) {
    // High value items are always higher risk
    if (currentValue > 50000) {
      return RiskLevel.critical;
    } else if (currentValue > 20000) {
      return RiskLevel.high;
    }

    // Classification-based risk
    switch (classification) {
      case EOClassification.expired:
      case EOClassification.obsolete:
        return currentValue > 10000 ? RiskLevel.high : RiskLevel.medium;
      case EOClassification.nearExpiry:
        return daysUntilExpiry != null && daysUntilExpiry <= 7
            ? RiskLevel.high
            : RiskLevel.medium;
      case EOClassification.excess:
        return currentValue > 5000 ? RiskLevel.medium : RiskLevel.low;
      case EOClassification.slowMoving:
        return RiskLevel.low;
    }
  }

  /// Generate category-level E&O analysis
  List<CategoryEOAnalysis> _generateCategoryAnalysis(
    List<ExcessObsoleteItem> eoItems,
    List<InventoryItem> allItems,
  ) {
    final categoryGroups = <String, List<InventoryItem>>{};
    final categoryEOGroups = <String, List<ExcessObsoleteItem>>{};

    // Group all items by category
    for (final item in allItems) {
      categoryGroups.putIfAbsent(item.category, () => []).add(item);
    }

    // Group E&O items by category
    for (final item in eoItems) {
      categoryEOGroups.putIfAbsent(item.category, () => []).add(item);
    }

    // Generate analysis for each category
    return categoryGroups.entries.map((entry) {
      final category = entry.key;
      final allCategoryItems = entry.value;
      final eoItemsInCategory = categoryEOGroups[category] ?? [];

      final totalValue = allCategoryItems.fold<double>(
          0.0, (sum, item) => sum + (item.quantity * (item.cost ?? 0.0)));

      final excessValue = eoItemsInCategory
          .where((item) => item.classification == EOClassification.excess)
          .fold<double>(0.0, (sum, item) => sum + item.excessValue);

      final obsoleteValue = eoItemsInCategory
          .where((item) => item.classification == EOClassification.obsolete)
          .fold<double>(0.0, (sum, item) => sum + item.currentValue);

      final expiredValue = eoItemsInCategory
          .where((item) => item.classification == EOClassification.expired)
          .fold<double>(0.0, (sum, item) => sum + item.currentValue);

      final excessItems = eoItemsInCategory
          .where((item) => item.classification == EOClassification.excess)
          .length;

      final obsoleteItems = eoItemsInCategory
          .where((item) => item.classification == EOClassification.obsolete)
          .length;

      final expiredItems = eoItemsInCategory
          .where((item) => item.classification == EOClassification.expired)
          .length;

      final averageDaysSinceMovement = eoItemsInCategory.isNotEmpty
          ? eoItemsInCategory.fold<double>(
                  0.0, (sum, item) => sum + item.daysSinceLastMovement) /
              eoItemsInCategory.length
          : 0.0;

      return CategoryEOAnalysis(
        category: category,
        totalValue: totalValue,
        excessValue: excessValue,
        obsoleteValue: obsoleteValue,
        expiredValue: expiredValue,
        totalItems: allCategoryItems.length,
        excessItems: excessItems,
        obsoleteItems: obsoleteItems,
        expiredItems: expiredItems,
        averageDaysSinceMovement: averageDaysSinceMovement,
      );
    }).toList();
  }

  /// Get E&O trends over time
  Future<List<ExcessObsoleteAnalysisResult>> getEOTrends({
    required List<DateTime> analysisPoints,
    String? categoryFilter,
    AgingThresholds? customThresholds,
  }) async {
    final trends = <ExcessObsoleteAnalysisResult>[];

    for (final analysisPoint in analysisPoints) {
      // Note: This is a simplified implementation
      // In practice, you'd need historical inventory snapshots
      final result = await execute(
        categoryFilter: categoryFilter,
        customThresholds: customThresholds,
      );
      trends.add(result);
    }

    return trends;
  }

  /// Get disposal recommendations
  List<ExcessObsoleteItem> getDisposalRecommendations(
    ExcessObsoleteAnalysisResult analysis,
  ) {
    return analysis.excessObsoleteItems
        .where((item) =>
            item.recommendedAction == RecommendedAction.dispose ||
            item.recommendedAction == RecommendedAction.liquidate)
        .toList()
      ..sort((a, b) => b.currentValue.compareTo(a.currentValue));
  }
}

/// Provider for ExcessObsoleteAnalysisUseCase
final excessObsoleteAnalysisUseCaseProvider =
    Provider<ExcessObsoleteAnalysisUseCase>((ref) {
  return ExcessObsoleteAnalysisUseCase(
    ref.watch(repo_provider.inventoryRepositoryProvider),
  );
});
