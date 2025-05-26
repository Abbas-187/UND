import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/inventory_movement_item_model.dart';
import '../../data/models/inventory_movement_model.dart';
import '../entities/cost_layer.dart';
import '../providers/inventory_repository_provider.dart' as repo_provider;
import '../repositories/inventory_repository.dart';
import 'process_inventory_movement_usecase.dart';

/// Data transfer object for return to supplier
class ReturnToSupplierData {
  const ReturnToSupplierData({
    required this.returnToSupplierId,
    required this.itemId,
    required this.supplierId,
    required this.supplierName,
    required this.returnedQuantity,
    required this.reasonForReturn,
    this.poNumber,
    this.batchLotNumber,
    this.warehouseId = 'MAIN',
  });

  final String returnToSupplierId;
  final String itemId;
  final String supplierId;
  final String supplierName;
  final double returnedQuantity;
  final String reasonForReturn;
  final String? poNumber;
  final String? batchLotNumber;
  final String warehouseId;
}

/// Result of return to supplier processing
class ReturnToSupplierResult {
  const ReturnToSupplierResult({
    required this.success,
    this.movementId,
    this.totalCost = 0.0,
    this.errors = const [],
    this.warnings = const [],
  });

  final bool success;
  final String? movementId;
  final double totalCost;
  final List<String> errors;
  final List<String> warnings;
}

/// Use case for processing returns to suppliers
class ProcessReturnToSupplierUseCase {
  const ProcessReturnToSupplierUseCase(
    this._repository,
    this._processMovementUseCase,
  );

  final InventoryRepository _repository;
  final ProcessInventoryMovementUseCase _processMovementUseCase;

  /// Process return to supplier from procurement module
  Future<ReturnToSupplierResult> execute({
    required List<ReturnToSupplierData> returns,
    required String returnedBy,
    String? notes,
  }) async {
    final errors = <String>[];
    final warnings = <String>[];
    double totalCost = 0.0;

    try {
      // Validate all items and check availability
      for (final returnData in returns) {
        final item = await _repository.getInventoryItem(returnData.itemId);
        if (item == null) {
          errors.add('Item not found in inventory: ${returnData.itemId}');
          continue;
        }

        // Check if item requires batch tracking
        final requiresBatchTracking =
            item.additionalAttributes?['requiresBatchTracking'] == true;

        if (requiresBatchTracking &&
            (returnData.batchLotNumber == null ||
                returnData.batchLotNumber!.isEmpty)) {
          errors.add('Batch number is required for item: ${item.name}');
          continue;
        }

        // Validate quantity
        if (returnData.returnedQuantity <= 0) {
          errors.add('Invalid quantity for item: ${item.name}');
          continue;
        }

        // Check if sufficient quantity is available
        final availableQuantity = await _getAvailableQuantity(
          returnData.itemId,
          returnData.warehouseId,
          returnData.batchLotNumber,
        );

        if (availableQuantity < returnData.returnedQuantity) {
          errors.add('Insufficient quantity available for item: ${item.name}. '
              'Available: $availableQuantity, Requested: ${returnData.returnedQuantity}');
        }
      }

      if (errors.isNotEmpty) {
        return ReturnToSupplierResult(success: false, errors: errors);
      }

      // Calculate cost of returned items
      totalCost = await _calculateReturnCost(returns);

      // Create inventory movement
      final movement = await _createReturnMovement(
        returns: returns,
        returnedBy: returnedBy,
        notes: notes,
        totalCost: totalCost,
      );

      // Process the movement using existing use case
      final result = await _processMovementUseCase.execute(
        movement: movement,
        validateBatchTracking: true,
        costingMethod: CostingMethod.fifo,
      );

      if (!result.success) {
        return ReturnToSupplierResult(
          success: false,
          errors: result.errors,
        );
      }

      return ReturnToSupplierResult(
        success: true,
        movementId: result.movementId,
        totalCost: totalCost,
        warnings: warnings,
      );
    } catch (e) {
      errors.add('Error processing return to supplier: ${e.toString()}');
      return ReturnToSupplierResult(success: false, errors: errors);
    }
  }

  /// Get available quantity for an item (optionally filtered by batch)
  Future<double> _getAvailableQuantity(
    String itemId,
    String warehouseId,
    String? batchLotNumber,
  ) async {
    final costLayers = await _repository.getAvailableCostLayers(
      itemId,
      warehouseId,
      CostingMethod.fifo,
    );

    if (batchLotNumber != null) {
      // Filter by specific batch
      final batchLayers = costLayers.where(
        (layer) => layer.batchLotNumber == batchLotNumber,
      );
      return batchLayers.fold<double>(
          0.0, (sum, layer) => sum + layer.remainingQuantity);
    } else {
      // Total available quantity
      return costLayers.fold<double>(
          0.0, (sum, layer) => sum + layer.remainingQuantity);
    }
  }

