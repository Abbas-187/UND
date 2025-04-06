import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/inventory_optimization_model.dart';
import '../../data/repositories/inventory_optimization_repository.dart';
import '../algorithms/safety_stock_calculator.dart';
import '../entities/time_series_point.dart';

/// Provider for inventory optimization repository
final inventoryOptimizationRepositoryProvider =
    Provider<InventoryOptimizationRepository>((ref) {
  return InventoryOptimizationRepository();
});

/// Provider for inventory optimization state
final inventoryOptimizationProvider = StateNotifierProvider<
    InventoryOptimizationState,
    AsyncValue<List<InventoryOptimizationModel>>>((ref) {
  return InventoryOptimizationState(ref);
});

/// State notifier for inventory optimization
class InventoryOptimizationState
    extends StateNotifier<AsyncValue<List<InventoryOptimizationModel>>> {
  InventoryOptimizationState(this._ref) : super(const AsyncLoading()) {
    _getInventoryOptimizations();
  }

  final Ref _ref;
  late final InventoryOptimizationRepository _repository =
      _ref.read(inventoryOptimizationRepositoryProvider);

  Future<List<InventoryOptimizationModel>> _getInventoryOptimizations() async {
    try {
      final optimizations = await _repository.getInventoryOptimizations();
      state = AsyncData(optimizations);
      return optimizations;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return [];
    }
  }

  Future<void> createInventoryOptimization(
      InventoryOptimizationModel optimization) async {
    try {
      state = const AsyncLoading();
      await _repository.createInventoryOptimization(optimization);
      state = AsyncData(await _getInventoryOptimizations());
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updateInventoryOptimization(
      InventoryOptimizationModel optimization) async {
    try {
      state = const AsyncLoading();
      if (optimization.id == null) {
        throw Exception('Cannot update optimization without id');
      }
      await _repository.updateInventoryOptimization(
        optimization.id!,
        optimization,
      );
      state = AsyncData(await _getInventoryOptimizations());
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> deleteInventoryOptimization(String id) async {
    try {
      state = const AsyncLoading();
      await _repository.deleteInventoryOptimization(id);
      state = AsyncData(await _getInventoryOptimizations());
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<double> calculateSafetyStock({
    required List<TimeSeriesPoint> demandHistory,
    required double leadTimeInDays,
    required double serviceLevel,
  }) async {
    try {
      final calculator = SafetyStockCalculator();
      final demandValues = demandHistory.map((point) => point.value).toList();
      return calculator.calculateSafetyStock(
        demandHistory: demandValues,
        leadTimeInDays: leadTimeInDays,
        serviceLevel: serviceLevel,
      );
    } catch (e) {
      throw Exception('Failed to calculate safety stock: $e');
    }
  }

  Future<Map<String, dynamic>> calculateReorderPoint({
    required double averageDailyDemand,
    required double leadTime,
    required double safetyStock,
  }) async {
    try {
      final rop = averageDailyDemand * leadTime + safetyStock;
      return {
        'reorderPoint': rop,
        'averageDailyDemand': averageDailyDemand,
        'leadTime': leadTime,
        'safetyStock': safetyStock,
      };
    } catch (e) {
      throw Exception('Failed to calculate reorder point: $e');
    }
  }

  Future<Map<String, dynamic>> calculateEconomicOrderQuantity({
    required double annualDemand,
    required double orderingCost,
    required double holdingCost,
  }) async {
    try {
      final eoq = math.sqrt((2 * annualDemand * orderingCost) / holdingCost);
      final annualOrderingCost = (annualDemand / eoq) * orderingCost;
      final annualHoldingCost = (eoq / 2) * holdingCost;
      final totalAnnualCost = annualOrderingCost + annualHoldingCost;

      return {
        'eoq': eoq,
        'annualOrderingCost': annualOrderingCost,
        'annualHoldingCost': annualHoldingCost,
        'totalAnnualCost': totalAnnualCost,
        'ordersPerYear': annualDemand / eoq,
      };
    } catch (e) {
      throw Exception('Failed to calculate EOQ: $e');
    }
  }
}
