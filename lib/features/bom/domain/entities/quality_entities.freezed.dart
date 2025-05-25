// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quality_entities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QualityScore {
  String get materialId;
  String get materialCode;
  String get materialName;
  double get overallScore;
  Map<String, double> get parameterScores;
  int get totalTests;
  int get passedTests;
  int get failedTests;
  int get defectCount;
  double get defectRate;
  DateTime get calculatedAt;
  String? get supplierId;
  String? get supplierName;
  Map<String, dynamic>? get qualityMetrics;

  /// Create a copy of QualityScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QualityScoreCopyWith<QualityScore> get copyWith =>
      _$QualityScoreCopyWithImpl<QualityScore>(
          this as QualityScore, _$identity);

  /// Serializes this QualityScore to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QualityScore &&
            (identical(other.materialId, materialId) ||
                other.materialId == materialId) &&
            (identical(other.materialCode, materialCode) ||
                other.materialCode == materialCode) &&
            (identical(other.materialName, materialName) ||
                other.materialName == materialName) &&
            (identical(other.overallScore, overallScore) ||
                other.overallScore == overallScore) &&
            const DeepCollectionEquality()
                .equals(other.parameterScores, parameterScores) &&
            (identical(other.totalTests, totalTests) ||
                other.totalTests == totalTests) &&
            (identical(other.passedTests, passedTests) ||
                other.passedTests == passedTests) &&
            (identical(other.failedTests, failedTests) ||
                other.failedTests == failedTests) &&
            (identical(other.defectCount, defectCount) ||
                other.defectCount == defectCount) &&
            (identical(other.defectRate, defectRate) ||
                other.defectRate == defectRate) &&
            (identical(other.calculatedAt, calculatedAt) ||
                other.calculatedAt == calculatedAt) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.supplierName, supplierName) ||
                other.supplierName == supplierName) &&
            const DeepCollectionEquality()
                .equals(other.qualityMetrics, qualityMetrics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      materialId,
      materialCode,
      materialName,
      overallScore,
      const DeepCollectionEquality().hash(parameterScores),
      totalTests,
      passedTests,
      failedTests,
      defectCount,
      defectRate,
      calculatedAt,
      supplierId,
      supplierName,
      const DeepCollectionEquality().hash(qualityMetrics));

  @override
  String toString() {
    return 'QualityScore(materialId: $materialId, materialCode: $materialCode, materialName: $materialName, overallScore: $overallScore, parameterScores: $parameterScores, totalTests: $totalTests, passedTests: $passedTests, failedTests: $failedTests, defectCount: $defectCount, defectRate: $defectRate, calculatedAt: $calculatedAt, supplierId: $supplierId, supplierName: $supplierName, qualityMetrics: $qualityMetrics)';
  }
}

/// @nodoc
abstract mixin class $QualityScoreCopyWith<$Res> {
  factory $QualityScoreCopyWith(
          QualityScore value, $Res Function(QualityScore) _then) =
      _$QualityScoreCopyWithImpl;
  @useResult
  $Res call(
      {String materialId,
      String materialCode,
      String materialName,
      double overallScore,
      Map<String, double> parameterScores,
      int totalTests,
      int passedTests,
      int failedTests,
      int defectCount,
      double defectRate,
      DateTime calculatedAt,
      String? supplierId,
      String? supplierName,
      Map<String, dynamic>? qualityMetrics});
}

/// @nodoc
class _$QualityScoreCopyWithImpl<$Res> implements $QualityScoreCopyWith<$Res> {
  _$QualityScoreCopyWithImpl(this._self, this._then);

  final QualityScore _self;
  final $Res Function(QualityScore) _then;

  /// Create a copy of QualityScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? materialId = null,
    Object? materialCode = null,
    Object? materialName = null,
    Object? overallScore = null,
    Object? parameterScores = null,
    Object? totalTests = null,
    Object? passedTests = null,
    Object? failedTests = null,
    Object? defectCount = null,
    Object? defectRate = null,
    Object? calculatedAt = null,
    Object? supplierId = freezed,
    Object? supplierName = freezed,
    Object? qualityMetrics = freezed,
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
      overallScore: null == overallScore
          ? _self.overallScore
          : overallScore // ignore: cast_nullable_to_non_nullable
              as double,
      parameterScores: null == parameterScores
          ? _self.parameterScores
          : parameterScores // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      totalTests: null == totalTests
          ? _self.totalTests
          : totalTests // ignore: cast_nullable_to_non_nullable
              as int,
      passedTests: null == passedTests
          ? _self.passedTests
          : passedTests // ignore: cast_nullable_to_non_nullable
              as int,
      failedTests: null == failedTests
          ? _self.failedTests
          : failedTests // ignore: cast_nullable_to_non_nullable
              as int,
      defectCount: null == defectCount
          ? _self.defectCount
          : defectCount // ignore: cast_nullable_to_non_nullable
              as int,
      defectRate: null == defectRate
          ? _self.defectRate
          : defectRate // ignore: cast_nullable_to_non_nullable
              as double,
      calculatedAt: null == calculatedAt
          ? _self.calculatedAt
          : calculatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      supplierId: freezed == supplierId
          ? _self.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierName: freezed == supplierName
          ? _self.supplierName
          : supplierName // ignore: cast_nullable_to_non_nullable
              as String?,
      qualityMetrics: freezed == qualityMetrics
          ? _self.qualityMetrics
          : qualityMetrics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _QualityScore extends QualityScore {
  const _QualityScore(
      {required this.materialId,
      required this.materialCode,
      required this.materialName,
      required this.overallScore,
      required final Map<String, double> parameterScores,
      required this.totalTests,
      required this.passedTests,
      required this.failedTests,
      this.defectCount = 0,
      this.defectRate = 0.0,
      required this.calculatedAt,
      this.supplierId,
      this.supplierName,
      final Map<String, dynamic>? qualityMetrics})
      : _parameterScores = parameterScores,
        _qualityMetrics = qualityMetrics,
        super._();
  factory _QualityScore.fromJson(Map<String, dynamic> json) =>
      _$QualityScoreFromJson(json);

  @override
  final String materialId;
  @override
  final String materialCode;
  @override
  final String materialName;
  @override
  final double overallScore;
  final Map<String, double> _parameterScores;
  @override
  Map<String, double> get parameterScores {
    if (_parameterScores is EqualUnmodifiableMapView) return _parameterScores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_parameterScores);
  }

  @override
  final int totalTests;
  @override
  final int passedTests;
  @override
  final int failedTests;
  @override
  @JsonKey()
  final int defectCount;
  @override
  @JsonKey()
  final double defectRate;
  @override
  final DateTime calculatedAt;
  @override
  final String? supplierId;
  @override
  final String? supplierName;
  final Map<String, dynamic>? _qualityMetrics;
  @override
  Map<String, dynamic>? get qualityMetrics {
    final value = _qualityMetrics;
    if (value == null) return null;
    if (_qualityMetrics is EqualUnmodifiableMapView) return _qualityMetrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of QualityScore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$QualityScoreCopyWith<_QualityScore> get copyWith =>
      __$QualityScoreCopyWithImpl<_QualityScore>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$QualityScoreToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _QualityScore &&
            (identical(other.materialId, materialId) ||
                other.materialId == materialId) &&
            (identical(other.materialCode, materialCode) ||
                other.materialCode == materialCode) &&
            (identical(other.materialName, materialName) ||
                other.materialName == materialName) &&
            (identical(other.overallScore, overallScore) ||
                other.overallScore == overallScore) &&
            const DeepCollectionEquality()
                .equals(other._parameterScores, _parameterScores) &&
            (identical(other.totalTests, totalTests) ||
                other.totalTests == totalTests) &&
            (identical(other.passedTests, passedTests) ||
                other.passedTests == passedTests) &&
            (identical(other.failedTests, failedTests) ||
                other.failedTests == failedTests) &&
            (identical(other.defectCount, defectCount) ||
                other.defectCount == defectCount) &&
            (identical(other.defectRate, defectRate) ||
                other.defectRate == defectRate) &&
            (identical(other.calculatedAt, calculatedAt) ||
                other.calculatedAt == calculatedAt) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.supplierName, supplierName) ||
                other.supplierName == supplierName) &&
            const DeepCollectionEquality()
                .equals(other._qualityMetrics, _qualityMetrics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      materialId,
      materialCode,
      materialName,
      overallScore,
      const DeepCollectionEquality().hash(_parameterScores),
      totalTests,
      passedTests,
      failedTests,
      defectCount,
      defectRate,
      calculatedAt,
      supplierId,
      supplierName,
      const DeepCollectionEquality().hash(_qualityMetrics));

  @override
  String toString() {
    return 'QualityScore(materialId: $materialId, materialCode: $materialCode, materialName: $materialName, overallScore: $overallScore, parameterScores: $parameterScores, totalTests: $totalTests, passedTests: $passedTests, failedTests: $failedTests, defectCount: $defectCount, defectRate: $defectRate, calculatedAt: $calculatedAt, supplierId: $supplierId, supplierName: $supplierName, qualityMetrics: $qualityMetrics)';
  }
}

