// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'optimized_bill_of_materials.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OptimizedBillOfMaterials {
  String get id;
  String get bomCode;
  String get bomName;
  String get productId;
  String get productCode;
  String get productName;
  BomType get bomType;
  String get version;
  double get baseQuantity;
  String get baseUnit;
  BomStatus get status;
  List<BomItem> get items;
  double get totalCost;
  double get laborCost;
  double get overheadCost;
  double get setupCost;
  double get yieldPercentage;
  String? get description;
  String? get notes;
  String? get approvedBy;
  DateTime? get approvedAt;
  DateTime? get effectiveFrom;
  DateTime? get effectiveTo;
  Map<String, dynamic>? get productionInstructions;
  Map<String, dynamic>? get qualityRequirements;
  Map<String, dynamic>? get packagingInstructions;
  List<String>? get alternativeBomIds;
  String? get parentBomId;
  List<String> get childBomIds;
  DateTime get createdAt;
  DateTime get updatedAt;
  String? get createdBy;
  String? get updatedBy; // Cached calculation results
  Map<String, dynamic>? get cachedCalculations;
  DateTime? get calculationsLastUpdated;

  /// Create a copy of OptimizedBillOfMaterials
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OptimizedBillOfMaterialsCopyWith<OptimizedBillOfMaterials> get copyWith =>
      _$OptimizedBillOfMaterialsCopyWithImpl<OptimizedBillOfMaterials>(
          this as OptimizedBillOfMaterials, _$identity);

  /// Serializes this OptimizedBillOfMaterials to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OptimizedBillOfMaterials &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bomCode, bomCode) || other.bomCode == bomCode) &&
            (identical(other.bomName, bomName) || other.bomName == bomName) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productCode, productCode) ||
                other.productCode == productCode) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.bomType, bomType) || other.bomType == bomType) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.baseQuantity, baseQuantity) ||
                other.baseQuantity == baseQuantity) &&
            (identical(other.baseUnit, baseUnit) ||
                other.baseUnit == baseUnit) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other.items, items) &&
            (identical(other.totalCost, totalCost) ||
                other.totalCost == totalCost) &&
            (identical(other.laborCost, laborCost) ||
                other.laborCost == laborCost) &&
            (identical(other.overheadCost, overheadCost) ||
                other.overheadCost == overheadCost) &&
            (identical(other.setupCost, setupCost) ||
                other.setupCost == setupCost) &&
            (identical(other.yieldPercentage, yieldPercentage) ||
                other.yieldPercentage == yieldPercentage) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.effectiveFrom, effectiveFrom) ||
                other.effectiveFrom == effectiveFrom) &&
            (identical(other.effectiveTo, effectiveTo) ||
                other.effectiveTo == effectiveTo) &&
            const DeepCollectionEquality()
                .equals(other.productionInstructions, productionInstructions) &&
            const DeepCollectionEquality()
                .equals(other.qualityRequirements, qualityRequirements) &&
            const DeepCollectionEquality()
                .equals(other.packagingInstructions, packagingInstructions) &&
            const DeepCollectionEquality()
                .equals(other.alternativeBomIds, alternativeBomIds) &&
            (identical(other.parentBomId, parentBomId) ||
                other.parentBomId == parentBomId) &&
            const DeepCollectionEquality()
                .equals(other.childBomIds, childBomIds) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            const DeepCollectionEquality()
                .equals(other.cachedCalculations, cachedCalculations) &&
            (identical(
                    other.calculationsLastUpdated, calculationsLastUpdated) ||
                other.calculationsLastUpdated == calculationsLastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        bomCode,
        bomName,
        productId,
        productCode,
        productName,
        bomType,
        version,
        baseQuantity,
        baseUnit,
        status,
        const DeepCollectionEquality().hash(items),
        totalCost,
        laborCost,
        overheadCost,
        setupCost,
        yieldPercentage,
        description,
        notes,
        approvedBy,
        approvedAt,
        effectiveFrom,
        effectiveTo,
        const DeepCollectionEquality().hash(productionInstructions),
        const DeepCollectionEquality().hash(qualityRequirements),
        const DeepCollectionEquality().hash(packagingInstructions),
        const DeepCollectionEquality().hash(alternativeBomIds),
        parentBomId,
        const DeepCollectionEquality().hash(childBomIds),
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
        const DeepCollectionEquality().hash(cachedCalculations),
        calculationsLastUpdated
      ]);

  @override
  String toString() {
    return 'OptimizedBillOfMaterials(id: $id, bomCode: $bomCode, bomName: $bomName, productId: $productId, productCode: $productCode, productName: $productName, bomType: $bomType, version: $version, baseQuantity: $baseQuantity, baseUnit: $baseUnit, status: $status, items: $items, totalCost: $totalCost, laborCost: $laborCost, overheadCost: $overheadCost, setupCost: $setupCost, yieldPercentage: $yieldPercentage, description: $description, notes: $notes, approvedBy: $approvedBy, approvedAt: $approvedAt, effectiveFrom: $effectiveFrom, effectiveTo: $effectiveTo, productionInstructions: $productionInstructions, qualityRequirements: $qualityRequirements, packagingInstructions: $packagingInstructions, alternativeBomIds: $alternativeBomIds, parentBomId: $parentBomId, childBomIds: $childBomIds, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy, updatedBy: $updatedBy, cachedCalculations: $cachedCalculations, calculationsLastUpdated: $calculationsLastUpdated)';
  }
}

