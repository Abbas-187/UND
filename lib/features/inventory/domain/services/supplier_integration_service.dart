import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';
import '../providers/inventory_repository_provider.dart' as repo_provider;

/// Supplier information for inventory planning
class SupplierInfo {
  const SupplierInfo({
    required this.supplierId,
    required this.supplierName,
    required this.leadTimeDays,
    required this.minimumOrderQuantity,
    this.preferredOrderQuantity,
    this.unitPrice,
    this.currency = 'USD',
    this.paymentTerms,
    this.qualityRating,
    this.deliveryReliability,
    this.lastOrderDate,
    this.contractExpiryDate,
    this.isPreferredSupplier = false,
    this.isActive = true,
  });

  final String supplierId;
  final String supplierName;
  final int leadTimeDays;
  final double minimumOrderQuantity;
  final double? preferredOrderQuantity;
  final double? unitPrice;
  final String currency;
  final String? paymentTerms;
  final double? qualityRating; // 0.0 to 5.0
  final double? deliveryReliability; // 0.0 to 1.0 (percentage)
  final DateTime? lastOrderDate;
  final DateTime? contractExpiryDate;
  final bool isPreferredSupplier;
  final bool isActive;
}

/// Reorder recommendation based on supplier information
class ReorderRecommendation {
  const ReorderRecommendation({
    required this.itemId,
    required this.itemName,
    required this.currentQuantity,
    required this.reorderPoint,
    required this.recommendedQuantity,
    required this.recommendedSupplier,
    required this.estimatedDeliveryDate,
    required this.estimatedCost,
    this.urgencyLevel = 'NORMAL',
    this.reason,
  });

  final String itemId;
  final String itemName;
  final double currentQuantity;
  final double reorderPoint;
  final double recommendedQuantity;
  final SupplierInfo recommendedSupplier;
  final DateTime estimatedDeliveryDate;
  final double estimatedCost;
  final String urgencyLevel; // LOW, NORMAL, HIGH, CRITICAL
  final String? reason;
}

/// Service for integrating supplier information with inventory planning
class SupplierIntegrationService {
  const SupplierIntegrationService(this._repository);

  final InventoryRepository _repository;

  /// Get supplier information for an inventory item
  Future<List<SupplierInfo>> getSupplierInfoForItem(String itemId) async {
    final item = await _repository.getInventoryItem(itemId);
    if (item == null) return [];

    // Extract supplier information from item attributes
    final supplierData =
        item.additionalAttributes?['suppliers'] as List<dynamic>?;
    if (supplierData == null) return [];

    return supplierData.map((data) {
      final supplierMap = data as Map<String, dynamic>;
      return SupplierInfo(
        supplierId: supplierMap['supplierId'] ?? '',
        supplierName: supplierMap['supplierName'] ?? '',
        leadTimeDays: supplierMap['leadTimeDays'] ?? 7,
        minimumOrderQuantity:
            (supplierMap['minimumOrderQuantity'] ?? 0).toDouble(),
        preferredOrderQuantity:
            supplierMap['preferredOrderQuantity']?.toDouble(),
        unitPrice: supplierMap['unitPrice']?.toDouble(),
        currency: supplierMap['currency'] ?? 'USD',
        paymentTerms: supplierMap['paymentTerms'],
        qualityRating: supplierMap['qualityRating']?.toDouble(),
        deliveryReliability: supplierMap['deliveryReliability']?.toDouble(),
        lastOrderDate: supplierMap['lastOrderDate'] != null
            ? DateTime.parse(supplierMap['lastOrderDate'])
            : null,
        contractExpiryDate: supplierMap['contractExpiryDate'] != null
            ? DateTime.parse(supplierMap['contractExpiryDate'])
            : null,
        isPreferredSupplier: supplierMap['isPreferredSupplier'] ?? false,
        isActive: supplierMap['isActive'] ?? true,
      );
    }).toList();
  }

  /// Get the preferred supplier for an item
  Future<SupplierInfo?> getPreferredSupplier(String itemId) async {
    final suppliers = await getSupplierInfoForItem(itemId);

    // First try to find explicitly preferred supplier
    final preferredSupplier =
        suppliers.where((s) => s.isPreferredSupplier && s.isActive).firstOrNull;
    if (preferredSupplier != null) return preferredSupplier;

    // If no preferred supplier, find the best one based on criteria
    if (suppliers.isEmpty) return null;

    final activeSuppliers = suppliers.where((s) => s.isActive).toList();
    if (activeSuppliers.isEmpty) return null;

    // Score suppliers based on multiple criteria
    activeSuppliers.sort((a, b) {
      final scoreA = _calculateSupplierScore(a);
      final scoreB = _calculateSupplierScore(b);
      return scoreB.compareTo(scoreA); // Higher score is better
    });

    return activeSuppliers.first;
  }

