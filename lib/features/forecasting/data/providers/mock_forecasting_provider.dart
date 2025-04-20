import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../inventory/data/providers/mock_inventory_provider.dart';
import '../models/sales_forecast_model.dart';
import '../../domain/entities/time_series_point.dart';
import 'package:intl/intl.dart';

/// Provides mock forecasting data that integrates with inventory
class MockForecastingProvider {
  MockForecastingProvider({
    required this.mockDataService,
    required this.mockInventoryProvider,
  });

  final MockDataService mockDataService;
  final MockInventoryProvider mockInventoryProvider;

  /// Get forecast for a specific item
  List<TimeSeriesPoint> getItemForecast(String itemId, {int days = 7}) {
    final forecastData = mockDataService.getInventoryForecast(itemId);

    if (forecastData.isEmpty) {
      // Generate random forecast if no data exists
      return _generateRandomForecast(days);
    }

    // Convert to TimeSeriesPoint
    final List<TimeSeriesPoint> result = [];
    for (final data in forecastData) {
      result.add(
        TimeSeriesPoint(
          timestamp: data['date'] as DateTime,
          value: data['forecastedValue'] as double,
        ),
      );
    }

    return result;
  }

  /// Generate forecast for all inventory items
  Map<String, List<TimeSeriesPoint>> generateForecastForAllItems(
      {int days = 7}) {
    final Map<String, List<TimeSeriesPoint>> result = {};

    for (final item in mockInventoryProvider.getAllItems()) {
      result[item.id] = getItemForecast(item.id, days: days);
    }

    return result;
  }

  /// Generate sales forecast model
  SalesForecastModel generateSalesForecast({
    required String productId,
    required String productName,
    int forecastDays = 30,
  }) {
    final inventoryItem = mockInventoryProvider.getItemById(productId);
    if (inventoryItem == null) {
      throw Exception('Product not found');
    }

    final forecastPoints = getItemForecast(productId, days: forecastDays);
    final historicalPoints = _generateRandomForecast(30, multiplier: 0.8);

    // Calculate total forecasted amount
    double totalForecastAmount = 0;
    for (final point in forecastPoints) {
      totalForecastAmount += point.value;
    }

    // Calculate average daily demand
    final avgDailyDemand = totalForecastAmount / forecastDays;

    return SalesForecastModel(
      id: 'forecast-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Forecast for $productName',
      description: 'Auto-generated forecast based on historical data',
      productId: productId,
      createdDate: DateTime.now(),
      methodName: 'TimeSeries',
      historicalData: historicalPoints,
      forecastData: forecastPoints,
      parameters: {
        'days': forecastDays,
        'averageDailyDemand': avgDailyDemand,
        'confidenceLevel': 0.85,
      },
      accuracy: {
        'mape': 12.5, // Mean Absolute Percentage Error
        'rmse': 3.2, // Root Mean Square Error
        'mae': 2.8, // Mean Absolute Error
      },
    );
  }

  /// Check inventory levels against future forecast
  List<Map<String, dynamic>> checkInventoryAgainstForecast(
      {int forecastDays = 30}) {
    final List<Map<String, dynamic>> result = [];
    final items = mockInventoryProvider.getAllItems();

    for (final item in items) {
      final forecastPoints = getItemForecast(item.id, days: forecastDays);

      // Calculate total forecasted amount
      double totalForecastedDemand = 0;
      for (final point in forecastPoints) {
        totalForecastedDemand += point.value;
      }

      // Calculate if there's sufficient inventory
      final sufficientInventory = item.quantity >= totalForecastedDemand;
      final daysUntilShortage = sufficientInventory
          ? forecastDays
          : _calculateDaysUntilShortage(item.quantity, forecastPoints);

      result.add({
        'itemId': item.id,
        'itemName': item.name,
        'currentInventory': item.quantity,
        'forecastedDemand': totalForecastedDemand,
        'sufficientInventory': sufficientInventory,
        'daysUntilShortage': daysUntilShortage,
        'unit': item.unit,
      });
    }

    return result;
  }

  // Helper method to generate random forecast data
  List<TimeSeriesPoint> _generateRandomForecast(int days,
      {double multiplier = 1.0}) {
    final List<TimeSeriesPoint> result = [];
    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < days; i++) {
      // Generate pseudo-random value that's somewhat consistent
      final baseValue = (((random + i * 7) % 30) + 10) * multiplier;
      // Add some daily variation
      final value = baseValue + (((random + i * 13) % 10) - 5);

      result.add(
        TimeSeriesPoint(
          timestamp: DateTime.now().add(Duration(days: i)),
          value: value,
        ),
      );
    }

    return result;
  }

  // Calculate days until inventory shortage
  int _calculateDaysUntilShortage(
      double currentInventory, List<TimeSeriesPoint> forecastPoints) {
    double remainingInventory = currentInventory;
    int day = 0;

    for (final point in forecastPoints) {
      if (remainingInventory < point.value) {
        return day;
      }

      remainingInventory -= point.value;
      day++;
    }

    return day;
  }

  // Generate seasonal factors
  Map<String, double> _generateSeasonalFactors() {
    return {
      'January': 0.85,
      'February': 0.90,
      'March': 0.95,
      'April': 1.0,
      'May': 1.05,
      'June': 1.15,
      'July': 1.2,
      'August': 1.1,
      'September': 1.0,
      'October': 0.95,
      'November': 1.1,
      'December': 1.3,
    };
  }
}

/// Provider for mock forecasting
final mockForecastingProvider = Provider<MockForecastingProvider>((ref) {
  final mockDataService = ref.read(mockDataServiceProvider);
  final inventoryProvider = ref.read(mockInventoryProvider);

  return MockForecastingProvider(
    mockDataService: mockDataService,
    mockInventoryProvider: inventoryProvider,
  );
});
