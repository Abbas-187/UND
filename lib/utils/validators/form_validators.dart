/// Utility class with common form validation methods.
class FormValidators {
  /// Validates that the field is not empty.
  static String? Function(String?) required(String errorMessage) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return errorMessage;
      }
      return null;
    };
  }

  /// Validates that the field is a valid email.
  static String? Function(String?) email(String errorMessage) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Email is required';
      }
      if (!emailRegex.hasMatch(value)) {
        return errorMessage;
      }
      return null;
    };
  }

  /// Validates that the field is a valid number.
  static String? Function(String?) number(String errorMessage) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Value is required';
      }
      if (double.tryParse(value) == null) {
        return errorMessage;
      }
      return null;
    };
  }

  /// Validates that the field is a valid positive number.
  static String? Function(String?) positiveNumber(String errorMessage) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Value is required';
      }
      final number = double.tryParse(value);
      if (number == null) {
        return 'Not a valid number';
      }
      if (number <= 0) {
        return errorMessage;
      }
      return null;
    };
  }

  /// Validates that the field has minimum length.
  static String? Function(String?) minLength(
      int minLength, String errorMessage) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Value is required';
      }
      if (value.length < minLength) {
        return errorMessage;
      }
      return null;
    };
  }

  /// Validates that the field has maximum length.
  static String? Function(String?) maxLength(
      int maxLength, String errorMessage) {
    return (String? value) {
      if (value == null) {
        return null;
      }
      if (value.length > maxLength) {
        return errorMessage;
      }
      return null;
    };
  }

  /// Combines multiple validators.
  static String? Function(String?) combine(
      List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }
}
