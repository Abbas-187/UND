import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../core/exceptions/failure.dart';
import '../../../../../core/exceptions/result.dart';
import '../../../../forecasting/domain/providers/production_planning_provider.dart';
import '../../domain/models/production_execution_model.dart';
import '../../domain/usecases/convert_plan_to_execution.dart';
import 'production_execution_providers.dart';

// TODO: Generate this file with:
// flutter pub run build_runner build --delete-conflicting-outputs
part 'production_integration_providers.g.dart';

/// Provider for the ConvertPlanToExecutionUseCase
@riverpod
ConvertPlanToExecutionUseCase convertPlanToExecutionUseCase(
    ConvertPlanToExecutionUseCaseRef ref) {
  final executionRepository = ref.watch(productionExecutionRepositoryProvider);
  final planRepository = ref.watch(productionPlanRepositoryProvider);

  return ConvertPlanToExecutionUseCase(
    executionRepository: executionRepository,
    planRepository: planRepository,
  );
}

/// State controller for integration between production planning and execution
@riverpod
class ProductionIntegrationController
    extends _$ProductionIntegrationController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  /// Convert a production plan to an execution
  ///
  /// Takes the plan ID and production line information to create a new execution
  /// record based on the plan data.
  Future<Result<ProductionExecutionModel>> convertPlanToExecution({
    required String planId,
    required String productionLineId,
    required String productionLineName,
  }) async {
    state = const AsyncLoading();

    try {
      final useCase = ref.read(convertPlanToExecutionUseCaseProvider);

      final result = await useCase.execute(
        planId: planId,
        productionLineId: productionLineId,
        productionLineName: productionLineName,
      );

      if (result.isSuccess) {
        state = const AsyncData(null);
      } else {
        state = AsyncError(result.failure!, StackTrace.current);
      }

      return result;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      return Result.failure(UnknownFailure(
        'Failed to convert plan to execution',
        details: e.toString(),
      ));
    }
  }

  /// Fetch executions created from a specific production plan
  Future<List<ProductionExecutionModel>> getExecutionsFromPlan(
      String planId) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(productionExecutionRepositoryProvider);
      final executions =
          await repository.getProductionExecutionsByPlanId(planId);

      state = const AsyncData(null);
      return executions;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      return [];
    }
  }
}

/// Provider to check if a production plan can be converted to execution
@riverpod
Future<bool> canConvertPlanToExecution(
    CanConvertPlanToExecutionRef ref, String planId) async {
  try {
    // Get the plan repository
    final planRepository = ref.watch(productionPlanRepositoryProvider);

    // Get the plan details
    final plan = await planRepository.getProductionPlanById(planId);

    // Check if plan is in the right state to be converted
    return plan.status == 'approved';
  } catch (e) {
    return false;
  }
}
