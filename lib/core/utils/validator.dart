/// A generic validator interface for validating models of type T
abstract class Validator<T> {
  /// Validates the given value and returns a ValidationResult.
  /// Throws [ArgumentError] if the value is null.
  ValidationResult validate(T value) {
    if (value == null) {
      throw ArgumentError('Value to validate cannot be null');
    }
    try {
      return validateValue(value);
    } catch (e) {
      // Optionally log error for diagnostics
      return ValidationResult.invalid(['Validation error: \\${e.toString()}']);
    }
  }

  /// Implement this method in subclasses to provide validation logic.
  ValidationResult validateValue(T value);
}

/// Result of validation
class ValidationResult {
  /// Helper to create a valid result
  factory ValidationResult.valid() =>
      const ValidationResult(isValid: true, errors: []);

  /// Helper to create an invalid result
  factory ValidationResult.invalid(List<String> errors) =>
      ValidationResult(isValid: false, errors: errors);

  /// Merge multiple ValidationResults into one
  factory ValidationResult.merge(List<ValidationResult> results) {
    final allErrors = results.expand((r) => r.errors).toList();
    return allErrors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(allErrors);
  }
  const ValidationResult({
    required this.isValid,
    required this.errors,
  });

  final bool isValid;
  final List<String> errors;

  /// Whether this result is invalid
  bool get isInvalid => !isValid;
}