  /// Calculate supplier score based on multiple criteria
  double _calculateSupplierScore(SupplierInfo supplier) {
    double score = 0.0;

    // Quality rating (0-5) -> 0-30 points
    if (supplier.qualityRating != null) {
      score += (supplier.qualityRating! / 5.0) * 30;
    }

    // Delivery reliability (0-1) -> 0-25 points
    if (supplier.deliveryReliability != null) {
      score += supplier.deliveryReliability! * 25;
    }

    // Lead time (shorter is better) -> 0-20 points
    final maxLeadTime = 30; // Assume 30 days is worst case
    score += ((maxLeadTime - supplier.leadTimeDays) / maxLeadTime) * 20;

    // Recent activity (more recent is better) -> 0-15 points
    if (supplier.lastOrderDate != null) {
      final daysSinceLastOrder =
          DateTime.now().difference(supplier.lastOrderDate!).inDays;
      final maxDays = 365; // 1 year
      if (daysSinceLastOrder <= maxDays) {
        score += ((maxDays - daysSinceLastOrder) / maxDays) * 15;
      }
    }

    // Contract validity -> 0-10 points
    if (supplier.contractExpiryDate != null) {
      final daysUntilExpiry =
          supplier.contractExpiryDate!.difference(DateTime.now()).inDays;
      if (daysUntilExpiry > 0) {
        score += 10; // Full points if contract is valid
      }
    } else {
      score += 5; // Half points if no contract expiry (assume ongoing)
    }

    return score;
  }

  /// Generate reorder recommendations for items below reorder point
  Future<List<ReorderRecommendation>> generateReorderRecommendations({
    String? warehouseId,
    List<String>? itemIds,
  }) async {
    final recommendations = <ReorderRecommendation>[];

    // Get items that need reordering
    final itemsNeedingReorder = await _repository.getItemsNeedingReorder();

    // Filter by provided itemIds if specified
    final filteredItems = itemIds != null
        ? itemsNeedingReorder
            .where((item) => itemIds.contains(item.id))
            .toList()
        : itemsNeedingReorder;

    for (final item in filteredItems) {
      final supplier = await getPreferredSupplier(item.id);
      if (supplier == null) continue;

      final recommendation = await _createReorderRecommendation(item, supplier);
      if (recommendation != null) {
        recommendations.add(recommendation);
      }
    }

    // Sort by urgency level
    recommendations.sort((a, b) {
      final urgencyOrder = {'CRITICAL': 0, 'HIGH': 1, 'NORMAL': 2, 'LOW': 3};
      return urgencyOrder[a.urgencyLevel]!
          .compareTo(urgencyOrder[b.urgencyLevel]!);
    });

    return recommendations;
  }

  /// Create a reorder recommendation for an item
  Future<ReorderRecommendation?> _createReorderRecommendation(
    InventoryItem item,
    SupplierInfo supplier,
  ) async {
    // Calculate recommended order quantity
    final safetyStock =
        (item.additionalAttributes?['safetyStock'] as double?) ?? 0;
    final averageDailyUsage =
        (item.additionalAttributes?['averageDailyUsage'] as double?) ?? 1;

    // Economic Order Quantity (EOQ) or minimum order quantity
    final recommendedQuantity = _calculateRecommendedOrderQuantity(
      item,
      supplier,
      averageDailyUsage,
      safetyStock,
    );

    // Calculate estimated delivery date
    final estimatedDeliveryDate =
        DateTime.now().add(Duration(days: supplier.leadTimeDays));

    // Calculate estimated cost
    final estimatedCost = recommendedQuantity * (supplier.unitPrice ?? 0);

    // Determine urgency level
    final urgencyLevel =
        _determineUrgencyLevel(item, supplier, averageDailyUsage);

    // Generate reason
    final reason = _generateReorderReason(item, supplier, urgencyLevel);

    return ReorderRecommendation(
      itemId: item.id,
      itemName: item.name,
      currentQuantity: item.quantity,
      reorderPoint: item.reorderPoint,
      recommendedQuantity: recommendedQuantity,
      recommendedSupplier: supplier,
      estimatedDeliveryDate: estimatedDeliveryDate,
      estimatedCost: estimatedCost,
      urgencyLevel: urgencyLevel,
      reason: reason,
    );
  }

