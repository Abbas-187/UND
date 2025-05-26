import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/inventory_movement_model.dart';
import '../../providers/inventory_repository_provider.dart' as repo_provider;
import '../../repositories/inventory_repository.dart';

/// Traceability record for a single movement
class TraceabilityRecord {
  const TraceabilityRecord({
    required this.movementId,
    required this.movementType,
    required this.movementDate,
    required this.quantity,
    required this.runningBalance,
    required this.location,
    required this.documentNumber,
    required this.referenceNumber,
    required this.employeeId,
    required this.notes,
    this.costAtTransaction,
    this.qualityStatus,
    this.expiryDate,
    this.supplierInfo,
    this.customerInfo,
    this.productionOrderInfo,
  });

  final String movementId;
  final InventoryMovementType movementType;
  final DateTime movementDate;
  final double quantity;
  final double runningBalance;
  final String location;
  final String documentNumber;
  final String referenceNumber;
  final String employeeId;
  final String notes;
  final double? costAtTransaction;
  final String? qualityStatus;
  final DateTime? expiryDate;
  final String? supplierInfo;
  final String? customerInfo;
  final String? productionOrderInfo;

  bool get isInbound => quantity > 0;
  bool get isOutbound => quantity < 0;
}

/// Complete traceability report for an item/batch
class TraceabilityReport {
  const TraceabilityReport({
    required this.itemId,
    required this.itemName,
    required this.batchLotNumber,
    required this.currentQuantity,
    required this.currentLocation,
    required this.currentQualityStatus,
    required this.traceabilityRecords,
    required this.summary,
    required this.generatedAt,
    required this.generatedBy,
  });

  final String itemId;
  final String itemName;
  final String? batchLotNumber;
  final double currentQuantity;
  final String currentLocation;
  final String currentQualityStatus;
  final List<TraceabilityRecord> traceabilityRecords;
  final TraceabilitySummary summary;
  final DateTime generatedAt;
  final String generatedBy;

  /// Get forward traceability (where did this batch go)
  List<TraceabilityRecord> get forwardTrace =>
      traceabilityRecords.where((record) => record.isOutbound).toList();

  /// Get backward traceability (where did this batch come from)
  List<TraceabilityRecord> get backwardTrace =>
      traceabilityRecords.where((record) => record.isInbound).toList();

  /// Get quality status changes
  List<TraceabilityRecord> get qualityChanges => traceabilityRecords
      .where((record) =>
          record.movementType == InventoryMovementType.qualityStatusUpdate)
      .toList();
}

/// Summary information for traceability
class TraceabilitySummary {
  const TraceabilitySummary({
    required this.totalMovements,
    required this.firstReceiptDate,
    required this.lastMovementDate,
    required this.totalInbound,
    required this.totalOutbound,
    required this.daysInInventory,
    required this.locationsVisited,
    required this.qualityStatusChanges,
    required this.suppliersInvolved,
    required this.customersServed,
    required this.productionOrdersUsed,
  });

  final int totalMovements;
  final DateTime? firstReceiptDate;
  final DateTime? lastMovementDate;
  final double totalInbound;
  final double totalOutbound;
  final int daysInInventory;
  final List<String> locationsVisited;
  final int qualityStatusChanges;
  final List<String> suppliersInvolved;
  final List<String> customersServed;
  final List<String> productionOrdersUsed;
}

/// Batch genealogy information
class BatchGenealogy {
  const BatchGenealogy({
    required this.parentBatches,
    required this.childBatches,
    required this.siblingBatches,
    required this.genealogyTree,
  });

  final List<BatchInfo> parentBatches;
  final List<BatchInfo> childBatches;
  final List<BatchInfo> siblingBatches;
  final Map<String, List<String>> genealogyTree;
}

/// Basic batch information
class BatchInfo {
  const BatchInfo({
    required this.batchNumber,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.createdDate,
    this.expiryDate,
    this.supplierInfo,
  });

  final String batchNumber;
  final String itemId;
  final String itemName;
  final double quantity;
  final DateTime createdDate;
  final DateTime? expiryDate;
  final String? supplierInfo;
}

