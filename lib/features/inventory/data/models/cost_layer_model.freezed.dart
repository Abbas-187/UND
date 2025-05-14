// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cost_layer_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CostLayerModel {
  String? get id;
  String get itemId;
  String get warehouseId;
  String get batchLotNumber;
  double get initialQuantity;
  double get remainingQuantity;
  double get costAtTransaction;
  String? get movementId;
  DateTime get movementDate;
  DateTime? get expirationDate;
  DateTime? get productionDate;
  DateTime get createdAt;

  /// Create a copy of CostLayerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CostLayerModelCopyWith<CostLayerModel> get copyWith =>
      _$CostLayerModelCopyWithImpl<CostLayerModel>(
          this as CostLayerModel, _$identity);

  /// Serializes this CostLayerModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CostLayerModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.batchLotNumber, batchLotNumber) ||
                other.batchLotNumber == batchLotNumber) &&
            (identical(other.initialQuantity, initialQuantity) ||
                other.initialQuantity == initialQuantity) &&
            (identical(other.remainingQuantity, remainingQuantity) ||
                other.remainingQuantity == remainingQuantity) &&
            (identical(other.costAtTransaction, costAtTransaction) ||
                other.costAtTransaction == costAtTransaction) &&
            (identical(other.movementId, movementId) ||
                other.movementId == movementId) &&
            (identical(other.movementDate, movementDate) ||
                other.movementDate == movementDate) &&
            (identical(other.expirationDate, expirationDate) ||
                other.expirationDate == expirationDate) &&
            (identical(other.productionDate, productionDate) ||
                other.productionDate == productionDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      itemId,
      warehouseId,
      batchLotNumber,
      initialQuantity,
      remainingQuantity,
      costAtTransaction,
      movementId,
      movementDate,
      expirationDate,
      productionDate,
      createdAt);

  @override
  String toString() {
    return 'CostLayerModel(id: $id, itemId: $itemId, warehouseId: $warehouseId, batchLotNumber: $batchLotNumber, initialQuantity: $initialQuantity, remainingQuantity: $remainingQuantity, costAtTransaction: $costAtTransaction, movementId: $movementId, movementDate: $movementDate, expirationDate: $expirationDate, productionDate: $productionDate, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $CostLayerModelCopyWith<$Res> {
  factory $CostLayerModelCopyWith(
          CostLayerModel value, $Res Function(CostLayerModel) _then) =
      _$CostLayerModelCopyWithImpl;
  @useResult
  $Res call(
      {String? id,
      String itemId,
      String warehouseId,
      String batchLotNumber,
      double initialQuantity,
      double remainingQuantity,
      double costAtTransaction,
      String? movementId,
      DateTime movementDate,
      DateTime? expirationDate,
      DateTime? productionDate,
      DateTime createdAt});
}

