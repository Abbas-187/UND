import 'package:cloud_firestore/cloud_firestore.dart';

class InventorySettingsRepository {
  InventorySettingsRepository(this.firestore);
  final FirebaseFirestore firestore;

  Future<double?> getApprovalThreshold() async {
    final doc = await firestore
        .collection('inventory_settings')
        .doc('cycle_count')
        .get();
    if (doc.exists && doc.data() != null) {
      return (doc.data()!['approvalThreshold'] as num?)?.toDouble();
    }
    return null;
  }

  Future<void> setApprovalThreshold(double threshold) async {
    await firestore.collection('inventory_settings').doc('cycle_count').set({
      'approvalThreshold': threshold,
    }, SetOptions(merge: true));
  }
}