/// @nodoc
abstract mixin class $OptimizedBillOfMaterialsCopyWith<$Res> {
  factory $OptimizedBillOfMaterialsCopyWith(OptimizedBillOfMaterials value,
          $Res Function(OptimizedBillOfMaterials) _then) =
      _$OptimizedBillOfMaterialsCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String bomCode,
      String bomName,
      String productId,
      String productCode,
      String productName,
      BomType bomType,
      String version,
      double baseQuantity,
      String baseUnit,
      BomStatus status,
      List<BomItem> items,
      double totalCost,
      double laborCost,
      double overheadCost,
      double setupCost,
      double yieldPercentage,
      String? description,
      String? notes,
      String? approvedBy,
      DateTime? approvedAt,
      DateTime? effectiveFrom,
      DateTime? effectiveTo,
      Map<String, dynamic>? productionInstructions,
      Map<String, dynamic>? qualityRequirements,
      Map<String, dynamic>? packagingInstructions,
      List<String>? alternativeBomIds,
      String? parentBomId,
      List<String> childBomIds,
      DateTime createdAt,
      DateTime updatedAt,
      String? createdBy,
      String? updatedBy,
      Map<String, dynamic>? cachedCalculations,
      DateTime? calculationsLastUpdated});
}

/// @nodoc
class _$OptimizedBillOfMaterialsCopyWithImpl<$Res>
    implements $OptimizedBillOfMaterialsCopyWith<$Res> {
  _$OptimizedBillOfMaterialsCopyWithImpl(this._self, this._then);

  final OptimizedBillOfMaterials _self;
  final $Res Function(OptimizedBillOfMaterials) _then;

  /// Create a copy of OptimizedBillOfMaterials
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bomCode = null,
    Object? bomName = null,
    Object? productId = null,
    Object? productCode = null,
    Object? productName = null,
    Object? bomType = null,
    Object? version = null,
    Object? baseQuantity = null,
    Object? baseUnit = null,
    Object? status = null,
    Object? items = null,
    Object? totalCost = null,
    Object? laborCost = null,
    Object? overheadCost = null,
    Object? setupCost = null,
    Object? yieldPercentage = null,
    Object? description = freezed,
    Object? notes = freezed,
    Object? approvedBy = freezed,
    Object? approvedAt = freezed,
    Object? effectiveFrom = freezed,
    Object? effectiveTo = freezed,
    Object? productionInstructions = freezed,
    Object? qualityRequirements = freezed,
    Object? packagingInstructions = freezed,
    Object? alternativeBomIds = freezed,
    Object? parentBomId = freezed,
    Object? childBomIds = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
    Object? cachedCalculations = freezed,
    Object? calculationsLastUpdated = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      bomCode: null == bomCode
          ? _self.bomCode
          : bomCode // ignore: cast_nullable_to_non_nullable
              as String,
      bomName: null == bomName
          ? _self.bomName
          : bomName // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productCode: null == productCode
          ? _self.productCode
          : productCode // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _self.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      bomType: null == bomType
          ? _self.bomType
          : bomType // ignore: cast_nullable_to_non_nullable
              as BomType,
      version: null == version
          ? _self.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      baseQuantity: null == baseQuantity
          ? _self.baseQuantity
          : baseQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      baseUnit: null == baseUnit
          ? _self.baseUnit
          : baseUnit // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as BomStatus,
      items: null == items
          ? _self.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<BomItem>,
      totalCost: null == totalCost
          ? _self.totalCost
          : totalCost // ignore: cast_nullable_to_non_nullable
              as double,
      laborCost: null == laborCost
          ? _self.laborCost
          : laborCost // ignore: cast_nullable_to_non_nullable
              as double,
      overheadCost: null == overheadCost
          ? _self.overheadCost
          : overheadCost // ignore: cast_nullable_to_non_nullable
              as double,
      setupCost: null == setupCost
          ? _self.setupCost
          : setupCost // ignore: cast_nullable_to_non_nullable
              as double,
      yieldPercentage: null == yieldPercentage
          ? _self.yieldPercentage
          : yieldPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedBy: freezed == approvedBy
          ? _self.approvedBy
          : approvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedAt: freezed == approvedAt
          ? _self.approvedAt
          : approvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      effectiveFrom: freezed == effectiveFrom
          ? _self.effectiveFrom
          : effectiveFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      effectiveTo: freezed == effectiveTo
          ? _self.effectiveTo
          : effectiveTo // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      productionInstructions: freezed == productionInstructions
          ? _self.productionInstructions
          : productionInstructions // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      qualityRequirements: freezed == qualityRequirements
          ? _self.qualityRequirements
          : qualityRequirements // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      packagingInstructions: freezed == packagingInstructions
          ? _self.packagingInstructions
          : packagingInstructions // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      alternativeBomIds: freezed == alternativeBomIds
          ? _self.alternativeBomIds
          : alternativeBomIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      parentBomId: freezed == parentBomId
          ? _self.parentBomId
          : parentBomId // ignore: cast_nullable_to_non_nullable
              as String?,
      childBomIds: null == childBomIds
          ? _self.childBomIds
          : childBomIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
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
      cachedCalculations: freezed == cachedCalculations
          ? _self.cachedCalculations
          : cachedCalculations // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      calculationsLastUpdated: freezed == calculationsLastUpdated
          ? _self.calculationsLastUpdated
          : calculationsLastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _OptimizedBillOfMaterials extends OptimizedBillOfMaterials {
  const _OptimizedBillOfMaterials(
      {required this.id,
      required this.bomCode,
      required this.bomName,
      required this.productId,
      required this.productCode,
      required this.productName,
      required this.bomType,
      required this.version,
      required this.baseQuantity,
      required this.baseUnit,
      this.status = BomStatus.draft,
      final List<BomItem> items = const [],
      this.totalCost = 0.0,
      this.laborCost = 0.0,
      this.overheadCost = 0.0,
      this.setupCost = 0.0,
      this.yieldPercentage = 0.0,
      this.description,
      this.notes,
      this.approvedBy,
      this.approvedAt,
      this.effectiveFrom,
      this.effectiveTo,
      final Map<String, dynamic>? productionInstructions,
      final Map<String, dynamic>? qualityRequirements,
      final Map<String, dynamic>? packagingInstructions,
      final List<String>? alternativeBomIds,
      this.parentBomId,
      final List<String> childBomIds = const [],
      required this.createdAt,
      required this.updatedAt,
      this.createdBy,
      this.updatedBy,
      final Map<String, dynamic>? cachedCalculations,
      this.calculationsLastUpdated})
      : _items = items,
        _productionInstructions = productionInstructions,
        _qualityRequirements = qualityRequirements,
        _packagingInstructions = packagingInstructions,
        _alternativeBomIds = alternativeBomIds,
        _childBomIds = childBomIds,
        _cachedCalculations = cachedCalculations,
        super._();
  factory _OptimizedBillOfMaterials.fromJson(Map<String, dynamic> json) =>
      _$OptimizedBillOfMaterialsFromJson(json);

  @override
  final String id;
  @override
  final String bomCode;
  @override
  final String bomName;
  @override
  final String productId;
  @override
  final String productCode;
  @override
  final String productName;
  @override
  final BomType bomType;
  @override
  final String version;
  @override
  final double baseQuantity;
  @override
  final String baseUnit;
  @override
  @JsonKey()
  final BomStatus status;
  final List<BomItem> _items;
  @override
  @JsonKey()
  List<BomItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final double totalCost;
  @override
  @JsonKey()
  final double laborCost;
  @override
  @JsonKey()
  final double overheadCost;
  @override
  @JsonKey()
  final double setupCost;
  @override
  @JsonKey()
  final double yieldPercentage;
  @override
  final String? description;
  @override
  final String? notes;
  @override
  final String? approvedBy;
  @override
  final DateTime? approvedAt;
  @override
  final DateTime? effectiveFrom;
  @override
  final DateTime? effectiveTo;
  final Map<String, dynamic>? _productionInstructions;
  @override
  Map<String, dynamic>? get productionInstructions {
    final value = _productionInstructions;
    if (value == null) return null;
    if (_productionInstructions is EqualUnmodifiableMapView)
      return _productionInstructions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _qualityRequirements;
  @override
  Map<String, dynamic>? get qualityRequirements {
    final value = _qualityRequirements;
    if (value == null) return null;
    if (_qualityRequirements is EqualUnmodifiableMapView)
      return _qualityRequirements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _packagingInstructions;
  @override
  Map<String, dynamic>? get packagingInstructions {
    final value = _packagingInstructions;
    if (value == null) return null;
    if (_packagingInstructions is EqualUnmodifiableMapView)
      return _packagingInstructions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<String>? _alternativeBomIds;
  @override
  List<String>? get alternativeBomIds {
    final value = _alternativeBomIds;
    if (value == null) return null;
    if (_alternativeBomIds is EqualUnmodifiableListView)
      return _alternativeBomIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? parentBomId;
  final List<String> _childBomIds;
  @override
  @JsonKey()
  List<String> get childBomIds {
    if (_childBomIds is EqualUnmodifiableListView) return _childBomIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_childBomIds);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? createdBy;
  @override
  final String? updatedBy;
// Cached calculation results
  final Map<String, dynamic>? _cachedCalculations;
// Cached calculation results
  @override
  Map<String, dynamic>? get cachedCalculations {
    final value = _cachedCalculations;
    if (value == null) return null;
    if (_cachedCalculations is EqualUnmodifiableMapView)
      return _cachedCalculations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? calculationsLastUpdated;

  /// Create a copy of OptimizedBillOfMaterials
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OptimizedBillOfMaterialsCopyWith<_OptimizedBillOfMaterials> get copyWith =>
      __$OptimizedBillOfMaterialsCopyWithImpl<_OptimizedBillOfMaterials>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$OptimizedBillOfMaterialsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OptimizedBillOfMaterials &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bomCode, bomCode) || other.bomCode == bomCode) &&
            (identical(other.bomName, bomName) || other.bomName == bomName) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productCode, productCode) ||
                other.productCode == productCode) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.bomType, bomType) || other.bomType == bomType) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.baseQuantity, baseQuantity) ||
                other.baseQuantity == baseQuantity) &&
            (identical(other.baseUnit, baseUnit) ||
                other.baseUnit == baseUnit) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.totalCost, totalCost) ||
                other.totalCost == totalCost) &&
            (identical(other.laborCost, laborCost) ||
                other.laborCost == laborCost) &&
            (identical(other.overheadCost, overheadCost) ||
                other.overheadCost == overheadCost) &&
            (identical(other.setupCost, setupCost) ||
                other.setupCost == setupCost) &&
            (identical(other.yieldPercentage, yieldPercentage) ||
                other.yieldPercentage == yieldPercentage) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.effectiveFrom, effectiveFrom) ||
                other.effectiveFrom == effectiveFrom) &&
            (identical(other.effectiveTo, effectiveTo) ||
                other.effectiveTo == effectiveTo) &&
            const DeepCollectionEquality().equals(
                other._productionInstructions, _productionInstructions) &&
            const DeepCollectionEquality()
                .equals(other._qualityRequirements, _qualityRequirements) &&
            const DeepCollectionEquality()
                .equals(other._packagingInstructions, _packagingInstructions) &&
            const DeepCollectionEquality()
                .equals(other._alternativeBomIds, _alternativeBomIds) &&
            (identical(other.parentBomId, parentBomId) ||
                other.parentBomId == parentBomId) &&
            const DeepCollectionEquality()
                .equals(other._childBomIds, _childBomIds) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            const DeepCollectionEquality()
                .equals(other._cachedCalculations, _cachedCalculations) &&
            (identical(
                    other.calculationsLastUpdated, calculationsLastUpdated) ||
                other.calculationsLastUpdated == calculationsLastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        bomCode,
        bomName,
        productId,
        productCode,
        productName,
        bomType,
        version,
        baseQuantity,
        baseUnit,
        status,
        const DeepCollectionEquality().hash(_items),
        totalCost,
        laborCost,
        overheadCost,
        setupCost,
        yieldPercentage,
        description,
        notes,
        approvedBy,
        approvedAt,
        effectiveFrom,
        effectiveTo,
        const DeepCollectionEquality().hash(_productionInstructions),
        const DeepCollectionEquality().hash(_qualityRequirements),
        const DeepCollectionEquality().hash(_packagingInstructions),
        const DeepCollectionEquality().hash(_alternativeBomIds),
        parentBomId,
        const DeepCollectionEquality().hash(_childBomIds),
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
        const DeepCollectionEquality().hash(_cachedCalculations),
        calculationsLastUpdated
      ]);

  @override
  String toString() {
    return 'OptimizedBillOfMaterials(id: $id, bomCode: $bomCode, bomName: $bomName, productId: $productId, productCode: $productCode, productName: $productName, bomType: $bomType, version: $version, baseQuantity: $baseQuantity, baseUnit: $baseUnit, status: $status, items: $items, totalCost: $totalCost, laborCost: $laborCost, overheadCost: $overheadCost, setupCost: $setupCost, yieldPercentage: $yieldPercentage, description: $description, notes: $notes, approvedBy: $approvedBy, approvedAt: $approvedAt, effectiveFrom: $effectiveFrom, effectiveTo: $effectiveTo, productionInstructions: $productionInstructions, qualityRequirements: $qualityRequirements, packagingInstructions: $packagingInstructions, alternativeBomIds: $alternativeBomIds, parentBomId: $parentBomId, childBomIds: $childBomIds, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy, updatedBy: $updatedBy, cachedCalculations: $cachedCalculations, calculationsLastUpdated: $calculationsLastUpdated)';
  }
}

