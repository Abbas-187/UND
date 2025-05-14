// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_movement_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InventoryMovementItemModel {
  String? get id;
  String get itemId;
  String get itemCode;
  String get itemName;
  String get uom;
  double get quantity;
  double? get costAtTransaction;
  String? get batchLotNumber;
  DateTime? get expirationDate;
  DateTime? get productionDate; // new optional properties
  Map<String, dynamic>? get customAttributes;
  String? get warehouseId;
  String? get status;
  String? get qualityStatus;
  String? get notes;

  /// Create a copy of InventoryMovementItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InventoryMovementItemModelCopyWith<InventoryMovementItemModel>
      get copyWith =>
          _$InventoryMovementItemModelCopyWithImpl<InventoryMovementItemModel>(
              this as InventoryMovementItemModel, _$identity);

  /// Serializes this InventoryMovementItemModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InventoryMovementItemModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.uom, uom) || other.uom == uom) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.costAtTransaction, costAtTransaction) ||
                other.costAtTransaction == costAtTransaction) &&
            (identical(other.batchLotNumber, batchLotNumber) ||
                other.batchLotNumber == batchLotNumber) &&
            (identical(other.expirationDate, expirationDate) ||
                other.expirationDate == expirationDate) &&
            (identical(other.productionDate, productionDate) ||
                other.productionDate == productionDate) &&
            const DeepCollectionEquality()
                .equals(other.customAttributes, customAttributes) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.qualityStatus, qualityStatus) ||
                other.qualityStatus == qualityStatus) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      itemId,
      itemCode,
      itemName,
      uom,
      quantity,
      costAtTransaction,
      batchLotNumber,
      expirationDate,
      productionDate,
      const DeepCollectionEquality().hash(customAttributes),
      warehouseId,
      status,
      qualityStatus,
      notes);

  @override
  String toString() {
    return 'InventoryMovementItemModel(id: $id, itemId: $itemId, itemCode: $itemCode, itemName: $itemName, uom: $uom, quantity: $quantity, costAtTransaction: $costAtTransaction, batchLotNumber: $batchLotNumber, expirationDate: $expirationDate, productionDate: $productionDate, customAttributes: $customAttributes, warehouseId: $warehouseId, status: $status, qualityStatus: $qualityStatus, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class $InventoryMovementItemModelCopyWith<$Res> {
  factory $InventoryMovementItemModelCopyWith(InventoryMovementItemModel value,
          $Res Function(InventoryMovementItemModel) _then) =
      _$InventoryMovementItemModelCopyWithImpl;
  @useResult
  $Res call(
      {String? id,
      String itemId,
      String itemCode,
      String itemName,
      String uom,
      double quantity,
      double? costAtTransaction,
      String? batchLotNumber,
      DateTime? expirationDate,
      DateTime? productionDate,
      Map<String, dynamic>? customAttributes,
      String? warehouseId,
      String? status,
      String? qualityStatus,
      String? notes});
}

