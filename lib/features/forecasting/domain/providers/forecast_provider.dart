import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/forecast_model.dart';
import '../../data/repositories/forecast_repository.dart';
import '../algorithms/arima.dart';
import '../algorithms/exponential_smoothing.dart';
import '../algorithms/linear_regression.dart';
import '../algorithms/moving_average.dart';
import '../algorithms/seasonal_decomposition.dart';
import '../entities/forecast_granularity.dart';
import '../entities/forecast_method.dart';
import '../entities/time_series_point.dart';

/// Provider for forecast repository
final forecastRepositoryProvider = Provider<ForecastRepository>((ref) {
  return ForecastRepository();
});

/// Provider for forecast data
final forecastProvider =
    StateNotifierProvider<ForecastState, AsyncValue<List<ForecastModel>>>(
        (ref) {
  return ForecastState(ref);
});

/// State notifier for forecasts
class ForecastState extends StateNotifier<AsyncValue<List<ForecastModel>>> {
  ForecastState(this._ref) : super(const AsyncLoading()) {
    _getForecasts();
  }

  final Ref _ref;
  late final ForecastRepository _repository =
      _ref.read(forecastRepositoryProvider);

  /// Fetches all forecasts
  Future<List<ForecastModel>> _getForecasts() async {
    try {
      final forecasts = await _repository.getForecasts();
      state = AsyncData(forecasts);
      return forecasts;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return [];
    }
  }

  /// Creates a new forecast
  Future<void> createForecast(ForecastModel forecast) async {
    try {
      state = const AsyncLoading();
      await _repository.createForecast(forecast);
      state = AsyncData(await _getForecasts());
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  /// Updates an existing forecast
  Future<void> updateForecast(ForecastModel forecast) async {
    try {
      state = const AsyncLoading();
      await _repository.updateForecast(forecast.id!, forecast);
      state = AsyncData(await _getForecasts());
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  /// Deletes a forecast
  Future<void> deleteForecast(String id) async {
    try {
      state = const AsyncLoading();
      await _repository.deleteForecast(id);
      state = AsyncData(await _getForecasts());
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  /// Generates a forecast based on historical data and the specified method
  Future<List<TimeSeriesPoint>> generateForecast({
    required List<TimeSeriesPoint> historicalData,
    required ForecastMethod method,
    required int periods,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      // Default parameters
      final defaultParams = <String, dynamic>{
        'windowSize': 3,
        'alpha': 0.3,
        'beta': 0.1,
        'gamma': 0.1,
        'seasonalPeriod': 12,
        'p': 1,
        'd': 1,
        'q': 1,
      };

      // Merge with provided parameters
      final params = {...defaultParams, ...?parameters};

      // Apply the appropriate forecasting algorithm
      switch (method) {
        case ForecastMethod.movingAverage:
          final movingAverage = MovingAverage();
          return movingAverage.forecast(
            timeSeries: historicalData,
            windowSize: params['windowSize'],
            periods: periods,
          );

        case ForecastMethod.exponentialSmoothing:
          final expSmoothing = ExponentialSmoothing();
          return expSmoothing.forecast(
            timeSeries: historicalData,
            alpha: params['alpha'],
            periods: periods,
          );

        case ForecastMethod.linearRegression:
          final linearRegression = LinearRegression();
          return linearRegression.forecast(
            timeSeries: historicalData,
            periods: periods,
          );

        case ForecastMethod.seasonalDecomposition:
          final seasonalDecomposition = SeasonalDecomposition();
          return seasonalDecomposition.forecast(
            timeSeries: historicalData,
            periods: periods,
            seasonalPeriod: params['seasonalPeriod'],
          );

        default:
          throw Exception('Unsupported forecast method: $method');
      }
    } catch (e) {
      rethrow;
    }
  }
}

/// Provider for current forecast
final currentForecastProvider = StateProvider<ForecastModel?>((ref) => null);
