import 'dart:math' as math;
import '../entities/purchase_order.dart';

class SupplierQuoteService {
  // Get quotes for a specific item from multiple suppliers
  Future<List<SupplierQuote>> getQuotesForItem(
    String itemId,
    double quantity,
  ) async {
    final suppliers = await _getItemSuppliers(itemId);
    final quotes = <SupplierQuote>[];

    for (final supplier in suppliers) {
      try {
        final quote = await _requestQuoteFromSupplier(
          supplier.id,
          itemId,
          quantity,
        );
        if (quote != null) {
          quotes.add(quote);
        }
      } catch (e) {
        // Log error but continue with other suppliers
        print('Failed to get quote from supplier ${supplier.name}: $e');
      }
    }

    return quotes;
  }

  // Select optimal supplier using multi-criteria optimization
  Future<SupplierQuote> selectOptimalSupplier(
    List<SupplierQuote> quotes,
    OptimizationCriteria criteria,
  ) async {
    if (quotes.isEmpty) {
      throw Exception('No quotes available for optimization');
    }

    if (quotes.length == 1) {
      return quotes.first;
    }

    // Calculate weighted scores for each quote
    final scoredQuotes = <ScoredQuote>[];

    for (final quote in quotes) {
      final score = await _calculateQuoteScore(quote, criteria);
      scoredQuotes.add(ScoredQuote(quote: quote, score: score));
    }

    // Sort by score (highest first)
    scoredQuotes.sort((a, b) => b.score.compareTo(a.score));

    return scoredQuotes.first.quote;
  }

  // Calculate Economic Order Quantity for cost optimization
  Future<double> calculateEconomicOrderQuantity(
    String itemId,
    double annualDemand,
  ) async {
    final orderingCost = await _getOrderingCost(itemId);
    final holdingCost = await _getHoldingCost(itemId);

    if (holdingCost <= 0) {
      throw Exception('Invalid holding cost for EOQ calculation');
    }

    // EOQ = sqrt((2 * D * S) / H)
    // D = Annual demand, S = Ordering cost, H = Holding cost
    final eoq = math.sqrt((2 * annualDemand * orderingCost) / holdingCost);

    return eoq;
  }

  // Generate procurement recommendations for a BOM
  Future<ProcurementRecommendation> generateRecommendations(
    String bomId,
    double batchSize,
  ) async {
    final bomItems = await _getBomItems(bomId);
    final recommendations = <RecommendedPurchase>[];
    double totalEstimatedCost = 0.0;
    int maxLeadTime = 0;

    for (final item in bomItems) {
      final requiredQuantity = item.quantity * batchSize;
      final availableStock = await _getAvailableStock(item.itemId);
      final shortageQuantity =
          math.max(0, requiredQuantity - availableStock).toDouble();

      if (shortageQuantity > 0) {
        final quotes = await getQuotesForItem(item.itemId, shortageQuantity);

        if (quotes.isNotEmpty) {
          final criteria = OptimizationCriteria(
            priceWeight: 0.4,
            qualityWeight: 0.3,
            deliveryWeight: 0.2,
            leadTimeWeight: 0.1,
          );

          final optimalQuote = await selectOptimalSupplier(quotes, criteria);

          // Calculate EOQ for better quantity optimization
          final annualDemand = await _getAnnualDemand(item.itemId);
          final eoq =
              await calculateEconomicOrderQuantity(item.itemId, annualDemand);

          // Recommend EOQ if it's significantly larger than shortage
          final recommendedQuantity = shortageQuantity > eoq * 0.5
              ? math.max(shortageQuantity, eoq).toDouble()
              : shortageQuantity;

          final recommendation = RecommendedPurchase(
            itemId: item.itemId,
            itemCode: item.itemCode,
            itemName: item.itemName,
            requiredQuantity: shortageQuantity,
            recommendedQuantity: recommendedQuantity,
            selectedSupplier: optimalQuote.supplierId,
            supplierName: optimalQuote.supplierName,
            unitPrice: optimalQuote.unitPrice,
            totalCost: optimalQuote.unitPrice * recommendedQuantity,
            leadTimeDays: optimalQuote.leadTimeDays,
            reason: _determineRecommendationReason(optimalQuote, quotes),
            confidenceScore: _calculateConfidenceScore(optimalQuote, quotes),
            alternativeSuppliers: quotes
                .where((q) => q.supplierId != optimalQuote.supplierId)
                .take(2)
                .map((q) => q.supplierName)
                .toList(),
          );

          recommendations.add(recommendation);
          totalEstimatedCost += recommendation.totalCost;
          maxLeadTime = math.max(maxLeadTime, recommendation.leadTimeDays);
        }
      }
    }

    return ProcurementRecommendation(
      bomId: bomId,
      recommendations: recommendations,
      totalEstimatedCost: totalEstimatedCost,
      averageLeadTime: maxLeadTime,
      generatedAt: DateTime.now(),
    );
  }

