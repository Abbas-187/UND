import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/audit_record_model.dart';
import 'inventory_audit_repository.dart';

/// Firestore implementation of InventoryAuditRepository
class InventoryAuditRepositoryImpl implements InventoryAuditRepository {
  InventoryAuditRepositoryImpl({
    required this.firestore,
  });

  final FirebaseFirestore firestore;
  static const _collection = 'inventory_audit_records';

  @override
  Future<void> createRecord(AuditRecord record) async {
    final docRef = firestore.collection(_collection).doc(record.recordId);
    await docRef.set(record.toJson());
  }

  @override
  Future<List<AuditRecord>> getRecordsByMovement(String movementId) async {
    final snapshot = await firestore
        .collection(_collection)
        .where('movementId', isEqualTo: movementId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final json = doc.data();
      return AuditRecord.fromJson({
        ...json,
        'recordId': doc.id,
      });
    }).toList();
  }
}
