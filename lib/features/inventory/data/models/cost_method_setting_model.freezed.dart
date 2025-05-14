// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cost_method_setting_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CostMethodSettingModel {
  String? get id;
  CostingMethod get defaultCostingMethod;
  bool get isCompanyWide;
  String? get warehouseId;
  String? get warehouseName;
  bool get allowWarehouseOverride;
  DateTime get effectiveFrom;
  DateTime? get lastUpdated;
  String? get updatedById;
  String? get updatedByName;
  Map<String, CostingMethod>? get itemSpecificMethods;

  /// Create a copy of CostMethodSettingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CostMethodSettingModelCopyWith<CostMethodSettingModel> get copyWith =>
      _$CostMethodSettingModelCopyWithImpl<CostMethodSettingModel>(
          this as CostMethodSettingModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CostMethodSettingModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.defaultCostingMethod, defaultCostingMethod) ||
                other.defaultCostingMethod == defaultCostingMethod) &&
            (identical(other.isCompanyWide, isCompanyWide) ||
                other.isCompanyWide == isCompanyWide) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.warehouseName, warehouseName) ||
                other.warehouseName == warehouseName) &&
            (identical(other.allowWarehouseOverride, allowWarehouseOverride) ||
                other.allowWarehouseOverride == allowWarehouseOverride) &&
            (identical(other.effectiveFrom, effectiveFrom) ||
                other.effectiveFrom == effectiveFrom) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.updatedById, updatedById) ||
                other.updatedById == updatedById) &&
            (identical(other.updatedByName, updatedByName) ||
                other.updatedByName == updatedByName) &&
            const DeepCollectionEquality()
                .equals(other.itemSpecificMethods, itemSpecificMethods));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      defaultCostingMethod,
      isCompanyWide,
      warehouseId,
      warehouseName,
      allowWarehouseOverride,
      effectiveFrom,
      lastUpdated,
      updatedById,
      updatedByName,
      const DeepCollectionEquality().hash(itemSpecificMethods));

  @override
  String toString() {
    return 'CostMethodSettingModel(id: $id, defaultCostingMethod: $defaultCostingMethod, isCompanyWide: $isCompanyWide, warehouseId: $warehouseId, warehouseName: $warehouseName, allowWarehouseOverride: $allowWarehouseOverride, effectiveFrom: $effectiveFrom, lastUpdated: $lastUpdated, updatedById: $updatedById, updatedByName: $updatedByName, itemSpecificMethods: $itemSpecificMethods)';
  }
}

/// @nodoc
abstract mixin class $CostMethodSettingModelCopyWith<$Res> {
  factory $CostMethodSettingModelCopyWith(CostMethodSettingModel value,
          $Res Function(CostMethodSettingModel) _then) =
      _$CostMethodSettingModelCopyWithImpl;
  @useResult
  $Res call(
      {String? id,
      CostingMethod defaultCostingMethod,
      bool isCompanyWide,
      String? warehouseId,
      String? warehouseName,
      bool allowWarehouseOverride,
      DateTime effectiveFrom,
      DateTime? lastUpdated,
      String? updatedById,
      String? updatedByName,
      Map<String, CostingMethod>? itemSpecificMethods});
}

/// @nodoc
class _$CostMethodSettingModelCopyWithImpl<$Res>
    implements $CostMethodSettingModelCopyWith<$Res> {
  _$CostMethodSettingModelCopyWithImpl(this._self, this._then);

  final CostMethodSettingModel _self;
  final $Res Function(CostMethodSettingModel) _then;

  /// Create a copy of CostMethodSettingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? defaultCostingMethod = null,
    Object? isCompanyWide = null,
    Object? warehouseId = freezed,
    Object? warehouseName = freezed,
    Object? allowWarehouseOverride = null,
    Object? effectiveFrom = null,
    Object? lastUpdated = freezed,
    Object? updatedById = freezed,
    Object? updatedByName = freezed,
    Object? itemSpecificMethods = freezed,
  }) {
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultCostingMethod: null == defaultCostingMethod
          ? _self.defaultCostingMethod
          : defaultCostingMethod // ignore: cast_nullable_to_non_nullable
              as CostingMethod,
      isCompanyWide: null == isCompanyWide
          ? _self.isCompanyWide
          : isCompanyWide // ignore: cast_nullable_to_non_nullable
              as bool,
      warehouseId: freezed == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String?,
      warehouseName: freezed == warehouseName
          ? _self.warehouseName
          : warehouseName // ignore: cast_nullable_to_non_nullable
              as String?,
      allowWarehouseOverride: null == allowWarehouseOverride
          ? _self.allowWarehouseOverride
          : allowWarehouseOverride // ignore: cast_nullable_to_non_nullable
              as bool,
      effectiveFrom: null == effectiveFrom
          ? _self.effectiveFrom
          : effectiveFrom // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUpdated: freezed == lastUpdated
          ? _self.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedById: freezed == updatedById
          ? _self.updatedById
          : updatedById // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedByName: freezed == updatedByName
          ? _self.updatedByName
          : updatedByName // ignore: cast_nullable_to_non_nullable
              as String?,
      itemSpecificMethods: freezed == itemSpecificMethods
          ? _self.itemSpecificMethods
          : itemSpecificMethods // ignore: cast_nullable_to_non_nullable
              as Map<String, CostingMethod>?,
    ));
  }
}

/// @nodoc

class _CostMethodSettingModel implements CostMethodSettingModel {
  const _CostMethodSettingModel(
      {this.id,
      required this.defaultCostingMethod,
      required this.isCompanyWide,
      this.warehouseId,
      this.warehouseName,
      required this.allowWarehouseOverride,
      required this.effectiveFrom,
      this.lastUpdated,
      this.updatedById,
      this.updatedByName,
      final Map<String, CostingMethod>? itemSpecificMethods})
      : _itemSpecificMethods = itemSpecificMethods;

