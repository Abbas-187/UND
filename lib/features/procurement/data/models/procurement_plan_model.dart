
import 'package:meta/meta.dart';
import '../../domain/entities/procurement_plan.dart';

@immutable
class ProcurementPlanModel {

  const ProcurementPlanModel({
    required this.id,
    required this.name,
    required this.creationDate,
    required this.createdBy,
    required this.status,
    required this.items,
    required this.estimatedTotalCost,
    this.notes,
    this.approvalDate,
    this.approvedBy,
    this.budgetLimit,
    this.requiredByDate,
  });

  factory ProcurementPlanModel.fromJson(Map<String, dynamic> json) {
    return ProcurementPlanModel(
      id: json['id'],
      name: json['name'],
      creationDate: DateTime.parse(json['creationDate']),
      createdBy: json['createdBy'],
      status: ProcurementPlanStatus.values.firstWhere(
          (e) => e.toString() == 'ProcurementPlanStatus.${json['status']}'),
      items: (json['items'] as List)
          .map((item) => ProcurementPlanItemModel.fromJson(item))
          .toList(),
      estimatedTotalCost: json['estimatedTotalCost'].toDouble(),
      notes: json['notes'],
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'])
          : null,
      approvedBy: json['approvedBy'],
      budgetLimit: json['budgetLimit']?.toDouble(),
      requiredByDate: json['requiredByDate'] != null
          ? DateTime.parse(json['requiredByDate'])
          : null,
    );
  }

  factory ProcurementPlanModel.fromEntity(ProcurementPlan entity) {
    return ProcurementPlanModel(
      id: entity.id,
      name: entity.name,
      creationDate: entity.creationDate,
      createdBy: entity.createdBy,
      status: entity.status,
      items: entity.items
          .map((item) => ProcurementPlanItemModel.fromEntity(item))
          .toList(),
      estimatedTotalCost: entity.estimatedTotalCost,
      notes: entity.notes,
      approvalDate: entity.approvalDate,
      approvedBy: entity.approvedBy,
      budgetLimit: entity.budgetLimit,
      requiredByDate: entity.requiredByDate,
    );
  }
  final String id;
  final String name;
  final DateTime creationDate;
  final String createdBy;
  final ProcurementPlanStatus status;
  final List<ProcurementPlanItemModel> items;
  final double estimatedTotalCost;
  final String? notes;
  final DateTime? approvalDate;
  final String? approvedBy;
  final double? budgetLimit;
  final DateTime? requiredByDate;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'creationDate': creationDate.toIso8601String(),
      'createdBy': createdBy,
      'status': status.toString().split('.').last,
      'items': items.map((item) => item.toJson()).toList(),
      'estimatedTotalCost': estimatedTotalCost,
      'notes': notes,
      'approvalDate': approvalDate?.toIso8601String(),
      'approvedBy': approvedBy,
      'budgetLimit': budgetLimit,
      'requiredByDate': requiredByDate?.toIso8601String(),
    };
  }

  ProcurementPlan toEntity() {
    return ProcurementPlan(
      id: id,
      name: name,
      creationDate: creationDate,
      createdBy: createdBy,
      status: status,
      items: items.map((item) => item.toEntity()).toList(),
      estimatedTotalCost: estimatedTotalCost,
      notes: notes,
      approvalDate: approvalDate,
      approvedBy: approvedBy,
      budgetLimit: budgetLimit,
      requiredByDate: requiredByDate,
    );
  }
}

@immutable
class ProcurementPlanItemModel {

  const ProcurementPlanItemModel({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.preferredSupplierId,
    required this.preferredSupplierName,
    required this.estimatedUnitCost,
    required this.estimatedTotalCost,
    required this.requiredByDate,
    required this.urgency,
    this.notes,
    this.productionPlanReference,
    this.inventoryLevel,
  });

  factory ProcurementPlanItemModel.fromJson(Map<String, dynamic> json) {
    return ProcurementPlanItemModel(
      id: json['id'],
      itemId: json['itemId'],
      itemName: json['itemName'],
      quantity: json['quantity'].toDouble(),
      unit: json['unit'],
      preferredSupplierId: json['preferredSupplierId'],
      preferredSupplierName: json['preferredSupplierName'],
      estimatedUnitCost: json['estimatedUnitCost'].toDouble(),
      estimatedTotalCost: json['estimatedTotalCost'].toDouble(),
      requiredByDate: DateTime.parse(json['requiredByDate']),
      urgency: ProcurementItemUrgency.values.firstWhere(
          (e) => e.toString() == 'ProcurementItemUrgency.${json['urgency']}'),
      notes: json['notes'],
      productionPlanReference: json['productionPlanReference'],
      inventoryLevel: json['inventoryLevel']?.toDouble(),
    );
  }

  factory ProcurementPlanItemModel.fromEntity(ProcurementPlanItem entity) {
    return ProcurementPlanItemModel(
      id: entity.id,
      itemId: entity.itemId,
      itemName: entity.itemName,
      quantity: entity.quantity,
      unit: entity.unit,
      preferredSupplierId: entity.preferredSupplierId,
      preferredSupplierName: entity.preferredSupplierName,
      estimatedUnitCost: entity.estimatedUnitCost,
      estimatedTotalCost: entity.estimatedTotalCost,
      requiredByDate: entity.requiredByDate,
      urgency: entity.urgency,
      notes: entity.notes,
      productionPlanReference: entity.productionPlanReference,
      inventoryLevel: entity.inventoryLevel,
    );
  }
  final String id;
  final String itemId;
  final String itemName;
  final double quantity;
  final String unit;
  final String preferredSupplierId;
  final String preferredSupplierName;
  final double estimatedUnitCost;
  final double estimatedTotalCost;
  final DateTime requiredByDate;
  final ProcurementItemUrgency urgency;
  final String? notes;
  final String? productionPlanReference;
  final double? inventoryLevel;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'unit': unit,
      'preferredSupplierId': preferredSupplierId,
      'preferredSupplierName': preferredSupplierName,
      'estimatedUnitCost': estimatedUnitCost,
      'estimatedTotalCost': estimatedTotalCost,
      'requiredByDate': requiredByDate.toIso8601String(),
      'urgency': urgency.toString().split('.').last,
      'notes': notes,
      'productionPlanReference': productionPlanReference,
      'inventoryLevel': inventoryLevel,
    };
  }

  ProcurementPlanItem toEntity() {
    return ProcurementPlanItem(
      id: id,
      itemId: itemId,
      itemName: itemName,
      quantity: quantity,
      unit: unit,
      preferredSupplierId: preferredSupplierId,
      preferredSupplierName: preferredSupplierName,
      estimatedUnitCost: estimatedUnitCost,
      estimatedTotalCost: estimatedTotalCost,
      requiredByDate: requiredByDate,
      urgency: urgency,
      notes: notes,
      productionPlanReference: productionPlanReference,
      inventoryLevel: inventoryLevel,
    );
  }
}
