import '../../domain/entities/time_series_point.dart';
import '../datasources/forecast_data_source.dart';
import '../models/forecast_model.dart';

/// Repository that handles forecast data operations
class ForecastRepository {
  ForecastRepository({
    ForecastDataSource? dataSource,
  }) : _dataSource = dataSource ?? ForecastDataSource();
  final ForecastDataSource _dataSource;

  /// Get a list of all forecasts
  Future<List<ForecastModel>> getForecasts() async {
    try {
      return await _dataSource.getForecasts();
    } catch (e) {
      throw Exception('Failed to get forecasts: ${e.toString()}');
    }
  }

  /// Get a specific forecast by ID
  Future<ForecastModel> getForecastById(String id) async {
    try {
      return await _dataSource.getForecastById(id);
    } catch (e) {
      throw Exception('Failed to get forecast: ${e.toString()}');
    }
  }

  /// Create a new forecast
  Future<String> createForecast(ForecastModel forecast) async {
    try {
      return await _dataSource.createForecast(forecast);
    } catch (e) {
      throw Exception('Failed to create forecast: ${e.toString()}');
    }
  }

  /// Update an existing forecast
  Future<void> updateForecast(String id, ForecastModel forecast) async {
    try {
      await _dataSource.updateForecast(id, forecast);
    } catch (e) {
      throw Exception('Failed to update forecast: ${e.toString()}');
    }
  }

  /// Delete a forecast
  Future<void> deleteForecast(String id) async {
    try {
      await _dataSource.deleteForecast(id);
    } catch (e) {
      throw Exception('Failed to delete forecast: ${e.toString()}');
    }
  }

  /// Get historical time series data for forecasting
  Future<List<TimeSeriesPoint>> getHistoricalData({
    required List<String> productIds,
    String? categoryId,
    String? warehouseId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return _dataSource.getHistoricalData(
        productIds: productIds,
        categoryId: categoryId,
        warehouseId: warehouseId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to get historical data: ${e.toString()}');
    }
  }
}

/// Provider for the forecast repository
ForecastRepository provideForecastRepository() {
  return ForecastRepository();
}
