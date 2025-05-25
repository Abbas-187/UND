// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mrp_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MrpRequirement {
  String get materialId;
  String get materialCode;
  String get materialName;
  DateTime get periodStart;
  DateTime get periodEnd;
  MrpRequirementType get requirementType;
  double get quantity;
  String get unit;
  double get grossRequirement;
  double get scheduledReceipt;
  double get projectedOnHand;
  double get netRequirement;
  double get plannedOrderReceipt;
  double get plannedOrderRelease;
  double get safetyStock;
  int get leadTimeDays;
  String? get supplierCode;
  String? get bomId;
  String? get parentMaterialId;
  Map<String, dynamic>? get additionalData;

  /// Create a copy of MrpRequirement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MrpRequirementCopyWith<MrpRequirement> get copyWith =>
      _$MrpRequirementCopyWithImpl<MrpRequirement>(
          this as MrpRequirement, _$identity);

  /// Serializes this MrpRequirement to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MrpRequirement &&
            (identical(other.materialId, materialId) ||
                other.materialId == materialId) &&
            (identical(other.materialCode, materialCode) ||
                other.materialCode == materialCode) &&
            (identical(other.materialName, materialName) ||
                other.materialName == materialName) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd) &&
            (identical(other.requirementType, requirementType) ||
                other.requirementType == requirementType) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.grossRequirement, grossRequirement) ||
                other.grossRequirement == grossRequirement) &&
            (identical(other.scheduledReceipt, scheduledReceipt) ||
                other.scheduledReceipt == scheduledReceipt) &&
            (identical(other.projectedOnHand, projectedOnHand) ||
                other.projectedOnHand == projectedOnHand) &&
            (identical(other.netRequirement, netRequirement) ||
                other.netRequirement == netRequirement) &&
            (identical(other.plannedOrderReceipt, plannedOrderReceipt) ||
                other.plannedOrderReceipt == plannedOrderReceipt) &&
            (identical(other.plannedOrderRelease, plannedOrderRelease) ||
                other.plannedOrderRelease == plannedOrderRelease) &&
            (identical(other.safetyStock, safetyStock) ||
                other.safetyStock == safetyStock) &&
            (identical(other.leadTimeDays, leadTimeDays) ||
                other.leadTimeDays == leadTimeDays) &&
            (identical(other.supplierCode, supplierCode) ||
                other.supplierCode == supplierCode) &&
            (identical(other.bomId, bomId) || other.bomId == bomId) &&
            (identical(other.parentMaterialId, parentMaterialId) ||
                other.parentMaterialId == parentMaterialId) &&
            const DeepCollectionEquality()
                .equals(other.additionalData, additionalData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        materialId,
        materialCode,
        materialName,
        periodStart,
        periodEnd,
        requirementType,
        quantity,
        unit,
        grossRequirement,
        scheduledReceipt,
        projectedOnHand,
        netRequirement,
        plannedOrderReceipt,
        plannedOrderRelease,
        safetyStock,
        leadTimeDays,
        supplierCode,
        bomId,
        parentMaterialId,
        const DeepCollectionEquality().hash(additionalData)
      ]);

  @override
  String toString() {
    return 'MrpRequirement(materialId: $materialId, materialCode: $materialCode, materialName: $materialName, periodStart: $periodStart, periodEnd: $periodEnd, requirementType: $requirementType, quantity: $quantity, unit: $unit, grossRequirement: $grossRequirement, scheduledReceipt: $scheduledReceipt, projectedOnHand: $projectedOnHand, netRequirement: $netRequirement, plannedOrderReceipt: $plannedOrderReceipt, plannedOrderRelease: $plannedOrderRelease, safetyStock: $safetyStock, leadTimeDays: $leadTimeDays, supplierCode: $supplierCode, bomId: $bomId, parentMaterialId: $parentMaterialId, additionalData: $additionalData)';
  }
}

/// @nodoc
abstract mixin class $MrpRequirementCopyWith<$Res> {
  factory $MrpRequirementCopyWith(
          MrpRequirement value, $Res Function(MrpRequirement) _then) =
      _$MrpRequirementCopyWithImpl;
  @useResult
  $Res call(
      {String materialId,
      String materialCode,
      String materialName,
      DateTime periodStart,
      DateTime periodEnd,
      MrpRequirementType requirementType,
      double quantity,
      String unit,
      double grossRequirement,
      double scheduledReceipt,
      double projectedOnHand,
      double netRequirement,
      double plannedOrderReceipt,
      double plannedOrderRelease,
      double safetyStock,
      int leadTimeDays,
      String? supplierCode,
      String? bomId,
      String? parentMaterialId,
      Map<String, dynamic>? additionalData});
}

