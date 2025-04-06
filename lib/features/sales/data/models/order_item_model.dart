class OrderItemModel {

  const OrderItemModel({
    this.id,
    required this.productId,
    required this.productName,
    required this.productCode,
    this.productCategory,
    required this.quantity,
    required this.uom,
    required this.unitPrice,
    this.discountPercent,
    this.discountAmount,
    this.taxPercent,
    this.taxAmount,
    this.notes,
    this.batchNumber,
    this.expiryDate,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String?,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productCode: json['productCode'] as String,
      productCategory: json['productCategory'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      uom: json['uom'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      discountPercent: json['discountPercent'] != null
          ? (json['discountPercent'] as num).toDouble()
          : null,
      discountAmount: json['discountAmount'] != null
          ? (json['discountAmount'] as num).toDouble()
          : null,
      taxPercent: json['taxPercent'] != null
          ? (json['taxPercent'] as num).toDouble()
          : null,
      taxAmount: json['taxAmount'] != null
          ? (json['taxAmount'] as num).toDouble()
          : null,
      notes: json['notes'] as String?,
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
    );
  }
  final String? id;
  final String productId;
  final String productName;
  final String productCode;
  final String? productCategory;
  final double quantity;
  final String uom; // Unit of Measure
  final double unitPrice;
  final double? discountPercent;
  final double? discountAmount;
  final double? taxPercent;
  final double? taxAmount;
  final String? notes;
  final String? batchNumber;
  final DateTime? expiryDate;

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'productId': productId,
      'productName': productName,
      'productCode': productCode,
      if (productCategory != null) 'productCategory': productCategory,
      'quantity': quantity,
      'uom': uom,
      'unitPrice': unitPrice,
      if (discountPercent != null) 'discountPercent': discountPercent,
      if (discountAmount != null) 'discountAmount': discountAmount,
      if (taxPercent != null) 'taxPercent': taxPercent,
      if (taxAmount != null) 'taxAmount': taxAmount,
      if (notes != null) 'notes': notes,
      if (batchNumber != null) 'batchNumber': batchNumber,
      if (expiryDate != null) 'expiryDate': expiryDate!.toIso8601String(),
    };
  }
}

// Extension methods for additional functionality
extension OrderItemModelX on OrderItemModel {
  double calculateLineTotal() {
    final baseAmount = quantity * unitPrice;
    final discount = discountAmount ??
        (discountPercent != null ? baseAmount * (discountPercent! / 100) : 0);
    final tax = taxAmount ??
        (taxPercent != null
            ? (baseAmount - discount) * (taxPercent! / 100)
            : 0);
    return baseAmount - discount + tax;
  }
}
