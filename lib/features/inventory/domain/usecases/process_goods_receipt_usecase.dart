import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/inventory_movement_item_model.dart';
import '../../data/models/inventory_movement_model.dart';
import '../entities/cost_layer.dart';
import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';
import '../providers/inventory_repository_provider.dart' as repo_provider;
import '../validators/inventory_movement_validator.dart';
import 'process_inventory_movement_usecase.dart';

/// Data transfer object for goods receipt from procurement
class GoodsReceiptData {
  const GoodsReceiptData({
    required this.poNumber,
    required this.poLineItemId,
    required this.itemId,
    required this.supplierId,
    required this.supplierName,
    required this.receivedQuantity,
    required this.costAtTransaction,
    this.batchLotNumber,
    this.expirationDate,
    this.productionDate,
    this.deliveryNoteReference,
    this.qualityStatus = 'PENDING_INSPECTION',
    this.warehouseId = 'MAIN',
  });

  final String poNumber;
  final String poLineItemId;
  final String itemId;
  final String supplierId;
  final String supplierName;
  final double receivedQuantity;
  final double costAtTransaction;
  final String? batchLotNumber;
  final DateTime? expirationDate;
  final DateTime? productionDate;
  final String? deliveryNoteReference;
  final String qualityStatus;
  final String warehouseId;
}

/// Result of goods receipt processing
class GoodsReceiptResult {
  const GoodsReceiptResult({
    required this.success,
    this.movementId,
    this.errors = const [],
    this.warnings = const [],
  });

  final bool success;
  final String? movementId;
  final List<String> errors;
  final List<String> warnings;
}

/// Use case for processing goods receipt from purchase orders
class ProcessGoodsReceiptUseCase {
  const ProcessGoodsReceiptUseCase(
    this._repository,
    this._processMovementUseCase,
  );

  final InventoryRepository _repository;
  final ProcessInventoryMovementUseCase _processMovementUseCase;

  /// Process goods receipt from procurement module
  Future<GoodsReceiptResult> execute({
    required List<GoodsReceiptData> receipts,
    required String receivedBy,
    String? notes,
  }) async {
    final errors = <String>[];
    final warnings = <String>[];

    try {
      // Validate all items exist in inventory master
      for (final receipt in receipts) {
        final item = await _repository.getInventoryItem(receipt.itemId);
        if (item == null) {
          errors.add('Item not found in inventory: ${receipt.itemId}');
          continue;
        }

        // Check if item requires batch tracking
        final requiresBatchTracking =
            item.additionalAttributes?['requiresBatchTracking'] == true;
        final isPerishable = item.additionalAttributes?['isPerishable'] == true;

        if ((requiresBatchTracking || isPerishable) &&
            (receipt.batchLotNumber == null ||
                receipt.batchLotNumber!.isEmpty)) {
          errors.add('Batch number is required for item: ${item.name}');
        }

        if (isPerishable && receipt.expirationDate == null) {
          errors.add(
              'Expiration date is required for perishable item: ${item.name}');
        }

        // Validate cost
        if (receipt.costAtTransaction <= 0) {
          errors.add('Invalid cost for item: ${item.name}');
        }

        // Validate quantity
        if (receipt.receivedQuantity <= 0) {
          errors.add('Invalid quantity for item: ${item.name}');
        }
      }

      if (errors.isNotEmpty) {
        return GoodsReceiptResult(success: false, errors: errors);
      }

      // Create inventory movement
      final movement = await _createInventoryMovement(
        receipts: receipts,
        receivedBy: receivedBy,
        notes: notes,
      );

      // Process the movement using existing use case
      final result = await _processMovementUseCase.execute(
        movement: movement,
        validateBatchTracking: true,
        costingMethod: CostingMethod.fifo,
      );

      if (!result.success) {
        return GoodsReceiptResult(
          success: false,
          errors: result.errors,
        );
      }

      return GoodsReceiptResult(
        success: true,
        movementId: result.movementId,
        warnings: warnings,
      );
    } catch (e) {
      errors.add('Error processing goods receipt: ${e.toString()}');
      return GoodsReceiptResult(success: false, errors: errors);
    }
  }

  /// Create inventory movement from goods receipt data
  Future<InventoryMovementModel> _createInventoryMovement({
    required List<GoodsReceiptData> receipts,
    required String receivedBy,
    String? notes,
  }) async {
    final movementId = const Uuid().v4();
    final now = DateTime.now();

    // Group receipts by warehouse
    final warehouseId = receipts.first.warehouseId;

    // Create movement items
    final items = <InventoryMovementItemModel>[];

    for (final receipt in receipts) {
      final item = await _repository.getInventoryItem(receipt.itemId);
      if (item == null) continue;

      final movementItem = InventoryMovementItemModel(
        id: const Uuid().v4(),
        itemId: receipt.itemId,
        itemCode: item.sapCode,
        itemName: item.name,
        quantity: receipt.receivedQuantity,
        uom: item.unit,
        batchLotNumber: receipt.batchLotNumber,
        expirationDate: receipt.expirationDate,
        productionDate: receipt.productionDate,
        costAtTransaction: receipt.costAtTransaction,
        qualityStatus: receipt.qualityStatus,
      );

      items.add(movementItem);
    }

    // Create the movement with correct constructor parameters
    final movement = InventoryMovementModel(
      id: movementId,
      documentNumber: 'GR-${now.millisecondsSinceEpoch}',
      movementType: InventoryMovementType.purchaseReceipt,
      warehouseId: warehouseId,
      movementDate: now,
      items: items,
      createdAt: now,
      updatedAt: now,
      initiatingEmployeeId: receivedBy,
      reasonNotes: notes ??
          'Goods receipt from PO: ${receipts.map((r) => r.poNumber).toSet().join(', ')}',
      referenceType: 'PURCHASE_ORDER',
      referenceNumber: receipts.first.poNumber,
      referenceDocuments: receipts
          .map((r) =>
              'PO_LINE:${r.poLineItemId}:${r.poNumber}:${r.supplierId}:${r.supplierName}:${r.deliveryNoteReference ?? ''}')
          .toList(),
      status: InventoryMovementStatus.completed,
      approvedById: receivedBy,
      approvedAt: now,
    );

    return movement;
  }
}

/// Provider for ProcessGoodsReceiptUseCase
final processGoodsReceiptUseCaseProvider =
    Provider<ProcessGoodsReceiptUseCase>((ref) {
  return ProcessGoodsReceiptUseCase(
    ref.watch(repo_provider.inventoryRepositoryProvider),
    ProcessInventoryMovementUseCase(
        ref.watch(repo_provider.inventoryRepositoryProvider)),
  );
});
