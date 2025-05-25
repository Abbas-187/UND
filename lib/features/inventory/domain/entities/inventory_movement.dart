import 'package:flutter/foundation.dart';

/// Enumeration of inventory movement types
enum InventoryMovementType {
  receipt, // Goods receipt from supplier
  issue, // Issue to production or customer
  return_, // Return from customer
  transfer, // Transfer between warehouses
  adjustment, // Inventory adjustment (count)
  production, // Production receipt
  consumption, // Consumption in production
  waste, // Waste/scrap
  expiry, // Expiry write-off
  qualityStatusChange, // Quality status change (e.g., release, quarantine)
  repack, // Repacking operations
  sample, // Sample for quality testing
  salesIssue, // Specific issue for sales order
  purchaseReceipt, // Specific receipt against purchase order
  productionConsumption, // Consumption in production process
  productionOutput, // Output from production process
  interWarehouseTransfer, // Transfer between warehouses
  intraWarehouseTransfer, // Transfer within warehouse locations
  scrapDisposal, // Scrapping of damaged goods
  qualityHold, // Quality hold/release operations
  initialBalanceAdjustment, // Initial balance adjustment
  reservationAdjustment, // Reservation adjustments
  // Additional movement types
  poReceipt, // Purchase order receipt alias
  transferIn, // Transfer in alias
  productionIssue, // Production issue alias
  salesReturn, // Sales return alias
  adjustmentOther, // Other adjustment alias
  transferOut, // Transfer out alias
  saleShipment, // Sale shipment alias
  adjustmentDamage, // Damage adjustment alias
  adjustmentCycleCountGain, // Cycle count gain alias
  adjustmentCycleCountLoss, // Cycle count loss alias
  qualityStatusUpdate, // Quality status update alias
}

/// Enumeration of inventory movement statuses
enum InventoryMovementStatus {
  draft, // Movement is in draft mode
  pending, // Movement is pending approval
  completed, // Movement is completed
  cancelled, // Movement is cancelled
}

/// Enumeration of approval statuses for inventory movements
enum ApprovalStatus {
  pending,
  approved,
  rejected,
  cancelled,
}

/// Entity class representing an inventory movement
class InventoryMovement {
  /// Creates an inventory movement entity
  const InventoryMovement({
    this.id,
    required this.documentNumber,
    required this.movementDate,
    required this.movementType,
    required this.warehouseId,
    this.sourceWarehouseId,
    this.targetWarehouseId,
    this.referenceNumber,
    this.referenceType,
    this.referenceDocuments,
    this.reasonNotes,
    this.reasonCode,
    this.initiatingEmployeeName,
    this.approverEmployeeName,
    required this.items,
    this.status = InventoryMovementStatus.draft,
    required this.createdAt,
    required this.updatedAt,
    required this.initiatingEmployeeId,
    this.approvedById,
    this.approvedAt,
  });
  final String? id;
  final String documentNumber;
  final DateTime movementDate;
  final InventoryMovementType movementType;
  final String warehouseId;
  final String? sourceWarehouseId;
  final String? targetWarehouseId;
  final String? referenceNumber;
  final String? referenceType;
  final List<String>? referenceDocuments;
  final String? reasonNotes;
  final String? reasonCode;
  final String? initiatingEmployeeName;
  final String? approverEmployeeName;
  final List<InventoryMovementItem> items;
  final InventoryMovementStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String initiatingEmployeeId;
  final String? approvedById;
  final DateTime? approvedAt;

