import '../../../procurement/domain/entities/purchase_order.dart';
import '../../../procurement/domain/services/supplier_quote_service.dart';

class BomProcurementIntegrationUseCase {
  final SupplierQuoteService _supplierQuoteService;

  BomProcurementIntegrationUseCase({
    required SupplierQuoteService supplierQuoteService,
  }) : _supplierQuoteService = supplierQuoteService;

  // Generate comprehensive procurement recommendations for a BOM
  Future<BomProcurementAnalysis> analyzeBomProcurement(
    String bomId,
    double batchSize, {
    OptimizationCriteria? customCriteria,
    bool includeAlternatives = true,
    bool calculateTCO = true,
  }) async {
    try {
      // Use default criteria if not provided
      final criteria = customCriteria ??
          OptimizationCriteria(
            priceWeight: 0.4,
            qualityWeight: 0.3,
            deliveryWeight: 0.2,
            leadTimeWeight: 0.1,
          );

      // Generate base recommendations
      final recommendations =
          await _supplierQuoteService.generateRecommendations(bomId, batchSize);

      // Calculate total cost of ownership if requested
      Map<String, double> tcoAnalysis = {};
      if (calculateTCO) {
        tcoAnalysis = await _calculateTCOForRecommendations(recommendations);
      }

      // Find alternative suppliers if requested
      Map<String, List<SupplierAlternative>> alternatives = {};
      if (includeAlternatives) {
        alternatives = await _findAlternativeSuppliers(recommendations);
      }

      // Analyze cost breakdown
      final costBreakdown = _analyzeCostBreakdown(recommendations);

      // Generate procurement insights
      final insights = _generateProcurementInsights(
        recommendations,
        tcoAnalysis,
        alternatives,
      );

      return BomProcurementAnalysis(
        bomId: bomId,
        batchSize: batchSize,
        recommendations: recommendations,
        costBreakdown: costBreakdown,
        tcoAnalysis: tcoAnalysis,
        alternatives: alternatives,
        insights: insights,
        optimizationCriteria: criteria,
        analyzedAt: DateTime.now(),
      );
    } catch (e) {
      throw BomProcurementException('Failed to analyze BOM procurement: $e');
    }
  }

  // Create optimized purchase orders from BOM
  Future<BomPurchaseOrderResult> createPurchaseOrdersFromBom(
    String bomId,
    double batchSize,
    String requestedBy, {
    OptimizationCriteria? customCriteria,
    bool groupBySupplier = true,
    bool optimizeDelivery = true,
    Map<String, String>? supplierPreferences, // itemId -> preferred supplierId
  }) async {
    try {
      // Apply supplier preferences if provided
      if (supplierPreferences != null && supplierPreferences.isNotEmpty) {
        await _applySupplierPreferences(bomId, supplierPreferences);
      }

      // Generate purchase orders
      final purchaseOrders = await _supplierQuoteService
          .generatePurchaseOrdersFromBom(bomId, batchSize, requestedBy);

      // Optimize delivery schedules if requested
      if (optimizeDelivery) {
        await _optimizeDeliverySchedules(purchaseOrders);
      }

      // Calculate summary metrics
      final summary = _calculatePOSummary(purchaseOrders);

      // Generate recommendations for the created POs
      final recommendations = _generatePORecommendations(
        purchaseOrders,
        summary,
      );

      return BomPurchaseOrderResult(
        bomId: bomId,
        batchSize: batchSize,
        purchaseOrders: purchaseOrders,
        summary: summary,
        recommendations: recommendations,
        createdAt: DateTime.now(),
        createdBy: requestedBy,
      );
    } catch (e) {
      throw BomProcurementException('Failed to create purchase orders: $e');
    }
  }

  // Compare supplier options for specific BOM items
  Future<BomSupplierComparison> compareSuppliers(
    String bomId,
    List<String> itemIds, {
    OptimizationCriteria? criteria,
    bool includeHistoricalData = true,
  }) async {
    try {
      final comparisons = <String, ItemSupplierComparison>{};

      for (final itemId in itemIds) {
        final quotes =
            await _supplierQuoteService.getQuotesForItem(itemId, 1.0);

        if (quotes.isNotEmpty) {
          final comparison = await _compareItemSuppliers(
            itemId,
            quotes,
            criteria,
            includeHistoricalData,
          );
          comparisons[itemId] = comparison;
        }
      }

      final insights = _generateSupplierInsights(comparisons);

      return BomSupplierComparison(
        bomId: bomId,
        itemComparisons: comparisons,
        insights: insights,
        comparedAt: DateTime.now(),
      );
    } catch (e) {
      throw BomProcurementException('Failed to compare suppliers: $e');
    }
  }

