// inventory_repository_impl.dart (commented out for testing)
/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/inventory_item_model.dart';
import '../models/warehouse_location_model.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl({FirebaseFirestore? firestore})
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

  /// Allocates inventory based on a BOM
  Future<bool> allocateInventoryForBom(String bomId, double batchSize) async {
    // Fetch the BOM ingredients
    final ingredients = await getBomIngredients(bomId);

    for (final ingredient in ingredients) {
      final requiredQuantity = ingredient['quantity'] * batchSize;
      final itemId = ingredient['itemId'];

      // Check if enough inventory is available
      final item = await getItemById(itemId);
      if (item == null || item.quantity < requiredQuantity) {
        return false; // Not enough inventory
      }

      // Deduct the required quantity
      await adjustQuantity(itemId, -requiredQuantity, 'Allocated for BOM $bomId');
    }

    return true;
  }

  /// Get BOM ingredients (placeholder implementation)
  Future<List<Map<String, dynamic>>> getBomIngredients(String bomId) async {
    // This should be implemented to fetch BOM ingredients from the BOM module
    // For now, return empty list
    return [];
  }
}

// Manual provider implementation instead of code generation
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl();
});
*/