  // Generate purchase orders from BOM with supplier grouping
  Future<List<PurchaseOrder>> generatePurchaseOrdersFromBom(
    String bomId,
    double batchSize,
    String requestedBy,
  ) async {
    final recommendation = await generateRecommendations(bomId, batchSize);

    // Group recommendations by supplier
    final supplierGroups = <String, List<RecommendedPurchase>>{};
    for (final rec in recommendation.recommendations) {
      supplierGroups.putIfAbsent(rec.selectedSupplier, () => []);
      supplierGroups[rec.selectedSupplier]!.add(rec);
    }

    final purchaseOrders = <PurchaseOrder>[];

    for (final entry in supplierGroups.entries) {
      final supplierId = entry.key;
      final items = entry.value;

      final poItems = items
          .map((item) => PurchaseOrderItem(
                id: _generateItemId(),
                itemId: item.itemId,
                itemName: item.itemName,
                quantity: item.recommendedQuantity,
                unitPrice: item.unitPrice,
                totalPrice: item.totalCost,
                unit: 'pcs', // Default unit, should be fetched from item master
                requiredByDate:
                    DateTime.now().add(Duration(days: item.leadTimeDays)),
                notes:
                    'BOM requirement: ${item.requiredQuantity} ${item.itemCode}',
              ))
          .toList();

      final totalAmount =
          items.fold<double>(0, (sum, item) => sum + item.totalCost);
      final maxLeadTime =
          items.fold<int>(0, (max, item) => math.max(max, item.leadTimeDays));

      final po = PurchaseOrder(
        id: _generatePOId(),
        procurementPlanId: '', // To be set by procurement service
        poNumber: _generatePONumber(),
        requestDate: DateTime.now(),
        requestedBy: requestedBy,
        supplierId: supplierId,
        supplierName: items.first.supplierName,
        status: PurchaseOrderStatus.draft,
        items: poItems,
        totalAmount: totalAmount,
        reasonForRequest: 'BOM requirements for production',
        intendedUse: 'Production of BOM $bomId',
        quantityJustification:
            'Calculated based on BOM requirements and EOQ optimization',
        supportingDocuments: [],
        deliveryDate: DateTime.now().add(Duration(days: maxLeadTime)),
      );

      purchaseOrders.add(po);
    }

    return purchaseOrders;
  }

  // Calculate total cost of ownership including hidden costs
  Future<double> calculateTotalCostOfOwnership(
    SupplierQuote quote,
    double quantity,
  ) async {
    double totalCost = quote.unitPrice * quantity;

    // Add shipping costs
    final shippingCost = await _getShippingCost(quote.supplierId, quantity);
    totalCost += shippingCost;

    // Add handling costs
    final handlingCost = await _getHandlingCost(quantity);
    totalCost += handlingCost;

    // Add quality inspection costs
    final inspectionCost = await _getInspectionCost(quote.itemId, quantity);
    totalCost += inspectionCost;

    // Add inventory holding costs for lead time
    final holdingCost = await _getHoldingCost(quote.itemId);
    final leadTimeHoldingCost =
        (holdingCost * quantity * quote.leadTimeDays) / 365;
    totalCost += leadTimeHoldingCost;

    // Add risk premium for unreliable suppliers
    final reliabilityScore = quote.deliveryRating ?? 0.8;
    if (reliabilityScore < 0.8) {
      final riskPremium =
          totalCost * (0.8 - reliabilityScore) * 0.1; // Up to 2% premium
      totalCost += riskPremium;
    }

    return totalCost;
  }

