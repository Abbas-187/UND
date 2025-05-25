// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Reservation {
  String get id;
  String get bomId;
  String get productionOrderId;
  String get itemId;
  String get itemCode;
  String get itemName;
  double get reservedQuantity;
  String get unit;
  ReservationStatus get status;
  DateTime get reservationDate;
  DateTime get expiryDate;
  String get reservedBy;
  String? get warehouseId;
  String? get batchNumber;
  String? get lotNumber;
  DateTime? get releaseDate;
  String? get releasedBy;
  String? get notes;
  int? get priority;
  Map<String, dynamic>? get metadata;

  /// Create a copy of Reservation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ReservationCopyWith<Reservation> get copyWith =>
      _$ReservationCopyWithImpl<Reservation>(this as Reservation, _$identity);

  /// Serializes this Reservation to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Reservation &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bomId, bomId) || other.bomId == bomId) &&
            (identical(other.productionOrderId, productionOrderId) ||
                other.productionOrderId == productionOrderId) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.reservedQuantity, reservedQuantity) ||
                other.reservedQuantity == reservedQuantity) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reservationDate, reservationDate) ||
                other.reservationDate == reservationDate) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.reservedBy, reservedBy) ||
                other.reservedBy == reservedBy) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.batchNumber, batchNumber) ||
                other.batchNumber == batchNumber) &&
            (identical(other.lotNumber, lotNumber) ||
                other.lotNumber == lotNumber) &&
            (identical(other.releaseDate, releaseDate) ||
                other.releaseDate == releaseDate) &&
            (identical(other.releasedBy, releasedBy) ||
                other.releasedBy == releasedBy) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            const DeepCollectionEquality().equals(other.metadata, metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        bomId,
        productionOrderId,
        itemId,
        itemCode,
        itemName,
        reservedQuantity,
        unit,
        status,
        reservationDate,
        expiryDate,
        reservedBy,
        warehouseId,
        batchNumber,
        lotNumber,
        releaseDate,
        releasedBy,
        notes,
        priority,
        const DeepCollectionEquality().hash(metadata)
      ]);

  @override
  String toString() {
    return 'Reservation(id: $id, bomId: $bomId, productionOrderId: $productionOrderId, itemId: $itemId, itemCode: $itemCode, itemName: $itemName, reservedQuantity: $reservedQuantity, unit: $unit, status: $status, reservationDate: $reservationDate, expiryDate: $expiryDate, reservedBy: $reservedBy, warehouseId: $warehouseId, batchNumber: $batchNumber, lotNumber: $lotNumber, releaseDate: $releaseDate, releasedBy: $releasedBy, notes: $notes, priority: $priority, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class $ReservationCopyWith<$Res> {
  factory $ReservationCopyWith(
          Reservation value, $Res Function(Reservation) _then) =
      _$ReservationCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String bomId,
      String productionOrderId,
      String itemId,
      String itemCode,
      String itemName,
      double reservedQuantity,
      String unit,
      ReservationStatus status,
      DateTime reservationDate,
      DateTime expiryDate,
      String reservedBy,
      String? warehouseId,
      String? batchNumber,
      String? lotNumber,
      DateTime? releaseDate,
      String? releasedBy,
      String? notes,
      int? priority,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$ReservationCopyWithImpl<$Res> implements $ReservationCopyWith<$Res> {
  _$ReservationCopyWithImpl(this._self, this._then);

  final Reservation _self;
  final $Res Function(Reservation) _then;

  /// Create a copy of Reservation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bomId = null,
    Object? productionOrderId = null,
    Object? itemId = null,
    Object? itemCode = null,
    Object? itemName = null,
    Object? reservedQuantity = null,
    Object? unit = null,
    Object? status = null,
    Object? reservationDate = null,
    Object? expiryDate = null,
    Object? reservedBy = null,
    Object? warehouseId = freezed,
    Object? batchNumber = freezed,
    Object? lotNumber = freezed,
    Object? releaseDate = freezed,
    Object? releasedBy = freezed,
    Object? notes = freezed,
    Object? priority = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      bomId: null == bomId
          ? _self.bomId
          : bomId // ignore: cast_nullable_to_non_nullable
              as String,
      productionOrderId: null == productionOrderId
          ? _self.productionOrderId
          : productionOrderId // ignore: cast_nullable_to_non_nullable
              as String,
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
      reservedQuantity: null == reservedQuantity
          ? _self.reservedQuantity
          : reservedQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _self.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as ReservationStatus,
      reservationDate: null == reservationDate
          ? _self.reservationDate
          : reservationDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiryDate: null == expiryDate
          ? _self.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reservedBy: null == reservedBy
          ? _self.reservedBy
          : reservedBy // ignore: cast_nullable_to_non_nullable
              as String,
      warehouseId: freezed == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String?,
      batchNumber: freezed == batchNumber
          ? _self.batchNumber
          : batchNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      lotNumber: freezed == lotNumber
          ? _self.lotNumber
          : lotNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      releaseDate: freezed == releaseDate
          ? _self.releaseDate
          : releaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      releasedBy: freezed == releasedBy
          ? _self.releasedBy
          : releasedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: freezed == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int?,
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Reservation implements Reservation {
  const _Reservation(
      {required this.id,
      required this.bomId,
      required this.productionOrderId,
      required this.itemId,
      required this.itemCode,
      required this.itemName,
      required this.reservedQuantity,
      required this.unit,
      required this.status,
      required this.reservationDate,
      required this.expiryDate,
      required this.reservedBy,
      this.warehouseId,
      this.batchNumber,
      this.lotNumber,
      this.releaseDate,
      this.releasedBy,
      this.notes,
      this.priority,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;
  factory _Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);

  @override
  final String id;
  @override
  final String bomId;
  @override
  final String productionOrderId;
  @override
  final String itemId;
  @override
  final String itemCode;
  @override
  final String itemName;
  @override
  final double reservedQuantity;
  @override
  final String unit;
  @override
  final ReservationStatus status;
  @override
  final DateTime reservationDate;
  @override
  final DateTime expiryDate;
  @override
  final String reservedBy;
  @override
  final String? warehouseId;
  @override
  final String? batchNumber;
  @override
  final String? lotNumber;
  @override
  final DateTime? releaseDate;
  @override
  final String? releasedBy;
  @override
  final String? notes;
  @override
  final int? priority;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of Reservation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReservationCopyWith<_Reservation> get copyWith =>
      __$ReservationCopyWithImpl<_Reservation>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ReservationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Reservation &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bomId, bomId) || other.bomId == bomId) &&
            (identical(other.productionOrderId, productionOrderId) ||
                other.productionOrderId == productionOrderId) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.reservedQuantity, reservedQuantity) ||
                other.reservedQuantity == reservedQuantity) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reservationDate, reservationDate) ||
                other.reservationDate == reservationDate) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.reservedBy, reservedBy) ||
                other.reservedBy == reservedBy) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.batchNumber, batchNumber) ||
                other.batchNumber == batchNumber) &&
            (identical(other.lotNumber, lotNumber) ||
                other.lotNumber == lotNumber) &&
            (identical(other.releaseDate, releaseDate) ||
                other.releaseDate == releaseDate) &&
            (identical(other.releasedBy, releasedBy) ||
                other.releasedBy == releasedBy) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        bomId,
        productionOrderId,
        itemId,
        itemCode,
        itemName,
        reservedQuantity,
        unit,
        status,
        reservationDate,
        expiryDate,
        reservedBy,
        warehouseId,
        batchNumber,
        lotNumber,
        releaseDate,
        releasedBy,
        notes,
        priority,
        const DeepCollectionEquality().hash(_metadata)
      ]);

  @override
  String toString() {
    return 'Reservation(id: $id, bomId: $bomId, productionOrderId: $productionOrderId, itemId: $itemId, itemCode: $itemCode, itemName: $itemName, reservedQuantity: $reservedQuantity, unit: $unit, status: $status, reservationDate: $reservationDate, expiryDate: $expiryDate, reservedBy: $reservedBy, warehouseId: $warehouseId, batchNumber: $batchNumber, lotNumber: $lotNumber, releaseDate: $releaseDate, releasedBy: $releasedBy, notes: $notes, priority: $priority, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class _$ReservationCopyWith<$Res>
    implements $ReservationCopyWith<$Res> {
  factory _$ReservationCopyWith(
          _Reservation value, $Res Function(_Reservation) _then) =
      __$ReservationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String bomId,
      String productionOrderId,
      String itemId,
      String itemCode,
      String itemName,
      double reservedQuantity,
      String unit,
      ReservationStatus status,
      DateTime reservationDate,
      DateTime expiryDate,
      String reservedBy,
      String? warehouseId,
      String? batchNumber,
      String? lotNumber,
      DateTime? releaseDate,
      String? releasedBy,
      String? notes,
      int? priority,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$ReservationCopyWithImpl<$Res> implements _$ReservationCopyWith<$Res> {
  __$ReservationCopyWithImpl(this._self, this._then);

  final _Reservation _self;
  final $Res Function(_Reservation) _then;

  /// Create a copy of Reservation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? bomId = null,
    Object? productionOrderId = null,
    Object? itemId = null,
    Object? itemCode = null,
    Object? itemName = null,
    Object? reservedQuantity = null,
    Object? unit = null,
    Object? status = null,
    Object? reservationDate = null,
    Object? expiryDate = null,
    Object? reservedBy = null,
    Object? warehouseId = freezed,
    Object? batchNumber = freezed,
    Object? lotNumber = freezed,
    Object? releaseDate = freezed,
    Object? releasedBy = freezed,
    Object? notes = freezed,
    Object? priority = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_Reservation(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      bomId: null == bomId
          ? _self.bomId
          : bomId // ignore: cast_nullable_to_non_nullable
              as String,
      productionOrderId: null == productionOrderId
          ? _self.productionOrderId
          : productionOrderId // ignore: cast_nullable_to_non_nullable
              as String,
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
      reservedQuantity: null == reservedQuantity
          ? _self.reservedQuantity
          : reservedQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _self.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as ReservationStatus,
      reservationDate: null == reservationDate
          ? _self.reservationDate
          : reservationDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiryDate: null == expiryDate
          ? _self.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reservedBy: null == reservedBy
          ? _self.reservedBy
          : reservedBy // ignore: cast_nullable_to_non_nullable
              as String,
      warehouseId: freezed == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String?,
      batchNumber: freezed == batchNumber
          ? _self.batchNumber
          : batchNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      lotNumber: freezed == lotNumber
          ? _self.lotNumber
          : lotNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      releaseDate: freezed == releaseDate
          ? _self.releaseDate
          : releaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      releasedBy: freezed == releasedBy
          ? _self.releasedBy
          : releasedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: freezed == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int?,
      metadata: freezed == metadata
          ? _self._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
mixin _$ReservationRequest {
  String get bomId;
  String get productionOrderId;
  double get batchSize;
  DateTime get requiredDate;
  String get requestedBy;
  String? get warehouseId;
  int? get priority;
  String? get notes;
  Map<String, String>? get itemPreferences;

  /// Create a copy of ReservationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ReservationRequestCopyWith<ReservationRequest> get copyWith =>
      _$ReservationRequestCopyWithImpl<ReservationRequest>(
          this as ReservationRequest, _$identity);

  /// Serializes this ReservationRequest to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ReservationRequest &&
            (identical(other.bomId, bomId) || other.bomId == bomId) &&
            (identical(other.productionOrderId, productionOrderId) ||
                other.productionOrderId == productionOrderId) &&
            (identical(other.batchSize, batchSize) ||
                other.batchSize == batchSize) &&
            (identical(other.requiredDate, requiredDate) ||
                other.requiredDate == requiredDate) &&
            (identical(other.requestedBy, requestedBy) ||
                other.requestedBy == requestedBy) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality()
                .equals(other.itemPreferences, itemPreferences));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      bomId,
      productionOrderId,
      batchSize,
      requiredDate,
      requestedBy,
      warehouseId,
      priority,
      notes,
      const DeepCollectionEquality().hash(itemPreferences));

  @override
  String toString() {
    return 'ReservationRequest(bomId: $bomId, productionOrderId: $productionOrderId, batchSize: $batchSize, requiredDate: $requiredDate, requestedBy: $requestedBy, warehouseId: $warehouseId, priority: $priority, notes: $notes, itemPreferences: $itemPreferences)';
  }
}

/// @nodoc
abstract mixin class $ReservationRequestCopyWith<$Res> {
  factory $ReservationRequestCopyWith(
          ReservationRequest value, $Res Function(ReservationRequest) _then) =
      _$ReservationRequestCopyWithImpl;
  @useResult
  $Res call(
      {String bomId,
      String productionOrderId,
      double batchSize,
      DateTime requiredDate,
      String requestedBy,
      String? warehouseId,
      int? priority,
      String? notes,
      Map<String, String>? itemPreferences});
}

/// @nodoc
class _$ReservationRequestCopyWithImpl<$Res>
    implements $ReservationRequestCopyWith<$Res> {
  _$ReservationRequestCopyWithImpl(this._self, this._then);

  final ReservationRequest _self;
  final $Res Function(ReservationRequest) _then;

  /// Create a copy of ReservationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bomId = null,
    Object? productionOrderId = null,
    Object? batchSize = null,
    Object? requiredDate = null,
    Object? requestedBy = null,
    Object? warehouseId = freezed,
    Object? priority = freezed,
    Object? notes = freezed,
    Object? itemPreferences = freezed,
  }) {
    return _then(_self.copyWith(
      bomId: null == bomId
          ? _self.bomId
          : bomId // ignore: cast_nullable_to_non_nullable
              as String,
      productionOrderId: null == productionOrderId
          ? _self.productionOrderId
          : productionOrderId // ignore: cast_nullable_to_non_nullable
              as String,
      batchSize: null == batchSize
          ? _self.batchSize
          : batchSize // ignore: cast_nullable_to_non_nullable
              as double,
      requiredDate: null == requiredDate
          ? _self.requiredDate
          : requiredDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      requestedBy: null == requestedBy
          ? _self.requestedBy
          : requestedBy // ignore: cast_nullable_to_non_nullable
              as String,
      warehouseId: freezed == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: freezed == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      itemPreferences: freezed == itemPreferences
          ? _self.itemPreferences
          : itemPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ReservationRequest implements ReservationRequest {
  const _ReservationRequest(
      {required this.bomId,
      required this.productionOrderId,
      required this.batchSize,
      required this.requiredDate,
      required this.requestedBy,
      this.warehouseId,
      this.priority,
      this.notes,
      final Map<String, String>? itemPreferences})
      : _itemPreferences = itemPreferences;
  factory _ReservationRequest.fromJson(Map<String, dynamic> json) =>
      _$ReservationRequestFromJson(json);

  @override
  final String bomId;
  @override
  final String productionOrderId;
  @override
  final double batchSize;
  @override
  final DateTime requiredDate;
  @override
  final String requestedBy;
  @override
  final String? warehouseId;
  @override
  final int? priority;
  @override
  final String? notes;
  final Map<String, String>? _itemPreferences;
  @override
  Map<String, String>? get itemPreferences {
    final value = _itemPreferences;
    if (value == null) return null;
    if (_itemPreferences is EqualUnmodifiableMapView) return _itemPreferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of ReservationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReservationRequestCopyWith<_ReservationRequest> get copyWith =>
      __$ReservationRequestCopyWithImpl<_ReservationRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ReservationRequestToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ReservationRequest &&
            (identical(other.bomId, bomId) || other.bomId == bomId) &&
            (identical(other.productionOrderId, productionOrderId) ||
                other.productionOrderId == productionOrderId) &&
            (identical(other.batchSize, batchSize) ||
                other.batchSize == batchSize) &&
            (identical(other.requiredDate, requiredDate) ||
                other.requiredDate == requiredDate) &&
            (identical(other.requestedBy, requestedBy) ||
                other.requestedBy == requestedBy) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality()
                .equals(other._itemPreferences, _itemPreferences));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      bomId,
      productionOrderId,
      batchSize,
      requiredDate,
      requestedBy,
      warehouseId,
      priority,
      notes,
      const DeepCollectionEquality().hash(_itemPreferences));

  @override
  String toString() {
    return 'ReservationRequest(bomId: $bomId, productionOrderId: $productionOrderId, batchSize: $batchSize, requiredDate: $requiredDate, requestedBy: $requestedBy, warehouseId: $warehouseId, priority: $priority, notes: $notes, itemPreferences: $itemPreferences)';
  }
}

/// @nodoc
abstract mixin class _$ReservationRequestCopyWith<$Res>
    implements $ReservationRequestCopyWith<$Res> {
  factory _$ReservationRequestCopyWith(
          _ReservationRequest value, $Res Function(_ReservationRequest) _then) =
      __$ReservationRequestCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String bomId,
      String productionOrderId,
      double batchSize,
      DateTime requiredDate,
      String requestedBy,
      String? warehouseId,
      int? priority,
      String? notes,
      Map<String, String>? itemPreferences});
}

/// @nodoc
class __$ReservationRequestCopyWithImpl<$Res>
    implements _$ReservationRequestCopyWith<$Res> {
  __$ReservationRequestCopyWithImpl(this._self, this._then);

  final _ReservationRequest _self;
  final $Res Function(_ReservationRequest) _then;

  /// Create a copy of ReservationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? bomId = null,
    Object? productionOrderId = null,
    Object? batchSize = null,
    Object? requiredDate = null,
    Object? requestedBy = null,
    Object? warehouseId = freezed,
    Object? priority = freezed,
    Object? notes = freezed,
    Object? itemPreferences = freezed,
  }) {
    return _then(_ReservationRequest(
      bomId: null == bomId
          ? _self.bomId
          : bomId // ignore: cast_nullable_to_non_nullable
              as String,
      productionOrderId: null == productionOrderId
          ? _self.productionOrderId
          : productionOrderId // ignore: cast_nullable_to_non_nullable
              as String,
      batchSize: null == batchSize
          ? _self.batchSize
          : batchSize // ignore: cast_nullable_to_non_nullable
              as double,
      requiredDate: null == requiredDate
          ? _self.requiredDate
          : requiredDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      requestedBy: null == requestedBy
          ? _self.requestedBy
          : requestedBy // ignore: cast_nullable_to_non_nullable
              as String,
      warehouseId: freezed == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: freezed == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      itemPreferences: freezed == itemPreferences
          ? _self._itemPreferences
          : itemPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
    ));
  }
}