/// @nodoc
abstract mixin class _$QualityScoreCopyWith<$Res>
    implements $QualityScoreCopyWith<$Res> {
  factory _$QualityScoreCopyWith(
          _QualityScore value, $Res Function(_QualityScore) _then) =
      __$QualityScoreCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String materialId,
      String materialCode,
      String materialName,
      double overallScore,
      Map<String, double> parameterScores,
      int totalTests,
      int passedTests,
      int failedTests,
      int defectCount,
      double defectRate,
      DateTime calculatedAt,
      String? supplierId,
      String? supplierName,
      Map<String, dynamic>? qualityMetrics});
}

/// @nodoc
class __$QualityScoreCopyWithImpl<$Res>
    implements _$QualityScoreCopyWith<$Res> {
  __$QualityScoreCopyWithImpl(this._self, this._then);

  final _QualityScore _self;
  final $Res Function(_QualityScore) _then;

  /// Create a copy of QualityScore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? materialId = null,
    Object? materialCode = null,
    Object? materialName = null,
    Object? overallScore = null,
    Object? parameterScores = null,
    Object? totalTests = null,
    Object? passedTests = null,
    Object? failedTests = null,
    Object? defectCount = null,
    Object? defectRate = null,
    Object? calculatedAt = null,
    Object? supplierId = freezed,
    Object? supplierName = freezed,
    Object? qualityMetrics = freezed,
  }) {
    return _then(_QualityScore(
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
      overallScore: null == overallScore
          ? _self.overallScore
          : overallScore // ignore: cast_nullable_to_non_nullable
              as double,
      parameterScores: null == parameterScores
          ? _self._parameterScores
          : parameterScores // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      totalTests: null == totalTests
          ? _self.totalTests
          : totalTests // ignore: cast_nullable_to_non_nullable
              as int,
      passedTests: null == passedTests
          ? _self.passedTests
          : passedTests // ignore: cast_nullable_to_non_nullable
              as int,
      failedTests: null == failedTests
          ? _self.failedTests
          : failedTests // ignore: cast_nullable_to_non_nullable
              as int,
      defectCount: null == defectCount
          ? _self.defectCount
          : defectCount // ignore: cast_nullable_to_non_nullable
              as int,
      defectRate: null == defectRate
          ? _self.defectRate
          : defectRate // ignore: cast_nullable_to_non_nullable
              as double,
      calculatedAt: null == calculatedAt
          ? _self.calculatedAt
          : calculatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      supplierId: freezed == supplierId
          ? _self.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierName: freezed == supplierName
          ? _self.supplierName
          : supplierName // ignore: cast_nullable_to_non_nullable
              as String?,
      qualityMetrics: freezed == qualityMetrics
          ? _self._qualityMetrics
          : qualityMetrics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
mixin _$QualityAlert {
  String get id;
  String get materialId;
  String get materialCode;
  String get alertType;
  String get severity;
  String get message;
  DateTime get alertDate;
  double get impactScore;
  String? get supplierId;
  String? get bomId;
  String? get recommendedAction;
  Map<String, dynamic>? get alertData;
  bool get isResolved;
  DateTime? get resolvedAt;
  String? get resolvedBy;
  String? get resolutionNotes;

  /// Create a copy of QualityAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QualityAlertCopyWith<QualityAlert> get copyWith =>
      _$QualityAlertCopyWithImpl<QualityAlert>(
          this as QualityAlert, _$identity);

  /// Serializes this QualityAlert to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QualityAlert &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.materialId, materialId) ||
                other.materialId == materialId) &&
            (identical(other.materialCode, materialCode) ||
                other.materialCode == materialCode) &&
            (identical(other.alertType, alertType) ||
                other.alertType == alertType) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.alertDate, alertDate) ||
                other.alertDate == alertDate) &&
            (identical(other.impactScore, impactScore) ||
                other.impactScore == impactScore) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.bomId, bomId) || other.bomId == bomId) &&
            (identical(other.recommendedAction, recommendedAction) ||
                other.recommendedAction == recommendedAction) &&
            const DeepCollectionEquality().equals(other.alertData, alertData) &&
            (identical(other.isResolved, isResolved) ||
                other.isResolved == isResolved) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy) &&
            (identical(other.resolutionNotes, resolutionNotes) ||
                other.resolutionNotes == resolutionNotes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      materialId,
      materialCode,
      alertType,
      severity,
      message,
      alertDate,
      impactScore,
      supplierId,
      bomId,
      recommendedAction,
      const DeepCollectionEquality().hash(alertData),
      isResolved,
      resolvedAt,
      resolvedBy,
      resolutionNotes);

  @override
  String toString() {
    return 'QualityAlert(id: $id, materialId: $materialId, materialCode: $materialCode, alertType: $alertType, severity: $severity, message: $message, alertDate: $alertDate, impactScore: $impactScore, supplierId: $supplierId, bomId: $bomId, recommendedAction: $recommendedAction, alertData: $alertData, isResolved: $isResolved, resolvedAt: $resolvedAt, resolvedBy: $resolvedBy, resolutionNotes: $resolutionNotes)';
  }
}

/// @nodoc
abstract mixin class $QualityAlertCopyWith<$Res> {
  factory $QualityAlertCopyWith(
          QualityAlert value, $Res Function(QualityAlert) _then) =
      _$QualityAlertCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String materialId,
      String materialCode,
      String alertType,
      String severity,
      String message,
      DateTime alertDate,
      double impactScore,
      String? supplierId,
      String? bomId,
      String? recommendedAction,
      Map<String, dynamic>? alertData,
      bool isResolved,
      DateTime? resolvedAt,
      String? resolvedBy,
      String? resolutionNotes});
}

/// @nodoc
class _$QualityAlertCopyWithImpl<$Res> implements $QualityAlertCopyWith<$Res> {
  _$QualityAlertCopyWithImpl(this._self, this._then);

  final QualityAlert _self;
  final $Res Function(QualityAlert) _then;

  /// Create a copy of QualityAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? materialId = null,
    Object? materialCode = null,
    Object? alertType = null,
    Object? severity = null,
    Object? message = null,
    Object? alertDate = null,
    Object? impactScore = null,
    Object? supplierId = freezed,
    Object? bomId = freezed,
    Object? recommendedAction = freezed,
    Object? alertData = freezed,
    Object? isResolved = null,
    Object? resolvedAt = freezed,
    Object? resolvedBy = freezed,
    Object? resolutionNotes = freezed,
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
      impactScore: null == impactScore
          ? _self.impactScore
          : impactScore // ignore: cast_nullable_to_non_nullable
              as double,
      supplierId: freezed == supplierId
          ? _self.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String?,
      bomId: freezed == bomId
          ? _self.bomId
          : bomId // ignore: cast_nullable_to_non_nullable
              as String?,
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
      resolutionNotes: freezed == resolutionNotes
          ? _self.resolutionNotes
          : resolutionNotes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _QualityAlert implements QualityAlert {
  const _QualityAlert(
      {required this.id,
      required this.materialId,
      required this.materialCode,
      required this.alertType,
      required this.severity,
      required this.message,
      required this.alertDate,
      required this.impactScore,
      this.supplierId,
      this.bomId,
      this.recommendedAction,
      final Map<String, dynamic>? alertData,
      this.isResolved = false,
      this.resolvedAt,
      this.resolvedBy,
      this.resolutionNotes})
      : _alertData = alertData;
  factory _QualityAlert.fromJson(Map<String, dynamic> json) =>
      _$QualityAlertFromJson(json);

  @override
  final String id;
  @override
  final String materialId;
  @override
  final String materialCode;
  @override
  final String alertType;
  @override
  final String severity;
  @override
  final String message;
  @override
  final DateTime alertDate;
  @override
  final double impactScore;
  @override
  final String? supplierId;
  @override
  final String? bomId;
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
  @override
  final String? resolutionNotes;

  /// Create a copy of QualityAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$QualityAlertCopyWith<_QualityAlert> get copyWith =>
      __$QualityAlertCopyWithImpl<_QualityAlert>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$QualityAlertToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _QualityAlert &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.materialId, materialId) ||
                other.materialId == materialId) &&
            (identical(other.materialCode, materialCode) ||
                other.materialCode == materialCode) &&
            (identical(other.alertType, alertType) ||
                other.alertType == alertType) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.alertDate, alertDate) ||
                other.alertDate == alertDate) &&
            (identical(other.impactScore, impactScore) ||
                other.impactScore == impactScore) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.bomId, bomId) || other.bomId == bomId) &&
            (identical(other.recommendedAction, recommendedAction) ||
                other.recommendedAction == recommendedAction) &&
            const DeepCollectionEquality()
                .equals(other._alertData, _alertData) &&
            (identical(other.isResolved, isResolved) ||
                other.isResolved == isResolved) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy) &&
            (identical(other.resolutionNotes, resolutionNotes) ||
                other.resolutionNotes == resolutionNotes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      materialId,
      materialCode,
      alertType,
      severity,
      message,
      alertDate,
      impactScore,
      supplierId,
      bomId,
      recommendedAction,
      const DeepCollectionEquality().hash(_alertData),
      isResolved,
      resolvedAt,
      resolvedBy,
      resolutionNotes);

  @override
  String toString() {
    return 'QualityAlert(id: $id, materialId: $materialId, materialCode: $materialCode, alertType: $alertType, severity: $severity, message: $message, alertDate: $alertDate, impactScore: $impactScore, supplierId: $supplierId, bomId: $bomId, recommendedAction: $recommendedAction, alertData: $alertData, isResolved: $isResolved, resolvedAt: $resolvedAt, resolvedBy: $resolvedBy, resolutionNotes: $resolutionNotes)';
  }
}

