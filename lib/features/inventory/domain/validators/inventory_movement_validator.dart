import '../../data/models/inventory_movement_model.dart';

/// Validator for inventory movements
/// Ensures that required fields for auditability are present based on movement type
class InventoryMovementValidator {
  const InventoryMovementValidator();

  /// Validate an inventory movement for audit compliance
  ValidationResult validate(InventoryMovementModel movement) {
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
