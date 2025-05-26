import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/quality_status.dart';
import '../entities/inventory_item.dart';
import '../providers/inventory_repository_provider.dart' as repo_provider;
import '../repositories/inventory_repository.dart';
import '../usecases/allocate_quality_aware_inventory_usecase.dart';
import '../usecases/update_inventory_quality_status_usecase.dart';

/// Quality control dashboard data
class QualityControlDashboard {
  const QualityControlDashboard({
    required this.totalItems,
    required this.itemsByStatus,
    required this.pendingInspectionCount,
    required this.rejectedCount,
    required this.blockedCount,
    required this.reworkCount,
    required this.criticalItems,
    required this.expiringItems,
  });

  final int totalItems;
  final Map<QualityStatus, int> itemsByStatus;
  final int pendingInspectionCount;
  final int rejectedCount;
  final int blockedCount;
  final int reworkCount;
  final List<QualityAlert> criticalItems;
  final List<QualityAlert> expiringItems;
}

/// Quality alert for items requiring attention
class QualityAlert {
  const QualityAlert({
    required this.itemId,
    required this.itemName,
    required this.batchLotNumber,
    required this.qualityStatus,
    required this.alertType,
    required this.message,
    required this.priority,
    this.expirationDate,
    this.daysUntilExpiry,
  });

  final String itemId;
  final String itemName;
  final String batchLotNumber;
  final QualityStatus qualityStatus;
  final QualityAlertType alertType;
  final String message;
  final AlertPriority priority;
  final DateTime? expirationDate;
  final int? daysUntilExpiry;
}

/// Types of quality alerts
enum QualityAlertType {
  statusChange,
  expiration,
  qualityIssue,
  batchRecall,
  inspection,
}

/// Alert priority levels
enum AlertPriority {
  low,
  medium,
  high,
  critical,
}

/// Quality inspection request
class QualityInspectionRequest {
  const QualityInspectionRequest({
    required this.itemId,
    required this.batchLotNumber,
    required this.inspectionType,
    required this.inspectedBy,
    this.notes,
    this.referenceDocumentId,
  });

  final String itemId;
  final String batchLotNumber;
  final String inspectionType;
  final String inspectedBy;
  final String? notes;
  final String? referenceDocumentId;
}

/// Quality inspection result
class QualityInspectionResult {
  const QualityInspectionResult({
    required this.passed,
    required this.newQualityStatus,
    required this.inspectionNotes,
    this.correctiveActions,
    this.followUpRequired = false,
  });

  final bool passed;
  final QualityStatus newQualityStatus;
  final String inspectionNotes;
  final List<String>? correctiveActions;
  final bool followUpRequired;
}

/// Comprehensive quality control service
class QualityControlService {
  const QualityControlService(
    this._repository,
    this._updateQualityStatusUseCase,
    this._allocateInventoryUseCase,
  );

  final InventoryRepository _repository;
  final UpdateInventoryQualityStatusUseCase _updateQualityStatusUseCase;
  final AllocateQualityAwareInventoryUseCase _allocateInventoryUseCase;

