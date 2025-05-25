// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InventoryItemModel {
  String? get id;
  String get appItemId;
  String get sapCode;
  String get name;
  String get category;
  String get subCategory;
  String get unit;
  double get quantity;
  double get minimumQuantity;
  double get reorderPoint;
  String get location;
  DateTime get lastUpdated;
  String? get batchNumber;
  DateTime? get expiryDate;
  Map<String, dynamic>? get additionalAttributes;
  double? get cost;
  int get lowStockThreshold;
  String? get supplier;
  double? get safetyStock;
  double? get currentConsumption;

  /// Create a copy of InventoryItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InventoryItemModelCopyWith<InventoryItemModel> get copyWith =>
      _$InventoryItemModelCopyWithImpl<InventoryItemModel>(
          this as InventoryItemModel, _$identity);

  /// Serializes this InventoryItemModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InventoryItemModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.appItemId, appItemId) ||
                other.appItemId == appItemId) &&
            (identical(other.sapCode, sapCode) || other.sapCode == sapCode) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.subCategory, subCategory) ||
                other.subCategory == subCategory) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.minimumQuantity, minimumQuantity) ||
                other.minimumQuantity == minimumQuantity) &&
            (identical(other.reorderPoint, reorderPoint) ||
                other.reorderPoint == reorderPoint) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.batchNumber, batchNumber) ||
                other.batchNumber == batchNumber) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            const DeepCollectionEquality()
                .equals(other.additionalAttributes, additionalAttributes) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            (identical(other.supplier, supplier) ||
                other.supplier == supplier) &&
            (identical(other.safetyStock, safetyStock) ||
                other.safetyStock == safetyStock) &&
            (identical(other.currentConsumption, currentConsumption) ||
                other.currentConsumption == currentConsumption));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        appItemId,
        sapCode,
        name,
        category,
        subCategory,
        unit,
        quantity,
        minimumQuantity,
        reorderPoint,
        location,
        lastUpdated,
        batchNumber,
        expiryDate,
        const DeepCollectionEquality().hash(additionalAttributes),
        cost,
        lowStockThreshold,
        supplier,
        safetyStock,
        currentConsumption
      ]);

  @override
  String toString() {
    return 'InventoryItemModel(id: $id, appItemId: $appItemId, sapCode: $sapCode, name: $name, category: $category, subCategory: $subCategory, unit: $unit, quantity: $quantity, minimumQuantity: $minimumQuantity, reorderPoint: $reorderPoint, location: $location, lastUpdated: $lastUpdated, batchNumber: $batchNumber, expiryDate: $expiryDate, additionalAttributes: $additionalAttributes, cost: $cost, lowStockThreshold: $lowStockThreshold, supplier: $supplier, safetyStock: $safetyStock, currentConsumption: $currentConsumption)';
  }
}

/// @nodoc
abstract mixin class $InventoryItemModelCopyWith<$Res> {
  factory $InventoryItemModelCopyWith(
          InventoryItemModel value, $Res Function(InventoryItemModel) _then) =
      _$InventoryItemModelCopyWithImpl;
  @useResult
  $Res call(
      {String? id,
      String appItemId,
      String sapCode,
      String name,
      String category,
      String subCategory,
      String unit,
      double quantity,
      double minimumQuantity,
      double reorderPoint,
      String location,
      DateTime lastUpdated,
      String? batchNumber,
      DateTime? expiryDate,
      Map<String, dynamic>? additionalAttributes,
      double? cost,
      int lowStockThreshold,
      String? supplier,
      double? safetyStock,
      double? currentConsumption});
}