/// @nodoc
class _$MrpRequirementCopyWithImpl<$Res>
    implements $MrpRequirementCopyWith<$Res> {
  _$MrpRequirementCopyWithImpl(this._self, this._then);

  final MrpRequirement _self;
  final $Res Function(MrpRequirement) _then;

  /// Create a copy of MrpRequirement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? materialId = null,
    Object? materialCode = null,
    Object? materialName = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? requirementType = null,
    Object? quantity = null,
    Object? unit = null,
    Object? grossRequirement = null,
    Object? scheduledReceipt = null,
    Object? projectedOnHand = null,
    Object? netRequirement = null,
    Object? plannedOrderReceipt = null,
    Object? plannedOrderRelease = null,
    Object? safetyStock = null,
    Object? leadTimeDays = null,
    Object? supplierCode = freezed,
    Object? bomId = freezed,
    Object? parentMaterialId = freezed,
    Object? additionalData = freezed,
  }) {
    return _then(_self.copyWith(
      materialId: null == materialId
          ? _self.materialId
          : materialId // ignore: cast_nullable_to_non_nullable
              as String,
      materialCode: null == materialCode
          ? _self.materialCode
          : materialCode // ignore: cast_nullable_to_non_nullable
              as String,
      materialName: null == materialName
          ? _self.materialName
          : materialName // ignore: cast_nullable_to_non_nullable
              as String,
      periodStart: null == periodStart
          ? _self.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      periodEnd: null == periodEnd
          ? _self.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime,
      requirementType: null == requirementType
          ? _self.requirementType
          : requirementType // ignore: cast_nullable_to_non_nullable
              as MrpRequirementType,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _self.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      grossRequirement: null == grossRequirement
          ? _self.grossRequirement
          : grossRequirement // ignore: cast_nullable_to_non_nullable
              as double,
      scheduledReceipt: null == scheduledReceipt
          ? _self.scheduledReceipt
          : scheduledReceipt // ignore: cast_nullable_to_non_nullable
              as double,
      projectedOnHand: null == projectedOnHand
          ? _self.projectedOnHand
          : projectedOnHand // ignore: cast_nullable_to_non_nullable
              as double,
      netRequirement: null == netRequirement
          ? _self.netRequirement
          : netRequirement // ignore: cast_nullable_to_non_nullable
              as double,
      plannedOrderReceipt: null == plannedOrderReceipt
          ? _self.plannedOrderReceipt
          : plannedOrderReceipt // ignore: cast_nullable_to_non_nullable
              as double,
      plannedOrderRelease: null == plannedOrderRelease
          ? _self.plannedOrderRelease
          : plannedOrderRelease // ignore: cast_nullable_to_non_nullable
              as double,
      safetyStock: null == safetyStock
          ? _self.safetyStock
          : safetyStock // ignore: cast_nullable_to_non_nullable
              as double,
      leadTimeDays: null == leadTimeDays
          ? _self.leadTimeDays
          : leadTimeDays // ignore: cast_nullable_to_non_nullable
              as int,
      supplierCode: freezed == supplierCode
          ? _self.supplierCode
          : supplierCode // ignore: cast_nullable_to_non_nullable
              as String?,
      bomId: freezed == bomId
          ? _self.bomId
          : bomId // ignore: cast_nullable_to_non_nullable
              as String?,
      parentMaterialId: freezed == parentMaterialId
          ? _self.parentMaterialId
          : parentMaterialId // ignore: cast_nullable_to_non_nullable
              as String?,
      additionalData: freezed == additionalData
          ? _self.additionalData
          : additionalData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _MrpRequirement extends MrpRequirement {
  const _MrpRequirement(
      {required this.materialId,
      required this.materialCode,
      required this.materialName,
      required this.periodStart,
      required this.periodEnd,
      required this.requirementType,
      required this.quantity,
      required this.unit,
      this.grossRequirement = 0.0,
      this.scheduledReceipt = 0.0,
      this.projectedOnHand = 0.0,
      this.netRequirement = 0.0,
      this.plannedOrderReceipt = 0.0,
      this.plannedOrderRelease = 0.0,
      this.safetyStock = 0.0,
      this.leadTimeDays = 0,
      this.supplierCode,
      this.bomId,
      this.parentMaterialId,
      final Map<String, dynamic>? additionalData})
      : _additionalData = additionalData,
        super._();
  factory _MrpRequirement.fromJson(Map<String, dynamic> json) =>
      _$MrpRequirementFromJson(json);

  @override
  final String materialId;
  @override
  final String materialCode;
  @override
  final String materialName;
  @override
  final DateTime periodStart;
  @override
  final DateTime periodEnd;
  @override
  final MrpRequirementType requirementType;
  @override
  final double quantity;
  @override
  final String unit;
  @override
  @JsonKey()
  final double grossRequirement;
  @override
  @JsonKey()
  final double scheduledReceipt;
  @override
  @JsonKey()
  final double projectedOnHand;
  @override
  @JsonKey()
  final double netRequirement;
  @override
  @JsonKey()
  final double plannedOrderReceipt;
  @override
  @JsonKey()
  final double plannedOrderRelease;
  @override
  @JsonKey()
  final double safetyStock;
  @override
  @JsonKey()
  final int leadTimeDays;
  @override
  final String? supplierCode;
  @override
  final String? bomId;
  @override
  final String? parentMaterialId;
  final Map<String, dynamic>? _additionalData;
  @override
  Map<String, dynamic>? get additionalData {
    final value = _additionalData;
    if (value == null) return null;
    if (_additionalData is EqualUnmodifiableMapView) return _additionalData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of MrpRequirement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MrpRequirementCopyWith<_MrpRequirement> get copyWith =>
      __$MrpRequirementCopyWithImpl<_MrpRequirement>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MrpRequirementToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MrpRequirement &&
            (identical(other.materialId, materialId) ||
                other.materialId == materialId) &&
            (identical(other.materialCode, materialCode) ||
                other.materialCode == materialCode) &&
            (identical(other.materialName, materialName) ||
                other.materialName == materialName) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd) &&
            (identical(other.requirementType, requirementType) ||
                other.requirementType == requirementType) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.grossRequirement, grossRequirement) ||
                other.grossRequirement == grossRequirement) &&
            (identical(other.scheduledReceipt, scheduledReceipt) ||
                other.scheduledReceipt == scheduledReceipt) &&
            (identical(other.projectedOnHand, projectedOnHand) ||
                other.projectedOnHand == projectedOnHand) &&
            (identical(other.netRequirement, netRequirement) ||
                other.netRequirement == netRequirement) &&
            (identical(other.plannedOrderReceipt, plannedOrderReceipt) ||
                other.plannedOrderReceipt == plannedOrderReceipt) &&
            (identical(other.plannedOrderRelease, plannedOrderRelease) ||
                other.plannedOrderRelease == plannedOrderRelease) &&
            (identical(other.safetyStock, safetyStock) ||
                other.safetyStock == safetyStock) &&
            (identical(other.leadTimeDays, leadTimeDays) ||
                other.leadTimeDays == leadTimeDays) &&
            (identical(other.supplierCode, supplierCode) ||
                other.supplierCode == supplierCode) &&
            (identical(other.bomId, bomId) || other.bomId == bomId) &&
            (identical(other.parentMaterialId, parentMaterialId) ||
                other.parentMaterialId == parentMaterialId) &&
            const DeepCollectionEquality()
                .equals(other._additionalData, _additionalData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        materialId,
        materialCode,
        materialName,
        periodStart,
        periodEnd,
        requirementType,
        quantity,
        unit,
        grossRequirement,
        scheduledReceipt,
        projectedOnHand,
        netRequirement,
        plannedOrderReceipt,
        plannedOrderRelease,
        safetyStock,
        leadTimeDays,
        supplierCode,
        bomId,
        parentMaterialId,
        const DeepCollectionEquality().hash(_additionalData)
      ]);

  @override
  String toString() {
    return 'MrpRequirement(materialId: $materialId, materialCode: $materialCode, materialName: $materialName, periodStart: $periodStart, periodEnd: $periodEnd, requirementType: $requirementType, quantity: $quantity, unit: $unit, grossRequirement: $grossRequirement, scheduledReceipt: $scheduledReceipt, projectedOnHand: $projectedOnHand, netRequirement: $netRequirement, plannedOrderReceipt: $plannedOrderReceipt, plannedOrderRelease: $plannedOrderRelease, safetyStock: $safetyStock, leadTimeDays: $leadTimeDays, supplierCode: $supplierCode, bomId: $bomId, parentMaterialId: $parentMaterialId, additionalData: $additionalData)';
  }
}

/// @nodoc
abstract mixin class _$MrpRequirementCopyWith<$Res>
    implements $MrpRequirementCopyWith<$Res> {
  factory _$MrpRequirementCopyWith(
          _MrpRequirement value, $Res Function(_MrpRequirement) _then) =
      __$MrpRequirementCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String materialId,
      String materialCode,
      String materialName,
      DateTime periodStart,
      DateTime periodEnd,
      MrpRequirementType requirementType,
      double quantity,
      String unit,
      double grossRequirement,
      double scheduledReceipt,
      double projectedOnHand,
      double netRequirement,
      double plannedOrderReceipt,
      double plannedOrderRelease,
      double safetyStock,
      int leadTimeDays,
      String? supplierCode,
      String? bomId,
      String? parentMaterialId,
      Map<String, dynamic>? additionalData});
}