/// @nodoc
class _$InventoryMovementItemModelCopyWithImpl<$Res>
    implements $InventoryMovementItemModelCopyWith<$Res> {
  _$InventoryMovementItemModelCopyWithImpl(this._self, this._then);

  final InventoryMovementItemModel _self;
  final $Res Function(InventoryMovementItemModel) _then;

  /// Create a copy of InventoryMovementItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? itemId = null,
    Object? itemCode = null,
    Object? itemName = null,
    Object? uom = null,
    Object? quantity = null,
    Object? costAtTransaction = freezed,
    Object? batchLotNumber = freezed,
    Object? expirationDate = freezed,
    Object? productionDate = freezed,
    Object? customAttributes = freezed,
    Object? warehouseId = freezed,
    Object? status = freezed,
    Object? qualityStatus = freezed,
    Object? notes = freezed,
  }) {
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      itemId: null == itemId
          ? _self.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      itemCode: null == itemCode
          ? _self.itemCode
          : itemCode // ignore: cast_nullable_to_non_nullable
              as String,
      itemName: null == itemName
          ? _self.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      uom: null == uom
          ? _self.uom
          : uom // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      costAtTransaction: freezed == costAtTransaction
          ? _self.costAtTransaction
          : costAtTransaction // ignore: cast_nullable_to_non_nullable
              as double?,
      batchLotNumber: freezed == batchLotNumber
          ? _self.batchLotNumber
          : batchLotNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      expirationDate: freezed == expirationDate
          ? _self.expirationDate
          : expirationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      productionDate: freezed == productionDate
          ? _self.productionDate
          : productionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      customAttributes: freezed == customAttributes
          ? _self.customAttributes
          : customAttributes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      warehouseId: freezed == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      qualityStatus: freezed == qualityStatus
          ? _self.qualityStatus
          : qualityStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _InventoryMovementItemModel extends InventoryMovementItemModel {
  const _InventoryMovementItemModel(
      {this.id,
      required this.itemId,
      required this.itemCode,
      required this.itemName,
      required this.uom,
      required this.quantity,
      this.costAtTransaction,
      this.batchLotNumber,
      this.expirationDate,
      this.productionDate,
      final Map<String, dynamic>? customAttributes,
      this.warehouseId,
      this.status,
      this.qualityStatus,
      this.notes})
      : _customAttributes = customAttributes,
        super._();
  factory _InventoryMovementItemModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryMovementItemModelFromJson(json);

  @override
  final String? id;
  @override
  final String itemId;
  @override
  final String itemCode;
  @override
  final String itemName;
  @override
  final String uom;
  @override
  final double quantity;
  @override
  final double? costAtTransaction;
  @override
  final String? batchLotNumber;
  @override
  final DateTime? expirationDate;
  @override
  final DateTime? productionDate;
// new optional properties
  final Map<String, dynamic>? _customAttributes;
// new optional properties
  @override
  Map<String, dynamic>? get customAttributes {
    final value = _customAttributes;
    if (value == null) return null;
    if (_customAttributes is EqualUnmodifiableMapView) return _customAttributes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? warehouseId;
  @override
  final String? status;
  @override
  final String? qualityStatus;
  @override
  final String? notes;

  /// Create a copy of InventoryMovementItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InventoryMovementItemModelCopyWith<_InventoryMovementItemModel>
      get copyWith => __$InventoryMovementItemModelCopyWithImpl<
          _InventoryMovementItemModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$InventoryMovementItemModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InventoryMovementItemModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.uom, uom) || other.uom == uom) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.costAtTransaction, costAtTransaction) ||
                other.costAtTransaction == costAtTransaction) &&
            (identical(other.batchLotNumber, batchLotNumber) ||
                other.batchLotNumber == batchLotNumber) &&
            (identical(other.expirationDate, expirationDate) ||
                other.expirationDate == expirationDate) &&
            (identical(other.productionDate, productionDate) ||
                other.productionDate == productionDate) &&
            const DeepCollectionEquality()
                .equals(other._customAttributes, _customAttributes) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.qualityStatus, qualityStatus) ||
                other.qualityStatus == qualityStatus) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      itemId,
      itemCode,
      itemName,
      uom,
      quantity,
      costAtTransaction,
      batchLotNumber,
      expirationDate,
      productionDate,
      const DeepCollectionEquality().hash(_customAttributes),
      warehouseId,
      status,
      qualityStatus,
      notes);

  @override
  String toString() {
    return 'InventoryMovementItemModel(id: $id, itemId: $itemId, itemCode: $itemCode, itemName: $itemName, uom: $uom, quantity: $quantity, costAtTransaction: $costAtTransaction, batchLotNumber: $batchLotNumber, expirationDate: $expirationDate, productionDate: $productionDate, customAttributes: $customAttributes, warehouseId: $warehouseId, status: $status, qualityStatus: $qualityStatus, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class _$InventoryMovementItemModelCopyWith<$Res>
    implements $InventoryMovementItemModelCopyWith<$Res> {
  factory _$InventoryMovementItemModelCopyWith(
          _InventoryMovementItemModel value,
          $Res Function(_InventoryMovementItemModel) _then) =
      __$InventoryMovementItemModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? id,
      String itemId,
      String itemCode,
      String itemName,
      String uom,
      double quantity,
      double? costAtTransaction,
      String? batchLotNumber,
      DateTime? expirationDate,
      DateTime? productionDate,
      Map<String, dynamic>? customAttributes,
      String? warehouseId,
      String? status,
      String? qualityStatus,
      String? notes});
}

/// @nodoc
class __$InventoryMovementItemModelCopyWithImpl<$Res>
    implements _$InventoryMovementItemModelCopyWith<$Res> {
  __$InventoryMovementItemModelCopyWithImpl(this._self, this._then);

  final _InventoryMovementItemModel _self;
  final $Res Function(_InventoryMovementItemModel) _then;

  /// Create a copy of InventoryMovementItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? itemId = null,
    Object? itemCode = null,
    Object? itemName = null,
    Object? uom = null,
    Object? quantity = null,
    Object? costAtTransaction = freezed,
    Object? batchLotNumber = freezed,
    Object? expirationDate = freezed,
    Object? productionDate = freezed,
    Object? customAttributes = freezed,
    Object? warehouseId = freezed,
    Object? status = freezed,
    Object? qualityStatus = freezed,
    Object? notes = freezed,
  }) {
    return _then(_InventoryMovementItemModel(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      itemId: null == itemId
          ? _self.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      itemCode: null == itemCode
          ? _self.itemCode
          : itemCode // ignore: cast_nullable_to_non_nullable
              as String,
      itemName: null == itemName
          ? _self.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      uom: null == uom
          ? _self.uom
          : uom // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      costAtTransaction: freezed == costAtTransaction
          ? _self.costAtTransaction
          : costAtTransaction // ignore: cast_nullable_to_non_nullable
              as double?,
      batchLotNumber: freezed == batchLotNumber
          ? _self.batchLotNumber
          : batchLotNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      expirationDate: freezed == expirationDate
          ? _self.expirationDate
          : expirationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      productionDate: freezed == productionDate
          ? _self.productionDate
          : productionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      customAttributes: freezed == customAttributes
          ? _self._customAttributes
          : customAttributes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      warehouseId: freezed == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      qualityStatus: freezed == qualityStatus
          ? _self.qualityStatus
          : qualityStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
