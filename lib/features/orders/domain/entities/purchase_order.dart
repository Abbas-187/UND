import 'package:uuid/uuid.dart';

class PurchaseOrderItem {
  final String id;
  final String productId;
  final String productName;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final String? notes;

  PurchaseOrderItem({
    String? id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    String? notes,
  })  : id = id ?? const Uuid().v4(),
        totalPrice = quantity * unitPrice,
        notes = notes;

  PurchaseOrderItem copyWith({
    String? id,
    String? productId,
    String? productName,
    double? quantity,
    String? unit,
    double? unitPrice,
    String? notes,
  }) {
    return PurchaseOrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'notes': notes,
    };
  }

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }
}

enum PurchaseOrderStatus {
  draft,
  submitted,
  approved,
  partiallyReceived,
  fullyReceived,
  cancelled,
  closed
}

class PurchaseOrder {
  final String id;
  final String orderNumber;
  final String supplierId;
  final String supplierName;
  final DateTime orderDate;
  final DateTime expectedDeliveryDate;
  final List<PurchaseOrderItem> items;
  final PurchaseOrderStatus status;
  final double totalAmount;
  final String? shippingAddress;
  final String? paymentTerms;
  final String? notes;
  final String? approvedBy;
  final DateTime? approvalDate;
  final List<Map<String, dynamic>>? receiptHistory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  PurchaseOrder({
    String? id,
    required this.orderNumber,
    required this.supplierId,
    required this.supplierName,
    required this.orderDate,
    required this.expectedDeliveryDate,
    required this.items,
    required this.status,
    this.shippingAddress,
    this.paymentTerms,
    this.notes,
    this.approvedBy,
    this.approvalDate,
    this.receiptHistory,
    required this.createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        totalAmount = items.fold(0, (sum, item) => sum + item.totalPrice),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  PurchaseOrder copyWith({
    String? id,
    String? orderNumber,
    String? supplierId,
    String? supplierName,
    DateTime? orderDate,
    DateTime? expectedDeliveryDate,
    List<PurchaseOrderItem>? items,
    PurchaseOrderStatus? status,
    String? shippingAddress,
    String? paymentTerms,
    String? notes,
    String? approvedBy,
    DateTime? approvalDate,
    List<Map<String, dynamic>>? receiptHistory,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      orderDate: orderDate ?? this.orderDate,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      items: items ?? this.items,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      notes: notes ?? this.notes,
      approvedBy: approvedBy ?? this.approvedBy,
      approvalDate: approvalDate ?? this.approvalDate,
      receiptHistory: receiptHistory ?? this.receiptHistory,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'orderDate': orderDate.toIso8601String(),
      'expectedDeliveryDate': expectedDeliveryDate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'status': status.toString().split('.').last,
      'totalAmount': totalAmount,
      'shippingAddress': shippingAddress,
      'paymentTerms': paymentTerms,
      'notes': notes,
      'approvedBy': approvedBy,
      'approvalDate': approvalDate?.toIso8601String(),
      'receiptHistory': receiptHistory,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String,
      orderDate: DateTime.parse(json['orderDate'] as String),
      expectedDeliveryDate:
          DateTime.parse(json['expectedDeliveryDate'] as String),
      items: (json['items'] as List)
          .map((item) =>
              PurchaseOrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      status: PurchaseOrderStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['status'],
        orElse: () => PurchaseOrderStatus.draft,
      ),
      shippingAddress: json['shippingAddress'] as String?,
      paymentTerms: json['paymentTerms'] as String?,
      notes: json['notes'] as String?,
      approvedBy: json['approvedBy'] as String?,
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'] as String)
          : null,
      receiptHistory: json['receiptHistory'] != null
          ? List<Map<String, dynamic>>.from(json['receiptHistory'] as List)
          : null,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
