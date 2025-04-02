import 'package:und_app/features/forecasting/domain/entities/time_series_point.dart';

/// Implementation of Moving Average algorithm for time series forecasting
class MovingAverage {
  /// Calculates forecast using simple moving average
  ///
  /// [timeSeries] - Historical time series data
  /// [windowSize] - Number of periods to include in moving average
  /// [periods] - Number of future periods to forecast
  ///
  /// Returns list of forecasted time series points
  List<TimeSeriesPoint> forecast({
    required List<TimeSeriesPoint> timeSeries,
    required int windowSize,
    required int periods,
  }) {
    if (timeSeries.isEmpty) {
      throw ArgumentError('Time series cannot be empty');
    }

    if (windowSize <= 0) {
      throw ArgumentError('Window size must be positive');
    }

    if (periods <= 0) {
      throw ArgumentError('Forecast periods must be positive');
    }

    if (windowSize > timeSeries.length) {
      throw ArgumentError(
          'Window size cannot be larger than time series length');
    }

    // Sort time series by date
    final sortedData = List<TimeSeriesPoint>.from(timeSeries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate last date in time series
    final lastDate = sortedData.last.timestamp;

    // Calculate forecast
    final forecastPoints = <TimeSeriesPoint>[];

    // Calculate initial forecast (based on last windowSize points)
    double nextValue = _calculateMovingAverage(
      sortedData.map((point) => point.value).toList(),
      sortedData.length - windowSize,
      windowSize,
    );

    // Generate forecast for specified number of periods
    for (int i = 0; i < periods; i++) {
      // Calculate next date based on average difference between dates
      final nextDate = _calculateNextDate(lastDate, i + 1, sortedData);
      forecastPoints
          .add(TimeSeriesPoint(timestamp: nextDate, value: nextValue));
    }

    return forecastPoints;
  }

  /// Calculate moving average starting at a specific index
  double _calculateMovingAverage(
      List<double> values, int startIndex, int windowSize) {
    if (startIndex < 0 ||
        startIndex + windowSize > values.length ||
        windowSize <= 0) {
      throw ArgumentError('Invalid parameters for moving average calculation');
    }

    double sum = 0;
    for (int i = startIndex; i < startIndex + windowSize; i++) {
      sum += values[i];
    }

    return sum / windowSize;
  }

  /// Calculate the next date based on average time difference
  DateTime _calculateNextDate(
      DateTime lastDate, int periodsAhead, List<TimeSeriesPoint> timeSeries) {
    if (timeSeries.length < 2) {
      // Default to daily if can't determine pattern
      return lastDate.add(Duration(days: periodsAhead));
    }

    // Calculate average time difference between points
    int totalDifference = 0;
    for (int i = 1; i < timeSeries.length; i++) {
      totalDifference += timeSeries[i]
          .timestamp
          .difference(timeSeries[i - 1].timestamp)
          .inDays;
    }

    final avgDifference = totalDifference / (timeSeries.length - 1);
    final daysToAdd = (avgDifference * periodsAhead).round();

    return lastDate.add(Duration(days: daysToAdd));
  }

  /// Calculate centered moving average (for decomposition)
  List<double?> calculateCenteredMovingAverage(
      List<double> values, int period) {
    final n = values.length;
    final result = List<double?>.filled(n, null);

    // For odd periods
    if (period % 2 == 1) {
      final halfPeriod = period ~/ 2;

      for (int i = halfPeriod; i < n - halfPeriod; i++) {
        double sum = 0;
        for (int j = i - halfPeriod; j <= i + halfPeriod; j++) {
          sum += values[j];
        }
        result[i] = sum / period;
      }
    }
    // For even periods (need to center between two values)
    else {
      final halfPeriod = period ~/ 2;

      for (int i = halfPeriod; i < n - halfPeriod; i++) {
        double sum1 = 0;
        double sum2 = 0;

        for (int j = i - halfPeriod; j < i + halfPeriod; j++) {
          sum1 += values[j];
        }

        for (int j = i - halfPeriod + 1; j < i + halfPeriod + 1; j++) {
          sum2 += values[j];
        }

        result[i] = (sum1 + sum2) / (2 * period);
      }
    }

    return result;
  }

  /// Calculate weighted moving average where recent values have higher weights
  double calculateWeightedMovingAverage(
      List<double> values, int startIndex, int windowSize) {
    if (startIndex < 0 ||
        startIndex + windowSize > values.length ||
        windowSize <= 0) {
      throw ArgumentError('Invalid parameters for moving average calculation');
    }

    double weightedSum = 0;
    int totalWeight = 0;

    for (int i = 0; i < windowSize; i++) {
      final weight = i + 1; // Linear weight
      weightedSum += values[startIndex + i] * weight;
      totalWeight += weight;
    }

    return weightedSum / totalWeight;
  }
}
