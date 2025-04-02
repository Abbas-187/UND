import '../datasources/procurement_data_source.dart';
import '../models/procurement_plan_model.dart';

/// Repository that handles procurement planning data operations
class ProcurementRepository {
  ProcurementRepository({
    ProcurementDataSource? dataSource,
  }) : _dataSource = dataSource ?? ProcurementDataSource();
  final ProcurementDataSource _dataSource;

  /// Get a list of all procurement plans
  Future<List<ProcurementPlanModel>> getProcurementPlans() async {
    try {
      return await _dataSource.getProcurementPlans();
    } catch (e) {
      throw Exception('Failed to get procurement plans: ${e.toString()}');
    }
  }

  /// Get a specific procurement plan by ID
  Future<ProcurementPlanModel> getProcurementPlanById(String id) async {
    try {
      return await _dataSource.getProcurementPlanById(id);
    } catch (e) {
      throw Exception('Failed to get procurement plan: ${e.toString()}');
    }
  }

  /// Create a new procurement plan
  Future<String> createProcurementPlan(ProcurementPlanModel plan) async {
    try {
      return await _dataSource.createProcurementPlan(plan);
    } catch (e) {
      throw Exception('Failed to create procurement plan: ${e.toString()}');
    }
  }

  /// Update an existing procurement plan
  Future<void> updateProcurementPlan(ProcurementPlanModel plan) async {
    try {
      await _dataSource.updateProcurementPlan(plan);
    } catch (e) {
      throw Exception('Failed to update procurement plan: ${e.toString()}');
    }
  }

  /// Delete a procurement plan
  Future<void> deleteProcurementPlan(String id) async {
    try {
      await _dataSource.deleteProcurementPlan(id);
    } catch (e) {
      throw Exception('Failed to delete procurement plan: ${e.toString()}');
    }
  }

  /// Approve a procurement plan
  Future<void> approveProcurementPlan(String id, String approverId) async {
    try {
      await _dataSource.approveProcurementPlan(id, approverId);
    } catch (e) {
      throw Exception('Failed to approve procurement plan: ${e.toString()}');
    }
  }

  /// Generate a procurement plan based on production plans and inventory levels
  Future<ProcurementPlanModel> generateProcurementPlan({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> productionPlanIds,
    double? budgetLimit,
  }) async {
    try {
      return await _dataSource.generateProcurementPlan(
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
        productionPlanIds: productionPlanIds,
        budgetLimit: budgetLimit,
      );
    } catch (e) {
      throw Exception('Failed to generate procurement plan: ${e.toString()}');
    }
  }
}

/// Provider for the procurement repository
ProcurementRepository provideProcurementRepository() {
  return ProcurementRepository();
}
