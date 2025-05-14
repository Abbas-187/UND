// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'interaction_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InteractionLog {
  String get id;
  String get customerId;
  String get type; // e.g., 'call', 'email', 'meeting'
  DateTime get date;
  String get notes;

  /// Create a copy of InteractionLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InteractionLogCopyWith<InteractionLog> get copyWith =>
      _$InteractionLogCopyWithImpl<InteractionLog>(
          this as InteractionLog, _$identity);

  /// Serializes this InteractionLog to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InteractionLog &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, customerId, type, date, notes);

  @override
  String toString() {
    return 'InteractionLog(id: $id, customerId: $customerId, type: $type, date: $date, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class $InteractionLogCopyWith<$Res> {
  factory $InteractionLogCopyWith(
          InteractionLog value, $Res Function(InteractionLog) _then) =
      _$InteractionLogCopyWithImpl;
  @useResult
  $Res call(
      {String id, String customerId, String type, DateTime date, String notes});
}

/// @nodoc
class _$InteractionLogCopyWithImpl<$Res>
    implements $InteractionLogCopyWith<$Res> {
  _$InteractionLogCopyWithImpl(this._self, this._then);

  final InteractionLog _self;
  final $Res Function(InteractionLog) _then;

  /// Create a copy of InteractionLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? type = null,
    Object? date = null,
    Object? notes = null,
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
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: null == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _InteractionLog extends InteractionLog {
  const _InteractionLog(
      {required this.id,
      required this.customerId,
      required this.type,
      required this.date,
      required this.notes})
      : super._();
  factory _InteractionLog.fromJson(Map<String, dynamic> json) =>
      _$InteractionLogFromJson(json);

  @override
  final String id;
  @override
  final String customerId;
  @override
  final String type;
// e.g., 'call', 'email', 'meeting'
  @override
  final DateTime date;
  @override
  final String notes;

  /// Create a copy of InteractionLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InteractionLogCopyWith<_InteractionLog> get copyWith =>
      __$InteractionLogCopyWithImpl<_InteractionLog>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$InteractionLogToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InteractionLog &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, customerId, type, date, notes);

  @override
  String toString() {
    return 'InteractionLog(id: $id, customerId: $customerId, type: $type, date: $date, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class _$InteractionLogCopyWith<$Res>
    implements $InteractionLogCopyWith<$Res> {
  factory _$InteractionLogCopyWith(
          _InteractionLog value, $Res Function(_InteractionLog) _then) =
      __$InteractionLogCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id, String customerId, String type, DateTime date, String notes});
}

/// @nodoc
class __$InteractionLogCopyWithImpl<$Res>
    implements _$InteractionLogCopyWith<$Res> {
  __$InteractionLogCopyWithImpl(this._self, this._then);

  final _InteractionLog _self;
  final $Res Function(_InteractionLog) _then;

  /// Create a copy of InteractionLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? type = null,
    Object? date = null,
    Object? notes = null,
  }) {
    return _then(_InteractionLog(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: null == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
