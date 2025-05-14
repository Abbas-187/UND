// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cost_layer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CostLayer {
  String get id;
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

  /// Create a copy of CostLayer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CostLayerCopyWith<CostLayer> get copyWith =>
      _$CostLayerCopyWithImpl<CostLayer>(this as CostLayer, _$identity);

  /// Serializes this CostLayer to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CostLayer &&
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
    return 'CostLayer(id: $id, itemId: $itemId, warehouseId: $warehouseId, batchLotNumber: $batchLotNumber, initialQuantity: $initialQuantity, remainingQuantity: $remainingQuantity, costAtTransaction: $costAtTransaction, movementId: $movementId, movementDate: $movementDate, expirationDate: $expirationDate, productionDate: $productionDate, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $CostLayerCopyWith<$Res> {
  factory $CostLayerCopyWith(CostLayer value, $Res Function(CostLayer) _then) =
      _$CostLayerCopyWithImpl;
  @useResult
  $Res call(
      {String id,
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
class _$CostLayerCopyWithImpl<$Res> implements $CostLayerCopyWith<$Res> {
  _$CostLayerCopyWithImpl(this._self, this._then);

  final CostLayer _self;
  final $Res Function(CostLayer) _then;

  /// Create a copy of CostLayer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
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
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
class _CostLayer implements CostLayer {
  const _CostLayer(
      {required this.id,
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
  factory _CostLayer.fromJson(Map<String, dynamic> json) =>
      _$CostLayerFromJson(json);

  @override
  final String id;
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

  /// Create a copy of CostLayer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CostLayerCopyWith<_CostLayer> get copyWith =>
      __$CostLayerCopyWithImpl<_CostLayer>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CostLayerToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CostLayer &&
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
    return 'CostLayer(id: $id, itemId: $itemId, warehouseId: $warehouseId, batchLotNumber: $batchLotNumber, initialQuantity: $initialQuantity, remainingQuantity: $remainingQuantity, costAtTransaction: $costAtTransaction, movementId: $movementId, movementDate: $movementDate, expirationDate: $expirationDate, productionDate: $productionDate, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$CostLayerCopyWith<$Res>
    implements $CostLayerCopyWith<$Res> {
  factory _$CostLayerCopyWith(
          _CostLayer value, $Res Function(_CostLayer) _then) =
      __$CostLayerCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
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
class __$CostLayerCopyWithImpl<$Res> implements _$CostLayerCopyWith<$Res> {
  __$CostLayerCopyWithImpl(this._self, this._then);

  final _CostLayer _self;
  final $Res Function(_CostLayer) _then;

  /// Create a copy of CostLayer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
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
    return _then(_CostLayer(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
mixin _$CostLayerConsumption {
  String get id;
  String get costLayerId;
  String get itemId;
  String get warehouseId;
  String get movementId;
  DateTime get movementDate;
  double get quantity;
  double get cost;
  DateTime get createdAt;

  /// Create a copy of CostLayerConsumption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CostLayerConsumptionCopyWith<CostLayerConsumption> get copyWith =>
      _$CostLayerConsumptionCopyWithImpl<CostLayerConsumption>(
          this as CostLayerConsumption, _$identity);

  /// Serializes this CostLayerConsumption to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CostLayerConsumption &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.costLayerId, costLayerId) ||
                other.costLayerId == costLayerId) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.movementId, movementId) ||
                other.movementId == movementId) &&
            (identical(other.movementDate, movementDate) ||
                other.movementDate == movementDate) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, costLayerId, itemId,
      warehouseId, movementId, movementDate, quantity, cost, createdAt);

  @override
  String toString() {
    return 'CostLayerConsumption(id: $id, costLayerId: $costLayerId, itemId: $itemId, warehouseId: $warehouseId, movementId: $movementId, movementDate: $movementDate, quantity: $quantity, cost: $cost, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $CostLayerConsumptionCopyWith<$Res> {
  factory $CostLayerConsumptionCopyWith(CostLayerConsumption value,
          $Res Function(CostLayerConsumption) _then) =
      _$CostLayerConsumptionCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String costLayerId,
      String itemId,
      String warehouseId,
      String movementId,
      DateTime movementDate,
      double quantity,
      double cost,
      DateTime createdAt});
}

/// @nodoc
class _$CostLayerConsumptionCopyWithImpl<$Res>
    implements $CostLayerConsumptionCopyWith<$Res> {
  _$CostLayerConsumptionCopyWithImpl(this._self, this._then);

  final CostLayerConsumption _self;
  final $Res Function(CostLayerConsumption) _then;

  /// Create a copy of CostLayerConsumption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? costLayerId = null,
    Object? itemId = null,
    Object? warehouseId = null,
    Object? movementId = null,
    Object? movementDate = null,
    Object? quantity = null,
    Object? cost = null,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      costLayerId: null == costLayerId
          ? _self.costLayerId
          : costLayerId // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _self.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      warehouseId: null == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String,
      movementId: null == movementId
          ? _self.movementId
          : movementId // ignore: cast_nullable_to_non_nullable
              as String,
      movementDate: null == movementDate
          ? _self.movementDate
          : movementDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      cost: null == cost
          ? _self.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _CostLayerConsumption implements CostLayerConsumption {
  const _CostLayerConsumption(
      {required this.id,
      required this.costLayerId,
      required this.itemId,
      required this.warehouseId,
      required this.movementId,
      required this.movementDate,
      required this.quantity,
      required this.cost,
      required this.createdAt});
  factory _CostLayerConsumption.fromJson(Map<String, dynamic> json) =>
      _$CostLayerConsumptionFromJson(json);

  @override
  final String id;
  @override
  final String costLayerId;
  @override
  final String itemId;
  @override
  final String warehouseId;
  @override
  final String movementId;
  @override
  final DateTime movementDate;
  @override
  final double quantity;
  @override
  final double cost;
  @override
  final DateTime createdAt;

  /// Create a copy of CostLayerConsumption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CostLayerConsumptionCopyWith<_CostLayerConsumption> get copyWith =>
      __$CostLayerConsumptionCopyWithImpl<_CostLayerConsumption>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CostLayerConsumptionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CostLayerConsumption &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.costLayerId, costLayerId) ||
                other.costLayerId == costLayerId) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.movementId, movementId) ||
                other.movementId == movementId) &&
            (identical(other.movementDate, movementDate) ||
                other.movementDate == movementDate) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, costLayerId, itemId,
      warehouseId, movementId, movementDate, quantity, cost, createdAt);

  @override
  String toString() {
    return 'CostLayerConsumption(id: $id, costLayerId: $costLayerId, itemId: $itemId, warehouseId: $warehouseId, movementId: $movementId, movementDate: $movementDate, quantity: $quantity, cost: $cost, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$CostLayerConsumptionCopyWith<$Res>
    implements $CostLayerConsumptionCopyWith<$Res> {
  factory _$CostLayerConsumptionCopyWith(_CostLayerConsumption value,
          $Res Function(_CostLayerConsumption) _then) =
      __$CostLayerConsumptionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String costLayerId,
      String itemId,
      String warehouseId,
      String movementId,
      DateTime movementDate,
      double quantity,
      double cost,
      DateTime createdAt});
}

/// @nodoc
class __$CostLayerConsumptionCopyWithImpl<$Res>
    implements _$CostLayerConsumptionCopyWith<$Res> {
  __$CostLayerConsumptionCopyWithImpl(this._self, this._then);

  final _CostLayerConsumption _self;
  final $Res Function(_CostLayerConsumption) _then;

  /// Create a copy of CostLayerConsumption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? costLayerId = null,
    Object? itemId = null,
    Object? warehouseId = null,
    Object? movementId = null,
    Object? movementDate = null,
    Object? quantity = null,
    Object? cost = null,
    Object? createdAt = null,
  }) {
    return _then(_CostLayerConsumption(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      costLayerId: null == costLayerId
          ? _self.costLayerId
          : costLayerId // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _self.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      warehouseId: null == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String,
      movementId: null == movementId
          ? _self.movementId
          : movementId // ignore: cast_nullable_to_non_nullable
              as String,
      movementDate: null == movementDate
          ? _self.movementDate
          : movementDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      cost: null == cost
          ? _self.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
mixin _$CompanySettings {
  String get id;
  CostingMethod get defaultCostingMethod;
  bool get enforceBatchTracking;
  bool get trackExpirationDates;
  int get defaultShelfLifeDays;

  /// Create a copy of CompanySettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CompanySettingsCopyWith<CompanySettings> get copyWith =>
      _$CompanySettingsCopyWithImpl<CompanySettings>(
          this as CompanySettings, _$identity);

  /// Serializes this CompanySettings to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CompanySettings &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.defaultCostingMethod, defaultCostingMethod) ||
                other.defaultCostingMethod == defaultCostingMethod) &&
            (identical(other.enforceBatchTracking, enforceBatchTracking) ||
                other.enforceBatchTracking == enforceBatchTracking) &&
            (identical(other.trackExpirationDates, trackExpirationDates) ||
                other.trackExpirationDates == trackExpirationDates) &&
            (identical(other.defaultShelfLifeDays, defaultShelfLifeDays) ||
                other.defaultShelfLifeDays == defaultShelfLifeDays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, defaultCostingMethod,
      enforceBatchTracking, trackExpirationDates, defaultShelfLifeDays);

  @override
  String toString() {
    return 'CompanySettings(id: $id, defaultCostingMethod: $defaultCostingMethod, enforceBatchTracking: $enforceBatchTracking, trackExpirationDates: $trackExpirationDates, defaultShelfLifeDays: $defaultShelfLifeDays)';
  }
}

/// @nodoc
abstract mixin class $CompanySettingsCopyWith<$Res> {
  factory $CompanySettingsCopyWith(
          CompanySettings value, $Res Function(CompanySettings) _then) =
      _$CompanySettingsCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      CostingMethod defaultCostingMethod,
      bool enforceBatchTracking,
      bool trackExpirationDates,
      int defaultShelfLifeDays});
}

