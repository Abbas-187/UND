import 'package:intl/intl.dart';

/// Utility class for date and time operations
class DateTimeUtils {
  /// Format a DateTime object to a readable date string
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(date);
  }

  /// Format a DateTime object to a readable time string
  static String formatTime(DateTime time, {String format = 'HH:mm'}) {
    return DateFormat(format).format(time);
  }

  /// Format a DateTime object to a readable date and time string
  static String formatDateTime(DateTime dateTime,
      {String format = 'yyyy-MM-dd HH:mm'}) {
    return DateFormat(format).format(dateTime);
  }

  /// Get relative time string (e.g., "2 hours ago")
  static String getRelativeTimeString(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  /// Parse a string to a DateTime object
  static DateTime? parseDateTime(String dateTimeString,
      {String format = 'yyyy-MM-dd HH:mm'}) {
    try {
      return DateFormat(format).parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  /// Get the start of the day for a given date
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get the end of the day for a given date
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get the start of the month for a given date
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get the end of the month for a given date
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get a list of dates between start and end date
  static List<DateTime> getDateRange(DateTime startDate, DateTime endDate) {
    final List<DateTime> dates = [];
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) || isSameDay(currentDate, endDate)) {
      dates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dates;
  }

  /// Get the start of the week (Monday) for a given date
  static DateTime startOfWeek(DateTime date) {
    // ISO 8601: Monday = 1, Sunday = 7
    final int dayOfWeek = date.weekday;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: dayOfWeek - 1));
  }
}
