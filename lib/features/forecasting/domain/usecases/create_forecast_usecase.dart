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

/// Use case for creating a new forecast
class CreateForecastUseCase {
  CreateForecastUseCase({ForecastRepository? repository})
      : _repository = repository ?? ForecastRepository();
  final ForecastRepository _repository;

  /// Create a new forecast with calculated forecast items
  Future<String> execute({
    required String name,
    required String description,
    required ForecastMethod method,
    required ForecastGranularity granularity,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> productIds,
    required List<TimeSeriesPoint> historicalData,
    String? categoryId,
    String? warehouseId,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      // Generate forecast data
      final forecastData = await _generateForecast(
        historicalData: historicalData,
        method: method,
        startDate: startDate,
        endDate: endDate,
        granularity: granularity,
        parameters: parameters,
      );

      // Convert method enum to string for storage
      final methodStr = method.toString().split('.').last;

      // Default product ID if none provided
      final defaultProductId =
          productIds.isNotEmpty ? productIds[0] : 'default-product';

      // Create forecast model
      final forecast = ForecastModel(
        name: name,
        description: description,
        createdDate: DateTime.now(),
        createdByUserId:
            'current-user-id', // In a real app, get from auth service
        productIds: productIds,
        categoryId: categoryId,
        warehouseId: warehouseId,
        startDate: startDate,
        endDate: endDate,
        forecastMethod: methodStr,
        methodParameters: parameters ?? {},
        forecastItems: forecastData
            .map((point) => ForecastItemModel(
                  productId: defaultProductId,
                  date: point.timestamp,
                  forecastedValue: point.value,
                ))
            .toList(),
        accuracyMetric: null, // Can be calculated later
      );

      // Save to repository
      return await _repository.createForecast(forecast);
    } catch (e) {
      throw Exception('Failed to create forecast: ${e.toString()}');
    }
  }

  /// Generate forecast data using the specified method
  Future<List<TimeSeriesPoint>> _generateForecast({
    required List<TimeSeriesPoint> historicalData,
    required ForecastMethod method,
    required DateTime startDate,
    required DateTime endDate,
    required ForecastGranularity granularity,
    Map<String, dynamic>? parameters,
  }) async {
    // Calculate number of periods to forecast
    final int periods = _calculatePeriods(startDate, endDate, granularity);

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

      case ForecastMethod.arima:
        final arimaModel = ArimaForecaster(
          p: params['p'],
          d: params['d'],
          q: params['q'],
          P: params['P'],
          D: params['D'],
          Q: params['Q'],
          seasonalPeriod: params['seasonalPeriod'],
        );
        return arimaModel.forecast(
          timeSeries: historicalData,
          periods: periods,
        );

      default:
        throw Exception('Unsupported forecast method: ${method.toString()}');
    }
  }

  /// Calculate the number of periods to forecast based on date range and granularity
  int _calculatePeriods(
      DateTime start, DateTime end, ForecastGranularity granularity) {
    switch (granularity) {
      case ForecastGranularity.daily:
        return end.difference(start).inDays + 1;
      case ForecastGranularity.weekly:
        return ((end.difference(start).inDays) / 7).ceil();
      case ForecastGranularity.monthly:
        return (end.year - start.year) * 12 + end.month - start.month + 1;
      case ForecastGranularity.quarterly:
        final months = (end.year - start.year) * 12 + end.month - start.month;
        return (months / 3).ceil();
      case ForecastGranularity.yearly:
        return end.year - start.year + 1;
      default:
        throw Exception('Unsupported granularity: ${granularity.toString()}');
    }
  }
}
