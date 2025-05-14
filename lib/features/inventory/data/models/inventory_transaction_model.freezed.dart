// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_transaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InventoryTransactionModel {
  String? get id;
  String get materialId;
  String get materialName;
  String get warehouseId;
  TransactionType get transactionType;
  double get quantity;
  String get uom;
  String? get batchNumber;
  String? get sourceLocationId;
  String? get destinationLocationId;
  String? get referenceNumber;
  String? get referenceType;
  String? get reason;
  String? get notes;
  DateTime? get transactionDate;
  String? get performedBy;
  String? get approvedBy;
  DateTime? get approvedAt;
  bool get isApproved;
  bool get isPending;
  DateTime? get createdAt;

  /// Create a copy of InventoryTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InventoryTransactionModelCopyWith<InventoryTransactionModel> get copyWith =>
      _$InventoryTransactionModelCopyWithImpl<InventoryTransactionModel>(
          this as InventoryTransactionModel, _$identity);

  /// Serializes this InventoryTransactionModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InventoryTransactionModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.materialId, materialId) ||
                other.materialId == materialId) &&
            (identical(other.materialName, materialName) ||
                other.materialName == materialName) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.transactionType, transactionType) ||
                other.transactionType == transactionType) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.uom, uom) || other.uom == uom) &&
            (identical(other.batchNumber, batchNumber) ||
                other.batchNumber == batchNumber) &&
            (identical(other.sourceLocationId, sourceLocationId) ||
                other.sourceLocationId == sourceLocationId) &&
            (identical(other.destinationLocationId, destinationLocationId) ||
                other.destinationLocationId == destinationLocationId) &&
            (identical(other.referenceNumber, referenceNumber) ||
                other.referenceNumber == referenceNumber) &&
            (identical(other.referenceType, referenceType) ||
                other.referenceType == referenceType) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.transactionDate, transactionDate) ||
                other.transactionDate == transactionDate) &&
            (identical(other.performedBy, performedBy) ||
                other.performedBy == performedBy) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.isApproved, isApproved) ||
                other.isApproved == isApproved) &&
            (identical(other.isPending, isPending) ||
                other.isPending == isPending) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        materialId,
        materialName,
        warehouseId,
        transactionType,
        quantity,
        uom,
        batchNumber,
        sourceLocationId,
        destinationLocationId,
        referenceNumber,
        referenceType,
        reason,
        notes,
        transactionDate,
        performedBy,
        approvedBy,
        approvedAt,
        isApproved,
        isPending,
        createdAt
      ]);

  @override
  String toString() {
    return 'InventoryTransactionModel(id: $id, materialId: $materialId, materialName: $materialName, warehouseId: $warehouseId, transactionType: $transactionType, quantity: $quantity, uom: $uom, batchNumber: $batchNumber, sourceLocationId: $sourceLocationId, destinationLocationId: $destinationLocationId, referenceNumber: $referenceNumber, referenceType: $referenceType, reason: $reason, notes: $notes, transactionDate: $transactionDate, performedBy: $performedBy, approvedBy: $approvedBy, approvedAt: $approvedAt, isApproved: $isApproved, isPending: $isPending, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $InventoryTransactionModelCopyWith<$Res> {
  factory $InventoryTransactionModelCopyWith(InventoryTransactionModel value,
          $Res Function(InventoryTransactionModel) _then) =
      _$InventoryTransactionModelCopyWithImpl;
  @useResult
  $Res call(
      {String? id,
      String materialId,
      String materialName,
      String warehouseId,
      TransactionType transactionType,
      double quantity,
      String uom,
      String? batchNumber,
      String? sourceLocationId,
      String? destinationLocationId,
      String? referenceNumber,
      String? referenceType,
      String? reason,
      String? notes,
      DateTime? transactionDate,
      String? performedBy,
      String? approvedBy,
      DateTime? approvedAt,
      bool isApproved,
      bool isPending,
      DateTime? createdAt});
}

