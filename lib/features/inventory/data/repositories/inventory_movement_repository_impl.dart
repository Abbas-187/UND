import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../../core/services/mock_data_service.dart';
import '../models/inventory_movement_model.dart';
import '../models/inventory_movement_type.dart';
import '../models/inventory_movement_item_model.dart';
import 'inventory_movement_repository.dart';

/// Implementation of the [InventoryMovementRepository] using mock data
class InventoryMovementRepositoryImpl implements InventoryMovementRepository {
  InventoryMovementRepositoryImpl({
    FirebaseFirestore? firestore,
    Logger? logger,
    MockDataService? mockDataService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _logger = logger ?? Logger(),
        _mockDataService = mockDataService ?? MockDataService();

  final FirebaseFirestore _firestore;
  final Logger _logger;
  final MockDataService _mockDataService;
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
          ? 'mov-${DateTime.now().millisecondsSinceEpoch}'
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

      // Add to mock data
      _mockDataService.inventoryMovements.add(newMovement);

      _logger.i('Successfully created inventory movement with ID: $movementId');
      return Future.value(newMovement);
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
      // Get from mock data
      final movement = _mockDataService.inventoryMovements
          .firstWhere((m) => m.movementId == id);
      return Future.value(movement);
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
      // Get from mock data
      final movements = _mockDataService.inventoryMovements
          .where((m) => m.movementType.toString() == type.toString())
          .toList();
      return Future.value(movements);
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
      // Get from mock data
      final movements = _mockDataService.inventoryMovements
          .where((m) => m.timestamp.isAfter(start) && m.timestamp.isBefore(end))
          .toList();
      return Future.value(movements);
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
      // Get from mock data
      final movements = _mockDataService.inventoryMovements
          .where((m) => isSource
              ? m.sourceLocationId == locationId
              : m.destinationLocationId == locationId)
          .toList();
      return Future.value(movements);
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
      // Get from mock data
      final movements = _mockDataService.inventoryMovements
          .where((m) => m.items.any((item) => item.productId == productId))
          .toList();
      return Future.value(movements);
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

      // Find the movement in mock data
      final index = _mockDataService.inventoryMovements
          .indexWhere((m) => m.movementId == id);

      if (index == -1) {
        throw Exception('Movement not found with ID: $id');
      }

      final currentMovement = _mockDataService.inventoryMovements[index];

      // Create updated model
      final updatedMovement = InventoryMovementModel(
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

      // Update in mock data
      _mockDataService.inventoryMovements[index] = updatedMovement;

      return Future.value(updatedMovement);
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
      _logger.i('Deleting movement $id');

      // Delete from mock data
      _mockDataService.inventoryMovements
          .removeWhere((m) => m.movementId == id);
    } catch (error, stackTrace) {
      _logger.e(
        'Error deleting movement',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to delete movement: $error');
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
          // Decrease quantity at source location (if not RECEIPT)
          if (movement.movementType != InventoryMovementType.RECEIPT) {
            await _adjustItemQuantity(
              transaction,
              movement.sourceLocationId,
              item.productId,
              -item.quantity,
            );
          }

          // Increase quantity at destination location (if not DISPOSAL)
          if (movement.movementType != InventoryMovementType.DISPOSAL) {
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
