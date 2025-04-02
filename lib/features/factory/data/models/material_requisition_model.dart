import 'package:cloud_firestore/cloud_firestore.dart';
import 'material_requisition_item_model.dart';

enum MaterialRequisitionStatus {
  draft,
  pending,
  approved,
  rejected,
  completed,
  cancelled
}

class MaterialRequisitionModel {
  const MaterialRequisitionModel({
    required this.id,
    required this.productionOrderId,
    required this.items,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.approvedByUserId,
    this.approvedAt,
    this.notes,
  });

  factory MaterialRequisitionModel.fromJson(Map<String, dynamic> json) {
    return MaterialRequisitionModel(
      id: json['id'] as String,
      productionOrderId: json['productionOrderId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => MaterialRequisitionItemModel.fromJson(
              item as Map<String, dynamic>))
          .toList(),
      status: MaterialRequisitionStatus.values.firstWhere(
        (e) => e.toString() == 'MaterialRequisitionStatus.${json['status']}',
        orElse: () => MaterialRequisitionStatus.draft,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      approvedByUserId: json['approvedByUserId'] as String?,
      approvedAt: json['approvedAt'] != null
          ? (json['approvedAt'] as Timestamp).toDate()
          : null,
      notes: json['notes'] as String?,
    );
  }

  final String id;
  final String productionOrderId;
  final List<MaterialRequisitionItemModel> items;
  final MaterialRequisitionStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? approvedByUserId;
  final DateTime? approvedAt;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productionOrderId': productionOrderId,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'approvedByUserId': approvedByUserId,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'notes': notes,
    };
  }

  MaterialRequisitionModel copyWith({
    String? id,
    String? productionOrderId,
    List<MaterialRequisitionItemModel>? items,
    MaterialRequisitionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? approvedByUserId,
    DateTime? approvedAt,
    String? notes,
  }) {
    return MaterialRequisitionModel(
      id: id ?? this.id,
      productionOrderId: productionOrderId ?? this.productionOrderId,
      items: items ?? this.items,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedByUserId: approvedByUserId ?? this.approvedByUserId,
      approvedAt: approvedAt ?? this.approvedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'MaterialRequisitionModel(id: $id, productionOrderId: $productionOrderId, items: $items, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, approvedByUserId: $approvedByUserId, approvedAt: $approvedAt, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MaterialRequisitionModel &&
        other.id == id &&
        other.productionOrderId == productionOrderId &&
        other.items == items &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.approvedByUserId == approvedByUserId &&
        other.approvedAt == approvedAt &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        productionOrderId.hashCode ^
        items.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        approvedByUserId.hashCode ^
        approvedAt.hashCode ^
        notes.hashCode;
  }
}
