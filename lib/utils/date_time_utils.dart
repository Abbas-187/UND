/// Utility functions for date and time operations
class DateTimeUtils {
  /// Returns the start of the day for a given DateTime
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 0, 0);
  }

  /// Returns the end of the day for a given DateTime
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Returns the start of the week for a given DateTime
  /// Week starts on Monday (weekday = 1)
  static DateTime startOfWeek(DateTime date) {
    final daysToSubtract = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysToSubtract)));
  }

  /// Returns the end of the week for a given DateTime
  /// Week ends on Sunday (weekday = 7)
  static DateTime endOfWeek(DateTime date) {
    final daysToAdd = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: daysToAdd)));
  }

  /// Returns the start of the month for a given DateTime
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1, 0, 0, 0);
  }

  /// Returns the end of the month for a given DateTime
  static DateTime endOfMonth(DateTime date) {
    final nextMonth = date.month < 12
        ? DateTime(date.year, date.month + 1, 1)
        : DateTime(date.year + 1, 1, 1);
    return nextMonth.subtract(const Duration(seconds: 1));
  }

  /// Format a datetime as a standard date string (YYYY-MM-DD)
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Format a datetime as a standard time string (HH:MM:SS)
  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }

  /// Format a datetime as a standard datetime string (YYYY-MM-DD HH:MM:SS)
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${formatTime(date)}';
  }

  /// Get a list of dates between start and end, inclusive
  static List<DateTime> dateRange(DateTime start, DateTime end) {
    final days = end.difference(start).inDays + 1;
    return List.generate(
        days, (i) => DateTime(start.year, start.month, start.day + i));
  }

  /// Group a list of datetimes by day
  static Map<String, List<DateTime>> groupByDay(List<DateTime> dates) {
    final result = <String, List<DateTime>>{};
    for (final date in dates) {
      final key = formatDate(date);
      if (!result.containsKey(key)) {
        result[key] = [];
      }
      result[key]!.add(date);
    }
    return result;
  }

  /// Group a list of datetimes by week
  static Map<String, List<DateTime>> groupByWeek(List<DateTime> dates) {
    final result = <String, List<DateTime>>{};
    for (final date in dates) {
      final weekStart = startOfWeek(date);
      final key = formatDate(weekStart);
      if (!result.containsKey(key)) {
        result[key] = [];
      }
      result[key]!.add(date);
    }
    return result;
  }

  /// Group a list of datetimes by month
  static Map<String, List<DateTime>> groupByMonth(List<DateTime> dates) {
    final result = <String, List<DateTime>>{};
    for (final date in dates) {
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      if (!result.containsKey(key)) {
        result[key] = [];
      }
      result[key]!.add(date);
    }
    return result;
  }

  /// Returns true if two date ranges overlap
  static bool rangesOverlap(
      DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    return start1.isBefore(end2) && start2.isBefore(end1);
  }
}
