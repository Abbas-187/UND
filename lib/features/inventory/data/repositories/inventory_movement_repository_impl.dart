import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../models/inventory_movement_model.dart';
import '../../models/inventory_movement_type.dart';
import 'inventory_movement_repository.dart';

/// Implementation of the [InventoryMovementRepository] using Firestore
class InventoryMovementRepositoryImpl implements InventoryMovementRepository {

  InventoryMovementRepositoryImpl({
    FirebaseFirestore? firestore,
    Logger? logger,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _logger = logger ?? Logger();
  final FirebaseFirestore _firestore;
  final Logger _logger;
  final String _collection = 'inventory_movements';

  /// Gets a reference to the movements collection
  CollectionReference<Map<String, dynamic>> get _movementsCollection =>
      _firestore.collection(_collection);

  @override
  Future<InventoryMovementModel> createMovement(
      InventoryMovementModel movement) async {
    try {
      _logger.i(
          'Creating new inventory movement of type: ${movement.movementType}');

      // Generate an ID if not provided
      final String movementId = movement.movementId.isEmpty
          ? _firestore.collection(_collection).doc().id
          : movement.movementId;

      // Create a new movement with the generated ID
      final newMovement = InventoryMovementModel(
        movementId: movementId,
        timestamp: movement.timestamp,
        movementType: movement.movementType,
        sourceLocationId: movement.sourceLocationId,
        sourceLocationName: movement.sourceLocationName,
        destinationLocationId: movement.destinationLocationId,
        destinationLocationName: movement.destinationLocationName,
        initiatingEmployeeId: movement.initiatingEmployeeId,
        initiatingEmployeeName: movement.initiatingEmployeeName,
        approvalStatus: movement.approvalStatus,
        approverEmployeeId: movement.approverEmployeeId,
        approverEmployeeName: movement.approverEmployeeName,
        reasonNotes: movement.reasonNotes,
        referenceDocuments: movement.referenceDocuments,
        items: movement.items,
      );

      // Convert to Map and save in Firestore
      await _movementsCollection.doc(movementId).set(newMovement.toJson());

      _logger.i('Successfully created inventory movement with ID: $movementId');
      return newMovement;
    } catch (error, stackTrace) {
      _logger.e(
        'Error creating inventory movement',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to create inventory movement: $error');
    }
  }

  @override
  Future<InventoryMovementModel> getMovementById(String id) async {
    try {
      final doc = await _movementsCollection.doc(id).get();
      if (!doc.exists) {
        throw Exception('Movement not found with ID: $id');
      }

      final data = doc.data()!;
      return InventoryMovementModel.fromJson(data);
    } catch (error, stackTrace) {
      _logger.e(
        'Error retrieving inventory movement with ID: $id',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to retrieve inventory movement: $error');
    }
  }

  @override
  Future<List<InventoryMovementModel>> getMovementsByType(
      InventoryMovementType type) async {
    try {
      final snapshot = await _movementsCollection
          .where('movementType', isEqualTo: type.toString().split('.').last)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => InventoryMovementModel.fromJson(doc.data()))
          .toList();
    } catch (error, stackTrace) {
      _logger.e(
        'Error retrieving movements by type: $type',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to retrieve movements by type: $error');
    }
  }

  @override
  Future<List<InventoryMovementModel>> getMovementsByTimeRange(
      DateTime start, DateTime end) async {
    try {
      final snapshot = await _movementsCollection
          .where('timestamp', isGreaterThanOrEqualTo: start.toIso8601String())
          .where('timestamp', isLessThanOrEqualTo: end.toIso8601String())
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => InventoryMovementModel.fromJson(doc.data()))
          .toList();
    } catch (error, stackTrace) {
      _logger.e(
        'Error retrieving movements by time range',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to retrieve movements by time range: $error');
    }
  }

  @override
  Future<List<InventoryMovementModel>> getMovementsByLocation(
      String locationId, bool isSource) async {
    try {
      final String fieldToQuery =
          isSource ? 'sourceLocationId' : 'destinationLocationId';

      final snapshot = await _movementsCollection
          .where(fieldToQuery, isEqualTo: locationId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => InventoryMovementModel.fromJson(doc.data()))
          .toList();
    } catch (error, stackTrace) {
      final String locationType = isSource ? 'source' : 'destination';
      _logger.e(
        'Error retrieving movements by $locationType location: $locationId',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to retrieve movements by location: $error');
    }
  }

  @override
  Future<List<InventoryMovementModel>> getMovementsByProduct(
      String productId) async {
    try {
      // This query is more complex as we need to search through nested items
      // For Firestore, we need to use array-contains query
      final snapshot = await _movementsCollection.get();

      // Filter in memory since productId is in a nested array
      return snapshot.docs
          .map((doc) => InventoryMovementModel.fromJson(doc.data()))
          .where((movement) =>
              movement.items.any((item) => item.productId == productId))
          .toList();
    } catch (error, stackTrace) {
      _logger.e(
        'Error retrieving movements by product ID: $productId',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to retrieve movements by product: $error');
    }
  }

  @override
  Future<InventoryMovementModel> updateMovementStatus(
      String id, ApprovalStatus status,
      {String? approverId, String? approverName}) async {
    try {
      _logger.i('Updating movement $id to status: $status');

      // Use a transaction to ensure data consistency
      return await _firestore
          .runTransaction<InventoryMovementModel>((transaction) async {
        final docRef = _movementsCollection.doc(id);
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          throw Exception('Movement not found with ID: $id');
        }

        final currentMovement = InventoryMovementModel.fromJson(doc.data()!);

        // Update the movement with new status and approver info
        final updatedData = {
          'approvalStatus': status.toString().split('.').last,
        };

        // Add approver information if provided
        if (approverId != null) {
          updatedData['approverEmployeeId'] = approverId;
        }

        if (approverName != null) {
          updatedData['approverEmployeeName'] = approverName;
        }

        transaction.update(docRef, updatedData);

        // Create updated model to return
        return InventoryMovementModel(
          movementId: currentMovement.movementId,
          timestamp: currentMovement.timestamp,
          movementType: currentMovement.movementType,
          sourceLocationId: currentMovement.sourceLocationId,
          sourceLocationName: currentMovement.sourceLocationName,
          destinationLocationId: currentMovement.destinationLocationId,
          destinationLocationName: currentMovement.destinationLocationName,
          initiatingEmployeeId: currentMovement.initiatingEmployeeId,
          initiatingEmployeeName: currentMovement.initiatingEmployeeName,
          approvalStatus: status,
          approverEmployeeId: approverId ?? currentMovement.approverEmployeeId,
          approverEmployeeName:
              approverName ?? currentMovement.approverEmployeeName,
          reasonNotes: currentMovement.reasonNotes,
          referenceDocuments: currentMovement.referenceDocuments,
          items: currentMovement.items,
        );
      });
    } catch (error, stackTrace) {
      _logger.e(
        'Error updating movement status',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to update movement status: $error');
    }
  }

  @override
  Future<void> deleteMovement(String id) async {
    try {
      _logger.w('Deleting inventory movement with ID: $id');

      // Check if movement exists before deleting
      final docSnapshot = await _movementsCollection.doc(id).get();
      if (!docSnapshot.exists) {
        throw Exception('Movement not found with ID: $id');
      }

      // Log the deletion event for audit purposes
      await _firestore.collection('inventory_movement_audit').add({
        'action': 'DELETE',
        'movementId': id,
        'timestamp': FieldValue.serverTimestamp(),
        'movementData': docSnapshot.data(),
      });

      // Delete the movement
      await _movementsCollection.doc(id).delete();

      _logger.i('Successfully deleted inventory movement with ID: $id');
    } catch (error, stackTrace) {
      _logger.e(
        'Error deleting inventory movement',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to delete inventory movement: $error');
    }
  }

  /// Helper method to update inventory quantities based on movement
  /// This would be called when a movement is approved
  Future<void> _updateInventoryQuantities(
      InventoryMovementModel movement) async {
    if (movement.approvalStatus != ApprovalStatus.APPROVED) {
      return; // Only update quantities for approved movements
    }

    try {
      await _firestore.runTransaction((transaction) async {
        // Process each item in the movement
        for (final item in movement.items) {
          // Decrease quantity at source location (if not RECEIPT or PRODUCTION_OUTPUT)
          if (movement.movementType != InventoryMovementType.RECEIPT &&
              movement.movementType !=
                  InventoryMovementType.PRODUCTION_OUTPUT) {
            await _adjustItemQuantity(
              transaction,
              movement.sourceLocationId,
              item.productId,
              -item.quantity,
            );
          }

          // Increase quantity at destination location (if not DISPOSAL or PRODUCTION_CONSUMPTION)
          if (movement.movementType != InventoryMovementType.DISPOSAL &&
              movement.movementType !=
                  InventoryMovementType.PRODUCTION_CONSUMPTION) {
            await _adjustItemQuantity(
              transaction,
              movement.destinationLocationId,
              item.productId,
              item.quantity,
            );
          }
        }
      });

      _logger.i(
          'Successfully updated inventory quantities for movement: ${movement.movementId}');
    } catch (error, stackTrace) {
      _logger.e(
        'Error updating inventory quantities',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to update inventory quantities: $error');
    }
  }

  /// Helper method to adjust quantity of an inventory item
  Future<void> _adjustItemQuantity(
    Transaction transaction,
    String locationId,
    String productId,
    double adjustment,
  ) async {
    final inventoryRef = _firestore
        .collection('inventory_items')
        .where('locationId', isEqualTo: locationId)
        .where('productId', isEqualTo: productId)
        .limit(1);

    final inventorySnapshot = await inventoryRef.get();

    if (inventorySnapshot.docs.isEmpty) {
      // Create new inventory record if item doesn't exist at this location
      if (adjustment > 0) {
        final newItemRef = _firestore.collection('inventory_items').doc();
        transaction.set(newItemRef, {
          'productId': productId,
          'locationId': locationId,
          'quantity': adjustment,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        throw Exception(
            'Cannot reduce quantity for non-existent inventory item');
      }
    } else {
      final doc = inventorySnapshot.docs.first;
      final currentQuantity = doc.data()['quantity'] as double;
      final newQuantity = currentQuantity + adjustment;

      if (newQuantity < 0) {
        throw Exception('Insufficient quantity available for adjustment');
      }

      transaction.update(doc.reference, {
        'quantity': newQuantity,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }
}

// Provider implementation
final inventoryMovementRepositoryImplProvider =
    Provider<InventoryMovementRepository>((ref) {
  return InventoryMovementRepositoryImpl();
});
