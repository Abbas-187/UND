import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/inventory_movement_model.dart';
import '../../models/inventory_movement_type.dart';

/// Repository interface for managing inventory movements in the system
abstract class InventoryMovementRepository {
  /// Creates a new inventory movement in the system
  ///
  /// Returns the created movement with generated ID
  Future<InventoryMovementModel> createMovement(
      InventoryMovementModel movement);

  /// Retrieves a specific movement by its ID
  ///
  /// Throws an exception if the movement is not found
  Future<InventoryMovementModel> getMovementById(String id);

  /// Retrieves all movements of a specific type
  Future<List<InventoryMovementModel>> getMovementsByType(
      InventoryMovementType type);

  /// Retrieves all movements that occurred within the specified time range
  Future<List<InventoryMovementModel>> getMovementsByTimeRange(
      DateTime start, DateTime end);

  /// Retrieves all movements involving a specific location
  ///
  /// If [isSource] is true, returns movements where the location is the source
  /// If [isSource] is false, returns movements where the location is the destination
  Future<List<InventoryMovementModel>> getMovementsByLocation(
      String locationId, bool isSource);

  /// Retrieves all movements involving a specific product/material
  Future<List<InventoryMovementModel>> getMovementsByProduct(String productId);

  /// Updates the approval status of a movement
  ///
  /// Optionally includes the approver information
  Future<InventoryMovementModel> updateMovementStatus(
      String id, ApprovalStatus status,
      {String? approverId, String? approverName});

  /// Deletes a movement from the system
  ///
  /// Should be used with caution as it affects inventory tracking
  Future<void> deleteMovement(String id);
}

// Provider definition for dependency injection
final inventoryMovementRepositoryProvider =
    Provider<InventoryMovementRepository>((ref) {
  throw UnimplementedError(
      'Provider must be overridden with an implementation');
});
