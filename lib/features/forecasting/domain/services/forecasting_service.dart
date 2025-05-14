import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/sales_forecast_model.dart';
import '../../data/repositories/sales_forecast_repository.dart';
import '../algorithms/arima.dart';
import '../algorithms/exponential_smoothing.dart';
import '../algorithms/linear_regression.dart';
import '../algorithms/moving_average.dart';
import '../algorithms/seasonal_decomposition.dart';
import '../entities/time_series_point.dart';

/// Forecasting methods supported by the service
enum ForecastingMethod {
  linearRegression,
  movingAverage,
  exponentialSmoothing,
  arima,
  seasonalDecomposition,
}

/// Service that provides functionality for sales forecasting
class ForecastingService {

  factory ForecastingService() {
    return _instance;
  }

  ForecastingService._internal()
      : _repository = SalesForecastRepository(),
        _firestore = FirebaseFirestore.instance;
  // Singleton pattern for easy access
  static final ForecastingService _instance = ForecastingService._internal();

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

  /// Get forecasts for a specific product
  Future<List<SalesForecastModel>> getForecastsForProduct(
      String productId) async {
    // For demo purposes, return mock data instead of calling repository
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Filter forecasts by productId, or return all if 'demo-product-id'
    if (productId == 'demo-product-id') {
      return _mockForecasts;
    }

    return _mockForecasts.where((f) => f.productId == productId).toList();
  }

  /// Get a specific forecast by ID
  Future<SalesForecastModel?> getForecastById(String forecastId) async {
    // For demo purposes, return mock data instead of calling repository
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _mockForecasts.firstWhere(
      (f) => f.id == forecastId,
      orElse: () => throw Exception('Forecast not found'),
    );
  }

  /// Delete a forecast
  Future<void> deleteForecast(String forecastId) async {
    // Implementation would call repository
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Mock data for forecasts
  final List<SalesForecastModel> _mockForecasts = [
    SalesForecastModel(
      id: 'forecast-001',
      name: 'Milk Sales Q2 2023',
      description: 'Seasonal forecast for whole milk sales in Q2 2023',
      productId: 'P001',
      createdDate: DateTime.now().subtract(const Duration(days: 30)),
      methodName: 'seasonalDecomposition',
      historicalData: _generateTimeSeriesData(
        start: DateTime.now().subtract(const Duration(days: 180)),
        end: DateTime.now(),
        interval: const Duration(days: 7),
        baseValue: 1200,
        trend: 5,
        seasonality: 100,
        noise: 30,
      ),
      forecastData: _generateTimeSeriesData(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 90)),
        interval: const Duration(days: 7),
        baseValue: 1500,
        trend: 8,
        seasonality: 120,
        noise: 0,
      ),
      parameters: {
        'seasonalPeriod': 4,
        'trendsEnabled': true,
      },
      accuracy: {
        'rmse': 35.7,
        'mape': 3.2,
        'r2': 0.92,
      },
    ),
    SalesForecastModel(
      id: 'forecast-002',
      name: 'Yogurt Demand Projection',
      description: 'Linear regression forecast for strawberry yogurt',
      productId: 'P003',
      createdDate: DateTime.now().subtract(const Duration(days: 15)),
      methodName: 'linearRegression',
      historicalData: _generateTimeSeriesData(
        start: DateTime.now().subtract(const Duration(days: 120)),
        end: DateTime.now(),
        interval: const Duration(days: 7),
        baseValue: 800,
        trend: 10,
        seasonality: 0,
        noise: 50,
      ),
      forecastData: _generateTimeSeriesData(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 60)),
        interval: const Duration(days: 7),
        baseValue: 1000,
        trend: 15,
        seasonality: 0,
        noise: 0,
      ),
      parameters: {
        'confidenceInterval': 0.95,
      },
      accuracy: {
        'rmse': 42.3,
        'mape': 4.8,
        'r2': 0.89,
      },
    ),
    SalesForecastModel(
      id: 'forecast-003',
      name: 'Cheese Production',
      description: 'Moving average projection for cheese curd production',
      productId: 'P004',
      createdDate: DateTime.now().subtract(const Duration(days: 45)),
      methodName: 'movingAverage',
      historicalData: _generateTimeSeriesData(
        start: DateTime.now().subtract(const Duration(days: 150)),
        end: DateTime.now(),
        interval: const Duration(days: 7),
        baseValue: 500,
        trend: -2,
        seasonality: 50,
        noise: 20,
      ),
      forecastData: _generateTimeSeriesData(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 75)),
        interval: const Duration(days: 7),
        baseValue: 450,
        trend: 0,
        seasonality: 50,
        noise: 0,
      ),
      parameters: {
        'windowSize': 4,
      },
      accuracy: {
        'rmse': 15.8,
        'mape': 3.1,
        'r2': 0.87,
      },
    ),
    SalesForecastModel(
      id: 'forecast-004',
      name: 'Butter Sales Prediction',
      description: 'Exponential smoothing for butter sales',
      productId: 'P005',
      createdDate: DateTime.now().subtract(const Duration(days: 60)),
      methodName: 'exponentialSmoothing',
      historicalData: _generateTimeSeriesData(
        start: DateTime.now().subtract(const Duration(days: 200)),
        end: DateTime.now(),
        interval: const Duration(days: 7),
        baseValue: 600,
        trend: 3,
        seasonality: 80,
        noise: 25,
      ),
      forecastData: _generateTimeSeriesData(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 84)),
        interval: const Duration(days: 7),
        baseValue: 750,
        trend: 5,
        seasonality: 80,
        noise: 0,
      ),
      parameters: {
        'alpha': 0.7,
        'beta': 0.2,
        'gamma': 0.1,
      },
      accuracy: {
        'rmse': 28.2,
        'mape': 3.9,
        'r2': 0.91,
      },
    ),
  ];

  /// Generate mock time series data with trend, seasonality and noise
  static List<TimeSeriesPoint> _generateTimeSeriesData({
    required DateTime start,
    required DateTime end,
    required Duration interval,
    required double baseValue,
    double trend = 0,
    double seasonality = 0,
    double noise = 0,
  }) {
    final List<TimeSeriesPoint> data = [];

    DateTime current = start;
    int i = 0;

    while (current.isBefore(end)) {
      // Calculate components
      final trendComponent = trend * i;
      final seasonalComponent =
          seasonality > 0 ? seasonality * math.sin(2 * math.pi * i / 12) : 0;
      final noiseComponent =
          noise > 0 ? (math.Random().nextDouble() * 2 - 1) * noise : 0;

      // Combine components
      final value =
          baseValue + trendComponent + seasonalComponent + noiseComponent;

      // Add to list
      data.add(TimeSeriesPoint(
        timestamp: current,
        value: value.roundToDouble(),
      ));

      // Next point
      current = current.add(interval);
      i++;
    }

    return data;
  }
}

/// Represents a saved forecast (immutable class)
class ForecastModel {
  /// Creates an immutable ForecastModel
  const ForecastModel({
    required this.id,
    required this.name,
    required this.productId,
    required this.method,
    required this.createdAt,
    required this.historicalData,
    required this.forecastData,
  });

  /// Create a ForecastModel from a Firestore document
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

  /// Unique identifier
  final String id;

  /// Name of the forecast
  final String name;

  /// ID of the product being forecast
  final String productId;

  /// Method used for forecasting
  final ForecastingMethod method;

  /// Date the forecast was created
  final DateTime createdAt;

  /// Historical time series data points
  final List<TimeSeriesPoint> historicalData;

  /// Forecasted time series data points
  final List<TimeSeriesPoint> forecastData;

  /// Convert method string to enum
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
