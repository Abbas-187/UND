import '../entities/cost_layer.dart';
import '../repositories/inventory_repository.dart';

/// Model for the picking suggestion result that includes batch and expiration info
class PickingSuggestion {
  const PickingSuggestion({
    required this.itemId,
    required this.itemName,
    required this.batchLotNumber,
    required this.locationId,
    required this.availableQuantity,
    required this.suggestedQuantity,
    this.expirationDate,
    this.daysUntilExpiration,
    this.costAtTransaction,
  });

  final String itemId;
  final String itemName;
  final String batchLotNumber;
  final String locationId;
  final double availableQuantity;
  final double suggestedQuantity;
  final DateTime? expirationDate;
  final int? daysUntilExpiration;
  final double? costAtTransaction;
}

/// Enum defining the sorting strategy for picking items
enum PickingStrategy {
  fefo, // First Expired, First Out
  fifo, // First In, First Out
  lifo, // Last In, First Out
  custom, // Custom sorting (defined by picker)
}

/// UseCase for generating picking suggestions based on FEFO for perishable items,
/// or FIFO/LIFO for non-perishable items.
class GeneratePickingSuggestionsUseCase {
  GeneratePickingSuggestionsUseCase(this._repository);

  final InventoryRepository _repository;

  /// Generate picking suggestions for an item based on the chosen strategy
  ///
  /// Parameters:
  /// - itemId: The ID of the item to pick
  /// - warehouseId: The warehouse to pick from
  /// - quantityNeeded: The total quantity needed
  /// - strategy: The picking strategy (FEFO, FIFO, LIFO, custom)
  /// - includeExpiringSoon: Whether to include items expiring soon, even if not needed to fulfill quantity
  /// - expiringThresholdDays: Items expiring within this many days are considered "expiring soon"
  ///
  /// Returns a list of PickingSuggestion objects
  Future<List<PickingSuggestion>> execute({
    required String itemId,
    required String warehouseId,
    required double quantityNeeded,
    PickingStrategy strategy = PickingStrategy.fefo,
    bool includeExpiringSoon = false,
    int expiringThresholdDays = 30,
  }) async {
    // Get the inventory item
    final item = await _repository.getInventoryItem(itemId);
    if (item == null) {
      return [];
    }

    // Get all available cost layers
    final costLayers = await _repository.getAvailableCostLayers(
      itemId,
      warehouseId,
      CostingMethod.fifo, // We'll sort manually based on strategy
    );

    if (costLayers.isEmpty) {
      return [];
    }

    // Determine if the item is perishable
    final isPerishable = item.customAttributes?['isPerishable'] == true;

    // Sort the layers based on strategy
    if (strategy == PickingStrategy.fefo && isPerishable) {
      // Sort by expiration date (ascending - soonest first)
      costLayers.sort((a, b) {
        if (a.expirationDate == null && b.expirationDate == null) return 0;
        if (a.expirationDate == null) return 1; // Nulls last
        if (b.expirationDate == null) return -1;
        return a.expirationDate!.compareTo(b.expirationDate!);
      });
    } else if (strategy == PickingStrategy.fifo ||
        (strategy == PickingStrategy.fefo && !isPerishable)) {
      // Sort by movement date (ascending - oldest first)
      costLayers.sort((a, b) => a.movementDate.compareTo(b.movementDate));
    } else if (strategy == PickingStrategy.lifo) {
      // Sort by movement date (descending - newest first)
      costLayers.sort((a, b) => b.movementDate.compareTo(a.movementDate));
    }

    final now = DateTime.now();
    final suggestions = <PickingSuggestion>[];
    double remainingNeeded = quantityNeeded;

    // Process layers to generate picking suggestions
    for (final layer in costLayers) {
      if (remainingNeeded <= 0 && !includeExpiringSoon) break;

      // Skip layers with no remaining quantity
      if (layer.remainingQuantity <= 0) continue;

      // For expiring soon items
      bool isExpiringSoon = false;
      int? daysUntilExpiry;

      if (layer.expirationDate != null) {
        daysUntilExpiry = layer.expirationDate!.difference(now).inDays;
        isExpiringSoon = daysUntilExpiry <= expiringThresholdDays;
      }

      // If we've met our quantity and this isn't expiring soon, skip it
      if (remainingNeeded <= 0 && !isExpiringSoon) continue;

      // Calculate suggested quantity
      final suggestedQty = remainingNeeded > 0
          ? (remainingNeeded > layer.remainingQuantity
              ? layer.remainingQuantity
              : remainingNeeded)
          : 0.0;

      // Create suggestion
      suggestions.add(
        PickingSuggestion(
          itemId: layer.itemId,
          itemName: item.name,
          batchLotNumber: layer.batchLotNumber,
          locationId: item.locationId ?? 'unknown',
          availableQuantity: layer.remainingQuantity,
          suggestedQuantity: suggestedQty,
          expirationDate: layer.expirationDate,
          daysUntilExpiration: daysUntilExpiry,
          costAtTransaction: layer.costAtTransaction,
        ),
      );

      // Update remaining needed
      remainingNeeded -= suggestedQty;
    }

    return suggestions;
  }
}