/// @nodoc
class _$CostLayerModelCopyWithImpl<$Res>
    implements $CostLayerModelCopyWith<$Res> {
  _$CostLayerModelCopyWithImpl(this._self, this._then);

  final CostLayerModel _self;
  final $Res Function(CostLayerModel) _then;

  /// Create a copy of CostLayerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? itemId = null,
    Object? warehouseId = null,
    Object? batchLotNumber = null,
    Object? initialQuantity = null,
    Object? remainingQuantity = null,
    Object? costAtTransaction = null,
    Object? movementId = freezed,
    Object? movementDate = null,
    Object? expirationDate = freezed,
    Object? productionDate = freezed,
    Object? createdAt = null,
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
      warehouseId: null == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String,
      batchLotNumber: null == batchLotNumber
          ? _self.batchLotNumber
          : batchLotNumber // ignore: cast_nullable_to_non_nullable
              as String,
      initialQuantity: null == initialQuantity
          ? _self.initialQuantity
          : initialQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      remainingQuantity: null == remainingQuantity
          ? _self.remainingQuantity
          : remainingQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      costAtTransaction: null == costAtTransaction
          ? _self.costAtTransaction
          : costAtTransaction // ignore: cast_nullable_to_non_nullable
              as double,
      movementId: freezed == movementId
          ? _self.movementId
          : movementId // ignore: cast_nullable_to_non_nullable
              as String?,
      movementDate: null == movementDate
          ? _self.movementDate
          : movementDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expirationDate: freezed == expirationDate
          ? _self.expirationDate
          : expirationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      productionDate: freezed == productionDate
          ? _self.productionDate
          : productionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _CostLayerModel implements CostLayerModel {
  const _CostLayerModel(
      {this.id,
      required this.itemId,
      required this.warehouseId,
      required this.batchLotNumber,
      required this.initialQuantity,
      required this.remainingQuantity,
      required this.costAtTransaction,
      this.movementId,
      required this.movementDate,
      this.expirationDate,
      this.productionDate,
      required this.createdAt});
  factory _CostLayerModel.fromJson(Map<String, dynamic> json) =>
      _$CostLayerModelFromJson(json);

  @override
  final String? id;
  @override
  final String itemId;
  @override
  final String warehouseId;
  @override
  final String batchLotNumber;
  @override
  final double initialQuantity;
  @override
  final double remainingQuantity;
  @override
  final double costAtTransaction;
  @override
  final String? movementId;
  @override
  final DateTime movementDate;
  @override
  final DateTime? expirationDate;
  @override
  final DateTime? productionDate;
  @override
  final DateTime createdAt;

  /// Create a copy of CostLayerModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CostLayerModelCopyWith<_CostLayerModel> get copyWith =>
      __$CostLayerModelCopyWithImpl<_CostLayerModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CostLayerModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CostLayerModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.batchLotNumber, batchLotNumber) ||
                other.batchLotNumber == batchLotNumber) &&
            (identical(other.initialQuantity, initialQuantity) ||
                other.initialQuantity == initialQuantity) &&
            (identical(other.remainingQuantity, remainingQuantity) ||
                other.remainingQuantity == remainingQuantity) &&
            (identical(other.costAtTransaction, costAtTransaction) ||
                other.costAtTransaction == costAtTransaction) &&
            (identical(other.movementId, movementId) ||
                other.movementId == movementId) &&
            (identical(other.movementDate, movementDate) ||
                other.movementDate == movementDate) &&
            (identical(other.expirationDate, expirationDate) ||
                other.expirationDate == expirationDate) &&
            (identical(other.productionDate, productionDate) ||
                other.productionDate == productionDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      itemId,
      warehouseId,
      batchLotNumber,
      initialQuantity,
      remainingQuantity,
      costAtTransaction,
      movementId,
      movementDate,
      expirationDate,
      productionDate,
      createdAt);

  @override
  String toString() {
    return 'CostLayerModel(id: $id, itemId: $itemId, warehouseId: $warehouseId, batchLotNumber: $batchLotNumber, initialQuantity: $initialQuantity, remainingQuantity: $remainingQuantity, costAtTransaction: $costAtTransaction, movementId: $movementId, movementDate: $movementDate, expirationDate: $expirationDate, productionDate: $productionDate, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$CostLayerModelCopyWith<$Res>
    implements $CostLayerModelCopyWith<$Res> {
  factory _$CostLayerModelCopyWith(
          _CostLayerModel value, $Res Function(_CostLayerModel) _then) =
      __$CostLayerModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? id,
      String itemId,
      String warehouseId,
      String batchLotNumber,
      double initialQuantity,
      double remainingQuantity,
      double costAtTransaction,
      String? movementId,
      DateTime movementDate,
      DateTime? expirationDate,
      DateTime? productionDate,
      DateTime createdAt});
}

/// @nodoc
class __$CostLayerModelCopyWithImpl<$Res>
    implements _$CostLayerModelCopyWith<$Res> {
  __$CostLayerModelCopyWithImpl(this._self, this._then);

  final _CostLayerModel _self;
  final $Res Function(_CostLayerModel) _then;

  /// Create a copy of CostLayerModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? itemId = null,
    Object? warehouseId = null,
    Object? batchLotNumber = null,
    Object? initialQuantity = null,
    Object? remainingQuantity = null,
    Object? costAtTransaction = null,
    Object? movementId = freezed,
    Object? movementDate = null,
    Object? expirationDate = freezed,
    Object? productionDate = freezed,
    Object? createdAt = null,
  }) {
    return _then(_CostLayerModel(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      itemId: null == itemId
          ? _self.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      warehouseId: null == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String,
      batchLotNumber: null == batchLotNumber
          ? _self.batchLotNumber
          : batchLotNumber // ignore: cast_nullable_to_non_nullable
              as String,
      initialQuantity: null == initialQuantity
          ? _self.initialQuantity
          : initialQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      remainingQuantity: null == remainingQuantity
          ? _self.remainingQuantity
          : remainingQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      costAtTransaction: null == costAtTransaction
          ? _self.costAtTransaction
          : costAtTransaction // ignore: cast_nullable_to_non_nullable
              as double,
      movementId: freezed == movementId
          ? _self.movementId
          : movementId // ignore: cast_nullable_to_non_nullable
              as String?,
      movementDate: null == movementDate
          ? _self.movementDate
          : movementDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expirationDate: freezed == expirationDate
          ? _self.expirationDate
          : expirationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      productionDate: freezed == productionDate
          ? _self.productionDate
          : productionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