  // Private helper methods
  Future<double> _calculateQuoteScore(
    SupplierQuote quote,
    OptimizationCriteria criteria,
  ) async {
    double score = 0.0;

    // Price score (lower is better, normalized to 0-1)
    final priceScore = await _calculatePriceScore(quote);
    score += priceScore * criteria.priceWeight;

    // Quality score (higher is better)
    final qualityScore = quote.qualityRating ?? 0.7; // Default quality rating
    score += qualityScore * criteria.qualityWeight;

    // Delivery reliability score (higher is better)
    final deliveryScore =
        quote.deliveryRating ?? 0.7; // Default delivery rating
    score += deliveryScore * criteria.deliveryWeight;

    // Lead time score (lower is better, normalized to 0-1)
    final leadTimeScore = await _calculateLeadTimeScore(quote);
    score += leadTimeScore * criteria.leadTimeWeight;

    return score;
  }

  Future<double> _calculatePriceScore(SupplierQuote quote) async {
    // Get market price for comparison
    final marketPrice = await _getMarketPrice(quote.itemId);
    if (marketPrice <= 0) return 0.5; // Default score if no market data

    // Score based on how much below/above market price
    final priceRatio = quote.unitPrice / marketPrice;
    if (priceRatio <= 0.9) return 1.0; // 10% below market = perfect score
    if (priceRatio <= 1.0) return 0.8; // At market = good score
    if (priceRatio <= 1.1) return 0.6; // 10% above market = fair score
    if (priceRatio <= 1.2) return 0.4; // 20% above market = poor score
    return 0.2; // More than 20% above = very poor score
  }

  Future<double> _calculateLeadTimeScore(SupplierQuote quote) async {
    final standardLeadTime = await _getStandardLeadTime(quote.itemId);
    if (standardLeadTime <= 0) return 0.5; // Default score if no data

    final leadTimeRatio = quote.leadTimeDays / standardLeadTime;
    if (leadTimeRatio <= 0.8) return 1.0; // 20% faster = perfect score
    if (leadTimeRatio <= 1.0) return 0.8; // Standard time = good score
    if (leadTimeRatio <= 1.2) return 0.6; // 20% slower = fair score
    if (leadTimeRatio <= 1.5) return 0.4; // 50% slower = poor score
    return 0.2; // More than 50% slower = very poor score
  }

  RecommendationReason _determineRecommendationReason(
    SupplierQuote selected,
    List<SupplierQuote> allQuotes,
  ) {
    // Find the best in each category
    final cheapest =
        allQuotes.reduce((a, b) => a.unitPrice < b.unitPrice ? a : b);
    final fastest =
        allQuotes.reduce((a, b) => a.leadTimeDays < b.leadTimeDays ? a : b);
    final highestQuality = allQuotes.reduce(
        (a, b) => (a.qualityRating ?? 0) > (b.qualityRating ?? 0) ? a : b);

    if (selected.supplierId == cheapest.supplierId) {
      return RecommendationReason.bestPrice;
    } else if (selected.supplierId == fastest.supplierId) {
      return RecommendationReason.fastestDelivery;
    } else if (selected.supplierId == highestQuality.supplierId) {
      return RecommendationReason.bestQuality;
    } else {
      return RecommendationReason.historicalPerformance;
    }
  }

  double _calculateConfidenceScore(
    SupplierQuote selected,
    List<SupplierQuote> allQuotes,
  ) {
    double confidence = 0.5; // Base confidence

    // Higher confidence if we have multiple quotes to compare
    if (allQuotes.length >= 3) confidence += 0.2;

    // Higher confidence if selected supplier has good ratings
    if (selected.qualityRating != null && selected.qualityRating! >= 0.8) {
      confidence += 0.1;
    }
    if (selected.deliveryRating != null && selected.deliveryRating! >= 0.8) {
      confidence += 0.1;
    }

    // Higher confidence if price is reasonable
    final avgPrice = allQuotes.fold<double>(0, (sum, q) => sum + q.unitPrice) /
        allQuotes.length;
    if (selected.unitPrice <= avgPrice * 1.1) {
      // Within 10% of average
      confidence += 0.1;
    }

    return confidence.clamp(0.0, 1.0);
  }

  String _generatePOId() => 'PO_${DateTime.now().millisecondsSinceEpoch}';
  String _generatePONumber() =>
      'PO${DateTime.now().year}${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  String _generateItemId() => 'POI_${DateTime.now().millisecondsSinceEpoch}';

