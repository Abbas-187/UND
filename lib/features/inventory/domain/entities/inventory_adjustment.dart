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
    this.approvalStatus = AdjustmentApprovalStatus.pending,
    this.approvedBy,
    this.approvedAt,
    this.categoryId,
    this.categoryName,
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
  final AdjustmentApprovalStatus approvalStatus;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? categoryId;
  final String? categoryName;
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
    AdjustmentApprovalStatus? approvalStatus,
    String? approvedBy,
    DateTime? approvedAt,
    String? categoryId,
    String? categoryName,
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
      approvalStatus: approvalStatus ?? this.approvalStatus,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      documentReference: documentReference ?? this.documentReference,
    );
  }

  factory InventoryAdjustment.fromJson(Map<String, dynamic> json) {
    return InventoryAdjustment(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      itemName: json['itemName'] as String,
      adjustmentType: AdjustmentType.values.firstWhere(
        (e) => e.toString() == 'AdjustmentType.${json['adjustmentType']}',
        orElse: () => AdjustmentType.manual,
      ),
      quantity: (json['quantity'] as num).toDouble(),
      previousQuantity: (json['previousQuantity'] as num).toDouble(),
      adjustedQuantity: (json['adjustedQuantity'] as num).toDouble(),
      reason: json['reason'] as String,
      performedBy: json['performedBy'] as String,
      performedAt: DateTime.parse(json['performedAt'] as String),
      notes: json['notes'] as String?,
      approvalStatus: AdjustmentApprovalStatus.values.firstWhere(
        (e) =>
            e.toString() ==
            'AdjustmentApprovalStatus.${json['approvalStatus']}',
        orElse: () => AdjustmentApprovalStatus.pending,
      ),
      approvedBy: json['approvedBy'] as String?,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      documentReference: json['documentReference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'itemName': itemName,
      'adjustmentType': adjustmentType.toString().split('.').last,
      'quantity': quantity,
      'previousQuantity': previousQuantity,
      'adjustedQuantity': adjustedQuantity,
      'reason': reason,
      'performedBy': performedBy,
      'performedAt': performedAt.toIso8601String(),
      'notes': notes,
      'approvalStatus': approvalStatus.toString().split('.').last,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'categoryId': categoryId,
      'categoryName': categoryName,
      'documentReference': documentReference,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryAdjustment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          itemId == other.itemId &&
          adjustmentType == other.adjustmentType &&
          quantity == other.quantity &&
          performedAt == other.performedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      itemId.hashCode ^
      adjustmentType.hashCode ^
      quantity.hashCode ^
      performedAt.hashCode;
}

enum AdjustmentType {
  manual,
  stockCount,
  expiry,
  damage,
  loss,
  return_to_supplier,
  system_correction,
  transfer,
}

enum AdjustmentApprovalStatus {
  pending,
  approved,
  rejected,
}
