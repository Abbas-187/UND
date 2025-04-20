import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/purchase_order.dart' as entity;

/// Enum representing different statuses a purchase order can have
enum PurchaseOrderStatus {
  draft,
  pending,
  approved,
  declined,
  inProgress,
  delivered,
  completed,
  canceled
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
@immutable
class PurchaseOrderItemModel {
  const PurchaseOrderItemModel({
    this.id,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    required this.requiredByDate,
    this.notes,
  });

  /// Convert from map to model
  factory PurchaseOrderItemModel.fromMap(Map<String, dynamic> map) {
    return PurchaseOrderItemModel(
      id: map['id'],
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      unit: map['unit'] ?? '',
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      requiredByDate:
          (map['requiredByDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: map['notes'],
    );
  }

  /// Convert from domain entity
  factory PurchaseOrderItemModel.fromEntity(entity.PurchaseOrderItem entity) {
    return PurchaseOrderItemModel(
      id: entity.id,
      itemId: entity.itemId,
      itemName: entity.itemName,
      quantity: entity.quantity,
      unit: entity.unit,
      unitPrice: entity.unitPrice,
      totalPrice: entity.totalPrice,
      requiredByDate: entity.requiredByDate,
      notes: entity.notes,
    );
  }

  final String? id;
  final String itemId;
  final String itemName;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final DateTime requiredByDate;
  final String? notes;

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'requiredByDate': Timestamp.fromDate(requiredByDate),
      'notes': notes,
    };
  }

  /// Convert to domain entity
  entity.PurchaseOrderItem toEntity() {
    return entity.PurchaseOrderItem(
      id: id ?? '',
      itemId: itemId,
      itemName: itemName,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      requiredByDate: requiredByDate,
      notes: notes,
    );
  }
}

/// Document that can be attached to a purchase order.
@immutable
class SupportingDocumentModel {
  const SupportingDocumentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.uploadDate,
  });

  /// Convert from map to model
  factory SupportingDocumentModel.fromMap(Map<String, dynamic> map) {
    return SupportingDocumentModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      url: map['url'] ?? '',
      uploadDate: (map['uploadDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert from domain entity
  factory SupportingDocumentModel.fromEntity(entity.SupportingDocument entity) {
    return SupportingDocumentModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      url: entity.url,
      uploadDate: entity.uploadDate,
    );
  }

  final String id;
  final String name;
  final String type;
  final String url;
  final DateTime uploadDate;

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'url': url,
      'uploadDate': Timestamp.fromDate(uploadDate),
    };
  }

  /// Convert to domain entity
  entity.SupportingDocument toEntity() {
    return entity.SupportingDocument(
      id: id,
      name: name,
      type: type,
      url: url,
      uploadDate: uploadDate,
    );
  }
}

/// Data model for PurchaseOrder
@immutable
class PurchaseOrderModel {
  const PurchaseOrderModel({
    this.id,
    required this.procurementPlanId,
    required this.poNumber,
    required this.requestDate,
    required this.requestedBy,
    required this.supplierId,
    required this.supplierName,
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.reasonForRequest,
    required this.intendedUse,
    required this.quantityJustification,
    required this.supportingDocuments,
    this.approvalDate,
    this.approvedBy,
    this.deliveryDate,
    this.completionDate,
    this.orderNumber,
    this.createdAt,
    this.expectedDeliveryDate,
  });

