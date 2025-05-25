import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../forecasting/domain/entities/time_series_point.dart';
import '../../../forecasting/domain/services/forecasting_service.dart';
import '../../../procurement/domain/providers/supplier_lead_time_provider.dart';
import '../../../procurement/domain/repositories/supplier_lead_time_repository.dart';
import '../../data/models/inventory_movement_model.dart';
import '../../data/repositories/inventory_movement_repository.dart';

/// State notifier for forecasting
class ForecastingNotifier extends StateNotifier<void> {
  ForecastingNotifier(
    this._service,
    this._movementRepository,
    this._supplierLeadTimeRepository,
  ) : super(null);

  final ForecastingService _service;
  final InventoryMovementRepository _movementRepository;
  final SupplierLeadTimeRepository _supplierLeadTimeRepository;

  /// Gets forecast for a material
  Future<Map<String, dynamic>> getForecastForMaterial({
    required String materialId,
    required int periodDays,
  }) async {
    try {
      // Get historical data for the material
      final historicalData = await _getHistoricalData(materialId);
      if (historicalData.length < 3) {
        print(
            '[Forecasting] Warning: Insufficient historical data for $materialId. Returning fallback forecast.');
        // Fallback: flat forecast
        return {
          'totalDemand': 0.0,
          'dailyDemand': 0.0,
          'confidenceScore': 0.2,
          'dataPoints': List.generate(
              periodDays,
              (i) => TimeSeriesPoint(
                  timestamp:
                      DateTime.now().subtract(Duration(days: periodDays - i)),
                  value: 0.0)),
        };
      }
      // Generate forecast
      final forecastData = await _service.generateForecast(
        historyData: historicalData,
        method: ForecastingMethod.linearRegression,
        periods: periodDays,
      );
      // Calculate forecast metrics
      final totalDemand =
          forecastData.fold<double>(0, (sum, point) => sum + point.value);
      final dailyDemand = periodDays > 0 ? totalDemand / periodDays : 0.0;
      final confidenceScore =
          _calculateConfidenceScore(historicalData, forecastData);
      return {
        'totalDemand': totalDemand,
        'dailyDemand': dailyDemand,
        'confidenceScore': confidenceScore,
        'dataPoints': forecastData,
      };
    } catch (e, st) {
      print(
          '[Forecasting] Error in getForecastForMaterial($materialId): $e\n$st');
      // Fallback: flat forecast
      return {
        'totalDemand': 0.0,
        'dailyDemand': 0.0,
        'confidenceScore': 0.1,
        'dataPoints': List.generate(
            periodDays,
            (i) => TimeSeriesPoint(
                timestamp:
                    DateTime.now().subtract(Duration(days: periodDays - i)),
                value: 0.0)),
      };
    }
  }

  /// Gets historical data for a material based on actual inventory movements
  Future<List<TimeSeriesPoint>> _getHistoricalData(String materialId) async {
    try {
      // Retrieve all movements for this product
      final movements =
          await _movementRepository.getMovementsByProduct(materialId);
      if (movements.isEmpty) {
        print('[Forecasting] No inventory movements found for $materialId.');
        return [];
      }
      // Filter to only consider issue, consumption, and sales types
      final consumptionMovements = movements.where((movement) {
        final type = movement.movementType;
        return type == InventoryMovementType.issue ||
            type == InventoryMovementType.consumption ||
            type == InventoryMovementType.productionConsumption ||
            type == InventoryMovementType.salesIssue ||
            type == InventoryMovementType.saleShipment;
      }).toList();
      if (consumptionMovements.isEmpty) {
        print('[Forecasting] No consumption movements for $materialId.');
        return [];
      }
      // Group by day to aggregate daily consumption
      final dailyConsumption = groupBy<InventoryMovementModel, String>(
        consumptionMovements,
        (movement) => movement.movementDate.toIso8601String().split('T')[0],
      );
      // Convert to daily time series points
      final timeSeriesData = dailyConsumption.entries.map((entry) {
        final date = DateTime.parse('${entry.key}T00:00:00Z');
        double totalQuantity = 0;
        for (final movement in entry.value) {
          for (final item in movement.items) {
            if (item.productId == materialId) {
              totalQuantity += item.quantity;
            }
          }
        }
        return TimeSeriesPoint(timestamp: date, value: totalQuantity);
      }).toList();
      timeSeriesData.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return timeSeriesData;
    } catch (e, st) {
      print(
          '[Forecasting] Error retrieving historical usage data for $materialId: $e\n$st');
      return [];
    }
  }