/// @nodoc
mixin _$ReservationResult {
  String get requestId;
  bool get isFullyReserved;
  List<Reservation> get reservations;
  List<ReservationFailure> get failures;
  DateTime get processedAt;
  String? get notes;

  /// Create a copy of ReservationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ReservationResultCopyWith<ReservationResult> get copyWith =>
      _$ReservationResultCopyWithImpl<ReservationResult>(
          this as ReservationResult, _$identity);

  /// Serializes this ReservationResult to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ReservationResult &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.isFullyReserved, isFullyReserved) ||
                other.isFullyReserved == isFullyReserved) &&
            const DeepCollectionEquality()
                .equals(other.reservations, reservations) &&
            const DeepCollectionEquality().equals(other.failures, failures) &&
            (identical(other.processedAt, processedAt) ||
                other.processedAt == processedAt) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      requestId,
      isFullyReserved,
      const DeepCollectionEquality().hash(reservations),
      const DeepCollectionEquality().hash(failures),
      processedAt,
      notes);

  @override
  String toString() {
    return 'ReservationResult(requestId: $requestId, isFullyReserved: $isFullyReserved, reservations: $reservations, failures: $failures, processedAt: $processedAt, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class $ReservationResultCopyWith<$Res> {
  factory $ReservationResultCopyWith(
          ReservationResult value, $Res Function(ReservationResult) _then) =
      _$ReservationResultCopyWithImpl;
  @useResult
  $Res call(
      {String requestId,
      bool isFullyReserved,
      List<Reservation> reservations,
      List<ReservationFailure> failures,
      DateTime processedAt,
      String? notes});
}

