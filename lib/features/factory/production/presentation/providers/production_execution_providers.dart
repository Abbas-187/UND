import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../production/domain/models/production_execution_model.dart';
import '../../../production/domain/repositories/production_execution_repository.dart';
import '../../../production/domain/usecases/complete_production_execution.dart';
import '../../../production/domain/usecases/create_production_execution.dart';
import '../../../production/domain/usecases/get_production_execution.dart';
import '../../../production/domain/usecases/get_production_executions.dart';
import '../../../production/domain/usecases/update_production_execution_status.dart';

part 'production_execution_providers.g.dart';

/// Provider for the production execution repository interface
/// This needs to be overridden in the data layer with the actual implementation
@riverpod
ProductionExecutionRepository productionExecutionRepository(
    ProductionExecutionRepositoryRef ref) {
  throw UnimplementedError(
      'You need to override this provider in the data layer');
}

/// Provider for the GetProductionExecutionsUseCase
@riverpod
GetProductionExecutionsUseCase getProductionExecutionsUseCase(
    GetProductionExecutionsUseCaseRef ref) {
  final repository = ref.watch(productionExecutionRepositoryProvider);
  return GetProductionExecutionsUseCase(repository);
}

/// Provider for the GetProductionExecutionUseCase
@riverpod
GetProductionExecutionUseCase getProductionExecutionUseCase(
    GetProductionExecutionUseCaseRef ref) {
  final repository = ref.watch(productionExecutionRepositoryProvider);
  return GetProductionExecutionUseCase(repository);
}

/// Provider for the UpdateProductionExecutionStatusUseCase
@riverpod
UpdateProductionExecutionStatusUseCase updateProductionExecutionStatusUseCase(
    UpdateProductionExecutionStatusUseCaseRef ref) {
  final repository = ref.watch(productionExecutionRepositoryProvider);
  return UpdateProductionExecutionStatusUseCase(repository);
}

/// Provider for the CompleteProductionExecutionUseCase
@riverpod
CompleteProductionExecutionUseCase completeProductionExecutionUseCase(
    CompleteProductionExecutionUseCaseRef ref) {
  final repository = ref.watch(productionExecutionRepositoryProvider);
  return CompleteProductionExecutionUseCase(repository);
}

/// Provider for the CreateProductionExecutionUseCase
@riverpod
CreateProductionExecutionUseCase createProductionExecutionUseCase(
    CreateProductionExecutionUseCaseRef ref) {
  final repository = ref.watch(productionExecutionRepositoryProvider);
  return CreateProductionExecutionUseCase(repository);
}

/// StreamProvider for a list of production executions with filtering
@riverpod
Stream<List<ProductionExecutionModel>> productionExecutions(
  ProductionExecutionsRef ref, {
  DateTime? startDate,
  DateTime? endDate,
  ProductionExecutionStatus? status,
  String? productId,
  String? productionLineId,
  String? searchQuery,
}) {
  final repository = ref.watch(productionExecutionRepositoryProvider);

  // If no filters are provided, watch all executions
  if (startDate == null &&
      endDate == null &&
      status == null &&
      productId == null &&
      productionLineId == null &&
      (searchQuery == null || searchQuery.isEmpty)) {
    // First fetch with repository query then setup a stream
    return repository.watchActiveProductionExecutions();
  }

  // When watching filtered executions, we need a different approach
  // Since we don't have a direct stream with filters in the repository,
  // we'll set up a periodic refresh or combine with snapshots

  // This is a simplified approach - in a real app, you might want to:
  // 1. Set up a Stream.periodic to refresh data
  // 2. Or use a more sophisticated stream transformation

  // For this implementation, we'll use the watchActiveProductionExecutions stream
  // and filter in-memory
  return repository.watchActiveProductionExecutions().map((executions) {
    // Apply filters in memory
    return executions.where((execution) {
      bool matches = true;

      if (startDate != null) {
        matches = matches && execution.scheduledDate.isAfter(startDate);
      }

      if (endDate != null) {
        matches = matches && execution.scheduledDate.isBefore(endDate);
      }

      if (status != null) {
        matches = matches && execution.status == status;
      }

      if (productId != null) {
        matches = matches && execution.productId == productId;
      }

      if (productionLineId != null) {
        matches = matches && execution.productionLineId == productionLineId;
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        matches = matches &&
            (execution.productName.toLowerCase().contains(query) ||
                execution.batchNumber.toLowerCase().contains(query));
      }

      return matches;
    }).toList();
  });
}

