import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/quality_status.dart';
import '../entities/cost_layer.dart';
import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';
import '../providers/inventory_repository_provider.dart' as repo_provider;

/// Allocation request for inventory items
class InventoryAllocationRequest {
  const InventoryAllocationRequest({
    required this.itemId,
    required this.requestedQuantity,
    required this.warehouseId,
    this.batchLotNumber,
    this.requiredQualityStatuses,
    this.excludeQualityStatuses,
    this.maxExpiryDate,
    this.minExpiryDate,
    this.costingMethod = CostingMethod.fifo,
  });

  final String itemId;
  final double requestedQuantity;
  final String warehouseId;
  final String? batchLotNumber;
  final List<QualityStatus>? requiredQualityStatuses;
  final List<QualityStatus>? excludeQualityStatuses;
  final DateTime? maxExpiryDate;
  final DateTime? minExpiryDate;
  final CostingMethod costingMethod;
}

/// Result of inventory allocation
class InventoryAllocationResult {
  const InventoryAllocationResult({
    required this.success,
    required this.allocatedQuantity,
    required this.allocations,
    this.errors = const [],
    this.warnings = const [],
  });

  final bool success;
  final double allocatedQuantity;
  final List<AllocationDetail> allocations;
  final List<String> errors;
  final List<String> warnings;

  bool get isFullyAllocated => allocatedQuantity >= 0;
  bool get isPartiallyAllocated => allocatedQuantity > 0 && !isFullyAllocated;
}

/// Detail of a specific allocation
class AllocationDetail {
  const AllocationDetail({
    required this.costLayerId,
    required this.itemId,
    required this.batchLotNumber,
    required this.allocatedQuantity,
    required this.costAtTransaction,
    required this.qualityStatus,
    this.expirationDate,
    this.productionDate,
  });

  final String costLayerId;
  final String itemId;
  final String batchLotNumber;
  final double allocatedQuantity;
  final double costAtTransaction;
  final QualityStatus qualityStatus;
  final DateTime? expirationDate;
  final DateTime? productionDate;

  double get totalCost => allocatedQuantity * costAtTransaction;
}

/// Enhanced use case for quality-aware inventory allocation
class AllocateQualityAwareInventoryUseCase {
  const AllocateQualityAwareInventoryUseCase(this._repository);

  final InventoryRepository _repository;

  /// Allocate inventory with quality status awareness
  Future<InventoryAllocationResult> execute(
    InventoryAllocationRequest request,
  ) async {
    final errors = <String>[];
    final warnings = <String>[];
    final allocations = <AllocationDetail>[];
    double remainingQuantity = request.requestedQuantity;

    try {
      // Validate request
      if (request.itemId.isEmpty) {
        errors.add('Item ID cannot be empty');
      }

      if (request.requestedQuantity <= 0) {
        errors.add('Requested quantity must be greater than zero');
      }

      if (request.warehouseId.isEmpty) {
        errors.add('Warehouse ID cannot be empty');
      }

      if (errors.isNotEmpty) {
        return InventoryAllocationResult(
          success: false,
          allocatedQuantity: 0,
          allocations: [],
          errors: errors,
        );
      }

      // Get inventory item
      final item = await _repository.getInventoryItem(request.itemId);
      if (item == null) {
        return InventoryAllocationResult(
          success: false,
          allocatedQuantity: 0,
          allocations: [],
          errors: ['Inventory item not found: ${request.itemId}'],
        );
      }

      // Get available cost layers with quality filtering
      final availableLayers = await _getQualityFilteredCostLayers(
        request,
        item,
      );

      if (availableLayers.isEmpty) {
        return InventoryAllocationResult(
          success: false,
          allocatedQuantity: 0,
          allocations: [],
          errors: ['No available inventory with required quality status'],
        );
      }

      // Sort layers based on costing method and expiry dates
      final sortedLayers = _sortCostLayers(availableLayers, request);

      // Allocate from available layers
      for (final layer in sortedLayers) {
        if (remainingQuantity <= 0) break;

        final quantityToAllocate = remainingQuantity > layer.remainingQuantity
            ? layer.remainingQuantity
            : remainingQuantity;

        // Get quality status for this layer
        final qualityStatus = _getLayerQualityStatus(layer, item);

        final allocation = AllocationDetail(
          costLayerId: layer.id,
          itemId: layer.itemId,
          batchLotNumber: layer.batchLotNumber,
          allocatedQuantity: quantityToAllocate,
          costAtTransaction: layer.costAtTransaction,
          qualityStatus: qualityStatus,
          expirationDate: layer.expirationDate,
          productionDate: layer.productionDate,
        );

        allocations.add(allocation);
        remainingQuantity -= quantityToAllocate;
      }

      // Check if allocation was successful
      final allocatedQuantity = request.requestedQuantity - remainingQuantity;
      final success =
          remainingQuantity <= 0.001; // Small epsilon for floating point

      if (!success) {
        warnings.add(
          'Only ${allocatedQuantity.toStringAsFixed(2)} of ${request.requestedQuantity.toStringAsFixed(2)} could be allocated',
        );
      }

      return InventoryAllocationResult(
        success: success,
        allocatedQuantity: allocatedQuantity,
        allocations: allocations,
        warnings: warnings,
      );
    } catch (e) {
      errors.add('Error during allocation: ${e.toString()}');
      return InventoryAllocationResult(
        success: false,
        allocatedQuantity: 0,
        allocations: allocations,
        errors: errors,
      );
    }
  }