/// @nodoc
abstract mixin class _$OptimizedBillOfMaterialsCopyWith<$Res>
    implements $OptimizedBillOfMaterialsCopyWith<$Res> {
  factory _$OptimizedBillOfMaterialsCopyWith(_OptimizedBillOfMaterials value,
          $Res Function(_OptimizedBillOfMaterials) _then) =
      __$OptimizedBillOfMaterialsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String bomCode,
      String bomName,
      String productId,
      String productCode,
      String productName,
      BomType bomType,
      String version,
      double baseQuantity,
      String baseUnit,
      BomStatus status,
      List<BomItem> items,
      double totalCost,
      double laborCost,
      double overheadCost,
      double setupCost,
      double yieldPercentage,
      String? description,
      String? notes,
      String? approvedBy,
      DateTime? approvedAt,
      DateTime? effectiveFrom,
      DateTime? effectiveTo,
      Map<String, dynamic>? productionInstructions,
      Map<String, dynamic>? qualityRequirements,
      Map<String, dynamic>? packagingInstructions,
      List<String>? alternativeBomIds,
      String? parentBomId,
      List<String> childBomIds,
      DateTime createdAt,
      DateTime updatedAt,
      String? createdBy,
      String? updatedBy,
      Map<String, dynamic>? cachedCalculations,
      DateTime? calculationsLastUpdated});
}

