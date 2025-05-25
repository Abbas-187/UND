import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/inventory_movement_model.dart';
import '../entities/cost_layer.dart';
import '../repositories/inventory_repository.dart';

/// Result of a cost calculation operation
class CostCalculationResult {
  CostCalculationResult({
    required this.totalCost,
    required this.averageCostPerUnit,
    required this.costBreakdown,
    required this.itemCosts,
    this.isPartial = false,
    required this.requestedQuantity,
    required this.actualQuantity,
  });
  final double totalCost;
  final double averageCostPerUnit;
  final List<CostUsage> costBreakdown;
  final Map<String, double> itemCosts; // Itemized costs by item ID
  final bool isPartial;
  final double requestedQuantity;
  final double actualQuantity;
}

/// Represents a usage of a cost layer in a calculation
class CostUsage {
  CostUsage({
    required this.layerId,
    required this.originalMovementId,
    this.batchLotNumber,
    required this.quantity,
    required this.costPerUnit,
    required this.movementDate,
    this.expirationDate,
  });
  final String layerId;
  final String originalMovementId;
  final String? batchLotNumber;
  final double quantity;
  final double costPerUnit;
  final DateTime movementDate;
  final DateTime? expirationDate;

  double get totalCost => quantity * costPerUnit;
}

/// Calculates the cost of an outbound inventory movement using FIFO or LIFO method
class CalculateOutboundMovementCostUseCase {
  CalculateOutboundMovementCostUseCase(this._repository);
  final InventoryRepository _repository;

  /// Calculate the cost of an outbound movement using the specified costing method
  Future<CostCalculationResult> execute({
    required InventoryMovementModel movement,
    required CostingMethod costingMethod,
  }) async {
    // Verify that this is an outbound movement
    if (![
      InventoryMovementType.issue,
      InventoryMovementType.consumption,
      InventoryMovementType.transferOut,
    ].contains(movement.movementType)) {
      throw ArgumentError('This use case is only for outbound movements');
    }

    double totalCost = 0;
    double totalQuantity = 0;
    bool isPartial = false;
    double requestedTotalQuantity = 0;
    List<CostUsage> allCostUsages = [];
    Map<String, double> itemCosts = {};

    // Process each item in the movement
    for (var item in movement.items) {
      // Skip items with positive quantities (should not happen in outbound movements)
      if (item.quantity >= 0) continue;

      final itemId = item.itemId;
      final requestedQuantity =
          item.quantity.abs(); // Make it positive for calculations
      requestedTotalQuantity += requestedQuantity;

      // Get available cost layers for this item from the repository
      final costLayers = await _repository.getAvailableCostLayers(
        itemId,
        movement.warehouseId,
        costingMethod,
      );

      // Sort cost layers based on the costing method
      if (costingMethod == CostingMethod.fifo) {
        // FIFO: oldest first (already sorted by repository)
      } else if (costingMethod == CostingMethod.lifo) {
        // LIFO: newest first (reverse the order)
        costLayers.sort((a, b) => b.movementDate.compareTo(a.movementDate));
      }

      // Calculate cost for this item
      double remainingToIssue = requestedQuantity;
      double itemCost = 0;
      List<CostUsage> itemCostUsages = [];

      for (var layer in costLayers) {
        if (remainingToIssue <= 0) break;

        // Determine how much to take from this layer
        final quantityFromLayer = remainingToIssue > layer.remainingQuantity
            ? layer.remainingQuantity
            : remainingToIssue;

        if (quantityFromLayer <= 0) continue;

        // Calculate cost from this layer
        final costFromLayer = quantityFromLayer * layer.costAtTransaction;
        itemCost += costFromLayer;

        // Track usage
        itemCostUsages.add(CostUsage(
          layerId: layer.id,
          originalMovementId: layer.movementId ?? '',
          batchLotNumber: layer.batchLotNumber,
          quantity: quantityFromLayer,
          costPerUnit: layer.costAtTransaction,
          movementDate: layer.movementDate,
          expirationDate: layer.expirationDate,
        ));

        // Update remaining to issue
        remainingToIssue -= quantityFromLayer;
      }

      // Check if we fulfilled the entire requested quantity
      final actualQuantity = requestedQuantity - remainingToIssue;
      if (actualQuantity < requestedQuantity) {
        isPartial = true;
      }

      // Update totals
      totalCost += itemCost;
      totalQuantity += actualQuantity;
      allCostUsages.addAll(itemCostUsages);
      itemCosts[itemId] = itemCost;
    }

    // Calculate average cost per unit
    final averageCostPerUnit =
        totalQuantity > 0 ? (totalCost / totalQuantity).toDouble() : 0.0;

    return CostCalculationResult(
      totalCost: totalCost,
      averageCostPerUnit: averageCostPerUnit,
      costBreakdown: allCostUsages,
      itemCosts: itemCosts,
      isPartial: isPartial,
      requestedQuantity: requestedTotalQuantity,
      actualQuantity: totalQuantity,
    );
  }
}

// Provider for the use case
final calculateOutboundMovementCostUseCaseProvider =
    Provider<CalculateOutboundMovementCostUseCase>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return CalculateOutboundMovementCostUseCase(repository);
});