  /// Calculates confidence score for the forecast based on data quality and quantity
  double _calculateConfidenceScore(
    List<TimeSeriesPoint> historicalData,
    List<TimeSeriesPoint> forecastData,
  ) {
    // If insufficient historical data, low confidence
    if (historicalData.length < 7) {
      return 0.5; // Limited data points
    }

    // Calculate mean of historical data
    final totalHistorical =
        historicalData.fold<double>(0, (sum, point) => sum + point.value);
    final meanHistorical = totalHistorical / historicalData.length;

    if (meanHistorical == 0) return 0.5; // Avoid division by zero

    // Calculate coefficient of variation (standard deviation / mean)
    // Higher variation means less predictable data, thus lower confidence
    double sumSquaredDeviations = 0;
    for (final point in historicalData) {
      sumSquaredDeviations += math.pow(point.value - meanHistorical, 2);
    }

    final variance = sumSquaredDeviations / historicalData.length;
    final stdDev = math.sqrt(variance);
    final coefficientOfVariation = stdDev / meanHistorical;

    // Base confidence score on coefficient of variation
    // Lower variation (more consistent data) results in higher confidence
    double baseConfidence = 1.0 - (coefficientOfVariation.clamp(0, 0.5) * 2);

    // Adjust confidence based on data quantity (more data = higher confidence)
    final dataQuantityFactor = (historicalData.length / 30).clamp(0.7, 1.0);

    return (baseConfidence * dataQuantityFactor).clamp(0.5, 0.95);
  }

  /// Gets supplier lead time info for a given material
  Future<Map<String, double>> getSupplierLeadTimeInfo({
    required String materialId,
    String? supplierId,
  }) async {
    try {
      if (supplierId != null) {
        final data = await _supplierLeadTimeRepository.getLeadTimeInfo(
          supplierId: supplierId,
          itemId: materialId,
        );
        if (data['averageLeadTimeDays'] == null ||
            data['averageLeadTimeDays']! <= 0) {
          print(
              '[LeadTime] Warning: Invalid averageLeadTimeDays for $materialId/$supplierId. Using fallback.');
          return {
            'averageLeadTimeDays': 7.0,
            'leadTimeVariability': 2.0,
            'maxLeadTimeDays': 14.0,
          };
        }
        return data;
      } else {
        final data = await _supplierLeadTimeRepository.getDefaultLeadTimeInfo(
          itemId: materialId,
        );
        if (data['averageLeadTimeDays'] == null ||
            data['averageLeadTimeDays']! <= 0) {
          print(
              '[LeadTime] Warning: Invalid default averageLeadTimeDays for $materialId. Using fallback.');
          return {
            'averageLeadTimeDays': 7.0,
            'leadTimeVariability': 2.0,
            'maxLeadTimeDays': 14.0,
          };
        }
        return data;
      }
    } catch (e, st) {
      print(
          '[LeadTime] Error retrieving supplier lead time for $materialId/$supplierId: $e\n$st');
      return {
        'averageLeadTimeDays': 7.0, // Default 1 week
        'leadTimeVariability': 2.0, // Default 2 days
        'maxLeadTimeDays': 14.0, // Default 2 weeks
      };
    }
  }
}

/// Provider for forecasting state
final forecastingProvider =
    StateNotifierProvider<ForecastingNotifier, void>((ref) {
  final service = ForecastingService();
  final movementRepository = ref.watch(inventoryMovementRepositoryProvider);
  final leadTimeRepository = ref.watch(supplierLeadTimeRepositoryProvider);
  return ForecastingNotifier(service, movementRepository, leadTimeRepository);
});
