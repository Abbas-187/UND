import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../entities/cost_layer.dart';
import '../../entities/inventory_item.dart';
import '../../repositories/inventory_repository.dart';
import '../../providers/inventory_repository_provider.dart' as repo_provider;
import '../../../data/models/inventory_movement_model.dart';
import '../../../data/models/inventory_movement_item_model.dart';
import '../process_inventory_movement_usecase.dart';

/// Data for finished goods receipt from production
class FinishedGoodsReceiptData {
  const FinishedGoodsReceiptData({
    required this.finishedGoodInventoryItemId,
    required this.quantityProduced,
    required this.newBatchLotNumber,
    required this.finishedGoodProductionDate,
    required this.costOfFinishedGood,
    this.finishedGoodExpirationDate,
    this.qualityStatus = 'AVAILABLE',
    this.notes,
  });

  final String finishedGoodInventoryItemId;
  final double quantityProduced;
  final String newBatchLotNumber;
  final DateTime finishedGoodProductionDate;
  final DateTime? finishedGoodExpirationDate;
  final double costOfFinishedGood; // Unit cost calculated by factory module
  final String qualityStatus;
  final String? notes;
}

/// Result of finished goods receipt
class FinishedGoodsReceiptResult {
  const FinishedGoodsReceiptResult({
    required this.success,
    required this.productionOrderId,
    this.movementId,
    this.finishedGoodItemId,
    this.quantityReceived = 0.0,
    this.totalValue = 0.0,
    this.batchNumber,
    this.errors = const [],
    this.warnings = const [],
  });

  final bool success;
  final String productionOrderId;
  final String? movementId;
  final String? finishedGoodItemId;
  final double quantityReceived;
  final double totalValue;
  final String? batchNumber;
  final List<String> errors;
  final List<String> warnings;
}

/// Use case for receiving finished goods from production completion
class ReceiveFinishedGoodsUseCase {
  const ReceiveFinishedGoodsUseCase(
    this._repository,
    this._processMovementUseCase,
  );

  final InventoryRepository _repository;
  final ProcessInventoryMovementUseCase _processMovementUseCase;

  /// Receive finished goods from production
  Future<FinishedGoodsReceiptResult> execute({
    required String productionOrderId,
    required FinishedGoodsReceiptData finishedGoodsData,
    required String receivedBy,
    String warehouseId = 'MAIN',
    String? notes,
  }) async {
    final errors = <String>[];
    final warnings = <String>[];

    try {
      // Validate production order exists
      if (productionOrderId.isEmpty) {
        errors.add('Production order ID is required');
        return FinishedGoodsReceiptResult(
          success: false,
          productionOrderId: productionOrderId,
          errors: errors,
        );
      }

      // Validate finished goods data
      final validationErrors = _validateFinishedGoodsData(finishedGoodsData);
      if (validationErrors.isNotEmpty) {
        errors.addAll(validationErrors);
        return FinishedGoodsReceiptResult(
          success: false,
          productionOrderId: productionOrderId,
          errors: errors,
        );
      }

      // Verify the finished good inventory item exists
      final inventoryItem = await _repository.getInventoryItem(
        finishedGoodsData.finishedGoodInventoryItemId,
      );
      if (inventoryItem == null) {
        errors.add(
          'Finished good inventory item not found: ${finishedGoodsData.finishedGoodInventoryItemId}',
        );
        return FinishedGoodsReceiptResult(
          success: false,
          productionOrderId: productionOrderId,
          errors: errors,
        );
      }

      // Check for duplicate batch numbers
      final batchExists = await _checkBatchExists(
        finishedGoodsData.finishedGoodInventoryItemId,
        finishedGoodsData.newBatchLotNumber,
        warehouseId,
      );
      if (batchExists) {
        warnings.add(
          'Batch number ${finishedGoodsData.newBatchLotNumber} already exists for item ${inventoryItem.name}',
        );
      }

      // Validate expiry date logic
      if (finishedGoodsData.finishedGoodExpirationDate != null &&
          finishedGoodsData.finishedGoodExpirationDate!
              .isBefore(finishedGoodsData.finishedGoodProductionDate)) {
        errors.add('Expiry date cannot be before production date');
        return FinishedGoodsReceiptResult(
          success: false,
          productionOrderId: productionOrderId,
          errors: errors,
        );
      }

      // Create inventory movement for finished goods receipt
      final movementId = await _createFinishedGoodsMovement(
        productionOrderId: productionOrderId,
        finishedGoodsData: finishedGoodsData,
        inventoryItem: inventoryItem,
        warehouseId: warehouseId,
        receivedBy: receivedBy,
        notes: notes,
      );

      final totalValue = finishedGoodsData.quantityProduced *
          finishedGoodsData.costOfFinishedGood;

      return FinishedGoodsReceiptResult(
        success: true,
        productionOrderId: productionOrderId,
        movementId: movementId,
        finishedGoodItemId: finishedGoodsData.finishedGoodInventoryItemId,
        quantityReceived: finishedGoodsData.quantityProduced,
        totalValue: totalValue,
        batchNumber: finishedGoodsData.newBatchLotNumber,
        warnings: warnings,
      );
    } catch (e) {
      errors.add('Unexpected error during finished goods receipt: $e');
      return FinishedGoodsReceiptResult(
        success: false,
        productionOrderId: productionOrderId,
        errors: errors,
        warnings: warnings,
      );
    }
  }

