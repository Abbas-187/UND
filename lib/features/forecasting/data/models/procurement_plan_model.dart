import 'package:cloud_firestore/cloud_firestore.dart';

class ProcurementPlanModel {
  factory ProcurementPlanModel.fromJson(Map<String, dynamic> json,
      {String? id}) {
    return ProcurementPlanModel(
      id: id ?? json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      createdDate: (json['createdDate'] as Timestamp).toDate(),
      createdByUserId: json['createdByUserId'] as String,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      procurementItems: (json['procurementItems'] as List<dynamic>)
          .map((e) => ProcurementItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String? ?? 'draft',
      approvedDate: (json['approvedDate'] as Timestamp?)?.toDate(),
      approvedByUserId: json['approvedByUserId'] as String?,
      totalBudget: (json['totalBudget'] as num?)?.toDouble(),
      totalCost: (json['totalCost'] as num?)?.toDouble(),
      lastUpdatedDate: (json['lastUpdatedDate'] as Timestamp?)?.toDate(),
    );
  }
  const ProcurementPlanModel({
    this.id,
    required this.name,
    required this.description,
    required this.createdDate,
    required this.createdByUserId,
    required this.startDate,
    required this.endDate,
    required this.procurementItems,
    this.status = 'draft',
    this.approvedDate,
    this.approvedByUserId,
    this.totalBudget,
    this.totalCost,
    this.lastUpdatedDate,
  });

  final String? id;
  final String name;
  final String description;
  final DateTime createdDate;
  final String createdByUserId;
  final DateTime startDate;
  final DateTime endDate;
  final List<ProcurementItemModel> procurementItems;
  final String status;
  final DateTime? approvedDate;
  final String? approvedByUserId;
  final double? totalBudget;
  final double? totalCost;
  final DateTime? lastUpdatedDate;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdDate': Timestamp.fromDate(createdDate),
      'createdByUserId': createdByUserId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'procurementItems': procurementItems.map((e) => e.toJson()).toList(),
      'status': status,
      'approvedDate':
          approvedDate != null ? Timestamp.fromDate(approvedDate!) : null,
      'approvedByUserId': approvedByUserId,
      'totalBudget': totalBudget,
      'totalCost': totalCost,
      'lastUpdatedDate':
          lastUpdatedDate != null ? Timestamp.fromDate(lastUpdatedDate!) : null,
    };
  }
}

class ProcurementItemModel {
  factory ProcurementItemModel.fromJson(Map<String, dynamic> json) {
    return ProcurementItemModel(
      materialId: json['materialId'] as String,
      materialName: json['materialName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitOfMeasure: json['unitOfMeasure'] as String,
      requiredByDate: (json['requiredByDate'] as Timestamp).toDate(),
      estimatedUnitCost: (json['estimatedUnitCost'] as num).toDouble(),
      preferredSupplierId: json['preferredSupplierId'] as String?,
      preferredSupplierName: json['preferredSupplierName'] as String?,
      alternativeSupplierIds: json['alternativeSupplierIds'] != null
          ? (json['alternativeSupplierIds'] as List<dynamic>).cast<String>()
          : null,
      status: json['status'] as String? ?? 'pending',
      purchaseOrderId: json['purchaseOrderId'] as String?,
      orderDate: (json['orderDate'] as Timestamp?)?.toDate(),
      expectedDeliveryDate:
          (json['expectedDeliveryDate'] as Timestamp?)?.toDate(),
      actualDeliveryDate: (json['actualDeliveryDate'] as Timestamp?)?.toDate(),
      actualUnitCost: (json['actualUnitCost'] as num?)?.toDouble(),
      actualQuantity: (json['actualQuantity'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }
  const ProcurementItemModel({
    required this.materialId,
    required this.materialName,
    required this.quantity,
    required this.unitOfMeasure,
    required this.requiredByDate,
    required this.estimatedUnitCost,
    this.preferredSupplierId,
    this.preferredSupplierName,
    this.alternativeSupplierIds,
    this.status = 'pending',
    this.purchaseOrderId,
    this.orderDate,
    this.expectedDeliveryDate,
    this.actualDeliveryDate,
    this.actualUnitCost,
    this.actualQuantity,
    this.notes,
  });

  final String materialId;
  final String materialName;
  final double quantity;
  final String unitOfMeasure;
  final DateTime requiredByDate;
  final double estimatedUnitCost;
  final String? preferredSupplierId;
  final String? preferredSupplierName;
  final List<String>? alternativeSupplierIds;
  final String status;
  final String? purchaseOrderId;
  final DateTime? orderDate;
  final DateTime? expectedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final double? actualUnitCost;
  final double? actualQuantity;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'materialName': materialName,
      'quantity': quantity,
      'unitOfMeasure': unitOfMeasure,
      'requiredByDate': Timestamp.fromDate(requiredByDate),
      'estimatedUnitCost': estimatedUnitCost,
      'preferredSupplierId': preferredSupplierId,
      'preferredSupplierName': preferredSupplierName,
      'alternativeSupplierIds': alternativeSupplierIds,
      'status': status,
      'purchaseOrderId': purchaseOrderId,
      'orderDate': orderDate != null ? Timestamp.fromDate(orderDate!) : null,
      'expectedDeliveryDate': expectedDeliveryDate != null
          ? Timestamp.fromDate(expectedDeliveryDate!)
          : null,
      'actualDeliveryDate': actualDeliveryDate != null
          ? Timestamp.fromDate(actualDeliveryDate!)
          : null,
      'actualUnitCost': actualUnitCost,
      'actualQuantity': actualQuantity,
      'notes': notes,
    };
  }
}