/// @nodoc
class _$ReservationResultCopyWithImpl<$Res>
    implements $ReservationResultCopyWith<$Res> {
  _$ReservationResultCopyWithImpl(this._self, this._then);

  final ReservationResult _self;
  final $Res Function(ReservationResult) _then;

  /// Create a copy of ReservationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestId = null,
    Object? isFullyReserved = null,
    Object? reservations = null,
    Object? failures = null,
    Object? processedAt = null,
    Object? notes = freezed,
  }) {
    return _then(_self.copyWith(
      requestId: null == requestId
          ? _self.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      isFullyReserved: null == isFullyReserved
          ? _self.isFullyReserved
          : isFullyReserved // ignore: cast_nullable_to_non_nullable
              as bool,
      reservations: null == reservations
          ? _self.reservations
          : reservations // ignore: cast_nullable_to_non_nullable
              as List<Reservation>,
      failures: null == failures
          ? _self.failures
          : failures // ignore: cast_nullable_to_non_nullable
              as List<ReservationFailure>,
      processedAt: null == processedAt
          ? _self.processedAt
          : processedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ReservationResult implements ReservationResult {
  const _ReservationResult(
      {required this.requestId,
      required this.isFullyReserved,
      required final List<Reservation> reservations,
      required final List<ReservationFailure> failures,
      required this.processedAt,
      this.notes})
      : _reservations = reservations,
        _failures = failures;
  factory _ReservationResult.fromJson(Map<String, dynamic> json) =>
      _$ReservationResultFromJson(json);

  @override
  final String requestId;
  @override
  final bool isFullyReserved;
  final List<Reservation> _reservations;
  @override
  List<Reservation> get reservations {
    if (_reservations is EqualUnmodifiableListView) return _reservations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reservations);
  }

  final List<ReservationFailure> _failures;
  @override
  List<ReservationFailure> get failures {
    if (_failures is EqualUnmodifiableListView) return _failures;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_failures);
  }

  @override
  final DateTime processedAt;
  @override
  final String? notes;

  /// Create a copy of ReservationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReservationResultCopyWith<_ReservationResult> get copyWith =>
      __$ReservationResultCopyWithImpl<_ReservationResult>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ReservationResultToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ReservationResult &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.isFullyReserved, isFullyReserved) ||
                other.isFullyReserved == isFullyReserved) &&
            const DeepCollectionEquality()
                .equals(other._reservations, _reservations) &&
            const DeepCollectionEquality().equals(other._failures, _failures) &&
            (identical(other.processedAt, processedAt) ||
                other.processedAt == processedAt) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      requestId,
      isFullyReserved,
      const DeepCollectionEquality().hash(_reservations),
      const DeepCollectionEquality().hash(_failures),
      processedAt,
      notes);

  @override
  String toString() {
    return 'ReservationResult(requestId: $requestId, isFullyReserved: $isFullyReserved, reservations: $reservations, failures: $failures, processedAt: $processedAt, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class _$ReservationResultCopyWith<$Res>
    implements $ReservationResultCopyWith<$Res> {
  factory _$ReservationResultCopyWith(
          _ReservationResult value, $Res Function(_ReservationResult) _then) =
      __$ReservationResultCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String requestId,
      bool isFullyReserved,
      List<Reservation> reservations,
      List<ReservationFailure> failures,
      DateTime processedAt,
      String? notes});
}