/// @nodoc
abstract mixin class _$QualityAlertCopyWith<$Res>
    implements $QualityAlertCopyWith<$Res> {
  factory _$QualityAlertCopyWith(
          _QualityAlert value, $Res Function(_QualityAlert) _then) =
      __$QualityAlertCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String materialId,
      String materialCode,
      String alertType,
      String severity,
      String message,
      DateTime alertDate,
      double impactScore,
      String? supplierId,
      String? bomId,
      String? recommendedAction,
      Map<String, dynamic>? alertData,
      bool isResolved,
      DateTime? resolvedAt,
      String? resolvedBy,
      String? resolutionNotes});
}

/// @nodoc
class __$QualityAlertCopyWithImpl<$Res>
    implements _$QualityAlertCopyWith<$Res> {
  __$QualityAlertCopyWithImpl(this._self, this._then);

  final _QualityAlert _self;
  final $Res Function(_QualityAlert) _then;

  /// Create a copy of QualityAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? materialId = null,
    Object? materialCode = null,
    Object? alertType = null,
    Object? severity = null,
    Object? message = null,
    Object? alertDate = null,
    Object? impactScore = null,
    Object? supplierId = freezed,
    Object? bomId = freezed,
    Object? recommendedAction = freezed,
    Object? alertData = freezed,
    Object? isResolved = null,
    Object? resolvedAt = freezed,
    Object? resolvedBy = freezed,
    Object? resolutionNotes = freezed,
  }) {
    return _then(_QualityAlert(
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
      impactScore: null == impactScore
          ? _self.impactScore
          : impactScore // ignore: cast_nullable_to_non_nullable
              as double,
      supplierId: freezed == supplierId
          ? _self.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String?,
      bomId: freezed == bomId
          ? _self.bomId
          : bomId // ignore: cast_nullable_to_non_nullable
              as String?,
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
      resolutionNotes: freezed == resolutionNotes
          ? _self.resolutionNotes
          : resolutionNotes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$QualityOptimization {
  String get id;
  String get bomId;
  String get optimizationType;
  String get description;
  double get expectedImprovement;
  double get implementationCost;
  int get implementationDays;
  String get priority;
  List<String> get affectedMaterials;
  Map<String, dynamic> get optimizationData;
  double get riskLevel;
  double get confidenceScore;
  DateTime get createdAt;
  String? get createdBy;

  /// Create a copy of QualityOptimization
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QualityOptimizationCopyWith<QualityOptimization> get copyWith =>
      _$QualityOptimizationCopyWithImpl<QualityOptimization>(
          this as QualityOptimization, _$identity);

  /// Serializes this QualityOptimization to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QualityOptimization &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bomId, bomId) || other.bomId == bomId) &&
            (identical(other.optimizationType, optimizationType) ||
                other.optimizationType == optimizationType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.expectedImprovement, expectedImprovement) ||
                other.expectedImprovement == expectedImprovement) &&
            (identical(other.implementationCost, implementationCost) ||
                other.implementationCost == implementationCost) &&
            (identical(other.implementationDays, implementationDays) ||
                other.implementationDays == implementationDays) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            const DeepCollectionEquality()
                .equals(other.affectedMaterials, affectedMaterials) &&
            const DeepCollectionEquality()
                .equals(other.optimizationData, optimizationData) &&
            (identical(other.riskLevel, riskLevel) ||
                other.riskLevel == riskLevel) &&
            (identical(other.confidenceScore, confidenceScore) ||
                other.confidenceScore == confidenceScore) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      bomId,
      optimizationType,
      description,
      expectedImprovement,
      implementationCost,
      implementationDays,
      priority,
      const DeepCollectionEquality().hash(affectedMaterials),
      const DeepCollectionEquality().hash(optimizationData),
      riskLevel,
      confidenceScore,
      createdAt,
      createdBy);

  @override
  String toString() {
    return 'QualityOptimization(id: $id, bomId: $bomId, optimizationType: $optimizationType, description: $description, expectedImprovement: $expectedImprovement, implementationCost: $implementationCost, implementationDays: $implementationDays, priority: $priority, affectedMaterials: $affectedMaterials, optimizationData: $optimizationData, riskLevel: $riskLevel, confidenceScore: $confidenceScore, createdAt: $createdAt, createdBy: $createdBy)';
  }
}

/// @nodoc
abstract mixin class $QualityOptimizationCopyWith<$Res> {
  factory $QualityOptimizationCopyWith(
          QualityOptimization value, $Res Function(QualityOptimization) _then) =
      _$QualityOptimizationCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String bomId,
      String optimizationType,
      String description,
      double expectedImprovement,
      double implementationCost,
      int implementationDays,
      String priority,
      List<String> affectedMaterials,
      Map<String, dynamic> optimizationData,
      double riskLevel,
      double confidenceScore,
      DateTime createdAt,
      String? createdBy});
}