/// @nodoc
class __$MrpRequirementCopyWithImpl<$Res>
    implements _$MrpRequirementCopyWith<$Res> {
  __$MrpRequirementCopyWithImpl(this._self, this._then);

  final _MrpRequirement _self;
  final $Res Function(_MrpRequirement) _then;

  /// Create a copy of MrpRequirement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? materialId = null,
    Object? materialCode = null,
    Object? materialName = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? requirementType = null,
    Object? quantity = null,
    Object? unit = null,
    Object? grossRequirement = null,
    Object? scheduledReceipt = null,
    Object? projectedOnHand = null,
    Object? netRequirement = null,
    Object? plannedOrderReceipt = null,
    Object? plannedOrderRelease = null,
    Object? safetyStock = null,
    Object? leadTimeDays = null,
    Object? supplierCode = freezed,
    Object? bomId = freezed,
    Object? parentMaterialId = freezed,
    Object? additionalData = freezed,
  }) {
    return _then(_MrpRequirement(
      materialId: null == materialId
          ? _self.materialId
          : materialId // ignore: cast_nullable_to_non_nullable
              as String,
      materialCode: null == materialCode
          ? _self.materialCode
          : materialCode // ignore: cast_nullable_to_non_nullable
              as String,
      materialName: null == materialName
          ? _self.materialName
          : materialName // ignore: cast_nullable_to_non_nullable
              as String,
      periodStart: null == periodStart
          ? _self.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      periodEnd: null == periodEnd
          ? _self.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime,
      requirementType: null == requirementType
          ? _self.requirementType
          : requirementType // ignore: cast_nullable_to_non_nullable
              as MrpRequirementType,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _self.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      grossRequirement: null == grossRequirement
          ? _self.grossRequirement
          : grossRequirement // ignore: cast_nullable_to_non_nullable
              as double,
      scheduledReceipt: null == scheduledReceipt
          ? _self.scheduledReceipt
          : scheduledReceipt // ignore: cast_nullable_to_non_nullable
              as double,
      projectedOnHand: null == projectedOnHand
          ? _self.projectedOnHand
          : projectedOnHand // ignore: cast_nullable_to_non_nullable
              as double,
      netRequirement: null == netRequirement
          ? _self.netRequirement
          : netRequirement // ignore: cast_nullable_to_non_nullable
              as double,
      plannedOrderReceipt: null == plannedOrderReceipt
          ? _self.plannedOrderReceipt
          : plannedOrderReceipt // ignore: cast_nullable_to_non_nullable
              as double,
      plannedOrderRelease: null == plannedOrderRelease
          ? _self.plannedOrderRelease
          : plannedOrderRelease // ignore: cast_nullable_to_non_nullable
              as double,
      safetyStock: null == safetyStock
          ? _self.safetyStock
          : safetyStock // ignore: cast_nullable_to_non_nullable
              as double,
      leadTimeDays: null == leadTimeDays
          ? _self.leadTimeDays
          : leadTimeDays // ignore: cast_nullable_to_non_nullable
              as int,
      supplierCode: freezed == supplierCode
          ? _self.supplierCode
          : supplierCode // ignore: cast_nullable_to_non_nullable
              as String?,
      bomId: freezed == bomId
          ? _self.bomId
          : bomId // ignore: cast_nullable_to_non_nullable
              as String?,
      parentMaterialId: freezed == parentMaterialId
          ? _self.parentMaterialId
          : parentMaterialId // ignore: cast_nullable_to_non_nullable
              as String?,
      additionalData: freezed == additionalData
          ? _self._additionalData
          : additionalData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
mixin _$MrpActionMessage {
  String get id;
  String get materialId;
  String get materialCode;
  MrpActionType get actionType;
  String get message;
  DateTime get currentDate;
  DateTime get recommendedDate;
  double get quantity;
  String get unit;
  String get priority;
  String? get orderId;
  String? get supplierCode;
  Map<String, dynamic>? get actionData;
  DateTime get createdAt;

  /// Create a copy of MrpActionMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MrpActionMessageCopyWith<MrpActionMessage> get copyWith =>
      _$MrpActionMessageCopyWithImpl<MrpActionMessage>(
          this as MrpActionMessage, _$identity);

  /// Serializes this MrpActionMessage to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MrpActionMessage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.materialId, materialId) ||
                other.materialId == materialId) &&
            (identical(other.materialCode, materialCode) ||
                other.materialCode == materialCode) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.currentDate, currentDate) ||
                other.currentDate == currentDate) &&
            (identical(other.recommendedDate, recommendedDate) ||
                other.recommendedDate == recommendedDate) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.supplierCode, supplierCode) ||
                other.supplierCode == supplierCode) &&
            const DeepCollectionEquality()
                .equals(other.actionData, actionData) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      materialId,
      materialCode,
      actionType,
      message,
      currentDate,
      recommendedDate,
      quantity,
      unit,
      priority,
      orderId,
      supplierCode,
      const DeepCollectionEquality().hash(actionData),
      createdAt);

  @override
  String toString() {
    return 'MrpActionMessage(id: $id, materialId: $materialId, materialCode: $materialCode, actionType: $actionType, message: $message, currentDate: $currentDate, recommendedDate: $recommendedDate, quantity: $quantity, unit: $unit, priority: $priority, orderId: $orderId, supplierCode: $supplierCode, actionData: $actionData, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $MrpActionMessageCopyWith<$Res> {
  factory $MrpActionMessageCopyWith(
          MrpActionMessage value, $Res Function(MrpActionMessage) _then) =
      _$MrpActionMessageCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String materialId,
      String materialCode,
      MrpActionType actionType,
      String message,
      DateTime currentDate,
      DateTime recommendedDate,
      double quantity,
      String unit,
      String priority,
      String? orderId,
      String? supplierCode,
      Map<String, dynamic>? actionData,
      DateTime createdAt});
}

/// @nodoc
class _$MrpActionMessageCopyWithImpl<$Res>
    implements $MrpActionMessageCopyWith<$Res> {
  _$MrpActionMessageCopyWithImpl(this._self, this._then);

  final MrpActionMessage _self;
  final $Res Function(MrpActionMessage) _then;

  /// Create a copy of MrpActionMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? materialId = null,
    Object? materialCode = null,
    Object? actionType = null,
    Object? message = null,
    Object? currentDate = null,
    Object? recommendedDate = null,
    Object? quantity = null,
    Object? unit = null,
    Object? priority = null,
    Object? orderId = freezed,
    Object? supplierCode = freezed,
    Object? actionData = freezed,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      materialId: null == materialId
          ? _self.materialId
          : materialId // ignore: cast_nullable_to_non_nullable
              as String,
      materialCode: null == materialCode
          ? _self.materialCode
          : materialCode // ignore: cast_nullable_to_non_nullable
              as String,
      actionType: null == actionType
          ? _self.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as MrpActionType,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      currentDate: null == currentDate
          ? _self.currentDate
          : currentDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      recommendedDate: null == recommendedDate
          ? _self.recommendedDate
          : recommendedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _self.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: freezed == orderId
          ? _self.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierCode: freezed == supplierCode
          ? _self.supplierCode
          : supplierCode // ignore: cast_nullable_to_non_nullable
              as String?,
      actionData: freezed == actionData
          ? _self.actionData
          : actionData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _MrpActionMessage implements MrpActionMessage {
  const _MrpActionMessage(
      {required this.id,
      required this.materialId,
      required this.materialCode,
      required this.actionType,
      required this.message,
      required this.currentDate,
      required this.recommendedDate,
      required this.quantity,
      required this.unit,
      this.priority = 'medium',
      this.orderId,
      this.supplierCode,
      final Map<String, dynamic>? actionData,
      required this.createdAt})
      : _actionData = actionData;
  factory _MrpActionMessage.fromJson(Map<String, dynamic> json) =>
      _$MrpActionMessageFromJson(json);

  @override
  final String id;
  @override
  final String materialId;
  @override
  final String materialCode;
  @override
  final MrpActionType actionType;
  @override
  final String message;
  @override
  final DateTime currentDate;
  @override
  final DateTime recommendedDate;
  @override
  final double quantity;
  @override
  final String unit;
  @override
  @JsonKey()
  final String priority;
  @override
  final String? orderId;
  @override
  final String? supplierCode;
  final Map<String, dynamic>? _actionData;
  @override
  Map<String, dynamic>? get actionData {
    final value = _actionData;
    if (value == null) return null;
    if (_actionData is EqualUnmodifiableMapView) return _actionData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime createdAt;

  /// Create a copy of MrpActionMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MrpActionMessageCopyWith<_MrpActionMessage> get copyWith =>
      __$MrpActionMessageCopyWithImpl<_MrpActionMessage>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MrpActionMessageToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MrpActionMessage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.materialId, materialId) ||
                other.materialId == materialId) &&
            (identical(other.materialCode, materialCode) ||
                other.materialCode == materialCode) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.currentDate, currentDate) ||
                other.currentDate == currentDate) &&
            (identical(other.recommendedDate, recommendedDate) ||
                other.recommendedDate == recommendedDate) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.supplierCode, supplierCode) ||
                other.supplierCode == supplierCode) &&
            const DeepCollectionEquality()
                .equals(other._actionData, _actionData) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      materialId,
      materialCode,
      actionType,
      message,
      currentDate,
      recommendedDate,
      quantity,
      unit,
      priority,
      orderId,
      supplierCode,
      const DeepCollectionEquality().hash(_actionData),
      createdAt);

  @override
  String toString() {
    return 'MrpActionMessage(id: $id, materialId: $materialId, materialCode: $materialCode, actionType: $actionType, message: $message, currentDate: $currentDate, recommendedDate: $recommendedDate, quantity: $quantity, unit: $unit, priority: $priority, orderId: $orderId, supplierCode: $supplierCode, actionData: $actionData, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$MrpActionMessageCopyWith<$Res>
    implements $MrpActionMessageCopyWith<$Res> {
  factory _$MrpActionMessageCopyWith(
          _MrpActionMessage value, $Res Function(_MrpActionMessage) _then) =
      __$MrpActionMessageCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String materialId,
      String materialCode,
      MrpActionType actionType,
      String message,
      DateTime currentDate,
      DateTime recommendedDate,
      double quantity,
      String unit,
      String priority,
      String? orderId,
      String? supplierCode,
      Map<String, dynamic>? actionData,
      DateTime createdAt});
}