  // Repository integration methods (to be implemented)
  Future<List<_Supplier>> _getItemSuppliers(String itemId) async {
    throw UnimplementedError('Supplier repository integration needed');
  }

  Future<SupplierQuote?> _requestQuoteFromSupplier(
    String supplierId,
    String itemId,
    double quantity,
  ) async {
    throw UnimplementedError('Supplier API integration needed');
  }

  Future<double> _getOrderingCost(String itemId) async {
    throw UnimplementedError('Cost repository integration needed');
  }

  Future<double> _getHoldingCost(String itemId) async {
    throw UnimplementedError('Cost repository integration needed');
  }

  Future<List<_BomItem>> _getBomItems(String bomId) async {
    throw UnimplementedError('BOM service integration needed');
  }

  Future<double> _getAvailableStock(String itemId) async {
    throw UnimplementedError('Inventory service integration needed');
  }

  Future<double> _getAnnualDemand(String itemId) async {
    throw UnimplementedError('Analytics service integration needed');
  }

  Future<double> _getMarketPrice(String itemId) async {
    throw UnimplementedError('Market data service integration needed');
  }

  Future<int> _getStandardLeadTime(String itemId) async {
    throw UnimplementedError('Item master service integration needed');
  }

  Future<double> _getShippingCost(String supplierId, double quantity) async {
    throw UnimplementedError('Logistics service integration needed');
  }

  Future<double> _getHandlingCost(double quantity) async {
    throw UnimplementedError('Warehouse service integration needed');
  }

  Future<double> _getInspectionCost(String itemId, double quantity) async {
    throw UnimplementedError('Quality service integration needed');
  }
}

// Supporting classes
class SupplierQuote {
  final String id;
  final String supplierId;
  final String supplierName;
  final String itemId;
  final double unitPrice;
  final String currency;
  final int leadTimeDays;
  final double minimumOrderQuantity;
  final DateTime validUntil;
  final double? qualityRating;
  final double? deliveryRating;

  SupplierQuote({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.itemId,
    required this.unitPrice,
    required this.currency,
    required this.leadTimeDays,
    required this.minimumOrderQuantity,
    required this.validUntil,
    this.qualityRating,
    this.deliveryRating,
  });
}

class OptimizationCriteria {
  final double priceWeight;
  final double qualityWeight;
  final double deliveryWeight;
  final double leadTimeWeight;

  OptimizationCriteria({
    required this.priceWeight,
    required this.qualityWeight,
    required this.deliveryWeight,
    required this.leadTimeWeight,
  });
}

class ProcurementRecommendation {
  final String bomId;
  final List<RecommendedPurchase> recommendations;
  final double totalEstimatedCost;
  final int averageLeadTime;
  final DateTime generatedAt;

  ProcurementRecommendation({
    required this.bomId,
    required this.recommendations,
    required this.totalEstimatedCost,
    required this.averageLeadTime,
    required this.generatedAt,
  });
}

class RecommendedPurchase {
  final String itemId;
  final String itemCode;
  final String itemName;
  final double requiredQuantity;
  final double recommendedQuantity;
  final String selectedSupplier;
  final String supplierName;
  final double unitPrice;
  final double totalCost;
  final int leadTimeDays;
  final RecommendationReason reason;
  final double confidenceScore;
  final List<String> alternativeSuppliers;

  RecommendedPurchase({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.requiredQuantity,
    required this.recommendedQuantity,
    required this.selectedSupplier,
    required this.supplierName,
    required this.unitPrice,
    required this.totalCost,
    required this.leadTimeDays,
    required this.reason,
    required this.confidenceScore,
    required this.alternativeSuppliers,
  });
}

class ScoredQuote {
  final SupplierQuote quote;
  final double score;

  ScoredQuote({required this.quote, required this.score});
}

enum RecommendationReason {
  bestPrice,
  bestQuality,
  fastestDelivery,
  preferredSupplier,
  onlyAvailable,
  bulkDiscount,
  historicalPerformance,
}

// Helper classes
class _Supplier {
  final String id;
  final String name;

  _Supplier({required this.id, required this.name});
}

class _BomItem {
  final String itemId;
  final String itemCode;
  final String itemName;
  final double quantity;
  final String unit;

  _BomItem({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.quantity,
    required this.unit,
  });
}