/// @nodoc
class __$ReservationResultCopyWithImpl<$Res>
    implements _$ReservationResultCopyWith<$Res> {
  __$ReservationResultCopyWithImpl(this._self, this._then);

  final _ReservationResult _self;
  final $Res Function(_ReservationResult) _then;

  /// Create a copy of ReservationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? requestId = null,
    Object? isFullyReserved = null,
    Object? reservations = null,
    Object? failures = null,
    Object? processedAt = null,
    Object? notes = freezed,
  }) {
    return _then(_ReservationResult(
      requestId: null == requestId
          ? _self.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      isFullyReserved: null == isFullyReserved
          ? _self.isFullyReserved
          : isFullyReserved // ignore: cast_nullable_to_non_nullable
              as bool,
      reservations: null == reservations
          ? _self._reservations
          : reservations // ignore: cast_nullable_to_non_nullable
              as List<Reservation>,
      failures: null == failures
          ? _self._failures
          : failures // ignore: cast_nullable_to_non_nullable
              as List<ReservationFailure>,
      processedAt: null == processedAt
          ? _self.processedAt
          : processedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$ReservationFailure {
  String get itemId;
  String get itemCode;
  double get requestedQuantity;
  double get availableQuantity;
  String get reason;
  FailureType get failureType;
  List<String>? get suggestedActions;

  /// Create a copy of ReservationFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ReservationFailureCopyWith<ReservationFailure> get copyWith =>
      _$ReservationFailureCopyWithImpl<ReservationFailure>(
          this as ReservationFailure, _$identity);

  /// Serializes this ReservationFailure to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ReservationFailure &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.requestedQuantity, requestedQuantity) ||
                other.requestedQuantity == requestedQuantity) &&
            (identical(other.availableQuantity, availableQuantity) ||
                other.availableQuantity == availableQuantity) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.failureType, failureType) ||
                other.failureType == failureType) &&
            const DeepCollectionEquality()
                .equals(other.suggestedActions, suggestedActions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      itemId,
      itemCode,
      requestedQuantity,
      availableQuantity,
      reason,
      failureType,
      const DeepCollectionEquality().hash(suggestedActions));

  @override
  String toString() {
    return 'ReservationFailure(itemId: $itemId, itemCode: $itemCode, requestedQuantity: $requestedQuantity, availableQuantity: $availableQuantity, reason: $reason, failureType: $failureType, suggestedActions: $suggestedActions)';
  }
}