  /// Validate finished goods data
  List<String> _validateFinishedGoodsData(FinishedGoodsReceiptData data) {
    final errors = <String>[];

    if (data.finishedGoodInventoryItemId.isEmpty) {
      errors.add('Finished good inventory item ID is required');
    }

    if (data.quantityProduced <= 0) {
      errors.add('Quantity produced must be greater than zero');
    }

    if (data.newBatchLotNumber.isEmpty) {
      errors.add('Batch lot number is required');
    }

    if (data.costOfFinishedGood < 0) {
      errors.add('Cost of finished good cannot be negative');
    }

    // Validate quality status
    const validQualityStatuses = [
      'AVAILABLE',
      'PENDING_QC',
      'QUARANTINE',
      'APPROVED',
      'REJECTED',
    ];
    if (!validQualityStatuses.contains(data.qualityStatus)) {
      errors.add('Invalid quality status: ${data.qualityStatus}');
    }

    return errors;
  }

  /// Check if batch number already exists
  Future<bool> _checkBatchExists(
    String itemId,
    String batchNumber,
    String warehouseId,
  ) async {
    try {
      // This would typically check the cost layers or inventory movements
      // For now, we'll assume it doesn't exist
      // In a real implementation, you would query the repository
      return false;
    } catch (e) {
      // If we can't check, assume it doesn't exist
      return false;
    }
  }

  /// Create inventory movement for finished goods receipt
  Future<String> _createFinishedGoodsMovement({
    required String productionOrderId,
    required FinishedGoodsReceiptData finishedGoodsData,
    required InventoryItem inventoryItem,
    required String warehouseId,
    required String receivedBy,
    String? notes,
  }) async {
    final movementId = const Uuid().v4();
    final now = DateTime.now();

    // Create movement item
    final movementItem = InventoryMovementItemModel(
      id: const Uuid().v4(),
      itemId: finishedGoodsData.finishedGoodInventoryItemId,
      itemCode: inventoryItem.sapCode,
      itemName: inventoryItem.name,
      quantity: finishedGoodsData.quantityProduced,
      uom: inventoryItem.unit,
      batchLotNumber: finishedGoodsData.newBatchLotNumber,
      expirationDate: finishedGoodsData.finishedGoodExpirationDate,
      productionDate: finishedGoodsData.finishedGoodProductionDate,
      costAtTransaction: finishedGoodsData.costOfFinishedGood,
      qualityStatus: finishedGoodsData.qualityStatus,
      notes: finishedGoodsData.notes ?? notes,
    );

    // Create the movement
    final movement = InventoryMovementModel(
      id: movementId,
      documentNumber: 'PO-${now.millisecondsSinceEpoch}',
      movementType: InventoryMovementType.productionOutput,
      warehouseId: warehouseId,
      movementDate: now,
      items: [movementItem],
      createdAt: now,
      updatedAt: now,
      initiatingEmployeeId: receivedBy,
      reasonNotes: notes ??
          'Finished goods receipt from production order: $productionOrderId',
      referenceType: 'PRODUCTION_ORDER',
      referenceNumber: productionOrderId,
      referenceDocuments: ['PRODUCTION_ORDER:$productionOrderId'],
      status: InventoryMovementStatus.completed,
      approvedById: receivedBy,
      approvedAt: now,
    );

    // Process the movement
    final result = await _processMovementUseCase.execute(
      movement: movement,
      validateBatchTracking: true,
      costingMethod: CostingMethod.fifo,
    );

    if (!result.success) {
      throw Exception(
          'Failed to process finished goods movement: ${result.errors.join(', ')}');
    }

    return movementId;
  }

  /// Calculate finished goods cost based on material costs and overhead
  static double calculateFinishedGoodsCost({
    required double totalMaterialCost,
    required double laborCost,
    required double overheadCost,
    required double quantityProduced,
  }) {
    if (quantityProduced <= 0) {
      throw ArgumentError('Quantity produced must be greater than zero');
    }

    final totalCost = totalMaterialCost + laborCost + overheadCost;
    return totalCost / quantityProduced;
  }

  /// Calculate expiry date based on shelf life
  static DateTime? calculateExpiryDate({
    required DateTime productionDate,
    int? shelfLifeDays,
  }) {
    if (shelfLifeDays == null || shelfLifeDays <= 0) {
      return null;
    }

    return productionDate.add(Duration(days: shelfLifeDays));
  }
}

/// Provider for ReceiveFinishedGoodsUseCase
final receiveFinishedGoodsUseCaseProvider =
    Provider<ReceiveFinishedGoodsUseCase>((ref) {
  return ReceiveFinishedGoodsUseCase(
    ref.watch(repo_provider.inventoryRepositoryProvider),
    ProcessInventoryMovementUseCase(
      ref.watch(repo_provider.inventoryRepositoryProvider),
    ),
  );
});