/// @nodoc
class __$OptimizedBillOfMaterialsCopyWithImpl<$Res>
    implements _$OptimizedBillOfMaterialsCopyWith<$Res> {
  __$OptimizedBillOfMaterialsCopyWithImpl(this._self, this._then);

  final _OptimizedBillOfMaterials _self;
  final $Res Function(_OptimizedBillOfMaterials) _then;

  /// Create a copy of OptimizedBillOfMaterials
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? bomCode = null,
    Object? bomName = null,
    Object? productId = null,
    Object? productCode = null,
    Object? productName = null,
    Object? bomType = null,
    Object? version = null,
    Object? baseQuantity = null,
    Object? baseUnit = null,
    Object? status = null,
    Object? items = null,
    Object? totalCost = null,
    Object? laborCost = null,
    Object? overheadCost = null,
    Object? setupCost = null,
    Object? yieldPercentage = null,
    Object? description = freezed,
    Object? notes = freezed,
    Object? approvedBy = freezed,
    Object? approvedAt = freezed,
    Object? effectiveFrom = freezed,
    Object? effectiveTo = freezed,
    Object? productionInstructions = freezed,
    Object? qualityRequirements = freezed,
    Object? packagingInstructions = freezed,
    Object? alternativeBomIds = freezed,
    Object? parentBomId = freezed,
    Object? childBomIds = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
    Object? cachedCalculations = freezed,
    Object? calculationsLastUpdated = freezed,
  }) {
    return _then(_OptimizedBillOfMaterials(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      bomCode: null == bomCode
          ? _self.bomCode
          : bomCode // ignore: cast_nullable_to_non_nullable
              as String,
      bomName: null == bomName
          ? _self.bomName
          : bomName // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productCode: null == productCode
          ? _self.productCode
          : productCode // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _self.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      bomType: null == bomType
          ? _self.bomType
          : bomType // ignore: cast_nullable_to_non_nullable
              as BomType,
      version: null == version
          ? _self.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      baseQuantity: null == baseQuantity
          ? _self.baseQuantity
          : baseQuantity // ignore: cast_nullable_to_non_nullable
              as double,
      baseUnit: null == baseUnit
          ? _self.baseUnit
          : baseUnit // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as BomStatus,
      items: null == items
          ? _self._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<BomItem>,
      totalCost: null == totalCost
          ? _self.totalCost
          : totalCost // ignore: cast_nullable_to_non_nullable
              as double,
      laborCost: null == laborCost
          ? _self.laborCost
          : laborCost // ignore: cast_nullable_to_non_nullable
              as double,
      overheadCost: null == overheadCost
          ? _self.overheadCost
          : overheadCost // ignore: cast_nullable_to_non_nullable
              as double,
      setupCost: null == setupCost
          ? _self.setupCost
          : setupCost // ignore: cast_nullable_to_non_nullable
              as double,
      yieldPercentage: null == yieldPercentage
          ? _self.yieldPercentage
          : yieldPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedBy: freezed == approvedBy
          ? _self.approvedBy
          : approvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedAt: freezed == approvedAt
          ? _self.approvedAt
          : approvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      effectiveFrom: freezed == effectiveFrom
          ? _self.effectiveFrom
          : effectiveFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      effectiveTo: freezed == effectiveTo
          ? _self.effectiveTo
          : effectiveTo // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      productionInstructions: freezed == productionInstructions
          ? _self._productionInstructions
          : productionInstructions // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      qualityRequirements: freezed == qualityRequirements
          ? _self._qualityRequirements
          : qualityRequirements // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      packagingInstructions: freezed == packagingInstructions
          ? _self._packagingInstructions
          : packagingInstructions // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      alternativeBomIds: freezed == alternativeBomIds
          ? _self._alternativeBomIds
          : alternativeBomIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      parentBomId: freezed == parentBomId
          ? _self.parentBomId
          : parentBomId // ignore: cast_nullable_to_non_nullable
              as String?,
      childBomIds: null == childBomIds
          ? _self._childBomIds
          : childBomIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
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
      cachedCalculations: freezed == cachedCalculations
          ? _self._cachedCalculations
          : cachedCalculations // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      calculationsLastUpdated: freezed == calculationsLastUpdated
          ? _self.calculationsLastUpdated
          : calculationsLastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
