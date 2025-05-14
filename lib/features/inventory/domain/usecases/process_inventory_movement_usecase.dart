import '../../data/models/inventory_movement_item_model.dart';
import '../../data/models/inventory_movement_model.dart';
import '../entities/cost_layer.dart';
import '../repositories/inventory_repository.dart';
import '../validators/inventory_movement_item_validator.dart';
import '../validators/inventory_movement_validator.dart';

/// Result class for movement processing operations
class MovementProcessingResult {

  const MovementProcessingResult({
    required this.success,
    this.movementId,
    this.errors = const [],
  });
  final bool success;
  final String? movementId;
  final List<String> errors;
}

/// UseCase for processing inventory movements with FIFO/LIFO costing
class ProcessInventoryMovementUseCase {

  const ProcessInventoryMovementUseCase(this._repository);
  final InventoryRepository _repository;

  /// Process an inventory movement
  ///
  /// This method processes an inventory movement by:
  /// 1. Validating the movement data
  /// 2. Applying FIFO/LIFO costing based on company's policy
  /// 3. Creating or updating cost layers for items
  /// 4. Updating inventory quantities
  /// 5. Saving the movement record
  ///
  /// Returns a result with success status and errors if any
  Future<MovementProcessingResult> execute({
    required InventoryMovementModel movement,
    bool validateBatchTracking = true,
    CostingMethod costingMethod = CostingMethod.fifo,
  }) async {
    final errors = <String>[];

    // Validate the movement for audit compliance
    final movementValidator = InventoryMovementValidator();
    final movementValidationResult = movementValidator.validate(movement);

    if (!movementValidationResult.isValid) {
      errors.addAll(movementValidationResult.errors);
      return MovementProcessingResult(success: false, errors: errors);
    }

    try {
      // Get company settings to determine costing method
      final settings = await _repository.getCompanySettings();

      // Use company's default costing method if not specified
      final effectiveCostingMethod =
          settings?.defaultCostingMethod ?? costingMethod;

      // Check if each item requires batch tracking when it's enabled
      if (validateBatchTracking) {
        for (final item in movement.items) {
          final inventoryItem = await _repository.getInventoryItem(item.itemId);

          // Skip validation if we can't find the item
          if (inventoryItem == null) continue;

          final requiresBatchTracking =
              inventoryItem.customAttributes?['requiresBatchTracking'] == true;

          final isPerishable =
              inventoryItem.customAttributes?['isPerishable'] == true;

          // Use the dedicated validator for perishable items
          if (isPerishable) {
            final validator =
                InventoryMovementItemValidator(isPerishable: true);
            final validationResult = validator.validate(item);

            if (!validationResult.isValid) {
              errors.addAll(validationResult.errors);
              continue;
            }
          } else if (requiresBatchTracking) {
            // For inbound movements, batch info is required
            if (_isInboundMovement(movement.movementType) &&
                (item.batchLotNumber == null || item.batchLotNumber!.isEmpty)) {
              errors.add('Batch number is required for item: ${item.itemName}');
            }
          }
        }

        if (errors.isNotEmpty) {
          return MovementProcessingResult(success: false, errors: errors);
        }
      }

      // Process each item in the movement
      for (final item in movement.items) {
        if (_isInboundMovement(movement.movementType)) {
          // For inbound movements, create a new cost layer
          await _processInboundItem(movement, item, effectiveCostingMethod);
        } else {
          // For outbound movements, apply FIFO/LIFO logic
          await _processOutboundItem(movement, item, effectiveCostingMethod);
        }
      }

      // Save the movement record
      final savedMovement = await _repository.saveMovement(movement);

      return MovementProcessingResult(
        success: true,
        movementId: savedMovement.id,
      );
    } catch (e) {
      errors.add('Error processing movement: ${e.toString()}');
      return MovementProcessingResult(success: false, errors: errors);
    }
  }

