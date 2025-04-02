import '../datasources/production_plan_data_source.dart';
import '../models/production_plan_model.dart';

/// Repository that handles production planning data operations
class ProductionPlanRepository {
  ProductionPlanRepository({
    ProductionPlanDataSource? dataSource,
  }) : _dataSource = dataSource ?? ProductionPlanDataSource();
  final ProductionPlanDataSource _dataSource;

  /// Get a list of all production plans
  Future<List<ProductionPlanModel>> getProductionPlans() async {
    try {
      return await _dataSource.getProductionPlans();
    } catch (e) {
      throw Exception('Failed to get production plans: ${e.toString()}');
    }
  }

  /// Get a specific production plan by ID
  Future<ProductionPlanModel> getProductionPlanById(String id) async {
    try {
      return await _dataSource.getProductionPlanById(id);
    } catch (e) {
      throw Exception('Failed to get production plan: ${e.toString()}');
    }
  }

  /// Create a new production plan
  Future<String> createProductionPlan(ProductionPlanModel plan) async {
    try {
      return await _dataSource.createProductionPlan(plan);
    } catch (e) {
      throw Exception('Failed to create production plan: ${e.toString()}');
    }
  }

  /// Update an existing production plan
  Future<void> updateProductionPlan(ProductionPlanModel plan) async {
    try {
      await _dataSource.updateProductionPlan(plan);
    } catch (e) {
      throw Exception('Failed to update production plan: ${e.toString()}');
    }
  }

  /// Delete a production plan
  Future<void> deleteProductionPlan(String id) async {
    try {
      await _dataSource.deleteProductionPlan(id);
    } catch (e) {
      throw Exception('Failed to delete production plan: ${e.toString()}');
    }
  }

  /// Approve a production plan
  Future<void> approveProductionPlan(String id, String approverId) async {
    try {
      await _dataSource.approveProductionPlan(id, approverId);
    } catch (e) {
      throw Exception('Failed to approve production plan: ${e.toString()}');
    }
  }

  /// Generate an optimized production plan based on forecasts and constraints
  Future<ProductionPlanModel> generateOptimizedProductionPlan({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> productIds,
    Map<String, dynamic>? constraints,
    Map<String, dynamic>? resourceAllocation,
  }) async {
    try {
      return await _dataSource.generateOptimizedProductionPlan(
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
        productIds: productIds,
        constraints: constraints,
        resourceAllocation: resourceAllocation,
      );
    } catch (e) {
      throw Exception(
          'Failed to generate optimized production plan: ${e.toString()}');
    }
  }
}

/// Provider for the production plan repository
ProductionPlanRepository provideProductionPlanRepository() {
  return ProductionPlanRepository();
}
