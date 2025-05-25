import '../../../sales/data/repositories/product_catalog_repository.dart';
import '../../data/models/inventory_movement_model.dart';

/// Validator for inventory movements
/// Ensures that required fields for auditability are present based on movement type
class InventoryMovementValidator {
  InventoryMovementValidator(
      {ProductCatalogRepository? productCatalogRepository})
      : _productCatalogRepository =
            productCatalogRepository ?? ProductCatalogRepository();

  final ProductCatalogRepository _productCatalogRepository;

  /// Validate an inventory movement for audit compliance
  Future<ValidationResult> validateAsync(
      InventoryMovementModel movement) async {
    final errors = <String>[];

    // Basic validation for all movements
    if (movement.documentNumber.isEmpty) {
      errors.add('Document number is required');
    }

    if (movement.warehouseId.isEmpty) {
      errors.add('Warehouse ID is required');
    }

    if (movement.initiatingEmployeeId.isEmpty) {
      errors.add('Initiating employee ID is required for audit traceability');
    }

    // Validate source/target warehouse for transfers
    if (movement.isTransfer) {
      if (movement.sourceWarehouseId == null ||
          movement.sourceWarehouseId!.isEmpty) {
        errors.add('Source warehouse ID is required for transfers');
      }

      if (movement.targetWarehouseId == null ||
          movement.targetWarehouseId!.isEmpty) {
        errors.add('Target warehouse ID is required for transfers');
      }

      if (movement.sourceWarehouseId == movement.targetWarehouseId &&
          movement.movementType ==
              InventoryMovementType.interWarehouseTransfer) {
        errors.add(
            'Source and target warehouses must be different for inter-warehouse transfers');
      }
    }

    // Validate reason notes for adjustments and other specific movements
    if (movement.requiresReasonNotes &&
        (movement.reasonNotes == null || movement.reasonNotes!.isEmpty)) {
      errors.add(
          'Reason notes are required for ${movement.movementTypeDisplay.toLowerCase()} movements');
    }

    // For sales issues and purchase receipts, reference document is required
    if ((movement.movementType == InventoryMovementType.salesIssue ||
            movement.movementType == InventoryMovementType.purchaseReceipt) &&
        (movement.referenceDocuments == null ||
            movement.referenceDocuments!.isEmpty)) {
      errors.add(
          'Reference document ID is required for ${movement.movementTypeDisplay.toLowerCase()} movements');
    }

    // Validate items list is not empty
    if (movement.items.isEmpty) {
      errors.add('At least one item is required for the movement');
    } else {
      // Batch/expiry validation for each item
      for (final item in movement.items) {
        try {
          final product =
              await _productCatalogRepository.getProductById(item.itemId);
          final isBatchTracked = product.isBatchTracked;
          final isPerishable = product.isPerishable;
          if (!item.hasRequiredBatchInfo(isPerishable, isBatchTracked)) {
            if (isPerishable &&
                (item.batchLotNumber == null || item.expirationDate == null)) {
              errors.add(
                  'Batch/expiry required for perishable item: \'${item.itemName}\'');
            } else if (isBatchTracked && item.batchLotNumber == null) {
              errors.add(
                  'Batch number required for batch-tracked item: \'${item.itemName}\'');
            }
          }
        } catch (e) {
          errors.add(
              'Failed to validate batch/expiry for item: ${item.itemName}');
        }
      }
    }

    // For completed movements, check if they have approval info
    if (movement.status == InventoryMovementStatus.completed) {
      if (movement.approvedById == null || movement.approvedById!.isEmpty) {
        errors.add('Approver ID is required for completed movements');
      }

      if (movement.approvedAt == null) {
        errors.add('Approval date is required for completed movements');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

/// Result of validation
class ValidationResult {
  const ValidationResult({
    required this.isValid,
    required this.errors,
  });

  final bool isValid;
  final List<String> errors;
}
