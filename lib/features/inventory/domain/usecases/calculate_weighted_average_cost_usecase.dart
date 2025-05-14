import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/inventory_movement_model.dart';
import '../repositories/inventory_repository.dart';

/// Result of a weighted average cost calculation
class WeightedAverageCostResult {

  WeightedAverageCostResult({
    this.previousWeightedAverageCost,
    required this.newWeightedAverageCost,
    required this.previousQuantity,
    required this.movementQuantity,
    required this.newTotalQuantity,
    required this.newTotalValue,
  });
  final double? previousWeightedAverageCost;
  final double newWeightedAverageCost;
  final double previousQuantity;
  final double movementQuantity;
  final double newTotalQuantity;
  final double newTotalValue;
}

/// Calculates the weighted average cost (WAC) for an item after a movement
class CalculateWeightedAverageCostUseCase {

  CalculateWeightedAverageCostUseCase(this._repository);
  final InventoryRepository _repository;

  /// Calculate the weighted average cost for an item after a movement
  Future<WeightedAverageCostResult> execute({
    required InventoryMovementModel movement,
    required String itemId,
    required String warehouseId,
  }) async {
    // Get current WAC and quantity for this item in the warehouse
    final currentWac =
        await _repository.getItemWeightedAverageCost(itemId, warehouseId);
    final currentQuantity =
        await _repository.getItemCurrentQuantity(itemId, warehouseId);

    // Calculate movement quantity and value for this item
    double movementQuantity = 0;
    double movementValue = 0;

    // Find all movement items for this item
    final movementItems =
        movement.items.where((item) => item.itemId == itemId).toList();

    // Sum up quantities and calculate total value
    for (final item in movementItems) {
      movementQuantity += item.quantity;

      // For receipts and positive adjustments, use the cost at transaction
      if (item.quantity > 0 && item.costAtTransaction != null) {
        movementValue += item.quantity * item.costAtTransaction!;
      }
      // For outbound movements, use the current WAC if available
      else if (item.quantity < 0 && currentWac != null) {
        movementValue += item.quantity * currentWac; // This will be negative
      }
    }

    // Calculate new weighted average cost
    double newWac;
    double newTotalQuantity = currentQuantity + movementQuantity;
    double newTotalValue;

    // For first receipt with no previous inventory
    if (currentQuantity <= 0 && movementQuantity > 0) {
      newWac = movementValue / movementQuantity;
      newTotalValue = movementValue;
    }
    // For outbound movements with existing inventory
    else if (movementQuantity < 0 && currentQuantity > 0) {
      // For outbound movements, WAC doesn't change, only quantity does
      newWac = currentWac ?? 0;
      newTotalValue = newTotalQuantity * newWac;
    }
    // For inbound movements with existing inventory
    else if (movementQuantity > 0 &&
        currentQuantity > 0 &&
        currentWac != null) {
      final currentValue = currentQuantity * currentWac;
      newTotalValue = currentValue + movementValue;
      newWac = newTotalQuantity > 0 ? newTotalValue / newTotalQuantity : 0;
    }
    // For other cases (e.g., inventory adjustments to zero)
    else {
      // If new quantity is zero, keep the last known WAC for reference
      newWac = currentWac ??
          (movementValue != 0 && movementQuantity != 0
              ? movementValue / movementQuantity
              : 0);
      newTotalValue = newTotalQuantity * newWac;
    }

    return WeightedAverageCostResult(
      previousWeightedAverageCost: currentWac,
      newWeightedAverageCost: newWac,
      previousQuantity: currentQuantity,
      movementQuantity: movementQuantity,
      newTotalQuantity: newTotalQuantity,
      newTotalValue: newTotalValue,
    );
  }
}

// Provider for the use case
final calculateWeightedAverageCostUseCaseProvider =
    Provider<CalculateWeightedAverageCostUseCase>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return CalculateWeightedAverageCostUseCase(repository);
});
