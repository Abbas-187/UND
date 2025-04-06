import 'dart:math' as math;
import '../entities/time_series_point.dart';

/// Implementation of Exponential Smoothing algorithm for time series forecasting
class ExponentialSmoothing {
  /// Calculates forecast using single exponential smoothing
  ///
  /// [timeSeries] - Historical time series data
  /// [alpha] - Smoothing parameter between 0 and 1
  /// [periods] - Number of future periods to forecast
  ///
  /// Returns list of forecasted values
  List<TimeSeriesPoint> forecast({
    required List<TimeSeriesPoint> timeSeries,
    required double alpha,
    required int periods,
  }) {
    if (timeSeries.isEmpty) {
      throw ArgumentError('Time series cannot be empty');
    }

    if (alpha < 0 || alpha > 1) {
      throw ArgumentError('Alpha must be between 0 and 1');
    }

    if (periods <= 0) {
      throw ArgumentError('Forecast periods must be positive');
    }

    // Sort time series by date
    final sortedData = List<TimeSeriesPoint>.from(timeSeries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate last date in time series
    final lastDate = sortedData.last.timestamp;

    // Calculate initial level (first observation)
    double level = sortedData.first.value;

    // Apply exponential smoothing formula
    for (int i = 1; i < sortedData.length; i++) {
      level = alpha * sortedData[i].value + (1 - alpha) * level;
    }

    // Final smoothed value becomes our forecast
    final forecast = <TimeSeriesPoint>[];

    // All forecasted values are the same in single exponential smoothing
    for (int i = 0; i < periods; i++) {
      final nextDate = _calculateNextDate(lastDate, i + 1, sortedData);
      forecast.add(TimeSeriesPoint(timestamp: nextDate, value: level));
    }

    return forecast;
  }

  /// Calculates forecast using double exponential smoothing (Holt's method)
  ///
  /// [timeSeries] - Historical time series data
  /// [alpha] - Level smoothing parameter between 0 and 1
  /// [beta] - Trend smoothing parameter between 0 and 1
  /// [periods] - Number of future periods to forecast
  ///
  /// Returns list of forecasted values
  List<TimeSeriesPoint> forecastDouble({
    required List<TimeSeriesPoint> timeSeries,
    required double alpha,
    required double beta,
    required int periods,
  }) {
    if (timeSeries.isEmpty) {
      throw ArgumentError('Time series cannot be empty');
    }

    if (alpha < 0 || alpha > 1) {
      throw ArgumentError('Alpha must be between 0 and 1');
    }

    if (beta < 0 || beta > 1) {
      throw ArgumentError('Beta must be between 0 and 1');
    }

    if (periods <= 0) {
      throw ArgumentError('Forecast periods must be positive');
    }

    if (timeSeries.length < 2) {
      throw ArgumentError(
          'Need at least two data points for double exponential smoothing');
    }

    // Sort time series by date
    final sortedData = List<TimeSeriesPoint>.from(timeSeries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate last date in time series
    final lastDate = sortedData.last.timestamp;

    // Initialize level and trend
    double level = sortedData.first.value;

    // Initialize trend as the difference between the first two points
    double trend = sortedData[1].value - sortedData[0].value;

    // If we have more historical data, we can calculate a better initial trend
    if (sortedData.length >= 4) {
      // Use average of first few differences
      double sum = 0;
      for (int i = 1; i < math.min(4, sortedData.length); i++) {
        sum += sortedData[i].value - sortedData[i - 1].value;
      }
      trend = sum / math.min(3, sortedData.length - 1).toDouble();
    }

    // Apply Holt's method (double exponential smoothing)
    for (int i = 1; i < sortedData.length; i++) {
      final prevLevel = level;

      // Update level
      level = alpha * sortedData[i].value + (1 - alpha) * (level + trend);

      // Update trend
      trend = beta * (level - prevLevel) + (1 - beta) * trend;
    }

    // Generate forecast
    final forecast = <TimeSeriesPoint>[];

    for (int i = 0; i < periods; i++) {
      final nextDate = _calculateNextDate(lastDate, i + 1, sortedData);
      final forecastValue = level + (i + 1) * trend;

      // Ensure non-negative values if appropriate for the domain
      final finalValue = forecastValue < 0 ? 0.0 : forecastValue.toDouble();

      forecast.add(TimeSeriesPoint(timestamp: nextDate, value: finalValue));
    }

    return forecast;
  }

  /// Calculates forecast using triple exponential smoothing (Holt-Winters method)
  ///
  /// [timeSeries] - Historical time series data
  /// [alpha] - Level smoothing parameter between 0 and 1
  /// [beta] - Trend smoothing parameter between 0 and 1
  /// [gamma] - Seasonal smoothing parameter between 0 and 1
  /// [seasonalPeriod] - Length of the seasonal cycle
  /// [periods] - Number of future periods to forecast
  /// [multiplicative] - Whether to use multiplicative (true) or additive (false) model
  ///
  /// Returns list of forecasted values
  List<TimeSeriesPoint> forecastTriple({
    required List<TimeSeriesPoint> timeSeries,
    required double alpha,
    required double beta,
    required double gamma,
    required int seasonalPeriod,
    required int periods,
    bool multiplicative = true,
  }) {
    if (timeSeries.isEmpty) {
      throw ArgumentError('Time series cannot be empty');
    }

    if (alpha < 0 ||
        alpha > 1 ||
        beta < 0 ||
        beta > 1 ||
        gamma < 0 ||
        gamma > 1) {
      throw ArgumentError('Smoothing parameters must be between 0 and 1');
    }

    if (periods <= 0) {
      throw ArgumentError('Forecast periods must be positive');
    }

    if (seasonalPeriod <= 0) {
      throw ArgumentError('Seasonal period must be positive');
    }

    if (timeSeries.length < seasonalPeriod * 2) {
      throw ArgumentError('Need at least two complete seasonal cycles');
    }

    // Sort time series by date
    final sortedData = List<TimeSeriesPoint>.from(timeSeries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate last date in time series
    final lastDate = sortedData.last.timestamp;

    // Extract values
    final values = sortedData.map((point) => point.value).toList();

    // Initialize level, trend, and seasonal components
    List<double> seasonalIndices =
        _initializeSeasonalIndices(values, seasonalPeriod, multiplicative);

    // Initialize level as the average of the first season
    double level = 0;
    for (int i = 0; i < seasonalPeriod; i++) {
      level += values[i];
    }
    level /= seasonalPeriod.toDouble();

    // Initialize trend
    double trend = 0;
    for (int i = 0; i < seasonalPeriod; i++) {
      trend +=
          (values[seasonalPeriod + i] - values[i]) / seasonalPeriod.toDouble();
    }
    trend /= seasonalPeriod.toDouble();

    // Apply Holt-Winters method
    for (int i = seasonalPeriod; i < values.length; i++) {
      final seasonalIndex = i % seasonalPeriod;
      final yt = values[i];
      final prevLevel = level;

      if (multiplicative) {
        // Multiplicative model
        level = alpha * (yt / seasonalIndices[seasonalIndex]) +
            (1 - alpha) * (prevLevel + trend);
        trend = beta * (level - prevLevel) + (1 - beta) * trend;
        seasonalIndices[seasonalIndex] =
            gamma * (yt / level) + (1 - gamma) * seasonalIndices[seasonalIndex];
      } else {
        // Additive model
        level = alpha * (yt - seasonalIndices[seasonalIndex]) +
            (1 - alpha) * (prevLevel + trend);
        trend = beta * (level - prevLevel) + (1 - beta) * trend;
        seasonalIndices[seasonalIndex] =
            gamma * (yt - level) + (1 - gamma) * seasonalIndices[seasonalIndex];
      }
    }

    // Generate forecast
    final forecast = <TimeSeriesPoint>[];

    for (int i = 0; i < periods; i++) {
      final nextDate = _calculateNextDate(lastDate, i + 1, sortedData);
      final seasonalIndex = (values.length + i) % seasonalPeriod;

      double forecastValue;
      if (multiplicative) {
        forecastValue =
            (level + (i + 1) * trend) * seasonalIndices[seasonalIndex];
      } else {
        forecastValue =
            level + (i + 1) * trend + seasonalIndices[seasonalIndex];
      }

      // Ensure non-negative values if appropriate for the domain
      final finalValue = forecastValue < 0 ? 0.0 : forecastValue.toDouble();

      forecast.add(TimeSeriesPoint(timestamp: nextDate, value: finalValue));
    }

    return forecast;
  }

  /// Initialize seasonal indices based on the first few seasonal cycles
  List<double> _initializeSeasonalIndices(
      List<double> values, int seasonalPeriod, bool multiplicative) {
    final indices = List<double>.filled(seasonalPeriod, 0);
    final seasonCount = values.length ~/ seasonalPeriod;

    for (int i = 0; i < seasonalPeriod; i++) {
      double sum = 0;
      for (int j = 0; j < seasonCount; j++) {
        final idx = i + j * seasonalPeriod;
        if (idx < values.length) {
          sum += values[idx];
        }
      }

      indices[i] = sum / seasonCount.toDouble();
    }

    if (multiplicative) {
      // For multiplicative model, normalize to average 1
      double sumIndices = indices.reduce((a, b) => a + b);
      double avgIndex = sumIndices / seasonalPeriod.toDouble();

      for (int i = 0; i < seasonalPeriod; i++) {
        indices[i] = indices[i] / avgIndex;
      }
    } else {
      // For additive model, normalize to average 0
      double sumIndices = indices.reduce((a, b) => a + b);
      double avgIndex = sumIndices / seasonalPeriod.toDouble();

      for (int i = 0; i < seasonalPeriod; i++) {
        indices[i] = indices[i] - avgIndex;
      }
    }

    return indices;
  }

  /// Calculates the next date based on average time difference
  DateTime _calculateNextDate(
      DateTime lastDate, int periodsAhead, List<TimeSeriesPoint> timeSeries) {
    if (timeSeries.length < 2) {
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

    final avgDifference = totalDifference / (timeSeries.length - 1).toDouble();
    final daysToAdd = (avgDifference * periodsAhead).round();

    return lastDate.add(Duration(days: daysToAdd));
  }
}
