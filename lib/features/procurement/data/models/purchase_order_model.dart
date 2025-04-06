import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/purchase_order.dart' as entity;

/// Enum representing different statuses a purchase order can have
enum PurchaseOrderStatus {
  draft,
  submitted,
  approved,
  rejected,
  received,
  cancelled
}

/// Enum representing different payment statuses for a purchase order
enum PaymentStatus { pending, partial, paid }

/// Converts [PurchaseOrderStatus] enum to string
String purchaseOrderStatusToString(PurchaseOrderStatus status) {
  return status.toString().split('.').last;
}

/// Converts string to [PurchaseOrderStatus] enum
PurchaseOrderStatus purchaseOrderStatusFromString(String status) {
  return PurchaseOrderStatus.values.firstWhere(
    (e) => e.toString().split('.').last == status,
    orElse: () => throw ArgumentError('Invalid purchase order status: $status'),
  );
}

/// Converts [PaymentStatus] enum to string
String paymentStatusToString(PaymentStatus status) {
  return status.toString().split('.').last;
}

/// Converts string to [PaymentStatus] enum
PaymentStatus paymentStatusFromString(String status) {
  return PaymentStatus.values.firstWhere(
    (e) => e.toString().split('.').last == status,
    orElse: () => throw ArgumentError('Invalid payment status: $status'),
  );
}

/// Data model for PurchaseOrderItem
class PurchaseOrderItemModel {

  const PurchaseOrderItemModel({
    this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    this.expectedDeliveryDate,
    this.notes,
  });

  /// Convert from map to model
  factory PurchaseOrderItemModel.fromMap(Map<String, dynamic> map) {
    return PurchaseOrderItemModel(
      id: map['id'],
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      unit: map['unit'] ?? '',
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      expectedDeliveryDate:
          (map['expectedDeliveryDate'] as Timestamp?)?.toDate(),
      notes: map['notes'],
    );
  }

  /// Convert from domain entity
  factory PurchaseOrderItemModel.fromEntity(entity.PurchaseOrderItem entity) {
    return PurchaseOrderItemModel(
      id: entity.id,
      productId: entity.productId,
      productName: entity.productName,
      quantity: entity.quantity,
      unit: entity.unit,
      unitPrice: entity.unitPrice,
      totalPrice: entity.totalPrice,
      expectedDeliveryDate: entity.expectedDeliveryDate,
      notes: entity.notes,
    );
  }
  final String? id;
  final String productId;
  final String productName;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final DateTime? expectedDeliveryDate;
  final String? notes;

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'expectedDeliveryDate': expectedDeliveryDate != null
          ? Timestamp.fromDate(expectedDeliveryDate!)
          : null,
      'notes': notes,
    };
  }

  /// Convert to domain entity
  entity.PurchaseOrderItem toEntity() {
    return entity.PurchaseOrderItem(
      id: id ?? '',
      productId: productId,
      productName: productName,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      expectedDeliveryDate: expectedDeliveryDate,
      notes: notes,
    );
  }
}

/// Data model for PurchaseOrder
class PurchaseOrderModel {

  const PurchaseOrderModel({
    this.id,
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
    this.createdAt,
    this.updatedAt,
  });

