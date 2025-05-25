import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/inventory_optimization_model.dart';
import '../../data/repositories/inventory_optimization_repository.dart';
import '../algorithms/safety_stock_calculator.dart';

/// Use case for calculating inventory optimization parameters
class CalculateInventoryOptimizationUseCase {
  CalculateInventoryOptimizationUseCase({
    InventoryOptimizationRepository? repository,
    SafetyStockCalculator? safetyStockCalculator,
  })  : _repository = repository ?? InventoryOptimizationRepository(),
        _safetyStockCalculator =
            safetyStockCalculator ?? SafetyStockCalculator();
  final InventoryOptimizationRepository _repository;
  final SafetyStockCalculator _safetyStockCalculator;

  /// Calculate optimal inventory parameters and save the results
  Future<String> execute({
    required String name,
    required String productId,
    required String warehouseId,
    required List<double> demandHistory,
    required double leadTime,
    required double serviceLevel,
    required double orderingCost,
    required double holdingCostPercentage,
    required double unitCost,
    double? leadTimeVariability,
  }) async {
    try {
      // Calculate safety stock
      final safetyStock = _safetyStockCalculator.calculateSafetyStock(
        demandHistory: demandHistory,
        serviceLevel: serviceLevel,
        leadTimeInDays: leadTime,
      );

      // Calculate average daily demand
      final avgDailyDemand =
          demandHistory.reduce((a, b) => a + b) / demandHistory.length;

      // Calculate reorder point
      final reorderPoint = avgDailyDemand * leadTime + safetyStock;

      // Calculate annual demand
      final annualDemand = avgDailyDemand * 365;

      // Calculate annual holding cost per unit
      final holdingCost = unitCost * holdingCostPercentage;

      // Calculate economic order quantity (EOQ)
      final eoq = math.sqrt((2 * annualDemand * orderingCost) / holdingCost);

      // Calculate annual ordering cost
      // final annualOrderingCost = (annualDemand / eoq) * orderingCost;

      // Calculate annual holding cost
      // final annualHoldingCost = (eoq / 2) * holdingCost;

      // Prepare input parameters map
      final inputParameters = {
        'productId': productId,
        'warehouseId': warehouseId,
        'leadTime': leadTime,
        'serviceLevel': serviceLevel,
        'orderingCost': orderingCost,
        'holdingCostPercentage': holdingCostPercentage,
        'unitCost': unitCost,
        'leadTimeVariability': leadTimeVariability,
        'demandHistory':
            demandHistory, // Consider if storing full history is needed
      };

      // Prepare results model
      final optimizationResult = OptimizationResultModel(
        productId: productId,
        safetyStockLevel: safetyStock,
        reorderPoint: reorderPoint,
        economicOrderQuantity: eoq,
        leadTimeAverage: leadTime, // Assuming leadTime is average
        leadTimeVariance: leadTimeVariability ?? 0.0, // Assuming 0 if null
        demandAverage: avgDailyDemand,
        demandVariance:
            _calculateVariance(demandHistory), // Use helper function
        serviceLevel: serviceLevel,
        stockoutProbability: 1.0 - serviceLevel, // Simple approximation
        holdingCost: holdingCost,
        orderingCost: orderingCost,
      );

      // Create optimization model
      final optimization = InventoryOptimizationModel(
        name: name,
        description: 'Optimization for product $productId', // Added description
        createdDate: DateTime.now(),
        createdByUserId: 'system', // Placeholder - needs actual user ID
        productIds: [productId], // Use list
        warehouseId: warehouseId,
        parameters: inputParameters, // Save input parameters
        results: {productId: optimizationResult}, // Save results map
      );

      // Save to repository
      return await _repository.createInventoryOptimization(optimization);
    } catch (e) {
      throw Exception('Failed to calculate inventory optimization: $e');
    }
  }

  /// Calculate optimal inventory parameters without saving
  Future<Map<String, dynamic>> calculateOnly({
    required List<double> demandHistory,
    required double leadTime,
    required double serviceLevel,
    required double orderingCost,
    required double holdingCostPercentage,
    required double unitCost,
    double? leadTimeVariability,
  }) async {
    try {
      // Calculate safety stock
      final safetyStock = _safetyStockCalculator.calculateSafetyStock(
        demandHistory: demandHistory,
        serviceLevel: serviceLevel,
        leadTimeInDays: leadTime,
      );

      // Calculate average daily demand
      final avgDailyDemand =
          demandHistory.reduce((a, b) => a + b) / demandHistory.length;

      // Calculate reorder point
      final reorderPoint = avgDailyDemand * leadTime + safetyStock;

      // Calculate annual demand
      final annualDemand = avgDailyDemand * 365;

      // Calculate annual holding cost per unit
      final holdingCost = unitCost * holdingCostPercentage;

      // Calculate economic order quantity (EOQ)
      final eoq = math.sqrt((2 * annualDemand * orderingCost) / holdingCost);

      // Calculate annual ordering cost
      final annualOrderingCost = (annualDemand / eoq) * orderingCost;

      // Calculate annual holding cost
      final annualHoldingCost = (eoq / 2) * holdingCost;

      return {
        'safetyStock': safetyStock,
        'reorderPoint': reorderPoint,
        'economicOrderQuantity': eoq,
        'averageDailyDemand': avgDailyDemand,
        'annualDemand': annualDemand,
        'annualOrderingCost': annualOrderingCost,
        'annualHoldingCost': annualHoldingCost,
      };
    } catch (e) {
      throw Exception('Failed to calculate inventory optimization: $e');
    }
  }

  // Helper function to calculate variance
  double _calculateVariance(List<double> values) {
    if (values.length <= 1) {
      return 0.0;
    }
    final mean = values.reduce((a, b) => a + b) / values.length;
    final sumSquaredDiffs = values.fold(0.0, (sum, value) {
      return sum + math.pow(value - mean, 2);
    });
    // Variance is sumSquaredDiffs / (n-1) for sample, or / n for population
    // Using sample variance here
    return sumSquaredDiffs / (values.length - 1);
  }
}

// Provider for CalculateInventoryOptimizationUseCase
final calculateInventoryOptimizationUseCaseProvider =
    Provider<CalculateInventoryOptimizationUseCase>((ref) {
  return CalculateInventoryOptimizationUseCase();
});