/// Derived provider for only active production executions
@riverpod
Stream<List<ProductionExecutionModel>> activeProductionExecutions(
    ActiveProductionExecutionsRef ref) {
  final repository = ref.watch(productionExecutionRepositoryProvider);
  return repository.watchActiveProductionExecutions();
}

/// Provider family for a single production execution by ID
@riverpod
Stream<ProductionExecutionModel> productionExecution(
    ProductionExecutionRef ref, String id) {
  final repository = ref.watch(productionExecutionRepositoryProvider);
  return repository.watchProductionExecution(id);
}

/// StateNotifier provider for managing production execution state
@riverpod
class ProductionExecutionController extends _$ProductionExecutionController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  /// Create a new production execution
  Future<void> createExecution(ProductionExecutionModel execution) async {
    final createUseCase = ref.read(createProductionExecutionUseCaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await createUseCase.execute(execution);
      if (result.isFailure) {
        throw result.failure!;
      }
      return;
    });
  }

  /// Update an existing production execution
  Future<void> updateExecution(ProductionExecutionModel execution) async {
    final repository = ref.read(productionExecutionRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await repository.updateProductionExecution(execution);
      if (result.isFailure) {
        throw result.failure!;
      }
      return;
    });
  }

  /// Delete a production execution
  Future<void> deleteExecution(String id) async {
    final repository = ref.read(productionExecutionRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await repository.deleteProductionExecution(id);
      if (result.isFailure) {
        throw result.failure!;
      }
      return;
    });
  }

  /// Start a production execution
  Future<void> startExecution(String id) async {
    final repository = ref.read(productionExecutionRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await repository.startProductionExecution(id);
      if (result.isFailure) {
        throw result.failure!;
      }
      return;
    });
  }

  /// Pause a production execution
  Future<void> pauseExecution(String id) async {
    final repository = ref.read(productionExecutionRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await repository.pauseProductionExecution(id);
      if (result.isFailure) {
        throw result.failure!;
      }
      return;
    });
  }

  /// Resume a production execution
  Future<void> resumeExecution(String id) async {
    final repository = ref.read(productionExecutionRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await repository.resumeProductionExecution(id);
      if (result.isFailure) {
        throw result.failure!;
      }
      return;
    });
  }

  /// Complete a production execution
  Future<void> completeExecution(
    String id, {
    double? actualYield,
    QualityRating? qualityRating,
    String? qualityNotes,
  }) async {
    final repository = ref.read(productionExecutionRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await repository.completeProductionExecution(
        id,
        actualYield: actualYield,
        qualityRating: qualityRating,
        qualityNotes: qualityNotes,
      );
      if (result.isFailure) {
        throw result.failure!;
      }
      return;
    });
  }

  /// Cancel a production execution
  Future<void> cancelExecution(String id, String reason) async {
    final repository = ref.read(productionExecutionRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await repository.cancelProductionExecution(id, reason);
      if (result.isFailure) {
        throw result.failure!;
      }
      return;
    });
  }

  /// Update the material usage in a production execution
  Future<void> updateMaterialUsage(
      String id, List<MaterialUsage> materials) async {
    final repository = ref.read(productionExecutionRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await repository.updateMaterialUsage(id, materials);
      if (result.isFailure) {
        throw result.failure!;
      }
      return;
    });
  }

  /// Update personnel assignments in a production execution
  Future<void> updatePersonnel(
      String id, List<AssignedPersonnel> personnel) async {
    final repository = ref.read(productionExecutionRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await repository.updateAssignedPersonnel(id, personnel);
      if (result.isFailure) {
        throw result.failure!;
      }
      return;
    });
  }
}
