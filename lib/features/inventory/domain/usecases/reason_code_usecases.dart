import '../entities/reason_code.dart';
import '../repositories/reason_code_repository.dart';

class GetReasonCodesUseCase {
  GetReasonCodesUseCase(this.repository);
  final ReasonCodeRepository repository;

  Future<List<ReasonCode>> call({String? appliesTo}) {
    return repository.getReasonCodes(appliesTo: appliesTo);
  }
}

class CreateReasonCodeUseCase {
  CreateReasonCodeUseCase(this.repository);
  final ReasonCodeRepository repository;

  Future<void> call(ReasonCode code) {
    return repository.createReasonCode(code);
  }
}

class UpdateReasonCodeUseCase {
  UpdateReasonCodeUseCase(this.repository);
  final ReasonCodeRepository repository;

  Future<void> call(ReasonCode code) {
    return repository.updateReasonCode(code);
  }
}

class DeleteReasonCodeUseCase {
  DeleteReasonCodeUseCase(this.repository);
  final ReasonCodeRepository repository;

  Future<void> call(String reasonCodeId) {
    return repository.deleteReasonCode(reasonCodeId);
  }
}
