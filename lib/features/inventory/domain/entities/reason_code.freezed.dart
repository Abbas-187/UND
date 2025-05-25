// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reason_code.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReasonCode {
  String get reasonCodeId;
  String get reasonCode;
  String? get description;
  String get appliesTo;

  /// Create a copy of ReasonCode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ReasonCodeCopyWith<ReasonCode> get copyWith =>
      _$ReasonCodeCopyWithImpl<ReasonCode>(this as ReasonCode, _$identity);

  /// Serializes this ReasonCode to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ReasonCode &&
            (identical(other.reasonCodeId, reasonCodeId) ||
                other.reasonCodeId == reasonCodeId) &&
            (identical(other.reasonCode, reasonCode) ||
                other.reasonCode == reasonCode) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.appliesTo, appliesTo) ||
                other.appliesTo == appliesTo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, reasonCodeId, reasonCode, description, appliesTo);

  @override
  String toString() {
    return 'ReasonCode(reasonCodeId: $reasonCodeId, reasonCode: $reasonCode, description: $description, appliesTo: $appliesTo)';
  }
}

/// @nodoc
abstract mixin class $ReasonCodeCopyWith<$Res> {
  factory $ReasonCodeCopyWith(
          ReasonCode value, $Res Function(ReasonCode) _then) =
      _$ReasonCodeCopyWithImpl;
  @useResult
  $Res call(
      {String reasonCodeId,
      String reasonCode,
      String? description,
      String appliesTo});
}

/// @nodoc
class _$ReasonCodeCopyWithImpl<$Res> implements $ReasonCodeCopyWith<$Res> {
  _$ReasonCodeCopyWithImpl(this._self, this._then);

  final ReasonCode _self;
  final $Res Function(ReasonCode) _then;

  /// Create a copy of ReasonCode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reasonCodeId = null,
    Object? reasonCode = null,
    Object? description = freezed,
    Object? appliesTo = null,
  }) {
    return _then(_self.copyWith(
      reasonCodeId: null == reasonCodeId
          ? _self.reasonCodeId
          : reasonCodeId // ignore: cast_nullable_to_non_nullable
              as String,
      reasonCode: null == reasonCode
          ? _self.reasonCode
          : reasonCode // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      appliesTo: null == appliesTo
          ? _self.appliesTo
          : appliesTo // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ReasonCode implements ReasonCode {
  const _ReasonCode(
      {required this.reasonCodeId,
      required this.reasonCode,
      this.description,
      required this.appliesTo});
  factory _ReasonCode.fromJson(Map<String, dynamic> json) =>
      _$ReasonCodeFromJson(json);

  @override
  final String reasonCodeId;
  @override
  final String reasonCode;
  @override
  final String? description;
  @override
  final String appliesTo;

  /// Create a copy of ReasonCode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReasonCodeCopyWith<_ReasonCode> get copyWith =>
      __$ReasonCodeCopyWithImpl<_ReasonCode>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ReasonCodeToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ReasonCode &&
            (identical(other.reasonCodeId, reasonCodeId) ||
                other.reasonCodeId == reasonCodeId) &&
            (identical(other.reasonCode, reasonCode) ||
                other.reasonCode == reasonCode) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.appliesTo, appliesTo) ||
                other.appliesTo == appliesTo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, reasonCodeId, reasonCode, description, appliesTo);

  @override
  String toString() {
    return 'ReasonCode(reasonCodeId: $reasonCodeId, reasonCode: $reasonCode, description: $description, appliesTo: $appliesTo)';
  }
}

/// @nodoc
abstract mixin class _$ReasonCodeCopyWith<$Res>
    implements $ReasonCodeCopyWith<$Res> {
  factory _$ReasonCodeCopyWith(
          _ReasonCode value, $Res Function(_ReasonCode) _then) =
      __$ReasonCodeCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String reasonCodeId,
      String reasonCode,
      String? description,
      String appliesTo});
}

/// @nodoc
class __$ReasonCodeCopyWithImpl<$Res> implements _$ReasonCodeCopyWith<$Res> {
  __$ReasonCodeCopyWithImpl(this._self, this._then);

  final _ReasonCode _self;
  final $Res Function(_ReasonCode) _then;

  /// Create a copy of ReasonCode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? reasonCodeId = null,
    Object? reasonCode = null,
    Object? description = freezed,
    Object? appliesTo = null,
  }) {
    return _then(_ReasonCode(
      reasonCodeId: null == reasonCodeId
          ? _self.reasonCodeId
          : reasonCodeId // ignore: cast_nullable_to_non_nullable
              as String,
      reasonCode: null == reasonCode
          ? _self.reasonCode
          : reasonCode // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      appliesTo: null == appliesTo
          ? _self.appliesTo
          : appliesTo // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
