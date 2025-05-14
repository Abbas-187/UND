// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_movement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InventoryMovementModel _$InventoryMovementModelFromJson(
        Map<String, dynamic> json) =>
    _InventoryMovementModel(
      id: json['id'] as String?,
      documentNumber: json['document_number'] as String,
      movementDate: DateTime.parse(json['movement_date'] as String),
      movementType:
          $enumDecode(_$InventoryMovementTypeEnumMap, json['movement_type']),
      warehouseId: json['warehouse_id'] as String,
      sourceWarehouseId: json['source_warehouse_id'] as String?,
      targetWarehouseId: json['target_warehouse_id'] as String?,
      referenceNumber: json['reference_number'] as String?,
      referenceType: json['reference_type'] as String?,
      referenceDocuments: (json['reference_documents'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      reasonNotes: json['reason_notes'] as String?,
      reasonCode: json['reason_code'] as String?,
      initiatingEmployeeName: json['initiating_employee_name'] as String?,
      approverEmployeeName: json['approver_employee_name'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => InventoryMovementItemModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          const [],
      status: $enumDecodeNullable(
              _$InventoryMovementStatusEnumMap, json['status']) ??
          InventoryMovementStatus.draft,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      initiatingEmployeeId: json['initiating_employee_id'] as String,
      approvedById: json['approved_by_id'] as String?,
      approvedAt: json['approved_at'] == null
          ? null
          : DateTime.parse(json['approved_at'] as String),
    );

Map<String, dynamic> _$InventoryMovementModelToJson(
        _InventoryMovementModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'document_number': instance.documentNumber,
      'movement_date': instance.movementDate.toIso8601String(),
      'movement_type': _$InventoryMovementTypeEnumMap[instance.movementType]!,
      'warehouse_id': instance.warehouseId,
      'source_warehouse_id': instance.sourceWarehouseId,
      'target_warehouse_id': instance.targetWarehouseId,
      'reference_number': instance.referenceNumber,
      'reference_type': instance.referenceType,
      'reference_documents': instance.referenceDocuments,
      'reason_notes': instance.reasonNotes,
      'reason_code': instance.reasonCode,
      'initiating_employee_name': instance.initiatingEmployeeName,
      'approver_employee_name': instance.approverEmployeeName,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'status': _$InventoryMovementStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'initiating_employee_id': instance.initiatingEmployeeId,
      'approved_by_id': instance.approvedById,
      'approved_at': instance.approvedAt?.toIso8601String(),
    };

const _$InventoryMovementTypeEnumMap = {
  InventoryMovementType.receipt: 'receipt',
  InventoryMovementType.issue: 'issue',
  InventoryMovementType.return_: 'return_',
  InventoryMovementType.transfer: 'transfer',
  InventoryMovementType.adjustment: 'adjustment',
  InventoryMovementType.production: 'production',
  InventoryMovementType.consumption: 'consumption',
  InventoryMovementType.waste: 'waste',
  InventoryMovementType.expiry: 'expiry',
  InventoryMovementType.qualityStatusChange: 'qualityStatusChange',
  InventoryMovementType.repack: 'repack',
  InventoryMovementType.sample: 'sample',
  InventoryMovementType.salesIssue: 'salesIssue',
  InventoryMovementType.purchaseReceipt: 'purchaseReceipt',
  InventoryMovementType.productionConsumption: 'productionConsumption',
  InventoryMovementType.productionOutput: 'productionOutput',
  InventoryMovementType.interWarehouseTransfer: 'interWarehouseTransfer',
  InventoryMovementType.intraWarehouseTransfer: 'intraWarehouseTransfer',
  InventoryMovementType.scrapDisposal: 'scrapDisposal',
  InventoryMovementType.qualityHold: 'qualityHold',
  InventoryMovementType.initialBalanceAdjustment: 'initialBalanceAdjustment',
  InventoryMovementType.reservationAdjustment: 'reservationAdjustment',
  InventoryMovementType.PO_RECEIPT: 'PO_RECEIPT',
  InventoryMovementType.TRANSFER_IN: 'TRANSFER_IN',
  InventoryMovementType.PRODUCTION_ISSUE: 'PRODUCTION_ISSUE',
  InventoryMovementType.SALES_RETURN: 'SALES_RETURN',
  InventoryMovementType.ADJUSTMENT_OTHER: 'ADJUSTMENT_OTHER',
  InventoryMovementType.TRANSFER_OUT: 'TRANSFER_OUT',
  InventoryMovementType.SALE_SHIPMENT: 'SALE_SHIPMENT',
  InventoryMovementType.ADJUSTMENT_DAMAGE: 'ADJUSTMENT_DAMAGE',
  InventoryMovementType.ADJUSTMENT_CYCLE_COUNT_GAIN:
      'ADJUSTMENT_CYCLE_COUNT_GAIN',
  InventoryMovementType.ADJUSTMENT_CYCLE_COUNT_LOSS:
      'ADJUSTMENT_CYCLE_COUNT_LOSS',
  InventoryMovementType.QUALITY_STATUS_UPDATE: 'QUALITY_STATUS_UPDATE',
};

const _$InventoryMovementStatusEnumMap = {
  InventoryMovementStatus.draft: 'draft',
  InventoryMovementStatus.pending: 'pending',
  InventoryMovementStatus.completed: 'completed',
  InventoryMovementStatus.cancelled: 'cancelled',
};
