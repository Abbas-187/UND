// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_audit_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InventoryAuditLogModel _$InventoryAuditLogModelFromJson(
        Map<String, dynamic> json) =>
    _InventoryAuditLogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userEmail: json['user_email'] as String?,
      userName: json['user_name'] as String?,
      actionType: $enumDecode(_$AuditActionTypeEnumMap, json['action_type']),
      entityType: $enumDecode(_$AuditEntityTypeEnumMap, json['entity_type']),
      entityId: json['entity_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      module: json['module'] as String,
      description: json['description'] as String?,
      beforeState: json['before_state'] as Map<String, dynamic>?,
      afterState: json['after_state'] as Map<String, dynamic>?,
      ipAddress: json['ip_address'] as String?,
      deviceInfo: json['device_info'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$InventoryAuditLogModelToJson(
        _InventoryAuditLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'user_email': instance.userEmail,
      'user_name': instance.userName,
      'action_type': _$AuditActionTypeEnumMap[instance.actionType]!,
      'entity_type': _$AuditEntityTypeEnumMap[instance.entityType]!,
      'entity_id': instance.entityId,
      'timestamp': instance.timestamp.toIso8601String(),
      'module': instance.module,
      'description': instance.description,
      'before_state': instance.beforeState,
      'after_state': instance.afterState,
      'ip_address': instance.ipAddress,
      'device_info': instance.deviceInfo,
      'metadata': instance.metadata,
    };

const _$AuditActionTypeEnumMap = {
  AuditActionType.create: 'create',
  AuditActionType.update: 'update',
  AuditActionType.delete: 'delete',
  AuditActionType.view: 'view',
  AuditActionType.export: 'export',
  AuditActionType.statusChange: 'statusChange',
  AuditActionType.qualityChange: 'qualityChange',
  AuditActionType.locationChange: 'locationChange',
  AuditActionType.quantityAdjustment: 'quantityAdjustment',
  AuditActionType.batchAttributeChange: 'batchAttributeChange',
  AuditActionType.costUpdate: 'costUpdate',
  AuditActionType.other: 'other',
};

const _$AuditEntityTypeEnumMap = {
  AuditEntityType.inventoryItem: 'inventoryItem',
  AuditEntityType.inventoryMovement: 'inventoryMovement',
  AuditEntityType.inventoryLocation: 'inventoryLocation',
  AuditEntityType.costLayer: 'costLayer',
  AuditEntityType.batchInfo: 'batchInfo',
  AuditEntityType.qualityReport: 'qualityReport',
  AuditEntityType.other: 'other',
};
