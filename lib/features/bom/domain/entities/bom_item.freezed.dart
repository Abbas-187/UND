// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bom_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BomItem {
  String get id;
  String get bomId;
  String get itemId;
  String get itemCode;
  String get itemName;
  String get itemDescription;
  BomItemType get itemType;
  double get quantity;
  String get unit;
  ConsumptionType get consumptionType;
  int get sequenceNumber;
  double get wastagePercentage;
  double get yieldPercentage;
  double get costPerUnit;
  double get totalCost;
  String? get alternativeItemId;
  String? get supplierCode;
  String? get batchNumber;
  DateTime? get expiryDate;
  String? get qualityGrade;
  String? get storageLocation;
  Map<String, dynamic>? get specifications;
  Map<String, dynamic>? get qualityParameters;
  BomItemStatus get status;
  String? get notes;
  DateTime? get effectiveFrom;
  DateTime? get effectiveTo;
  DateTime get createdAt;
  DateTime get updatedAt;
  String? get createdBy;
  String? get updatedBy;

  /// Create a copy of BomItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BomItemCopyWith<BomItem> get copyWith =>
      _$BomItemCopyWithImpl<BomItem>(this as BomItem, _$identity);

  /// Serializes this BomItem to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BomItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bomId, bomId) || other.bomId == bomId) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.itemDescription, itemDescription) ||
                other.itemDescription == itemDescription) &&
            (identical(other.itemType, itemType) ||
                other.itemType == itemType) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.consumptionType, consumptionType) ||
                other.consumptionType == consumptionType) &&
            (identical(other.sequenceNumber, sequenceNumber) ||
                other.sequenceNumber == sequenceNumber) &&
            (identical(other.wastagePercentage, wastagePercentage) ||
                other.wastagePercentage == wastagePercentage) &&
            (identical(other.yieldPercentage, yieldPercentage) ||
                other.yieldPercentage == yieldPercentage) &&
            (identical(other.costPerUnit, costPerUnit) ||
                other.costPerUnit == costPerUnit) &&
            (identical(other.totalCost, totalCost) ||
                other.totalCost == totalCost) &&
            (identical(other.alternativeItemId, alternativeItemId) ||
                other.alternativeItemId == alternativeItemId) &&
            (identical(other.supplierCode, supplierCode) ||
                other.supplierCode == supplierCode) &&
            (identical(other.batchNumber, batchNumber) ||
                other.batchNumber == batchNumber) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.qualityGrade, qualityGrade) ||
                other.qualityGrade == qualityGrade) &&
            (identical(other.storageLocation, storageLocation) ||
                other.storageLocation == storageLocation) &&
            const DeepCollectionEquality()
                .equals(other.specifications, specifications) &&
            const DeepCollectionEquality()
                .equals(other.qualityParameters, qualityParameters) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.effectiveFrom, effectiveFrom) ||
                other.effectiveFrom == effectiveFrom) &&
            (identical(other.effectiveTo, effectiveTo) ||
                other.effectiveTo == effectiveTo) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        bomId,
        itemId,
        itemCode,
        itemName,
        itemDescription,
        itemType,
        quantity,
        unit,
        consumptionType,
        sequenceNumber,
        wastagePercentage,
        yieldPercentage,
        costPerUnit,
        totalCost,
        alternativeItemId,
        supplierCode,
        batchNumber,
        expiryDate,
        qualityGrade,
        storageLocation,
        const DeepCollectionEquality().hash(specifications),
        const DeepCollectionEquality().hash(qualityParameters),
        status,
        notes,
        effectiveFrom,
        effectiveTo,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy
      ]);

  @override
  String toString() {
    return 'BomItem(id: $id, bomId: $bomId, itemId: $itemId, itemCode: $itemCode, itemName: $itemName, itemDescription: $itemDescription, itemType: $itemType, quantity: $quantity, unit: $unit, consumptionType: $consumptionType, sequenceNumber: $sequenceNumber, wastagePercentage: $wastagePercentage, yieldPercentage: $yieldPercentage, costPerUnit: $costPerUnit, totalCost: $totalCost, alternativeItemId: $alternativeItemId, supplierCode: $supplierCode, batchNumber: $batchNumber, expiryDate: $expiryDate, qualityGrade: $qualityGrade, storageLocation: $storageLocation, specifications: $specifications, qualityParameters: $qualityParameters, status: $status, notes: $notes, effectiveFrom: $effectiveFrom, effectiveTo: $effectiveTo, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy, updatedBy: $updatedBy)';
  }
}

