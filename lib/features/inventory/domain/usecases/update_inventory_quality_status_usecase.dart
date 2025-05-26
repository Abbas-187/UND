import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/inventory_movement_item_model.dart';
import '../../data/models/inventory_movement_model.dart';
import '../../data/models/quality_status.dart';
import '../entities/inventory_item.dart';
import '../providers/inventory_repository_provider.dart' as repo_provider;
import '../repositories/inventory_repository.dart';

/// Result of quality status update operation
class QualityStatusUpdateResult {
  const QualityStatusUpdateResult({
    required this.success,
    this.movementId,
    this.errors = const [],
    this.warnings = const [],
  });

  final bool success;
  final String? movementId;
  final List<String> errors;
  final List<String> warnings;
}

/// Enhanced use case for updating the quality status of inventory items or batches
class UpdateInventoryQualityStatusUseCase {
  const UpdateInventoryQualityStatusUseCase(this._repository);

  final InventoryRepository _repository;

  /// Updates the quality status of an inventory item or batch and logs a quality update movement
  Future<QualityStatusUpdateResult> execute({
    required String inventoryItemId,
    String? batchLotNumber,
    required QualityStatus newQualityStatus,
    required String reason,
    String? referenceDocumentId,
    required String userId,
    double? quantityAffected,
    String? notes,
  }) async {
    final errors = <String>[];
    final warnings = <String>[];

    try {
      // Validate inputs
      if (inventoryItemId.isEmpty) {
        errors.add('Inventory item ID cannot be empty');
      }

      if (reason.isEmpty) {
        errors.add('Reason for quality status change is required');
      }

      if (userId.isEmpty) {
        errors.add('User ID is required for audit trail');
      }

      if (errors.isNotEmpty) {
        return QualityStatusUpdateResult(success: false, errors: errors);
      }

      // Fetch the inventory item
      final item = await _repository.getInventoryItem(inventoryItemId);
      if (item == null) {
        return QualityStatusUpdateResult(
          success: false,
          errors: ['Inventory item not found: $inventoryItemId'],
        );
      }

      // Check if item requires batch tracking
      final requiresBatchTracking =
          item.additionalAttributes?['requiresBatchTracking'] == true;

      if (requiresBatchTracking &&
          (batchLotNumber == null || batchLotNumber.isEmpty)) {
        errors.add(
            'Batch number is required for batch-tracked item: ${item.name}');
      }

      // Get current quality status
      final currentStatus = _getCurrentQualityStatus(item, batchLotNumber);

      // Check if status change is valid
      if (currentStatus == newQualityStatus) {
        warnings
            .add('Quality status is already ${newQualityStatus.description}');
      }

      // Validate status transition
      final transitionValidation =
          _validateStatusTransition(currentStatus, newQualityStatus);
      if (!transitionValidation.isValid) {
        errors.add(transitionValidation.reason ?? 'Invalid status transition');
      }

      if (errors.isNotEmpty) {
        return QualityStatusUpdateResult(
          success: false,
          errors: errors,
          warnings: warnings,
        );
      }

      // Update quality status in item attributes
      final updatedItem = await _updateItemQualityStatus(
        item,
        batchLotNumber,
        currentStatus,
        newQualityStatus,
        userId,
      );

      // Save updated item
      await _repository.updateInventoryItem(updatedItem);

      // Create quality status change movement
      final movement = await _createQualityStatusMovement(
        item: updatedItem,
        batchLotNumber: batchLotNumber,
        fromStatus: currentStatus,
        toStatus: newQualityStatus,
        reason: reason,
        referenceDocumentId: referenceDocumentId,
        userId: userId,
        quantityAffected: quantityAffected ?? item.quantity,
        notes: notes,
      );

      // Save movement using the correct method name
      final movementId = await _repository.addMovement(movement);

      // Create quality status change record for audit trail
      final statusChange = QualityStatusChange(
        id: const Uuid().v4(),
        itemId: inventoryItemId,
        batchLotNumber: batchLotNumber,
        fromStatus: currentStatus,
        toStatus: newQualityStatus,
        reason: reason,
        changedBy: userId,
        changedAt: DateTime.now(),
        referenceDocumentId: referenceDocumentId,
        notes: notes,
      );

      // Save quality status change record (for now, store in movement notes)
      // TODO: Implement proper quality status change audit table

      return QualityStatusUpdateResult(
        success: true,
        movementId: movementId,
        warnings: warnings,
      );
    } catch (e) {
      errors.add('Error updating quality status: ${e.toString()}');
      return QualityStatusUpdateResult(success: false, errors: errors);
    }
  }

  /// Get current quality status for item or batch
  QualityStatus _getCurrentQualityStatus(
      InventoryItem item, String? batchLotNumber) {
    final attributes = item.additionalAttributes ?? {};

    if (batchLotNumber != null) {
      // Get batch-specific quality status
      final batchStatuses =
          attributes['batchQualityStatus'] as Map<String, dynamic>?;
      if (batchStatuses != null && batchStatuses.containsKey(batchLotNumber)) {
        final statusCode = batchStatuses[batchLotNumber] as String;
        return QualityStatus.fromCode(statusCode);
      }
    }

    // Get item-level quality status
    final itemStatus = attributes['qualityStatus'] as String?;
    if (itemStatus != null) {
      return QualityStatus.fromLegacyString(itemStatus);
    }

    // Default to pending inspection for new items
    return QualityStatus.pendingInspection;
  }

