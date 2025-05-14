// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InventoryTransactionModel _$InventoryTransactionModelFromJson(
        Map<String, dynamic> json) =>
    _InventoryTransactionModel(
      id: json['id'] as String?,
      materialId: json['material_id'] as String,
      materialName: json['material_name'] as String,
      warehouseId: json['warehouse_id'] as String,
      transactionType:
          $enumDecode(_$TransactionTypeEnumMap, json['transaction_type']),
      quantity: (json['quantity'] as num).toDouble(),
      uom: json['uom'] as String,
      batchNumber: json['batch_number'] as String?,
      sourceLocationId: json['source_location_id'] as String?,
      destinationLocationId: json['destination_location_id'] as String?,
      referenceNumber: json['reference_number'] as String?,
      referenceType: json['reference_type'] as String?,
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      transactionDate: json['transaction_date'] == null
          ? null
          : DateTime.parse(json['transaction_date'] as String),
      performedBy: json['performed_by'] as String?,
      approvedBy: json['approved_by'] as String?,
      approvedAt: json['approved_at'] == null
          ? null
          : DateTime.parse(json['approved_at'] as String),
      isApproved: json['is_approved'] as bool? ?? false,
      isPending: json['is_pending'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$InventoryTransactionModelToJson(
        _InventoryTransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'material_id': instance.materialId,
      'material_name': instance.materialName,
      'warehouse_id': instance.warehouseId,
      'transaction_type': _$TransactionTypeEnumMap[instance.transactionType]!,
      'quantity': instance.quantity,
      'uom': instance.uom,
      'batch_number': instance.batchNumber,
      'source_location_id': instance.sourceLocationId,
      'destination_location_id': instance.destinationLocationId,
      'reference_number': instance.referenceNumber,
      'reference_type': instance.referenceType,
      'reason': instance.reason,
      'notes': instance.notes,
      'transaction_date': instance.transactionDate?.toIso8601String(),
      'performed_by': instance.performedBy,
      'approved_by': instance.approvedBy,
      'approved_at': instance.approvedAt?.toIso8601String(),
      'is_approved': instance.isApproved,
      'is_pending': instance.isPending,
      'created_at': instance.createdAt?.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.receipt: 'receipt',
  TransactionType.issue: 'issue',
  TransactionType.transfer: 'transfer',
  TransactionType.return_: 'return_',
  TransactionType.count: 'count',
  TransactionType.adjustment: 'adjustment',
  TransactionType.other: 'other',
};
