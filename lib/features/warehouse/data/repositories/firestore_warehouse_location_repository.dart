import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/warehouse_location_repository.dart';
import '../models/warehouse_location_model.dart';

/// Implementation of WarehouseLocationRepository using Firestore
class FirestoreWarehouseLocationRepository
    implements WarehouseLocationRepository {
  FirestoreWarehouseLocationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const String _collection = 'warehouse_locations';

  @override
  Future<List<WarehouseLocationModel>> getAllLocations() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();

      return querySnapshot.docs
          .map((doc) => WarehouseLocationModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch warehouse locations: $e');
    }
  }

  @override
  Future<List<WarehouseLocationModel>> getLocationsByWarehouse(
      String warehouseId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('warehouseId', isEqualTo: warehouseId)
          .get();

      return querySnapshot.docs
          .map((doc) => WarehouseLocationModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch locations for warehouse: $e');
    }
  }

  @override
  Future<WarehouseLocationModel?> getLocationById(String locationId) async {
    try {
      final docSnapshot =
          await _firestore.collection(_collection).doc(locationId).get();

      if (!docSnapshot.exists) {
        return null;
      }

      return WarehouseLocationModel.fromJson({
        'id': docSnapshot.id,
        ...docSnapshot.data()!,
      });
    } catch (e) {
      throw Exception('Failed to fetch location: $e');
    }
  }

  @override
  Future<List<WarehouseLocationModel>> getLocationsByType(
      String locationType) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('locationType', isEqualTo: locationType)
          .get();

      return querySnapshot.docs
          .map((doc) => WarehouseLocationModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch locations by type: $e');
    }
  }

  @override
  Future<List<WarehouseLocationModel>> getLocationsByZone(String zone) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('zone', isEqualTo: zone)
          .get();

      return querySnapshot.docs
          .map((doc) => WarehouseLocationModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch locations by zone: $e');
    }
  }

  @override
  Future<String> createLocation(WarehouseLocationModel location) async {
    try {
      final docRef =
          await _firestore.collection(_collection).add(location.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create location: $e');
    }
  }

  @override
  Future<void> updateLocation(WarehouseLocationModel location) async {
    try {
      if (location.id == null) {
        throw Exception('Location ID is required for update');
      }

      await _firestore
          .collection(_collection)
          .doc(location.id)
          .update(location.toJson());
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  @override
  Future<void> deleteLocation(String locationId) async {
    try {
      await _firestore.collection(_collection).doc(locationId).delete();
    } catch (e) {
      throw Exception('Failed to delete location: $e');
    }
  }

  @override
  Future<List<WarehouseLocationModel>> getSuitableLocationsForItem({
    required Map<String, dynamic> itemRequirements,
    String? warehouseId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(_collection);

      // Apply warehouse filter if provided
      if (warehouseId != null) {
        query = query.where('warehouseId', isEqualTo: warehouseId);
      }

      // Filter for active locations only
      query = query.where('isActive', isEqualTo: true);

      // Temperature requirements filter
      if (itemRequirements['needsRefrigeration'] == true) {
        query = query.where('locationType', isEqualTo: 'coldStorage');
      } else if (itemRequirements['isFrozen'] == true) {
        query = query.where('locationType', isEqualTo: 'freezer');
      }

      // Get results and return as models
      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => WarehouseLocationModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch suitable locations: $e');
    }
  }

  @override
  double calculateDistance(String locationId1, String locationId2) {
    // Parse location codes to estimate distance
    // This is a simplified implementation - would be replaced with actual
    // warehouse layout distance calculations in a real system

    // Extract zone, aisle, rack info
    final parts1 = locationId1.split('/');
    final parts2 = locationId2.split('/');

    // Calculate a simple Manhattan distance based on parts
    int distance = 0;

    // Calculate distance based on different parts of the location ID
    for (int i = 0; i < math.min(parts1.length, parts2.length); i++) {
      if (parts1[i] != parts2[i]) {
        // Each difference adds to the distance
        distance += (i + 1) * 5; // Weight differences by their position
      }
    }

    // Difference in length also matters
    distance += (parts1.length - parts2.length).abs() * 2;

    // Normalize value between 0.0 and 1.0 without cast
    return math.min(1.0, math.max(0.0, distance / 50.0));
  }
}
