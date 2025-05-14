import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'inventory_movement_item_model.dart';

// Generate freezed files
part 'inventory_movement_model.freezed.dart';
part 'inventory_movement_model.g.dart';

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

  // Added missing enum constants referenced elsewhere
  PO_RECEIPT, // Purchase order receipt alias
  TRANSFER_IN, // Transfer in alias
  PRODUCTION_ISSUE, // Production issue alias
  SALES_RETURN, // Sales return alias
  ADJUSTMENT_OTHER, // Other adjustment alias
  TRANSFER_OUT, // Transfer out alias
  SALE_SHIPMENT, // Sale shipment alias
  ADJUSTMENT_DAMAGE, // Damage adjustment alias
  ADJUSTMENT_CYCLE_COUNT_GAIN, // Cycle count gain alias
  ADJUSTMENT_CYCLE_COUNT_LOSS, // Cycle count loss alias
  QUALITY_STATUS_UPDATE, // Quality status update alias
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
  PENDING,
  APPROVED,
  REJECTED,
  CANCELLED,
}

/// Model representing an inventory movement
@freezed
abstract class InventoryMovementModel with _$InventoryMovementModel {
  const InventoryMovementModel._(); // Added for custom methods

  /// Creates an inventory movement model
  const factory InventoryMovementModel({
    String? id,
    required String documentNumber,
    required DateTime movementDate,
    required InventoryMovementType movementType,
    required String warehouseId,
    String? sourceWarehouseId,
    String? targetWarehouseId,
    String? referenceNumber,
    String? referenceType,
    List<String>? referenceDocuments,
    String? reasonNotes,
    String? reasonCode,
    String? initiatingEmployeeName,
    String? approverEmployeeName,
    @Default([]) List<InventoryMovementItemModel> items,
    @Default(InventoryMovementStatus.draft) InventoryMovementStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String initiatingEmployeeId,
    String? approvedById,
    DateTime? approvedAt,
  }) = _InventoryMovementModel;

  /// Creates an InventoryMovementModel from JSON
  factory InventoryMovementModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryMovementModelFromJson(json);

  /// Convert to Firestore format with Timestamps
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // Convert DateTime to Timestamp for Firestore
    json['movementDate'] = Timestamp.fromDate(movementDate);
    json['createdAt'] = Timestamp.fromDate(createdAt);
    json['updatedAt'] = Timestamp.fromDate(updatedAt);
    if (approvedAt != null) {
      json['approvedAt'] = Timestamp.fromDate(approvedAt!);
    }
    return json;
  }

  /// Alias for the document ID
  String get movementId => id ?? '';

  /// Alias for movement date to match code expectations
  DateTime get timestamp => movementDate;

  /// Aliases for source/destination location IDs
  String? get sourceLocationId => sourceWarehouseId;
  String? get destinationLocationId => targetWarehouseId;

  /// Aliases for location names (reuse warehouse fields)
  String? get sourceLocationName => sourceWarehouseId;
  String? get destinationLocationName => targetWarehouseId;

  /// Approval status mapped to ApprovalStatus enum for UI compatibility
  ApprovalStatus get approvalStatus {
    switch (status) {
      case InventoryMovementStatus.pending:
        return ApprovalStatus.PENDING;
      case InventoryMovementStatus.completed:
        return ApprovalStatus.APPROVED;
      case InventoryMovementStatus.cancelled:
        return ApprovalStatus.CANCELLED;
      default:
        return ApprovalStatus.PENDING;
    }
  }

  /// Alias for approvedById to match expected naming
  String? get approverEmployeeId => approvedById;

  /// Helper methods to check movement type
  bool get isInbound =>
      movementType == InventoryMovementType.receipt ||
      movementType == InventoryMovementType.return_ ||
      movementType == InventoryMovementType.production ||
      movementType == InventoryMovementType.purchaseReceipt ||
      movementType == InventoryMovementType.productionOutput;

  bool get isOutbound =>
      movementType == InventoryMovementType.issue ||
      movementType == InventoryMovementType.consumption ||
      movementType == InventoryMovementType.waste ||
      movementType == InventoryMovementType.expiry ||
      movementType == InventoryMovementType.salesIssue ||
      movementType == InventoryMovementType.productionConsumption ||
      movementType == InventoryMovementType.sample ||
      movementType == InventoryMovementType.scrapDisposal;

  bool get isTransfer =>
      movementType == InventoryMovementType.transfer ||
      movementType == InventoryMovementType.interWarehouseTransfer ||
      movementType == InventoryMovementType.intraWarehouseTransfer;

  bool get isAdjustment =>
      movementType == InventoryMovementType.adjustment ||
      movementType == InventoryMovementType.initialBalanceAdjustment ||
      movementType == InventoryMovementType.reservationAdjustment;

  bool get isQualityRelated =>
      movementType == InventoryMovementType.qualityStatusChange ||
      movementType == InventoryMovementType.qualityHold;

  // Check if reason notes are required for this movement type
  bool get requiresReasonNotes =>
      isAdjustment ||
      movementType == InventoryMovementType.waste ||
      movementType == InventoryMovementType.scrapDisposal ||
      movementType == InventoryMovementType.expiry ||
      isQualityRelated;

  // Validate if all required fields are present for audit
  bool isAuditCompliant() {
    // All movements require initiatingEmployeeId
    if (initiatingEmployeeId.isEmpty) {
      return false;
    }

    // Adjustments and other manual movements require reason notes
    if (requiresReasonNotes && (reasonNotes == null || reasonNotes!.isEmpty)) {
      return false;
    }

    // Check for reference document links where applicable
    if ((movementType == InventoryMovementType.salesIssue ||
            movementType == InventoryMovementType.purchaseReceipt) &&
        (referenceDocuments == null || referenceDocuments!.isEmpty)) {
      return false;
    }

    return true;
  }

  // Get simplified movement type string for display
  String get movementTypeDisplay {
    final typeString = movementType.toString().split('.').last;
    if (typeString == 'return_') return 'Return';

    // Convert camelCase to Title Case with spaces
    final result = typeString.replaceAllMapped(
        RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}');

    return result.substring(0, 1).toUpperCase() + result.substring(1);
  }
}