  /// Validate quality status transition
  StatusTransitionValidation _validateStatusTransition(
    QualityStatus fromStatus,
    QualityStatus toStatus,
  ) {
    // Define invalid transitions
    final invalidTransitions = <QualityStatus, List<QualityStatus>>{
      QualityStatus.rejected: [QualityStatus.excellent, QualityStatus.good],
      QualityStatus.blocked: [QualityStatus.excellent, QualityStatus.good],
    };

    final invalidTargets = invalidTransitions[fromStatus];
    if (invalidTargets != null && invalidTargets.contains(toStatus)) {
      return StatusTransitionValidation(
        isValid: false,
        reason:
            'Cannot change from ${fromStatus.description} to ${toStatus.description}',
      );
    }

    return const StatusTransitionValidation(isValid: true);
  }

  /// Update item quality status in attributes
  Future<InventoryItem> _updateItemQualityStatus(
    InventoryItem item,
    String? batchLotNumber,
    QualityStatus fromStatus,
    QualityStatus toStatus,
    String userId,
  ) async {
    final updatedAttributes =
        Map<String, dynamic>.from(item.additionalAttributes ?? {});

    if (batchLotNumber != null) {
      // Update batch-specific quality status
      updatedAttributes['batchQualityStatus'] ??= <String, dynamic>{};
      final batchStatuses =
          updatedAttributes['batchQualityStatus'] as Map<String, dynamic>;
      batchStatuses[batchLotNumber] = toStatus.code;

      // Update batch quality history
      updatedAttributes['batchQualityHistory'] ??= <String, dynamic>{};
      final batchHistory =
          updatedAttributes['batchQualityHistory'] as Map<String, dynamic>;
      batchHistory[batchLotNumber] ??= <Map<String, dynamic>>[];
      final history =
          batchHistory[batchLotNumber] as List<Map<String, dynamic>>;
      history.add({
        'fromStatus': fromStatus.code,
        'toStatus': toStatus.code,
        'changedAt': DateTime.now().toIso8601String(),
        'changedBy': userId,
      });

      // Update last quality status update timestamp
      updatedAttributes['lastQualityStatusUpdateTimestamp'] =
          DateTime.now().toIso8601String();
    } else {
      // Update item-level quality status
      updatedAttributes['qualityStatus'] = toStatus.code;
      updatedAttributes['lastQualityStatusUpdateTimestamp'] =
          DateTime.now().toIso8601String();
      updatedAttributes['lastQualityUpdateReason'] =
          'Status changed to ${toStatus.description}';
    }

    return item.copyWith(additionalAttributes: updatedAttributes);
  }

  /// Create quality status change movement
  Future<InventoryMovementModel> _createQualityStatusMovement({
    required InventoryItem item,
    String? batchLotNumber,
    required QualityStatus fromStatus,
    required QualityStatus toStatus,
    required String reason,
    String? referenceDocumentId,
    required String userId,
    required double quantityAffected,
    String? notes,
  }) async {
    final movementId = const Uuid().v4();
    final now = DateTime.now();

    // Create movement item
    final movementItem = InventoryMovementItemModel(
      id: const Uuid().v4(),
      itemId: item.id,
      itemCode: item.sapCode,
      itemName: item.name,
      quantity: 0, // Quality status changes don't affect quantity
      uom: item.unit,
      batchLotNumber: batchLotNumber,
      qualityStatus: toStatus.code,
      notes:
          'Quality status changed from ${fromStatus.description} to ${toStatus.description}',
      customAttributes: {
        'fromQualityStatus': fromStatus.code,
        'toQualityStatus': toStatus.code,
        'quantityAffected': quantityAffected,
      },
    );

    // Create the movement
    final movement = InventoryMovementModel(
      id: movementId,
      documentNumber: 'QS-${now.millisecondsSinceEpoch}',
      movementType: InventoryMovementType.qualityStatusUpdate,
      warehouseId: 'MAIN', // Default warehouse, should be configurable
      movementDate: now,
      items: [movementItem],
      createdAt: now,
      updatedAt: now,
      initiatingEmployeeId: userId,
      reasonNotes: reason,
      referenceType: 'QUALITY_STATUS_CHANGE',
      referenceNumber: referenceDocumentId,
      referenceDocuments:
          referenceDocumentId != null ? [referenceDocumentId] : null,
      status: InventoryMovementStatus.completed,
      approvedById: userId,
      approvedAt: now,
    );

    return movement;
  }
}

/// Status transition validation result
class StatusTransitionValidation {
  const StatusTransitionValidation({
    required this.isValid,
    this.reason,
  });

  final bool isValid;
  final String? reason;
}

/// Provider for UpdateInventoryQualityStatusUseCase
final updateInventoryQualityStatusUseCaseProvider =
    Provider<UpdateInventoryQualityStatusUseCase>((ref) {
  return UpdateInventoryQualityStatusUseCase(
    ref.watch(repo_provider.inventoryRepositoryProvider),
  );
});