/// @nodoc
class _$CompanySettingsCopyWithImpl<$Res>
    implements $CompanySettingsCopyWith<$Res> {
  _$CompanySettingsCopyWithImpl(this._self, this._then);

  final CompanySettings _self;
  final $Res Function(CompanySettings) _then;

  /// Create a copy of CompanySettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? defaultCostingMethod = null,
    Object? enforceBatchTracking = null,
    Object? trackExpirationDates = null,
    Object? defaultShelfLifeDays = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      defaultCostingMethod: null == defaultCostingMethod
          ? _self.defaultCostingMethod
          : defaultCostingMethod // ignore: cast_nullable_to_non_nullable
              as CostingMethod,
      enforceBatchTracking: null == enforceBatchTracking
          ? _self.enforceBatchTracking
          : enforceBatchTracking // ignore: cast_nullable_to_non_nullable
              as bool,
      trackExpirationDates: null == trackExpirationDates
          ? _self.trackExpirationDates
          : trackExpirationDates // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultShelfLifeDays: null == defaultShelfLifeDays
          ? _self.defaultShelfLifeDays
          : defaultShelfLifeDays // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _CompanySettings implements CompanySettings {
  const _CompanySettings(
      {required this.id,
      this.defaultCostingMethod = CostingMethod.fifo,
      this.enforceBatchTracking = false,
      this.trackExpirationDates = false,
      this.defaultShelfLifeDays = 365});
  factory _CompanySettings.fromJson(Map<String, dynamic> json) =>
      _$CompanySettingsFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final CostingMethod defaultCostingMethod;
  @override
  @JsonKey()
  final bool enforceBatchTracking;
  @override
  @JsonKey()
  final bool trackExpirationDates;
  @override
  @JsonKey()
  final int defaultShelfLifeDays;

  /// Create a copy of CompanySettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CompanySettingsCopyWith<_CompanySettings> get copyWith =>
      __$CompanySettingsCopyWithImpl<_CompanySettings>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CompanySettingsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CompanySettings &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.defaultCostingMethod, defaultCostingMethod) ||
                other.defaultCostingMethod == defaultCostingMethod) &&
            (identical(other.enforceBatchTracking, enforceBatchTracking) ||
                other.enforceBatchTracking == enforceBatchTracking) &&
            (identical(other.trackExpirationDates, trackExpirationDates) ||
                other.trackExpirationDates == trackExpirationDates) &&
            (identical(other.defaultShelfLifeDays, defaultShelfLifeDays) ||
                other.defaultShelfLifeDays == defaultShelfLifeDays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, defaultCostingMethod,
      enforceBatchTracking, trackExpirationDates, defaultShelfLifeDays);

  @override
  String toString() {
    return 'CompanySettings(id: $id, defaultCostingMethod: $defaultCostingMethod, enforceBatchTracking: $enforceBatchTracking, trackExpirationDates: $trackExpirationDates, defaultShelfLifeDays: $defaultShelfLifeDays)';
  }
}