/// @nodoc
class _$QualityOptimizationCopyWithImpl<$Res>
    implements $QualityOptimizationCopyWith<$Res> {
  _$QualityOptimizationCopyWithImpl(this._self, this._then);

  final QualityOptimization _self;
  final $Res Function(QualityOptimization) _then;

  /// Create a copy of QualityOptimization
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bomId = null,
    Object? optimizationType = null,
    Object? description = null,
    Object? expectedImprovement = null,
    Object? implementationCost = null,
    Object? implementationDays = null,
    Object? priority = null,
    Object? affectedMaterials = null,
    Object? optimizationData = null,
    Object? riskLevel = null,
    Object? confidenceScore = null,
    Object? createdAt = null,
    Object? createdBy = freezed,
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
      optimizationType: null == optimizationType
          ? _self.optimizationType
          : optimizationType // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      expectedImprovement: null == expectedImprovement
          ? _self.expectedImprovement
          : expectedImprovement // ignore: cast_nullable_to_non_nullable
              as double,
      implementationCost: null == implementationCost
          ? _self.implementationCost
          : implementationCost // ignore: cast_nullable_to_non_nullable
              as double,
      implementationDays: null == implementationDays
          ? _self.implementationDays
          : implementationDays // ignore: cast_nullable_to_non_nullable
              as int,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      affectedMaterials: null == affectedMaterials
          ? _self.affectedMaterials
          : affectedMaterials // ignore: cast_nullable_to_non_nullable
              as List<String>,
      optimizationData: null == optimizationData
          ? _self.optimizationData
          : optimizationData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      riskLevel: null == riskLevel
          ? _self.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as double,
      confidenceScore: null == confidenceScore
          ? _self.confidenceScore
          : confidenceScore // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdBy: freezed == createdBy
          ? _self.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _QualityOptimization extends QualityOptimization {
  const _QualityOptimization(
      {required this.id,
      required this.bomId,
      required this.optimizationType,
      required this.description,
      required this.expectedImprovement,
      required this.implementationCost,
      required this.implementationDays,
      required this.priority,
      required final List<String> affectedMaterials,
      required final Map<String, dynamic> optimizationData,
      this.riskLevel = 0.0,
      this.confidenceScore = 0.0,
      required this.createdAt,
      this.createdBy})
      : _affectedMaterials = affectedMaterials,
        _optimizationData = optimizationData,
        super._();
  factory _QualityOptimization.fromJson(Map<String, dynamic> json) =>
      _$QualityOptimizationFromJson(json);

  @override
  final String id;
  @override
  final String bomId;
  @override
  final String optimizationType;
  @override
  final String description;
  @override
  final double expectedImprovement;
  @override
  final double implementationCost;
  @override
  final int implementationDays;
  @override
  final String priority;
  final List<String> _affectedMaterials;
  @override
  List<String> get affectedMaterials {
    if (_affectedMaterials is EqualUnmodifiableListView)
      return _affectedMaterials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_affectedMaterials);
  }

  final Map<String, dynamic> _optimizationData;
  @override
  Map<String, dynamic> get optimizationData {
    if (_optimizationData is EqualUnmodifiableMapView) return _optimizationData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_optimizationData);
  }

  @override
  @JsonKey()
  final double riskLevel;
  @override
  @JsonKey()
  final double confidenceScore;
  @override
  final DateTime createdAt;
  @override
  final String? createdBy;

  /// Create a copy of QualityOptimization
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$QualityOptimizationCopyWith<_QualityOptimization> get copyWith =>
      __$QualityOptimizationCopyWithImpl<_QualityOptimization>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$QualityOptimizationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _QualityOptimization &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bomId, bomId) || other.bomId == bomId) &&
            (identical(other.optimizationType, optimizationType) ||
                other.optimizationType == optimizationType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.expectedImprovement, expectedImprovement) ||
                other.expectedImprovement == expectedImprovement) &&
            (identical(other.implementationCost, implementationCost) ||
                other.implementationCost == implementationCost) &&
            (identical(other.implementationDays, implementationDays) ||
                other.implementationDays == implementationDays) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            const DeepCollectionEquality()
                .equals(other._affectedMaterials, _affectedMaterials) &&
            const DeepCollectionEquality()
                .equals(other._optimizationData, _optimizationData) &&
            (identical(other.riskLevel, riskLevel) ||
                other.riskLevel == riskLevel) &&
            (identical(other.confidenceScore, confidenceScore) ||
                other.confidenceScore == confidenceScore) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      bomId,
      optimizationType,
      description,
      expectedImprovement,
      implementationCost,
      implementationDays,
      priority,
      const DeepCollectionEquality().hash(_affectedMaterials),
      const DeepCollectionEquality().hash(_optimizationData),
      riskLevel,
      confidenceScore,
      createdAt,
      createdBy);

  @override
  String toString() {
    return 'QualityOptimization(id: $id, bomId: $bomId, optimizationType: $optimizationType, description: $description, expectedImprovement: $expectedImprovement, implementationCost: $implementationCost, implementationDays: $implementationDays, priority: $priority, affectedMaterials: $affectedMaterials, optimizationData: $optimizationData, riskLevel: $riskLevel, confidenceScore: $confidenceScore, createdAt: $createdAt, createdBy: $createdBy)';
  }
}

/// @nodoc
abstract mixin class _$QualityOptimizationCopyWith<$Res>
    implements $QualityOptimizationCopyWith<$Res> {
  factory _$QualityOptimizationCopyWith(_QualityOptimization value,
          $Res Function(_QualityOptimization) _then) =
      __$QualityOptimizationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String bomId,
      String optimizationType,
      String description,
      double expectedImprovement,
      double implementationCost,
      int implementationDays,
      String priority,
      List<String> affectedMaterials,
      Map<String, dynamic> optimizationData,
      double riskLevel,
      double confidenceScore,
      DateTime createdAt,
      String? createdBy});
}