/// Use case for generating comprehensive traceability reports
class TraceabilityReportUseCase {
  const TraceabilityReportUseCase(this._repository);

  final InventoryRepository _repository;

  /// Generate complete traceability report for an item/batch
  Future<TraceabilityReport> generateTraceabilityReport({
    required String itemId,
    String? batchLotNumber,
    required String generatedBy,
  }) async {
    try {
      // Get the inventory item
      final item = await _repository.getInventoryItem(itemId);
      if (item == null) {
        throw Exception('Item not found: $itemId');
      }

      // Get all movements for this item
      final allMovements = await _repository.getMovementsForItem(itemId);

      // Filter movements by batch if specified
      final movements = batchLotNumber != null
          ? allMovements
              .where((movement) => movement.items.any((item) =>
                  item.itemId == itemId &&
                  item.batchLotNumber == batchLotNumber))
              .toList()
          : allMovements;

      // Sort movements chronologically
      movements.sort((a, b) => a.movementDate.compareTo(b.movementDate));

      // Build traceability records
      final traceabilityRecords = <TraceabilityRecord>[];
      double runningBalance = 0.0;

      for (final movement in movements) {
        for (final movementItem in movement.items) {
          if (movementItem.itemId == itemId &&
              (batchLotNumber == null ||
                  movementItem.batchLotNumber == batchLotNumber)) {
            // Update running balance
            if (movement.isInbound) {
              runningBalance += movementItem.quantity;
            } else {
              runningBalance -= movementItem.quantity.abs();
            }

            final record = TraceabilityRecord(
              movementId: movement.id ?? '',
              movementType: movement.movementType,
              movementDate: movement.movementDate,
              quantity: movement.isInbound
                  ? movementItem.quantity
                  : -movementItem.quantity.abs(),
              runningBalance: runningBalance,
              location: movement.warehouseId,
              documentNumber: movement.documentNumber,
              referenceNumber: movement.referenceNumber ?? '',
              employeeId: movement.initiatingEmployeeId ?? 'SYSTEM',
              notes: movementItem.notes ?? movement.reasonNotes ?? '',
              costAtTransaction: movementItem.costAtTransaction,
              qualityStatus: movementItem.qualityStatus,
              expiryDate: movementItem.expirationDate,
              supplierInfo: _extractSupplierInfo(movement),
              customerInfo: _extractCustomerInfo(movement),
              productionOrderInfo: _extractProductionOrderInfo(movement),
            );

            traceabilityRecords.add(record);
          }
        }
      }

      // Generate summary
      final summary = _generateSummary(traceabilityRecords);

      // Get current status
      final currentQuantity = item.quantity;
      final currentLocation = 'MAIN'; // Default location
      final currentQualityStatus =
          item.additionalAttributes?['qualityStatus'] as String? ?? 'AVAILABLE';

      return TraceabilityReport(
        itemId: itemId,
        itemName: item.name,
        batchLotNumber: batchLotNumber,
        currentQuantity: currentQuantity,
        currentLocation: currentLocation,
        currentQualityStatus: currentQualityStatus,
        traceabilityRecords: traceabilityRecords,
        summary: summary,
        generatedAt: DateTime.now(),
        generatedBy: generatedBy,
      );
    } catch (e) {
      throw Exception('Failed to generate traceability report: $e');
    }
  }

  /// Generate batch genealogy information
  Future<BatchGenealogy> generateBatchGenealogy({
    required String batchLotNumber,
  }) async {
    try {
      // This is a simplified implementation
      // In practice, you'd need to track batch relationships through production processes

      final parentBatches = <BatchInfo>[];
      final childBatches = <BatchInfo>[];
      final siblingBatches = <BatchInfo>[];
      final genealogyTree = <String, List<String>>{};

      // TODO: Implement actual batch genealogy tracking
      // This would require:
      // 1. Production order tracking that shows which batches were consumed to create new batches
      // 2. Batch splitting/merging operations
      // 3. Rework operations that create new batches from existing ones

      return BatchGenealogy(
        parentBatches: parentBatches,
        childBatches: childBatches,
        siblingBatches: siblingBatches,
        genealogyTree: genealogyTree,
      );
    } catch (e) {
      throw Exception('Failed to generate batch genealogy: $e');
    }
  }