/// @nodoc
abstract mixin class $ReservationFailureCopyWith<$Res> {
  factory $ReservationFailureCopyWith(
          ReservationFailure value, $Res Function(ReservationFailure) _then) =
      _$ReservationFailureCopyWithImpl;
  @useResult
  $Res call(
      {String itemId,
      String itemCode,
      double requestedQuantity,
      double availableQuantity,
      String reason,
      FailureType failureType,
      List<String>? suggestedActions});
}

/// @nodoc
class _$ReservationFailureCopyWithImpl<$Res>
    implements $ReservationFailureCopyWith<$Res> {
  _$ReservationFailureCopyWithImpl(this._self, this._then);

  final ReservationFailure _self;
  final $Res Function(ReservationFailure) _then;

  /// Create a copy of ReservationFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? itemCode = null,
    Object? requestedQuantity = null,
    Object? availableQuantity = null,
    Object? reason = null,
    Object? failureType = null,
    Object? suggestedActions = freezed,
  }) {
    return _then(_self.copyWith(
      itemId: null == itemId
          ? _self.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      itemCode: null == itemCode
          ? _self.itemCode
          : itemCode // ignore: cast_nullable_to_non_nullable
              as String,
      requestedQuantity: null == requestedQuantity
          ? _self.requestedQuantity
          : requestedQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      availableQuantity: null == availableQuantity
          ? _self.availableQuantity
          : availableQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      reason: null == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      failureType: null == failureType
          ? _self.failureType
          : failureType // ignore: cast_nullable_to_non_nullable
              as FailureType,
      suggestedActions: freezed == suggestedActions
          ? _self.suggestedActions
          : suggestedActions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ReservationFailure implements ReservationFailure {
  const _ReservationFailure(
      {required this.itemId,
      required this.itemCode,
      required this.requestedQuantity,
      required this.availableQuantity,
      required this.reason,
      required this.failureType,
      final List<String>? suggestedActions})
      : _suggestedActions = suggestedActions;
  factory _ReservationFailure.fromJson(Map<String, dynamic> json) =>
      _$ReservationFailureFromJson(json);

  @override
  final String itemId;
  @override
  final String itemCode;
  @override
  final double requestedQuantity;
  @override
  final double availableQuantity;
  @override
  final String reason;
  @override
  final FailureType failureType;
  final List<String>? _suggestedActions;
  @override
  List<String>? get suggestedActions {
    final value = _suggestedActions;
    if (value == null) return null;
    if (_suggestedActions is EqualUnmodifiableListView)
      return _suggestedActions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Create a copy of ReservationFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReservationFailureCopyWith<_ReservationFailure> get copyWith =>
      __$ReservationFailureCopyWithImpl<_ReservationFailure>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ReservationFailureToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ReservationFailure &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.requestedQuantity, requestedQuantity) ||
                other.requestedQuantity == requestedQuantity) &&
            (identical(other.availableQuantity, availableQuantity) ||
                other.availableQuantity == availableQuantity) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.failureType, failureType) ||
                other.failureType == failureType) &&
            const DeepCollectionEquality()
                .equals(other._suggestedActions, _suggestedActions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      itemId,
      itemCode,
      requestedQuantity,
      availableQuantity,
      reason,
      failureType,
      const DeepCollectionEquality().hash(_suggestedActions));

  @override
  String toString() {
    return 'ReservationFailure(itemId: $itemId, itemCode: $itemCode, requestedQuantity: $requestedQuantity, availableQuantity: $availableQuantity, reason: $reason, failureType: $failureType, suggestedActions: $suggestedActions)';
  }
}

/// @nodoc
abstract mixin class _$ReservationFailureCopyWith<$Res>
    implements $ReservationFailureCopyWith<$Res> {
  factory _$ReservationFailureCopyWith(
          _ReservationFailure value, $Res Function(_ReservationFailure) _then) =
      __$ReservationFailureCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String itemId,
      String itemCode,
      double requestedQuantity,
      double availableQuantity,
      String reason,
      FailureType failureType,
      List<String>? suggestedActions});
}

