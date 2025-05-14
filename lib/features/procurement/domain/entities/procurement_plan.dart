import 'package:meta/meta.dart';

@immutable
class ProcurementPlan {

  const ProcurementPlan({
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
  final String id;
  final String name;
  final DateTime creationDate;
  final String createdBy;
  final ProcurementPlanStatus status;
  final List<ProcurementPlanItem> items;
  final double estimatedTotalCost;
  final String? notes;
  final DateTime? approvalDate;
  final String? approvedBy;
  final double? budgetLimit;
  final DateTime? requiredByDate;

  ProcurementPlan copyWith({
    String? id,
    String? name,
    DateTime? creationDate,
    String? createdBy,
    ProcurementPlanStatus? status,
    List<ProcurementPlanItem>? items,
    double? estimatedTotalCost,
    String? notes,
    DateTime? approvalDate,
    String? approvedBy,
    double? budgetLimit,
    DateTime? requiredByDate,
  }) {
    return ProcurementPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      creationDate: creationDate ?? this.creationDate,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      items: items ?? this.items,
      estimatedTotalCost: estimatedTotalCost ?? this.estimatedTotalCost,
      notes: notes ?? this.notes,
      approvalDate: approvalDate ?? this.approvalDate,
      approvedBy: approvedBy ?? this.approvedBy,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      requiredByDate: requiredByDate ?? this.requiredByDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcurementPlan &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          creationDate == other.creationDate &&
          createdBy == other.createdBy &&
          status == other.status &&
          items == other.items &&
          estimatedTotalCost == other.estimatedTotalCost &&
          notes == other.notes &&
          approvalDate == other.approvalDate &&
          approvedBy == other.approvedBy &&
          budgetLimit == other.budgetLimit &&
          requiredByDate == other.requiredByDate;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      creationDate.hashCode ^
      createdBy.hashCode ^
      status.hashCode ^
      items.hashCode ^
      estimatedTotalCost.hashCode ^
      notes.hashCode ^
      approvalDate.hashCode ^
      approvedBy.hashCode ^
      budgetLimit.hashCode ^
      requiredByDate.hashCode;
}

@immutable
class ProcurementPlanItem {

  const ProcurementPlanItem({
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

  ProcurementPlanItem copyWith({
    String? id,
    String? itemId,
    String? itemName,
    double? quantity,
    String? unit,
    String? preferredSupplierId,
    String? preferredSupplierName,
    double? estimatedUnitCost,
    double? estimatedTotalCost,
    DateTime? requiredByDate,
    ProcurementItemUrgency? urgency,
    String? notes,
    String? productionPlanReference,
    double? inventoryLevel,
  }) {
    return ProcurementPlanItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      preferredSupplierId: preferredSupplierId ?? this.preferredSupplierId,
      preferredSupplierName:
          preferredSupplierName ?? this.preferredSupplierName,
      estimatedUnitCost: estimatedUnitCost ?? this.estimatedUnitCost,
      estimatedTotalCost: estimatedTotalCost ?? this.estimatedTotalCost,
      requiredByDate: requiredByDate ?? this.requiredByDate,
      urgency: urgency ?? this.urgency,
      notes: notes ?? this.notes,
      productionPlanReference:
          productionPlanReference ?? this.productionPlanReference,
      inventoryLevel: inventoryLevel ?? this.inventoryLevel,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcurementPlanItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          itemId == other.itemId &&
          itemName == other.itemName &&
          quantity == other.quantity &&
          unit == other.unit &&
          preferredSupplierId == other.preferredSupplierId &&
          preferredSupplierName == other.preferredSupplierName &&
          estimatedUnitCost == other.estimatedUnitCost &&
          estimatedTotalCost == other.estimatedTotalCost &&
          requiredByDate == other.requiredByDate &&
          urgency == other.urgency &&
          notes == other.notes &&
          productionPlanReference == other.productionPlanReference &&
          inventoryLevel == other.inventoryLevel;

  @override
  int get hashCode =>
      id.hashCode ^
      itemId.hashCode ^
      itemName.hashCode ^
      quantity.hashCode ^
      unit.hashCode ^
      preferredSupplierId.hashCode ^
      preferredSupplierName.hashCode ^
      estimatedUnitCost.hashCode ^
      estimatedTotalCost.hashCode ^
      requiredByDate.hashCode ^
      urgency.hashCode ^
      notes.hashCode ^
      productionPlanReference.hashCode ^
      inventoryLevel.hashCode;
}

enum ProcurementPlanStatus {
  draft,
  pendingApproval,
  approved,
  rejected,
  inProgress,
  completed,
  cancelled
}

enum ProcurementItemUrgency { low, medium, high, critical }