  /// Get all batches for an item
  Future<List<String>> getBatchesForItem(String itemId) async {
    try {
      final movements = await _repository.getMovementsForItem(itemId);
      final batches = <String>{};

      for (final movement in movements) {
        for (final item in movement.items) {
          if (item.itemId == itemId && item.batchLotNumber != null) {
            batches.add(item.batchLotNumber!);
          }
        }
      }

      return batches.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get batches for item: $e');
    }
  }

  /// Find items by supplier batch
  Future<List<TraceabilityReport>> findItemsBySupplierBatch({
    required String supplierBatchNumber,
    required String generatedBy,
  }) async {
    try {
      final reports = <TraceabilityReport>[];

      // Get all movements and find those with the supplier batch number
      final allItems = await _repository.getItems();

      for (final item in allItems) {
        final movements = await _repository.getMovementsForItem(item.id);

        // Check if any movement references the supplier batch
        final hasSupplierBatch = movements.any((movement) => movement.items.any(
            (movementItem) =>
                movementItem.customAttributes?['supplierBatchNumber'] ==
                supplierBatchNumber));

        if (hasSupplierBatch) {
          // Find the specific batch lot number for this supplier batch
          String? batchLotNumber;
          for (final movement in movements) {
            for (final movementItem in movement.items) {
              if (movementItem.customAttributes?['supplierBatchNumber'] ==
                  supplierBatchNumber) {
                batchLotNumber = movementItem.batchLotNumber;
                break;
              }
            }
            if (batchLotNumber != null) break;
          }

          final report = await generateTraceabilityReport(
            itemId: item.id,
            batchLotNumber: batchLotNumber,
            generatedBy: generatedBy,
          );
          reports.add(report);
        }
      }

      return reports;
    } catch (e) {
      throw Exception('Failed to find items by supplier batch: $e');
    }
  }

  /// Generate recall report for a specific batch or supplier
  Future<RecallReport> generateRecallReport({
    String? batchLotNumber,
    String? supplierBatchNumber,
    String? supplierId,
    DateTime? fromDate,
    DateTime? toDate,
    required String generatedBy,
  }) async {
    try {
      final affectedItems = <TraceabilityReport>[];
      final affectedCustomers = <String>{};
      final affectedLocations = <String>{};
      double totalQuantityAffected = 0.0;
      double totalValueAffected = 0.0;

      // Find all affected items based on criteria
      if (supplierBatchNumber != null) {
        final reports = await findItemsBySupplierBatch(
          supplierBatchNumber: supplierBatchNumber,
          generatedBy: generatedBy,
        );
        affectedItems.addAll(reports);
      } else if (batchLotNumber != null) {
        // Find items with this specific batch
        final allItems = await _repository.getItems();
        for (final item in allItems) {
          try {
            final report = await generateTraceabilityReport(
              itemId: item.id,
              batchLotNumber: batchLotNumber,
              generatedBy: generatedBy,
            );
            if (report.traceabilityRecords.isNotEmpty) {
              affectedItems.add(report);
            }
          } catch (e) {
            // Item doesn't have this batch, continue
          }
        }
      }

      // Analyze affected items
      for (final report in affectedItems) {
        totalQuantityAffected += report.currentQuantity;

        // Extract customer and location information
        for (final record in report.traceabilityRecords) {
          if (record.customerInfo != null) {
            affectedCustomers.add(record.customerInfo!);
          }
          affectedLocations.add(record.location);
        }
      }

      return RecallReport(
        recallId: 'RECALL-${DateTime.now().millisecondsSinceEpoch}',
        recallReason: 'Quality issue or safety concern',
        affectedItems: affectedItems,
        affectedCustomers: affectedCustomers.toList(),
        affectedLocations: affectedLocations.toList(),
        totalQuantityAffected: totalQuantityAffected,
        totalValueAffected: totalValueAffected,
        generatedAt: DateTime.now(),
        generatedBy: generatedBy,
      );
    } catch (e) {
      throw Exception('Failed to generate recall report: $e');
    }
  }