/// @nodoc
class _$InventoryItemModelCopyWithImpl<$Res>
    implements $InventoryItemModelCopyWith<$Res> {
  _$InventoryItemModelCopyWithImpl(this._self, this._then);

  final InventoryItemModel _self;
  final $Res Function(InventoryItemModel) _then;

  /// Create a copy of InventoryItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? appItemId = null,
    Object? sapCode = null,
    Object? name = null,
    Object? category = null,
    Object? subCategory = null,
    Object? unit = null,
    Object? quantity = null,
    Object? minimumQuantity = null,
    Object? reorderPoint = null,
    Object? location = null,
    Object? lastUpdated = null,
    Object? batchNumber = freezed,
    Object? expiryDate = freezed,
    Object? additionalAttributes = freezed,
    Object? cost = freezed,
    Object? lowStockThreshold = null,
    Object? supplier = freezed,
    Object? safetyStock = freezed,
    Object? currentConsumption = freezed,
  }) {
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      appItemId: null == appItemId
          ? _self.appItemId
          : appItemId // ignore: cast_nullable_to_non_nullable
              as String,
      sapCode: null == sapCode
          ? _self.sapCode
          : sapCode // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      subCategory: null == subCategory
          ? _self.subCategory
          : subCategory // ignore: cast_nullable_to_non_nullable
              as String,
      unit: null == unit
          ? _self.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      minimumQuantity: null == minimumQuantity
          ? _self.minimumQuantity
          : minimumQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      reorderPoint: null == reorderPoint
          ? _self.reorderPoint
          : reorderPoint // ignore: cast_nullable_to_non_nullable
              as double,
      location: null == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdated: null == lastUpdated
          ? _self.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      batchNumber: freezed == batchNumber
          ? _self.batchNumber
          : batchNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      expiryDate: freezed == expiryDate
          ? _self.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      additionalAttributes: freezed == additionalAttributes
          ? _self.additionalAttributes
          : additionalAttributes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      cost: freezed == cost
          ? _self.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
      lowStockThreshold: null == lowStockThreshold
          ? _self.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as int,
      supplier: freezed == supplier
          ? _self.supplier
          : supplier // ignore: cast_nullable_to_non_nullable
              as String?,
      safetyStock: freezed == safetyStock
          ? _self.safetyStock
          : safetyStock // ignore: cast_nullable_to_non_nullable
              as double?,
      currentConsumption: freezed == currentConsumption
          ? _self.currentConsumption
          : currentConsumption // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _InventoryItemModel extends InventoryItemModel {
  const _InventoryItemModel(
      {this.id,
      required this.appItemId,
      this.sapCode = '',
      required this.name,
      required this.category,
      this.subCategory = '',
      required this.unit,
      required this.quantity,
      required this.minimumQuantity,
      required this.reorderPoint,
      required this.location,
      required this.lastUpdated,
      this.batchNumber,
      this.expiryDate,
      final Map<String, dynamic>? additionalAttributes,
      this.cost,
      this.lowStockThreshold = 5,
      this.supplier,
      this.safetyStock,
      this.currentConsumption})
      : _additionalAttributes = additionalAttributes,
        super._();
  factory _InventoryItemModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemModelFromJson(json);

  @override
  final String? id;
  @override
  final String appItemId;
  @override
  @JsonKey()
  final String sapCode;
  @override
  final String name;
  @override
  final String category;
  @override
  @JsonKey()
  final String subCategory;
  @override
  final String unit;
  @override
  final double quantity;
  @override
  final double minimumQuantity;
  @override
  final double reorderPoint;
  @override
  final String location;
  @override
  final DateTime lastUpdated;
  @override
  final String? batchNumber;
  @override
  final DateTime? expiryDate;
  final Map<String, dynamic>? _additionalAttributes;
  @override
  Map<String, dynamic>? get additionalAttributes {
    final value = _additionalAttributes;
    if (value == null) return null;
    if (_additionalAttributes is EqualUnmodifiableMapView)
      return _additionalAttributes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final double? cost;
  @override
  @JsonKey()
  final int lowStockThreshold;
  @override
  final String? supplier;
  @override
  final double? safetyStock;
  @override
  final double? currentConsumption;

  /// Create a copy of InventoryItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InventoryItemModelCopyWith<_InventoryItemModel> get copyWith =>
      __$InventoryItemModelCopyWithImpl<_InventoryItemModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$InventoryItemModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InventoryItemModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.appItemId, appItemId) ||
                other.appItemId == appItemId) &&
            (identical(other.sapCode, sapCode) || other.sapCode == sapCode) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.subCategory, subCategory) ||
                other.subCategory == subCategory) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.minimumQuantity, minimumQuantity) ||
                other.minimumQuantity == minimumQuantity) &&
            (identical(other.reorderPoint, reorderPoint) ||
                other.reorderPoint == reorderPoint) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.batchNumber, batchNumber) ||
                other.batchNumber == batchNumber) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            const DeepCollectionEquality()
                .equals(other._additionalAttributes, _additionalAttributes) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            (identical(other.supplier, supplier) ||
                other.supplier == supplier) &&
            (identical(other.safetyStock, safetyStock) ||
                other.safetyStock == safetyStock) &&
            (identical(other.currentConsumption, currentConsumption) ||
                other.currentConsumption == currentConsumption));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        appItemId,
        sapCode,
        name,
        category,
        subCategory,
        unit,
        quantity,
        minimumQuantity,
        reorderPoint,
        location,
        lastUpdated,
        batchNumber,
        expiryDate,
        const DeepCollectionEquality().hash(_additionalAttributes),
        cost,
        lowStockThreshold,
        supplier,
        safetyStock,
        currentConsumption
      ]);

  @override
  String toString() {
    return 'InventoryItemModel(id: $id, appItemId: $appItemId, sapCode: $sapCode, name: $name, category: $category, subCategory: $subCategory, unit: $unit, quantity: $quantity, minimumQuantity: $minimumQuantity, reorderPoint: $reorderPoint, location: $location, lastUpdated: $lastUpdated, batchNumber: $batchNumber, expiryDate: $expiryDate, additionalAttributes: $additionalAttributes, cost: $cost, lowStockThreshold: $lowStockThreshold, supplier: $supplier, safetyStock: $safetyStock, currentConsumption: $currentConsumption)';
  }
}

