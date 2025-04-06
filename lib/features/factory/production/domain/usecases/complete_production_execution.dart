import '../../../../../core/exceptions/failure.dart';
import '../../../../../core/exceptions/result.dart';
import '../models/production_execution_model.dart';
import '../repositories/production_execution_repository.dart';

/// Use case for completing a production execution with final data.
///
/// Follows the clean architecture pattern to encapsulate the business logic for
/// finalizing a production run with actual yield and quality assessment.
class CompleteProductionExecutionUseCase {

  /// Constructor that allows dependency injection of the repository
  const CompleteProductionExecutionUseCase(this.repository);
  final ProductionExecutionRepository repository;

  /// Executes the use case to complete a production execution.
  ///
  /// Takes a production execution ID and completion data as input and validates before completing.
  /// Returns a [Result] that either contains the completed [ProductionExecutionModel] or a [Failure].
  ///
  /// @param id The ID of the production execution to complete
  /// @param actualYield The actual yield from the production run
  /// @param qualityRating The quality rating of the produced product
  /// @param qualityNotes Optional notes about quality assessment
  /// @return A Result containing either the completed model or a failure
  Future<Result<ProductionExecutionModel>> execute(
    String id, {
    required double actualYield,
    required QualityRating qualityRating,
    String? qualityNotes,
  }) async {
    try {
      // Validate input
      if (id.isEmpty) {
        return Result.failure(
            ValidationFailure('Production execution ID cannot be empty'));
      }

      if (actualYield < 0) {
        return Result.failure(
            ValidationFailure('Actual yield cannot be negative'));
      }

      // Get current execution to validate state
      final currentExecution = await repository.getProductionExecutionById(id);

      if (currentExecution.isFailure) {
        return currentExecution;
      }

      final current = currentExecution.data!;

      // Validate current status - only in-progress executions can be completed
      if (current.status != ProductionExecutionStatus.inProgress) {
        return Result.failure(ValidationFailure(
            'Only in-progress executions can be completed. Current status: ${current.status}'));
      }

      // Calculate yield efficiency if expected yield is available
      double? yieldEfficiency;
      if (current.expectedYield > 0) {
        yieldEfficiency = (actualYield / current.expectedYield) * 100;
      }

      // Call repository to complete the production execution
      return await repository.completeProductionExecution(
        id,
        actualYield: actualYield,
        qualityRating: qualityRating,
        qualityNotes: qualityNotes,
      );
    } catch (e) {
      return Result.failure(UnknownFailure(
          'Failed to complete production execution',
          details: e.toString()));
    }
  }
}
