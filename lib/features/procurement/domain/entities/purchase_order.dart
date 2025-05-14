import 'package:meta/meta.dart';

/// Status of a purchase order.
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

/// Represents a purchase order item.
@immutable
class PurchaseOrderItem {

  const PurchaseOrderItem({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    required this.requiredByDate,
    this.notes,
  });
  final String id;
  final String itemId;
  final String itemName;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final DateTime requiredByDate;
  final String? notes;

  PurchaseOrderItem copyWith({
    String? id,
    String? itemId,
    String? itemName,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? totalPrice,
    DateTime? requiredByDate,
    String? notes,
  }) {
    return PurchaseOrderItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      requiredByDate: requiredByDate ?? this.requiredByDate,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseOrderItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          itemId == other.itemId &&
          itemName == other.itemName &&
          quantity == other.quantity &&
          unit == other.unit &&
          unitPrice == other.unitPrice &&
          totalPrice == other.totalPrice &&
          requiredByDate == other.requiredByDate &&
          notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^
      itemId.hashCode ^
      itemName.hashCode ^
      quantity.hashCode ^
      unit.hashCode ^
      unitPrice.hashCode ^
      totalPrice.hashCode ^
      requiredByDate.hashCode ^
      notes.hashCode;
}

/// Document that can be attached to a purchase order.
@immutable
class SupportingDocument {

  const SupportingDocument({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.uploadDate,
  });
  final String id;
  final String name;
  final String type;
  final String url;
  final DateTime uploadDate;

  SupportingDocument copyWith({
    String? id,
    String? name,
    String? type,
    String? url,
    DateTime? uploadDate,
  }) {
    return SupportingDocument(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      url: url ?? this.url,
      uploadDate: uploadDate ?? this.uploadDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportingDocument &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          url == other.url &&
          uploadDate == other.uploadDate;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      url.hashCode ^
      uploadDate.hashCode;
}

/// Represents a purchase order.
@immutable
class PurchaseOrder {

  const PurchaseOrder({
    required this.id,
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
  });
  final String id;
  final String procurementPlanId;
  final String poNumber;
  final DateTime requestDate;
  final String requestedBy;
  final String supplierId;
  final String supplierName;
  final PurchaseOrderStatus status;
  final List<PurchaseOrderItem> items;
  final double totalAmount;
  final String reasonForRequest;
  final String intendedUse;
  final String quantityJustification;
  final List<SupportingDocument> supportingDocuments;
  final DateTime? approvalDate;
  final String? approvedBy;
  final DateTime? deliveryDate;
  final DateTime? completionDate;

  PurchaseOrder copyWith({
    String? id,
    String? procurementPlanId,
    String? poNumber,
    DateTime? requestDate,
    String? requestedBy,
    String? supplierId,
    String? supplierName,
    PurchaseOrderStatus? status,
    List<PurchaseOrderItem>? items,
    double? totalAmount,
    String? reasonForRequest,
    String? intendedUse,
    String? quantityJustification,
    List<SupportingDocument>? supportingDocuments,
    DateTime? approvalDate,
    String? approvedBy,
    DateTime? deliveryDate,
    DateTime? completionDate,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      procurementPlanId: procurementPlanId ?? this.procurementPlanId,
      poNumber: poNumber ?? this.poNumber,
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
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseOrder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          procurementPlanId == other.procurementPlanId &&
          poNumber == other.poNumber &&
          requestDate == other.requestDate &&
          requestedBy == other.requestedBy &&
          supplierId == other.supplierId &&
          supplierName == other.supplierName &&
          status == other.status &&
          items == other.items &&
          totalAmount == other.totalAmount &&
          reasonForRequest == other.reasonForRequest &&
          intendedUse == other.intendedUse &&
          quantityJustification == other.quantityJustification &&
          supportingDocuments == other.supportingDocuments &&
          approvalDate == other.approvalDate &&
          approvedBy == other.approvedBy &&
          deliveryDate == other.deliveryDate &&
          completionDate == other.completionDate;

  @override
  int get hashCode =>
      id.hashCode ^
      procurementPlanId.hashCode ^
      poNumber.hashCode ^
      requestDate.hashCode ^
      requestedBy.hashCode ^
      supplierId.hashCode ^
      supplierName.hashCode ^
      status.hashCode ^
      items.hashCode ^
      totalAmount.hashCode ^
      reasonForRequest.hashCode ^
      intendedUse.hashCode ^
      quantityJustification.hashCode ^
      supportingDocuments.hashCode ^
      approvalDate.hashCode ^
      approvedBy.hashCode ^
      deliveryDate.hashCode ^
      completionDate.hashCode;
}
