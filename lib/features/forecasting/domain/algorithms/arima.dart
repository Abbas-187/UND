import 'dart:math' as math;
import '../entities/time_series_point.dart';

/// Implementation of ARIMA (Autoregressive Integrated Moving Average) algorithm for time series forecasting
class ArimaForecaster {
  /// Non-seasonal autoregressive order
  final int p;

  /// Non-seasonal differencing order
  final int d;

  /// Non-seasonal moving average order
  final int q;

  /// Seasonal autoregressive order
  final int P;

  /// Seasonal differencing order
  final int D;

  /// Seasonal moving average order
  final int Q;

  /// Length of the seasonal period
  final int seasonalPeriod;

  /// Creates an ARIMA model with the specified parameters
  ArimaForecaster({
    required this.p,
    required this.d,
    required this.q,
    this.P = 0,
    this.D = 0,
    this.Q = 0,
    this.seasonalPeriod = 0,
  }) {
    if (p < 0 || d < 0 || q < 0) {
      throw ArgumentError('Non-seasonal parameters must be non-negative');
    }
    if (P < 0 || D < 0 || Q < 0) {
      throw ArgumentError('Seasonal parameters must be non-negative');
    }
    if (seasonalPeriod < 0) {
      throw ArgumentError('Seasonal period must be non-negative');
    }
  }

  /// Calculates forecast using ARIMA model
  ///
  /// [timeSeries] - Historical time series data
  /// [periods] - Number of future periods to forecast
  ///
  /// Returns list of forecasted time series points
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

    // Extract values
    final values = sortedData.map((point) => point.value).toList();

    // Apply differencing if needed
    var diffValues = List<double>.from(values);
    for (int i = 0; i < d; i++) {
      diffValues = _difference(diffValues);
    }

    // Apply seasonal differencing if needed
    for (int i = 0; i < D; i++) {
      diffValues = _seasonalDifference(diffValues, seasonalPeriod);
    }

    // Fit ARIMA model
    final model = _fitArimaModel(diffValues);

    // Generate forecasts
    final forecasts = <TimeSeriesPoint>[];
    final lastDate = sortedData.last.timestamp;

    // Generate forecast values
    var forecastValues = _generateForecastValues(model, periods);

    // Reverse differencing transformations
    for (int i = 0; i < D; i++) {
      forecastValues =
          _reverseSeasonalDifference(forecastValues, values, seasonalPeriod);
    }
    for (int i = 0; i < d; i++) {
      forecastValues = _reverseDifference(forecastValues, values);
    }

    // Create forecast points
    for (int i = 0; i < periods; i++) {
      final nextDate = _calculateNextDate(lastDate, i + 1, sortedData);
      forecasts
          .add(TimeSeriesPoint(timestamp: nextDate, value: forecastValues[i]));
    }

