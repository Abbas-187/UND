// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Order {
  String get id;
  String get customerId;
  DateTime get date;
  double get totalAmount;
  String get status;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OrderCopyWith<Order> get copyWith =>
      _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Order &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, customerId, date, totalAmount, status);

  @override
  String toString() {
    return 'Order(id: $id, customerId: $customerId, date: $date, totalAmount: $totalAmount, status: $status)';
  }
}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res> {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) =
      _$OrderCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String customerId,
      DateTime date,
      double totalAmount,
      String status});
}

/// @nodoc
class _$OrderCopyWithImpl<$Res> implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? date = null,
    Object? totalAmount = null,
    Object? status = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalAmount: null == totalAmount
          ? _self.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Order extends Order {
  const _Order(
      {required this.id,
      required this.customerId,
      required this.date,
      required this.totalAmount,
      required this.status})
      : super._();
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  @override
  final String id;
  @override
  final String customerId;
  @override
  final DateTime date;
  @override
  final double totalAmount;
  @override
  final String status;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OrderCopyWith<_Order> get copyWith =>
      __$OrderCopyWithImpl<_Order>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$OrderToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Order &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, customerId, date, totalAmount, status);

  @override
  String toString() {
    return 'Order(id: $id, customerId: $customerId, date: $date, totalAmount: $totalAmount, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) =
      __$OrderCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String customerId,
      DateTime date,
      double totalAmount,
      String status});
}

/// @nodoc
class __$OrderCopyWithImpl<$Res> implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? date = null,
    Object? totalAmount = null,
    Object? status = null,
  }) {
    return _then(_Order(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalAmount: null == totalAmount
          ? _self.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