/// @nodoc
class __$ReservationFailureCopyWithImpl<$Res>
    implements _$ReservationFailureCopyWith<$Res> {
  __$ReservationFailureCopyWithImpl(this._self, this._then);

  final _ReservationFailure _self;
  final $Res Function(_ReservationFailure) _then;

  /// Create a copy of ReservationFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? itemId = null,
    Object? itemCode = null,
    Object? requestedQuantity = null,
    Object? availableQuantity = null,
    Object? reason = null,
    Object? failureType = null,
    Object? suggestedActions = freezed,
  }) {
    return _then(_ReservationFailure(
      itemId: null == itemId
          ? _self.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      itemCode: null == itemCode
          ? _self.itemCode
          : itemCode // ignore: cast_nullable_to_non_nullable
              as String,
      requestedQuantity: null == requestedQuantity
          ? _self.requestedQuantity
          : requestedQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      availableQuantity: null == availableQuantity
          ? _self.availableQuantity
          : availableQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      reason: null == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      failureType: null == failureType
          ? _self.failureType
          : failureType // ignore: cast_nullable_to_non_nullable
              as FailureType,
      suggestedActions: freezed == suggestedActions
          ? _self._suggestedActions
          : suggestedActions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
mixin _$ReservationConflict {
  String get itemId;
  String get itemCode;
  String get itemName;
  double get requiredQuantity;
  double get availableQuantity;
  List<Reservation> get conflictingReservations;
  ConflictType get conflictType;

  /// Create a copy of ReservationConflict
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ReservationConflictCopyWith<ReservationConflict> get copyWith =>
      _$ReservationConflictCopyWithImpl<ReservationConflict>(
          this as ReservationConflict, _$identity);

  /// Serializes this ReservationConflict to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ReservationConflict &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.requiredQuantity, requiredQuantity) ||
                other.requiredQuantity == requiredQuantity) &&
            (identical(other.availableQuantity, availableQuantity) ||
                other.availableQuantity == availableQuantity) &&
            const DeepCollectionEquality().equals(
                other.conflictingReservations, conflictingReservations) &&
            (identical(other.conflictType, conflictType) ||
                other.conflictType == conflictType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      itemId,
      itemCode,
      itemName,
      requiredQuantity,
      availableQuantity,
      const DeepCollectionEquality().hash(conflictingReservations),
      conflictType);

  @override
  String toString() {
    return 'ReservationConflict(itemId: $itemId, itemCode: $itemCode, itemName: $itemName, requiredQuantity: $requiredQuantity, availableQuantity: $availableQuantity, conflictingReservations: $conflictingReservations, conflictType: $conflictType)';
  }
}

/// @nodoc
abstract mixin class $ReservationConflictCopyWith<$Res> {
  factory $ReservationConflictCopyWith(
          ReservationConflict value, $Res Function(ReservationConflict) _then) =
      _$ReservationConflictCopyWithImpl;
  @useResult
  $Res call(
      {String itemId,
      String itemCode,
      String itemName,
      double requiredQuantity,
      double availableQuantity,
      List<Reservation> conflictingReservations,
      ConflictType conflictType});
}

/// @nodoc
class _$ReservationConflictCopyWithImpl<$Res>
    implements $ReservationConflictCopyWith<$Res> {
  _$ReservationConflictCopyWithImpl(this._self, this._then);

  final ReservationConflict _self;
  final $Res Function(ReservationConflict) _then;

  /// Create a copy of ReservationConflict
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? itemCode = null,
    Object? itemName = null,
    Object? requiredQuantity = null,
    Object? availableQuantity = null,
    Object? conflictingReservations = null,
    Object? conflictType = null,
  }) {
    return _then(_self.copyWith(
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
      requiredQuantity: null == requiredQuantity
          ? _self.requiredQuantity
          : requiredQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      availableQuantity: null == availableQuantity
          ? _self.availableQuantity
          : availableQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      conflictingReservations: null == conflictingReservations
          ? _self.conflictingReservations
          : conflictingReservations // ignore: cast_nullable_to_non_nullable
              as List<Reservation>,
      conflictType: null == conflictType
          ? _self.conflictType
          : conflictType // ignore: cast_nullable_to_non_nullable
              as ConflictType,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ReservationConflict implements ReservationConflict {
  const _ReservationConflict(
      {required this.itemId,
      required this.itemCode,
      required this.itemName,
      required this.requiredQuantity,
      required this.availableQuantity,
      required final List<Reservation> conflictingReservations,
      required this.conflictType})
      : _conflictingReservations = conflictingReservations;
  factory _ReservationConflict.fromJson(Map<String, dynamic> json) =>
      _$ReservationConflictFromJson(json);

  @override
  final String itemId;
  @override
  final String itemCode;
  @override
  final String itemName;
  @override
  final double requiredQuantity;
  @override
  final double availableQuantity;
  final List<Reservation> _conflictingReservations;
  @override
  List<Reservation> get conflictingReservations {
    if (_conflictingReservations is EqualUnmodifiableListView)
      return _conflictingReservations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conflictingReservations);
  }

  @override
  final ConflictType conflictType;

  /// Create a copy of ReservationConflict
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReservationConflictCopyWith<_ReservationConflict> get copyWith =>
      __$ReservationConflictCopyWithImpl<_ReservationConflict>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ReservationConflictToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ReservationConflict &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.requiredQuantity, requiredQuantity) ||
                other.requiredQuantity == requiredQuantity) &&
            (identical(other.availableQuantity, availableQuantity) ||
                other.availableQuantity == availableQuantity) &&
            const DeepCollectionEquality().equals(
                other._conflictingReservations, _conflictingReservations) &&
            (identical(other.conflictType, conflictType) ||
                other.conflictType == conflictType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      itemId,
      itemCode,
      itemName,
      requiredQuantity,
      availableQuantity,
      const DeepCollectionEquality().hash(_conflictingReservations),
      conflictType);

  @override
  String toString() {
    return 'ReservationConflict(itemId: $itemId, itemCode: $itemCode, itemName: $itemName, requiredQuantity: $requiredQuantity, availableQuantity: $availableQuantity, conflictingReservations: $conflictingReservations, conflictType: $conflictType)';
  }
}

/// @nodoc
abstract mixin class _$ReservationConflictCopyWith<$Res>
    implements $ReservationConflictCopyWith<$Res> {
  factory _$ReservationConflictCopyWith(_ReservationConflict value,
          $Res Function(_ReservationConflict) _then) =
      __$ReservationConflictCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String itemId,
      String itemCode,
      String itemName,
      double requiredQuantity,
      double availableQuantity,
      List<Reservation> conflictingReservations,
      ConflictType conflictType});
}

/// @nodoc
class __$ReservationConflictCopyWithImpl<$Res>
    implements _$ReservationConflictCopyWith<$Res> {
  __$ReservationConflictCopyWithImpl(this._self, this._then);

  final _ReservationConflict _self;
  final $Res Function(_ReservationConflict) _then;

  /// Create a copy of ReservationConflict
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? itemId = null,
    Object? itemCode = null,
    Object? itemName = null,
    Object? requiredQuantity = null,
    Object? availableQuantity = null,
    Object? conflictingReservations = null,
    Object? conflictType = null,
  }) {
    return _then(_ReservationConflict(
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
      requiredQuantity: null == requiredQuantity
          ? _self.requiredQuantity
          : requiredQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      availableQuantity: null == availableQuantity
          ? _self.availableQuantity
          : availableQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      conflictingReservations: null == conflictingReservations
          ? _self._conflictingReservations
          : conflictingReservations // ignore: cast_nullable_to_non_nullable
              as List<Reservation>,
      conflictType: null == conflictType
          ? _self.conflictType
          : conflictType // ignore: cast_nullable_to_non_nullable
              as ConflictType,
    ));
  }
}

