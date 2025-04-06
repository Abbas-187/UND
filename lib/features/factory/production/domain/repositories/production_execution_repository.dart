import '../../../../../core/exceptions/result.dart';
import '../models/production_execution_model.dart';

/// Repository interface for production execution operations in a dairy factory
abstract class ProductionExecutionRepository {
  /// Creates a new production execution record
  Future<Result<ProductionExecutionModel>> createProductionExecution(
      ProductionExecutionModel execution);

  /// Retrieves a production execution by its ID
  Future<Result<ProductionExecutionModel>> getProductionExecutionById(
      String id);

  /// Queries production executions with optional filtering parameters
  ///
  /// Can filter by date range, status, product ID, and production line
  Future<Result<List<ProductionExecutionModel>>> queryProductionExecutions({
    DateTime? startDate,
    DateTime? endDate,
    ProductionExecutionStatus? status,
    String? productId,
    String? productionLineId,
    String? searchQuery,
  });

  /// Updates an existing production execution record
  Future<Result<ProductionExecutionModel>> updateProductionExecution(
      ProductionExecutionModel execution);

  /// Updates the status of a production execution
  Future<Result<ProductionExecutionModel>> updateProductionExecutionStatus(
      String id, ProductionExecutionStatus status);

  /// Updates the actual yield and efficiency of a production execution
  Future<Result<ProductionExecutionModel>> updateProductionYield(
      String id, double actualYield, double? yieldEfficiency);

  /// Updates material usage in a production execution
  Future<Result<ProductionExecutionModel>> updateMaterialUsage(
      String id, List<MaterialUsage> materials);

  /// Updates assigned personnel in a production execution
  Future<Result<ProductionExecutionModel>> updateAssignedPersonnel(
      String id, List<AssignedPersonnel> personnel);

  /// Updates the quality metrics of a completed production run
  Future<Result<ProductionExecutionModel>> updateQualityMetrics(
      String id, QualityRating rating, String? qualityNotes);

  /// Starts a production execution, updating its status and recording start time
  Future<Result<ProductionExecutionModel>> startProductionExecution(String id);

  /// Pauses an in-progress production execution
  Future<Result<ProductionExecutionModel>> pauseProductionExecution(String id);

  /// Resumes a paused production execution
  Future<Result<ProductionExecutionModel>> resumeProductionExecution(String id);

  /// Completes a production execution, recording end time and final data
  Future<Result<ProductionExecutionModel>> completeProductionExecution(
    String id, {
    double? actualYield,
    QualityRating? qualityRating,
    String? qualityNotes,
  });

  /// Cancels a production execution
  Future<Result<ProductionExecutionModel>> cancelProductionExecution(
      String id, String reason);

  /// Provides a real-time stream of changes to a specific production execution
  Stream<ProductionExecutionModel> watchProductionExecution(String id);

  /// Provides a real-time stream of currently active production executions
  Stream<List<ProductionExecutionModel>> watchActiveProductionExecutions();

  /// Gets production executions scheduled for today
  Future<Result<List<ProductionExecutionModel>>>
      getTodaysProductionExecutions();

  /// Gets all production executions for a specific product
  Future<Result<List<ProductionExecutionModel>>>
      getProductionExecutionsForProduct(String productId);

  /// Gets all production executions using a specific production line
  Future<Result<List<ProductionExecutionModel>>> getProductionExecutionsForLine(
      String productionLineId);

  /// Gets all production executions linked to a specific production plan
  Future<List<ProductionExecutionModel>> getProductionExecutionsByPlanId(
      String planId);

  /// Gets production efficiency statistics for a given period
  ///
  /// Returns a map with product IDs as keys and efficiency percentages as values
  Future<Result<Map<String, double>>> getProductionEfficiencyStats(
      DateTime startDate, DateTime endDate);

  /// Gets production output statistics for a given period
  ///
  /// Returns a map with product IDs as keys and total output quantities as values
  Future<Result<Map<String, double>>> getProductionOutputStats(
      DateTime startDate, DateTime endDate);

  /// Deletes a production execution (for administrative purposes only)
  Future<Result<void>> deleteProductionExecution(String id);
}
