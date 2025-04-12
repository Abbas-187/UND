import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/inventory_item_model.dart';
import '../models/warehouse_location_model.dart';
import '../../domain/entities/inventory_item.dart';

class InventoryRepository {
  InventoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // Implementation of interface methods
  Future<List<InventoryItem>> getItems() async {
    final snapshot = await _firestore.collection('inventory_items').get();

    return snapshot.docs
        .map((doc) => InventoryItemModel.fromFirestore(doc).toDomain())
        .toList();
  }

  Future<InventoryItem?> getItem(String id) async {
    final snapshot =
        await _firestore.collection('inventory_items').doc(id).get();

    if (!snapshot.exists) return null;

    return InventoryItemModel.fromFirestore(snapshot).toDomain();
  }

  Future<List<InventoryItemModel>> getInventoryItemsByWarehouse(
      String warehouseId) async {
    final snapshot = await _firestore
        .collection('inventory_items')
        .where('warehouseId', isEqualTo: warehouseId)
        .get();

    return snapshot.docs
        .map((doc) => InventoryItemModel.fromFirestore(doc))
        .toList();
  }

  Future<InventoryItemModel?> getInventoryItemForTransaction(
      String warehouseId, String materialId) async {
    final snapshot = await _firestore
        .collection('inventory_items')
        .where('warehouseId', isEqualTo: warehouseId)
        .where('materialId', isEqualTo: materialId)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return InventoryItemModel.fromFirestore(snapshot.docs.first);
  }

  Future<WarehouseLocationModel?> getWarehouseLocation(
      String locationId) async {
    final snapshot = await _firestore
        .collection('warehouse_locations')
        .doc(locationId)
        .get();

    if (!snapshot.exists) return null;

    return WarehouseLocationModel.fromJson(
        snapshot.data()!..['id'] = snapshot.id);
  }
}

// Manual provider implementation instead of code generation
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository();
});
