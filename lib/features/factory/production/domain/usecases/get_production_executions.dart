import '../../../../../core/exceptions/failure.dart';
import '../../../../../core/exceptions/result.dart';
import '../models/production_execution_model.dart';
import '../repositories/production_execution_repository.dart';

/// Use case for querying production executions with filters.
///
/// Follows the clean architecture pattern to encapsulate the business logic for
/// retrieving production runs based on various criteria.
class GetProductionExecutionsUseCase {

  /// Constructor that allows dependency injection of the repository
  const GetProductionExecutionsUseCase(this.repository);
  final ProductionExecutionRepository repository;

  /// Executes the use case to query production executions with optional filters.
  ///
  /// Takes optional filter parameters and validates them before querying.
  /// Returns a [Result] that either contains a list of [ProductionExecutionModel] or a [Failure].
  ///
  /// @param startDate Optional start date for filtering executions
  /// @param endDate Optional end date for filtering executions
  /// @param status Optional status for filtering executions
  /// @param productId Optional product ID for filtering executions
  /// @param productionLineId Optional production line ID for filtering executions
  /// @param searchQuery Optional search query for filtering executions
  /// @return A Result containing either a list of execution models or a failure
  Future<Result<List<ProductionExecutionModel>>> execute({
    DateTime? startDate,
    DateTime? endDate,
    ProductionExecutionStatus? status,
    String? productId,
    String? productionLineId,
    String? searchQuery,
  }) async {
    try {
      // Validate date range if both dates are provided
      if (startDate != null && endDate != null) {
        if (endDate.isBefore(startDate)) {
          return Result.failure(
              ValidationFailure('End date must be after start date'));
        }
      }

      // Validate product ID if provided
      if (productId != null && productId.isEmpty) {
        return Result.failure(ValidationFailure('Product ID cannot be empty'));
      }

      // Validate production line ID if provided
      if (productionLineId != null && productionLineId.isEmpty) {
        return Result.failure(
            ValidationFailure('Production line ID cannot be empty'));
      }

      // Call repository to query production executions
      return await repository.queryProductionExecutions(
        startDate: startDate,
        endDate: endDate,
        status: status,
        productId: productId,
        productionLineId: productionLineId,
        searchQuery: searchQuery,
      );
    } catch (e) {
      return Result.failure(UnknownFailure(
          'Failed to query production executions',
          details: e.toString()));
    }
  }
}