  /// Process an inbound inventory item (receipt, return, production)
  Future<void> _processInboundItem(
    InventoryMovementModel movement,
    InventoryMovementItemModel item,
    CostingMethod costingMethod,
  ) async {
    // For inbound movements, we create a new cost layer
    final costLayer = CostLayer(
      id: 'layer_${DateTime.now().millisecondsSinceEpoch}_${item.itemId}',
      itemId: item.itemId,
      warehouseId: movement.warehouseId,
      batchLotNumber: item.batchLotNumber ?? 'NO_BATCH',
      initialQuantity: item.quantity,
      remainingQuantity: item.quantity,
      costAtTransaction: item.costAtTransaction ?? 0.0,
      movementId: movement.id,
      movementDate: movement.movementDate,
      expirationDate: item.expirationDate,
      productionDate: item.productionDate,
      createdAt: DateTime.now(),
    );

    // Save the cost layer
    await _repository.saveCostLayer(costLayer);

    // Update inventory quantity
    await _repository.updateInventoryQuantity(
        item.itemId, movement.warehouseId, item.quantity);
  }

  /// Process an outbound inventory item (issue, consumption, etc.)
  Future<void> _processOutboundItem(
    InventoryMovementModel movement,
    InventoryMovementItemModel item,
    CostingMethod costingMethod,
  ) async {
    // Get available cost layers for this item
    final costLayers = await _repository.getAvailableCostLayers(
      item.itemId,
      movement.warehouseId,
      costingMethod,
    );

    if (costLayers.isEmpty) {
      throw Exception('No cost layers available for item ${item.itemName}');
    }

    // The quantity we need to consume (absolute value)
    double remainingQuantityToConsume = item.quantity.abs();
    double totalCost = 0.0;

    // Go through each cost layer and consume quantity
    for (final layer in costLayers) {
      if (remainingQuantityToConsume <= 0) break;

      final quantityToConsumeFromLayer =
          remainingQuantityToConsume > layer.remainingQuantity
              ? layer.remainingQuantity
              : remainingQuantityToConsume;

      if (quantityToConsumeFromLayer <= 0) continue;

      // Calculate cost for this consumption
      final cost = quantityToConsumeFromLayer * layer.costAtTransaction;
      totalCost += cost;

      // Update the layer's remaining quantity
      final updatedLayer = layer.copyWith(
        remainingQuantity: layer.remainingQuantity - quantityToConsumeFromLayer,
      );

      await _repository.saveCostLayer(updatedLayer);

      // Record the consumption
      final consumption = CostLayerConsumption(
        id: 'consumption_${DateTime.now().millisecondsSinceEpoch}_${layer.id}',
        costLayerId: layer.id,
        itemId: item.itemId,
        warehouseId: movement.warehouseId,
        movementId: movement.id,
        movementDate: movement.movementDate,
        quantity: quantityToConsumeFromLayer,
        cost: cost,
        createdAt: DateTime.now(),
      );

      await _repository.saveCostLayerConsumption(consumption);

      // Reduce the remaining quantity to consume
      remainingQuantityToConsume -= quantityToConsumeFromLayer;
    }

    // If we couldn't fully consume the quantity, throw an error
    if (remainingQuantityToConsume > 0.001) {
      // Using a small epsilon for floating point comparison
      throw Exception(
          'Insufficient quantity available for item ${item.itemName}');
    }

    // Update the item's cost
    final updatedItem = item.copyWith(
      costAtTransaction: totalCost / item.quantity.abs(),
    );

    // Update inventory quantity (negative for outbound)
    await _repository.updateInventoryQuantity(item.itemId, movement.warehouseId,
        item.quantity // Already negative for outbound
        );
  }

  /// Determine if a movement type is inbound
  bool _isInboundMovement(InventoryMovementType type) {
    return type == InventoryMovementType.receipt ||
        type == InventoryMovementType.return_ ||
        type == InventoryMovementType.production ||
        type == InventoryMovementType.purchaseReceipt ||
        type == InventoryMovementType.productionOutput;
  }
}
