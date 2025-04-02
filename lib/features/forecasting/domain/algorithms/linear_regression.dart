import 'dart:math' as math;
import 'package:und_app/features/forecasting/domain/entities/time_series_point.dart';

/// Implementation of Linear Regression for time series forecasting
class LinearRegression {
  double? _slope;
  double? _intercept;
  DateTime? _startDate;

  /// Calculates forecast using simple linear regression
  ///
  /// [timeSeries] - Historical time series data
  /// [periods] - Number of future periods to forecast
  ///
  /// Returns list of forecasted values
  List<TimeSeriesPoint> forecast({
    required List<TimeSeriesPoint> timeSeries,
    required int periods,
  }) {
    if (timeSeries.isEmpty) {
      throw ArgumentError('Time series cannot be empty');
    }

    if (periods <= 0) {
      throw ArgumentError('Forecast periods must be positive');
    }

    // Sort time series by date
    final sortedData = List<TimeSeriesPoint>.from(timeSeries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Convert dates to numeric X values (days since first observation)
    _startDate = sortedData.first.timestamp;
    final xValues = sortedData
        .map((point) =>
            point.timestamp.difference(_startDate!).inDays.toDouble())
        .toList();

    final yValues = sortedData.map((point) => point.value).toList();

    // Calculate regression coefficients
    _calculateCoefficients(xValues, yValues);

    // Generate forecasts
    final forecasts = <TimeSeriesPoint>[];
    final lastDate = sortedData.last.timestamp;

    for (int i = 0; i < periods; i++) {
      final nextDate = _calculateNextDate(lastDate, i + 1, sortedData);
      final xValue = nextDate.difference(_startDate!).inDays.toDouble();
      final forecastValue = _intercept! + _slope! * xValue;

      forecasts.add(TimeSeriesPoint(
        timestamp: nextDate,
        value:
            forecastValue < 0 ? 0 : forecastValue, // Ensure non-negative values
      ));
    }

    return forecasts;
  }

  /// Calculate regression coefficients (slope and intercept)
  void _calculateCoefficients(List<double> xValues, List<double> yValues) {
    final n = xValues.length;

    // Calculate means
    final meanX = xValues.reduce((a, b) => a + b) / n;
    final meanY = yValues.reduce((a, b) => a + b) / n;

    // Calculate slope (b1)
    double numerator = 0;
    double denominator = 0;

    for (int i = 0; i < n; i++) {
      numerator += (xValues[i] - meanX) * (yValues[i] - meanY);
      denominator += math.pow(xValues[i] - meanX, 2);
    }

    _slope = denominator != 0 ? numerator / denominator : 0;

    // Calculate intercept (b0)
    _intercept = meanY - _slope! * meanX;
  }

  /// Gets the calculated slope coefficient
  double getSlope() {
    if (_slope == null) {
      throw StateError(
          'Regression coefficients not calculated. Call forecast() first.');
    }
    return _slope!;
  }

  /// Gets the calculated intercept coefficient
  double getIntercept() {
    if (_intercept == null) {
      throw StateError(
          'Regression coefficients not calculated. Call forecast() first.');
    }
    return _intercept!;
  }

  /// Calculates the next date based on average time difference
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

  /// Calculates coefficient of determination (R²)
  /// Returns a value between 0 and 1, where higher values indicate better fit
  double calculateRSquared(List<TimeSeriesPoint> timeSeries) {
    if (_slope == null || _intercept == null || _startDate == null) {
      throw StateError(
          'Regression coefficients not calculated. Call forecast() first.');
    }

    final n = timeSeries.length;
    if (n < 2) return 0;

    // Sort time series by date
    final sortedData = List<TimeSeriesPoint>.from(timeSeries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Convert to X and Y values
    final xValues = sortedData
        .map((point) =>
            point.timestamp.difference(_startDate!).inDays.toDouble())
        .toList();
    final yValues = sortedData.map((point) => point.value).toList();

    // Calculate mean of Y values
    final meanY = yValues.reduce((a, b) => a + b) / n;

    // Calculate total sum of squares
    double totalSumSquares = 0;
    for (int i = 0; i < n; i++) {
      totalSumSquares += math.pow(yValues[i] - meanY, 2);
    }

    // Calculate residual sum of squares
    double residualSumSquares = 0;
    for (int i = 0; i < n; i++) {
      final predictedY = _intercept! + _slope! * xValues[i];
      residualSumSquares += math.pow(yValues[i] - predictedY, 2);
    }

    // Calculate R-squared
    if (totalSumSquares == 0) return 0; // Avoid division by zero
    return 1 - (residualSumSquares / totalSumSquares);
  }
}