/// @nodoc
abstract mixin class _$InventoryItemModelCopyWith<$Res>
    implements $InventoryItemModelCopyWith<$Res> {
  factory _$InventoryItemModelCopyWith(
          _InventoryItemModel value, $Res Function(_InventoryItemModel) _then) =
      __$InventoryItemModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? id,
      String appItemId,
      String sapCode,
      String name,
      String category,
      String subCategory,
      String unit,
      double quantity,
      double minimumQuantity,
      double reorderPoint,
      String location,
      DateTime lastUpdated,
      String? batchNumber,
      DateTime? expiryDate,
      Map<String, dynamic>? additionalAttributes,
      double? cost,
      int lowStockThreshold,
      String? supplier,
      double? safetyStock,
      double? currentConsumption});
}

/// @nodoc
class __$InventoryItemModelCopyWithImpl<$Res>
    implements _$InventoryItemModelCopyWith<$Res> {
  __$InventoryItemModelCopyWithImpl(this._self, this._then);

  final _InventoryItemModel _self;
  final $Res Function(_InventoryItemModel) _then;

  /// Create a copy of InventoryItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? appItemId = null,
    Object? sapCode = null,
    Object? name = null,
    Object? category = null,
    Object? subCategory = null,
    Object? unit = null,
    Object? quantity = null,
    Object? minimumQuantity = null,
    Object? reorderPoint = null,
    Object? location = null,
    Object? lastUpdated = null,
    Object? batchNumber = freezed,
    Object? expiryDate = freezed,
    Object? additionalAttributes = freezed,
    Object? cost = freezed,
    Object? lowStockThreshold = null,
    Object? supplier = freezed,
    Object? safetyStock = freezed,
    Object? currentConsumption = freezed,
  }) {
    return _then(_InventoryItemModel(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      appItemId: null == appItemId
          ? _self.appItemId
          : appItemId // ignore: cast_nullable_to_non_nullable
              as String,
      sapCode: null == sapCode
          ? _self.sapCode
          : sapCode // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      subCategory: null == subCategory
          ? _self.subCategory
          : subCategory // ignore: cast_nullable_to_non_nullable
              as String,
      unit: null == unit
          ? _self.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      minimumQuantity: null == minimumQuantity
          ? _self.minimumQuantity
          : minimumQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      reorderPoint: null == reorderPoint
          ? _self.reorderPoint
          : reorderPoint // ignore: cast_nullable_to_non_nullable
              as double,
      location: null == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdated: null == lastUpdated
          ? _self.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      batchNumber: freezed == batchNumber
          ? _self.batchNumber
          : batchNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      expiryDate: freezed == expiryDate
          ? _self.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      additionalAttributes: freezed == additionalAttributes
          ? _self._additionalAttributes
          : additionalAttributes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      cost: freezed == cost
          ? _self.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
      lowStockThreshold: null == lowStockThreshold
          ? _self.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as int,
      supplier: freezed == supplier
          ? _self.supplier
          : supplier // ignore: cast_nullable_to_non_nullable
              as String?,
      safetyStock: freezed == safetyStock
          ? _self.safetyStock
          : safetyStock // ignore: cast_nullable_to_non_nullable
              as double?,
      currentConsumption: freezed == currentConsumption
          ? _self.currentConsumption
          : currentConsumption // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

// dart format on
