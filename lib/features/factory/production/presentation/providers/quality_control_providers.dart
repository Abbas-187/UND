import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/quality_control_repository_impl.dart';
import '../../domain/models/quality_control_result_model.dart';
import '../../domain/repositories/quality_control_repository.dart';
import '../../domain/usecases/record_quality_control_usecase.dart';

/// Provider for the quality control repository
final qualityControlRepositoryProvider =
    Provider<QualityControlRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  final authRepository = ref.watch(authRepositoryProvider);
  return QualityControlRepositoryImpl(firestore, authRepository);
});

/// Provider for the record quality control use case
final recordQualityControlUseCaseProvider =
    Provider<RecordQualityControlUseCase>((ref) {
  final repository = ref.watch(qualityControlRepositoryProvider);
  return RecordQualityControlUseCase(repository);
});

/// Provider to record a quality control result
final recordQualityControlResultProvider =
    FutureProvider.family<QualityControlResultModel, QualityControlResultModel>(
        (ref, result) async {
  final useCase = ref.watch(recordQualityControlUseCaseProvider);
  final recordResult = await useCase.recordQualityControlResult(result);

  return recordResult.fold(
    (resultModel) => resultModel,
    (failure) => throw Exception(failure.message),
  );
});

/// Provider to get quality control results for a specific batch
final qualityControlResultsByBatchProvider =
    FutureProvider.family<List<QualityControlResultModel>, String>(
        (ref, batchId) async {
  final useCase = ref.watch(recordQualityControlUseCaseProvider);
  final result = await useCase.getQualityControlResultsForBatch(batchId);

  return result.fold(
    (results) => results,
    (failure) => throw Exception(failure.message),
  );
});

/// Provider to get quality control results for a specific execution
final qualityControlResultsByExecutionProvider =
    FutureProvider.family<List<QualityControlResultModel>, String>(
        (ref, executionId) async {
  final useCase = ref.watch(recordQualityControlUseCaseProvider);
  final result =
      await useCase.getQualityControlResultsForExecution(executionId);

  return result.fold(
    (results) => results,
    (failure) => throw Exception(failure.message),
  );
});

/// Provider that streams quality control results for a batch in real-time
final watchQualityControlResultsByBatchProvider =
    StreamProvider.family<List<QualityControlResultModel>, String>(
        (ref, batchId) {
  final useCase = ref.watch(recordQualityControlUseCaseProvider);
  return useCase.watchQualityControlResultsForBatch(batchId);
});

/// Provider to record a corrective action for a quality control result
final recordCorrectiveActionProvider =
    FutureProvider.family<QualityControlResultModel, CorrectiveActionParams>(
        (ref, params) async {
  final repository = ref.watch(qualityControlRepositoryProvider);
  final result = await repository.recordCorrectiveAction(
      params.resultId, params.correctiveAction);

  return result.fold(
    (resultModel) => resultModel,
    (failure) => throw Exception(failure.message),
  );
});

/// Provider to review a quality control result
final reviewQualityControlResultProvider = FutureProvider.family<
    QualityControlResultModel, ReviewQualityControlParams>((ref, params) async {
  final repository = ref.watch(qualityControlRepositoryProvider);
  final result = await repository.reviewQualityControlResult(
      params.resultId, params.reviewedBy);

  return result.fold(
    (resultModel) => resultModel,
    (failure) => throw Exception(failure.message),
  );
});

/// Provider to get failed quality control results
final failedQualityControlResultsProvider =
    FutureProvider<List<QualityControlResultModel>>((ref) async {
  final repository = ref.watch(qualityControlRepositoryProvider);
  final result = await repository.getFailedQualityControlResults();

  return result.fold(
    (results) => results,
    (failure) => throw Exception(failure.message),
  );
});

/// Provider to get critical quality control results
final criticalQualityControlResultsProvider =
    FutureProvider<List<QualityControlResultModel>>((ref) async {
  final repository = ref.watch(qualityControlRepositoryProvider);
  final result = await repository.getCriticalQualityControlResults();

  return result.fold(
    (results) => results,
    (failure) => throw Exception(failure.message),
  );
});

/// Parameters class for recording a corrective action
class CorrectiveActionParams {
  const CorrectiveActionParams({
    required this.resultId,
    required this.correctiveAction,
  });
  final String resultId;
  final String correctiveAction;
}

/// Parameters class for reviewing a quality control result
class ReviewQualityControlParams {
  const ReviewQualityControlParams({
    required this.resultId,
    required this.reviewedBy,
  });
  final String resultId;
  final String reviewedBy;
}
