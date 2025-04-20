import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../data/repositories/inventory_movement_repository.dart';
import '../../data/models/inventory_movement_model.dart';
import '../../data/models/inventory_movement_type.dart';
import '../../providers/inventory_movement_providers.dart' as providers;

/// Service class to handle inventory movement business logic
class InventoryMovementService {
  InventoryMovementService({
    required InventoryMovementRepository movementRepository,
    required Logger logger,
  })  : _movementRepository = movementRepository,
        _logger = logger;
  final InventoryMovementRepository _movementRepository;
  final Logger _logger;

  /// Creates a new inventory movement with validation
  Future<InventoryMovementModel> createMovement(
      InventoryMovementModel movement) async {
    try {
      _logger.i('Creating new movement of type ${movement.movementType}');

      // Validate movement data
      _validateMovement(movement);

      // Create the movement
      final createdMovement =
          await _movementRepository.createMovement(movement);

      _logger.i(
          'Successfully created movement with ID: ${createdMovement.movementId}');
      return createdMovement;
    } catch (error, stackTrace) {
      _logger.e(
        'Error creating movement',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Updates the approval status of a movement
  Future<InventoryMovementModel> approveOrRejectMovement(
    String id,
    ApprovalStatus status,
    String approverId,
    String approverName,
  ) async {
    try {
      _logger.i('Updating movement $id to status: $status');

      if (status != ApprovalStatus.APPROVED &&
          status != ApprovalStatus.REJECTED) {
        throw Exception(
            'Invalid approval status: must be APPROVED or REJECTED');
      }

      // Update movement status
      final updatedMovement = await _movementRepository.updateMovementStatus(
        id,
        status,
        approverId: approverId,
        approverName: approverName,
      );

      _logger.i('Successfully updated movement status to $status');
      return updatedMovement;
    } catch (error, stackTrace) {
      _logger.e(
        'Error updating movement status',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Retrieves movement details by ID
  Future<InventoryMovementModel> getMovement(String id) async {
    try {
      return await _movementRepository.getMovementById(id);
    } catch (error, stackTrace) {
      _logger.e(
        'Error retrieving movement with ID: $id',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Retrieves movements for a specific report type
  Future<List<InventoryMovementModel>> getMovementsForReport({
    InventoryMovementType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? locationId,
    bool? isSource,
    String? productId,
  }) async {
    try {
      if (type != null) {
        return await _movementRepository.getMovementsByType(type);
      } else if (startDate != null && endDate != null) {
        return await _movementRepository.getMovementsByTimeRange(
            startDate, endDate);
      } else if (locationId != null && isSource != null) {
        return await _movementRepository.getMovementsByLocation(
            locationId, isSource);
      } else if (productId != null) {
        return await _movementRepository.getMovementsByProduct(productId);
      } else {
        throw Exception('Invalid report criteria');
      }
    } catch (error, stackTrace) {
      _logger.e(
        'Error retrieving movements for report',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Validates movement data before saving
  void _validateMovement(InventoryMovementModel movement) {
    // Validate source and destination based on movement type
    switch (movement.movementType) {
      case InventoryMovementType.RECEIPT:
        if (movement.destinationLocationId.isEmpty) {
          throw Exception(
              'Destination location is required for RECEIPT movements');
        }
        break;
      case InventoryMovementType.DISPOSAL:
        if (movement.sourceLocationId.isEmpty) {
          throw Exception('Source location is required for DISPOSAL movements');
        }
        break;
      case InventoryMovementType.TRANSFER:
      case InventoryMovementType.ADJUSTMENT:
      case InventoryMovementType.ISSUE:
      case InventoryMovementType.RETURN:
        if (movement.sourceLocationId.isEmpty ||
            movement.destinationLocationId.isEmpty) {
          throw Exception(
              'Both source and destination locations are required for this movement type');
        }
        break;
    }

    // Validate items
    if (movement.items.isEmpty) {
      throw Exception('Movement must have at least one item');
    }

    // Validate item quantities
    for (final item in movement.items) {
      if (item.quantity <= 0) {
        throw Exception('Item quantity must be greater than zero');
      }
    }
  }
}

/// Provider for the inventory movement service
final inventoryMovementServiceProvider =
    Provider<InventoryMovementService>((ref) {
  final repository = ref.watch(providers.inventoryMovementRepositoryProvider);
  final logger = ref.watch(providers.loggerProvider);

  return InventoryMovementService(
    movementRepository: repository,
    logger: logger,
  );
});