/// @nodoc
abstract mixin class $BomItemCopyWith<$Res> {
  factory $BomItemCopyWith(BomItem value, $Res Function(BomItem) _then) =
      _$BomItemCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String bomId,
      String itemId,
      String itemCode,
      String itemName,
      String itemDescription,
      BomItemType itemType,
      double quantity,
      String unit,
      ConsumptionType consumptionType,
      int sequenceNumber,
      double wastagePercentage,
      double yieldPercentage,
      double costPerUnit,
      double totalCost,
      String? alternativeItemId,
      String? supplierCode,
      String? batchNumber,
      DateTime? expiryDate,
      String? qualityGrade,
      String? storageLocation,
      Map<String, dynamic>? specifications,
      Map<String, dynamic>? qualityParameters,
      BomItemStatus status,
      String? notes,
      DateTime? effectiveFrom,
      DateTime? effectiveTo,
      DateTime createdAt,
      DateTime updatedAt,
      String? createdBy,
      String? updatedBy});
}

/// @nodoc
class _$BomItemCopyWithImpl<$Res> implements $BomItemCopyWith<$Res> {
  _$BomItemCopyWithImpl(this._self, this._then);

  final BomItem _self;
  final $Res Function(BomItem) _then;

  /// Create a copy of BomItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bomId = null,
    Object? itemId = null,
    Object? itemCode = null,
    Object? itemName = null,
    Object? itemDescription = null,
    Object? itemType = null,
    Object? quantity = null,
    Object? unit = null,
    Object? consumptionType = null,
    Object? sequenceNumber = null,
    Object? wastagePercentage = null,
    Object? yieldPercentage = null,
    Object? costPerUnit = null,
    Object? totalCost = null,
    Object? alternativeItemId = freezed,
    Object? supplierCode = freezed,
    Object? batchNumber = freezed,
    Object? expiryDate = freezed,
    Object? qualityGrade = freezed,
    Object? storageLocation = freezed,
    Object? specifications = freezed,
    Object? qualityParameters = freezed,
    Object? status = null,
    Object? notes = freezed,
    Object? effectiveFrom = freezed,
    Object? effectiveTo = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
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
      itemDescription: null == itemDescription
          ? _self.itemDescription
          : itemDescription // ignore: cast_nullable_to_non_nullable
              as String,
      itemType: null == itemType
          ? _self.itemType
          : itemType // ignore: cast_nullable_to_non_nullable
              as BomItemType,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _self.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      consumptionType: null == consumptionType
          ? _self.consumptionType
          : consumptionType // ignore: cast_nullable_to_non_nullable
              as ConsumptionType,
      sequenceNumber: null == sequenceNumber
          ? _self.sequenceNumber
          : sequenceNumber // ignore: cast_nullable_to_non_nullable
              as int,
      wastagePercentage: null == wastagePercentage
          ? _self.wastagePercentage
          : wastagePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      yieldPercentage: null == yieldPercentage
          ? _self.yieldPercentage
          : yieldPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      costPerUnit: null == costPerUnit
          ? _self.costPerUnit
          : costPerUnit // ignore: cast_nullable_to_non_nullable
              as double,
      totalCost: null == totalCost
          ? _self.totalCost
          : totalCost // ignore: cast_nullable_to_non_nullable
              as double,
      alternativeItemId: freezed == alternativeItemId
          ? _self.alternativeItemId
          : alternativeItemId // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierCode: freezed == supplierCode
          ? _self.supplierCode
          : supplierCode // ignore: cast_nullable_to_non_nullable
              as String?,
      batchNumber: freezed == batchNumber
          ? _self.batchNumber
          : batchNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      expiryDate: freezed == expiryDate
          ? _self.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      qualityGrade: freezed == qualityGrade
          ? _self.qualityGrade
          : qualityGrade // ignore: cast_nullable_to_non_nullable
              as String?,
      storageLocation: freezed == storageLocation
          ? _self.storageLocation
          : storageLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      specifications: freezed == specifications
          ? _self.specifications
          : specifications // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      qualityParameters: freezed == qualityParameters
          ? _self.qualityParameters
          : qualityParameters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as BomItemStatus,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      effectiveFrom: freezed == effectiveFrom
          ? _self.effectiveFrom
          : effectiveFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      effectiveTo: freezed == effectiveTo
          ? _self.effectiveTo
          : effectiveTo // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdBy: freezed == createdBy
          ? _self.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedBy: freezed == updatedBy
          ? _self.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _BomItem extends BomItem {
  const _BomItem(
      {required this.id,
      required this.bomId,
      required this.itemId,
      required this.itemCode,
      required this.itemName,
      required this.itemDescription,
      required this.itemType,
      required this.quantity,
      required this.unit,
      required this.consumptionType,
      required this.sequenceNumber,
      this.wastagePercentage = 0.0,
      this.yieldPercentage = 0.0,
      this.costPerUnit = 0.0,
      this.totalCost = 0.0,
      this.alternativeItemId,
      this.supplierCode,
      this.batchNumber,
      this.expiryDate,
      this.qualityGrade,
      this.storageLocation,
      final Map<String, dynamic>? specifications,
      final Map<String, dynamic>? qualityParameters,
      this.status = BomItemStatus.active,
      this.notes,
      this.effectiveFrom,
      this.effectiveTo,
      required this.createdAt,
      required this.updatedAt,
      this.createdBy,
      this.updatedBy})
      : _specifications = specifications,
        _qualityParameters = qualityParameters,
        super._();
  factory _BomItem.fromJson(Map<String, dynamic> json) =>
      _$BomItemFromJson(json);

  @override
  final String id;
  @override
  final String bomId;
  @override
  final String itemId;
  @override
  final String itemCode;
  @override
  final String itemName;
  @override
  final String itemDescription;
  @override
  final BomItemType itemType;
  @override
  final double quantity;
  @override
  final String unit;
  @override
  final ConsumptionType consumptionType;
  @override
  final int sequenceNumber;
  @override
  @JsonKey()
  final double wastagePercentage;
  @override
  @JsonKey()
  final double yieldPercentage;
  @override
  @JsonKey()
  final double costPerUnit;
  @override
  @JsonKey()
  final double totalCost;
  @override
  final String? alternativeItemId;
  @override
  final String? supplierCode;
  @override
  final String? batchNumber;
  @override
  final DateTime? expiryDate;
  @override
  final String? qualityGrade;
  @override
  final String? storageLocation;
  final Map<String, dynamic>? _specifications;
  @override
  Map<String, dynamic>? get specifications {
    final value = _specifications;
    if (value == null) return null;
    if (_specifications is EqualUnmodifiableMapView) return _specifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _qualityParameters;
  @override
  Map<String, dynamic>? get qualityParameters {
    final value = _qualityParameters;
    if (value == null) return null;
    if (_qualityParameters is EqualUnmodifiableMapView)
      return _qualityParameters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final BomItemStatus status;
  @override
  final String? notes;
  @override
  final DateTime? effectiveFrom;
  @override
  final DateTime? effectiveTo;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? createdBy;
  @override
  final String? updatedBy;

  /// Create a copy of BomItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BomItemCopyWith<_BomItem> get copyWith =>
      __$BomItemCopyWithImpl<_BomItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$BomItemToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BomItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bomId, bomId) || other.bomId == bomId) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.itemCode, itemCode) ||
                other.itemCode == itemCode) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.itemDescription, itemDescription) ||
                other.itemDescription == itemDescription) &&
            (identical(other.itemType, itemType) ||
                other.itemType == itemType) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.consumptionType, consumptionType) ||
                other.consumptionType == consumptionType) &&
            (identical(other.sequenceNumber, sequenceNumber) ||
                other.sequenceNumber == sequenceNumber) &&
            (identical(other.wastagePercentage, wastagePercentage) ||
                other.wastagePercentage == wastagePercentage) &&
            (identical(other.yieldPercentage, yieldPercentage) ||
                other.yieldPercentage == yieldPercentage) &&
            (identical(other.costPerUnit, costPerUnit) ||
                other.costPerUnit == costPerUnit) &&
            (identical(other.totalCost, totalCost) ||
                other.totalCost == totalCost) &&
            (identical(other.alternativeItemId, alternativeItemId) ||
                other.alternativeItemId == alternativeItemId) &&
            (identical(other.supplierCode, supplierCode) ||
                other.supplierCode == supplierCode) &&
            (identical(other.batchNumber, batchNumber) ||
                other.batchNumber == batchNumber) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.qualityGrade, qualityGrade) ||
                other.qualityGrade == qualityGrade) &&
            (identical(other.storageLocation, storageLocation) ||
                other.storageLocation == storageLocation) &&
            const DeepCollectionEquality()
                .equals(other._specifications, _specifications) &&
            const DeepCollectionEquality()
                .equals(other._qualityParameters, _qualityParameters) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.effectiveFrom, effectiveFrom) ||
                other.effectiveFrom == effectiveFrom) &&
            (identical(other.effectiveTo, effectiveTo) ||
                other.effectiveTo == effectiveTo) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        bomId,
        itemId,
        itemCode,
        itemName,
        itemDescription,
        itemType,
        quantity,
        unit,
        consumptionType,
        sequenceNumber,
        wastagePercentage,
        yieldPercentage,
        costPerUnit,
        totalCost,
        alternativeItemId,
        supplierCode,
        batchNumber,
        expiryDate,
        qualityGrade,
        storageLocation,
        const DeepCollectionEquality().hash(_specifications),
        const DeepCollectionEquality().hash(_qualityParameters),
        status,
        notes,
        effectiveFrom,
        effectiveTo,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy
      ]);

  @override
  String toString() {
    return 'BomItem(id: $id, bomId: $bomId, itemId: $itemId, itemCode: $itemCode, itemName: $itemName, itemDescription: $itemDescription, itemType: $itemType, quantity: $quantity, unit: $unit, consumptionType: $consumptionType, sequenceNumber: $sequenceNumber, wastagePercentage: $wastagePercentage, yieldPercentage: $yieldPercentage, costPerUnit: $costPerUnit, totalCost: $totalCost, alternativeItemId: $alternativeItemId, supplierCode: $supplierCode, batchNumber: $batchNumber, expiryDate: $expiryDate, qualityGrade: $qualityGrade, storageLocation: $storageLocation, specifications: $specifications, qualityParameters: $qualityParameters, status: $status, notes: $notes, effectiveFrom: $effectiveFrom, effectiveTo: $effectiveTo, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy, updatedBy: $updatedBy)';
  }
}

