// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'crm_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CrmReport {
  @JsonKey(name: 'total_customers')
  int get totalCustomers;
  @JsonKey(name: 'total_interactions')
  int get totalInteractions;
  @JsonKey(name: 'total_orders')
  int get totalOrders;

  /// Create a copy of CrmReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CrmReportCopyWith<CrmReport> get copyWith =>
      _$CrmReportCopyWithImpl<CrmReport>(this as CrmReport, _$identity);

  /// Serializes this CrmReport to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CrmReport &&
            (identical(other.totalCustomers, totalCustomers) ||
                other.totalCustomers == totalCustomers) &&
            (identical(other.totalInteractions, totalInteractions) ||
                other.totalInteractions == totalInteractions) &&
            (identical(other.totalOrders, totalOrders) ||
                other.totalOrders == totalOrders));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, totalCustomers, totalInteractions, totalOrders);

  @override
  String toString() {
    return 'CrmReport(totalCustomers: $totalCustomers, totalInteractions: $totalInteractions, totalOrders: $totalOrders)';
  }
}

/// @nodoc
abstract mixin class $CrmReportCopyWith<$Res> {
  factory $CrmReportCopyWith(CrmReport value, $Res Function(CrmReport) _then) =
      _$CrmReportCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'total_customers') int totalCustomers,
      @JsonKey(name: 'total_interactions') int totalInteractions,
      @JsonKey(name: 'total_orders') int totalOrders});
}

/// @nodoc
class _$CrmReportCopyWithImpl<$Res> implements $CrmReportCopyWith<$Res> {
  _$CrmReportCopyWithImpl(this._self, this._then);

  final CrmReport _self;
  final $Res Function(CrmReport) _then;

  /// Create a copy of CrmReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalCustomers = null,
    Object? totalInteractions = null,
    Object? totalOrders = null,
  }) {
    return _then(_self.copyWith(
      totalCustomers: null == totalCustomers
          ? _self.totalCustomers
          : totalCustomers // ignore: cast_nullable_to_non_nullable
              as int,
      totalInteractions: null == totalInteractions
          ? _self.totalInteractions
          : totalInteractions // ignore: cast_nullable_to_non_nullable
              as int,
      totalOrders: null == totalOrders
          ? _self.totalOrders
          : totalOrders // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _CrmReport implements CrmReport {
  const _CrmReport(
      {@JsonKey(name: 'total_customers') required this.totalCustomers,
      @JsonKey(name: 'total_interactions') required this.totalInteractions,
      @JsonKey(name: 'total_orders') required this.totalOrders});
  factory _CrmReport.fromJson(Map<String, dynamic> json) =>
      _$CrmReportFromJson(json);

  @override
  @JsonKey(name: 'total_customers')
  final int totalCustomers;
  @override
  @JsonKey(name: 'total_interactions')
  final int totalInteractions;
  @override
  @JsonKey(name: 'total_orders')
  final int totalOrders;

  /// Create a copy of CrmReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CrmReportCopyWith<_CrmReport> get copyWith =>
      __$CrmReportCopyWithImpl<_CrmReport>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CrmReportToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CrmReport &&
            (identical(other.totalCustomers, totalCustomers) ||
                other.totalCustomers == totalCustomers) &&
            (identical(other.totalInteractions, totalInteractions) ||
                other.totalInteractions == totalInteractions) &&
            (identical(other.totalOrders, totalOrders) ||
                other.totalOrders == totalOrders));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, totalCustomers, totalInteractions, totalOrders);

  @override
  String toString() {
    return 'CrmReport(totalCustomers: $totalCustomers, totalInteractions: $totalInteractions, totalOrders: $totalOrders)';
  }
}

/// @nodoc
abstract mixin class _$CrmReportCopyWith<$Res>
    implements $CrmReportCopyWith<$Res> {
  factory _$CrmReportCopyWith(
          _CrmReport value, $Res Function(_CrmReport) _then) =
      __$CrmReportCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'total_customers') int totalCustomers,
      @JsonKey(name: 'total_interactions') int totalInteractions,
      @JsonKey(name: 'total_orders') int totalOrders});
}

/// @nodoc
class __$CrmReportCopyWithImpl<$Res> implements _$CrmReportCopyWith<$Res> {
  __$CrmReportCopyWithImpl(this._self, this._then);

  final _CrmReport _self;
  final $Res Function(_CrmReport) _then;

  /// Create a copy of CrmReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? totalCustomers = null,
    Object? totalInteractions = null,
    Object? totalOrders = null,
  }) {
    return _then(_CrmReport(
      totalCustomers: null == totalCustomers
          ? _self.totalCustomers
          : totalCustomers // ignore: cast_nullable_to_non_nullable
              as int,
      totalInteractions: null == totalInteractions
          ? _self.totalInteractions
          : totalInteractions // ignore: cast_nullable_to_non_nullable
              as int,
      totalOrders: null == totalOrders
          ? _self.totalOrders
          : totalOrders // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