/// @nodoc
class _$InventoryTransactionModelCopyWithImpl<$Res>
    implements $InventoryTransactionModelCopyWith<$Res> {
  _$InventoryTransactionModelCopyWithImpl(this._self, this._then);

  final InventoryTransactionModel _self;
  final $Res Function(InventoryTransactionModel) _then;

  /// Create a copy of InventoryTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? materialId = null,
    Object? materialName = null,
    Object? warehouseId = null,
    Object? transactionType = null,
    Object? quantity = null,
    Object? uom = null,
    Object? batchNumber = freezed,
    Object? sourceLocationId = freezed,
    Object? destinationLocationId = freezed,
    Object? referenceNumber = freezed,
    Object? referenceType = freezed,
    Object? reason = freezed,
    Object? notes = freezed,
    Object? transactionDate = freezed,
    Object? performedBy = freezed,
    Object? approvedBy = freezed,
    Object? approvedAt = freezed,
    Object? isApproved = null,
    Object? isPending = null,
    Object? createdAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      materialId: null == materialId
          ? _self.materialId
          : materialId // ignore: cast_nullable_to_non_nullable
              as String,
      materialName: null == materialName
          ? _self.materialName
          : materialName // ignore: cast_nullable_to_non_nullable
              as String,
      warehouseId: null == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String,
      transactionType: null == transactionType
          ? _self.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      uom: null == uom
          ? _self.uom
          : uom // ignore: cast_nullable_to_non_nullable
              as String,
      batchNumber: freezed == batchNumber
          ? _self.batchNumber
          : batchNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceLocationId: freezed == sourceLocationId
          ? _self.sourceLocationId
          : sourceLocationId // ignore: cast_nullable_to_non_nullable
              as String?,
      destinationLocationId: freezed == destinationLocationId
          ? _self.destinationLocationId
          : destinationLocationId // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceNumber: freezed == referenceNumber
          ? _self.referenceNumber
          : referenceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceType: freezed == referenceType
          ? _self.referenceType
          : referenceType // ignore: cast_nullable_to_non_nullable
              as String?,
      reason: freezed == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionDate: freezed == transactionDate
          ? _self.transactionDate
          : transactionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      performedBy: freezed == performedBy
          ? _self.performedBy
          : performedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedBy: freezed == approvedBy
          ? _self.approvedBy
          : approvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedAt: freezed == approvedAt
          ? _self.approvedAt
          : approvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isApproved: null == isApproved
          ? _self.isApproved
          : isApproved // ignore: cast_nullable_to_non_nullable
              as bool,
      isPending: null == isPending
          ? _self.isPending
          : isPending // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _InventoryTransactionModel extends InventoryTransactionModel {
  const _InventoryTransactionModel(
      {this.id,
      required this.materialId,
      required this.materialName,
      required this.warehouseId,
      required this.transactionType,
      required this.quantity,
      required this.uom,
      this.batchNumber,
      this.sourceLocationId,
      this.destinationLocationId,
      this.referenceNumber,
      this.referenceType,
      this.reason,
      this.notes,
      this.transactionDate,
      this.performedBy,
      this.approvedBy,
      this.approvedAt,
      this.isApproved = false,
      this.isPending = false,
      this.createdAt})
      : super._();
  factory _InventoryTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryTransactionModelFromJson(json);

  @override
  final String? id;
  @override
  final String materialId;
  @override
  final String materialName;
  @override
  final String warehouseId;
  @override
  final TransactionType transactionType;
  @override
  final double quantity;
  @override
  final String uom;
  @override
  final String? batchNumber;
  @override
  final String? sourceLocationId;
  @override
  final String? destinationLocationId;
  @override
  final String? referenceNumber;
  @override
  final String? referenceType;
  @override
  final String? reason;
  @override
  final String? notes;
  @override
  final DateTime? transactionDate;
  @override
  final String? performedBy;
  @override
  final String? approvedBy;
  @override
  final DateTime? approvedAt;
  @override
  @JsonKey()
  final bool isApproved;
  @override
  @JsonKey()
  final bool isPending;
  @override
  final DateTime? createdAt;

  /// Create a copy of InventoryTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InventoryTransactionModelCopyWith<_InventoryTransactionModel>
      get copyWith =>
          __$InventoryTransactionModelCopyWithImpl<_InventoryTransactionModel>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$InventoryTransactionModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InventoryTransactionModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.materialId, materialId) ||
                other.materialId == materialId) &&
            (identical(other.materialName, materialName) ||
                other.materialName == materialName) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.transactionType, transactionType) ||
                other.transactionType == transactionType) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.uom, uom) || other.uom == uom) &&
            (identical(other.batchNumber, batchNumber) ||
                other.batchNumber == batchNumber) &&
            (identical(other.sourceLocationId, sourceLocationId) ||
                other.sourceLocationId == sourceLocationId) &&
            (identical(other.destinationLocationId, destinationLocationId) ||
                other.destinationLocationId == destinationLocationId) &&
            (identical(other.referenceNumber, referenceNumber) ||
                other.referenceNumber == referenceNumber) &&
            (identical(other.referenceType, referenceType) ||
                other.referenceType == referenceType) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.transactionDate, transactionDate) ||
                other.transactionDate == transactionDate) &&
            (identical(other.performedBy, performedBy) ||
                other.performedBy == performedBy) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.isApproved, isApproved) ||
                other.isApproved == isApproved) &&
            (identical(other.isPending, isPending) ||
                other.isPending == isPending) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        materialId,
        materialName,
        warehouseId,
        transactionType,
        quantity,
        uom,
        batchNumber,
        sourceLocationId,
        destinationLocationId,
        referenceNumber,
        referenceType,
        reason,
        notes,
        transactionDate,
        performedBy,
        approvedBy,
        approvedAt,
        isApproved,
        isPending,
        createdAt
      ]);

  @override
  String toString() {
    return 'InventoryTransactionModel(id: $id, materialId: $materialId, materialName: $materialName, warehouseId: $warehouseId, transactionType: $transactionType, quantity: $quantity, uom: $uom, batchNumber: $batchNumber, sourceLocationId: $sourceLocationId, destinationLocationId: $destinationLocationId, referenceNumber: $referenceNumber, referenceType: $referenceType, reason: $reason, notes: $notes, transactionDate: $transactionDate, performedBy: $performedBy, approvedBy: $approvedBy, approvedAt: $approvedAt, isApproved: $isApproved, isPending: $isPending, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$InventoryTransactionModelCopyWith<$Res>
    implements $InventoryTransactionModelCopyWith<$Res> {
  factory _$InventoryTransactionModelCopyWith(_InventoryTransactionModel value,
          $Res Function(_InventoryTransactionModel) _then) =
      __$InventoryTransactionModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? id,
      String materialId,
      String materialName,
      String warehouseId,
      TransactionType transactionType,
      double quantity,
      String uom,
      String? batchNumber,
      String? sourceLocationId,
      String? destinationLocationId,
      String? referenceNumber,
      String? referenceType,
      String? reason,
      String? notes,
      DateTime? transactionDate,
      String? performedBy,
      String? approvedBy,
      DateTime? approvedAt,
      bool isApproved,
      bool isPending,
      DateTime? createdAt});
}