  /// Creates a copy of this InventoryMovement with the given fields replaced with new values
  InventoryMovement copyWith({
    String? id,
    String? documentNumber,
    DateTime? movementDate,
    InventoryMovementType? movementType,
    String? warehouseId,
    String? sourceWarehouseId,
    String? targetWarehouseId,
    String? referenceNumber,
    String? referenceType,
    List<String>? referenceDocuments,
    String? reasonNotes,
    String? reasonCode,
    String? initiatingEmployeeName,
    String? approverEmployeeName,
    List<InventoryMovementItem>? items,
    InventoryMovementStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? initiatingEmployeeId,
    String? approvedById,
    DateTime? approvedAt,
  }) {
    return InventoryMovement(
      id: id ?? this.id,
      documentNumber: documentNumber ?? this.documentNumber,
      movementDate: movementDate ?? this.movementDate,
      movementType: movementType ?? this.movementType,
      warehouseId: warehouseId ?? this.warehouseId,
      sourceWarehouseId: sourceWarehouseId ?? this.sourceWarehouseId,
      targetWarehouseId: targetWarehouseId ?? this.targetWarehouseId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      referenceType: referenceType ?? this.referenceType,
      referenceDocuments: referenceDocuments ?? this.referenceDocuments,
      reasonNotes: reasonNotes ?? this.reasonNotes,
      reasonCode: reasonCode ?? this.reasonCode,
      initiatingEmployeeName:
          initiatingEmployeeName ?? this.initiatingEmployeeName,
      approverEmployeeName: approverEmployeeName ?? this.approverEmployeeName,
      items: items ?? this.items,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      initiatingEmployeeId: initiatingEmployeeId ?? this.initiatingEmployeeId,
      approvedById: approvedById ?? this.approvedById,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InventoryMovement &&
        other.id == id &&
        other.documentNumber == documentNumber &&
        other.movementDate == movementDate &&
        other.movementType == movementType &&
        other.warehouseId == warehouseId &&
        other.sourceWarehouseId == sourceWarehouseId &&
        other.targetWarehouseId == targetWarehouseId &&
        other.referenceNumber == referenceNumber &&
        other.referenceType == referenceType &&
        listEquals(other.referenceDocuments, referenceDocuments) &&
        other.reasonNotes == reasonNotes &&
        other.reasonCode == reasonCode &&
        other.initiatingEmployeeName == initiatingEmployeeName &&
        other.approverEmployeeName == approverEmployeeName &&
        listEquals(other.items, items) &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.initiatingEmployeeId == initiatingEmployeeId &&
        other.approvedById == approvedById &&
        other.approvedAt == approvedAt;
  }

  @override
  int get hashCode {
    // Using Object.hash for the first set of properties
    final hash1 = Object.hash(
      id,
      documentNumber,
      movementDate,
      movementType,
      warehouseId,
      sourceWarehouseId,
      targetWarehouseId,
      referenceNumber,
      referenceType,
      Object.hashAll(referenceDocuments ?? []),
    );

    // Using Object.hash for the second set of properties
    final hash2 = Object.hash(
      reasonNotes,
      reasonCode,
      initiatingEmployeeName,
      approverEmployeeName,
      Object.hashAll(items),
      status,
      createdAt,
      updatedAt,
      initiatingEmployeeId,
      approvedById,
      approvedAt,
    );

    // Combining the two hashes
    return Object.hash(hash1, hash2);
  }
}

/// Entity representing an inventory movement item
class InventoryMovementItem {
  /// Creates an inventory movement item entity
  const InventoryMovementItem({
    this.id,
    required this.inventoryItemId,
    required this.itemCode,
    required this.itemName,
    required this.quantity,
    required this.unitOfMeasure,
    this.batchNumber,
    this.serialNumber,
    this.expiryDate,
    this.locationId,
    this.locationName,
    this.binLocation,
    this.notes,
    this.unitCost,
    this.totalCost,
    this.reasonCode,
    this.qualityStatus,
    this.referenceLineId,
  });
  final String? id;
  final String inventoryItemId;
  final String itemCode;
  final String itemName;
  final double quantity;
  final String unitOfMeasure;
  final String? batchNumber;
  final String? serialNumber;
  final DateTime? expiryDate;
  final String? locationId;
  final String? locationName;
  final String? binLocation;
  final String? notes;
  final double? unitCost;
  final double? totalCost;
  final String? reasonCode;
  final String? qualityStatus;
  final String? referenceLineId;

  /// Creates a copy of this InventoryMovementItem with the given fields replaced with new values
  InventoryMovementItem copyWith({
    String? id,
    String? inventoryItemId,
    String? itemCode,
    String? itemName,
    double? quantity,
    String? unitOfMeasure,
    String? batchNumber,
    String? serialNumber,
    DateTime? expiryDate,
    String? locationId,
    String? locationName,
    String? binLocation,
    String? notes,
    double? unitCost,
    double? totalCost,
    String? reasonCode,
    String? qualityStatus,
    String? referenceLineId,
  }) {
    return InventoryMovementItem(
      id: id ?? this.id,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      batchNumber: batchNumber ?? this.batchNumber,
      serialNumber: serialNumber ?? this.serialNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      binLocation: binLocation ?? this.binLocation,
      notes: notes ?? this.notes,
      unitCost: unitCost ?? this.unitCost,
      totalCost: totalCost ?? this.totalCost,
      reasonCode: reasonCode ?? this.reasonCode,
      qualityStatus: qualityStatus ?? this.qualityStatus,
      referenceLineId: referenceLineId ?? this.referenceLineId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InventoryMovementItem &&
        other.id == id &&
        other.inventoryItemId == inventoryItemId &&
        other.itemCode == itemCode &&
        other.itemName == itemName &&
        other.quantity == quantity &&
        other.unitOfMeasure == unitOfMeasure &&
        other.batchNumber == batchNumber &&
        other.serialNumber == serialNumber &&
        other.expiryDate == expiryDate &&
        other.locationId == locationId &&
        other.locationName == locationName &&
        other.binLocation == binLocation &&
        other.notes == notes &&
        other.unitCost == unitCost &&
        other.totalCost == totalCost &&
        other.reasonCode == reasonCode &&
        other.qualityStatus == qualityStatus &&
        other.referenceLineId == referenceLineId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      inventoryItemId,
      itemCode,
      itemName,
      quantity,
      unitOfMeasure,
      batchNumber,
      serialNumber,
      expiryDate,
      locationId,
      locationName,
      binLocation,
      notes,
      unitCost,
      totalCost,
      reasonCode,
      qualityStatus,
      referenceLineId,
    );
  }
}
