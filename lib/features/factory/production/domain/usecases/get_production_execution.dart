import '../../../../../core/exceptions/failure.dart';
import '../../../../../core/exceptions/result.dart';
import '../models/production_execution_model.dart';
import '../repositories/production_execution_repository.dart';

/// Use case for retrieving a specific production execution by its ID.
///
/// Follows the clean architecture pattern to encapsulate the business logic for
/// fetching a production run.
class GetProductionExecutionUseCase {

  /// Constructor that allows dependency injection of the repository
  const GetProductionExecutionUseCase(this.repository);
  final ProductionExecutionRepository repository;

  /// Executes the use case to retrieve a production execution by ID.
  ///
  /// Takes a production execution ID as input and validates it before retrieving.
  /// Returns a [Result] that either contains the [ProductionExecutionModel] or a [Failure].
  ///
  /// @param id The ID of the production execution to retrieve
  /// @return A Result containing either the execution model or a failure
  Future<Result<ProductionExecutionModel>> execute(String id) async {
    try {
      // Validate input
      if (id.isEmpty) {
        return Result.failure(
            ValidationFailure('Production execution ID cannot be empty'));
      }

      // Call repository to get the production execution
      return await repository.getProductionExecutionById(id);
    } catch (e) {
      return Result.failure(UnknownFailure(
          'Failed to retrieve production execution',
          details: e.toString()));
    }
  }
}