  /// Get cost layers filtered by quality status
  Future<List<CostLayer>> _getQualityFilteredCostLayers(
    InventoryAllocationRequest request,
    InventoryItem item,
  ) async {
    // Get all available cost layers
    final allLayers = await _repository.getAvailableCostLayers(
      request.itemId,
      request.warehouseId,
      request.costingMethod,
    );

    // Filter by batch if specified
    var filteredLayers = request.batchLotNumber != null
        ? allLayers
            .where((layer) => layer.batchLotNumber == request.batchLotNumber)
            .toList()
        : allLayers;

    // Filter by expiry dates if specified
    if (request.maxExpiryDate != null) {
      filteredLayers = filteredLayers
          .where((layer) =>
              layer.expirationDate == null ||
              layer.expirationDate!.isBefore(request.maxExpiryDate!))
          .toList();
    }

    if (request.minExpiryDate != null) {
      filteredLayers = filteredLayers
          .where((layer) =>
              layer.expirationDate == null ||
              layer.expirationDate!.isAfter(request.minExpiryDate!))
          .toList();
    }

    // Filter by quality status
    final qualityFilteredLayers = <CostLayer>[];

    for (final layer in filteredLayers) {
      final qualityStatus = _getLayerQualityStatus(layer, item);

      // Check if quality status meets requirements
      if (_isQualityStatusAcceptable(qualityStatus, request)) {
        qualityFilteredLayers.add(layer);
      }
    }

    return qualityFilteredLayers;
  }

  /// Get quality status for a cost layer
  QualityStatus _getLayerQualityStatus(CostLayer layer, InventoryItem item) {
    final attributes = item.additionalAttributes ?? {};

    // Check batch-specific quality status first
    final batchStatuses =
        attributes['batchQualityStatus'] as Map<String, dynamic>?;
    if (batchStatuses != null &&
        batchStatuses.containsKey(layer.batchLotNumber)) {
      final statusCode = batchStatuses[layer.batchLotNumber] as String;
      return QualityStatus.fromCode(statusCode);
    }

    // Fall back to item-level quality status
    final itemStatus = attributes['qualityStatus'] as String?;
    if (itemStatus != null) {
      return QualityStatus.fromLegacyString(itemStatus);
    }

    // Default to available for items without explicit quality status
    return QualityStatus.available;
  }

  /// Check if quality status is acceptable for allocation
  bool _isQualityStatusAcceptable(
    QualityStatus status,
    InventoryAllocationRequest request,
  ) {
    // If specific quality statuses are required
    if (request.requiredQualityStatuses != null &&
        request.requiredQualityStatuses!.isNotEmpty) {
      return request.requiredQualityStatuses!.contains(status);
    }

    // If specific quality statuses are excluded
    if (request.excludeQualityStatuses != null &&
        request.excludeQualityStatuses!.isNotEmpty) {
      return !request.excludeQualityStatuses!.contains(status);
    }

    // Default: only allow statuses that are available for use
    return status.isAvailableForUse;
  }

  /// Sort cost layers based on costing method and expiry dates
  List<CostLayer> _sortCostLayers(
    List<CostLayer> layers,
    InventoryAllocationRequest request,
  ) {
    final sortedLayers = List<CostLayer>.from(layers);

    sortedLayers.sort((a, b) {
      // Primary sort: FIFO/LIFO based on movement date
      int dateComparison;
      if (request.costingMethod == CostingMethod.fifo) {
        dateComparison = a.movementDate.compareTo(b.movementDate);
      } else {
        dateComparison = b.movementDate.compareTo(a.movementDate);
      }

      if (dateComparison != 0) return dateComparison;

      // Secondary sort: FEFO (First Expired, First Out) for perishable items
      if (a.expirationDate != null && b.expirationDate != null) {
        return a.expirationDate!.compareTo(b.expirationDate!);
      } else if (a.expirationDate != null) {
        return -1; // Items with expiry dates come first
      } else if (b.expirationDate != null) {
        return 1;
      }

      // Tertiary sort: by batch lot number for consistency
      return a.batchLotNumber.compareTo(b.batchLotNumber);
    });

    return sortedLayers;
  }

  /// Reserve allocated inventory (to be called after successful allocation)
  Future<bool> reserveAllocatedInventory(
    List<AllocationDetail> allocations,
    String reservationId,
    String reservedBy,
  ) async {
    try {
      for (final allocation in allocations) {
        // TODO: Update cost layer to reduce remaining quantity
        // await _repository.updateCostLayerQuantity(
        //   allocation.costLayerId,
        //   -allocation.allocatedQuantity,
        // );

        // TODO: Create reservation record (if reservation system exists)
        // This will be implemented when reservation system is added
      }
      return true;
    } catch (e) {
      // Rollback reservations on error
      await _rollbackReservations(allocations);
      return false;
    }
  }

  /// Rollback reservations in case of error
  Future<void> _rollbackReservations(List<AllocationDetail> allocations) async {
    for (final allocation in allocations) {
      try {
        // TODO: Add back the quantity to cost layer
        // await _repository.updateCostLayerQuantity(
        //   allocation.costLayerId,
        //   allocation.allocatedQuantity, // Add back the quantity
        // );
      } catch (e) {
        // Log error but continue with rollback
        print(
            'Error rolling back allocation for ${allocation.costLayerId}: $e');
      }
    }
  }
}

/// Provider for AllocateQualityAwareInventoryUseCase
final allocateQualityAwareInventoryUseCaseProvider =
    Provider<AllocateQualityAwareInventoryUseCase>((ref) {
  return AllocateQualityAwareInventoryUseCase(
    ref.watch(repo_provider.inventoryRepositoryProvider),
  );
});