  /// Calculate recommended order quantity
  double _calculateRecommendedOrderQuantity(
    InventoryItem item,
    SupplierInfo supplier,
    double averageDailyUsage,
    double safetyStock,
  ) {
    // Calculate quantity needed to reach target stock level
    final targetStockLevel = item.reorderPoint +
        safetyStock +
        (averageDailyUsage * supplier.leadTimeDays);
    final quantityNeeded = targetStockLevel - item.quantity;

    // Ensure we meet minimum order quantity
    final recommendedQuantity = quantityNeeded > supplier.minimumOrderQuantity
        ? quantityNeeded
        : supplier.minimumOrderQuantity;

    // Use preferred order quantity if it's larger
    if (supplier.preferredOrderQuantity != null &&
        supplier.preferredOrderQuantity! > recommendedQuantity) {
      return supplier.preferredOrderQuantity!;
    }

    return recommendedQuantity;
  }

  /// Determine urgency level based on current stock and lead time
  String _determineUrgencyLevel(
    InventoryItem item,
    SupplierInfo supplier,
    double averageDailyUsage,
  ) {
    final daysOfStockRemaining = averageDailyUsage > 0
        ? item.quantity / averageDailyUsage
        : double.infinity;

    if (daysOfStockRemaining <= supplier.leadTimeDays * 0.5) {
      return 'CRITICAL'; // Less than half lead time remaining
    } else if (daysOfStockRemaining <= supplier.leadTimeDays) {
      return 'HIGH'; // Less than lead time remaining
    } else if (item.quantity <= item.reorderPoint) {
      return 'NORMAL'; // Below reorder point
    } else {
      return 'LOW'; // Above reorder point but flagged for other reasons
    }
  }

  /// Generate reason for reorder recommendation
  String _generateReorderReason(
    InventoryItem item,
    SupplierInfo supplier,
    String urgencyLevel,
  ) {
    final reasons = <String>[];

    if (item.quantity <= item.minimumQuantity) {
      reasons.add('Below minimum quantity');
    }

    if (item.quantity <= item.reorderPoint) {
      reasons.add('Below reorder point');
    }

    switch (urgencyLevel) {
      case 'CRITICAL':
        reasons.add('Stock will run out before delivery');
        break;
      case 'HIGH':
        reasons.add('Stock may run out during lead time');
        break;
    }

    if (supplier.contractExpiryDate != null) {
      final daysUntilExpiry =
          supplier.contractExpiryDate!.difference(DateTime.now()).inDays;
      if (daysUntilExpiry <= 30) {
        reasons.add('Supplier contract expiring soon');
      }
    }

    return reasons.isEmpty ? 'Routine reorder' : reasons.join(', ');
  }

  /// Update supplier information for an item
  Future<void> updateSupplierInfo(
      String itemId, List<SupplierInfo> suppliers) async {
    final item = await _repository.getInventoryItem(itemId);
    if (item == null) return;

    final supplierData = suppliers
        .map((supplier) => {
              'supplierId': supplier.supplierId,
              'supplierName': supplier.supplierName,
              'leadTimeDays': supplier.leadTimeDays,
              'minimumOrderQuantity': supplier.minimumOrderQuantity,
              'preferredOrderQuantity': supplier.preferredOrderQuantity,
              'unitPrice': supplier.unitPrice,
              'currency': supplier.currency,
              'paymentTerms': supplier.paymentTerms,
              'qualityRating': supplier.qualityRating,
              'deliveryReliability': supplier.deliveryReliability,
              'lastOrderDate': supplier.lastOrderDate?.toIso8601String(),
              'contractExpiryDate':
                  supplier.contractExpiryDate?.toIso8601String(),
              'isPreferredSupplier': supplier.isPreferredSupplier,
              'isActive': supplier.isActive,
            })
        .toList();

    final updatedAttributes =
        Map<String, dynamic>.from(item.additionalAttributes ?? {});
    updatedAttributes['suppliers'] = supplierData;

    final updatedItem = item.copyWith(additionalAttributes: updatedAttributes);
    await _repository.updateInventoryItem(updatedItem);
  }
}

/// Provider for SupplierIntegrationService
final supplierIntegrationServiceProvider =
    Provider<SupplierIntegrationService>((ref) {
  return SupplierIntegrationService(
    ref.watch(repo_provider.inventoryRepositoryProvider),
  );
});
