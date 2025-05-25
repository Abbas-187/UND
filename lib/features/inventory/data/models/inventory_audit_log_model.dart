import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'inventory_audit_log_model.freezed.dart';
part 'inventory_audit_log_model.g.dart';

/// Type of the audit action being logged
enum AuditActionType {
  create,
  update,
  delete,
  view,
  export,
  statusChange,
  qualityChange,
  locationChange,
  quantityAdjustment,
  batchAttributeChange,
  costUpdate,
  other
}

/// Entity type being audited
enum AuditEntityType {
  inventoryItem,
  inventoryMovement,
  inventoryLocation,
  costLayer,
  batchInfo,
  qualityReport,
  other
}

/// Model representing an audit log entry for inventory operations
@freezed
abstract class InventoryAuditLogModel with _$InventoryAuditLogModel {
  const InventoryAuditLogModel._();

  /// Factory constructor
  const factory InventoryAuditLogModel({
    /// Unique identifier for this audit log entry
    required String id,

    /// The user/employee who performed the action
    required String userId,

    /// Email of the user for easier identification
    String? userEmail,

    /// Name of the user for easier identification
    String? userName,

    /// The type of action performed
    required AuditActionType actionType,

    /// The type of entity being audited
    required AuditEntityType entityType,

    /// The ID of the entity being audited (e.g., inventoryItemId, movementId)
    required String entityId,

    /// The time when the action was performed
    required DateTime timestamp,

    /// The module where the action was performed
    required String module,

    /// A description of the action
    String? description,

    /// Previous state of relevant data
    Map<String, dynamic>? beforeState,

    /// New state of relevant data
    Map<String, dynamic>? afterState,

    /// IP address of the user who performed the action
    String? ipAddress,

    /// The device used to perform the action
    String? deviceInfo,

    /// Additional contextual information
    Map<String, dynamic>? metadata,
  }) = _InventoryAuditLogModel;

  /// Create from JSON
  factory InventoryAuditLogModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryAuditLogModelFromJson(json);

  /// Create a new audit log entry with a generated ID
  factory InventoryAuditLogModel.create({
    required String userId,
    String? userEmail,
    String? userName,
    required AuditActionType actionType,
    required AuditEntityType entityType,
    required String entityId,
    required String module,
    String? description,
    Map<String, dynamic>? beforeState,
    Map<String, dynamic>? afterState,
    String? ipAddress,
    String? deviceInfo,
    Map<String, dynamic>? metadata,
  }) {
    return InventoryAuditLogModel(
      id: const Uuid().v4(),
      userId: userId,
      userEmail: userEmail,
      userName: userName,
      actionType: actionType,
      entityType: entityType,
      entityId: entityId,
      timestamp: DateTime.now(),
      module: module,
      description: description,
      beforeState: beforeState,
      afterState: afterState,
      ipAddress: ipAddress,
      deviceInfo: deviceInfo,
      metadata: metadata,
    );
  }

  /// Convert to Firestore format with Timestamps
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