  /// Get quality control dashboard data
  Future<QualityControlDashboard> getQualityControlDashboard({
    String? warehouseId,
  }) async {
    try {
      // Get all inventory items
      final items = await _repository.getItems();

      final itemsByStatus = <QualityStatus, int>{};
      final criticalItems = <QualityAlert>[];
      final expiringItems = <QualityAlert>[];

      int pendingInspectionCount = 0;
      int rejectedCount = 0;
      int blockedCount = 0;
      int reworkCount = 0;

      for (final item in items) {
        // Get quality status for item and its batches
        final itemQualityData = await _getItemQualityData(item);

        for (final batchData in itemQualityData) {
          final status = batchData['status'] as QualityStatus;
          final batchNumber = batchData['batchNumber'] as String;

          // Count by status
          itemsByStatus[status] = (itemsByStatus[status] ?? 0) + 1;

          switch (status) {
            case QualityStatus.pendingInspection:
              pendingInspectionCount++;
              break;
            case QualityStatus.rejected:
              rejectedCount++;
              break;
            case QualityStatus.blocked:
              blockedCount++;
              break;
            case QualityStatus.rework:
              reworkCount++;
              break;
            default:
              break;
          }

          // Check for critical items
          if (status.requiresAttention) {
            criticalItems.add(QualityAlert(
              itemId: item.id,
              itemName: item.name,
              batchLotNumber: batchNumber,
              qualityStatus: status,
              alertType: QualityAlertType.qualityIssue,
              message:
                  'Item requires immediate attention: ${status.description}',
              priority: _getAlertPriority(status),
            ));
          }

          // Check for expiring items
          final expirationDate = batchData['expirationDate'] as DateTime?;
          if (expirationDate != null) {
            final daysUntilExpiry =
                expirationDate.difference(DateTime.now()).inDays;
            if (daysUntilExpiry <= 7 && daysUntilExpiry >= 0) {
              expiringItems.add(QualityAlert(
                itemId: item.id,
                itemName: item.name,
                batchLotNumber: batchNumber,
                qualityStatus: status,
                alertType: QualityAlertType.expiration,
                message: 'Item expires in $daysUntilExpiry days',
                priority: daysUntilExpiry <= 3
                    ? AlertPriority.critical
                    : AlertPriority.high,
                expirationDate: expirationDate,
                daysUntilExpiry: daysUntilExpiry,
              ));
            }
          }
        }
      }

      return QualityControlDashboard(
        totalItems: items.length,
        itemsByStatus: itemsByStatus,
        pendingInspectionCount: pendingInspectionCount,
        rejectedCount: rejectedCount,
        blockedCount: blockedCount,
        reworkCount: reworkCount,
        criticalItems: criticalItems,
        expiringItems: expiringItems,
      );
    } catch (e) {
      throw Exception('Failed to get quality control dashboard: $e');
    }
  }

  /// Process quality inspection
  Future<QualityStatusUpdateResult> processQualityInspection({
    required QualityInspectionRequest request,
    required QualityInspectionResult result,
  }) async {
    try {
      // Update quality status based on inspection result
      final updateResult = await _updateQualityStatusUseCase.execute(
        inventoryItemId: request.itemId,
        batchLotNumber: request.batchLotNumber,
        newQualityStatus: result.newQualityStatus,
        reason: 'Quality inspection: ${request.inspectionType}',
        referenceDocumentId: request.referenceDocumentId,
        userId: request.inspectedBy,
        notes:
            '${result.inspectionNotes}${result.correctiveActions != null ? '\nCorrective Actions: ${result.correctiveActions!.join(', ')}' : ''}',
      );

      return updateResult;
    } catch (e) {
      return QualityStatusUpdateResult(
        success: false,
        errors: ['Failed to process quality inspection: $e'],
      );
    }
  }

  /// Get items requiring quality inspection
  Future<List<InventoryItem>> getItemsRequiringInspection({
    String? warehouseId,
  }) async {
    try {
      final items = await _repository.getItems();
      final itemsRequiringInspection = <InventoryItem>[];

      for (final item in items) {
        final qualityData = await _getItemQualityData(item);

        // Check if any batch is pending inspection
        final hasPendingInspection = qualityData.any(
          (batch) => batch['status'] == QualityStatus.pendingInspection,
        );

        if (hasPendingInspection) {
          itemsRequiringInspection.add(item);
        }
      }

      return itemsRequiringInspection;
    } catch (e) {
      throw Exception('Failed to get items requiring inspection: $e');
    }
  }

  /// Get quality-aware stock levels
  Future<Map<String, Map<QualityStatus, double>>> getQualityAwareStockLevels({
    String? warehouseId,
    List<String>? itemIds,
  }) async {
    try {
      final stockLevels = <String, Map<QualityStatus, double>>{};

      final items = itemIds != null
          ? await Future.wait(
              itemIds.map((id) => _repository.getInventoryItem(id)))
          : await _repository.getItems();

      for (final item in items) {
        if (item == null) continue;

        final qualityData = await _getItemQualityData(item);
        final itemStockLevels = <QualityStatus, double>{};

        for (final batchData in qualityData) {
          final status = batchData['status'] as QualityStatus;
          final quantity = batchData['quantity'] as double;

          itemStockLevels[status] = (itemStockLevels[status] ?? 0) + quantity;
        }

        stockLevels[item.id] = itemStockLevels;
      }

      return stockLevels;
    } catch (e) {
      throw Exception('Failed to get quality-aware stock levels: $e');
    }
  }

  /// Perform quality-aware allocation
  Future<InventoryAllocationResult> allocateQualityAwareInventory(
    InventoryAllocationRequest request,
  ) async {
    return await _allocateInventoryUseCase.execute(request);
  }