/// @nodoc
abstract mixin class _$BomItemCopyWith<$Res> implements $BomItemCopyWith<$Res> {
  factory _$BomItemCopyWith(_BomItem value, $Res Function(_BomItem) _then) =
      __$BomItemCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String bomId,
      String itemId,
      String itemCode,
      String itemName,
      String itemDescription,
      BomItemType itemType,
      double quantity,
      String unit,
      ConsumptionType consumptionType,
      int sequenceNumber,
      double wastagePercentage,
      double yieldPercentage,
      double costPerUnit,
      double totalCost,
      String? alternativeItemId,
      String? supplierCode,
      String? batchNumber,
      DateTime? expiryDate,
      String? qualityGrade,
      String? storageLocation,
      Map<String, dynamic>? specifications,
      Map<String, dynamic>? qualityParameters,
      BomItemStatus status,
      String? notes,
      DateTime? effectiveFrom,
      DateTime? effectiveTo,
      DateTime createdAt,
      DateTime updatedAt,
      String? createdBy,
      String? updatedBy});
}

/// @nodoc
class __$BomItemCopyWithImpl<$Res> implements _$BomItemCopyWith<$Res> {
  __$BomItemCopyWithImpl(this._self, this._then);

  final _BomItem _self;
  final $Res Function(_BomItem) _then;