  /// Calculate the cost of returned items based on original cost layers
  Future<double> _calculateReturnCost(
      List<ReturnToSupplierData> returns) async {
    double totalCost = 0.0;

    for (final returnData in returns) {
      final costLayers = await _repository.getAvailableCostLayers(
        returnData.itemId,
        returnData.warehouseId,
        CostingMethod.fifo, // Use FIFO to get oldest cost first
      );

      // Filter by batch if specified
      final relevantLayers = returnData.batchLotNumber != null
          ? costLayers
              .where(
                  (layer) => layer.batchLotNumber == returnData.batchLotNumber)
              .toList()
          : costLayers;

      if (relevantLayers.isEmpty) {
        continue; // Skip if no cost layers found
      }

      // Calculate cost using FIFO method (oldest cost first)
      double remainingToReturn = returnData.returnedQuantity;

      for (final layer in relevantLayers) {
        if (remainingToReturn <= 0) break;

        final quantityFromLayer = remainingToReturn > layer.remainingQuantity
            ? layer.remainingQuantity
            : remainingToReturn;

        totalCost += quantityFromLayer * layer.costAtTransaction;
        remainingToReturn -= quantityFromLayer;
      }
    }

    return totalCost;
  }

  /// Create inventory movement for return to supplier
  Future<InventoryMovementModel> _createReturnMovement({
    required List<ReturnToSupplierData> returns,
    required String returnedBy,
    String? notes,
    required double totalCost,
  }) async {
    final movementId = const Uuid().v4();
    final now = DateTime.now();

    // Group returns by warehouse
    final warehouseId = returns.first.warehouseId;

    // Create movement items
    final items = <InventoryMovementItemModel>[];

    for (final returnData in returns) {
      final item = await _repository.getInventoryItem(returnData.itemId);
      if (item == null) continue;

      // Calculate cost for this specific return
      final itemCost = await _calculateItemReturnCost(returnData);

      final movementItem = InventoryMovementItemModel(
        id: const Uuid().v4(),
        itemId: returnData.itemId,
        itemCode: item.sapCode,
        itemName: item.name,
        quantity: -returnData.returnedQuantity, // Negative for outbound
        uom: item.unit,
        batchLotNumber: returnData.batchLotNumber,
        costAtTransaction:
            itemCost / returnData.returnedQuantity, // Cost per unit
        qualityStatus: 'RETURNED',
      );

      items.add(movementItem);
    }

    // Create the movement
    final movement = InventoryMovementModel(
      id: movementId,
      documentNumber: 'RTS-${now.millisecondsSinceEpoch}',
      movementType: InventoryMovementType.return_,
      warehouseId: warehouseId,
      movementDate: now,
      items: items,
      createdAt: now,
      updatedAt: now,
      initiatingEmployeeId: returnedBy,
      reasonNotes: notes ??
          'Return to supplier: ${returns.map((r) => r.reasonForReturn).toSet().join(', ')}',
      referenceType: 'SUPPLIER_RETURN',
      referenceNumber: returns.first.returnToSupplierId,
      referenceDocuments: returns
          .map((r) =>
              'RETURN:${r.returnToSupplierId}:${r.supplierId}:${r.supplierName}:${r.poNumber ?? ''}:${r.reasonForReturn}')
          .toList(),
      status: InventoryMovementStatus.completed,
      approvedById: returnedBy,
      approvedAt: now,
    );

    return movement;
  }

  /// Calculate cost for a specific item return
  Future<double> _calculateItemReturnCost(
      ReturnToSupplierData returnData) async {
    final costLayers = await _repository.getAvailableCostLayers(
      returnData.itemId,
      returnData.warehouseId,
      CostingMethod.fifo,
    );

    // Filter by batch if specified
    final relevantLayers = returnData.batchLotNumber != null
        ? costLayers
            .where((layer) => layer.batchLotNumber == returnData.batchLotNumber)
            .toList()
        : costLayers;

    if (relevantLayers.isEmpty) {
      return 0.0;
    }

    double totalCost = 0.0;
    double remainingToReturn = returnData.returnedQuantity;

    for (final layer in relevantLayers) {
      if (remainingToReturn <= 0) break;

      final quantityFromLayer = remainingToReturn > layer.remainingQuantity
          ? layer.remainingQuantity
          : remainingToReturn;

      totalCost += quantityFromLayer * layer.costAtTransaction;
      remainingToReturn -= quantityFromLayer;
    }

    return totalCost;
  }
}

/// Provider for ProcessReturnToSupplierUseCase
final processReturnToSupplierUseCaseProvider =
    Provider<ProcessReturnToSupplierUseCase>((ref) {
  return ProcessReturnToSupplierUseCase(
    ref.watch(repo_provider.inventoryRepositoryProvider),
    ProcessInventoryMovementUseCase(
        ref.watch(repo_provider.inventoryRepositoryProvider)),
  );
});
