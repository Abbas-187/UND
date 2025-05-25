import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/reason_code_usecases.dart';
import 'reason_code_repository_provider.dart';

final getReasonCodesUseCaseProvider = Provider<GetReasonCodesUseCase>((ref) {
  final repo = ref.watch(reasonCodeRepositoryProvider);
  return GetReasonCodesUseCase(repo);
});

final createReasonCodeUseCaseProvider =
    Provider<CreateReasonCodeUseCase>((ref) {
  final repo = ref.watch(reasonCodeRepositoryProvider);
  return CreateReasonCodeUseCase(repo);
});

final updateReasonCodeUseCaseProvider =
    Provider<UpdateReasonCodeUseCase>((ref) {
  final repo = ref.watch(reasonCodeRepositoryProvider);
  return UpdateReasonCodeUseCase(repo);
});

final deleteReasonCodeUseCaseProvider =
    Provider<DeleteReasonCodeUseCase>((ref) {
  final repo = ref.watch(reasonCodeRepositoryProvider);
  return DeleteReasonCodeUseCase(repo);
});