/// @nodoc
class __$InventoryTransactionModelCopyWithImpl<$Res>
    implements _$InventoryTransactionModelCopyWith<$Res> {
  __$InventoryTransactionModelCopyWithImpl(this._self, this._then);

  final _InventoryTransactionModel _self;
  final $Res Function(_InventoryTransactionModel) _then;

  /// Create a copy of InventoryTransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? materialId = null,
    Object? materialName = null,
    Object? warehouseId = null,
    Object? transactionType = null,
    Object? quantity = null,
    Object? uom = null,
    Object? batchNumber = freezed,
    Object? sourceLocationId = freezed,
    Object? destinationLocationId = freezed,
    Object? referenceNumber = freezed,
    Object? referenceType = freezed,
    Object? reason = freezed,
    Object? notes = freezed,
    Object? transactionDate = freezed,
    Object? performedBy = freezed,
    Object? approvedBy = freezed,
    Object? approvedAt = freezed,
    Object? isApproved = null,
    Object? isPending = null,
    Object? createdAt = freezed,
  }) {
    return _then(_InventoryTransactionModel(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      materialId: null == materialId
          ? _self.materialId
          : materialId // ignore: cast_nullable_to_non_nullable
              as String,
      materialName: null == materialName
          ? _self.materialName
          : materialName // ignore: cast_nullable_to_non_nullable
              as String,
      warehouseId: null == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String,
      transactionType: null == transactionType
          ? _self.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      uom: null == uom
          ? _self.uom
          : uom // ignore: cast_nullable_to_non_nullable
              as String,
      batchNumber: freezed == batchNumber
          ? _self.batchNumber
          : batchNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceLocationId: freezed == sourceLocationId
          ? _self.sourceLocationId
          : sourceLocationId // ignore: cast_nullable_to_non_nullable
              as String?,
      destinationLocationId: freezed == destinationLocationId
          ? _self.destinationLocationId
          : destinationLocationId // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceNumber: freezed == referenceNumber
          ? _self.referenceNumber
          : referenceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceType: freezed == referenceType
          ? _self.referenceType
          : referenceType // ignore: cast_nullable_to_non_nullable
              as String?,
      reason: freezed == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionDate: freezed == transactionDate
          ? _self.transactionDate
          : transactionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      performedBy: freezed == performedBy
          ? _self.performedBy
          : performedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedBy: freezed == approvedBy
          ? _self.approvedBy
          : approvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedAt: freezed == approvedAt
          ? _self.approvedAt
          : approvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isApproved: null == isApproved
          ? _self.isApproved
          : isApproved // ignore: cast_nullable_to_non_nullable
              as bool,
      isPending: null == isPending
          ? _self.isPending
          : isPending // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