/// @nodoc
abstract mixin class _$CompanySettingsCopyWith<$Res>
    implements $CompanySettingsCopyWith<$Res> {
  factory _$CompanySettingsCopyWith(
          _CompanySettings value, $Res Function(_CompanySettings) _then) =
      __$CompanySettingsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      CostingMethod defaultCostingMethod,
      bool enforceBatchTracking,
      bool trackExpirationDates,
      int defaultShelfLifeDays});
}

/// @nodoc
class __$CompanySettingsCopyWithImpl<$Res>
    implements _$CompanySettingsCopyWith<$Res> {
  __$CompanySettingsCopyWithImpl(this._self, this._then);

  final _CompanySettings _self;
  final $Res Function(_CompanySettings) _then;

  /// Create a copy of CompanySettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? defaultCostingMethod = null,
    Object? enforceBatchTracking = null,
    Object? trackExpirationDates = null,
    Object? defaultShelfLifeDays = null,
  }) {
    return _then(_CompanySettings(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      defaultCostingMethod: null == defaultCostingMethod
          ? _self.defaultCostingMethod
          : defaultCostingMethod // ignore: cast_nullable_to_non_nullable
              as CostingMethod,
      enforceBatchTracking: null == enforceBatchTracking
          ? _self.enforceBatchTracking
          : enforceBatchTracking // ignore: cast_nullable_to_non_nullable
              as bool,
      trackExpirationDates: null == trackExpirationDates
          ? _self.trackExpirationDates
          : trackExpirationDates // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultShelfLifeDays: null == defaultShelfLifeDays
          ? _self.defaultShelfLifeDays
          : defaultShelfLifeDays // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