  // Optimize procurement timing for BOM
  Future<BomProcurementSchedule> optimizeProcurementTiming(
    String bomId,
    double batchSize,
    DateTime productionStartDate, {
    int bufferDays = 5,
    bool considerLeadTimes = true,
    bool optimizeForCost = true,
  }) async {
    try {
      final recommendations =
          await _supplierQuoteService.generateRecommendations(bomId, batchSize);

      final scheduleItems = <ProcurementScheduleItem>[];

      for (final rec in recommendations.recommendations) {
        final orderDate = _calculateOptimalOrderDate(
          productionStartDate,
          rec.leadTimeDays,
          bufferDays,
          optimizeForCost,
        );

        scheduleItems.add(ProcurementScheduleItem(
          itemId: rec.itemId,
          itemCode: rec.itemCode,
          itemName: rec.itemName,
          supplierId: rec.selectedSupplier,
          supplierName: rec.supplierName,
          quantity: rec.recommendedQuantity,
          unitPrice: rec.unitPrice,
          totalCost: rec.totalCost,
          leadTimeDays: rec.leadTimeDays,
          recommendedOrderDate: orderDate,
          expectedDeliveryDate: orderDate.add(Duration(days: rec.leadTimeDays)),
          priority: _calculateProcurementPriority(rec, productionStartDate),
        ));
      }

      // Sort by recommended order date
      scheduleItems.sort(
          (a, b) => a.recommendedOrderDate.compareTo(b.recommendedOrderDate));

      final insights =
          _generateScheduleInsights(scheduleItems, productionStartDate);

      return BomProcurementSchedule(
        bomId: bomId,
        batchSize: batchSize,
        productionStartDate: productionStartDate,
        scheduleItems: scheduleItems,
        insights: insights,
        totalEstimatedCost:
            scheduleItems.fold(0.0, (sum, item) => sum + item.totalCost),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw BomProcurementException(
          'Failed to optimize procurement timing: $e');
    }
  }

  // Private helper methods
  Future<Map<String, double>> _calculateTCOForRecommendations(
    ProcurementRecommendation recommendations,
  ) async {
    final tcoAnalysis = <String, double>{};

    for (final rec in recommendations.recommendations) {
      // Create a mock quote for TCO calculation
      final quote = SupplierQuote(
        id: 'temp_${rec.itemId}',
        supplierId: rec.selectedSupplier,
        supplierName: rec.supplierName,
        itemId: rec.itemId,
        unitPrice: rec.unitPrice,
        currency: 'USD',
        leadTimeDays: rec.leadTimeDays,
        minimumOrderQuantity: 1.0,
        validUntil: DateTime.now().add(const Duration(days: 30)),
      );

      final tco = await _supplierQuoteService.calculateTotalCostOfOwnership(
        quote,
        rec.recommendedQuantity,
      );

      tcoAnalysis[rec.itemId] = tco;
    }

    return tcoAnalysis;
  }

  Future<Map<String, List<SupplierAlternative>>> _findAlternativeSuppliers(
    ProcurementRecommendation recommendations,
  ) async {
    final alternatives = <String, List<SupplierAlternative>>{};

    for (final rec in recommendations.recommendations) {
      final quotes = await _supplierQuoteService.getQuotesForItem(
        rec.itemId,
        rec.recommendedQuantity,
      );

      final alternativeQuotes = quotes
          .where((q) => q.supplierId != rec.selectedSupplier)
          .take(3)
          .toList();

      alternatives[rec.itemId] = alternativeQuotes
          .map((quote) => SupplierAlternative(
                supplierId: quote.supplierId,
                supplierName: quote.supplierName,
                unitPrice: quote.unitPrice,
                leadTimeDays: quote.leadTimeDays,
                qualityRating: quote.qualityRating,
                deliveryRating: quote.deliveryRating,
                priceDifference: quote.unitPrice - rec.unitPrice,
                leadTimeDifference: quote.leadTimeDays - rec.leadTimeDays,
              ))
          .toList();
    }

    return alternatives;
  }

  ProcurementCostBreakdown _analyzeCostBreakdown(
    ProcurementRecommendation recommendations,
  ) {
    final itemCosts = <String, double>{};
    final supplierCosts = <String, double>{};

    double totalCost = 0.0;
    double highestItemCost = 0.0;
    String mostExpensiveItem = '';

    for (final rec in recommendations.recommendations) {
      itemCosts[rec.itemCode] = rec.totalCost;
      supplierCosts[rec.supplierName] =
          (supplierCosts[rec.supplierName] ?? 0) + rec.totalCost;

      totalCost += rec.totalCost;

      if (rec.totalCost > highestItemCost) {
        highestItemCost = rec.totalCost;
        mostExpensiveItem = rec.itemCode;
      }
    }

    return ProcurementCostBreakdown(
      totalCost: totalCost,
      itemCosts: itemCosts,
      supplierCosts: supplierCosts,
      mostExpensiveItem: mostExpensiveItem,
      mostExpensiveItemCost: highestItemCost,
      averageItemCost: totalCost / itemCosts.length,
    );
  }

  List<String> _generateProcurementInsights(
    ProcurementRecommendation recommendations,
    Map<String, double> tcoAnalysis,
    Map<String, List<SupplierAlternative>> alternatives,
  ) {
    final insights = <String>[];

    // Cost insights
    if (recommendations.totalEstimatedCost > 10000) {
      insights.add('High-value procurement - consider bulk discounts');
    }

    // Lead time insights
    if (recommendations.averageLeadTime > 14) {
      insights.add('Long lead times detected - plan procurement early');
    }

    // Supplier diversity insights
    final uniqueSuppliers = recommendations.recommendations
        .map((r) => r.selectedSupplier)
        .toSet()
        .length;
    if (uniqueSuppliers < recommendations.recommendations.length * 0.5) {
      insights.add('Consider diversifying suppliers to reduce risk');
    }

    // TCO insights
    if (tcoAnalysis.isNotEmpty) {
      final avgTCOIncrease = tcoAnalysis.values
              .map((tco) => tco / recommendations.totalEstimatedCost)
              .reduce((a, b) => a + b) /
          tcoAnalysis.length;
      if (avgTCOIncrease > 1.2) {
        insights.add('TCO is 20%+ higher than base cost - review hidden costs');
      }
    }

    return insights;
  }

  Future<ItemSupplierComparison> _compareItemSuppliers(
    String itemId,
    List<SupplierQuote> quotes,
    OptimizationCriteria? criteria,
    bool includeHistoricalData,
  ) async {
    final defaultCriteria = criteria ??
        OptimizationCriteria(
          priceWeight: 0.4,
          qualityWeight: 0.3,
          deliveryWeight: 0.2,
          leadTimeWeight: 0.1,
        );

    final bestQuote = await _supplierQuoteService.selectOptimalSupplier(
      quotes,
      defaultCriteria,
    );

    final supplierScores = <String, double>{};
    for (final quote in quotes) {
      // This would need actual scoring implementation
      supplierScores[quote.supplierId] = 0.8; // Placeholder
    }

    return ItemSupplierComparison(
      itemId: itemId,
      quotes: quotes,
      recommendedSupplier: bestQuote.supplierId,
      supplierScores: supplierScores,
      priceRange: PriceRange(
        min: quotes.map((q) => q.unitPrice).reduce((a, b) => a < b ? a : b),
        max: quotes.map((q) => q.unitPrice).reduce((a, b) => a > b ? a : b),
        average: quotes.map((q) => q.unitPrice).reduce((a, b) => a + b) /
            quotes.length,
      ),
      leadTimeRange: LeadTimeRange(
        min: quotes.map((q) => q.leadTimeDays).reduce((a, b) => a < b ? a : b),
        max: quotes.map((q) => q.leadTimeDays).reduce((a, b) => a > b ? a : b),
        average: quotes.map((q) => q.leadTimeDays).reduce((a, b) => a + b) ~/
            quotes.length,
      ),
    );
  }

  List<String> _generateSupplierInsights(
    Map<String, ItemSupplierComparison> comparisons,
  ) {
    final insights = <String>[];

    // Price variance insights
    final highVarianceItems = comparisons.entries
        .where((entry) =>
            (entry.value.priceRange.max - entry.value.priceRange.min) /
                entry.value.priceRange.average >
            0.3)
        .map((entry) => entry.key)
        .toList();

    if (highVarianceItems.isNotEmpty) {
      insights.add(
          'High price variance detected for ${highVarianceItems.length} items');
    }

    return insights;
  }

  DateTime _calculateOptimalOrderDate(
    DateTime productionStartDate,
    int leadTimeDays,
    int bufferDays,
    bool optimizeForCost,
  ) {
    final requiredDeliveryDate =
        productionStartDate.subtract(Duration(days: bufferDays));
    final baseOrderDate =
        requiredDeliveryDate.subtract(Duration(days: leadTimeDays));

    if (optimizeForCost) {
      // Add extra days for potential cost savings
      return baseOrderDate.subtract(const Duration(days: 3));
    }

    return baseOrderDate;
  }

  int _calculateProcurementPriority(
    RecommendedPurchase rec,
    DateTime productionStartDate,
  ) {
    // Higher priority for items with longer lead times or higher costs
    if (rec.leadTimeDays > 14 || rec.totalCost > 5000) {
      return 1; // High priority
    } else if (rec.leadTimeDays > 7 || rec.totalCost > 1000) {
      return 2; // Medium priority
    } else {
      return 3; // Low priority
    }
  }

  List<String> _generateScheduleInsights(
    List<ProcurementScheduleItem> scheduleItems,
    DateTime productionStartDate,
  ) {
    final insights = <String>[];

    final highPriorityItems =
        scheduleItems.where((item) => item.priority == 1).length;
    if (highPriorityItems > 0) {
      insights.add(
          '$highPriorityItems high-priority items require immediate ordering');
    }

    final earlyOrderDate = scheduleItems.first.recommendedOrderDate;
    final daysUntilFirstOrder =
        earlyOrderDate.difference(DateTime.now()).inDays;
    if (daysUntilFirstOrder < 0) {
      insights.add(
          'Some items should have been ordered already - expedite procurement');
    } else if (daysUntilFirstOrder < 3) {
      insights.add(
          'First orders needed within 3 days - prepare procurement immediately');
    }

    return insights;
  }

  // Placeholder methods for future implementation
  Future<void> _applySupplierPreferences(
    String bomId,
    Map<String, String> preferences,
  ) async {
    // Implementation would apply supplier preferences to quote selection
  }

  Future<void> _optimizeDeliverySchedules(
      List<PurchaseOrder> purchaseOrders) async {
    // Implementation would optimize delivery dates across POs
  }

  PurchaseOrderSummary _calculatePOSummary(List<PurchaseOrder> purchaseOrders) {
    final totalAmount =
        purchaseOrders.fold<double>(0, (sum, po) => sum + po.totalAmount);
    final uniqueSuppliers =
        purchaseOrders.map((po) => po.supplierId).toSet().length;
    final totalItems =
        purchaseOrders.fold<int>(0, (sum, po) => sum + po.items.length);

    return PurchaseOrderSummary(
      totalOrders: purchaseOrders.length,
      totalAmount: totalAmount,
      uniqueSuppliers: uniqueSuppliers,
      totalItems: totalItems,
      averageOrderValue: totalAmount / purchaseOrders.length,
    );
  }

  List<String> _generatePORecommendations(
    List<PurchaseOrder> purchaseOrders,
    PurchaseOrderSummary summary,
  ) {
    final recommendations = <String>[];

    if (summary.totalAmount > 50000) {
      recommendations.add('High-value procurement - ensure proper approvals');
    }

    if (summary.uniqueSuppliers < 3) {
      recommendations.add('Consider adding more suppliers for risk mitigation');
    }

    return recommendations;
  }
}

// Supporting classes
class BomProcurementAnalysis {
  final String bomId;
  final double batchSize;
  final ProcurementRecommendation recommendations;
  final ProcurementCostBreakdown costBreakdown;
  final Map<String, double> tcoAnalysis;
  final Map<String, List<SupplierAlternative>> alternatives;
  final List<String> insights;
  final OptimizationCriteria optimizationCriteria;
  final DateTime analyzedAt;

