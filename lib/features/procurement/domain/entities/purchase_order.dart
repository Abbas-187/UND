enum PurchaseOrderStatus {
  draft,
  submitted,
  approved,
  rejected,
  partiallyReceived,
  received,
  cancelled,
  closed
}

class PurchaseOrderItem {

  const PurchaseOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    this.expectedDeliveryDate,
    this.notes,
  });
  final String id;
  final String productId;
  final String productName;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final DateTime? expectedDeliveryDate;
  final String? notes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseOrderItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class PurchaseOrder {

  const PurchaseOrder({
    required this.id,
    required this.orderNumber,
    required this.supplierId,
    required this.supplierName,
    required this.orderDate,
    this.approvalDate,
    required this.expectedDeliveryDate,
    required this.status,
    required this.items,
    required this.totalAmount,
    this.paymentTerms,
    this.shippingTerms,
    this.notes,
    this.approvedBy,
    required this.createdAt,
    this.updatedAt,
  });
  final String id;
  final String orderNumber;
  final String supplierId;
  final String supplierName;
  final DateTime orderDate;
  final DateTime? approvalDate;
  final DateTime expectedDeliveryDate;
  final PurchaseOrderStatus status;
  final List<PurchaseOrderItem> items;
  final double totalAmount;
  final String? paymentTerms;
  final String? shippingTerms;
  final String? notes;
  final String? approvedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseOrder &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
