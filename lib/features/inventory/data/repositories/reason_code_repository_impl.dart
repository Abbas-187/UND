import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/reason_code.dart';
import '../../domain/repositories/reason_code_repository.dart';

class ReasonCodeRepositoryImpl implements ReasonCodeRepository {
  ReasonCodeRepositoryImpl(this.firestore);
  final FirebaseFirestore firestore;

  @override
  Future<List<ReasonCode>> getReasonCodes({String? appliesTo}) async {
    Query<Map<String, dynamic>> query = firestore.collection('reason_codes');
    if (appliesTo != null) {
      query = query.where('appliesTo', isEqualTo: appliesTo);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map(
            (doc) => ReasonCode.fromJson(doc.data()..['reasonCodeId'] = doc.id))
        .toList();
  }

  @override
  Future<void> createReasonCode(ReasonCode code) async {
    await firestore.collection('reason_codes').add(code.toJson());
  }

  @override
  Future<void> updateReasonCode(ReasonCode code) async {
    await firestore
        .collection('reason_codes')
        .doc(code.reasonCodeId)
        .set(code.toJson());
  }

  @override
  Future<void> deleteReasonCode(String reasonCodeId) async {
    // Implement logic to delete a reason code
    // This is a placeholder implementation
    throw UnimplementedError('deleteReasonCode is not implemented yet.');
  }
}
