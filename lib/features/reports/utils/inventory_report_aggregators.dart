import 'package:cloud_firestore/cloud_firestore.dart';
import '../../inventory/data/models/inventory_item_model.dart';
import '../../inventory/data/models/inventory_movement_model.dart';
import 'report_aggregators.dart';

class InventoryReportAggregators extends ReportAggregators {
  InventoryReportAggregators({
    required FirebaseFirestore firestore,
  }) : super(firestore);

  /// Get inventory items from Firestore
  Future<List<InventoryItemModel>> getInventoryItems() async {
    final snapshot = await firestore.collection('inventory_items').get();
    return snapshot.docs
        .map((doc) => InventoryItemModel.fromFirestore(doc))
        .toList();
  }

  /// Get inventory movements from Firestore
  Future<List<InventoryMovementModel>> getInventoryMovements() async {
    final snapshot = await firestore.collection('inventory_movements').get();
    return snapshot.docs
        .map((doc) => InventoryMovementModel.fromJson(doc.data()))
        .toList();
  }
}
