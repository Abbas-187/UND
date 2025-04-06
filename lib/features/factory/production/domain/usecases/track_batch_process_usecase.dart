import '../../../../../core/exceptions/failure.dart';
import '../../../../../core/exceptions/result.dart';
import '../models/production_batch_model.dart';
import '../repositories/production_batch_repository.dart';

/// Use case for tracking batch process in real-time during production execution.
///
/// This class encapsulates the business logic for updating process parameters and status
/// as the batch progresses through the manufacturing process.
class TrackBatchProcessUseCase {

  /// Constructor that allows dependency injection of the repository
  const TrackBatchProcessUseCase(this.repository);
  final ProductionBatchRepository repository;

  /// Updates process parameters for a specific batch
  ///
  /// Takes a batch ID and process parameters map and updates the batch record.
  /// The parameters map can include measurements like temperature, pH, viscosity, etc.
  /// Returns a [Result] with the updated [ProductionBatchModel] or a [Failure].
  Future<Result<ProductionBatchModel>> updateProcessParameters(
      String batchId, Map<String, dynamic> parameters) async {
    try {
      // Validate input
      if (batchId.isEmpty) {
        return Result.failure(ValidationFailure('Batch ID cannot be empty'));
      }

      if (parameters.isEmpty) {
        return Result.failure(
            ValidationFailure('Process parameters cannot be empty'));
      }

      // Call repository to update the batch parameters
      return await repository.updateBatchParameters(batchId, parameters);
    } catch (e) {
      return Result.failure(UnknownFailure(
          'Failed to update process parameters',
          details: e.toString()));
    }
  }

  /// Starts tracking a batch process
  ///
  /// Takes a batch ID and updates its status to inProgress, recording the start time.
  /// Returns a [Result] with the updated [ProductionBatchModel] or a [Failure].
  Future<Result<ProductionBatchModel>> startBatchProcess(String batchId) async {
    try {
      // Validate input
      if (batchId.isEmpty) {
        return Result.failure(ValidationFailure('Batch ID cannot be empty'));
      }

      // Call repository to start the batch
      return await repository.startBatch(batchId);
    } catch (e) {
      return Result.failure(
          UnknownFailure('Failed to start batch', details: e.toString()));
    }
  }

  /// Completes a batch process
  ///
  /// Takes a batch ID and actual quantity produced, updates status to completed,
  /// and records the end time. Returns a [Result] with the updated [ProductionBatchModel] or a [Failure].
  Future<Result<ProductionBatchModel>> completeBatchProcess(
      String batchId, double actualQuantity) async {
    try {
      // Validate input
      if (batchId.isEmpty) {
        return Result.failure(ValidationFailure('Batch ID cannot be empty'));
      }

      if (actualQuantity < 0) {
        return Result.failure(
            ValidationFailure('Actual quantity cannot be negative'));
      }

      // Call repository to complete the batch with the actual quantity
      return await repository.completeBatch(batchId, actualQuantity);
    } catch (e) {
      return Result.failure(
          UnknownFailure('Failed to complete batch', details: e.toString()));
    }
  }

  /// Records a failed batch process
  ///
  /// Takes a batch ID and failure reason, updates status to failed.
  /// Returns a [Result] with the updated [ProductionBatchModel] or a [Failure].
  Future<Result<ProductionBatchModel>> failBatchProcess(
      String batchId, String reason) async {
    try {
      // Validate input
      if (batchId.isEmpty) {
        return Result.failure(ValidationFailure('Batch ID cannot be empty'));
      }

      if (reason.isEmpty) {
        return Result.failure(
            ValidationFailure('Failure reason cannot be empty'));
      }

      // Call repository to fail the batch with the reason
      return await repository.failBatch(batchId, reason);
    } catch (e) {
      return Result.failure(UnknownFailure('Failed to record batch failure',
          details: e.toString()));
    }
  }

  /// Provides a real-time stream of batch updates
  ///
  /// Takes a batch ID and returns a Stream of [ProductionBatchModel] updates.
  Stream<ProductionBatchModel> watchBatchProcess(String batchId) {
    if (batchId.isEmpty) {
      throw ValidationFailure('Batch ID cannot be empty');
    }

    return repository.watchBatch(batchId);
  }
}