  /// Bulk update quality status for multiple items/batches
  Future<List<QualityStatusUpdateResult>> bulkUpdateQualityStatus({
    required List<String> itemIds,
    required QualityStatus newQualityStatus,
    required String reason,
    required String userId,
    String? batchLotNumber,
  }) async {
    final results = <QualityStatusUpdateResult>[];

    for (final itemId in itemIds) {
      try {
        final result = await _updateQualityStatusUseCase.execute(
          inventoryItemId: itemId,
          batchLotNumber: batchLotNumber,
          newQualityStatus: newQualityStatus,
          reason: reason,
          userId: userId,
        );
        results.add(result);
      } catch (e) {
        results.add(QualityStatusUpdateResult(
          success: false,
          errors: ['Failed to update item $itemId: $e'],
        ));
      }
    }

    return results;
  }

  /// Get quality history for an item
  Future<List<QualityStatusChange>> getQualityHistory({
    required String itemId,
    String? batchLotNumber,
  }) async {
    try {
      final item = await _repository.getInventoryItem(itemId);
      if (item == null) {
        throw Exception('Item not found: $itemId');
      }

      final attributes = item.additionalAttributes ?? {};
      final history = <QualityStatusChange>[];

      if (batchLotNumber != null) {
        // Get batch-specific history
        final batchHistory =
            attributes['batchQualityHistory'] as Map<String, dynamic>?;
        if (batchHistory != null && batchHistory.containsKey(batchLotNumber)) {
          final batchChanges = batchHistory[batchLotNumber] as List<dynamic>;

          for (final change in batchChanges) {
            final changeMap = change as Map<String, dynamic>;
            history.add(QualityStatusChange(
              id: 'history-${DateTime.now().millisecondsSinceEpoch}',
              itemId: itemId,
              batchLotNumber: batchLotNumber,
              fromStatus:
                  QualityStatus.fromCode(changeMap['fromStatus'] as String),
              toStatus: QualityStatus.fromCode(changeMap['toStatus'] as String),
              reason: 'Historical change',
              changedBy: changeMap['changedBy'] as String,
              changedAt: DateTime.parse(changeMap['changedAt'] as String),
            ));
          }
        }
      }

      return history;
    } catch (e) {
      throw Exception('Failed to get quality history: $e');
    }
  }

  /// Get quality data for an item including all batches
  Future<List<Map<String, dynamic>>> _getItemQualityData(
      InventoryItem item) async {
    final attributes = item.additionalAttributes ?? {};
    final qualityData = <Map<String, dynamic>>[];

    // Check if item has batch tracking
    final batchStatuses =
        attributes['batchQualityStatus'] as Map<String, dynamic>?;

    if (batchStatuses != null && batchStatuses.isNotEmpty) {
      // Item has batch-specific quality statuses
      for (final entry in batchStatuses.entries) {
        final batchNumber = entry.key;
        final statusCode = entry.value as String;
        final status = QualityStatus.fromCode(statusCode);

        qualityData.add({
          'batchNumber': batchNumber,
          'status': status,
          'quantity': item.quantity, // TODO: Get batch-specific quantity
          'expirationDate': null, // TODO: Get batch-specific expiration date
        });
      }
    } else {
      // Item has single quality status
      final itemStatus = attributes['qualityStatus'] as String?;
      final status = itemStatus != null
          ? QualityStatus.fromLegacyString(itemStatus)
          : QualityStatus.available;

      qualityData.add({
        'batchNumber': item.batchNumber ?? 'NO_BATCH',
        'status': status,
        'quantity': item.quantity,
        'expirationDate': item.expiryDate,
      });
    }

    return qualityData;
  }

  /// Get alert priority based on quality status
  AlertPriority _getAlertPriority(QualityStatus status) {
    switch (status) {
      case QualityStatus.critical:
      case QualityStatus.rejected:
        return AlertPriority.critical;
      case QualityStatus.blocked:
      case QualityStatus.rework:
        return AlertPriority.high;
      case QualityStatus.warning:
      case QualityStatus.pendingInspection:
        return AlertPriority.medium;
      default:
        return AlertPriority.low;
    }
  }
}

/// Provider for QualityControlService
final qualityControlServiceProvider = Provider<QualityControlService>((ref) {
  return QualityControlService(
    ref.watch(repo_provider.inventoryRepositoryProvider),
    ref.watch(updateInventoryQualityStatusUseCaseProvider),
    ref.watch(allocateQualityAwareInventoryUseCaseProvider),
  );
});
