import '../algorithms/moving_average.dart';
import '../algorithms/exponential_smoothing.dart';
import '../algorithms/linear_regression.dart';
import '../algorithms/seasonal_decomposition.dart';
import '../algorithms/arima.dart';
import '../entities/time_series_point.dart';
import '../../data/repositories/sales_forecast_repository.dart';
import '../../data/models/sales_forecast_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

/// Forecasting methods supported by the service
enum ForecastingMethod {
  movingAverage,
  exponentialSmoothing,
  linearRegression,
  seasonalDecomposition,
  arima,
}

/// Service for generating and managing sales forecasts
class ForecastingService {
  ForecastingService({
    SalesForecastRepository? repository,
    FirebaseFirestore? firestore,
  })  : _repository = repository ?? SalesForecastRepository(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final SalesForecastRepository _repository;
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  /// Generate a forecast using the specified method
  ///
  /// [historyData] - Historical time series data
  /// [method] - Forecasting method to use
  /// [periods] - Number of future periods to forecast
  /// [parameters] - Optional parameters for specific forecasting methods
  Future<List<TimeSeriesPoint>> generateForecast({
    required List<TimeSeriesPoint> historyData,
    required ForecastingMethod method,
    required int periods,
    Map<String, dynamic>? parameters,
  }) async {
    if (historyData.isEmpty) {
      throw ArgumentError('Historical data cannot be empty');
    }

    if (periods <= 0) {
      throw ArgumentError('Forecast periods must be positive');
    }

    // Sort time series data by date
    final sortedData = List<TimeSeriesPoint>.from(historyData)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Generate forecast based on the selected method
    switch (method) {
      case ForecastingMethod.movingAverage:
        return _generateMovingAverageForecast(sortedData, periods, parameters);

      case ForecastingMethod.exponentialSmoothing:
        return _generateExponentialSmoothingForecast(
            sortedData, periods, parameters);

      case ForecastingMethod.linearRegression:
        return _generateLinearRegressionForecast(sortedData, periods);

      case ForecastingMethod.seasonalDecomposition:
        return _generateSeasonalDecompositionForecast(
            sortedData, periods, parameters);

      case ForecastingMethod.arima:
        return _generateArimaForecast(sortedData, periods, parameters);
    }
  }

  /// Generate forecast using moving average method
  List<TimeSeriesPoint> _generateMovingAverageForecast(
    List<TimeSeriesPoint> historyData,
    int periods,
    Map<String, dynamic>? parameters,
  ) {
    // Extract window size parameter with default value
    final windowSize = parameters?['windowSize'] as int? ??
        _calculateDefaultWindowSize(historyData.length);

    final algorithm = MovingAverage();
    return algorithm.forecast(
      timeSeries: historyData,
      windowSize: windowSize,
      periods: periods,
    );
  }

  /// Generate forecast using exponential smoothing method
  List<TimeSeriesPoint> _generateExponentialSmoothingForecast(
    List<TimeSeriesPoint> historyData,
    int periods,
    Map<String, dynamic>? parameters,
  ) {
    // Extract alpha parameter with default value
    final alpha = parameters?['alpha'] as double? ?? 0.3;

    final algorithm = ExponentialSmoothing();
    return algorithm.forecast(
      timeSeries: historyData,
      alpha: alpha,
      periods: periods,
    );
  }

  /// Generate forecast using linear regression method
  List<TimeSeriesPoint> _generateLinearRegressionForecast(
    List<TimeSeriesPoint> historyData,
    int periods,
  ) {
    final algorithm = LinearRegression();
    return algorithm.forecast(
      timeSeries: historyData,
      periods: periods,
    );
  }

  /// Generate forecast using seasonal decomposition method
  List<TimeSeriesPoint> _generateSeasonalDecompositionForecast(
    List<TimeSeriesPoint> historyData,
    int periods,
    Map<String, dynamic>? parameters,
  ) {
    // Extract seasonal period parameter
    final seasonalPeriod = parameters?['seasonalPeriod'] as int? ??
        _detectSeasonalPeriod(historyData);

    final algorithm = SeasonalDecomposition();
    return algorithm.forecast(
      timeSeries: historyData,
      seasonalPeriod: seasonalPeriod,
      periods: periods,
    );
  }

  /// Generate forecast using ARIMA method
  List<TimeSeriesPoint> _generateArimaForecast(
    List<TimeSeriesPoint> historyData,
    int periods,
    Map<String, dynamic>? parameters,
  ) {
    // Extract ARIMA parameters with default values
    final p = parameters?['p'] as int? ?? 1; // Autoregressive order
    final d = parameters?['d'] as int? ?? 1; // Differencing order
    final q = parameters?['q'] as int? ?? 1; // Moving average order
    final P = parameters?['P'] as int? ?? 0; // Seasonal autoregressive order
    final D = parameters?['D'] as int? ?? 0; // Seasonal differencing order
    final Q = parameters?['Q'] as int? ?? 0; // Seasonal moving average order
    final seasonalPeriod =
        parameters?['seasonalPeriod'] as int? ?? 0; // Seasonal period length

    final algorithm = ArimaForecaster(
      p: p,
      d: d,
      q: q,
      P: P,
      D: D,
      Q: Q,
      seasonalPeriod: seasonalPeriod,
    );

    return algorithm.forecast(
      timeSeries: historyData,
      periods: periods,
    );
  }

  /// Save a forecast to the repository
  Future<String> saveForecast({
    required String name,
    required String productId,
    required ForecastingMethod method,
    required List<TimeSeriesPoint> historicalData,
    required List<TimeSeriesPoint> forecastData,
    String? description,
    Map<String, dynamic>? parameters,
  }) async {
    final forecast = SalesForecastModel(
      name: name,
      description: description ?? 'Forecast for product $productId',
      productId: productId,
      createdDate: DateTime.now(),
      methodName: method.toString().split('.').last,
      historicalData: historicalData,
      forecastData: forecastData,
      parameters: parameters ?? {},
      accuracy: _calculateForecastAccuracy(historicalData),
    );

    return await _repository.createSalesForecast(forecast);
  }

  /// Calculate default window size for moving average
  int _calculateDefaultWindowSize(int dataLength) {
    // Use approximately 20% of the data length as window size
    final windowSize = (dataLength * 0.2).round();
    // Ensure window size is at least 2 and no larger than half the data length
    return windowSize.clamp(2, dataLength ~/ 2);
  }

  /// Detect seasonal period from time series data
  int _detectSeasonalPeriod(List<TimeSeriesPoint> data) {
    // This is a simplified approach - in a real implementation, you would
    // use autocorrelation or spectral analysis to detect seasonality

    // Common seasonal periods: 12 for monthly data, 4 for quarterly, 7 for daily

    // Check data point spacing
    if (data.length < 3) return 1; // Default to no seasonality

    // Calculate average time difference between points in days
    int totalDifference = 0;
    for (int i = 1; i < data.length; i++) {
      totalDifference +=
          data[i].timestamp.difference(data[i - 1].timestamp).inDays;
    }

    final avgDifferenceInDays = totalDifference / (data.length - 1);

    // Determine seasonal period based on average time difference
    if (avgDifferenceInDays >= 28 && avgDifferenceInDays <= 31) {
      return 12; // Monthly data, yearly seasonality
    } else if (avgDifferenceInDays >= 89 && avgDifferenceInDays <= 92) {
      return 4; // Quarterly data, yearly seasonality
    } else if (avgDifferenceInDays >= 1 && avgDifferenceInDays <= 1.5) {
      return 7; // Daily data, weekly seasonality
    } else if (avgDifferenceInDays >= 6.5 && avgDifferenceInDays <= 7.5) {
      return 52; // Weekly data, yearly seasonality
    }

    // Default to no seasonality if pattern cannot be determined
    return 1;
  }

  /// Calculate forecast accuracy metrics (simplified)
  Map<String, double> _calculateForecastAccuracy(
      List<TimeSeriesPoint> historicalData) {
    // This is a placeholder - in a real implementation, you would
    // calculate accuracy metrics using cross-validation or hold-out samples

    // Returning placeholder metrics
    return {
      'mape': 0.0, // Mean Absolute Percentage Error
      'rmse': 0.0, // Root Mean Square Error
      'mae': 0.0, // Mean Absolute Error
    };
  }

  /// Get saved forecasts for a specific product
  Future<List<SalesForecastModel>> getForecastsForProduct(
      String productId) async {
    return await _repository.getSalesForecasts(productId: productId);
  }

  /// Get a specific forecast by ID
  Future<SalesForecastModel> getForecastById(String forecastId) async {
    return await _repository.getSalesForecastById(forecastId);
  }

  /// Delete a forecast
  Future<void> deleteForecast(String forecastId) async {
    await _repository.deleteSalesForecast(forecastId);
  }
}

/// Represents a saved forecast
class ForecastModel {
  final String id;
  final String name;
  final String productId;
  final ForecastingMethod method;
  final DateTime createdAt;
  final List<TimeSeriesPoint> historicalData;
  final List<TimeSeriesPoint> forecastData;

  ForecastModel({
    required this.id,
    required this.name,
    required this.productId,
    required this.method,
    required this.createdAt,
    required this.historicalData,
    required this.forecastData,
  });

  factory ForecastModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ForecastModel(
      id: doc.id,
      name: data['name'] as String,
      productId: data['productId'] as String,
      method: _methodFromString(data['method'] as String),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      historicalData: (data['historicalData'] as List)
          .map((item) => TimeSeriesPoint.fromJson(item as Map<String, dynamic>))
          .toList(),
      forecastData: (data['forecastData'] as List)
          .map((item) => TimeSeriesPoint.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static ForecastingMethod _methodFromString(String methodString) {
    switch (methodString) {
      case 'movingAverage':
        return ForecastingMethod.movingAverage;
      case 'exponentialSmoothing':
        return ForecastingMethod.exponentialSmoothing;
      case 'linearRegression':
        return ForecastingMethod.linearRegression;
      case 'seasonalDecomposition':
        return ForecastingMethod.seasonalDecomposition;
      default:
        return ForecastingMethod.movingAverage;
    }
  }
}

// Helper function for moving average
int max(int a, int b) => a > b ? a : b;
