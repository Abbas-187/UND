// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_movement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InventoryMovementModel {
  String? get id;
  String get documentNumber;
  DateTime get movementDate;
  InventoryMovementType get movementType;
  String get warehouseId;
  String? get sourceWarehouseId;
  String? get targetWarehouseId;
  String? get referenceNumber;
  String? get referenceType;
  List<String>? get referenceDocuments;
  String? get reasonNotes;
  String? get reasonCode;
  String? get initiatingEmployeeName;
  String? get approverEmployeeName;
  List<InventoryMovementItemModel> get items;
  InventoryMovementStatus get status;
  DateTime get createdAt;
  DateTime get updatedAt;
  String get initiatingEmployeeId;
  String? get approvedById;
  DateTime? get approvedAt;

  /// Create a copy of InventoryMovementModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InventoryMovementModelCopyWith<InventoryMovementModel> get copyWith =>
      _$InventoryMovementModelCopyWithImpl<InventoryMovementModel>(
          this as InventoryMovementModel, _$identity);

  /// Serializes this InventoryMovementModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InventoryMovementModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.documentNumber, documentNumber) ||
                other.documentNumber == documentNumber) &&
            (identical(other.movementDate, movementDate) ||
                other.movementDate == movementDate) &&
            (identical(other.movementType, movementType) ||
                other.movementType == movementType) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.sourceWarehouseId, sourceWarehouseId) ||
                other.sourceWarehouseId == sourceWarehouseId) &&
            (identical(other.targetWarehouseId, targetWarehouseId) ||
                other.targetWarehouseId == targetWarehouseId) &&
            (identical(other.referenceNumber, referenceNumber) ||
                other.referenceNumber == referenceNumber) &&
            (identical(other.referenceType, referenceType) ||
                other.referenceType == referenceType) &&
            const DeepCollectionEquality()
                .equals(other.referenceDocuments, referenceDocuments) &&
            (identical(other.reasonNotes, reasonNotes) ||
                other.reasonNotes == reasonNotes) &&
            (identical(other.reasonCode, reasonCode) ||
                other.reasonCode == reasonCode) &&
            (identical(other.initiatingEmployeeName, initiatingEmployeeName) ||
                other.initiatingEmployeeName == initiatingEmployeeName) &&
            (identical(other.approverEmployeeName, approverEmployeeName) ||
                other.approverEmployeeName == approverEmployeeName) &&
            const DeepCollectionEquality().equals(other.items, items) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.initiatingEmployeeId, initiatingEmployeeId) ||
                other.initiatingEmployeeId == initiatingEmployeeId) &&
            (identical(other.approvedById, approvedById) ||
                other.approvedById == approvedById) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        documentNumber,
        movementDate,
        movementType,
        warehouseId,
        sourceWarehouseId,
        targetWarehouseId,
        referenceNumber,
        referenceType,
        const DeepCollectionEquality().hash(referenceDocuments),
        reasonNotes,
        reasonCode,
        initiatingEmployeeName,
        approverEmployeeName,
        const DeepCollectionEquality().hash(items),
        status,
        createdAt,
        updatedAt,
        initiatingEmployeeId,
        approvedById,
        approvedAt
      ]);

  @override
  String toString() {
    return 'InventoryMovementModel(id: $id, documentNumber: $documentNumber, movementDate: $movementDate, movementType: $movementType, warehouseId: $warehouseId, sourceWarehouseId: $sourceWarehouseId, targetWarehouseId: $targetWarehouseId, referenceNumber: $referenceNumber, referenceType: $referenceType, referenceDocuments: $referenceDocuments, reasonNotes: $reasonNotes, reasonCode: $reasonCode, initiatingEmployeeName: $initiatingEmployeeName, approverEmployeeName: $approverEmployeeName, items: $items, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, initiatingEmployeeId: $initiatingEmployeeId, approvedById: $approvedById, approvedAt: $approvedAt)';
  }
}