  /// Convert from Firestore document to PurchaseOrderModel
  factory PurchaseOrderModel.fromMap(Map<String, dynamic> map, String docId) {
    final itemsData =
        (map['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    return PurchaseOrderModel(
      id: docId,
      orderNumber: map['orderNumber'] ?? '',
      supplierId: map['supplierId'] ?? '',
      supplierName: map['supplierName'] ?? '',
      orderDate: (map['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approvalDate: (map['approvalDate'] as Timestamp?)?.toDate(),
      expectedDeliveryDate:
          (map['expectedDeliveryDate'] as Timestamp?)?.toDate() ??
              DateTime.now(),
      status: map['status'] ?? 'draft',
      items: itemsData
          .map((item) => PurchaseOrderItemModel.fromMap(item))
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      paymentTerms: map['paymentTerms'],
      shippingTerms: map['shippingTerms'],
      notes: map['notes'],
      approvedBy: map['approvedBy'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert from Domain Entity to Model
  factory PurchaseOrderModel.fromEntity(entity.PurchaseOrder entity) {
    return PurchaseOrderModel(
      id: entity.id,
      orderNumber: entity.orderNumber,
      supplierId: entity.supplierId,
      supplierName: entity.supplierName,
      orderDate: entity.orderDate,
      approvalDate: entity.approvalDate,
      expectedDeliveryDate: entity.expectedDeliveryDate,
      status: entity.status.toString().split('.').last,
      items: entity.items
          .map((item) => PurchaseOrderItemModel.fromEntity(item))
          .toList(),
      totalAmount: entity.totalAmount,
      paymentTerms: entity.paymentTerms,
      shippingTerms: entity.shippingTerms,
      notes: entity.notes,
      approvedBy: entity.approvedBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
  final String? id;
  final String orderNumber;
  final String supplierId;
  final String supplierName;
  final DateTime orderDate;
  final DateTime? approvalDate;
  final DateTime expectedDeliveryDate;
  final String status;
  final List<PurchaseOrderItemModel> items;
  final double totalAmount;
  final String? paymentTerms;
  final String? shippingTerms;
  final String? notes;
  final String? approvedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'orderDate': Timestamp.fromDate(orderDate),
      'approvalDate':
          approvalDate != null ? Timestamp.fromDate(approvalDate!) : null,
      'expectedDeliveryDate': Timestamp.fromDate(expectedDeliveryDate),
      'status': status,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'paymentTerms': paymentTerms,
      'shippingTerms': shippingTerms,
      'notes': notes,
      'approvedBy': approvedBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Convert to Domain Entity
  entity.PurchaseOrder toEntity() {
    return entity.PurchaseOrder(
      id: id ?? '',
      orderNumber: orderNumber,
      supplierId: supplierId,
      supplierName: supplierName,
      orderDate: orderDate,
      approvalDate: approvalDate,
      expectedDeliveryDate: expectedDeliveryDate,
      status: _mapStringToPurchaseOrderStatus(status),
      items: items.map((item) => item.toEntity()).toList(),
      totalAmount: totalAmount,
      paymentTerms: paymentTerms,
      shippingTerms: shippingTerms,
      notes: notes,
      approvedBy: approvedBy,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt,
    );
  }

  /// Map string to PurchaseOrderStatus enum
  entity.PurchaseOrderStatus _mapStringToPurchaseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return entity.PurchaseOrderStatus.draft;
      case 'submitted':
        return entity.PurchaseOrderStatus.submitted;
      case 'approved':
        return entity.PurchaseOrderStatus.approved;
      case 'rejected':
        return entity.PurchaseOrderStatus.rejected;
      case 'received':
        return entity.PurchaseOrderStatus.received;
      case 'cancelled':
        return entity.PurchaseOrderStatus.cancelled;
      default:
        return entity.PurchaseOrderStatus.draft;
    }
  }

  PurchaseOrderModel copyWith({
    String? id,
    String? orderNumber,
    String? supplierId,
    String? supplierName,
    DateTime? orderDate,
    DateTime? approvalDate,
    DateTime? expectedDeliveryDate,
    String? status,
    List<PurchaseOrderItemModel>? items,
    double? totalAmount,
    String? paymentTerms,
    String? shippingTerms,
    String? notes,
    String? approvedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseOrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      orderDate: orderDate ?? this.orderDate,
      approvalDate: approvalDate ?? this.approvalDate,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      status: status ?? this.status,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      shippingTerms: shippingTerms ?? this.shippingTerms,
      notes: notes ?? this.notes,
      approvedBy: approvedBy ?? this.approvedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