/// @nodoc
class __$MrpActionMessageCopyWithImpl<$Res>
    implements _$MrpActionMessageCopyWith<$Res> {
  __$MrpActionMessageCopyWithImpl(this._self, this._then);

  final _MrpActionMessage _self;
  final $Res Function(_MrpActionMessage) _then;

  /// Create a copy of MrpActionMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? materialId = null,
    Object? materialCode = null,
    Object? actionType = null,
    Object? message = null,
    Object? currentDate = null,
    Object? recommendedDate = null,
    Object? quantity = null,
    Object? unit = null,
    Object? priority = null,
    Object? orderId = freezed,
    Object? supplierCode = freezed,
    Object? actionData = freezed,
    Object? createdAt = null,
  }) {
    return _then(_MrpActionMessage(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      materialId: null == materialId
          ? _self.materialId
          : materialId // ignore: cast_nullable_to_non_nullable
              as String,
      materialCode: null == materialCode
          ? _self.materialCode
          : materialCode // ignore: cast_nullable_to_non_nullable
              as String,
      actionType: null == actionType
          ? _self.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as MrpActionType,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      currentDate: null == currentDate
          ? _self.currentDate
          : currentDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      recommendedDate: null == recommendedDate
          ? _self.recommendedDate
          : recommendedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _self.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: freezed == orderId
          ? _self.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierCode: freezed == supplierCode
          ? _self.supplierCode
          : supplierCode // ignore: cast_nullable_to_non_nullable
              as String?,
      actionData: freezed == actionData
          ? _self._actionData
          : actionData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
mixin _$MrpRecommendations {
  String get planId;
  List<MrpActionMessage> get actionMessages;
  List<String> get criticalMaterials;
  Map<String, double> get costOptimizations;
  Map<String, int> get leadTimeImprovements;
  List<String> get supplierRecommendations;
  double get totalCostSavings;
  double get inventoryReduction;
  DateTime get generatedAt;
  Map<String, dynamic>? get optimizationMetrics;

  /// Create a copy of MrpRecommendations
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MrpRecommendationsCopyWith<MrpRecommendations> get copyWith =>
      _$MrpRecommendationsCopyWithImpl<MrpRecommendations>(
          this as MrpRecommendations, _$identity);

  /// Serializes this MrpRecommendations to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MrpRecommendations &&
            (identical(other.planId, planId) || other.planId == planId) &&
            const DeepCollectionEquality()
                .equals(other.actionMessages, actionMessages) &&
            const DeepCollectionEquality()
                .equals(other.criticalMaterials, criticalMaterials) &&
            const DeepCollectionEquality()
                .equals(other.costOptimizations, costOptimizations) &&
            const DeepCollectionEquality()
                .equals(other.leadTimeImprovements, leadTimeImprovements) &&
            const DeepCollectionEquality().equals(
                other.supplierRecommendations, supplierRecommendations) &&
            (identical(other.totalCostSavings, totalCostSavings) ||
                other.totalCostSavings == totalCostSavings) &&
            (identical(other.inventoryReduction, inventoryReduction) ||
                other.inventoryReduction == inventoryReduction) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt) &&
            const DeepCollectionEquality()
                .equals(other.optimizationMetrics, optimizationMetrics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      planId,
      const DeepCollectionEquality().hash(actionMessages),
      const DeepCollectionEquality().hash(criticalMaterials),
      const DeepCollectionEquality().hash(costOptimizations),
      const DeepCollectionEquality().hash(leadTimeImprovements),
      const DeepCollectionEquality().hash(supplierRecommendations),
      totalCostSavings,
      inventoryReduction,
      generatedAt,
      const DeepCollectionEquality().hash(optimizationMetrics));

  @override
  String toString() {
    return 'MrpRecommendations(planId: $planId, actionMessages: $actionMessages, criticalMaterials: $criticalMaterials, costOptimizations: $costOptimizations, leadTimeImprovements: $leadTimeImprovements, supplierRecommendations: $supplierRecommendations, totalCostSavings: $totalCostSavings, inventoryReduction: $inventoryReduction, generatedAt: $generatedAt, optimizationMetrics: $optimizationMetrics)';
  }
}

/// @nodoc
abstract mixin class $MrpRecommendationsCopyWith<$Res> {
  factory $MrpRecommendationsCopyWith(
          MrpRecommendations value, $Res Function(MrpRecommendations) _then) =
      _$MrpRecommendationsCopyWithImpl;
  @useResult
  $Res call(
      {String planId,
      List<MrpActionMessage> actionMessages,
      List<String> criticalMaterials,
      Map<String, double> costOptimizations,
      Map<String, int> leadTimeImprovements,
      List<String> supplierRecommendations,
      double totalCostSavings,
      double inventoryReduction,
      DateTime generatedAt,
      Map<String, dynamic>? optimizationMetrics});
}

/// @nodoc
class _$MrpRecommendationsCopyWithImpl<$Res>
    implements $MrpRecommendationsCopyWith<$Res> {
  _$MrpRecommendationsCopyWithImpl(this._self, this._then);

  final MrpRecommendations _self;
  final $Res Function(MrpRecommendations) _then;

  /// Create a copy of MrpRecommendations
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? planId = null,
    Object? actionMessages = null,
    Object? criticalMaterials = null,
    Object? costOptimizations = null,
    Object? leadTimeImprovements = null,
    Object? supplierRecommendations = null,
    Object? totalCostSavings = null,
    Object? inventoryReduction = null,
    Object? generatedAt = null,
    Object? optimizationMetrics = freezed,
  }) {
    return _then(_self.copyWith(
      planId: null == planId
          ? _self.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      actionMessages: null == actionMessages
          ? _self.actionMessages
          : actionMessages // ignore: cast_nullable_to_non_nullable
              as List<MrpActionMessage>,
      criticalMaterials: null == criticalMaterials
          ? _self.criticalMaterials
          : criticalMaterials // ignore: cast_nullable_to_non_nullable
              as List<String>,
      costOptimizations: null == costOptimizations
          ? _self.costOptimizations
          : costOptimizations // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      leadTimeImprovements: null == leadTimeImprovements
          ? _self.leadTimeImprovements
          : leadTimeImprovements // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      supplierRecommendations: null == supplierRecommendations
          ? _self.supplierRecommendations
          : supplierRecommendations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      totalCostSavings: null == totalCostSavings
          ? _self.totalCostSavings
          : totalCostSavings // ignore: cast_nullable_to_non_nullable
              as double,
      inventoryReduction: null == inventoryReduction
          ? _self.inventoryReduction
          : inventoryReduction // ignore: cast_nullable_to_non_nullable
              as double,
      generatedAt: null == generatedAt
          ? _self.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      optimizationMetrics: freezed == optimizationMetrics
          ? _self.optimizationMetrics
          : optimizationMetrics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _MrpRecommendations implements MrpRecommendations {
  const _MrpRecommendations(
      {required this.planId,
      required final List<MrpActionMessage> actionMessages,
      required final List<String> criticalMaterials,
      required final Map<String, double> costOptimizations,
      required final Map<String, int> leadTimeImprovements,
      final List<String> supplierRecommendations = const [],
      this.totalCostSavings = 0.0,
      this.inventoryReduction = 0.0,
      required this.generatedAt,
      final Map<String, dynamic>? optimizationMetrics})
      : _actionMessages = actionMessages,
        _criticalMaterials = criticalMaterials,
        _costOptimizations = costOptimizations,
        _leadTimeImprovements = leadTimeImprovements,
        _supplierRecommendations = supplierRecommendations,
        _optimizationMetrics = optimizationMetrics;
  factory _MrpRecommendations.fromJson(Map<String, dynamic> json) =>
      _$MrpRecommendationsFromJson(json);

  @override
  final String planId;
  final List<MrpActionMessage> _actionMessages;
  @override
  List<MrpActionMessage> get actionMessages {
    if (_actionMessages is EqualUnmodifiableListView) return _actionMessages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actionMessages);
  }

  final List<String> _criticalMaterials;
  @override
  List<String> get criticalMaterials {
    if (_criticalMaterials is EqualUnmodifiableListView)
      return _criticalMaterials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_criticalMaterials);
  }

  final Map<String, double> _costOptimizations;
  @override
  Map<String, double> get costOptimizations {
    if (_costOptimizations is EqualUnmodifiableMapView)
      return _costOptimizations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_costOptimizations);
  }

  final Map<String, int> _leadTimeImprovements;
  @override
  Map<String, int> get leadTimeImprovements {
    if (_leadTimeImprovements is EqualUnmodifiableMapView)
      return _leadTimeImprovements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_leadTimeImprovements);
  }

  final List<String> _supplierRecommendations;
  @override
  @JsonKey()
  List<String> get supplierRecommendations {
    if (_supplierRecommendations is EqualUnmodifiableListView)
      return _supplierRecommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_supplierRecommendations);
  }

  @override
  @JsonKey()
  final double totalCostSavings;
  @override
  @JsonKey()
  final double inventoryReduction;
  @override
  final DateTime generatedAt;
  final Map<String, dynamic>? _optimizationMetrics;
  @override
  Map<String, dynamic>? get optimizationMetrics {
    final value = _optimizationMetrics;
    if (value == null) return null;
    if (_optimizationMetrics is EqualUnmodifiableMapView)
      return _optimizationMetrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of MrpRecommendations
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MrpRecommendationsCopyWith<_MrpRecommendations> get copyWith =>
      __$MrpRecommendationsCopyWithImpl<_MrpRecommendations>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MrpRecommendationsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MrpRecommendations &&
            (identical(other.planId, planId) || other.planId == planId) &&
            const DeepCollectionEquality()
                .equals(other._actionMessages, _actionMessages) &&
            const DeepCollectionEquality()
                .equals(other._criticalMaterials, _criticalMaterials) &&
            const DeepCollectionEquality()
                .equals(other._costOptimizations, _costOptimizations) &&
            const DeepCollectionEquality()
                .equals(other._leadTimeImprovements, _leadTimeImprovements) &&
            const DeepCollectionEquality().equals(
                other._supplierRecommendations, _supplierRecommendations) &&
            (identical(other.totalCostSavings, totalCostSavings) ||
                other.totalCostSavings == totalCostSavings) &&
            (identical(other.inventoryReduction, inventoryReduction) ||
                other.inventoryReduction == inventoryReduction) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt) &&
            const DeepCollectionEquality()
                .equals(other._optimizationMetrics, _optimizationMetrics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      planId,
      const DeepCollectionEquality().hash(_actionMessages),
      const DeepCollectionEquality().hash(_criticalMaterials),
      const DeepCollectionEquality().hash(_costOptimizations),
      const DeepCollectionEquality().hash(_leadTimeImprovements),
      const DeepCollectionEquality().hash(_supplierRecommendations),
      totalCostSavings,
      inventoryReduction,
      generatedAt,
      const DeepCollectionEquality().hash(_optimizationMetrics));

  @override
  String toString() {
    return 'MrpRecommendations(planId: $planId, actionMessages: $actionMessages, criticalMaterials: $criticalMaterials, costOptimizations: $costOptimizations, leadTimeImprovements: $leadTimeImprovements, supplierRecommendations: $supplierRecommendations, totalCostSavings: $totalCostSavings, inventoryReduction: $inventoryReduction, generatedAt: $generatedAt, optimizationMetrics: $optimizationMetrics)';
  }
}

