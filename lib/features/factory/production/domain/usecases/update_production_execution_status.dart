import '../../../../../core/exceptions/failure.dart';
import '../../../../../core/exceptions/result.dart';
import '../models/production_execution_model.dart';
import '../repositories/production_execution_repository.dart';

/// Use case for updating the status of a production execution.
///
/// Follows the clean architecture pattern to encapsulate the business logic for
/// changing the status of a production run (e.g., in-progress, completed, etc.).
class UpdateProductionExecutionStatusUseCase {

  /// Constructor that allows dependency injection of the repository
  const UpdateProductionExecutionStatusUseCase(this.repository);
  final ProductionExecutionRepository repository;

  /// Executes the use case to update the status of a production execution.
  ///
  /// Takes a production execution ID and new status as input and validates the status
  /// transition before updating. Returns a [Result] that either contains the updated
  /// [ProductionExecutionModel] or a [Failure].
  ///
  /// @param id The ID of the production execution to update
  /// @param status The new status to set
  /// @return A Result containing either the updated model or a failure
  Future<Result<ProductionExecutionModel>> execute(
      String id, ProductionExecutionStatus status) async {
    try {
      // Validate input
      if (id.isEmpty) {
        return Result.failure(
            ValidationFailure('Production execution ID cannot be empty'));
      }

      // Get current execution to validate state transition
      final currentExecution = await repository.getProductionExecutionById(id);

      if (currentExecution.isFailure) {
        return currentExecution;
      }

      final current = currentExecution.data!;

      // Validate status transition
      if (!_isValidStatusTransition(current.status, status)) {
        return Result.failure(ValidationFailure(
            'Invalid status transition from ${current.status} to $status'));
      }

      // Call repository to update status
      return await repository.updateProductionExecutionStatus(id, status);
    } catch (e) {
      return Result.failure(UnknownFailure(
          'Failed to update production execution status',
          details: e.toString()));
    }
  }

  /// Validates that a status transition is allowed according to business rules.
  ///
  /// The allowed transitions are:
  /// - planned -> inProgress, cancelled
  /// - inProgress -> paused, completed, failed
  /// - paused -> inProgress, cancelled
  /// - completed (terminal state)
  /// - cancelled (terminal state)
  /// - failed (terminal state)
  bool _isValidStatusTransition(
      ProductionExecutionStatus current, ProductionExecutionStatus next) {
    switch (current) {
      case ProductionExecutionStatus.planned:
        return next == ProductionExecutionStatus.inProgress ||
            next == ProductionExecutionStatus.cancelled;

      case ProductionExecutionStatus.inProgress:
        return next == ProductionExecutionStatus.paused ||
            next == ProductionExecutionStatus.completed ||
            next == ProductionExecutionStatus.failed;

      case ProductionExecutionStatus.paused:
        return next == ProductionExecutionStatus.inProgress ||
            next == ProductionExecutionStatus.cancelled;

      case ProductionExecutionStatus.completed:
      case ProductionExecutionStatus.cancelled:
      case ProductionExecutionStatus.failed:
        // Terminal states cannot transition to other states
        return false;
    }
  }
}
