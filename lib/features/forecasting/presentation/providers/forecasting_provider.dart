import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../inventory/data/models/inventory_item_model.dart';
import '../../../inventory/data/repositories/inventory_repository.dart';
import '../../../sales/data/repositories/sales_repository.dart';
import '../../data/models/sales_forecast_model.dart';
import '../../domain/entities/time_series_point.dart';
import '../../domain/services/forecasting_service.dart';

/// States for the forecasting feature
abstract class ForecastingState {}

/// Initial state with no data
class ForecastingInitialState extends ForecastingState {}

/// Loading state while generating forecast
class ForecastingLoadingState extends ForecastingState {}

/// Error state when forecast generation fails
class ForecastingErrorState extends ForecastingState {
  ForecastingErrorState({required this.message});
  final String message;
}

/// Loaded state with forecast data
class ForecastingLoadedState extends ForecastingState {
  ForecastingLoadedState({
    required this.productId,
    required this.productName,
    required this.historicalData,
    required this.forecastData,
  });

  final String productId;
  final String productName;
  final List<TimeSeriesPoint> historicalData;
  final List<TimeSeriesPoint> forecastData;
}

/// Provider for forecasting state
final forecastingProvider =
    StateNotifierProvider<ForecastingNotifier, ForecastingState>(
  (ref) => ForecastingNotifier(
    forecastingService: ForecastingService(),
    salesRepository: SalesRepository(),
    inventoryRepository: InventoryRepository(),
  ),
);

/// Notifier for managing forecasting state
class ForecastingNotifier extends StateNotifier<ForecastingState> {
  ForecastingNotifier({
    required ForecastingService forecastingService,
    required SalesRepository salesRepository,
    required InventoryRepository inventoryRepository,
  })  : _forecastingService = forecastingService,
        _salesRepository = salesRepository,
        _inventoryRepository = inventoryRepository,
        super(ForecastingInitialState());

  final ForecastingService _forecastingService;
  final SalesRepository _salesRepository;
  final InventoryRepository _inventoryRepository;

  /// Generate a forecast for a product
  Future<void> generateForecast({
    required String productId,
    required String method,
    required int periods,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      state = ForecastingLoadingState();

      // Get product details
      final product = await _getInventoryItem(productId);
      if (product == null) {
        state = ForecastingErrorState(message: 'Product not found');
        return;
      }

      // Get historical sales data for the product
      final historicalData = await _getSalesHistoryForProduct(productId);
      if (historicalData.isEmpty) {
        state = ForecastingErrorState(
            message: 'No historical sales data available for this product');
        return;
      }

      // For now, just use the mock data since we don't have the actual forecasting implementation
      final SalesForecastModel? forecast =
          await _forecastingService.getForecastById("forecast-001");

      if (forecast == null) {
        state = ForecastingErrorState(message: 'Failed to generate forecast');
        return;
      }

      // Update state with forecast data
      state = ForecastingLoadedState(
        productId: productId,
        productName: product.name,
        historicalData: forecast.historicalData,
        forecastData: forecast.forecastData,
      );
    } catch (e) {
      state = ForecastingErrorState(message: 'Failed to generate forecast: $e');
    }
  }

  /// Save the current forecast
  Future<void> saveForecast({
    required String name,
    required String productId,
    required String method,
  }) async {
    try {
      if (state is! ForecastingLoadedState) {
        return;
      }

      final currentState = state as ForecastingLoadedState;

      // For demo purposes, just simulate saving
      await Future.delayed(const Duration(milliseconds: 300));

      // In a real implementation, we would call something like:
      // await _forecastingService.saveForecast(
      //   name: name,
      //   productId: productId,
      //   method: ForecastingMethod.values.firstWhere(
      //     (e) => e.toString().split('.').last == method,
      //     orElse: () => ForecastingMethod.linearRegression,
      //   ),
      //   historicalData: currentState.historicalData,
      //   forecastData: currentState.forecastData,
      // );
    } catch (e) {
      state = ForecastingErrorState(message: 'Failed to save forecast: $e');
    }
  }

  /// Get historical sales data for a product
  Future<List<TimeSeriesPoint>> _getSalesHistoryForProduct(
      String productId) async {
    try {
      // Get sales data for the last 12 months
      final endDate = DateTime.now();
      final startDate = DateTime(endDate.year - 1, endDate.month, endDate.day);

      // In a real implementation, this would fetch data from the repository
      // For now, return some mock data
      final forecasts =
          await _forecastingService.getForecastsForProduct(productId);
      if (forecasts.isNotEmpty) {
        return forecasts.first.historicalData;
      }

      // If no forecasts found, return empty list
      return [];
    } catch (e) {
      throw Exception('Failed to get sales history: $e');
    }
  }

  /// Load saved forecast by ID
  Future<void> loadForecastById(String forecastId) async {
    try {
      state = ForecastingLoadingState();

      final forecast = await _forecastingService.getForecastById(forecastId);
      if (forecast == null) {
        state = ForecastingErrorState(message: 'Forecast not found');
        return;
      }

      // Get product details
      final product = await _getInventoryItem(forecast.productId);
      final productName = product?.name ?? 'Unknown Product';

      state = ForecastingLoadedState(
        productId: forecast.productId,
        productName: productName,
        historicalData: forecast.historicalData,
        forecastData: forecast.forecastData,
      );
    } catch (e) {
      state = ForecastingErrorState(message: 'Failed to load forecast: $e');
    }
  }

  /// Helper method to get inventory item by ID
  Future<InventoryItemModel?> _getInventoryItem(String id) async {
    try {
      final items = await _inventoryRepository.getInventoryItemsByWarehouse('');
      return items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
}