/// @nodoc
abstract mixin class $InventoryMovementModelCopyWith<$Res> {
  factory $InventoryMovementModelCopyWith(InventoryMovementModel value,
          $Res Function(InventoryMovementModel) _then) =
      _$InventoryMovementModelCopyWithImpl;
  @useResult
  $Res call(
      {String? id,
      String documentNumber,
      DateTime movementDate,
      InventoryMovementType movementType,
      String warehouseId,
      String? sourceWarehouseId,
      String? targetWarehouseId,
      String? referenceNumber,
      String? referenceType,
      List<String>? referenceDocuments,
      String? reasonNotes,
      String? reasonCode,
      String? initiatingEmployeeName,
      String? approverEmployeeName,
      List<InventoryMovementItemModel> items,
      InventoryMovementStatus status,
      DateTime createdAt,
      DateTime updatedAt,
      String initiatingEmployeeId,
      String? approvedById,
      DateTime? approvedAt});
}

/// @nodoc
class _$InventoryMovementModelCopyWithImpl<$Res>
    implements $InventoryMovementModelCopyWith<$Res> {
  _$InventoryMovementModelCopyWithImpl(this._self, this._then);

  final InventoryMovementModel _self;
  final $Res Function(InventoryMovementModel) _then;

  /// Create a copy of InventoryMovementModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? documentNumber = null,
    Object? movementDate = null,
    Object? movementType = null,
    Object? warehouseId = null,
    Object? sourceWarehouseId = freezed,
    Object? targetWarehouseId = freezed,
    Object? referenceNumber = freezed,
    Object? referenceType = freezed,
    Object? referenceDocuments = freezed,
    Object? reasonNotes = freezed,
    Object? reasonCode = freezed,
    Object? initiatingEmployeeName = freezed,
    Object? approverEmployeeName = freezed,
    Object? items = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? initiatingEmployeeId = null,
    Object? approvedById = freezed,
    Object? approvedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      documentNumber: null == documentNumber
          ? _self.documentNumber
          : documentNumber // ignore: cast_nullable_to_non_nullable
              as String,
      movementDate: null == movementDate
          ? _self.movementDate
          : movementDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      movementType: null == movementType
          ? _self.movementType
          : movementType // ignore: cast_nullable_to_non_nullable
              as InventoryMovementType,
      warehouseId: null == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String,
      sourceWarehouseId: freezed == sourceWarehouseId
          ? _self.sourceWarehouseId
          : sourceWarehouseId // ignore: cast_nullable_to_non_nullable
              as String?,
      targetWarehouseId: freezed == targetWarehouseId
          ? _self.targetWarehouseId
          : targetWarehouseId // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceNumber: freezed == referenceNumber
          ? _self.referenceNumber
          : referenceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceType: freezed == referenceType
          ? _self.referenceType
          : referenceType // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceDocuments: freezed == referenceDocuments
          ? _self.referenceDocuments
          : referenceDocuments // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      reasonNotes: freezed == reasonNotes
          ? _self.reasonNotes
          : reasonNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      reasonCode: freezed == reasonCode
          ? _self.reasonCode
          : reasonCode // ignore: cast_nullable_to_non_nullable
              as String?,
      initiatingEmployeeName: freezed == initiatingEmployeeName
          ? _self.initiatingEmployeeName
          : initiatingEmployeeName // ignore: cast_nullable_to_non_nullable
              as String?,
      approverEmployeeName: freezed == approverEmployeeName
          ? _self.approverEmployeeName
          : approverEmployeeName // ignore: cast_nullable_to_non_nullable
              as String?,
      items: null == items
          ? _self.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<InventoryMovementItemModel>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as InventoryMovementStatus,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      initiatingEmployeeId: null == initiatingEmployeeId
          ? _self.initiatingEmployeeId
          : initiatingEmployeeId // ignore: cast_nullable_to_non_nullable
              as String,
      approvedById: freezed == approvedById
          ? _self.approvedById
          : approvedById // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedAt: freezed == approvedAt
          ? _self.approvedAt
          : approvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _InventoryMovementModel extends InventoryMovementModel {
  const _InventoryMovementModel(
      {this.id,
      required this.documentNumber,
      required this.movementDate,
      required this.movementType,
      required this.warehouseId,
      this.sourceWarehouseId,
      this.targetWarehouseId,
      this.referenceNumber,
      this.referenceType,
      final List<String>? referenceDocuments,
      this.reasonNotes,
      this.reasonCode,
      this.initiatingEmployeeName,
      this.approverEmployeeName,
      final List<InventoryMovementItemModel> items = const [],
      this.status = InventoryMovementStatus.draft,
      required this.createdAt,
      required this.updatedAt,
      required this.initiatingEmployeeId,
      this.approvedById,
      this.approvedAt})
      : _referenceDocuments = referenceDocuments,
        _items = items,
        super._();
  factory _InventoryMovementModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryMovementModelFromJson(json);

  @override
  final String? id;
  @override
  final String documentNumber;
  @override
  final DateTime movementDate;
  @override
  final InventoryMovementType movementType;
  @override
  final String warehouseId;
  @override
  final String? sourceWarehouseId;
  @override
  final String? targetWarehouseId;
  @override
  final String? referenceNumber;
  @override
  final String? referenceType;
  final List<String>? _referenceDocuments;
  @override
  List<String>? get referenceDocuments {
    final value = _referenceDocuments;
    if (value == null) return null;
    if (_referenceDocuments is EqualUnmodifiableListView)
      return _referenceDocuments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? reasonNotes;
  @override
  final String? reasonCode;
  @override
  final String? initiatingEmployeeName;
  @override
  final String? approverEmployeeName;
  final List<InventoryMovementItemModel> _items;
  @override
  @JsonKey()
  List<InventoryMovementItemModel> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final InventoryMovementStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String initiatingEmployeeId;
  @override
  final String? approvedById;
  @override
  final DateTime? approvedAt;

  /// Create a copy of InventoryMovementModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InventoryMovementModelCopyWith<_InventoryMovementModel> get copyWith =>
      __$InventoryMovementModelCopyWithImpl<_InventoryMovementModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$InventoryMovementModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InventoryMovementModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.documentNumber, documentNumber) ||
                other.documentNumber == documentNumber) &&
            (identical(other.movementDate, movementDate) ||
                other.movementDate == movementDate) &&
            (identical(other.movementType, movementType) ||
                other.movementType == movementType) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.sourceWarehouseId, sourceWarehouseId) ||
                other.sourceWarehouseId == sourceWarehouseId) &&
            (identical(other.targetWarehouseId, targetWarehouseId) ||
                other.targetWarehouseId == targetWarehouseId) &&
            (identical(other.referenceNumber, referenceNumber) ||
                other.referenceNumber == referenceNumber) &&
            (identical(other.referenceType, referenceType) ||
                other.referenceType == referenceType) &&
            const DeepCollectionEquality()
                .equals(other._referenceDocuments, _referenceDocuments) &&
            (identical(other.reasonNotes, reasonNotes) ||
                other.reasonNotes == reasonNotes) &&
            (identical(other.reasonCode, reasonCode) ||
                other.reasonCode == reasonCode) &&
            (identical(other.initiatingEmployeeName, initiatingEmployeeName) ||
                other.initiatingEmployeeName == initiatingEmployeeName) &&
            (identical(other.approverEmployeeName, approverEmployeeName) ||
                other.approverEmployeeName == approverEmployeeName) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.initiatingEmployeeId, initiatingEmployeeId) ||
                other.initiatingEmployeeId == initiatingEmployeeId) &&
            (identical(other.approvedById, approvedById) ||
                other.approvedById == approvedById) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        documentNumber,
        movementDate,
        movementType,
        warehouseId,
        sourceWarehouseId,
        targetWarehouseId,
        referenceNumber,
        referenceType,
        const DeepCollectionEquality().hash(_referenceDocuments),
        reasonNotes,
        reasonCode,
        initiatingEmployeeName,
        approverEmployeeName,
        const DeepCollectionEquality().hash(_items),
        status,
        createdAt,
        updatedAt,
        initiatingEmployeeId,
        approvedById,
        approvedAt
      ]);

  @override
  String toString() {
    return 'InventoryMovementModel(id: $id, documentNumber: $documentNumber, movementDate: $movementDate, movementType: $movementType, warehouseId: $warehouseId, sourceWarehouseId: $sourceWarehouseId, targetWarehouseId: $targetWarehouseId, referenceNumber: $referenceNumber, referenceType: $referenceType, referenceDocuments: $referenceDocuments, reasonNotes: $reasonNotes, reasonCode: $reasonCode, initiatingEmployeeName: $initiatingEmployeeName, approverEmployeeName: $approverEmployeeName, items: $items, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, initiatingEmployeeId: $initiatingEmployeeId, approvedById: $approvedById, approvedAt: $approvedAt)';
  }
}