  @override
  final String? id;
  @override
  final CostingMethod defaultCostingMethod;
  @override
  final bool isCompanyWide;
  @override
  final String? warehouseId;
  @override
  final String? warehouseName;
  @override
  final bool allowWarehouseOverride;
  @override
  final DateTime effectiveFrom;
  @override
  final DateTime? lastUpdated;
  @override
  final String? updatedById;
  @override
  final String? updatedByName;
  final Map<String, CostingMethod>? _itemSpecificMethods;
  @override
  Map<String, CostingMethod>? get itemSpecificMethods {
    final value = _itemSpecificMethods;
    if (value == null) return null;
    if (_itemSpecificMethods is EqualUnmodifiableMapView)
      return _itemSpecificMethods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of CostMethodSettingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CostMethodSettingModelCopyWith<_CostMethodSettingModel> get copyWith =>
      __$CostMethodSettingModelCopyWithImpl<_CostMethodSettingModel>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CostMethodSettingModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.defaultCostingMethod, defaultCostingMethod) ||
                other.defaultCostingMethod == defaultCostingMethod) &&
            (identical(other.isCompanyWide, isCompanyWide) ||
                other.isCompanyWide == isCompanyWide) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.warehouseName, warehouseName) ||
                other.warehouseName == warehouseName) &&
            (identical(other.allowWarehouseOverride, allowWarehouseOverride) ||
                other.allowWarehouseOverride == allowWarehouseOverride) &&
            (identical(other.effectiveFrom, effectiveFrom) ||
                other.effectiveFrom == effectiveFrom) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.updatedById, updatedById) ||
                other.updatedById == updatedById) &&
            (identical(other.updatedByName, updatedByName) ||
                other.updatedByName == updatedByName) &&
            const DeepCollectionEquality()
                .equals(other._itemSpecificMethods, _itemSpecificMethods));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      defaultCostingMethod,
      isCompanyWide,
      warehouseId,
      warehouseName,
      allowWarehouseOverride,
      effectiveFrom,
      lastUpdated,
      updatedById,
      updatedByName,
      const DeepCollectionEquality().hash(_itemSpecificMethods));

  @override
  String toString() {
    return 'CostMethodSettingModel(id: $id, defaultCostingMethod: $defaultCostingMethod, isCompanyWide: $isCompanyWide, warehouseId: $warehouseId, warehouseName: $warehouseName, allowWarehouseOverride: $allowWarehouseOverride, effectiveFrom: $effectiveFrom, lastUpdated: $lastUpdated, updatedById: $updatedById, updatedByName: $updatedByName, itemSpecificMethods: $itemSpecificMethods)';
  }
}

/// @nodoc
abstract mixin class _$CostMethodSettingModelCopyWith<$Res>
    implements $CostMethodSettingModelCopyWith<$Res> {
  factory _$CostMethodSettingModelCopyWith(_CostMethodSettingModel value,
          $Res Function(_CostMethodSettingModel) _then) =
      __$CostMethodSettingModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? id,
      CostingMethod defaultCostingMethod,
      bool isCompanyWide,
      String? warehouseId,
      String? warehouseName,
      bool allowWarehouseOverride,
      DateTime effectiveFrom,
      DateTime? lastUpdated,
      String? updatedById,
      String? updatedByName,
      Map<String, CostingMethod>? itemSpecificMethods});
}

/// @nodoc
class __$CostMethodSettingModelCopyWithImpl<$Res>
    implements _$CostMethodSettingModelCopyWith<$Res> {
  __$CostMethodSettingModelCopyWithImpl(this._self, this._then);

  final _CostMethodSettingModel _self;
  final $Res Function(_CostMethodSettingModel) _then;

  /// Create a copy of CostMethodSettingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? defaultCostingMethod = null,
    Object? isCompanyWide = null,
    Object? warehouseId = freezed,
    Object? warehouseName = freezed,
    Object? allowWarehouseOverride = null,
    Object? effectiveFrom = null,
    Object? lastUpdated = freezed,
    Object? updatedById = freezed,
    Object? updatedByName = freezed,
    Object? itemSpecificMethods = freezed,
  }) {
    return _then(_CostMethodSettingModel(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultCostingMethod: null == defaultCostingMethod
          ? _self.defaultCostingMethod
          : defaultCostingMethod // ignore: cast_nullable_to_non_nullable
              as CostingMethod,
      isCompanyWide: null == isCompanyWide
          ? _self.isCompanyWide
          : isCompanyWide // ignore: cast_nullable_to_non_nullable
              as bool,
      warehouseId: freezed == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String?,
      warehouseName: freezed == warehouseName
          ? _self.warehouseName
          : warehouseName // ignore: cast_nullable_to_non_nullable
              as String?,
      allowWarehouseOverride: null == allowWarehouseOverride
          ? _self.allowWarehouseOverride
          : allowWarehouseOverride // ignore: cast_nullable_to_non_nullable
              as bool,
      effectiveFrom: null == effectiveFrom
          ? _self.effectiveFrom
          : effectiveFrom // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUpdated: freezed == lastUpdated
          ? _self.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedById: freezed == updatedById
          ? _self.updatedById
          : updatedById // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedByName: freezed == updatedByName
          ? _self.updatedByName
          : updatedByName // ignore: cast_nullable_to_non_nullable
              as String?,
      itemSpecificMethods: freezed == itemSpecificMethods
          ? _self._itemSpecificMethods
          : itemSpecificMethods // ignore: cast_nullable_to_non_nullable
              as Map<String, CostingMethod>?,
    ));
  }
}

// dart format on
