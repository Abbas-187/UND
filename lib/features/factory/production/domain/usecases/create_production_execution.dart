import '../../../../../core/exceptions/failure.dart';
import '../../../../../core/exceptions/result.dart';
import '../models/production_execution_model.dart';
import '../repositories/production_execution_repository.dart';

/// Use case for creating a new production execution.
///
/// Follows the clean architecture pattern to encapsulate the business logic for
/// starting a new production run.
class CreateProductionExecutionUseCase {

  /// Constructor that allows dependency injection of the repository
  const CreateProductionExecutionUseCase(this.repository);
  final ProductionExecutionRepository repository;

  /// Executes the use case to create a new production execution.
  ///
  /// Takes a [ProductionExecutionModel] as input and validates it before passing to the repository.
  /// Returns a [Result] that either contains the created [ProductionExecutionModel] or a [Failure].
  ///
  /// Validates:
  /// - Batch number is not empty
  /// - Production order ID is not empty
  /// - Product ID and name are not empty
  /// - Target quantity is greater than zero
  /// - Production line ID is specified
  Future<Result<ProductionExecutionModel>> execute(
      ProductionExecutionModel execution) async {
    try {
      // Validate input
      if (execution.batchNumber.isEmpty) {
        return Result.failure(
            ValidationFailure('Batch number cannot be empty'));
      }

      if (execution.productionOrderId.isEmpty) {
        return Result.failure(
            ValidationFailure('Production order ID cannot be empty'));
      }

      if (execution.productId.isEmpty || execution.productName.isEmpty) {
        return Result.failure(
            ValidationFailure('Product details cannot be empty'));
      }

      if (execution.targetQuantity <= 0) {
        return Result.failure(
            ValidationFailure('Target quantity must be greater than zero'));
      }

      if (execution.productionLineId.isEmpty) {
        return Result.failure(
            ValidationFailure('Production line must be specified'));
      }

      // Ensure status is set to planned initially
      final validExecution = execution.copyWith(
        status: ProductionExecutionStatus.planned,
      );

      // Call repository to create the production execution
      return await repository.createProductionExecution(validExecution);
    } catch (e) {
      return Result.failure(UnknownFailure(
          'Failed to create production execution',
          details: e.toString()));
    }
  }
}
