import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/exceptions/result.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/production_batch_repository_impl.dart';
import '../../domain/models/production_batch_model.dart';
import '../../domain/repositories/production_batch_repository.dart';
import '../../domain/usecases/track_batch_process_usecase.dart';

/// Provider for the production batch repository
final productionBatchRepositoryProvider =
    Provider<ProductionBatchRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  final authRepository = ref.watch(authRepositoryProvider);
  return ProductionBatchRepositoryImpl(firestore, authRepository);
});

/// Provider for the track batch process use case
final trackBatchProcessUseCaseProvider =
    Provider<TrackBatchProcessUseCase>((ref) {
  final repository = ref.watch(productionBatchRepositoryProvider);
  return TrackBatchProcessUseCase(repository);
});

/// Provider for all batches for a specific execution
final batchesByExecutionProvider =
    FutureProvider.family<List<ProductionBatchModel>, String>(
        (ref, executionId) async {
  final repository = ref.watch(productionBatchRepositoryProvider);
  final result = await repository.getBatchesByExecutionId(executionId);

  return result.fold(
    (batches) => batches,
    (failure) => throw Exception(failure.message),
  );
});

/// Provider that streams batches for a specific execution in real-time
final watchBatchesByExecutionProvider =
    StreamProvider.family<List<ProductionBatchModel>, String>(
        (ref, executionId) {
  final repository = ref.watch(productionBatchRepositoryProvider);
  return repository.watchBatchesByExecutionId(executionId);
});

/// Provider for a single batch by its ID
final batchByIdProvider =
    FutureProvider.family<ProductionBatchModel, String>((ref, batchId) async {
  final repository = ref.watch(productionBatchRepositoryProvider);
  final result = await repository.getBatchById(batchId);

  return result.fold(
    (batch) => batch,
    (failure) => throw Exception(failure.message),
  );
});

/// Provider that streams a specific batch in real-time
final watchBatchProvider =
    StreamProvider.family<ProductionBatchModel, String>((ref, batchId) {
  final repository = ref.watch(productionBatchRepositoryProvider);
  return repository.watchBatch(batchId);
});

/// Provider to update batch process parameters
final updateBatchParametersProvider =
    FutureProvider.family<ProductionBatchModel, UpdateBatchParametersParams>(
        (ref, params) async {
  final useCase = ref.watch(trackBatchProcessUseCaseProvider);
  final result =
      await useCase.updateProcessParameters(params.batchId, params.parameters);

  return result.fold(
    (batch) => batch,
    (failure) => throw Exception(failure.message),
  );
});

/// Provider to start a batch
final startBatchProvider =
    FutureProvider.family<ProductionBatchModel, String>((ref, batchId) async {
  final useCase = ref.watch(trackBatchProcessUseCaseProvider);
  final result = await useCase.startBatchProcess(batchId);

  return result.fold(
    (batch) => batch,
    (failure) => throw Exception(failure.message),
  );
});

/// Provider to complete a batch
final completeBatchProvider =
    FutureProvider.family<ProductionBatchModel, CompleteBatchParams>(
        (ref, params) async {
  final useCase = ref.watch(trackBatchProcessUseCaseProvider);
  final result =
      await useCase.completeBatchProcess(params.batchId, params.actualQuantity);

  return result.fold(
    (batch) => batch,
    (failure) => throw Exception(failure.message),
  );
});

/// Provider to record a failed batch
final failBatchProvider =
    FutureProvider.family<ProductionBatchModel, FailBatchParams>(
        (ref, params) async {
  final useCase = ref.watch(trackBatchProcessUseCaseProvider);
  final result = await useCase.failBatchProcess(params.batchId, params.reason);

  return result.fold(
    (batch) => batch,
    (failure) => throw Exception(failure.message),
  );
});

/// Parameters class for updating batch parameters
class UpdateBatchParametersParams {
  const UpdateBatchParametersParams({
    required this.batchId,
    required this.parameters,
  });
  final String batchId;
  final Map<String, dynamic> parameters;
}

/// Parameters class for completing a batch
class CompleteBatchParams {
  const CompleteBatchParams({
    required this.batchId,
    required this.actualQuantity,
  });
  final String batchId;
  final double actualQuantity;
}

/// Parameters class for failing a batch
class FailBatchParams {
  const FailBatchParams({
    required this.batchId,
    required this.reason,
  });
  final String batchId;
  final String reason;
}
