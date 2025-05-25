import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../../core/di/app_providers.dart';
import '../../data/models/inventory_movement_model.dart';
import '../../data/repositories/inventory_movement_repository.dart';
import '../validators/inventory_movement_validator.dart';
import '../../../sales/data/repositories/product_catalog_repository.dart';

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

      // Async batch/expiry validation
      final validator = InventoryMovementValidator(
          productCatalogRepository: ProductCatalogRepository());
      final validationResult = await validator.validateAsync(movement);
      if (!validationResult.isValid) {
        throw Exception(
            'Movement validation failed: ${validationResult.errors.join('; ')}');
      }

      // Validate movement data (legacy sync checks)
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

      if (status != ApprovalStatus.approved &&
          status != ApprovalStatus.rejected) {
        throw Exception(
            'Invalid approval status: must be approved or rejected');
      }

      // Update movement status
      // final updatedMovement = await _movementRepository.updateMovementStatus(
      //   id,
      //   status,
      //   approverId: approverId,
      //   approverName: approverName,
      // );

      _logger.i('Successfully updated movement status to $status');
      // return updatedMovement;
      throw UnimplementedError('updateMovementStatus is not implemented');
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
      case InventoryMovementType.poReceipt:
      case InventoryMovementType.productionOutput:
      case InventoryMovementType.salesReturn:
      case InventoryMovementType.transferIn:
      case InventoryMovementType.productionIssue:
      case InventoryMovementType.transferOut:
      case InventoryMovementType.saleShipment:
      case InventoryMovementType.adjustmentDamage:
      case InventoryMovementType.adjustmentCycleCountGain:
      case InventoryMovementType.adjustmentCycleCountLoss:
      case InventoryMovementType.adjustmentOther:
      case InventoryMovementType.qualityStatusUpdate:
      // Handle all cases by adding a default case
      default:
        if (movement.sourceLocationId == null ||
            movement.sourceLocationId!.isEmpty ||
            movement.destinationLocationId == null ||
            movement.destinationLocationId!.isEmpty) {
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
  final repository = ref.watch(inventoryMovementRepositoryProvider);
  final logger = ref.watch(loggerProvider);

  return InventoryMovementService(
    movementRepository: repository,
    logger: logger,
  );
});