/// @nodoc
abstract mixin class _$MrpRecommendationsCopyWith<$Res>
    implements $MrpRecommendationsCopyWith<$Res> {
  factory _$MrpRecommendationsCopyWith(
          _MrpRecommendations value, $Res Function(_MrpRecommendations) _then) =
      __$MrpRecommendationsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String planId,
      List<MrpActionMessage> actionMessages,
      List<String> criticalMaterials,
      Map<String, double> costOptimizations,
      Map<String, int> leadTimeImprovements,
      List<String> supplierRecommendations,
      double totalCostSavings,
      double inventoryReduction,
      DateTime generatedAt,
      Map<String, dynamic>? optimizationMetrics});
}

/// @nodoc
class __$MrpRecommendationsCopyWithImpl<$Res>
    implements _$MrpRecommendationsCopyWith<$Res> {
  __$MrpRecommendationsCopyWithImpl(this._self, this._then);

  final _MrpRecommendations _self;
  final $Res Function(_MrpRecommendations) _then;

  /// Create a copy of MrpRecommendations
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? planId = null,
    Object? actionMessages = null,
    Object? criticalMaterials = null,
    Object? costOptimizations = null,
    Object? leadTimeImprovements = null,
    Object? supplierRecommendations = null,
    Object? totalCostSavings = null,
    Object? inventoryReduction = null,
    Object? generatedAt = null,
    Object? optimizationMetrics = freezed,
  }) {
    return _then(_MrpRecommendations(
      planId: null == planId
          ? _self.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      actionMessages: null == actionMessages
          ? _self._actionMessages
          : actionMessages // ignore: cast_nullable_to_non_nullable
              as List<MrpActionMessage>,
      criticalMaterials: null == criticalMaterials
          ? _self._criticalMaterials
          : criticalMaterials // ignore: cast_nullable_to_non_nullable
              as List<String>,
      costOptimizations: null == costOptimizations
          ? _self._costOptimizations
          : costOptimizations // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      leadTimeImprovements: null == leadTimeImprovements
          ? _self._leadTimeImprovements
          : leadTimeImprovements // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      supplierRecommendations: null == supplierRecommendations
          ? _self._supplierRecommendations
          : supplierRecommendations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      totalCostSavings: null == totalCostSavings
          ? _self.totalCostSavings
          : totalCostSavings // ignore: cast_nullable_to_non_nullable
              as double,
      inventoryReduction: null == inventoryReduction
          ? _self.inventoryReduction
          : inventoryReduction // ignore: cast_nullable_to_non_nullable
              as double,
      generatedAt: null == generatedAt
          ? _self.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      optimizationMetrics: freezed == optimizationMetrics
          ? _self._optimizationMetrics
          : optimizationMetrics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
mixin _$MrpAlert {
  String get id;
  String get planId;
  String get materialId;
  String get alertType;
  String get severity;
  String get message;
  DateTime get alertDate;
  double get impactQuantity;
  String? get recommendedAction;
  Map<String, dynamic>? get alertData;
  bool get isResolved;
  DateTime? get resolvedAt;
  String? get resolvedBy;

  /// Create a copy of MrpAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MrpAlertCopyWith<MrpAlert> get copyWith =>
      _$MrpAlertCopyWithImpl<MrpAlert>(this as MrpAlert, _$identity);

  /// Serializes this MrpAlert to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MrpAlert &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.materialId, materialId) ||
                other.materialId == materialId) &&
            (identical(other.alertType, alertType) ||
                other.alertType == alertType) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.alertDate, alertDate) ||
                other.alertDate == alertDate) &&
            (identical(other.impactQuantity, impactQuantity) ||
                other.impactQuantity == impactQuantity) &&
            (identical(other.recommendedAction, recommendedAction) ||
                other.recommendedAction == recommendedAction) &&
            const DeepCollectionEquality().equals(other.alertData, alertData) &&
            (identical(other.isResolved, isResolved) ||
                other.isResolved == isResolved) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      planId,
      materialId,
      alertType,
      severity,
      message,
      alertDate,
      impactQuantity,
      recommendedAction,
      const DeepCollectionEquality().hash(alertData),
      isResolved,
      resolvedAt,
      resolvedBy);

  @override
  String toString() {
    return 'MrpAlert(id: $id, planId: $planId, materialId: $materialId, alertType: $alertType, severity: $severity, message: $message, alertDate: $alertDate, impactQuantity: $impactQuantity, recommendedAction: $recommendedAction, alertData: $alertData, isResolved: $isResolved, resolvedAt: $resolvedAt, resolvedBy: $resolvedBy)';
  }
}

/// @nodoc
abstract mixin class $MrpAlertCopyWith<$Res> {
  factory $MrpAlertCopyWith(MrpAlert value, $Res Function(MrpAlert) _then) =
      _$MrpAlertCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String planId,
      String materialId,
      String alertType,
      String severity,
      String message,
      DateTime alertDate,
      double impactQuantity,
      String? recommendedAction,
      Map<String, dynamic>? alertData,
      bool isResolved,
      DateTime? resolvedAt,
      String? resolvedBy});
}

/// @nodoc
class _$MrpAlertCopyWithImpl<$Res> implements $MrpAlertCopyWith<$Res> {
  _$MrpAlertCopyWithImpl(this._self, this._then);

  final MrpAlert _self;
  final $Res Function(MrpAlert) _then;