/// @nodoc
mixin _$ReservationOptimization {
  List<OptimizedAllocation> get optimizedAllocations;
  List<ReservationRequest> get unallocatedRequests;
  double get optimizationScore;
  DateTime get processedAt;

  /// Create a copy of ReservationOptimization
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ReservationOptimizationCopyWith<ReservationOptimization> get copyWith =>
      _$ReservationOptimizationCopyWithImpl<ReservationOptimization>(
          this as ReservationOptimization, _$identity);

  /// Serializes this ReservationOptimization to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ReservationOptimization &&
            const DeepCollectionEquality()
                .equals(other.optimizedAllocations, optimizedAllocations) &&
            const DeepCollectionEquality()
                .equals(other.unallocatedRequests, unallocatedRequests) &&
            (identical(other.optimizationScore, optimizationScore) ||
                other.optimizationScore == optimizationScore) &&
            (identical(other.processedAt, processedAt) ||
                other.processedAt == processedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(optimizedAllocations),
      const DeepCollectionEquality().hash(unallocatedRequests),
      optimizationScore,
      processedAt);

  @override
  String toString() {
    return 'ReservationOptimization(optimizedAllocations: $optimizedAllocations, unallocatedRequests: $unallocatedRequests, optimizationScore: $optimizationScore, processedAt: $processedAt)';
  }
}

/// @nodoc
abstract mixin class $ReservationOptimizationCopyWith<$Res> {
  factory $ReservationOptimizationCopyWith(ReservationOptimization value,
          $Res Function(ReservationOptimization) _then) =
      _$ReservationOptimizationCopyWithImpl;
  @useResult
  $Res call(
      {List<OptimizedAllocation> optimizedAllocations,
      List<ReservationRequest> unallocatedRequests,
      double optimizationScore,
      DateTime processedAt});
}

/// @nodoc
class _$ReservationOptimizationCopyWithImpl<$Res>
    implements $ReservationOptimizationCopyWith<$Res> {
  _$ReservationOptimizationCopyWithImpl(this._self, this._then);

  final ReservationOptimization _self;
  final $Res Function(ReservationOptimization) _then;

  /// Create a copy of ReservationOptimization
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? optimizedAllocations = null,
    Object? unallocatedRequests = null,
    Object? optimizationScore = null,
    Object? processedAt = null,
  }) {
    return _then(_self.copyWith(
      optimizedAllocations: null == optimizedAllocations
          ? _self.optimizedAllocations
          : optimizedAllocations // ignore: cast_nullable_to_non_nullable
              as List<OptimizedAllocation>,
      unallocatedRequests: null == unallocatedRequests
          ? _self.unallocatedRequests
          : unallocatedRequests // ignore: cast_nullable_to_non_nullable
              as List<ReservationRequest>,
      optimizationScore: null == optimizationScore
          ? _self.optimizationScore
          : optimizationScore // ignore: cast_nullable_to_non_nullable
              as double,
      processedAt: null == processedAt
          ? _self.processedAt
          : processedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ReservationOptimization implements ReservationOptimization {
  const _ReservationOptimization(
      {required final List<OptimizedAllocation> optimizedAllocations,
      required final List<ReservationRequest> unallocatedRequests,
      required this.optimizationScore,
      required this.processedAt})
      : _optimizedAllocations = optimizedAllocations,
        _unallocatedRequests = unallocatedRequests;
  factory _ReservationOptimization.fromJson(Map<String, dynamic> json) =>
      _$ReservationOptimizationFromJson(json);

  final List<OptimizedAllocation> _optimizedAllocations;
  @override
  List<OptimizedAllocation> get optimizedAllocations {
    if (_optimizedAllocations is EqualUnmodifiableListView)
      return _optimizedAllocations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_optimizedAllocations);
  }

  final List<ReservationRequest> _unallocatedRequests;
  @override
  List<ReservationRequest> get unallocatedRequests {
    if (_unallocatedRequests is EqualUnmodifiableListView)
      return _unallocatedRequests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_unallocatedRequests);
  }

  @override
  final double optimizationScore;
  @override
  final DateTime processedAt;

  /// Create a copy of ReservationOptimization
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReservationOptimizationCopyWith<_ReservationOptimization> get copyWith =>
      __$ReservationOptimizationCopyWithImpl<_ReservationOptimization>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ReservationOptimizationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ReservationOptimization &&
            const DeepCollectionEquality()
                .equals(other._optimizedAllocations, _optimizedAllocations) &&
            const DeepCollectionEquality()
                .equals(other._unallocatedRequests, _unallocatedRequests) &&
            (identical(other.optimizationScore, optimizationScore) ||
                other.optimizationScore == optimizationScore) &&
            (identical(other.processedAt, processedAt) ||
                other.processedAt == processedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_optimizedAllocations),
      const DeepCollectionEquality().hash(_unallocatedRequests),
      optimizationScore,
      processedAt);

  @override
  String toString() {
    return 'ReservationOptimization(optimizedAllocations: $optimizedAllocations, unallocatedRequests: $unallocatedRequests, optimizationScore: $optimizationScore, processedAt: $processedAt)';
  }
}

/// @nodoc
abstract mixin class _$ReservationOptimizationCopyWith<$Res>
    implements $ReservationOptimizationCopyWith<$Res> {
  factory _$ReservationOptimizationCopyWith(_ReservationOptimization value,
          $Res Function(_ReservationOptimization) _then) =
      __$ReservationOptimizationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<OptimizedAllocation> optimizedAllocations,
      List<ReservationRequest> unallocatedRequests,
      double optimizationScore,
      DateTime processedAt});
}