    return forecasts;
  }

  /// Applies differencing to the time series
  List<double> _difference(List<double> values) {
    final diff = <double>[];
    for (int i = 1; i < values.length; i++) {
      diff.add(values[i] - values[i - 1]);
    }
    return diff;
  }

  /// Applies seasonal differencing to the time series
  List<double> _seasonalDifference(List<double> values, int period) {
    if (period <= 0) return values;
    final diff = <double>[];
    for (int i = period; i < values.length; i++) {
      diff.add(values[i] - values[i - period]);
    }
    return diff;
  }

  /// Reverses differencing transformation
  List<double> _reverseDifference(
      List<double> diffValues, List<double> originalValues) {
    final values = <double>[];
    values.add(originalValues.last);
    for (int i = 0; i < diffValues.length; i++) {
      values.add(values.last + diffValues[i]);
    }
    return values;
  }

  /// Reverses seasonal differencing transformation
  List<double> _reverseSeasonalDifference(
    List<double> diffValues,
    List<double> originalValues,
    int period,
  ) {
    if (period <= 0) return diffValues;
    final values = <double>[];
    for (int i = 0; i < period; i++) {
      values.add(originalValues[originalValues.length - period + i]);
    }
    for (int i = 0; i < diffValues.length; i++) {
      values.add(values[values.length - period] + diffValues[i]);
    }
    return values;
  }

  /// Fits ARIMA model to the differenced time series
  Map<String, dynamic> _fitArimaModel(List<double> values) {
    // This is a simplified implementation that uses least squares estimation
    // In practice, you would want to use more sophisticated methods like maximum likelihood
    final model = <String, dynamic>{};

    // Calculate coefficients for AR terms
    if (p > 0) {
      final arCoeffs = <double>[];
      for (int i = 0; i < p; i++) {
        arCoeffs.add(_calculateAutocorrelation(values, i + 1));
      }
      model['ar'] = arCoeffs;
    }

    // Calculate coefficients for MA terms
    if (q > 0) {
      final maCoeffs = <double>[];
      for (int i = 0; i < q; i++) {
        maCoeffs.add(_calculateAutocorrelation(values, i + 1));
      }
      model['ma'] = maCoeffs;
    }

    // Calculate seasonal coefficients if needed
    if (P > 0 && seasonalPeriod > 0) {
      final seasonalArCoeffs = <double>[];
      for (int i = 0; i < P; i++) {
        seasonalArCoeffs
            .add(_calculateAutocorrelation(values, (i + 1) * seasonalPeriod));
      }
      model['seasonalAr'] = seasonalArCoeffs;
    }

    if (Q > 0 && seasonalPeriod > 0) {
      final seasonalMaCoeffs = <double>[];
      for (int i = 0; i < Q; i++) {
        seasonalMaCoeffs
            .add(_calculateAutocorrelation(values, (i + 1) * seasonalPeriod));
      }
      model['seasonalMa'] = seasonalMaCoeffs;
    }

    return model;
  }

  /// Calculates autocorrelation at a given lag
  double _calculateAutocorrelation(List<double> values, int lag) {
    if (lag >= values.length) return 0.0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    double numerator = 0;
    double denominator = 0;

    for (int i = 0; i < values.length - lag; i++) {
      numerator += (values[i] - mean) * (values[i + lag] - mean);
      denominator += math.pow(values[i] - mean, 2);
    }

    return numerator / denominator;
  }

  /// Generates forecast values using the fitted model
  List<double> _generateForecastValues(
      Map<String, dynamic> model, int periods) {
    final forecasts = <double>[];
    final lastValues = List<double>.from(model['lastValues'] ?? []);

    for (int i = 0; i < periods; i++) {
      double forecast = 0;

      // Add AR terms
      if (model.containsKey('ar')) {
        final arCoeffs = model['ar'] as List<double>;
        for (int j = 0; j < arCoeffs.length; j++) {
          if (i - j >= 0) {
            forecast += arCoeffs[j] * forecasts[i - j];
          } else {
            forecast += arCoeffs[j] * lastValues[lastValues.length + i - j];
          }
        }
      }

      // Add MA terms
      if (model.containsKey('ma')) {
        final maCoeffs = model['ma'] as List<double>;
        for (int j = 0; j < maCoeffs.length; j++) {
          if (i - j >= 0) {
            forecast += maCoeffs[j] *
                (forecasts[i - j] - lastValues[lastValues.length + i - j]);
          }
        }
      }

      // Add seasonal AR terms
      if (model.containsKey('seasonalAr') && seasonalPeriod > 0) {
        final seasonalArCoeffs = model['seasonalAr'] as List<double>;
        for (int j = 0; j < seasonalArCoeffs.length; j++) {
          final lag = (j + 1) * seasonalPeriod;
          if (i - lag >= 0) {
            forecast += seasonalArCoeffs[j] * forecasts[i - lag];
          } else {
            forecast +=
                seasonalArCoeffs[j] * lastValues[lastValues.length + i - lag];
          }
        }
      }

      // Add seasonal MA terms
      if (model.containsKey('seasonalMa') && seasonalPeriod > 0) {
        final seasonalMaCoeffs = model['seasonalMa'] as List<double>;
        for (int j = 0; j < seasonalMaCoeffs.length; j++) {
          final lag = (j + 1) * seasonalPeriod;
          if (i - lag >= 0) {
            forecast += seasonalMaCoeffs[j] *
                (forecasts[i - lag] - lastValues[lastValues.length + i - lag]);
          }
        }
      }

      forecasts.add(forecast);
    }

    return forecasts;
  }

  /// Calculates the next date based on the average difference between dates
  DateTime _calculateNextDate(
      DateTime lastDate, int periods, List<TimeSeriesPoint> sortedData) {
    if (sortedData.length < 2) {
      return lastDate.add(Duration(days: periods));
    }

    // Calculate average difference between consecutive dates
    int totalDays = 0;
    int count = 0;
    for (int i = 1; i < sortedData.length; i++) {
      totalDays += sortedData[i]
          .timestamp
          .difference(sortedData[i - 1].timestamp)
          .inDays;
      count++;
    }

    final averageDays = (totalDays / count).round();
    return lastDate.add(Duration(days: averageDays * periods));
  }
}