/// @nodoc
class __$QualityOptimizationCopyWithImpl<$Res>
    implements _$QualityOptimizationCopyWith<$Res> {
  __$QualityOptimizationCopyWithImpl(this._self, this._then);

  final _QualityOptimization _self;
  final $Res Function(_QualityOptimization) _then;

  /// Create a copy of QualityOptimization
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? bomId = null,
    Object? optimizationType = null,
    Object? description = null,
    Object? expectedImprovement = null,
    Object? implementationCost = null,
    Object? implementationDays = null,
    Object? priority = null,
    Object? affectedMaterials = null,
    Object? optimizationData = null,
    Object? riskLevel = null,
    Object? confidenceScore = null,
    Object? createdAt = null,
    Object? createdBy = freezed,
  }) {
    return _then(_QualityOptimization(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      bomId: null == bomId
          ? _self.bomId
          : bomId // ignore: cast_nullable_to_non_nullable
              as String,
      optimizationType: null == optimizationType
          ? _self.optimizationType
          : optimizationType // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      expectedImprovement: null == expectedImprovement
          ? _self.expectedImprovement
          : expectedImprovement // ignore: cast_nullable_to_non_nullable
              as double,
      implementationCost: null == implementationCost
          ? _self.implementationCost
          : implementationCost // ignore: cast_nullable_to_non_nullable
              as double,
      implementationDays: null == implementationDays
          ? _self.implementationDays
          : implementationDays // ignore: cast_nullable_to_non_nullable
              as int,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      affectedMaterials: null == affectedMaterials
          ? _self._affectedMaterials
          : affectedMaterials // ignore: cast_nullable_to_non_nullable
              as List<String>,
      optimizationData: null == optimizationData
          ? _self._optimizationData
          : optimizationData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      riskLevel: null == riskLevel
          ? _self.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as double,
      confidenceScore: null == confidenceScore
          ? _self.confidenceScore
          : confidenceScore // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdBy: freezed == createdBy
          ? _self.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$QualityImpactAnalysis {
  String get bomId;
  double get overallQualityScore;
  Map<String, QualityScore> get materialQualityScores;
  List<QualityAlert> get qualityRisks;
  List<String> get criticalMaterials;
  Map<String, double> get supplierQualityScores;
  double get qualityCostImpact;
  double get defectProbability;
  DateTime get analysisDate;
  Map<String, dynamic>? get analysisMetrics;

  /// Create a copy of QualityImpactAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QualityImpactAnalysisCopyWith<QualityImpactAnalysis> get copyWith =>
      _$QualityImpactAnalysisCopyWithImpl<QualityImpactAnalysis>(
          this as QualityImpactAnalysis, _$identity);

  /// Serializes this QualityImpactAnalysis to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QualityImpactAnalysis &&
            (identical(other.bomId, bomId) || other.bomId == bomId) &&
            (identical(other.overallQualityScore, overallQualityScore) ||
                other.overallQualityScore == overallQualityScore) &&
            const DeepCollectionEquality()
                .equals(other.materialQualityScores, materialQualityScores) &&
            const DeepCollectionEquality()
                .equals(other.qualityRisks, qualityRisks) &&
            const DeepCollectionEquality()
                .equals(other.criticalMaterials, criticalMaterials) &&
            const DeepCollectionEquality()
                .equals(other.supplierQualityScores, supplierQualityScores) &&
            (identical(other.qualityCostImpact, qualityCostImpact) ||
                other.qualityCostImpact == qualityCostImpact) &&
            (identical(other.defectProbability, defectProbability) ||
                other.defectProbability == defectProbability) &&
            (identical(other.analysisDate, analysisDate) ||
                other.analysisDate == analysisDate) &&
            const DeepCollectionEquality()
                .equals(other.analysisMetrics, analysisMetrics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      bomId,
      overallQualityScore,
      const DeepCollectionEquality().hash(materialQualityScores),
      const DeepCollectionEquality().hash(qualityRisks),
      const DeepCollectionEquality().hash(criticalMaterials),
      const DeepCollectionEquality().hash(supplierQualityScores),
      qualityCostImpact,
      defectProbability,
      analysisDate,
      const DeepCollectionEquality().hash(analysisMetrics));

  @override
  String toString() {
    return 'QualityImpactAnalysis(bomId: $bomId, overallQualityScore: $overallQualityScore, materialQualityScores: $materialQualityScores, qualityRisks: $qualityRisks, criticalMaterials: $criticalMaterials, supplierQualityScores: $supplierQualityScores, qualityCostImpact: $qualityCostImpact, defectProbability: $defectProbability, analysisDate: $analysisDate, analysisMetrics: $analysisMetrics)';
  }
}

/// @nodoc
abstract mixin class $QualityImpactAnalysisCopyWith<$Res> {
  factory $QualityImpactAnalysisCopyWith(QualityImpactAnalysis value,
          $Res Function(QualityImpactAnalysis) _then) =
      _$QualityImpactAnalysisCopyWithImpl;
  @useResult
  $Res call(
      {String bomId,
      double overallQualityScore,
      Map<String, QualityScore> materialQualityScores,
      List<QualityAlert> qualityRisks,
      List<String> criticalMaterials,
      Map<String, double> supplierQualityScores,
      double qualityCostImpact,
      double defectProbability,
      DateTime analysisDate,
      Map<String, dynamic>? analysisMetrics});
}

/// @nodoc
class _$QualityImpactAnalysisCopyWithImpl<$Res>
    implements $QualityImpactAnalysisCopyWith<$Res> {
  _$QualityImpactAnalysisCopyWithImpl(this._self, this._then);

  final QualityImpactAnalysis _self;
  final $Res Function(QualityImpactAnalysis) _then;

  /// Create a copy of QualityImpactAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bomId = null,
    Object? overallQualityScore = null,
    Object? materialQualityScores = null,
    Object? qualityRisks = null,
    Object? criticalMaterials = null,
    Object? supplierQualityScores = null,
    Object? qualityCostImpact = null,
    Object? defectProbability = null,
    Object? analysisDate = null,
    Object? analysisMetrics = freezed,
  }) {
    return _then(_self.copyWith(
      bomId: null == bomId
          ? _self.bomId
          : bomId // ignore: cast_nullable_to_non_nullable
              as String,
      overallQualityScore: null == overallQualityScore
          ? _self.overallQualityScore
          : overallQualityScore // ignore: cast_nullable_to_non_nullable
              as double,
      materialQualityScores: null == materialQualityScores
          ? _self.materialQualityScores
          : materialQualityScores // ignore: cast_nullable_to_non_nullable
              as Map<String, QualityScore>,
      qualityRisks: null == qualityRisks
          ? _self.qualityRisks
          : qualityRisks // ignore: cast_nullable_to_non_nullable
              as List<QualityAlert>,
      criticalMaterials: null == criticalMaterials
          ? _self.criticalMaterials
          : criticalMaterials // ignore: cast_nullable_to_non_nullable
              as List<String>,
      supplierQualityScores: null == supplierQualityScores
          ? _self.supplierQualityScores
          : supplierQualityScores // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      qualityCostImpact: null == qualityCostImpact
          ? _self.qualityCostImpact
          : qualityCostImpact // ignore: cast_nullable_to_non_nullable
              as double,
      defectProbability: null == defectProbability
          ? _self.defectProbability
          : defectProbability // ignore: cast_nullable_to_non_nullable
              as double,
      analysisDate: null == analysisDate
          ? _self.analysisDate
          : analysisDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      analysisMetrics: freezed == analysisMetrics
          ? _self.analysisMetrics
          : analysisMetrics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _QualityImpactAnalysis extends QualityImpactAnalysis {
  const _QualityImpactAnalysis(
      {required this.bomId,
      required this.overallQualityScore,
      required final Map<String, QualityScore> materialQualityScores,
      required final List<QualityAlert> qualityRisks,
      required final List<String> criticalMaterials,
      required final Map<String, double> supplierQualityScores,
      this.qualityCostImpact = 0.0,
      this.defectProbability = 0.0,
      required this.analysisDate,
      final Map<String, dynamic>? analysisMetrics})
      : _materialQualityScores = materialQualityScores,
        _qualityRisks = qualityRisks,
        _criticalMaterials = criticalMaterials,
        _supplierQualityScores = supplierQualityScores,
        _analysisMetrics = analysisMetrics,
        super._();
  factory _QualityImpactAnalysis.fromJson(Map<String, dynamic> json) =>
      _$QualityImpactAnalysisFromJson(json);

  @override
  final String bomId;
  @override
  final double overallQualityScore;
  final Map<String, QualityScore> _materialQualityScores;
  @override
  Map<String, QualityScore> get materialQualityScores {
    if (_materialQualityScores is EqualUnmodifiableMapView)
      return _materialQualityScores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_materialQualityScores);
  }

  final List<QualityAlert> _qualityRisks;
  @override
  List<QualityAlert> get qualityRisks {
    if (_qualityRisks is EqualUnmodifiableListView) return _qualityRisks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_qualityRisks);
  }

  final List<String> _criticalMaterials;
  @override
  List<String> get criticalMaterials {
    if (_criticalMaterials is EqualUnmodifiableListView)
      return _criticalMaterials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_criticalMaterials);
  }

  final Map<String, double> _supplierQualityScores;
  @override
  Map<String, double> get supplierQualityScores {
    if (_supplierQualityScores is EqualUnmodifiableMapView)
      return _supplierQualityScores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_supplierQualityScores);
  }

  @override
  @JsonKey()
  final double qualityCostImpact;
  @override
  @JsonKey()
  final double defectProbability;
  @override
  final DateTime analysisDate;
  final Map<String, dynamic>? _analysisMetrics;
  @override
  Map<String, dynamic>? get analysisMetrics {
    final value = _analysisMetrics;
    if (value == null) return null;
    if (_analysisMetrics is EqualUnmodifiableMapView) return _analysisMetrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of QualityImpactAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$QualityImpactAnalysisCopyWith<_QualityImpactAnalysis> get copyWith =>
      __$QualityImpactAnalysisCopyWithImpl<_QualityImpactAnalysis>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$QualityImpactAnalysisToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _QualityImpactAnalysis &&
            (identical(other.bomId, bomId) || other.bomId == bomId) &&
            (identical(other.overallQualityScore, overallQualityScore) ||
                other.overallQualityScore == overallQualityScore) &&
            const DeepCollectionEquality()
                .equals(other._materialQualityScores, _materialQualityScores) &&
            const DeepCollectionEquality()
                .equals(other._qualityRisks, _qualityRisks) &&
            const DeepCollectionEquality()
                .equals(other._criticalMaterials, _criticalMaterials) &&
            const DeepCollectionEquality()
                .equals(other._supplierQualityScores, _supplierQualityScores) &&
            (identical(other.qualityCostImpact, qualityCostImpact) ||
                other.qualityCostImpact == qualityCostImpact) &&
            (identical(other.defectProbability, defectProbability) ||
                other.defectProbability == defectProbability) &&
            (identical(other.analysisDate, analysisDate) ||
                other.analysisDate == analysisDate) &&
            const DeepCollectionEquality()
                .equals(other._analysisMetrics, _analysisMetrics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      bomId,
      overallQualityScore,
      const DeepCollectionEquality().hash(_materialQualityScores),
      const DeepCollectionEquality().hash(_qualityRisks),
      const DeepCollectionEquality().hash(_criticalMaterials),
      const DeepCollectionEquality().hash(_supplierQualityScores),
      qualityCostImpact,
      defectProbability,
      analysisDate,
      const DeepCollectionEquality().hash(_analysisMetrics));

  @override
  String toString() {
    return 'QualityImpactAnalysis(bomId: $bomId, overallQualityScore: $overallQualityScore, materialQualityScores: $materialQualityScores, qualityRisks: $qualityRisks, criticalMaterials: $criticalMaterials, supplierQualityScores: $supplierQualityScores, qualityCostImpact: $qualityCostImpact, defectProbability: $defectProbability, analysisDate: $analysisDate, analysisMetrics: $analysisMetrics)';
  }
}

/// @nodoc
abstract mixin class _$QualityImpactAnalysisCopyWith<$Res>
    implements $QualityImpactAnalysisCopyWith<$Res> {
  factory _$QualityImpactAnalysisCopyWith(_QualityImpactAnalysis value,
          $Res Function(_QualityImpactAnalysis) _then) =
      __$QualityImpactAnalysisCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String bomId,
      double overallQualityScore,
      Map<String, QualityScore> materialQualityScores,
      List<QualityAlert> qualityRisks,
      List<String> criticalMaterials,
      Map<String, double> supplierQualityScores,
      double qualityCostImpact,
      double defectProbability,
      DateTime analysisDate,
      Map<String, dynamic>? analysisMetrics});
}