/// @nodoc
class __$ReservationOptimizationCopyWithImpl<$Res>
    implements _$ReservationOptimizationCopyWith<$Res> {
  __$ReservationOptimizationCopyWithImpl(this._self, this._then);

  final _ReservationOptimization _self;
  final $Res Function(_ReservationOptimization) _then;

  /// Create a copy of ReservationOptimization
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? optimizedAllocations = null,
    Object? unallocatedRequests = null,
    Object? optimizationScore = null,
    Object? processedAt = null,
  }) {
    return _then(_ReservationOptimization(
      optimizedAllocations: null == optimizedAllocations
          ? _self._optimizedAllocations
          : optimizedAllocations // ignore: cast_nullable_to_non_nullable
              as List<OptimizedAllocation>,
      unallocatedRequests: null == unallocatedRequests
          ? _self._unallocatedRequests
          : unallocatedRequests // ignore: cast_nullable_to_non_nullable
              as List<ReservationRequest>,
      optimizationScore: null == optimizationScore
          ? _self.optimizationScore
          : optimizationScore // ignore: cast_nullable_to_non_nullable
              as double,
      processedAt: null == processedAt
          ? _self.processedAt
          : processedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
mixin _$OptimizedAllocation {
  ReservationRequest get request;
  ReservationResult get result;
  double get allocationScore;

  /// Create a copy of OptimizedAllocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OptimizedAllocationCopyWith<OptimizedAllocation> get copyWith =>
      _$OptimizedAllocationCopyWithImpl<OptimizedAllocation>(
          this as OptimizedAllocation, _$identity);

  /// Serializes this OptimizedAllocation to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OptimizedAllocation &&
            (identical(other.request, request) || other.request == request) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.allocationScore, allocationScore) ||
                other.allocationScore == allocationScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, request, result, allocationScore);

  @override
  String toString() {
    return 'OptimizedAllocation(request: $request, result: $result, allocationScore: $allocationScore)';
  }
}

/// @nodoc
abstract mixin class $OptimizedAllocationCopyWith<$Res> {
  factory $OptimizedAllocationCopyWith(
          OptimizedAllocation value, $Res Function(OptimizedAllocation) _then) =
      _$OptimizedAllocationCopyWithImpl;
  @useResult
  $Res call(
      {ReservationRequest request,
      ReservationResult result,
      double allocationScore});

  $ReservationRequestCopyWith<$Res> get request;
  $ReservationResultCopyWith<$Res> get result;
}

/// @nodoc
class _$OptimizedAllocationCopyWithImpl<$Res>
    implements $OptimizedAllocationCopyWith<$Res> {
  _$OptimizedAllocationCopyWithImpl(this._self, this._then);

  final OptimizedAllocation _self;
  final $Res Function(OptimizedAllocation) _then;

  /// Create a copy of OptimizedAllocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? request = null,
    Object? result = null,
    Object? allocationScore = null,
  }) {
    return _then(_self.copyWith(
      request: null == request
          ? _self.request
          : request // ignore: cast_nullable_to_non_nullable
              as ReservationRequest,
      result: null == result
          ? _self.result
          : result // ignore: cast_nullable_to_non_nullable
              as ReservationResult,
      allocationScore: null == allocationScore
          ? _self.allocationScore
          : allocationScore // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }

  /// Create a copy of OptimizedAllocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReservationRequestCopyWith<$Res> get request {
    return $ReservationRequestCopyWith<$Res>(_self.request, (value) {
      return _then(_self.copyWith(request: value));
    });
  }

  /// Create a copy of OptimizedAllocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReservationResultCopyWith<$Res> get result {
    return $ReservationResultCopyWith<$Res>(_self.result, (value) {
      return _then(_self.copyWith(result: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _OptimizedAllocation implements OptimizedAllocation {
  const _OptimizedAllocation(
      {required this.request,
      required this.result,
      required this.allocationScore});
  factory _OptimizedAllocation.fromJson(Map<String, dynamic> json) =>
      _$OptimizedAllocationFromJson(json);

  @override
  final ReservationRequest request;
  @override
  final ReservationResult result;
  @override
  final double allocationScore;

  /// Create a copy of OptimizedAllocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OptimizedAllocationCopyWith<_OptimizedAllocation> get copyWith =>
      __$OptimizedAllocationCopyWithImpl<_OptimizedAllocation>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$OptimizedAllocationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OptimizedAllocation &&
            (identical(other.request, request) || other.request == request) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.allocationScore, allocationScore) ||
                other.allocationScore == allocationScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, request, result, allocationScore);

  @override
  String toString() {
    return 'OptimizedAllocation(request: $request, result: $result, allocationScore: $allocationScore)';
  }
}

/// @nodoc
abstract mixin class _$OptimizedAllocationCopyWith<$Res>
    implements $OptimizedAllocationCopyWith<$Res> {
  factory _$OptimizedAllocationCopyWith(_OptimizedAllocation value,
          $Res Function(_OptimizedAllocation) _then) =
      __$OptimizedAllocationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {ReservationRequest request,
      ReservationResult result,
      double allocationScore});

  @override
  $ReservationRequestCopyWith<$Res> get request;
  @override
  $ReservationResultCopyWith<$Res> get result;
}

/// @nodoc
class __$OptimizedAllocationCopyWithImpl<$Res>
    implements _$OptimizedAllocationCopyWith<$Res> {
  __$OptimizedAllocationCopyWithImpl(this._self, this._then);

  final _OptimizedAllocation _self;
  final $Res Function(_OptimizedAllocation) _then;

  /// Create a copy of OptimizedAllocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? request = null,
    Object? result = null,
    Object? allocationScore = null,
  }) {
    return _then(_OptimizedAllocation(
      request: null == request
          ? _self.request
          : request // ignore: cast_nullable_to_non_nullable
              as ReservationRequest,
      result: null == result
          ? _self.result
          : result // ignore: cast_nullable_to_non_nullable
              as ReservationResult,
      allocationScore: null == allocationScore
          ? _self.allocationScore
          : allocationScore // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }

  /// Create a copy of OptimizedAllocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReservationRequestCopyWith<$Res> get request {
    return $ReservationRequestCopyWith<$Res>(_self.request, (value) {
      return _then(_self.copyWith(request: value));
    });
  }

  /// Create a copy of OptimizedAllocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReservationResultCopyWith<$Res> get result {
    return $ReservationResultCopyWith<$Res>(_self.result, (value) {
      return _then(_self.copyWith(result: value));
    });
  }
}

// dart format on
