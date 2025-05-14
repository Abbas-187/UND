// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InventoryFilter {
  String get searchQuery;
  bool get showLowStock;
  bool get showNeedsReorder;
  bool get showExpiringSoon;
  String? get selectedCategory;
  String? get selectedLocation;

  /// Create a copy of InventoryFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InventoryFilterCopyWith<InventoryFilter> get copyWith =>
      _$InventoryFilterCopyWithImpl<InventoryFilter>(
          this as InventoryFilter, _$identity);

  /// Serializes this InventoryFilter to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InventoryFilter &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.showLowStock, showLowStock) ||
                other.showLowStock == showLowStock) &&
            (identical(other.showNeedsReorder, showNeedsReorder) ||
                other.showNeedsReorder == showNeedsReorder) &&
            (identical(other.showExpiringSoon, showExpiringSoon) ||
                other.showExpiringSoon == showExpiringSoon) &&
            (identical(other.selectedCategory, selectedCategory) ||
                other.selectedCategory == selectedCategory) &&
            (identical(other.selectedLocation, selectedLocation) ||
                other.selectedLocation == selectedLocation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, searchQuery, showLowStock,
      showNeedsReorder, showExpiringSoon, selectedCategory, selectedLocation);

  @override
  String toString() {
    return 'InventoryFilter(searchQuery: $searchQuery, showLowStock: $showLowStock, showNeedsReorder: $showNeedsReorder, showExpiringSoon: $showExpiringSoon, selectedCategory: $selectedCategory, selectedLocation: $selectedLocation)';
  }
}

/// @nodoc
abstract mixin class $InventoryFilterCopyWith<$Res> {
  factory $InventoryFilterCopyWith(
          InventoryFilter value, $Res Function(InventoryFilter) _then) =
      _$InventoryFilterCopyWithImpl;
  @useResult
  $Res call(
      {String searchQuery,
      bool showLowStock,
      bool showNeedsReorder,
      bool showExpiringSoon,
      String? selectedCategory,
      String? selectedLocation});
}

/// @nodoc
class _$InventoryFilterCopyWithImpl<$Res>
    implements $InventoryFilterCopyWith<$Res> {
  _$InventoryFilterCopyWithImpl(this._self, this._then);

  final InventoryFilter _self;
  final $Res Function(InventoryFilter) _then;

  /// Create a copy of InventoryFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? searchQuery = null,
    Object? showLowStock = null,
    Object? showNeedsReorder = null,
    Object? showExpiringSoon = null,
    Object? selectedCategory = freezed,
    Object? selectedLocation = freezed,
  }) {
    return _then(_self.copyWith(
      searchQuery: null == searchQuery
          ? _self.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      showLowStock: null == showLowStock
          ? _self.showLowStock
          : showLowStock // ignore: cast_nullable_to_non_nullable
              as bool,
      showNeedsReorder: null == showNeedsReorder
          ? _self.showNeedsReorder
          : showNeedsReorder // ignore: cast_nullable_to_non_nullable
              as bool,
      showExpiringSoon: null == showExpiringSoon
          ? _self.showExpiringSoon
          : showExpiringSoon // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedCategory: freezed == selectedCategory
          ? _self.selectedCategory
          : selectedCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedLocation: freezed == selectedLocation
          ? _self.selectedLocation
          : selectedLocation // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _InventoryFilter implements InventoryFilter {
  const _InventoryFilter(
      {this.searchQuery = '',
      this.showLowStock = false,
      this.showNeedsReorder = false,
      this.showExpiringSoon = false,
      this.selectedCategory,
      this.selectedLocation});
  factory _InventoryFilter.fromJson(Map<String, dynamic> json) =>
      _$InventoryFilterFromJson(json);

  @override
  @JsonKey()
  final String searchQuery;
  @override
  @JsonKey()
  final bool showLowStock;
  @override
  @JsonKey()
  final bool showNeedsReorder;
  @override
  @JsonKey()
  final bool showExpiringSoon;
  @override
  final String? selectedCategory;
  @override
  final String? selectedLocation;

  /// Create a copy of InventoryFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InventoryFilterCopyWith<_InventoryFilter> get copyWith =>
      __$InventoryFilterCopyWithImpl<_InventoryFilter>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$InventoryFilterToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InventoryFilter &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.showLowStock, showLowStock) ||
                other.showLowStock == showLowStock) &&
            (identical(other.showNeedsReorder, showNeedsReorder) ||
                other.showNeedsReorder == showNeedsReorder) &&
            (identical(other.showExpiringSoon, showExpiringSoon) ||
                other.showExpiringSoon == showExpiringSoon) &&
            (identical(other.selectedCategory, selectedCategory) ||
                other.selectedCategory == selectedCategory) &&
            (identical(other.selectedLocation, selectedLocation) ||
                other.selectedLocation == selectedLocation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, searchQuery, showLowStock,
      showNeedsReorder, showExpiringSoon, selectedCategory, selectedLocation);

  @override
  String toString() {
    return 'InventoryFilter(searchQuery: $searchQuery, showLowStock: $showLowStock, showNeedsReorder: $showNeedsReorder, showExpiringSoon: $showExpiringSoon, selectedCategory: $selectedCategory, selectedLocation: $selectedLocation)';
  }
}

/// @nodoc
abstract mixin class _$InventoryFilterCopyWith<$Res>
    implements $InventoryFilterCopyWith<$Res> {
  factory _$InventoryFilterCopyWith(
          _InventoryFilter value, $Res Function(_InventoryFilter) _then) =
      __$InventoryFilterCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String searchQuery,
      bool showLowStock,
      bool showNeedsReorder,
      bool showExpiringSoon,
      String? selectedCategory,
      String? selectedLocation});
}

/// @nodoc
class __$InventoryFilterCopyWithImpl<$Res>
    implements _$InventoryFilterCopyWith<$Res> {
  __$InventoryFilterCopyWithImpl(this._self, this._then);

  final _InventoryFilter _self;
  final $Res Function(_InventoryFilter) _then;

  /// Create a copy of InventoryFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? searchQuery = null,
    Object? showLowStock = null,
    Object? showNeedsReorder = null,
    Object? showExpiringSoon = null,
    Object? selectedCategory = freezed,
    Object? selectedLocation = freezed,
  }) {
    return _then(_InventoryFilter(
      searchQuery: null == searchQuery
          ? _self.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      showLowStock: null == showLowStock
          ? _self.showLowStock
          : showLowStock // ignore: cast_nullable_to_non_nullable
              as bool,
      showNeedsReorder: null == showNeedsReorder
          ? _self.showNeedsReorder
          : showNeedsReorder // ignore: cast_nullable_to_non_nullable
              as bool,
      showExpiringSoon: null == showExpiringSoon
          ? _self.showExpiringSoon
          : showExpiringSoon // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedCategory: freezed == selectedCategory
          ? _self.selectedCategory
          : selectedCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedLocation: freezed == selectedLocation
          ? _self.selectedLocation
          : selectedLocation // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
