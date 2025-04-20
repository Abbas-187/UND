import 'package:intl/intl.dart';

/// Utility class for formatting currency values.
class CurrencyFormatter {
  /// Format a double value as currency.
  static String format(double value,
      {String symbol = '\$', int decimalPlaces = 2}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalPlaces,
    );
    return formatter.format(value);
  }

  /// Format a double value as currency with the locale's default currency symbol.
  static String formatWithLocale(double value, String locale,
      {int decimalPlaces = 2}) {
    final formatter = NumberFormat.currency(
      locale: locale,
      decimalDigits: decimalPlaces,
    );
    return formatter.format(value);
  }
}
