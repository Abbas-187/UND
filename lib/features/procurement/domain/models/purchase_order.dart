import 'package:flutter/foundation.dart';

@immutable
class PurchaseOrder {
  final String id;
  final String poNumber;
  final String supplierId;
  final String supplierName;
  final List<PurchaseOrderItem> items;
  final double totalAmount;
  final String status;
  final DateTime requestDate;
  final String reasonForRequest;
  final String intendedUse;
  final String quantityJustification;

  const PurchaseOrder({
    required this.id,
    required this.poNumber,
    required this.supplierId,
    required this.supplierName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.requestDate,
    required this.reasonForRequest,
    required this.intendedUse,
    required this.quantityJustification,
  });
}

@immutable
class PurchaseOrderItem {
  final String id;
  final String itemName;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final DateTime requiredByDate;

  const PurchaseOrderItem({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    required this.requiredByDate,
  });
}
