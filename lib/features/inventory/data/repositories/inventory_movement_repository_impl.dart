import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/inventory_movement_model.dart';
import 'inventory_movement_repository.dart';

/// Firestore implementation of InventoryMovementRepository
class InventoryMovementRepositoryImpl implements InventoryMovementRepository {
  InventoryMovementRepositoryImpl({
    required this.firestore,
    required this.logger,
  });

  final FirebaseFirestore firestore;
  final Logger logger;
  static const _collection = 'inventory_movements';

  @override
  Future<InventoryMovementModel> createMovement(
      InventoryMovementModel movement) async {
    final docRef = firestore.collection(_collection).doc(movement.movementId);
    final data = movement.toJson();
    await docRef.set(data);
    logger.i('Created inventory movement: ${movement.movementId}');
    return movement;
  }

  @override
  Future<InventoryMovementModel> getMovementById(String id) async {
    final doc = await firestore.collection(_collection).doc(id).get();
    if (!doc.exists) {
      throw Exception('Movement not found: $id');
    }
    final json = doc.data()!;
    return InventoryMovementModel.fromJson({
      ...json,
      'movementId': doc.id,
    });
  }

  @override
  Future<List<InventoryMovementModel>> getAllMovements() async {
    final snapshot = await firestore.collection(_collection).get();
    return snapshot.docs.map((doc) {
      final json = doc.data();
      return InventoryMovementModel.fromJson({
        ...json,
        'movementId': doc.id,
      });
    }).toList();
  }

  @override
  Future<List<InventoryMovementModel>> getMovementsByType(
      InventoryMovementType type) async {
    final snapshot = await firestore
        .collection(_collection)
        .where('movementType', isEqualTo: type.toString().split('.').last)
        .get();
    return snapshot.docs.map((doc) {
      final json = doc.data();
      return InventoryMovementModel.fromJson({
        ...json,
        'movementId': doc.id,
      });
    }).toList();
  }

  @override
  Future<List<InventoryMovementModel>> getMovementsByTimeRange(
      DateTime start, DateTime end) async {
    final snapshot = await firestore
        .collection(_collection)
        .where('timestamp', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('timestamp', isLessThanOrEqualTo: end.toIso8601String())
        .get();
    return snapshot.docs.map((doc) {
      final json = doc.data();
      return InventoryMovementModel.fromJson({
        ...json,
        'movementId': doc.id,
      });
    }).toList();
  }

  @override
  Future<List<InventoryMovementModel>> getMovementsByLocation(
      String locationId, bool isSource) async {
    final field = isSource ? 'sourceLocationId' : 'destinationLocationId';
    final snapshot = await firestore
        .collection(_collection)
        .where(field, isEqualTo: locationId)
        .get();
    return snapshot.docs.map((doc) {
      final json = doc.data();
      return InventoryMovementModel.fromJson({
        ...json,
        'movementId': doc.id,
      });
    }).toList();
  }

  @override
  Future<List<InventoryMovementModel>> getMovementsByProduct(
      String productId) async {
    final all = await getAllMovements();
    return all
        .where((m) => m.items.any((item) => item.productId == productId))
        .toList();
  }
}
