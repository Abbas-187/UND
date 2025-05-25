// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'production_plan_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductionPlanItem {
  String get productId;
  String get productName;
  int get requiredQuantity;
  int get availableStock;
  int get productionQuantity;
  DateTime get deadline;

  /// Create a copy of ProductionPlanItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProductionPlanItemCopyWith<ProductionPlanItem> get copyWith =>
      _$ProductionPlanItemCopyWithImpl<ProductionPlanItem>(
          this as ProductionPlanItem, _$identity);

  /// Serializes this ProductionPlanItem to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProductionPlanItem &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.requiredQuantity, requiredQuantity) ||
                other.requiredQuantity == requiredQuantity) &&
            (identical(other.availableStock, availableStock) ||
                other.availableStock == availableStock) &&
            (identical(other.productionQuantity, productionQuantity) ||
                other.productionQuantity == productionQuantity) &&
            (identical(other.deadline, deadline) ||
                other.deadline == deadline));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, productId, productName,
      requiredQuantity, availableStock, productionQuantity, deadline);

  @override
  String toString() {
    return 'ProductionPlanItem(productId: $productId, productName: $productName, requiredQuantity: $requiredQuantity, availableStock: $availableStock, productionQuantity: $productionQuantity, deadline: $deadline)';
  }
}

/// @nodoc
abstract mixin class $ProductionPlanItemCopyWith<$Res> {
  factory $ProductionPlanItemCopyWith(
          ProductionPlanItem value, $Res Function(ProductionPlanItem) _then) =
      _$ProductionPlanItemCopyWithImpl;
  @useResult
  $Res call(
      {String productId,
      String productName,
      int requiredQuantity,
      int availableStock,
      int productionQuantity,
      DateTime deadline});
}

/// @nodoc
class _$ProductionPlanItemCopyWithImpl<$Res>
    implements $ProductionPlanItemCopyWith<$Res> {
  _$ProductionPlanItemCopyWithImpl(this._self, this._then);

  final ProductionPlanItem _self;
  final $Res Function(ProductionPlanItem) _then;

  /// Create a copy of ProductionPlanItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? requiredQuantity = null,
    Object? availableStock = null,
    Object? productionQuantity = null,
    Object? deadline = null,
  }) {
    return _then(_self.copyWith(
      productId: null == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _self.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      requiredQuantity: null == requiredQuantity
          ? _self.requiredQuantity
          : requiredQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      availableStock: null == availableStock
          ? _self.availableStock
          : availableStock // ignore: cast_nullable_to_non_nullable
              as int,
      productionQuantity: null == productionQuantity
          ? _self.productionQuantity
          : productionQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      deadline: null == deadline
          ? _self.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ProductionPlanItem implements ProductionPlanItem {
  const _ProductionPlanItem(
      {required this.productId,
      required this.productName,
      required this.requiredQuantity,
      required this.availableStock,
      required this.productionQuantity,
      required this.deadline});
  factory _ProductionPlanItem.fromJson(Map<String, dynamic> json) =>
      _$ProductionPlanItemFromJson(json);

  @override
  final String productId;
  @override
  final String productName;
  @override
  final int requiredQuantity;
  @override
  final int availableStock;
  @override
  final int productionQuantity;
  @override
  final DateTime deadline;

  /// Create a copy of ProductionPlanItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProductionPlanItemCopyWith<_ProductionPlanItem> get copyWith =>
      __$ProductionPlanItemCopyWithImpl<_ProductionPlanItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ProductionPlanItemToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProductionPlanItem &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.requiredQuantity, requiredQuantity) ||
                other.requiredQuantity == requiredQuantity) &&
            (identical(other.availableStock, availableStock) ||
                other.availableStock == availableStock) &&
            (identical(other.productionQuantity, productionQuantity) ||
                other.productionQuantity == productionQuantity) &&
            (identical(other.deadline, deadline) ||
                other.deadline == deadline));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, productId, productName,
      requiredQuantity, availableStock, productionQuantity, deadline);

  @override
  String toString() {
    return 'ProductionPlanItem(productId: $productId, productName: $productName, requiredQuantity: $requiredQuantity, availableStock: $availableStock, productionQuantity: $productionQuantity, deadline: $deadline)';
  }
}

/// @nodoc
abstract mixin class _$ProductionPlanItemCopyWith<$Res>
    implements $ProductionPlanItemCopyWith<$Res> {
  factory _$ProductionPlanItemCopyWith(
          _ProductionPlanItem value, $Res Function(_ProductionPlanItem) _then) =
      __$ProductionPlanItemCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String productId,
      String productName,
      int requiredQuantity,
      int availableStock,
      int productionQuantity,
      DateTime deadline});
}