  /// Create a copy of MrpAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? planId = null,
    Object? materialId = null,
    Object? alertType = null,
    Object? severity = null,
    Object? message = null,
    Object? alertDate = null,
    Object? impactQuantity = null,
    Object? recommendedAction = freezed,
    Object? alertData = freezed,
    Object? isResolved = null,
    Object? resolvedAt = freezed,
    Object? resolvedBy = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      planId: null == planId
          ? _self.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      materialId: null == materialId
          ? _self.materialId
          : materialId // ignore: cast_nullable_to_non_nullable
              as String,
      alertType: null == alertType
          ? _self.alertType
          : alertType // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _self.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      alertDate: null == alertDate
          ? _self.alertDate
          : alertDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      impactQuantity: null == impactQuantity
          ? _self.impactQuantity
          : impactQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      recommendedAction: freezed == recommendedAction
          ? _self.recommendedAction
          : recommendedAction // ignore: cast_nullable_to_non_nullable
              as String?,
      alertData: freezed == alertData
          ? _self.alertData
          : alertData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isResolved: null == isResolved
          ? _self.isResolved
          : isResolved // ignore: cast_nullable_to_non_nullable
              as bool,
      resolvedAt: freezed == resolvedAt
          ? _self.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedBy: freezed == resolvedBy
          ? _self.resolvedBy
          : resolvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _MrpAlert implements MrpAlert {
  const _MrpAlert(
      {required this.id,
      required this.planId,
      required this.materialId,
      required this.alertType,
      required this.severity,
      required this.message,
      required this.alertDate,
      required this.impactQuantity,
      this.recommendedAction,
      final Map<String, dynamic>? alertData,
      this.isResolved = false,
      this.resolvedAt,
      this.resolvedBy})
      : _alertData = alertData;
  factory _MrpAlert.fromJson(Map<String, dynamic> json) =>
      _$MrpAlertFromJson(json);

  @override
  final String id;
  @override
  final String planId;
  @override
  final String materialId;
  @override
  final String alertType;
  @override
  final String severity;
  @override
  final String message;
  @override
  final DateTime alertDate;
  @override
  final double impactQuantity;
  @override
  final String? recommendedAction;
  final Map<String, dynamic>? _alertData;
  @override
  Map<String, dynamic>? get alertData {
    final value = _alertData;
    if (value == null) return null;
    if (_alertData is EqualUnmodifiableMapView) return _alertData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final bool isResolved;
  @override
  final DateTime? resolvedAt;
  @override
  final String? resolvedBy;

  /// Create a copy of MrpAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MrpAlertCopyWith<_MrpAlert> get copyWith =>
      __$MrpAlertCopyWithImpl<_MrpAlert>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MrpAlertToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MrpAlert &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.materialId, materialId) ||
                other.materialId == materialId) &&
            (identical(other.alertType, alertType) ||
                other.alertType == alertType) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.alertDate, alertDate) ||
                other.alertDate == alertDate) &&
            (identical(other.impactQuantity, impactQuantity) ||
                other.impactQuantity == impactQuantity) &&
            (identical(other.recommendedAction, recommendedAction) ||
                other.recommendedAction == recommendedAction) &&
            const DeepCollectionEquality()
                .equals(other._alertData, _alertData) &&
            (identical(other.isResolved, isResolved) ||
                other.isResolved == isResolved) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      planId,
      materialId,
      alertType,
      severity,
      message,
      alertDate,
      impactQuantity,
      recommendedAction,
      const DeepCollectionEquality().hash(_alertData),
      isResolved,
      resolvedAt,
      resolvedBy);

  @override
  String toString() {
    return 'MrpAlert(id: $id, planId: $planId, materialId: $materialId, alertType: $alertType, severity: $severity, message: $message, alertDate: $alertDate, impactQuantity: $impactQuantity, recommendedAction: $recommendedAction, alertData: $alertData, isResolved: $isResolved, resolvedAt: $resolvedAt, resolvedBy: $resolvedBy)';
  }
}

/// @nodoc
abstract mixin class _$MrpAlertCopyWith<$Res>
    implements $MrpAlertCopyWith<$Res> {
  factory _$MrpAlertCopyWith(_MrpAlert value, $Res Function(_MrpAlert) _then) =
      __$MrpAlertCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String planId,
      String materialId,
      String alertType,
      String severity,
      String message,
      DateTime alertDate,
      double impactQuantity,
      String? recommendedAction,
      Map<String, dynamic>? alertData,
      bool isResolved,
      DateTime? resolvedAt,
      String? resolvedBy});
}

/// @nodoc
class __$MrpAlertCopyWithImpl<$Res> implements _$MrpAlertCopyWith<$Res> {
  __$MrpAlertCopyWithImpl(this._self, this._then);

  final _MrpAlert _self;
  final $Res Function(_MrpAlert) _then;

  /// Create a copy of MrpAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? planId = null,
    Object? materialId = null,
    Object? alertType = null,
    Object? severity = null,
    Object? message = null,
    Object? alertDate = null,
    Object? impactQuantity = null,
    Object? recommendedAction = freezed,
    Object? alertData = freezed,
    Object? isResolved = null,
    Object? resolvedAt = freezed,
    Object? resolvedBy = freezed,
  }) {
    return _then(_MrpAlert(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      planId: null == planId
          ? _self.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      materialId: null == materialId
          ? _self.materialId
          : materialId // ignore: cast_nullable_to_non_nullable
              as String,
      alertType: null == alertType
          ? _self.alertType
          : alertType // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _self.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      alertDate: null == alertDate
          ? _self.alertDate
          : alertDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      impactQuantity: null == impactQuantity
          ? _self.impactQuantity
          : impactQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      recommendedAction: freezed == recommendedAction
          ? _self.recommendedAction
          : recommendedAction // ignore: cast_nullable_to_non_nullable
              as String?,
      alertData: freezed == alertData
          ? _self._alertData
          : alertData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isResolved: null == isResolved
          ? _self.isResolved
          : isResolved // ignore: cast_nullable_to_non_nullable
              as bool,
      resolvedAt: freezed == resolvedAt
          ? _self.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedBy: freezed == resolvedBy
          ? _self.resolvedBy
          : resolvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$MrpPlan {
  String get id;
  String get planName;
  String get planCode;
  DateTime get planningStartDate;
  DateTime get planningEndDate;
  int get planningHorizonDays;
  List<String> get bomIds;
  Map<String, double> get productionSchedule;
  List<MrpRequirement> get requirements;
  List<MrpActionMessage> get actionMessages;
  List<MrpAlert> get alerts;
  MrpPlanStatus get status;
  double get totalMaterialCost;
  double get totalInventoryValue;
  int get totalMaterials;
  int get criticalMaterials;
  String? get createdBy;
  String? get approvedBy;
  DateTime? get approvedAt;
  DateTime get createdAt;
  DateTime get updatedAt;
  Map<String, dynamic>? get planningParameters;
  Map<String, dynamic>? get optimizationResults;

  /// Create a copy of MrpPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MrpPlanCopyWith<MrpPlan> get copyWith =>
      _$MrpPlanCopyWithImpl<MrpPlan>(this as MrpPlan, _$identity);

  /// Serializes this MrpPlan to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MrpPlan &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.planName, planName) ||
                other.planName == planName) &&
            (identical(other.planCode, planCode) ||
                other.planCode == planCode) &&
            (identical(other.planningStartDate, planningStartDate) ||
                other.planningStartDate == planningStartDate) &&
            (identical(other.planningEndDate, planningEndDate) ||
                other.planningEndDate == planningEndDate) &&
            (identical(other.planningHorizonDays, planningHorizonDays) ||
                other.planningHorizonDays == planningHorizonDays) &&
            const DeepCollectionEquality().equals(other.bomIds, bomIds) &&
            const DeepCollectionEquality()
                .equals(other.productionSchedule, productionSchedule) &&
            const DeepCollectionEquality()
                .equals(other.requirements, requirements) &&
            const DeepCollectionEquality()
                .equals(other.actionMessages, actionMessages) &&
            const DeepCollectionEquality().equals(other.alerts, alerts) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalMaterialCost, totalMaterialCost) ||
                other.totalMaterialCost == totalMaterialCost) &&
            (identical(other.totalInventoryValue, totalInventoryValue) ||
                other.totalInventoryValue == totalInventoryValue) &&
            (identical(other.totalMaterials, totalMaterials) ||
                other.totalMaterials == totalMaterials) &&
            (identical(other.criticalMaterials, criticalMaterials) ||
                other.criticalMaterials == criticalMaterials) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality()
                .equals(other.planningParameters, planningParameters) &&
            const DeepCollectionEquality()
                .equals(other.optimizationResults, optimizationResults));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        planName,
        planCode,
        planningStartDate,
        planningEndDate,
        planningHorizonDays,
        const DeepCollectionEquality().hash(bomIds),
        const DeepCollectionEquality().hash(productionSchedule),
        const DeepCollectionEquality().hash(requirements),
        const DeepCollectionEquality().hash(actionMessages),
        const DeepCollectionEquality().hash(alerts),
        status,
        totalMaterialCost,
        totalInventoryValue,
        totalMaterials,
        criticalMaterials,
        createdBy,
        approvedBy,
        approvedAt,
        createdAt,
        updatedAt,
        const DeepCollectionEquality().hash(planningParameters),
        const DeepCollectionEquality().hash(optimizationResults)
      ]);

  @override
  String toString() {
    return 'MrpPlan(id: $id, planName: $planName, planCode: $planCode, planningStartDate: $planningStartDate, planningEndDate: $planningEndDate, planningHorizonDays: $planningHorizonDays, bomIds: $bomIds, productionSchedule: $productionSchedule, requirements: $requirements, actionMessages: $actionMessages, alerts: $alerts, status: $status, totalMaterialCost: $totalMaterialCost, totalInventoryValue: $totalInventoryValue, totalMaterials: $totalMaterials, criticalMaterials: $criticalMaterials, createdBy: $createdBy, approvedBy: $approvedBy, approvedAt: $approvedAt, createdAt: $createdAt, updatedAt: $updatedAt, planningParameters: $planningParameters, optimizationResults: $optimizationResults)';
  }
}

