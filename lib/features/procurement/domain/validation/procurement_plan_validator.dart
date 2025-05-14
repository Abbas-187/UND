import '../entities/procurement_plan.dart';

/// Result of a validation operation.
class ValidationResult {

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  /// Creates a valid result with no errors or warnings.
  factory ValidationResult.valid() => const ValidationResult(isValid: true);

  /// Creates an invalid result with the specified errors.
  factory ValidationResult.invalid(List<String> errors) =>
      ValidationResult(isValid: false, errors: errors);

  /// Creates a valid result with warnings.
  factory ValidationResult.withWarnings(List<String> warnings) =>
      ValidationResult(isValid: true, warnings: warnings);
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
}

/// Validator for procurement plans.
class ProcurementPlanValidator {
  /// Validates a procurement plan.
  ///
  /// [plan] - The procurement plan to validate
  /// Returns a validation result
  Future<ValidationResult> validate(ProcurementPlan plan) async {
    final errors = <String>[];
    final warnings = <String>[];

    // Validate plan data
    if (plan.name.isEmpty) {
      errors.add('Plan name cannot be empty');
    }

    if (plan.items.isEmpty) {
      errors.add('Plan must have at least one item');
    }

    // Validate budget constraints
    if (plan.budgetLimit != null &&
        plan.estimatedTotalCost > plan.budgetLimit!) {
      errors.add('Total cost exceeds budget limit');
    }

    // Validate each procurement item
    for (final item in plan.items) {
      _validateProcurementItem(item, errors, warnings);
    }

    // Check for any items with zero or negative quantities
    final hasInvalidQuantities = plan.items.any((item) => item.quantity <= 0);
    if (hasInvalidQuantities) {
      errors.add('All items must have positive quantities');
    }

    // Check if any items have unreasonably high quantities
    final hasUnreasonablyHighQuantities =
        plan.items.any((item) => item.quantity > 10000);
    if (hasUnreasonablyHighQuantities) {
      warnings.add('Some items have unusually high quantities');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validates a procurement plan item.
  void _validateProcurementItem(
    ProcurementPlanItem item,
    List<String> errors,
    List<String> warnings,
  ) {
    if (item.itemName.isEmpty) {
      errors.add('Item name cannot be empty: ${item.id}');
    }

    if (item.quantity <= 0) {
      errors.add('Item quantity must be positive: ${item.itemName}');
    }

    if (item.estimatedUnitCost <= 0) {
      errors.add('Item unit cost must be positive: ${item.itemName}');
    }

    // Validate required date
    final now = DateTime.now();
    if (item.requiredByDate.isBefore(now)) {
      errors.add('Required date cannot be in the past: ${item.itemName}');
    }

    // Business logic validation
    if (item.estimatedTotalCost != item.quantity * item.estimatedUnitCost) {
      errors.add('Total cost calculation mismatch for item: ${item.itemName}');
    }

    // Warning for high cost items
    if (item.estimatedTotalCost > 10000) {
      warnings.add('High cost item: ${item.itemName}');
    }
  }
}
