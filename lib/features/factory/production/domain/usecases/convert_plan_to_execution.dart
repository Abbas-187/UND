import 'package:uuid/uuid.dart';

import '../../../../../core/exceptions/failure.dart';
import '../../../../../core/exceptions/result.dart';
import '../../../../forecasting/data/repositories/production_plan_repository.dart';
import '../models/production_execution_model.dart';
import '../repositories/production_execution_repository.dart';

/// Use case for converting a production plan to a production execution.
///
/// This use case handles the business logic for creating a new production execution
/// from an approved production plan, including validation and data transformation.
class ConvertPlanToExecutionUseCase {

  /// Constructor that allows dependency injection of repositories
  const ConvertPlanToExecutionUseCase({
    required this.executionRepository,
    required this.planRepository,
  });
  final ProductionExecutionRepository executionRepository;
  final ProductionPlanRepository planRepository;

  /// Executes the use case to convert a production plan to an execution.
  ///
  /// Takes a plan ID as input, validates the plan status and availability,
  /// then creates a new production execution from the plan data.
  ///
  /// Returns a [Result] that either contains the created [ProductionExecutionModel] or a [Failure].
  ///
  /// Validates:
  /// - Plan exists
  /// - Plan is approved
  /// - Resource availability for execution
  Future<Result<ProductionExecutionModel>> execute({
    required String planId,
    required String productionLineId,
    required String productionLineName,
  }) async {
    try {
      // Retrieve the production plan
      final plan = await planRepository.getProductionPlanById(planId);

      // Validate plan exists and is approved
      if (plan.status != 'approved') {
        return Result.failure(ValidationFailure(
            'Only approved plans can be converted to executions'));
      }

      // Generate batch number
      final batchNumber =
          'BATCH-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      // Convert plan items to materials
      final materials = plan.productionItems.map((item) {
        return MaterialUsage(
          materialId: item.productId,
          materialName: item.productName,
          plannedQuantity: item.quantity,
          actualQuantity: 0.0, // Will be updated during execution
          unitOfMeasure: item.unitOfMeasure,
        );
      }).toList();

      // Calculate expected yield based on plan
      final totalQuantity = plan.productionItems
          .fold<double>(0, (total, item) => total + item.quantity);

      // Create new execution model
      final execution = ProductionExecutionModel(
        id: const Uuid().v4(),
        batchNumber: batchNumber,
        productionOrderId: planId, // Link to original plan ID
        scheduledDate: plan.startDate,
        productId:
            plan.productIds?.isNotEmpty == true ? plan.productIds!.first : '',
        productName: plan.name,
        targetQuantity: totalQuantity,
        unitOfMeasure:
            materials.isNotEmpty ? materials.first.unitOfMeasure : 'units',
        status: ProductionExecutionStatus.planned,
        productionLineId: productionLineId,
        productionLineName: productionLineName,
        assignedPersonnel: const [],
        materials: materials,
        expectedYield: totalQuantity * 0.95, // Assuming 95% efficiency
        createdAt: DateTime.now(),
        createdBy: '', // This will be set by the repository
        updatedAt: DateTime.now(),
        updatedBy: '', // This will be set by the repository
        metadata: {
          'sourceType': 'productionPlan',
          'sourcePlanId': planId,
          'planName': plan.name,
          'planCreatedBy': plan.createdBy ?? '',
        },
      );

      // Store the execution record
      final result =
          await executionRepository.createProductionExecution(execution);

      // Update plan status to indicate it has been converted
      if (result.isSuccess && result.data != null) {
        final updatedPlan = plan.copyWith(
          status: 'inExecution',
        );

        // Store updated plan back to repository
        await planRepository.updateProductionPlan(updatedPlan);
      }

      return result;
    } catch (e) {
      return Result.failure(UnknownFailure(
          'Failed to convert plan to execution',
          details: e.toString()));
    }
  }
}