/// @nodoc
abstract mixin class $MrpPlanCopyWith<$Res> {
  factory $MrpPlanCopyWith(MrpPlan value, $Res Function(MrpPlan) _then) =
      _$MrpPlanCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String planName,
      String planCode,
      DateTime planningStartDate,
      DateTime planningEndDate,
      int planningHorizonDays,
      List<String> bomIds,
      Map<String, double> productionSchedule,
      List<MrpRequirement> requirements,
      List<MrpActionMessage> actionMessages,
      List<MrpAlert> alerts,
      MrpPlanStatus status,
      double totalMaterialCost,
      double totalInventoryValue,
      int totalMaterials,
      int criticalMaterials,
      String? createdBy,
      String? approvedBy,
      DateTime? approvedAt,
      DateTime createdAt,
      DateTime updatedAt,
      Map<String, dynamic>? planningParameters,
      Map<String, dynamic>? optimizationResults});
}

/// @nodoc
class _$MrpPlanCopyWithImpl<$Res> implements $MrpPlanCopyWith<$Res> {
  _$MrpPlanCopyWithImpl(this._self, this._then);

  final MrpPlan _self;
  final $Res Function(MrpPlan) _then;

  /// Create a copy of MrpPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? planName = null,
    Object? planCode = null,
    Object? planningStartDate = null,
    Object? planningEndDate = null,
    Object? planningHorizonDays = null,
    Object? bomIds = null,
    Object? productionSchedule = null,
    Object? requirements = null,
    Object? actionMessages = null,
    Object? alerts = null,
    Object? status = null,
    Object? totalMaterialCost = null,
    Object? totalInventoryValue = null,
    Object? totalMaterials = null,
    Object? criticalMaterials = null,
    Object? createdBy = freezed,
    Object? approvedBy = freezed,
    Object? approvedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? planningParameters = freezed,
    Object? optimizationResults = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      planName: null == planName
          ? _self.planName
          : planName // ignore: cast_nullable_to_non_nullable
              as String,
      planCode: null == planCode
          ? _self.planCode
          : planCode // ignore: cast_nullable_to_non_nullable
              as String,
      planningStartDate: null == planningStartDate
          ? _self.planningStartDate
          : planningStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      planningEndDate: null == planningEndDate
          ? _self.planningEndDate
          : planningEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      planningHorizonDays: null == planningHorizonDays
          ? _self.planningHorizonDays
          : planningHorizonDays // ignore: cast_nullable_to_non_nullable
              as int,
      bomIds: null == bomIds
          ? _self.bomIds
          : bomIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      productionSchedule: null == productionSchedule
          ? _self.productionSchedule
          : productionSchedule // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      requirements: null == requirements
          ? _self.requirements
          : requirements // ignore: cast_nullable_to_non_nullable
              as List<MrpRequirement>,
      actionMessages: null == actionMessages
          ? _self.actionMessages
          : actionMessages // ignore: cast_nullable_to_non_nullable
              as List<MrpActionMessage>,
      alerts: null == alerts
          ? _self.alerts
          : alerts // ignore: cast_nullable_to_non_nullable
              as List<MrpAlert>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as MrpPlanStatus,
      totalMaterialCost: null == totalMaterialCost
          ? _self.totalMaterialCost
          : totalMaterialCost // ignore: cast_nullable_to_non_nullable
              as double,
      totalInventoryValue: null == totalInventoryValue
          ? _self.totalInventoryValue
          : totalInventoryValue // ignore: cast_nullable_to_non_nullable
              as double,
      totalMaterials: null == totalMaterials
          ? _self.totalMaterials
          : totalMaterials // ignore: cast_nullable_to_non_nullable
              as int,
      criticalMaterials: null == criticalMaterials
          ? _self.criticalMaterials
          : criticalMaterials // ignore: cast_nullable_to_non_nullable
              as int,
      createdBy: freezed == createdBy
          ? _self.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedBy: freezed == approvedBy
          ? _self.approvedBy
          : approvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedAt: freezed == approvedAt
          ? _self.approvedAt
          : approvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      planningParameters: freezed == planningParameters
          ? _self.planningParameters
          : planningParameters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      optimizationResults: freezed == optimizationResults
          ? _self.optimizationResults
          : optimizationResults // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _MrpPlan extends MrpPlan {
  const _MrpPlan(
      {required this.id,
      required this.planName,
      required this.planCode,
      required this.planningStartDate,
      required this.planningEndDate,
      required this.planningHorizonDays,
      required final List<String> bomIds,
      required final Map<String, double> productionSchedule,
      required final List<MrpRequirement> requirements,
      required final List<MrpActionMessage> actionMessages,
      required final List<MrpAlert> alerts,
      this.status = MrpPlanStatus.draft,
      this.totalMaterialCost = 0.0,
      this.totalInventoryValue = 0.0,
      this.totalMaterials = 0,
      this.criticalMaterials = 0,
      this.createdBy,
      this.approvedBy,
      this.approvedAt,
      required this.createdAt,
      required this.updatedAt,
      final Map<String, dynamic>? planningParameters,
      final Map<String, dynamic>? optimizationResults})
      : _bomIds = bomIds,
        _productionSchedule = productionSchedule,
        _requirements = requirements,
        _actionMessages = actionMessages,
        _alerts = alerts,
        _planningParameters = planningParameters,
        _optimizationResults = optimizationResults,
        super._();
  factory _MrpPlan.fromJson(Map<String, dynamic> json) =>
      _$MrpPlanFromJson(json);