/// @nodoc
class __$QualityImpactAnalysisCopyWithImpl<$Res>
    implements _$QualityImpactAnalysisCopyWith<$Res> {
  __$QualityImpactAnalysisCopyWithImpl(this._self, this._then);

  final _QualityImpactAnalysis _self;
  final $Res Function(_QualityImpactAnalysis) _then;

  /// Create a copy of QualityImpactAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? bomId = null,
    Object? overallQualityScore = null,
    Object? materialQualityScores = null,
    Object? qualityRisks = null,
    Object? criticalMaterials = null,
    Object? supplierQualityScores = null,
    Object? qualityCostImpact = null,
    Object? defectProbability = null,
    Object? analysisDate = null,
    Object? analysisMetrics = freezed,
  }) {
    return _then(_QualityImpactAnalysis(
      bomId: null == bomId
          ? _self.bomId
          : bomId // ignore: cast_nullable_to_non_nullable
              as String,
      overallQualityScore: null == overallQualityScore
          ? _self.overallQualityScore
          : overallQualityScore // ignore: cast_nullable_to_non_nullable
              as double,
      materialQualityScores: null == materialQualityScores
          ? _self._materialQualityScores
          : materialQualityScores // ignore: cast_nullable_to_non_nullable
              as Map<String, QualityScore>,
      qualityRisks: null == qualityRisks
          ? _self._qualityRisks
          : qualityRisks // ignore: cast_nullable_to_non_nullable
              as List<QualityAlert>,
      criticalMaterials: null == criticalMaterials
          ? _self._criticalMaterials
          : criticalMaterials // ignore: cast_nullable_to_non_nullable
              as List<String>,
      supplierQualityScores: null == supplierQualityScores
          ? _self._supplierQualityScores
          : supplierQualityScores // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      qualityCostImpact: null == qualityCostImpact
          ? _self.qualityCostImpact
          : qualityCostImpact // ignore: cast_nullable_to_non_nullable
              as double,
      defectProbability: null == defectProbability
          ? _self.defectProbability
          : defectProbability // ignore: cast_nullable_to_non_nullable
              as double,
      analysisDate: null == analysisDate
          ? _self.analysisDate
          : analysisDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      analysisMetrics: freezed == analysisMetrics
          ? _self._analysisMetrics
          : analysisMetrics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
mixin _$SupplierQualityPerformance {
  String get supplierId;
  String get supplierName;
  double get overallQualityScore;
  Map<String, double> get materialQualityScores;
  int get totalDeliveries;
  int get qualityIssues;
  double get defectRate;
  double get onTimeDeliveryRate;
  List<QualityAlert> get recentIssues;
  double get improvementTrend;
  String get performanceTrend;
  DateTime get lastEvaluationDate;
  Map<String, dynamic>? get performanceMetrics;

  /// Create a copy of SupplierQualityPerformance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SupplierQualityPerformanceCopyWith<SupplierQualityPerformance>
      get copyWith =>
          _$SupplierQualityPerformanceCopyWithImpl<SupplierQualityPerformance>(
              this as SupplierQualityPerformance, _$identity);

  /// Serializes this SupplierQualityPerformance to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SupplierQualityPerformance &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.supplierName, supplierName) ||
                other.supplierName == supplierName) &&
            (identical(other.overallQualityScore, overallQualityScore) ||
                other.overallQualityScore == overallQualityScore) &&
            const DeepCollectionEquality()
                .equals(other.materialQualityScores, materialQualityScores) &&
            (identical(other.totalDeliveries, totalDeliveries) ||
                other.totalDeliveries == totalDeliveries) &&
            (identical(other.qualityIssues, qualityIssues) ||
                other.qualityIssues == qualityIssues) &&
            (identical(other.defectRate, defectRate) ||
                other.defectRate == defectRate) &&
            (identical(other.onTimeDeliveryRate, onTimeDeliveryRate) ||
                other.onTimeDeliveryRate == onTimeDeliveryRate) &&
            const DeepCollectionEquality()
                .equals(other.recentIssues, recentIssues) &&
            (identical(other.improvementTrend, improvementTrend) ||
                other.improvementTrend == improvementTrend) &&
            (identical(other.performanceTrend, performanceTrend) ||
                other.performanceTrend == performanceTrend) &&
            (identical(other.lastEvaluationDate, lastEvaluationDate) ||
                other.lastEvaluationDate == lastEvaluationDate) &&
            const DeepCollectionEquality()
                .equals(other.performanceMetrics, performanceMetrics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      supplierId,
      supplierName,
      overallQualityScore,
      const DeepCollectionEquality().hash(materialQualityScores),
      totalDeliveries,
      qualityIssues,
      defectRate,
      onTimeDeliveryRate,
      const DeepCollectionEquality().hash(recentIssues),
      improvementTrend,
      performanceTrend,
      lastEvaluationDate,
      const DeepCollectionEquality().hash(performanceMetrics));

  @override
  String toString() {
    return 'SupplierQualityPerformance(supplierId: $supplierId, supplierName: $supplierName, overallQualityScore: $overallQualityScore, materialQualityScores: $materialQualityScores, totalDeliveries: $totalDeliveries, qualityIssues: $qualityIssues, defectRate: $defectRate, onTimeDeliveryRate: $onTimeDeliveryRate, recentIssues: $recentIssues, improvementTrend: $improvementTrend, performanceTrend: $performanceTrend, lastEvaluationDate: $lastEvaluationDate, performanceMetrics: $performanceMetrics)';
  }
}

/// @nodoc
abstract mixin class $SupplierQualityPerformanceCopyWith<$Res> {
  factory $SupplierQualityPerformanceCopyWith(SupplierQualityPerformance value,
          $Res Function(SupplierQualityPerformance) _then) =
      _$SupplierQualityPerformanceCopyWithImpl;
  @useResult
  $Res call(
      {String supplierId,
      String supplierName,
      double overallQualityScore,
      Map<String, double> materialQualityScores,
      int totalDeliveries,
      int qualityIssues,
      double defectRate,
      double onTimeDeliveryRate,
      List<QualityAlert> recentIssues,
      double improvementTrend,
      String performanceTrend,
      DateTime lastEvaluationDate,
      Map<String, dynamic>? performanceMetrics});
}

/// @nodoc
class _$SupplierQualityPerformanceCopyWithImpl<$Res>
    implements $SupplierQualityPerformanceCopyWith<$Res> {
  _$SupplierQualityPerformanceCopyWithImpl(this._self, this._then);

  final SupplierQualityPerformance _self;
  final $Res Function(SupplierQualityPerformance) _then;

  /// Create a copy of SupplierQualityPerformance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? supplierId = null,
    Object? supplierName = null,
    Object? overallQualityScore = null,
    Object? materialQualityScores = null,
    Object? totalDeliveries = null,
    Object? qualityIssues = null,
    Object? defectRate = null,
    Object? onTimeDeliveryRate = null,
    Object? recentIssues = null,
    Object? improvementTrend = null,
    Object? performanceTrend = null,
    Object? lastEvaluationDate = null,
    Object? performanceMetrics = freezed,
  }) {
    return _then(_self.copyWith(
      supplierId: null == supplierId
          ? _self.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      supplierName: null == supplierName
          ? _self.supplierName
          : supplierName // ignore: cast_nullable_to_non_nullable
              as String,
      overallQualityScore: null == overallQualityScore
          ? _self.overallQualityScore
          : overallQualityScore // ignore: cast_nullable_to_non_nullable
              as double,
      materialQualityScores: null == materialQualityScores
          ? _self.materialQualityScores
          : materialQualityScores // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      totalDeliveries: null == totalDeliveries
          ? _self.totalDeliveries
          : totalDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      qualityIssues: null == qualityIssues
          ? _self.qualityIssues
          : qualityIssues // ignore: cast_nullable_to_non_nullable
              as int,
      defectRate: null == defectRate
          ? _self.defectRate
          : defectRate // ignore: cast_nullable_to_non_nullable
              as double,
      onTimeDeliveryRate: null == onTimeDeliveryRate
          ? _self.onTimeDeliveryRate
          : onTimeDeliveryRate // ignore: cast_nullable_to_non_nullable
              as double,
      recentIssues: null == recentIssues
          ? _self.recentIssues
          : recentIssues // ignore: cast_nullable_to_non_nullable
              as List<QualityAlert>,
      improvementTrend: null == improvementTrend
          ? _self.improvementTrend
          : improvementTrend // ignore: cast_nullable_to_non_nullable
              as double,
      performanceTrend: null == performanceTrend
          ? _self.performanceTrend
          : performanceTrend // ignore: cast_nullable_to_non_nullable
              as String,
      lastEvaluationDate: null == lastEvaluationDate
          ? _self.lastEvaluationDate
          : lastEvaluationDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      performanceMetrics: freezed == performanceMetrics
          ? _self.performanceMetrics
          : performanceMetrics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SupplierQualityPerformance extends SupplierQualityPerformance {
  const _SupplierQualityPerformance(
      {required this.supplierId,
      required this.supplierName,
      required this.overallQualityScore,
      required final Map<String, double> materialQualityScores,
      required this.totalDeliveries,
      required this.qualityIssues,
      required this.defectRate,
      required this.onTimeDeliveryRate,
      required final List<QualityAlert> recentIssues,
      this.improvementTrend = 0.0,
      this.performanceTrend = 'stable',
      required this.lastEvaluationDate,
      final Map<String, dynamic>? performanceMetrics})
      : _materialQualityScores = materialQualityScores,
        _recentIssues = recentIssues,
        _performanceMetrics = performanceMetrics,
        super._();
  factory _SupplierQualityPerformance.fromJson(Map<String, dynamic> json) =>
      _$SupplierQualityPerformanceFromJson(json);

  @override
  final String supplierId;
  @override
  final String supplierName;
  @override
  final double overallQualityScore;
  final Map<String, double> _materialQualityScores;
  @override
  Map<String, double> get materialQualityScores {
    if (_materialQualityScores is EqualUnmodifiableMapView)
      return _materialQualityScores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_materialQualityScores);
  }

  @override
  final int totalDeliveries;
  @override
  final int qualityIssues;
  @override
  final double defectRate;
  @override
  final double onTimeDeliveryRate;
  final List<QualityAlert> _recentIssues;
  @override
  List<QualityAlert> get recentIssues {
    if (_recentIssues is EqualUnmodifiableListView) return _recentIssues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentIssues);
  }

  @override
  @JsonKey()
  final double improvementTrend;
  @override
  @JsonKey()
  final String performanceTrend;
  @override
  final DateTime lastEvaluationDate;
  final Map<String, dynamic>? _performanceMetrics;
  @override
  Map<String, dynamic>? get performanceMetrics {
    final value = _performanceMetrics;
    if (value == null) return null;
    if (_performanceMetrics is EqualUnmodifiableMapView)
      return _performanceMetrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of SupplierQualityPerformance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SupplierQualityPerformanceCopyWith<_SupplierQualityPerformance>
      get copyWith => __$SupplierQualityPerformanceCopyWithImpl<
          _SupplierQualityPerformance>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SupplierQualityPerformanceToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SupplierQualityPerformance &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.supplierName, supplierName) ||
                other.supplierName == supplierName) &&
            (identical(other.overallQualityScore, overallQualityScore) ||
                other.overallQualityScore == overallQualityScore) &&
            const DeepCollectionEquality()
                .equals(other._materialQualityScores, _materialQualityScores) &&
            (identical(other.totalDeliveries, totalDeliveries) ||
                other.totalDeliveries == totalDeliveries) &&
            (identical(other.qualityIssues, qualityIssues) ||
                other.qualityIssues == qualityIssues) &&
            (identical(other.defectRate, defectRate) ||
                other.defectRate == defectRate) &&
            (identical(other.onTimeDeliveryRate, onTimeDeliveryRate) ||
                other.onTimeDeliveryRate == onTimeDeliveryRate) &&
            const DeepCollectionEquality()
                .equals(other._recentIssues, _recentIssues) &&
            (identical(other.improvementTrend, improvementTrend) ||
                other.improvementTrend == improvementTrend) &&
            (identical(other.performanceTrend, performanceTrend) ||
                other.performanceTrend == performanceTrend) &&
            (identical(other.lastEvaluationDate, lastEvaluationDate) ||
                other.lastEvaluationDate == lastEvaluationDate) &&
            const DeepCollectionEquality()
                .equals(other._performanceMetrics, _performanceMetrics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      supplierId,
      supplierName,
      overallQualityScore,
      const DeepCollectionEquality().hash(_materialQualityScores),
      totalDeliveries,
      qualityIssues,
      defectRate,
      onTimeDeliveryRate,
      const DeepCollectionEquality().hash(_recentIssues),
      improvementTrend,
      performanceTrend,
      lastEvaluationDate,
      const DeepCollectionEquality().hash(_performanceMetrics));

  @override
  String toString() {
    return 'SupplierQualityPerformance(supplierId: $supplierId, supplierName: $supplierName, overallQualityScore: $overallQualityScore, materialQualityScores: $materialQualityScores, totalDeliveries: $totalDeliveries, qualityIssues: $qualityIssues, defectRate: $defectRate, onTimeDeliveryRate: $onTimeDeliveryRate, recentIssues: $recentIssues, improvementTrend: $improvementTrend, performanceTrend: $performanceTrend, lastEvaluationDate: $lastEvaluationDate, performanceMetrics: $performanceMetrics)';
  }
}

/// @nodoc
abstract mixin class _$SupplierQualityPerformanceCopyWith<$Res>
    implements $SupplierQualityPerformanceCopyWith<$Res> {
  factory _$SupplierQualityPerformanceCopyWith(
          _SupplierQualityPerformance value,
          $Res Function(_SupplierQualityPerformance) _then) =
      __$SupplierQualityPerformanceCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String supplierId,
      String supplierName,
      double overallQualityScore,
      Map<String, double> materialQualityScores,
      int totalDeliveries,
      int qualityIssues,
      double defectRate,
      double onTimeDeliveryRate,
      List<QualityAlert> recentIssues,
      double improvementTrend,
      String performanceTrend,
      DateTime lastEvaluationDate,
      Map<String, dynamic>? performanceMetrics});
}