  BomProcurementAnalysis({
    required this.bomId,
    required this.batchSize,
    required this.recommendations,
    required this.costBreakdown,
    required this.tcoAnalysis,
    required this.alternatives,
    required this.insights,
    required this.optimizationCriteria,
    required this.analyzedAt,
  });
}

class BomPurchaseOrderResult {
  final String bomId;
  final double batchSize;
  final List<PurchaseOrder> purchaseOrders;
  final PurchaseOrderSummary summary;
  final List<String> recommendations;
  final DateTime createdAt;
  final String createdBy;

  BomPurchaseOrderResult({
    required this.bomId,
    required this.batchSize,
    required this.purchaseOrders,
    required this.summary,
    required this.recommendations,
    required this.createdAt,
    required this.createdBy,
  });
}

class BomSupplierComparison {
  final String bomId;
  final Map<String, ItemSupplierComparison> itemComparisons;
  final List<String> insights;
  final DateTime comparedAt;

  BomSupplierComparison({
    required this.bomId,
    required this.itemComparisons,
    required this.insights,
    required this.comparedAt,
  });
}

class BomProcurementSchedule {
  final String bomId;
  final double batchSize;
  final DateTime productionStartDate;
  final List<ProcurementScheduleItem> scheduleItems;
  final List<String> insights;
  final double totalEstimatedCost;
  final DateTime createdAt;