  /// Convert from Firestore document to PurchaseOrderModel
  factory PurchaseOrderModel.fromMap(Map<String, dynamic> map, String docId) {
    final itemsData =
        (map['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final docsData = (map['supportingDocuments'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    return PurchaseOrderModel(
      id: docId,
      procurementPlanId: map['procurementPlanId'] ?? '',
      poNumber: map['poNumber'] ?? '',
      orderNumber: map['orderNumber'] ?? map['poNumber'] ?? '',
      requestDate:
          (map['requestDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      requestedBy: map['requestedBy'] ?? '',
      supplierId: map['supplierId'] ?? '',
      supplierName: map['supplierName'] ?? '',
      status: map['status'] ?? 'draft',
      items: itemsData
          .map((item) => PurchaseOrderItemModel.fromMap(item))
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      reasonForRequest: map['reasonForRequest'] ?? '',
      intendedUse: map['intendedUse'] ?? '',
      quantityJustification: map['quantityJustification'] ?? '',
      supportingDocuments:
          docsData.map((doc) => SupportingDocumentModel.fromMap(doc)).toList(),
      approvalDate: (map['approvalDate'] as Timestamp?)?.toDate(),
      approvedBy: map['approvedBy'],
      deliveryDate: (map['deliveryDate'] as Timestamp?)?.toDate(),
      completionDate: (map['completionDate'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expectedDeliveryDate:
          (map['expectedDeliveryDate'] as Timestamp?)?.toDate() ??
              (map['deliveryDate'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert from Domain Entity to Model
  factory PurchaseOrderModel.fromEntity(entity.PurchaseOrder entity) {
    return PurchaseOrderModel(
      id: entity.id,
      procurementPlanId: entity.procurementPlanId,
      poNumber: entity.poNumber,
      orderNumber: entity.poNumber,
      requestDate: entity.requestDate,
      requestedBy: entity.requestedBy,
      supplierId: entity.supplierId,
      supplierName: entity.supplierName,
      status: entity.status.toString().split('.').last,
      items: entity.items
          .map((item) => PurchaseOrderItemModel.fromEntity(item))
          .toList(),
      totalAmount: entity.totalAmount,
      reasonForRequest: entity.reasonForRequest,
      intendedUse: entity.intendedUse,
      quantityJustification: entity.quantityJustification,
      supportingDocuments: entity.supportingDocuments
          .map((doc) => SupportingDocumentModel.fromEntity(doc))
          .toList(),
      approvalDate: entity.approvalDate,
      approvedBy: entity.approvedBy,
      deliveryDate: entity.deliveryDate,
      completionDate: entity.completionDate,
      createdAt: entity.requestDate,
      expectedDeliveryDate: entity.deliveryDate,
    );
  }
  final String? id;
  final String procurementPlanId;
  final String poNumber;
  final String? orderNumber;
  final DateTime requestDate;
  final String requestedBy;
  final String supplierId;
  final String supplierName;
  final String status;
  final List<PurchaseOrderItemModel> items;
  final double totalAmount;
  final String reasonForRequest;
  final String intendedUse;
  final String quantityJustification;
  final List<SupportingDocumentModel> supportingDocuments;
  final DateTime? approvalDate;
  final String? approvedBy;
  final DateTime? deliveryDate;
  final DateTime? completionDate;
  final DateTime? createdAt;
  final DateTime? expectedDeliveryDate;

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'procurementPlanId': procurementPlanId,
      'poNumber': poNumber,
      'orderNumber': orderNumber ?? poNumber,
      'requestDate': Timestamp.fromDate(requestDate),
      'requestedBy': requestedBy,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'status': status,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'reasonForRequest': reasonForRequest,
      'intendedUse': intendedUse,
      'quantityJustification': quantityJustification,
      'supportingDocuments':
          supportingDocuments.map((doc) => doc.toMap()).toList(),
      'approvalDate':
          approvalDate != null ? Timestamp.fromDate(approvalDate!) : null,
      'approvedBy': approvedBy,
      'deliveryDate':
          deliveryDate != null ? Timestamp.fromDate(deliveryDate!) : null,
      'completionDate':
          completionDate != null ? Timestamp.fromDate(completionDate!) : null,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : Timestamp.fromDate(requestDate),
      'expectedDeliveryDate': expectedDeliveryDate != null
          ? Timestamp.fromDate(expectedDeliveryDate!)
          : (deliveryDate != null ? Timestamp.fromDate(deliveryDate!) : null),
    };
  }

  /// Convert to Domain Entity
  entity.PurchaseOrder toEntity() {
    return entity.PurchaseOrder(
      id: id ?? '',
      procurementPlanId: procurementPlanId,
      poNumber: poNumber,
      requestDate: requestDate,
      requestedBy: requestedBy,
      supplierId: supplierId,
      supplierName: supplierName,
      status: _mapStringToPurchaseOrderStatus(status),
      items: items.map((item) => item.toEntity()).toList(),
      totalAmount: totalAmount,
      reasonForRequest: reasonForRequest,
      intendedUse: intendedUse,
      quantityJustification: quantityJustification,
      supportingDocuments:
          supportingDocuments.map((doc) => doc.toEntity()).toList(),
      approvalDate: approvalDate,
      approvedBy: approvedBy,
      deliveryDate: deliveryDate,
      completionDate: completionDate,
    );
  }

  /// Map string to PurchaseOrderStatus enum
  entity.PurchaseOrderStatus _mapStringToPurchaseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return entity.PurchaseOrderStatus.draft;
      case 'pending':
        return entity.PurchaseOrderStatus.pending;
      case 'approved':
        return entity.PurchaseOrderStatus.approved;
      case 'declined':
        return entity.PurchaseOrderStatus.declined;
      case 'inprogress':
        return entity.PurchaseOrderStatus.inProgress;
      case 'delivered':
        return entity.PurchaseOrderStatus.delivered;
      case 'completed':
        return entity.PurchaseOrderStatus.completed;
      case 'canceled':
        return entity.PurchaseOrderStatus.canceled;
      default:
        return entity.PurchaseOrderStatus.draft;
    }
  }

  PurchaseOrderModel copyWith({
    String? id,
    String? procurementPlanId,
    String? poNumber,
    String? orderNumber,
    DateTime? requestDate,
    String? requestedBy,
    String? supplierId,
    String? supplierName,
    String? status,
    List<PurchaseOrderItemModel>? items,
    double? totalAmount,
    String? reasonForRequest,
    String? intendedUse,
    String? quantityJustification,
    List<SupportingDocumentModel>? supportingDocuments,
    DateTime? approvalDate,
    String? approvedBy,
    DateTime? deliveryDate,
    DateTime? completionDate,
    DateTime? createdAt,
    DateTime? expectedDeliveryDate,
  }) {
    return PurchaseOrderModel(
      id: id ?? this.id,
      procurementPlanId: procurementPlanId ?? this.procurementPlanId,
      poNumber: poNumber ?? this.poNumber,
      orderNumber: orderNumber ?? this.orderNumber,
      requestDate: requestDate ?? this.requestDate,
      requestedBy: requestedBy ?? this.requestedBy,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      status: status ?? this.status,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      reasonForRequest: reasonForRequest ?? this.reasonForRequest,
      intendedUse: intendedUse ?? this.intendedUse,
      quantityJustification:
          quantityJustification ?? this.quantityJustification,
      supportingDocuments: supportingDocuments ?? this.supportingDocuments,
      approvalDate: approvalDate ?? this.approvalDate,
      approvedBy: approvedBy ?? this.approvedBy,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      completionDate: completionDate ?? this.completionDate,
      createdAt: createdAt ?? this.createdAt,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
    );
  }
}