/// @nodoc
class __$SupplierQualityPerformanceCopyWithImpl<$Res>
    implements _$SupplierQualityPerformanceCopyWith<$Res> {
  __$SupplierQualityPerformanceCopyWithImpl(this._self, this._then);

  final _SupplierQualityPerformance _self;
  final $Res Function(_SupplierQualityPerformance) _then;

  /// Create a copy of SupplierQualityPerformance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? supplierId = null,
    Object? supplierName = null,
    Object? overallQualityScore = null,
    Object? materialQualityScores = null,
    Object? totalDeliveries = null,
    Object? qualityIssues = null,
    Object? defectRate = null,
    Object? onTimeDeliveryRate = null,
    Object? recentIssues = null,
    Object? improvementTrend = null,
    Object? performanceTrend = null,
    Object? lastEvaluationDate = null,
    Object? performanceMetrics = freezed,
  }) {
    return _then(_SupplierQualityPerformance(
      supplierId: null == supplierId
          ? _self.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      supplierName: null == supplierName
          ? _self.supplierName
          : supplierName // ignore: cast_nullable_to_non_nullable
              as String,
      overallQualityScore: null == overallQualityScore
          ? _self.overallQualityScore
          : overallQualityScore // ignore: cast_nullable_to_non_nullable
              as double,
      materialQualityScores: null == materialQualityScores
          ? _self._materialQualityScores
          : materialQualityScores // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      totalDeliveries: null == totalDeliveries
          ? _self.totalDeliveries
          : totalDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      qualityIssues: null == qualityIssues
          ? _self.qualityIssues
          : qualityIssues // ignore: cast_nullable_to_non_nullable
              as int,
      defectRate: null == defectRate
          ? _self.defectRate
          : defectRate // ignore: cast_nullable_to_non_nullable
              as double,
      onTimeDeliveryRate: null == onTimeDeliveryRate
          ? _self.onTimeDeliveryRate
          : onTimeDeliveryRate // ignore: cast_nullable_to_non_nullable
              as double,
      recentIssues: null == recentIssues
          ? _self._recentIssues
          : recentIssues // ignore: cast_nullable_to_non_nullable
              as List<QualityAlert>,
      improvementTrend: null == improvementTrend
          ? _self.improvementTrend
          : improvementTrend // ignore: cast_nullable_to_non_nullable
              as double,
      performanceTrend: null == performanceTrend
          ? _self.performanceTrend
          : performanceTrend // ignore: cast_nullable_to_non_nullable
              as String,
      lastEvaluationDate: null == lastEvaluationDate
          ? _self.lastEvaluationDate
          : lastEvaluationDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      performanceMetrics: freezed == performanceMetrics
          ? _self._performanceMetrics
          : performanceMetrics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
mixin _$QualityCertification {
  String get id;
  String get materialId;
  String get supplierId;
  String get certificationType;
  String get certificateNumber;
  DateTime get issuedDate;
  DateTime get expiryDate;
  String get issuingAuthority;
  QualityStatus get status;
  List<String> get attachmentUrls;
  String? get notes;
  DateTime? get lastVerificationDate;
  String? get verifiedBy;

  /// Create a copy of QualityCertification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QualityCertificationCopyWith<QualityCertification> get copyWith =>
      _$QualityCertificationCopyWithImpl<QualityCertification>(
          this as QualityCertification, _$identity);

  /// Serializes this QualityCertification to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QualityCertification &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.materialId, materialId) ||
                other.materialId == materialId) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.certificationType, certificationType) ||
                other.certificationType == certificationType) &&
            (identical(other.certificateNumber, certificateNumber) ||
                other.certificateNumber == certificateNumber) &&
            (identical(other.issuedDate, issuedDate) ||
                other.issuedDate == issuedDate) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.issuingAuthority, issuingAuthority) ||
                other.issuingAuthority == issuingAuthority) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other.attachmentUrls, attachmentUrls) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.lastVerificationDate, lastVerificationDate) ||
                other.lastVerificationDate == lastVerificationDate) &&
            (identical(other.verifiedBy, verifiedBy) ||
                other.verifiedBy == verifiedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      materialId,
      supplierId,
      certificationType,
      certificateNumber,
      issuedDate,
      expiryDate,
      issuingAuthority,
      status,
      const DeepCollectionEquality().hash(attachmentUrls),
      notes,
      lastVerificationDate,
      verifiedBy);

  @override
  String toString() {
    return 'QualityCertification(id: $id, materialId: $materialId, supplierId: $supplierId, certificationType: $certificationType, certificateNumber: $certificateNumber, issuedDate: $issuedDate, expiryDate: $expiryDate, issuingAuthority: $issuingAuthority, status: $status, attachmentUrls: $attachmentUrls, notes: $notes, lastVerificationDate: $lastVerificationDate, verifiedBy: $verifiedBy)';
  }
}

