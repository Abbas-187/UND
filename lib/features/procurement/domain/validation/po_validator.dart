import '../entities/purchase_order.dart';
import '../validation/procurement_plan_validator.dart';

/// Validator for purchase orders.
class POValidator {
  /// Validates a purchase order.
  ///
  /// [po] - The purchase order to validate
  /// Returns a validation result
  Future<ValidationResult> validate(PurchaseOrder po) async {
    final errors = <String>[];
    final warnings = <String>[];

    // Validate basic purchase order data
    if (po.poNumber.isEmpty) {
      errors.add('Purchase order number cannot be empty');
    }

    if (po.supplierId.isEmpty) {
      errors.add('Supplier ID cannot be empty');
    }

    if (po.supplierName.isEmpty) {
      errors.add('Supplier name cannot be empty');
    }

    if (po.items.isEmpty) {
      errors.add('Purchase order must have at least one item');
    }

    // Validate required fields for approval workflow
    if (po.reasonForRequest.isEmpty) {
      errors.add('Reason for request is required');
    }

    if (po.intendedUse.isEmpty) {
      errors.add('Intended use is required');
    }

    if (po.quantityJustification.isEmpty) {
      errors.add('Quantity justification is required');
    }

    // Validate items
    for (final item in po.items) {
      _validatePurchaseOrderItem(item, errors, warnings);
    }

    // Validate total amount
    final calculatedTotal = po.items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

    if ((calculatedTotal - po.totalAmount).abs() > 0.01) {
      errors.add('Total amount does not match sum of item costs');
    }

    // Check for any items with zero or negative quantities
    final hasInvalidQuantities = po.items.any((item) => item.quantity <= 0);
    if (hasInvalidQuantities) {
      errors.add('All items must have positive quantities');
    }

    // Warning for high value purchase orders
    if (po.totalAmount > 100000) {
      warnings.add('High value purchase order (over \$100,000)');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validates a purchase order item.
  void _validatePurchaseOrderItem(
    PurchaseOrderItem item,
    List<String> errors,
    List<String> warnings,
  ) {
    if (item.itemName.isEmpty) {
      errors.add('Item name cannot be empty: ${item.id}');
    }

    if (item.quantity <= 0) {
      errors.add('Item quantity must be positive: ${item.itemName}');
    }

    if (item.unitPrice <= 0) {
      errors.add('Item unit cost must be positive: \\${item.itemName}');
    }

    // Validate required date is in the future
    final now = DateTime.now();
    if (item.requiredByDate.isBefore(now)) {
      errors.add('Required date cannot be in the past: ${item.itemName}');
    }

    // Check for pricing calculation issues
    final calculatedTotal = item.quantity * item.unitPrice;
    if ((calculatedTotal - item.totalPrice).abs() > 0.01) {
      errors.add(
          'Total cost for item \\${item.itemName} does not match quantity * unit cost');
    }

    // Warning for large quantities
    if (item.quantity > 1000) {
      warnings.add('Large quantity ordered for item: ${item.itemName}');
    }

    // Warning for high unit price
    if (item.unitPrice > 5000) {
      warnings.add('High unit cost for item: \\${item.itemName}');
    }
  }
}
