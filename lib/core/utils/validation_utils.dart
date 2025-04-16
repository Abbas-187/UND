/// Utility class for common validation operations
class ValidationUtils {
  /// Checks if a string is a valid email address
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;

    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }

  /// Checks if a string is a valid phone number
  static bool isValidPhone(String? phone) {
    if (phone == null || phone.isEmpty) return false;

    // Supports multiple phone formats including international
    final phoneRegExp = RegExp(
      r'^\+?[0-9]{10,15}$',
    );
    return phoneRegExp.hasMatch(phone.replaceAll(RegExp(r'[\s()-]'), ''));
  }

  /// Checks if a password meets minimum strength requirements
  static bool isStrongPassword(String? password) {
    if (password == null || password.isEmpty) return false;
    if (password.length < 8) return false;

    // Check if password has at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) return false;

    // Check if password has at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) return false;

    // Check if password has at least one digit
    if (!password.contains(RegExp(r'[0-9]'))) return false;

    // Check if password has at least one special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;

    return true;
  }

  /// Checks if a string is a valid URL
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    final urlRegExp = RegExp(
      r'^(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?$',
    );
    return urlRegExp.hasMatch(url);
  }

  /// Checks if a date string is in a valid format
  static bool isValidDateFormat(String? date, {String format = 'yyyy-MM-dd'}) {
    if (date == null || date.isEmpty) return false;

    try {
      switch (format) {
        case 'yyyy-MM-dd':
          final RegExp dateRegExp = RegExp(
            r'^\d{4}-\d{2}-\d{2}$',
          );
          if (!dateRegExp.hasMatch(date)) return false;

          // Parse and validate the date components
          final parts = date.split('-');
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);

          if (month < 1 || month > 12) return false;
          if (day < 1 || day > 31) return false;

          return true;

        case 'MM/dd/yyyy':
          final RegExp dateRegExp = RegExp(
            r'^\d{2}/\d{2}/\d{4}$',
          );
          if (!dateRegExp.hasMatch(date)) return false;

          // Parse and validate the date components
          final parts = date.split('/');
          final month = int.parse(parts[0]);
          final day = int.parse(parts[1]);
          final year = int.parse(parts[2]);

          if (month < 1 || month > 12) return false;
          if (day < 1 || day > 31) return false;

          return true;

        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Checks if a string is a valid credit card number
  static bool isValidCreditCard(String? cardNumber) {
    if (cardNumber == null || cardNumber.isEmpty) return false;

    // Remove any spaces or dashes
    final cleanCardNumber = cardNumber.replaceAll(RegExp(r'[\s-]'), '');

    // Check if the card number contains only digits
    if (!RegExp(r'^\d+$').hasMatch(cleanCardNumber)) return false;

    // Check if the card number length is valid
    if (cleanCardNumber.length < 13 || cleanCardNumber.length > 19)
      return false;

    // Implement Luhn algorithm (checksum) for credit card validation
    int sum = 0;
    bool alternate = false;

    for (int i = cleanCardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanCardNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  /// Validates a numeric value is within a range
  static bool isInRange(num value, num min, num max) {
    return value >= min && value <= max;
  }
}
