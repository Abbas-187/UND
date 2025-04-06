import '../../../../../core/exceptions/result.dart';
import '../models/production_batch_model.dart';

/// Repository interface for production batch operations
abstract class ProductionBatchRepository {
  /// Creates a new production batch
  Future<Result<ProductionBatchModel>> createBatch(ProductionBatchModel batch);

  /// Gets a batch by its ID
  Future<Result<ProductionBatchModel>> getBatchById(String id);

  /// Gets all batches for a specific execution
  Future<Result<List<ProductionBatchModel>>> getBatchesByExecutionId(
      String executionId);

  /// Updates an existing batch
  Future<Result<ProductionBatchModel>> updateBatch(ProductionBatchModel batch);

  /// Updates the status of a batch
  Future<Result<ProductionBatchModel>> updateBatchStatus(
      String id, BatchStatus status);

  /// Records the start of a batch, setting status to inProgress
  Future<Result<ProductionBatchModel>> startBatch(String id);

  /// Records the completion of a batch with actual quantities
  Future<Result<ProductionBatchModel>> completeBatch(
      String id, double actualQuantity);

  /// Records a failed batch with reason
  Future<Result<ProductionBatchModel>> failBatch(String id, String reason);

  /// Updates batch process parameters
  Future<Result<ProductionBatchModel>> updateBatchParameters(
      String id, Map<String, dynamic> parameters);

  /// Gets a real-time stream of batch updates
  Stream<ProductionBatchModel> watchBatch(String id);

  /// Gets a real-time stream of all batches for an execution
  Stream<List<ProductionBatchModel>> watchBatchesByExecutionId(
      String executionId);

  /// Gets batches created within a date range
  Future<Result<List<ProductionBatchModel>>> getBatchesByDateRange(
      DateTime startDate, DateTime endDate);

  /// Gets batches by product ID
  Future<Result<List<ProductionBatchModel>>> getBatchesByProductId(
      String productId);

  /// Deletes a batch (for administrative purposes only)
  Future<Result<void>> deleteBatch(String id);
}
