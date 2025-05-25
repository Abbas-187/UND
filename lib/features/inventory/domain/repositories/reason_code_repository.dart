import '../entities/reason_code.dart';

abstract class ReasonCodeRepository {
  Future<List<ReasonCode>> getReasonCodes({String? appliesTo});
  Future<void> createReasonCode(ReasonCode code);
  Future<void> updateReasonCode(ReasonCode code);
  Future<void> deleteReasonCode(String reasonCodeId);
}
