
/// Utility class for form-related functionality
class FormUtils {
  /// Validates that a value is not empty
  static String? requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  /// Validates that a value is a valid email address
  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  /// Validates that a value is a valid number
  static String? numberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }

    return null;
  }

  /// Validates that a number is greater than zero
  static String? positiveNumberValidator(String? value) {
    final baseValidation = numberValidator(value);
    if (baseValidation != null) {
      return baseValidation;
    }

    final number = double.parse(value!);
    if (number <= 0) {
      return 'Value must be greater than zero';
    }

    return null;
  }

  /// Validates that a string has a minimum length
  static String? Function(String?) minLengthValidator(int minLength) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'This field is required';
      }

      if (value.length < minLength) {
        return 'Must be at least $minLength characters';
      }

      return null;
    };
  }
}
