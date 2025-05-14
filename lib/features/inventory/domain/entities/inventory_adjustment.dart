enum AdjustmentType {
  stockCount,
  damage,
  expiry,
  manual,
  return_to_supplier,
  system_correction,
  loss,
  transfer,
}

enum AdjustmentApprovalStatus {
  pending,
  approved,
  rejected,
}

class InventoryAdjustment {

  const InventoryAdjustment({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.adjustmentType,
    required this.quantity,
    required this.previousQuantity,
    required this.adjustedQuantity,
    required this.reason,
    required this.performedBy,
    required this.performedAt,
    this.notes,
    required this.categoryId,
    required this.categoryName,
    this.approvalStatus,
    this.approvedBy,
    this.approvedAt,
    this.documentReference,
  });
  final String id;
  final String itemId;
  final String itemName;
  final AdjustmentType adjustmentType;
  final double quantity;
  final double previousQuantity;
  final double adjustedQuantity;
  final String reason;
  final String performedBy;
  final DateTime performedAt;
  final String? notes;
  final String categoryId;
  final String categoryName;
  final AdjustmentApprovalStatus? approvalStatus;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? documentReference;

  InventoryAdjustment copyWith({
    String? id,
    String? itemId,
    String? itemName,
    AdjustmentType? adjustmentType,
    double? quantity,
    double? previousQuantity,
    double? adjustedQuantity,
    String? reason,
    String? performedBy,
    DateTime? performedAt,
    String? notes,
    String? categoryId,
    String? categoryName,
    AdjustmentApprovalStatus? approvalStatus,
    String? approvedBy,
    DateTime? approvedAt,
    String? documentReference,
  }) {
    return InventoryAdjustment(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      adjustmentType: adjustmentType ?? this.adjustmentType,
      quantity: quantity ?? this.quantity,
      previousQuantity: previousQuantity ?? this.previousQuantity,
      adjustedQuantity: adjustedQuantity ?? this.adjustedQuantity,
      reason: reason ?? this.reason,
      performedBy: performedBy ?? this.performedBy,
      performedAt: performedAt ?? this.performedAt,
      notes: notes ?? this.notes,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      documentReference: documentReference ?? this.documentReference,
    );
  }
}