  BomProcurementSchedule({
    required this.bomId,
    required this.batchSize,
    required this.productionStartDate,
    required this.scheduleItems,
    required this.insights,
    required this.totalEstimatedCost,
    required this.createdAt,
  });
}

class ProcurementCostBreakdown {
  final double totalCost;
  final Map<String, double> itemCosts;
  final Map<String, double> supplierCosts;
  final String mostExpensiveItem;
  final double mostExpensiveItemCost;
  final double averageItemCost;

  ProcurementCostBreakdown({
    required this.totalCost,
    required this.itemCosts,
    required this.supplierCosts,
    required this.mostExpensiveItem,
    required this.mostExpensiveItemCost,
    required this.averageItemCost,
  });
}

class SupplierAlternative {
  final String supplierId;
  final String supplierName;
  final double unitPrice;
  final int leadTimeDays;
  final double? qualityRating;
  final double? deliveryRating;
  final double priceDifference;
  final int leadTimeDifference;

  SupplierAlternative({
    required this.supplierId,
    required this.supplierName,
    required this.unitPrice,
    required this.leadTimeDays,
    this.qualityRating,
    this.deliveryRating,
    required this.priceDifference,
    required this.leadTimeDifference,
  });
}

class ItemSupplierComparison {
  final String itemId;
  final List<SupplierQuote> quotes;
  final String recommendedSupplier;
  final Map<String, double> supplierScores;
  final PriceRange priceRange;
  final LeadTimeRange leadTimeRange;