  /// Create a copy of BomItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? bomId = null,
    Object? itemId = null,
    Object? itemCode = null,
    Object? itemName = null,
    Object? itemDescription = null,
    Object? itemType = null,
    Object? quantity = null,
    Object? unit = null,
    Object? consumptionType = null,
    Object? sequenceNumber = null,
    Object? wastagePercentage = null,
    Object? yieldPercentage = null,
    Object? costPerUnit = null,
    Object? totalCost = null,
    Object? alternativeItemId = freezed,
    Object? supplierCode = freezed,
    Object? batchNumber = freezed,
    Object? expiryDate = freezed,
    Object? qualityGrade = freezed,
    Object? storageLocation = freezed,
    Object? specifications = freezed,
    Object? qualityParameters = freezed,
    Object? status = null,
    Object? notes = freezed,
    Object? effectiveFrom = freezed,
    Object? effectiveTo = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
  }) {
    return _then(_BomItem(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      bomId: null == bomId
          ? _self.bomId
          : bomId // ignore: cast_nullable_to_non_nullable
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
      itemDescription: null == itemDescription
          ? _self.itemDescription
          : itemDescription // ignore: cast_nullable_to_non_nullable
              as String,
      itemType: null == itemType
          ? _self.itemType
          : itemType // ignore: cast_nullable_to_non_nullable
              as BomItemType,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _self.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      consumptionType: null == consumptionType
          ? _self.consumptionType
          : consumptionType // ignore: cast_nullable_to_non_nullable
              as ConsumptionType,
      sequenceNumber: null == sequenceNumber
          ? _self.sequenceNumber
          : sequenceNumber // ignore: cast_nullable_to_non_nullable
              as int,
      wastagePercentage: null == wastagePercentage
          ? _self.wastagePercentage
          : wastagePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      yieldPercentage: null == yieldPercentage
          ? _self.yieldPercentage
          : yieldPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      costPerUnit: null == costPerUnit
          ? _self.costPerUnit
          : costPerUnit // ignore: cast_nullable_to_non_nullable
              as double,
      totalCost: null == totalCost
          ? _self.totalCost
          : totalCost // ignore: cast_nullable_to_non_nullable
              as double,
      alternativeItemId: freezed == alternativeItemId
          ? _self.alternativeItemId
          : alternativeItemId // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierCode: freezed == supplierCode
          ? _self.supplierCode
          : supplierCode // ignore: cast_nullable_to_non_nullable
              as String?,
      batchNumber: freezed == batchNumber
          ? _self.batchNumber
          : batchNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      expiryDate: freezed == expiryDate
          ? _self.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      qualityGrade: freezed == qualityGrade
          ? _self.qualityGrade
          : qualityGrade // ignore: cast_nullable_to_non_nullable
              as String?,
      storageLocation: freezed == storageLocation
          ? _self.storageLocation
          : storageLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      specifications: freezed == specifications
          ? _self._specifications
          : specifications // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      qualityParameters: freezed == qualityParameters
          ? _self._qualityParameters
          : qualityParameters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as BomItemStatus,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      effectiveFrom: freezed == effectiveFrom
          ? _self.effectiveFrom
          : effectiveFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      effectiveTo: freezed == effectiveTo
          ? _self.effectiveTo
          : effectiveTo // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdBy: freezed == createdBy
          ? _self.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedBy: freezed == updatedBy
          ? _self.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
