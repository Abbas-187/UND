// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_audit_log_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InventoryAuditLogModel {
  /// Unique identifier for this audit log entry
  String get id;

  /// The user/employee who performed the action
  String get userId;

  /// Email of the user for easier identification
  String? get userEmail;

  /// Name of the user for easier identification
  String? get userName;

  /// The type of action performed
  AuditActionType get actionType;

  /// The type of entity being audited
  AuditEntityType get entityType;

  /// The ID of the entity being audited (e.g., inventoryItemId, movementId)
  String get entityId;

  /// The time when the action was performed
  DateTime get timestamp;

  /// The module where the action was performed
  String get module;

  /// A description of the action
  String? get description;

  /// Previous state of relevant data
  Map<String, dynamic>? get beforeState;

  /// New state of relevant data
  Map<String, dynamic>? get afterState;

  /// IP address of the user who performed the action
  String? get ipAddress;

  /// The device used to perform the action
  String? get deviceInfo;

  /// Additional contextual information
  Map<String, dynamic>? get metadata;

  /// Create a copy of InventoryAuditLogModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InventoryAuditLogModelCopyWith<InventoryAuditLogModel> get copyWith =>
      _$InventoryAuditLogModelCopyWithImpl<InventoryAuditLogModel>(
          this as InventoryAuditLogModel, _$identity);

  /// Serializes this InventoryAuditLogModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InventoryAuditLogModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userEmail, userEmail) ||
                other.userEmail == userEmail) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.entityType, entityType) ||
                other.entityType == entityType) &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.module, module) || other.module == module) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other.beforeState, beforeState) &&
            const DeepCollectionEquality()
                .equals(other.afterState, afterState) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.deviceInfo, deviceInfo) ||
                other.deviceInfo == deviceInfo) &&
            const DeepCollectionEquality().equals(other.metadata, metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      userEmail,
      userName,
      actionType,
      entityType,
      entityId,
      timestamp,
      module,
      description,
      const DeepCollectionEquality().hash(beforeState),
      const DeepCollectionEquality().hash(afterState),
      ipAddress,
      deviceInfo,
      const DeepCollectionEquality().hash(metadata));

  @override
  String toString() {
    return 'InventoryAuditLogModel(id: $id, userId: $userId, userEmail: $userEmail, userName: $userName, actionType: $actionType, entityType: $entityType, entityId: $entityId, timestamp: $timestamp, module: $module, description: $description, beforeState: $beforeState, afterState: $afterState, ipAddress: $ipAddress, deviceInfo: $deviceInfo, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class $InventoryAuditLogModelCopyWith<$Res> {
  factory $InventoryAuditLogModelCopyWith(InventoryAuditLogModel value,
          $Res Function(InventoryAuditLogModel) _then) =
      _$InventoryAuditLogModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      String? userEmail,
      String? userName,
      AuditActionType actionType,
      AuditEntityType entityType,
      String entityId,
      DateTime timestamp,
      String module,
      String? description,
      Map<String, dynamic>? beforeState,
      Map<String, dynamic>? afterState,
      String? ipAddress,
      String? deviceInfo,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$InventoryAuditLogModelCopyWithImpl<$Res>
    implements $InventoryAuditLogModelCopyWith<$Res> {
  _$InventoryAuditLogModelCopyWithImpl(this._self, this._then);

  final InventoryAuditLogModel _self;
  final $Res Function(InventoryAuditLogModel) _then;

  /// Create a copy of InventoryAuditLogModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userEmail = freezed,
    Object? userName = freezed,
    Object? actionType = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? timestamp = null,
    Object? module = null,
    Object? description = freezed,
    Object? beforeState = freezed,
    Object? afterState = freezed,
    Object? ipAddress = freezed,
    Object? deviceInfo = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userEmail: freezed == userEmail
          ? _self.userEmail
          : userEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _self.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      actionType: null == actionType
          ? _self.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as AuditActionType,
      entityType: null == entityType
          ? _self.entityType
          : entityType // ignore: cast_nullable_to_non_nullable
              as AuditEntityType,
      entityId: null == entityId
          ? _self.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      module: null == module
          ? _self.module
          : module // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      beforeState: freezed == beforeState
          ? _self.beforeState
          : beforeState // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      afterState: freezed == afterState
          ? _self.afterState
          : afterState // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      ipAddress: freezed == ipAddress
          ? _self.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceInfo: freezed == deviceInfo
          ? _self.deviceInfo
          : deviceInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _InventoryAuditLogModel extends InventoryAuditLogModel {
  const _InventoryAuditLogModel(
      {required this.id,
      required this.userId,
      this.userEmail,
      this.userName,
      required this.actionType,
      required this.entityType,
      required this.entityId,
      required this.timestamp,
      required this.module,
      this.description,
      final Map<String, dynamic>? beforeState,
      final Map<String, dynamic>? afterState,
      this.ipAddress,
      this.deviceInfo,
      final Map<String, dynamic>? metadata})
      : _beforeState = beforeState,
        _afterState = afterState,
        _metadata = metadata,
        super._();
  factory _InventoryAuditLogModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryAuditLogModelFromJson(json);

  /// Unique identifier for this audit log entry
  @override
  final String id;

  /// The user/employee who performed the action
  @override
  final String userId;

  /// Email of the user for easier identification
  @override
  final String? userEmail;

  /// Name of the user for easier identification
  @override
  final String? userName;

  /// The type of action performed
  @override
  final AuditActionType actionType;

  /// The type of entity being audited
  @override
  final AuditEntityType entityType;

  /// The ID of the entity being audited (e.g., inventoryItemId, movementId)
  @override
  final String entityId;

  /// The time when the action was performed
  @override
  final DateTime timestamp;

  /// The module where the action was performed
  @override
  final String module;

  /// A description of the action
  @override
  final String? description;

  /// Previous state of relevant data
  final Map<String, dynamic>? _beforeState;

  /// Previous state of relevant data
  @override
  Map<String, dynamic>? get beforeState {
    final value = _beforeState;
    if (value == null) return null;
    if (_beforeState is EqualUnmodifiableMapView) return _beforeState;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// New state of relevant data
  final Map<String, dynamic>? _afterState;

  /// New state of relevant data
  @override
  Map<String, dynamic>? get afterState {
    final value = _afterState;
    if (value == null) return null;
    if (_afterState is EqualUnmodifiableMapView) return _afterState;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// IP address of the user who performed the action
  @override
  final String? ipAddress;

  /// The device used to perform the action
  @override
  final String? deviceInfo;

  /// Additional contextual information
  final Map<String, dynamic>? _metadata;

  /// Additional contextual information
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of InventoryAuditLogModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InventoryAuditLogModelCopyWith<_InventoryAuditLogModel> get copyWith =>
      __$InventoryAuditLogModelCopyWithImpl<_InventoryAuditLogModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$InventoryAuditLogModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InventoryAuditLogModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userEmail, userEmail) ||
                other.userEmail == userEmail) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.entityType, entityType) ||
                other.entityType == entityType) &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.module, module) || other.module == module) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._beforeState, _beforeState) &&
            const DeepCollectionEquality()
                .equals(other._afterState, _afterState) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.deviceInfo, deviceInfo) ||
                other.deviceInfo == deviceInfo) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      userEmail,
      userName,
      actionType,
      entityType,
      entityId,
      timestamp,
      module,
      description,
      const DeepCollectionEquality().hash(_beforeState),
      const DeepCollectionEquality().hash(_afterState),
      ipAddress,
      deviceInfo,
      const DeepCollectionEquality().hash(_metadata));

  @override
  String toString() {
    return 'InventoryAuditLogModel(id: $id, userId: $userId, userEmail: $userEmail, userName: $userName, actionType: $actionType, entityType: $entityType, entityId: $entityId, timestamp: $timestamp, module: $module, description: $description, beforeState: $beforeState, afterState: $afterState, ipAddress: $ipAddress, deviceInfo: $deviceInfo, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class _$InventoryAuditLogModelCopyWith<$Res>
    implements $InventoryAuditLogModelCopyWith<$Res> {
  factory _$InventoryAuditLogModelCopyWith(_InventoryAuditLogModel value,
          $Res Function(_InventoryAuditLogModel) _then) =
      __$InventoryAuditLogModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String? userEmail,
      String? userName,
      AuditActionType actionType,
      AuditEntityType entityType,
      String entityId,
      DateTime timestamp,
      String module,
      String? description,
      Map<String, dynamic>? beforeState,
      Map<String, dynamic>? afterState,
      String? ipAddress,
      String? deviceInfo,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$InventoryAuditLogModelCopyWithImpl<$Res>
    implements _$InventoryAuditLogModelCopyWith<$Res> {
  __$InventoryAuditLogModelCopyWithImpl(this._self, this._then);

  final _InventoryAuditLogModel _self;
  final $Res Function(_InventoryAuditLogModel) _then;

  /// Create a copy of InventoryAuditLogModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userEmail = freezed,
    Object? userName = freezed,
    Object? actionType = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? timestamp = null,
    Object? module = null,
    Object? description = freezed,
    Object? beforeState = freezed,
    Object? afterState = freezed,
    Object? ipAddress = freezed,
    Object? deviceInfo = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_InventoryAuditLogModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userEmail: freezed == userEmail
          ? _self.userEmail
          : userEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _self.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      actionType: null == actionType
          ? _self.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as AuditActionType,
      entityType: null == entityType
          ? _self.entityType
          : entityType // ignore: cast_nullable_to_non_nullable
              as AuditEntityType,
      entityId: null == entityId
          ? _self.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      module: null == module
          ? _self.module
          : module // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      beforeState: freezed == beforeState
          ? _self._beforeState
          : beforeState // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      afterState: freezed == afterState
          ? _self._afterState
          : afterState // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      ipAddress: freezed == ipAddress
          ? _self.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceInfo: freezed == deviceInfo
          ? _self.deviceInfo
          : deviceInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _self._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

// dart format on
