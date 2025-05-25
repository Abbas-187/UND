import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/exceptions/failure.dart';
import '../../../../../core/exceptions/result.dart';
import '../integration/factory_quality_control_inventory_integration_provider.dart';
import '../models/quality_control_result_model.dart';
import '../repositories/quality_control_repository.dart';

/// Use case for recording quality control results during production execution.
///
/// This class encapsulates the business logic for recording and managing
/// quality control checks during the manufacturing process.
class RecordQualityControlUseCase {
  /// Constructor that allows dependency injection of the repository
  const RecordQualityControlUseCase(this.repository);
  final QualityControlRepository repository;

  /// Records a new quality control result
  ///
  /// Takes a [QualityControlResultModel] as input and validates it before recording.
  /// Returns a [Result] with the recorded [QualityControlResultModel] or a [Failure].
  Future<Result<QualityControlResultModel>> recordQualityControlResult(
    QualityControlResultModel result, {
    required WidgetRef ref,
    required String inventoryItemId,
    String? batchLotNumber,
    required String userId,
  }) async {
    try {
      // Validate input
      if (result.batchId.isEmpty) {
        return Result.failure(ValidationFailure('Batch ID cannot be empty'));
      }

      if (result.checkpointName.isEmpty) {
        return Result.failure(
            ValidationFailure('Checkpoint name cannot be empty'));
      }

      if (result.parameters.isEmpty) {
        return Result.failure(ValidationFailure('Parameters cannot be empty'));
      }

      if (result.measurements.isEmpty) {
        return Result.failure(
            ValidationFailure('Measurements cannot be empty'));
      } // Call repository to record the quality control result
      final qcResult = await repository.recordQualityControlResult(result);
      // If successful, update inventory quality status
      if (qcResult.isSuccess) {
        final integration =
            ref.read(factoryQualityControlInventoryIntegrationProvider);
        await integration.handleQcResult(
          inventoryItemId: inventoryItemId,
          batchLotNumber: batchLotNumber,
          qcResult: qcResult.data!,
          userId: userId,
        );
      }
      return qcResult;
    } catch (e) {
      return Result.failure(UnknownFailure(
          'Failed to record quality control result',
          details: e.toString()));
    }
  }

  /// Records corrective action for a failed quality control check
  ///
  /// Takes a result ID and corrective action description.
  /// Returns a [Result] with the updated [QualityControlResultModel] or a [Failure].
  Future<Result<QualityControlResultModel>> recordCorrectiveAction(
      String resultId, String correctiveAction) async {
    try {
      // Validate input
      if (resultId.isEmpty) {
        return Result.failure(ValidationFailure('Result ID cannot be empty'));
      }

      if (correctiveAction.isEmpty) {
        return Result.failure(
            ValidationFailure('Corrective action cannot be empty'));
      }

      // Call repository to record the corrective action
      return await repository.recordCorrectiveAction(
          resultId, correctiveAction);
    } catch (e) {
      return Result.failure(UnknownFailure('Failed to record corrective action',
          details: e.toString()));
    }
  }

  /// Reviews a quality control result
  ///
  /// Takes a result ID and reviewer ID, records the review.
  /// Returns a [Result] with the updated [QualityControlResultModel] or a [Failure].
  Future<Result<QualityControlResultModel>> reviewQualityControlResult(
      String resultId, String reviewerId) async {
    try {
      // Validate input
      if (resultId.isEmpty) {
        return Result.failure(ValidationFailure('Result ID cannot be empty'));
      }

      if (reviewerId.isEmpty) {
        return Result.failure(ValidationFailure('Reviewer ID cannot be empty'));
      }

      // Call repository to record the review
      return await repository.reviewQualityControlResult(resultId, reviewerId);
    } catch (e) {
      return Result.failure(UnknownFailure(
          'Failed to review quality control result',
          details: e.toString()));
    }
  }

  /// Gets all quality control results for a batch
  ///
  /// Takes a batch ID and returns all associated quality control results.
  /// Returns a [Result] with a list of [QualityControlResultModel] or a [Failure].
  Future<Result<List<QualityControlResultModel>>>
      getQualityControlResultsForBatch(String batchId) async {
    try {
      // Validate input
      if (batchId.isEmpty) {
        return Result.failure(ValidationFailure('Batch ID cannot be empty'));
      }

      // Call repository to get quality control results for the batch
      return await repository.getQualityControlResultsByBatchId(batchId);
    } catch (e) {
      return Result.failure(UnknownFailure(
          'Failed to get quality control results',
          details: e.toString()));
    }
  }

  /// Gets all quality control results for an execution
  ///
  /// Takes an execution ID and returns all associated quality control results.
  /// Returns a [Result] with a list of [QualityControlResultModel] or a [Failure].
  Future<Result<List<QualityControlResultModel>>>
      getQualityControlResultsForExecution(String executionId) async {
    try {
      // Validate input
      if (executionId.isEmpty) {
        return Result.failure(
            ValidationFailure('Execution ID cannot be empty'));
      }

      // Call repository to get quality control results for the execution
      return await repository
          .getQualityControlResultsByExecutionId(executionId);
    } catch (e) {
      return Result.failure(UnknownFailure(
          'Failed to get quality control results',
          details: e.toString()));
    }
  }

  /// Provides a real-time stream of quality control results for a batch
  ///
  /// Takes a batch ID and returns a Stream of [QualityControlResultModel] updates.
  Stream<List<QualityControlResultModel>> watchQualityControlResultsForBatch(
      String batchId) {
    if (batchId.isEmpty) {
      throw ValidationFailure('Batch ID cannot be empty');
    }

    return repository.watchQualityControlResultsByBatchId(batchId);
  }
}
