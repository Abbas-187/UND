import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:und_app/features/forecasting/domain/entities/time_series_point.dart';
import 'package:und_app/features/forecasting/domain/services/forecasting_service.dart';
import 'package:und_app/features/inventory/data/models/inventory_item_model.dart';
import 'package:und_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:und_app/features/sales/data/models/sales_order_model.dart';
import 'package:und_app/features/sales/data/repositories/sales_repository.dart';

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
    required ForecastingMethod method,
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

      // Generate forecast using the selected method
      final forecastData = await _forecastingService.generateForecast(
        historyData: historicalData,
        method: method,
        periods: periods,
        parameters: parameters,
      );

      // Update state with forecast data
      state = ForecastingLoadedState(
        productId: productId,
        productName: product.name,
        historicalData: historicalData,
        forecastData: forecastData,
      );
    } catch (e) {
      state = ForecastingErrorState(message: 'Failed to generate forecast: $e');
    }
  }

  /// Save the current forecast
  Future<void> saveForecast({
    required String name,
    required String productId,
    required ForecastingMethod method,
  }) async {
    try {
      if (state is! ForecastingLoadedState) {
        return;
      }

      final currentState = state as ForecastingLoadedState;

      await _forecastingService.saveForecast(
        name: name,
        productId: productId,
        method: method,
        historicalData: currentState.historicalData,
        forecastData: currentState.forecastData,
      );
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

      // Query sales orders
      final salesOrders = await _salesRepository.getSalesOrders(
        startDate: startDate,
        endDate: endDate,
      );

      // Extract product quantities by month
      final Map<DateTime, double> monthlySales = {};

      for (final order in salesOrders) {
        for (final item in order.items) {
          if (item.productId == productId) {
            // Get the month start date (1st day of the month)
            final monthStart =
                DateTime(order.orderDate.year, order.orderDate.month, 1);

            // Add to monthly total
            monthlySales[monthStart] =
                (monthlySales[monthStart] ?? 0) + item.quantity;
          }
        }
      }

      // Convert to time series points
      final List<TimeSeriesPoint> timeSeriesData = [];

      // Add a point for each month, even if no sales
      DateTime currentMonth = DateTime(startDate.year, startDate.month, 1);

      while (!currentMonth.isAfter(endDate)) {
        timeSeriesData.add(
          TimeSeriesPoint(
            timestamp: currentMonth,
            value: monthlySales[currentMonth] ?? 0,
          ),
        );

        // Move to next month
        if (currentMonth.month == 12) {
          currentMonth = DateTime(currentMonth.year + 1, 1, 1);
        } else {
          currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
        }
      }

      return timeSeriesData;
    } catch (e) {
      throw Exception('Failed to get sales history: $e');
    }
  }

  /// Load saved forecast by ID
  Future<void> loadForecastById(String forecastId) async {
    try {
      state = ForecastingLoadingState();

      final forecast = await _forecastingService.getForecastById(forecastId);

      // Get product details
      final product = await _getInventoryItem(forecast.productId);
      if (product == null) {
        state = ForecastingErrorState(message: 'Product not found');
        return;
      }

      state = ForecastingLoadedState(
        productId: forecast.productId,
        productName: product.name,
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