/// @nodoc
abstract mixin class $QualityCertificationCopyWith<$Res> {
  factory $QualityCertificationCopyWith(QualityCertification value,
          $Res Function(QualityCertification) _then) =
      _$QualityCertificationCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String materialId,
      String supplierId,
      String certificationType,
      String certificateNumber,
      DateTime issuedDate,
      DateTime expiryDate,
      String issuingAuthority,
      QualityStatus status,
      List<String> attachmentUrls,
      String? notes,
      DateTime? lastVerificationDate,
      String? verifiedBy});
}

/// @nodoc
class _$QualityCertificationCopyWithImpl<$Res>
    implements $QualityCertificationCopyWith<$Res> {
  _$QualityCertificationCopyWithImpl(this._self, this._then);

  final QualityCertification _self;
  final $Res Function(QualityCertification) _then;

  /// Create a copy of QualityCertification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? materialId = null,
    Object? supplierId = null,
    Object? certificationType = null,
    Object? certificateNumber = null,
    Object? issuedDate = null,
    Object? expiryDate = null,
    Object? issuingAuthority = null,
    Object? status = null,
    Object? attachmentUrls = null,
    Object? notes = freezed,
    Object? lastVerificationDate = freezed,
    Object? verifiedBy = freezed,
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
      supplierId: null == supplierId
          ? _self.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      certificationType: null == certificationType
          ? _self.certificationType
          : certificationType // ignore: cast_nullable_to_non_nullable
              as String,
      certificateNumber: null == certificateNumber
          ? _self.certificateNumber
          : certificateNumber // ignore: cast_nullable_to_non_nullable
              as String,
      issuedDate: null == issuedDate
          ? _self.issuedDate
          : issuedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiryDate: null == expiryDate
          ? _self.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      issuingAuthority: null == issuingAuthority
          ? _self.issuingAuthority
          : issuingAuthority // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as QualityStatus,
      attachmentUrls: null == attachmentUrls
          ? _self.attachmentUrls
          : attachmentUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      lastVerificationDate: freezed == lastVerificationDate
          ? _self.lastVerificationDate
          : lastVerificationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      verifiedBy: freezed == verifiedBy
          ? _self.verifiedBy
          : verifiedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _QualityCertification extends QualityCertification {
  const _QualityCertification(
      {required this.id,
      required this.materialId,
      required this.supplierId,
      required this.certificationType,
      required this.certificateNumber,
      required this.issuedDate,
      required this.expiryDate,
      required this.issuingAuthority,
      required this.status,
      final List<String> attachmentUrls = const [],
      this.notes,
      this.lastVerificationDate,
      this.verifiedBy})
      : _attachmentUrls = attachmentUrls,
        super._();
  factory _QualityCertification.fromJson(Map<String, dynamic> json) =>
      _$QualityCertificationFromJson(json);

  @override
  final String id;
  @override
  final String materialId;
  @override
  final String supplierId;
  @override
  final String certificationType;
  @override
  final String certificateNumber;
  @override
  final DateTime issuedDate;
  @override
  final DateTime expiryDate;
  @override
  final String issuingAuthority;
  @override
  final QualityStatus status;
  final List<String> _attachmentUrls;
  @override
  @JsonKey()
  List<String> get attachmentUrls {
    if (_attachmentUrls is EqualUnmodifiableListView) return _attachmentUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachmentUrls);
  }

  @override
  final String? notes;
  @override
  final DateTime? lastVerificationDate;
  @override
  final String? verifiedBy;

  /// Create a copy of QualityCertification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$QualityCertificationCopyWith<_QualityCertification> get copyWith =>
      __$QualityCertificationCopyWithImpl<_QualityCertification>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$QualityCertificationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _QualityCertification &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.materialId, materialId) ||
                other.materialId == materialId) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.certificationType, certificationType) ||
                other.certificationType == certificationType) &&
            (identical(other.certificateNumber, certificateNumber) ||
                other.certificateNumber == certificateNumber) &&
            (identical(other.issuedDate, issuedDate) ||
                other.issuedDate == issuedDate) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.issuingAuthority, issuingAuthority) ||
                other.issuingAuthority == issuingAuthority) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._attachmentUrls, _attachmentUrls) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.lastVerificationDate, lastVerificationDate) ||
                other.lastVerificationDate == lastVerificationDate) &&
            (identical(other.verifiedBy, verifiedBy) ||
                other.verifiedBy == verifiedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      materialId,
      supplierId,
      certificationType,
      certificateNumber,
      issuedDate,
      expiryDate,
      issuingAuthority,
      status,
      const DeepCollectionEquality().hash(_attachmentUrls),
      notes,
      lastVerificationDate,
      verifiedBy);

  @override
  String toString() {
    return 'QualityCertification(id: $id, materialId: $materialId, supplierId: $supplierId, certificationType: $certificationType, certificateNumber: $certificateNumber, issuedDate: $issuedDate, expiryDate: $expiryDate, issuingAuthority: $issuingAuthority, status: $status, attachmentUrls: $attachmentUrls, notes: $notes, lastVerificationDate: $lastVerificationDate, verifiedBy: $verifiedBy)';
  }
}

/// @nodoc
abstract mixin class _$QualityCertificationCopyWith<$Res>
    implements $QualityCertificationCopyWith<$Res> {
  factory _$QualityCertificationCopyWith(_QualityCertification value,
          $Res Function(_QualityCertification) _then) =
      __$QualityCertificationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String materialId,
      String supplierId,
      String certificationType,
      String certificateNumber,
      DateTime issuedDate,
      DateTime expiryDate,
      String issuingAuthority,
      QualityStatus status,
      List<String> attachmentUrls,
      String? notes,
      DateTime? lastVerificationDate,
      String? verifiedBy});
}

/// @nodoc
class __$QualityCertificationCopyWithImpl<$Res>
    implements _$QualityCertificationCopyWith<$Res> {
  __$QualityCertificationCopyWithImpl(this._self, this._then);

  final _QualityCertification _self;
  final $Res Function(_QualityCertification) _then;

  /// Create a copy of QualityCertification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? materialId = null,
    Object? supplierId = null,
    Object? certificationType = null,
    Object? certificateNumber = null,
    Object? issuedDate = null,
    Object? expiryDate = null,
    Object? issuingAuthority = null,
    Object? status = null,
    Object? attachmentUrls = null,
    Object? notes = freezed,
    Object? lastVerificationDate = freezed,
    Object? verifiedBy = freezed,
  }) {
    return _then(_QualityCertification(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      materialId: null == materialId
          ? _self.materialId
          : materialId // ignore: cast_nullable_to_non_nullable
              as String,
      supplierId: null == supplierId
          ? _self.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      certificationType: null == certificationType
          ? _self.certificationType
          : certificationType // ignore: cast_nullable_to_non_nullable
              as String,
      certificateNumber: null == certificateNumber
          ? _self.certificateNumber
          : certificateNumber // ignore: cast_nullable_to_non_nullable
              as String,
      issuedDate: null == issuedDate
          ? _self.issuedDate
          : issuedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiryDate: null == expiryDate
          ? _self.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      issuingAuthority: null == issuingAuthority
          ? _self.issuingAuthority
          : issuingAuthority // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as QualityStatus,
      attachmentUrls: null == attachmentUrls
          ? _self._attachmentUrls
          : attachmentUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      lastVerificationDate: freezed == lastVerificationDate
          ? _self.lastVerificationDate
          : lastVerificationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      verifiedBy: freezed == verifiedBy
          ? _self.verifiedBy
          : verifiedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