  /// Generate summary from traceability records
  TraceabilitySummary _generateSummary(List<TraceabilityRecord> records) {
    if (records.isEmpty) {
      return const TraceabilitySummary(
        totalMovements: 0,
        firstReceiptDate: null,
        lastMovementDate: null,
        totalInbound: 0.0,
        totalOutbound: 0.0,
        daysInInventory: 0,
        locationsVisited: [],
        qualityStatusChanges: 0,
        suppliersInvolved: [],
        customersServed: [],
        productionOrdersUsed: [],
      );
    }

    final firstReceiptDate = records.first.movementDate;
    final lastMovementDate = records.last.movementDate;
    final daysInInventory =
        lastMovementDate.difference(firstReceiptDate).inDays;

    final totalInbound = records
        .where((r) => r.isInbound)
        .fold<double>(0.0, (sum, r) => sum + r.quantity);

    final totalOutbound = records
        .where((r) => r.isOutbound)
        .fold<double>(0.0, (sum, r) => sum + r.quantity.abs());

    final locationsVisited = records.map((r) => r.location).toSet().toList();

    final qualityStatusChanges = records
        .where(
            (r) => r.movementType == InventoryMovementType.qualityStatusUpdate)
        .length;

    final suppliersInvolved = records
        .where((r) => r.supplierInfo != null)
        .map((r) => r.supplierInfo!)
        .toSet()
        .toList();

    final customersServed = records
        .where((r) => r.customerInfo != null)
        .map((r) => r.customerInfo!)
        .toSet()
        .toList();

    final productionOrdersUsed = records
        .where((r) => r.productionOrderInfo != null)
        .map((r) => r.productionOrderInfo!)
        .toSet()
        .toList();

    return TraceabilitySummary(
      totalMovements: records.length,
      firstReceiptDate: firstReceiptDate,
      lastMovementDate: lastMovementDate,
      totalInbound: totalInbound,
      totalOutbound: totalOutbound,
      daysInInventory: daysInInventory,
      locationsVisited: locationsVisited,
      qualityStatusChanges: qualityStatusChanges,
      suppliersInvolved: suppliersInvolved,
      customersServed: customersServed,
      productionOrdersUsed: productionOrdersUsed,
    );
  }

  /// Extract supplier information from movement
  String? _extractSupplierInfo(InventoryMovementModel movement) {
    if (movement.movementType == InventoryMovementType.receipt ||
        movement.movementType == InventoryMovementType.purchaseReceipt) {
      return movement.referenceNumber; // Assuming this contains supplier info
    }
    return null;
  }

  /// Extract customer information from movement
  String? _extractCustomerInfo(InventoryMovementModel movement) {
    if (movement.movementType == InventoryMovementType.salesIssue ||
        movement.movementType == InventoryMovementType.saleShipment) {
      return movement.referenceNumber; // Assuming this contains customer info
    }
    return null;
  }

  /// Extract production order information from movement
  String? _extractProductionOrderInfo(InventoryMovementModel movement) {
    if (movement.movementType == InventoryMovementType.productionIssue ||
        movement.movementType == InventoryMovementType.productionOutput) {
      return movement
          .referenceNumber; // Assuming this contains production order info
    }
    return null;
  }
}

/// Recall report for affected items
class RecallReport {
  const RecallReport({
    required this.recallId,
    required this.recallReason,
    required this.affectedItems,
    required this.affectedCustomers,
    required this.affectedLocations,
    required this.totalQuantityAffected,
    required this.totalValueAffected,
    required this.generatedAt,
    required this.generatedBy,
  });

  final String recallId;
  final String recallReason;
  final List<TraceabilityReport> affectedItems;
  final List<String> affectedCustomers;
  final List<String> affectedLocations;
  final double totalQuantityAffected;
  final double totalValueAffected;
  final DateTime generatedAt;
  final String generatedBy;
}

/// Provider for TraceabilityReportUseCase
final traceabilityReportUseCaseProvider =
    Provider<TraceabilityReportUseCase>((ref) {
  return TraceabilityReportUseCase(
    ref.watch(repo_provider.inventoryRepositoryProvider),
  );
});
