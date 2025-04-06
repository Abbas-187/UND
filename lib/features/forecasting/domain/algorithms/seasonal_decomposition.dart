import '../entities/time_series_point.dart';
import 'linear_regression.dart';

/// Implementation of Seasonal Decomposition algorithm for time series forecasting
///
/// The seasonal decomposition method breaks down a time series into:
/// 1. Trend component (long-term progression)
/// 2. Seasonal component (repeating patterns)
/// 3. Residual component (random fluctuations)
///
/// This implementation uses a multiplicative model (components multiply together)
class SeasonalDecomposition {
  /// Calculates forecast using seasonal decomposition
  ///
  /// [timeSeries] - Historical time series data
  /// [seasonalPeriod] - Length of the seasonal cycle (e.g., 12 for monthly data with yearly seasonality)
  /// [periods] - Number of future periods to forecast
  ///
  /// Returns list of forecasted time series points
  List<TimeSeriesPoint> forecast({
    required List<TimeSeriesPoint> timeSeries,
    required int seasonalPeriod,
    required int periods,
  }) {
    if (timeSeries.isEmpty) {
      throw ArgumentError('Time series cannot be empty');
    }

    if (seasonalPeriod <= 0) {
      throw ArgumentError('Seasonal period must be positive');
    }

    if (periods <= 0) {
      throw ArgumentError('Forecast periods must be positive');
    }

    if (timeSeries.length < seasonalPeriod * 2) {
      throw ArgumentError(
          'Time series too short for seasonal decomposition with period $seasonalPeriod');
    }

    // Sort time series by date
    final sortedData = List<TimeSeriesPoint>.from(timeSeries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Extract values
    final values = sortedData.map((point) => point.value).toList();

    // 1. Calculate centered moving averages for trend
    final trendEstimates =
        _calculateCenteredMovingAverage(values, seasonalPeriod);

    // 2. Calculate seasonal indices (original / trend)
    final seasonalIndices =
        _calculateSeasonalIndices(values, trendEstimates, seasonalPeriod);

    // 3. Calculate deseasonalized data
    final deseasonalizedData =
        _calculateDeseasonalizedData(values, seasonalIndices, seasonalPeriod);

    // 4. Fit trend model to deseasonalized data
    final trendModel = _fitTrendModel(sortedData, deseasonalizedData);

    // 5. Generate forecasts
    final forecasts = <TimeSeriesPoint>[];
    final lastDate = sortedData.last.timestamp;

    for (int i = 0; i < periods; i++) {
      final nextDate = _calculateNextDate(lastDate, i + 1, sortedData);

      // Calculate trend component for future date
      final forecastIndex = values.length + i;
      final trendValue = _calculateTrendValue(trendModel, forecastIndex);

      // Get seasonal index for this period in the cycle
      final seasonalIndex = seasonalIndices[forecastIndex % seasonalPeriod];

      // Final forecast is trend * seasonality
      final forecastValue = trendValue * seasonalIndex;

      forecasts.add(TimeSeriesPoint(
        timestamp: nextDate,
        value:
            forecastValue < 0 ? 0 : forecastValue, // Ensure non-negative values
      ));
    }

    return forecasts;
  }

  /// Decomposes time series into components: trend, seasonal, and residual
  ///
  /// [timeSeries] - Historical time series data
  /// [seasonalPeriod] - Length of the seasonal cycle
  ///
  /// Returns map with components: 'original', 'trend', 'seasonal', 'residual'
  Map<String, List<double>> decompose({
    required List<TimeSeriesPoint> timeSeries,
    required int seasonalPeriod,
  }) {
    if (timeSeries.isEmpty) {
      throw ArgumentError('Time series cannot be empty');
    }

    if (seasonalPeriod <= 0) {
      throw ArgumentError('Seasonal period must be positive');
    }

    if (timeSeries.length < seasonalPeriod * 2) {
      throw ArgumentError(
          'Time series too short for seasonal decomposition with period $seasonalPeriod');
    }

    // Sort time series by date
    final sortedData = List<TimeSeriesPoint>.from(timeSeries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Extract values
    final values = sortedData.map((point) => point.value).toList();

    // 1. Calculate centered moving averages for trend
    final trendEstimates =
        _calculateCenteredMovingAverage(values, seasonalPeriod);

    // Fill missing trend values at the ends
    final filledTrend = _fillTrendMissingValues(trendEstimates, values.length);

    // 2. Calculate seasonal indices
    final seasonalIndices =
        _calculateSeasonalIndices(values, trendEstimates, seasonalPeriod);

    // 3. Generate seasonal component for each observation
    final seasonal = <double>[];
    for (int i = 0; i < values.length; i++) {
      seasonal.add(seasonalIndices[i % seasonalPeriod]);
    }

    // 4. Calculate residuals
    final residuals = <double>[];
    for (int i = 0; i < values.length; i++) {
      final residual = filledTrend[i] > 0
          ? values[i] / (filledTrend[i] * seasonal[i])
          : 1.0; // Default to 1 if trend is zero/missing
      residuals.add(residual);
    }

    return {
      'original': values,
      'trend': filledTrend,
      'seasonal': seasonal,
      'residual': residuals,
    };
  }

  /// Calculates centered moving average for the trend component
  List<double?> _calculateCenteredMovingAverage(
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

  /// Fill missing trend values at the beginning and end
  List<double> _fillTrendMissingValues(List<double?> trend, int length) {
    final result = List<double>.filled(length, 0);

    // Find first and last non-null indices
    int firstNonNull = -1;
    int lastNonNull = -1;

    for (int i = 0; i < trend.length; i++) {
      if (trend[i] != null) {
        firstNonNull = i;
        break;
      }
    }

    for (int i = trend.length - 1; i >= 0; i--) {
      if (trend[i] != null) {
        lastNonNull = i;
        break;
      }
    }

    if (firstNonNull == -1 || lastNonNull == -1) {
      // No valid trend values
      return List<double>.filled(length, 1.0);
    }

    // Copy non-null values
    for (int i = firstNonNull; i <= lastNonNull; i++) {
      result[i] = trend[i]!;
    }

    // Forward fill beginning
    for (int i = 0; i < firstNonNull; i++) {
      result[i] = result[firstNonNull];
    }

    // Forward fill end
    for (int i = lastNonNull + 1; i < length; i++) {
      result[i] = result[lastNonNull];
    }

    return result;
  }

  /// Calculate seasonal indices for the multiplicative model
  List<double> _calculateSeasonalIndices(
      List<double> values, List<double?> trendEstimates, int period) {
    final n = values.length;

    // Group ratios by season position
    final seasonalIndices = List<List<double>>.generate(period, (_) => []);

    // Calculate seasonal factors (original / trend)
    for (int i = 0; i < n; i++) {
      if (trendEstimates[i] != null && trendEstimates[i]! > 0) {
        final seasonalIndex = i % period;
        final factor = values[i] / trendEstimates[i]!;
        seasonalIndices[seasonalIndex].add(factor);
      }
    }

    // Calculate median for each seasonal position (more robust than mean)
    final medianSeasonalIndices = List<double>.filled(period, 0);
    for (int i = 0; i < period; i++) {
      if (seasonalIndices[i].isNotEmpty) {
        seasonalIndices[i].sort();
        final middle = seasonalIndices[i].length ~/ 2;
        if (seasonalIndices[i].length % 2 == 0) {
          medianSeasonalIndices[i] =
              (seasonalIndices[i][middle - 1] + seasonalIndices[i][middle]) / 2;
        } else {
          medianSeasonalIndices[i] = seasonalIndices[i][middle];
        }
      } else {
        medianSeasonalIndices[i] = 1; // Default to no seasonal effect
      }
    }

    // Normalize seasonal factors to ensure they sum to the period length
    final sum = medianSeasonalIndices.reduce((a, b) => a + b);
    final adjustmentFactor = period / sum;

    return medianSeasonalIndices
        .map((index) => index * adjustmentFactor)
        .toList();
  }

  /// Calculate deseasonalized data for trend modeling
  List<double> _calculateDeseasonalizedData(
      List<double> values, List<double> seasonalIndices, int period) {
    return List<double>.generate(values.length, (index) {
      final seasonalIndex = seasonalIndices[index % period];
      return values[index] / seasonalIndex;
    });
  }

  /// Fit trend model to deseasonalized data
  /// Returns coefficients: [intercept, slope]
  List<double> _fitTrendModel(
      List<TimeSeriesPoint> originalData, List<double> deseasonalizedValues) {
    // Use linear regression to model trend
    final regression = LinearRegression();

    // Create time series with deseasonalized values
    final timeSeriesForTrend = List<TimeSeriesPoint>.generate(
      originalData.length,
      (index) => TimeSeriesPoint(
        timestamp: originalData[index].timestamp,
        value: deseasonalizedValues[index],
      ),
    );

    // Use linear regression algorithm (dummy forecast to extract coefficients)
    regression.forecast(timeSeries: timeSeriesForTrend, periods: 1);

    // Get coefficients from linear regression
    final intercept = regression.getIntercept();
    final slope = regression.getSlope();

    return [intercept, slope];
  }

  /// Calculate trend value for a given index using trend model
  double _calculateTrendValue(List<double> trendModel, int index) {
    final intercept = trendModel[0];
    final slope = trendModel[1];
    return intercept + slope * index;
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
}
