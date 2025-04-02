import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/production_plan_model.dart';
import '../../data/repositories/production_plan_repository.dart';

/// Provider for production plan repository
final productionPlanRepositoryProvider =
    Provider<ProductionPlanRepository>((ref) {
  return ProductionPlanRepository();
});

/// Provider for production planning state
final productionPlanningProvider = StateNotifierProvider<
    ProductionPlanningState, AsyncValue<List<ProductionPlanModel>>>((ref) {
  return ProductionPlanningState(ref);
});

/// State notifier for production planning
class ProductionPlanningState
    extends StateNotifier<AsyncValue<List<ProductionPlanModel>>> {
  ProductionPlanningState(this._ref) : super(const AsyncLoading()) {
    _getProductionPlans();
  }

  final Ref _ref;
  late final ProductionPlanRepository _repository =
      _ref.read(productionPlanRepositoryProvider);

  Future<List<ProductionPlanModel>> _getProductionPlans() async {
    try {
      final plans = await _repository.getProductionPlans();
      state = AsyncData(plans);
      return plans;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return [];
    }
  }

  Future<void> createProductionPlan(ProductionPlanModel plan) async {
    try {
      state = const AsyncLoading();
      await _repository.createProductionPlan(plan);
      state = AsyncData(await _getProductionPlans());
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updateProductionPlan(ProductionPlanModel plan) async {
    try {
      state = const AsyncLoading();
      await _repository.updateProductionPlan(plan);
      state = AsyncData(await _getProductionPlans());
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> deleteProductionPlan(String id) async {
    try {
      state = const AsyncLoading();
      await _repository.deleteProductionPlan(id);
      state = AsyncData(await _getProductionPlans());
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  /// Calculate resource utilization for a production plan
  Future<Map<String, double>> calculateResourceUtilization(
      ProductionPlanModel plan) async {
    try {
      final utilization = <String, double>{};

      // Assume default values if resource requirements are not specified
      final int numWorkers = 5; // Default number of workers

      // Define capacity for each resource
      final resourceCapacity = {
        'labor': 8 * 60 * numWorkers, // worker-minutes available per day
        'machine': 24 * 60, // machine-minutes available per day
      };

      // Calculate total time required for each resource
      // Assume 1 hour per unit as default production time
      final resourceUsage = {
        'labor': plan.productionItems
            .fold(0.0, (sum, item) => sum + 1.0 * item.quantity),
        'machine': plan.productionItems
            .fold(0.0, (sum, item) => sum + 0.5 * item.quantity),
      };

      // Calculate utilization percentage for each resource
      resourceCapacity.forEach((resource, capacity) {
        final usage = resourceUsage[resource] ?? 0.0;
        utilization[resource] = (usage / capacity) * 100;
      });

      return utilization;
    } catch (e) {
      throw Exception('Failed to calculate resource utilization: $e');
    }
  }

  /// Generate an optimized production schedule based on demand and constraints
  Future<List<Map<String, dynamic>>> generateProductionSchedule(
    List<Map<String, dynamic>> demandForecast,
    Map<String, dynamic> resourceConstraints,
  ) async {
    try {
      // This would be a complex algorithm in production
      // Simplified version:
      final schedule = <Map<String, dynamic>>[];

      for (final demand in demandForecast) {
        schedule.add({
          'productId': demand['productId'],
          'quantity': demand['quantity'],
          'startDate': demand['date'],
          'endDate': demand[
              'date'], // Simplified - would calculate based on processing time
          'resources': {
            'labor':
                demand['quantity'] * 10, // Simplified - 10 minutes per unit
            'machine':
                demand['quantity'] * 5, // Simplified - 5 minutes per unit
          },
        });
      }

      return schedule;
    } catch (e) {
      throw Exception('Failed to generate production schedule: $e');
    }
  }
}