  ItemSupplierComparison({
    required this.itemId,
    required this.quotes,
    required this.recommendedSupplier,
    required this.supplierScores,
    required this.priceRange,
    required this.leadTimeRange,
  });
}

class PriceRange {
  final double min;
  final double max;
  final double average;

  PriceRange({
    required this.min,
    required this.max,
    required this.average,
  });
}

class LeadTimeRange {
  final int min;
  final int max;
  final int average;

  LeadTimeRange({
    required this.min,
    required this.max,
    required this.average,
  });
}

class ProcurementScheduleItem {
  final String itemId;
  final String itemCode;
  final String itemName;
  final String supplierId;
  final String supplierName;
  final double quantity;
  final double unitPrice;
  final double totalCost;
  final int leadTimeDays;
  final DateTime recommendedOrderDate;
  final DateTime expectedDeliveryDate;
  final int priority;

  ProcurementScheduleItem({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.supplierId,
    required this.supplierName,
    required this.quantity,
    required this.unitPrice,
    required this.totalCost,
    required this.leadTimeDays,
    required this.recommendedOrderDate,
    required this.expectedDeliveryDate,
    required this.priority,
  });
}

class PurchaseOrderSummary {
  final int totalOrders;
  final double totalAmount;
  final int uniqueSuppliers;
  final int totalItems;
  final double averageOrderValue;

  PurchaseOrderSummary({
    required this.totalOrders,
    required this.totalAmount,
    required this.uniqueSuppliers,
    required this.totalItems,
    required this.averageOrderValue,
  });
}

class BomProcurementException implements Exception {
  final String message;
  BomProcurementException(this.message);

  @override
  String toString() => 'BomProcurementException: $message';
}