  @override
  final String id;
  @override
  final String planName;
  @override
  final String planCode;
  @override
  final DateTime planningStartDate;
  @override
  final DateTime planningEndDate;
  @override
  final int planningHorizonDays;
  final List<String> _bomIds;
  @override
  List<String> get bomIds {
    if (_bomIds is EqualUnmodifiableListView) return _bomIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bomIds);
  }

  final Map<String, double> _productionSchedule;
  @override
  Map<String, double> get productionSchedule {
    if (_productionSchedule is EqualUnmodifiableMapView)
      return _productionSchedule;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_productionSchedule);
  }

  final List<MrpRequirement> _requirements;
  @override
  List<MrpRequirement> get requirements {
    if (_requirements is EqualUnmodifiableListView) return _requirements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requirements);
  }

  final List<MrpActionMessage> _actionMessages;
  @override
  List<MrpActionMessage> get actionMessages {
    if (_actionMessages is EqualUnmodifiableListView) return _actionMessages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actionMessages);
  }

  final List<MrpAlert> _alerts;
  @override
  List<MrpAlert> get alerts {
    if (_alerts is EqualUnmodifiableListView) return _alerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alerts);
  }

  @override
  @JsonKey()
  final MrpPlanStatus status;
  @override
  @JsonKey()
  final double totalMaterialCost;
  @override
  @JsonKey()
  final double totalInventoryValue;
  @override
  @JsonKey()
  final int totalMaterials;
  @override
  @JsonKey()
  final int criticalMaterials;
  @override
  final String? createdBy;
  @override
  final String? approvedBy;
  @override
  final DateTime? approvedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  final Map<String, dynamic>? _planningParameters;
  @override
  Map<String, dynamic>? get planningParameters {
    final value = _planningParameters;
    if (value == null) return null;
    if (_planningParameters is EqualUnmodifiableMapView)
      return _planningParameters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _optimizationResults;
  @override
  Map<String, dynamic>? get optimizationResults {
    final value = _optimizationResults;
    if (value == null) return null;
    if (_optimizationResults is EqualUnmodifiableMapView)
      return _optimizationResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of MrpPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MrpPlanCopyWith<_MrpPlan> get copyWith =>
      __$MrpPlanCopyWithImpl<_MrpPlan>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MrpPlanToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MrpPlan &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.planName, planName) ||
                other.planName == planName) &&
            (identical(other.planCode, planCode) ||
                other.planCode == planCode) &&
            (identical(other.planningStartDate, planningStartDate) ||
                other.planningStartDate == planningStartDate) &&
            (identical(other.planningEndDate, planningEndDate) ||
                other.planningEndDate == planningEndDate) &&
            (identical(other.planningHorizonDays, planningHorizonDays) ||
                other.planningHorizonDays == planningHorizonDays) &&
            const DeepCollectionEquality().equals(other._bomIds, _bomIds) &&
            const DeepCollectionEquality()
                .equals(other._productionSchedule, _productionSchedule) &&
            const DeepCollectionEquality()
                .equals(other._requirements, _requirements) &&
            const DeepCollectionEquality()
                .equals(other._actionMessages, _actionMessages) &&
            const DeepCollectionEquality().equals(other._alerts, _alerts) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalMaterialCost, totalMaterialCost) ||
                other.totalMaterialCost == totalMaterialCost) &&
            (identical(other.totalInventoryValue, totalInventoryValue) ||
                other.totalInventoryValue == totalInventoryValue) &&
            (identical(other.totalMaterials, totalMaterials) ||
                other.totalMaterials == totalMaterials) &&
            (identical(other.criticalMaterials, criticalMaterials) ||
                other.criticalMaterials == criticalMaterials) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality()
                .equals(other._planningParameters, _planningParameters) &&
            const DeepCollectionEquality()
                .equals(other._optimizationResults, _optimizationResults));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        planName,
        planCode,
        planningStartDate,
        planningEndDate,
        planningHorizonDays,
        const DeepCollectionEquality().hash(_bomIds),
        const DeepCollectionEquality().hash(_productionSchedule),
        const DeepCollectionEquality().hash(_requirements),
        const DeepCollectionEquality().hash(_actionMessages),
        const DeepCollectionEquality().hash(_alerts),
        status,
        totalMaterialCost,
        totalInventoryValue,
        totalMaterials,
        criticalMaterials,
        createdBy,
        approvedBy,
        approvedAt,
        createdAt,
        updatedAt,
        const DeepCollectionEquality().hash(_planningParameters),
        const DeepCollectionEquality().hash(_optimizationResults)
      ]);

  @override
  String toString() {
    return 'MrpPlan(id: $id, planName: $planName, planCode: $planCode, planningStartDate: $planningStartDate, planningEndDate: $planningEndDate, planningHorizonDays: $planningHorizonDays, bomIds: $bomIds, productionSchedule: $productionSchedule, requirements: $requirements, actionMessages: $actionMessages, alerts: $alerts, status: $status, totalMaterialCost: $totalMaterialCost, totalInventoryValue: $totalInventoryValue, totalMaterials: $totalMaterials, criticalMaterials: $criticalMaterials, createdBy: $createdBy, approvedBy: $approvedBy, approvedAt: $approvedAt, createdAt: $createdAt, updatedAt: $updatedAt, planningParameters: $planningParameters, optimizationResults: $optimizationResults)';
  }
}

/// @nodoc
abstract mixin class _$MrpPlanCopyWith<$Res> implements $MrpPlanCopyWith<$Res> {
  factory _$MrpPlanCopyWith(_MrpPlan value, $Res Function(_MrpPlan) _then) =
      __$MrpPlanCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String planName,
      String planCode,
      DateTime planningStartDate,
      DateTime planningEndDate,
      int planningHorizonDays,
      List<String> bomIds,
      Map<String, double> productionSchedule,
      List<MrpRequirement> requirements,
      List<MrpActionMessage> actionMessages,
      List<MrpAlert> alerts,
      MrpPlanStatus status,
      double totalMaterialCost,
      double totalInventoryValue,
      int totalMaterials,
      int criticalMaterials,
      String? createdBy,
      String? approvedBy,
      DateTime? approvedAt,
      DateTime createdAt,
      DateTime updatedAt,
      Map<String, dynamic>? planningParameters,
      Map<String, dynamic>? optimizationResults});
}

/// @nodoc
class __$MrpPlanCopyWithImpl<$Res> implements _$MrpPlanCopyWith<$Res> {
  __$MrpPlanCopyWithImpl(this._self, this._then);

  final _MrpPlan _self;
  final $Res Function(_MrpPlan) _then;

  /// Create a copy of MrpPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? planName = null,
    Object? planCode = null,
    Object? planningStartDate = null,
    Object? planningEndDate = null,
    Object? planningHorizonDays = null,
    Object? bomIds = null,
    Object? productionSchedule = null,
    Object? requirements = null,
    Object? actionMessages = null,
    Object? alerts = null,
    Object? status = null,
    Object? totalMaterialCost = null,
    Object? totalInventoryValue = null,
    Object? totalMaterials = null,
    Object? criticalMaterials = null,
    Object? createdBy = freezed,
    Object? approvedBy = freezed,
    Object? approvedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? planningParameters = freezed,
    Object? optimizationResults = freezed,
  }) {
    return _then(_MrpPlan(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      planName: null == planName
          ? _self.planName
          : planName // ignore: cast_nullable_to_non_nullable
              as String,
      planCode: null == planCode
          ? _self.planCode
          : planCode // ignore: cast_nullable_to_non_nullable
              as String,
      planningStartDate: null == planningStartDate
          ? _self.planningStartDate
          : planningStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      planningEndDate: null == planningEndDate
          ? _self.planningEndDate
          : planningEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      planningHorizonDays: null == planningHorizonDays
          ? _self.planningHorizonDays
          : planningHorizonDays // ignore: cast_nullable_to_non_nullable
              as int,
      bomIds: null == bomIds
          ? _self._bomIds
          : bomIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      productionSchedule: null == productionSchedule
          ? _self._productionSchedule
          : productionSchedule // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      requirements: null == requirements
          ? _self._requirements
          : requirements // ignore: cast_nullable_to_non_nullable
              as List<MrpRequirement>,
      actionMessages: null == actionMessages
          ? _self._actionMessages
          : actionMessages // ignore: cast_nullable_to_non_nullable
              as List<MrpActionMessage>,
      alerts: null == alerts
          ? _self._alerts
          : alerts // ignore: cast_nullable_to_non_nullable
              as List<MrpAlert>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as MrpPlanStatus,
      totalMaterialCost: null == totalMaterialCost
          ? _self.totalMaterialCost
          : totalMaterialCost // ignore: cast_nullable_to_non_nullable
              as double,
      totalInventoryValue: null == totalInventoryValue
          ? _self.totalInventoryValue
          : totalInventoryValue // ignore: cast_nullable_to_non_nullable
              as double,
      totalMaterials: null == totalMaterials
          ? _self.totalMaterials
          : totalMaterials // ignore: cast_nullable_to_non_nullable
              as int,
      criticalMaterials: null == criticalMaterials
          ? _self.criticalMaterials
          : criticalMaterials // ignore: cast_nullable_to_non_nullable
              as int,
      createdBy: freezed == createdBy
          ? _self.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedBy: freezed == approvedBy
          ? _self.approvedBy
          : approvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedAt: freezed == approvedAt
          ? _self.approvedAt
          : approvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      planningParameters: freezed == planningParameters
          ? _self._planningParameters
          : planningParameters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      optimizationResults: freezed == optimizationResults
          ? _self._optimizationResults
          : optimizationResults // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

// dart format on