/// @nodoc
abstract mixin class _$InventoryMovementModelCopyWith<$Res>
    implements $InventoryMovementModelCopyWith<$Res> {
  factory _$InventoryMovementModelCopyWith(_InventoryMovementModel value,
          $Res Function(_InventoryMovementModel) _then) =
      __$InventoryMovementModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? id,
      String documentNumber,
      DateTime movementDate,
      InventoryMovementType movementType,
      String warehouseId,
      String? sourceWarehouseId,
      String? targetWarehouseId,
      String? referenceNumber,
      String? referenceType,
      List<String>? referenceDocuments,
      String? reasonNotes,
      String? reasonCode,
      String? initiatingEmployeeName,
      String? approverEmployeeName,
      List<InventoryMovementItemModel> items,
      InventoryMovementStatus status,
      DateTime createdAt,
      DateTime updatedAt,
      String initiatingEmployeeId,
      String? approvedById,
      DateTime? approvedAt});
}

/// @nodoc
class __$InventoryMovementModelCopyWithImpl<$Res>
    implements _$InventoryMovementModelCopyWith<$Res> {
  __$InventoryMovementModelCopyWithImpl(this._self, this._then);

  final _InventoryMovementModel _self;
  final $Res Function(_InventoryMovementModel) _then;

  /// Create a copy of InventoryMovementModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? documentNumber = null,
    Object? movementDate = null,
    Object? movementType = null,
    Object? warehouseId = null,
    Object? sourceWarehouseId = freezed,
    Object? targetWarehouseId = freezed,
    Object? referenceNumber = freezed,
    Object? referenceType = freezed,
    Object? referenceDocuments = freezed,
    Object? reasonNotes = freezed,
    Object? reasonCode = freezed,
    Object? initiatingEmployeeName = freezed,
    Object? approverEmployeeName = freezed,
    Object? items = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? initiatingEmployeeId = null,
    Object? approvedById = freezed,
    Object? approvedAt = freezed,
  }) {
    return _then(_InventoryMovementModel(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      documentNumber: null == documentNumber
          ? _self.documentNumber
          : documentNumber // ignore: cast_nullable_to_non_nullable
              as String,
      movementDate: null == movementDate
          ? _self.movementDate
          : movementDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      movementType: null == movementType
          ? _self.movementType
          : movementType // ignore: cast_nullable_to_non_nullable
              as InventoryMovementType,
      warehouseId: null == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String,
      sourceWarehouseId: freezed == sourceWarehouseId
          ? _self.sourceWarehouseId
          : sourceWarehouseId // ignore: cast_nullable_to_non_nullable
              as String?,
      targetWarehouseId: freezed == targetWarehouseId
          ? _self.targetWarehouseId
          : targetWarehouseId // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceNumber: freezed == referenceNumber
          ? _self.referenceNumber
          : referenceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceType: freezed == referenceType
          ? _self.referenceType
          : referenceType // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceDocuments: freezed == referenceDocuments
          ? _self._referenceDocuments
          : referenceDocuments // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      reasonNotes: freezed == reasonNotes
          ? _self.reasonNotes
          : reasonNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      reasonCode: freezed == reasonCode
          ? _self.reasonCode
          : reasonCode // ignore: cast_nullable_to_non_nullable
              as String?,
      initiatingEmployeeName: freezed == initiatingEmployeeName
          ? _self.initiatingEmployeeName
          : initiatingEmployeeName // ignore: cast_nullable_to_non_nullable
              as String?,
      approverEmployeeName: freezed == approverEmployeeName
          ? _self.approverEmployeeName
          : approverEmployeeName // ignore: cast_nullable_to_non_nullable
              as String?,
      items: null == items
          ? _self._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<InventoryMovementItemModel>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as InventoryMovementStatus,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      initiatingEmployeeId: null == initiatingEmployeeId
          ? _self.initiatingEmployeeId
          : initiatingEmployeeId // ignore: cast_nullable_to_non_nullable
              as String,
      approvedById: freezed == approvedById
          ? _self.approvedById
          : approvedById // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedAt: freezed == approvedAt
          ? _self.approvedAt
          : approvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
