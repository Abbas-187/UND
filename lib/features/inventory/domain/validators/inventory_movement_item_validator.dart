import '../../../../core/utils/validator.dart';
import '../../data/models/inventory_movement_item_model.dart';

/// Validator for inventory movement items
/// Ensures that required fields like batchLotNumber, productionDate and expirationDate
/// are present for perishable items
class InventoryMovementItemValidator
    extends Validator<InventoryMovementItemModel> {
  InventoryMovementItemValidator({this.isPerishable = false});

  /// Whether the item is perishable and requires full batch tracking
  final bool isPerishable;

  @override
  ValidationResult validateValue(InventoryMovementItemModel item) {
    final errors = <String>[];

    // Basic validation for all items
    if (item.itemId.isEmpty) {
      errors.add('Item ID is required');
    }
    if (item.itemCode.isEmpty) {
      errors.add('Item code is required');
    }
    if (item.itemName.isEmpty) {
      errors.add('Item name is required');
    }
    if (item.uom.isEmpty) {
      errors.add('Unit of measure is required');
    }

    // Additional validation for perishable items
    if (isPerishable) {
      if (item.batchLotNumber == null || item.batchLotNumber!.isEmpty) {
        errors.add('Batch/Lot number is required for perishable items');
      }
      if (item.expirationDate == null) {
        errors.add('Expiration date is required for perishable items');
      } else {
        // Ensure expiration date is in the future
        if (item.expirationDate!.isBefore(DateTime.now())) {
          errors.add('Expiration date must be in the future');
        }
      }
      if (item.productionDate == null) {
        errors.add('Production date is required for perishable items');
      } else {
        // Ensure production date is not in the future
        if (item.productionDate!.isAfter(DateTime.now())) {
          errors.add('Production date cannot be in the future');
        }
        // If expiration date is set, ensure production date is before expiration
        if (item.expirationDate != null &&
            item.productionDate!.isAfter(item.expirationDate!)) {
          errors.add('Production date must be before expiration date');
        }
      }
    }

    // For inbound movements, cost validation
    if (item.quantity > 0 &&
        (item.costAtTransaction == null || item.costAtTransaction! <= 0)) {
      errors.add(
          'Cost at transaction is required for inbound movements and must be greater than zero');
    }

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }
}