/// @nodoc
class __$ProductionPlanItemCopyWithImpl<$Res>
    implements _$ProductionPlanItemCopyWith<$Res> {
  __$ProductionPlanItemCopyWithImpl(this._self, this._then);

  final _ProductionPlanItem _self;
  final $Res Function(_ProductionPlanItem) _then;

  /// Create a copy of ProductionPlanItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? requiredQuantity = null,
    Object? availableStock = null,
    Object? productionQuantity = null,
    Object? deadline = null,
  }) {
    return _then(_ProductionPlanItem(
      productId: null == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _self.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      requiredQuantity: null == requiredQuantity
          ? _self.requiredQuantity
          : requiredQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      availableStock: null == availableStock
          ? _self.availableStock
          : availableStock // ignore: cast_nullable_to_non_nullable
              as int,
      productionQuantity: null == productionQuantity
          ? _self.productionQuantity
          : productionQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      deadline: null == deadline
          ? _self.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
mixin _$ProductionPlan {
  String get id;
  DateTime get startDate;
  DateTime get endDate;
  List<ProductionPlanItem> get items;
  String get status;

  /// Create a copy of ProductionPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProductionPlanCopyWith<ProductionPlan> get copyWith =>
      _$ProductionPlanCopyWithImpl<ProductionPlan>(
          this as ProductionPlan, _$identity);

  /// Serializes this ProductionPlan to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProductionPlan &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            const DeepCollectionEquality().equals(other.items, items) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, startDate, endDate,
      const DeepCollectionEquality().hash(items), status);

  @override
  String toString() {
    return 'ProductionPlan(id: $id, startDate: $startDate, endDate: $endDate, items: $items, status: $status)';
  }
}

/// @nodoc
abstract mixin class $ProductionPlanCopyWith<$Res> {
  factory $ProductionPlanCopyWith(
          ProductionPlan value, $Res Function(ProductionPlan) _then) =
      _$ProductionPlanCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      DateTime startDate,
      DateTime endDate,
      List<ProductionPlanItem> items,
      String status});
}

/// @nodoc
class _$ProductionPlanCopyWithImpl<$Res>
    implements $ProductionPlanCopyWith<$Res> {
  _$ProductionPlanCopyWithImpl(this._self, this._then);

  final ProductionPlan _self;
  final $Res Function(ProductionPlan) _then;

  /// Create a copy of ProductionPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? items = null,
    Object? status = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _self.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _self.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      items: null == items
          ? _self.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ProductionPlanItem>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ProductionPlan implements ProductionPlan {
  const _ProductionPlan(
      {required this.id,
      required this.startDate,
      required this.endDate,
      required final List<ProductionPlanItem> items,
      required this.status})
      : _items = items;
  factory _ProductionPlan.fromJson(Map<String, dynamic> json) =>
      _$ProductionPlanFromJson(json);

  @override
  final String id;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  final List<ProductionPlanItem> _items;
  @override
  List<ProductionPlanItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String status;

  /// Create a copy of ProductionPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProductionPlanCopyWith<_ProductionPlan> get copyWith =>
      __$ProductionPlanCopyWithImpl<_ProductionPlan>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ProductionPlanToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProductionPlan &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, startDate, endDate,
      const DeepCollectionEquality().hash(_items), status);

  @override
  String toString() {
    return 'ProductionPlan(id: $id, startDate: $startDate, endDate: $endDate, items: $items, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$ProductionPlanCopyWith<$Res>
    implements $ProductionPlanCopyWith<$Res> {
  factory _$ProductionPlanCopyWith(
          _ProductionPlan value, $Res Function(_ProductionPlan) _then) =
      __$ProductionPlanCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime startDate,
      DateTime endDate,
      List<ProductionPlanItem> items,
      String status});
}

/// @nodoc
class __$ProductionPlanCopyWithImpl<$Res>
    implements _$ProductionPlanCopyWith<$Res> {
  __$ProductionPlanCopyWithImpl(this._self, this._then);

  final _ProductionPlan _self;
  final $Res Function(_ProductionPlan) _then;

  /// Create a copy of ProductionPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? items = null,
    Object? status = null,
  }) {
    return _then(_ProductionPlan(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _self.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _self.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      items: null == items
          ? _self._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ProductionPlanItem>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
