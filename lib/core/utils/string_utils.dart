/// Utility class for common string operations
class StringUtils {
  /// Check if a string is null or empty
  static bool isNullOrEmpty(String? str) {
    return str == null || str.isEmpty;
  }

  /// Check if a string is null, empty, or only contains whitespace
  static bool isNullOrBlank(String? str) {
    return str == null || str.trim().isEmpty;
  }

  /// Get a substring safely without throwing exceptions
  static String safeSubstring(String str, int start, [int? end]) {
    if (isNullOrEmpty(str)) return '';

    if (start < 0) start = 0;
    if (end != null && end > str.length) end = str.length;
    if (end != null && start > end) start = end;

    if (end == null) {
      if (start >= str.length) return '';
      return str.substring(start);
    } else {
      if (start >= str.length) return '';
      return str.substring(start, end);
    }
  }

  /// Capitalize the first letter of a string
  static String capitalizeFirst(String str) {
    if (isNullOrEmpty(str)) return '';
    return str[0].toUpperCase() + str.substring(1);
  }

  /// Truncate a string to a specified length and add an ellipsis if needed
  static String truncate(String str, int maxLength, {String ellipsis = '...'}) {
    if (isNullOrEmpty(str) || str.length <= maxLength) return str;
    return '${str.substring(0, maxLength)}$ellipsis';
  }

  /// Convert a string to title case
  static String toTitleCase(String str) {
    if (isNullOrEmpty(str)) return '';

    return str
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }

  /// Remove all special characters from a string
  static String removeSpecialCharacters(String str) {
    if (isNullOrEmpty(str)) return '';
    return str.replaceAll(RegExp(r'[^\w\s]+'), '');
  }

  /// Convert a string to a slug format
  static String slugify(String str) {
    if (isNullOrEmpty(str)) return '';

    return str
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s_-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}
