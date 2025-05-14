// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
LocationModel _$LocationModelFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'storage':
      return StorageLocation.fromJson(json);
    case 'warehouse':
      return WarehouseLocation.fromJson(json);
    case 'inventory':
      return InventoryLocation.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'LocationModel',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$LocationModel {
  @JsonKey(name: 'location_name')
  String get locationName;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LocationModelCopyWith<LocationModel> get copyWith =>
      _$LocationModelCopyWithImpl<LocationModel>(
          this as LocationModel, _$identity);

  /// Serializes this LocationModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LocationModel &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, locationName);

  @override
  String toString() {
    return 'LocationModel(locationName: $locationName)';
  }
}

/// @nodoc
abstract mixin class $LocationModelCopyWith<$Res> {
  factory $LocationModelCopyWith(
          LocationModel value, $Res Function(LocationModel) _then) =
      _$LocationModelCopyWithImpl;
  @useResult
  $Res call({@JsonKey(name: 'location_name') String locationName});
}

/// @nodoc
class _$LocationModelCopyWithImpl<$Res>
    implements $LocationModelCopyWith<$Res> {
  _$LocationModelCopyWithImpl(this._self, this._then);

  final LocationModel _self;
  final $Res Function(LocationModel) _then;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locationName = null,
  }) {
    return _then(_self.copyWith(
      locationName: null == locationName
          ? _self.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class StorageLocation implements LocationModel {
  const StorageLocation(
      {@JsonKey(name: 'location_id') required this.locationId,
      @JsonKey(name: 'location_name') required this.locationName,
      required this.quantity,
      this.zone,
      this.aisle,
      this.rack,
      this.bin,
      this.notes,
      final String? $type})
      : $type = $type ?? 'storage';
  factory StorageLocation.fromJson(Map<String, dynamic> json) =>
      _$StorageLocationFromJson(json);

  @JsonKey(name: 'location_id')
  final String locationId;
  @override
  @JsonKey(name: 'location_name')
  final String locationName;
  final double quantity;
  final String? zone;
  final String? aisle;
  final String? rack;
  final String? bin;
  final String? notes;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StorageLocationCopyWith<StorageLocation> get copyWith =>
      _$StorageLocationCopyWithImpl<StorageLocation>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$StorageLocationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StorageLocation &&
            (identical(other.locationId, locationId) ||
                other.locationId == locationId) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.zone, zone) || other.zone == zone) &&
            (identical(other.aisle, aisle) || other.aisle == aisle) &&
            (identical(other.rack, rack) || other.rack == rack) &&
            (identical(other.bin, bin) || other.bin == bin) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, locationId, locationName,
      quantity, zone, aisle, rack, bin, notes);

  @override
  String toString() {
    return 'LocationModel.storage(locationId: $locationId, locationName: $locationName, quantity: $quantity, zone: $zone, aisle: $aisle, rack: $rack, bin: $bin, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class $StorageLocationCopyWith<$Res>
    implements $LocationModelCopyWith<$Res> {
  factory $StorageLocationCopyWith(
          StorageLocation value, $Res Function(StorageLocation) _then) =
      _$StorageLocationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'location_id') String locationId,
      @JsonKey(name: 'location_name') String locationName,
      double quantity,
      String? zone,
      String? aisle,
      String? rack,
      String? bin,
      String? notes});
}

/// @nodoc
class _$StorageLocationCopyWithImpl<$Res>
    implements $StorageLocationCopyWith<$Res> {
  _$StorageLocationCopyWithImpl(this._self, this._then);

  final StorageLocation _self;
  final $Res Function(StorageLocation) _then;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? locationId = null,
    Object? locationName = null,
    Object? quantity = null,
    Object? zone = freezed,
    Object? aisle = freezed,
    Object? rack = freezed,
    Object? bin = freezed,
    Object? notes = freezed,
  }) {
    return _then(StorageLocation(
      locationId: null == locationId
          ? _self.locationId
          : locationId // ignore: cast_nullable_to_non_nullable
              as String,
      locationName: null == locationName
          ? _self.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      zone: freezed == zone
          ? _self.zone
          : zone // ignore: cast_nullable_to_non_nullable
              as String?,
      aisle: freezed == aisle
          ? _self.aisle
          : aisle // ignore: cast_nullable_to_non_nullable
              as String?,
      rack: freezed == rack
          ? _self.rack
          : rack // ignore: cast_nullable_to_non_nullable
              as String?,
      bin: freezed == bin
          ? _self.bin
          : bin // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class WarehouseLocation implements LocationModel {
  const WarehouseLocation(
      {this.id,
      @JsonKey(name: 'warehouse_id') required this.warehouseId,
      @JsonKey(name: 'location_code') required this.locationCode,
      @JsonKey(name: 'location_name') required this.locationName,
      @JsonKey(name: 'location_type') required this.locationType,
      this.zone,
      this.aisle,
      this.rack,
      this.level,
      this.bin,
      @JsonKey(name: 'parent_location_id') this.parentLocationId,
      @JsonKey(name: 'max_weight') this.maxWeight,
      @JsonKey(name: 'max_volume') this.maxVolume,
      @JsonKey(name: 'current_weight') this.currentWeight,
      @JsonKey(name: 'current_volume') this.currentVolume,
      @JsonKey(name: 'current_item_count') this.currentItemCount,
      @JsonKey(name: 'special_handling') final List<String>? specialHandling,
      @JsonKey(name: 'restricted_materials')
      final List<String>? restrictedMaterials,
      @JsonKey(name: 'temperature_zone') this.temperatureZone,
      @JsonKey(name: 'min_temperature') this.minTemperature,
      @JsonKey(name: 'max_temperature') this.maxTemperature,
      this.requiresHumidityControl = false,
      @JsonKey(name: 'min_humidity') this.minHumidity,
      @JsonKey(name: 'max_humidity') this.maxHumidity,
      required this.isActive,
      this.isQuarantine = false,
      this.isStaging = false,
      this.isReceiving = false,
      this.isShipping = false,
      this.notes,
      this.barcode,
      this.createdBy,
      required this.createdAt,
      this.updatedBy,
      this.updatedAt,
      final String? $type})
      : _specialHandling = specialHandling,
        _restrictedMaterials = restrictedMaterials,
        $type = $type ?? 'warehouse';
  factory WarehouseLocation.fromJson(Map<String, dynamic> json) =>
      _$WarehouseLocationFromJson(json);

  final String? id;
  @JsonKey(name: 'warehouse_id')
  final String warehouseId;
  @JsonKey(name: 'location_code')
  final String locationCode;
  @override
  @JsonKey(name: 'location_name')
  final String locationName;
  @JsonKey(name: 'location_type')
  final String locationType;
  final String? zone;
  final String? aisle;
  final String? rack;
  final String? level;
  final String? bin;
  @JsonKey(name: 'parent_location_id')
  final String? parentLocationId;
  @JsonKey(name: 'max_weight')
  final double? maxWeight;
  @JsonKey(name: 'max_volume')
  final double? maxVolume;
  @JsonKey(name: 'current_weight')
  final double? currentWeight;
  @JsonKey(name: 'current_volume')
  final double? currentVolume;
  @JsonKey(name: 'current_item_count')
  final int? currentItemCount;
  final List<String>? _specialHandling;
  @JsonKey(name: 'special_handling')
  List<String>? get specialHandling {
    final value = _specialHandling;
    if (value == null) return null;
    if (_specialHandling is EqualUnmodifiableListView) return _specialHandling;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _restrictedMaterials;
  @JsonKey(name: 'restricted_materials')
  List<String>? get restrictedMaterials {
    final value = _restrictedMaterials;
    if (value == null) return null;
    if (_restrictedMaterials is EqualUnmodifiableListView)
      return _restrictedMaterials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @JsonKey(name: 'temperature_zone')
  final String? temperatureZone;
  @JsonKey(name: 'min_temperature')
  final double? minTemperature;
  @JsonKey(name: 'max_temperature')
  final double? maxTemperature;
  @JsonKey()
  final bool requiresHumidityControl;
  @JsonKey(name: 'min_humidity')
  final double? minHumidity;
  @JsonKey(name: 'max_humidity')
  final double? maxHumidity;
  final bool isActive;
  @JsonKey()
  final bool isQuarantine;
  @JsonKey()
  final bool isStaging;
  @JsonKey()
  final bool isReceiving;
  @JsonKey()
  final bool isShipping;
  final String? notes;
  final String? barcode;
  final String? createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WarehouseLocationCopyWith<WarehouseLocation> get copyWith =>
      _$WarehouseLocationCopyWithImpl<WarehouseLocation>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WarehouseLocationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WarehouseLocation &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.locationCode, locationCode) ||
                other.locationCode == locationCode) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.locationType, locationType) ||
                other.locationType == locationType) &&
            (identical(other.zone, zone) || other.zone == zone) &&
            (identical(other.aisle, aisle) || other.aisle == aisle) &&
            (identical(other.rack, rack) || other.rack == rack) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.bin, bin) || other.bin == bin) &&
            (identical(other.parentLocationId, parentLocationId) ||
                other.parentLocationId == parentLocationId) &&
            (identical(other.maxWeight, maxWeight) ||
                other.maxWeight == maxWeight) &&
            (identical(other.maxVolume, maxVolume) ||
                other.maxVolume == maxVolume) &&
            (identical(other.currentWeight, currentWeight) ||
                other.currentWeight == currentWeight) &&
            (identical(other.currentVolume, currentVolume) ||
                other.currentVolume == currentVolume) &&
            (identical(other.currentItemCount, currentItemCount) ||
                other.currentItemCount == currentItemCount) &&
            const DeepCollectionEquality()
                .equals(other._specialHandling, _specialHandling) &&
            const DeepCollectionEquality()
                .equals(other._restrictedMaterials, _restrictedMaterials) &&
            (identical(other.temperatureZone, temperatureZone) ||
                other.temperatureZone == temperatureZone) &&
            (identical(other.minTemperature, minTemperature) ||
                other.minTemperature == minTemperature) &&
            (identical(other.maxTemperature, maxTemperature) ||
                other.maxTemperature == maxTemperature) &&
            (identical(
                    other.requiresHumidityControl, requiresHumidityControl) ||
                other.requiresHumidityControl == requiresHumidityControl) &&
            (identical(other.minHumidity, minHumidity) ||
                other.minHumidity == minHumidity) &&
            (identical(other.maxHumidity, maxHumidity) ||
                other.maxHumidity == maxHumidity) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isQuarantine, isQuarantine) ||
                other.isQuarantine == isQuarantine) &&
            (identical(other.isStaging, isStaging) ||
                other.isStaging == isStaging) &&
            (identical(other.isReceiving, isReceiving) ||
                other.isReceiving == isReceiving) &&
            (identical(other.isShipping, isShipping) ||
                other.isShipping == isShipping) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        warehouseId,
        locationCode,
        locationName,
        locationType,
        zone,
        aisle,
        rack,
        level,
        bin,
        parentLocationId,
        maxWeight,
        maxVolume,
        currentWeight,
        currentVolume,
        currentItemCount,
        const DeepCollectionEquality().hash(_specialHandling),
        const DeepCollectionEquality().hash(_restrictedMaterials),
        temperatureZone,
        minTemperature,
        maxTemperature,
        requiresHumidityControl,
        minHumidity,
        maxHumidity,
        isActive,
        isQuarantine,
        isStaging,
        isReceiving,
        isShipping,
        notes,
        barcode,
        createdBy,
        createdAt,
        updatedBy,
        updatedAt
      ]);

  @override
  String toString() {
    return 'LocationModel.warehouse(id: $id, warehouseId: $warehouseId, locationCode: $locationCode, locationName: $locationName, locationType: $locationType, zone: $zone, aisle: $aisle, rack: $rack, level: $level, bin: $bin, parentLocationId: $parentLocationId, maxWeight: $maxWeight, maxVolume: $maxVolume, currentWeight: $currentWeight, currentVolume: $currentVolume, currentItemCount: $currentItemCount, specialHandling: $specialHandling, restrictedMaterials: $restrictedMaterials, temperatureZone: $temperatureZone, minTemperature: $minTemperature, maxTemperature: $maxTemperature, requiresHumidityControl: $requiresHumidityControl, minHumidity: $minHumidity, maxHumidity: $maxHumidity, isActive: $isActive, isQuarantine: $isQuarantine, isStaging: $isStaging, isReceiving: $isReceiving, isShipping: $isShipping, notes: $notes, barcode: $barcode, createdBy: $createdBy, createdAt: $createdAt, updatedBy: $updatedBy, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $WarehouseLocationCopyWith<$Res>
    implements $LocationModelCopyWith<$Res> {
  factory $WarehouseLocationCopyWith(
          WarehouseLocation value, $Res Function(WarehouseLocation) _then) =
      _$WarehouseLocationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'warehouse_id') String warehouseId,
      @JsonKey(name: 'location_code') String locationCode,
      @JsonKey(name: 'location_name') String locationName,
      @JsonKey(name: 'location_type') String locationType,
      String? zone,
      String? aisle,
      String? rack,
      String? level,
      String? bin,
      @JsonKey(name: 'parent_location_id') String? parentLocationId,
      @JsonKey(name: 'max_weight') double? maxWeight,
      @JsonKey(name: 'max_volume') double? maxVolume,
      @JsonKey(name: 'current_weight') double? currentWeight,
      @JsonKey(name: 'current_volume') double? currentVolume,
      @JsonKey(name: 'current_item_count') int? currentItemCount,
      @JsonKey(name: 'special_handling') List<String>? specialHandling,
      @JsonKey(name: 'restricted_materials') List<String>? restrictedMaterials,
      @JsonKey(name: 'temperature_zone') String? temperatureZone,
      @JsonKey(name: 'min_temperature') double? minTemperature,
      @JsonKey(name: 'max_temperature') double? maxTemperature,
      bool requiresHumidityControl,
      @JsonKey(name: 'min_humidity') double? minHumidity,
      @JsonKey(name: 'max_humidity') double? maxHumidity,
      bool isActive,
      bool isQuarantine,
      bool isStaging,
      bool isReceiving,
      bool isShipping,
      String? notes,
      String? barcode,
      String? createdBy,
      DateTime createdAt,
      String? updatedBy,
      DateTime? updatedAt});
}

/// @nodoc
class _$WarehouseLocationCopyWithImpl<$Res>
    implements $WarehouseLocationCopyWith<$Res> {
  _$WarehouseLocationCopyWithImpl(this._self, this._then);

  final WarehouseLocation _self;
  final $Res Function(WarehouseLocation) _then;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? warehouseId = null,
    Object? locationCode = null,
    Object? locationName = null,
    Object? locationType = null,
    Object? zone = freezed,
    Object? aisle = freezed,
    Object? rack = freezed,
    Object? level = freezed,
    Object? bin = freezed,
    Object? parentLocationId = freezed,
    Object? maxWeight = freezed,
    Object? maxVolume = freezed,
    Object? currentWeight = freezed,
    Object? currentVolume = freezed,
    Object? currentItemCount = freezed,
    Object? specialHandling = freezed,
    Object? restrictedMaterials = freezed,
    Object? temperatureZone = freezed,
    Object? minTemperature = freezed,
    Object? maxTemperature = freezed,
    Object? requiresHumidityControl = null,
    Object? minHumidity = freezed,
    Object? maxHumidity = freezed,
    Object? isActive = null,
    Object? isQuarantine = null,
    Object? isStaging = null,
    Object? isReceiving = null,
    Object? isShipping = null,
    Object? notes = freezed,
    Object? barcode = freezed,
    Object? createdBy = freezed,
    Object? createdAt = null,
    Object? updatedBy = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(WarehouseLocation(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      warehouseId: null == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String,
      locationCode: null == locationCode
          ? _self.locationCode
          : locationCode // ignore: cast_nullable_to_non_nullable
              as String,
      locationName: null == locationName
          ? _self.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String,
      locationType: null == locationType
          ? _self.locationType
          : locationType // ignore: cast_nullable_to_non_nullable
              as String,
      zone: freezed == zone
          ? _self.zone
          : zone // ignore: cast_nullable_to_non_nullable
              as String?,
      aisle: freezed == aisle
          ? _self.aisle
          : aisle // ignore: cast_nullable_to_non_nullable
              as String?,
      rack: freezed == rack
          ? _self.rack
          : rack // ignore: cast_nullable_to_non_nullable
              as String?,
      level: freezed == level
          ? _self.level
          : level // ignore: cast_nullable_to_non_nullable
              as String?,
      bin: freezed == bin
          ? _self.bin
          : bin // ignore: cast_nullable_to_non_nullable
              as String?,
      parentLocationId: freezed == parentLocationId
          ? _self.parentLocationId
          : parentLocationId // ignore: cast_nullable_to_non_nullable
              as String?,
      maxWeight: freezed == maxWeight
          ? _self.maxWeight
          : maxWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      maxVolume: freezed == maxVolume
          ? _self.maxVolume
          : maxVolume // ignore: cast_nullable_to_non_nullable
              as double?,
      currentWeight: freezed == currentWeight
          ? _self.currentWeight
          : currentWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      currentVolume: freezed == currentVolume
          ? _self.currentVolume
          : currentVolume // ignore: cast_nullable_to_non_nullable
              as double?,
      currentItemCount: freezed == currentItemCount
          ? _self.currentItemCount
          : currentItemCount // ignore: cast_nullable_to_non_nullable
              as int?,
      specialHandling: freezed == specialHandling
          ? _self._specialHandling
          : specialHandling // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      restrictedMaterials: freezed == restrictedMaterials
          ? _self._restrictedMaterials
          : restrictedMaterials // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      temperatureZone: freezed == temperatureZone
          ? _self.temperatureZone
          : temperatureZone // ignore: cast_nullable_to_non_nullable
              as String?,
      minTemperature: freezed == minTemperature
          ? _self.minTemperature
          : minTemperature // ignore: cast_nullable_to_non_nullable
              as double?,
      maxTemperature: freezed == maxTemperature
          ? _self.maxTemperature
          : maxTemperature // ignore: cast_nullable_to_non_nullable
              as double?,
      requiresHumidityControl: null == requiresHumidityControl
          ? _self.requiresHumidityControl
          : requiresHumidityControl // ignore: cast_nullable_to_non_nullable
              as bool,
      minHumidity: freezed == minHumidity
          ? _self.minHumidity
          : minHumidity // ignore: cast_nullable_to_non_nullable
              as double?,
      maxHumidity: freezed == maxHumidity
          ? _self.maxHumidity
          : maxHumidity // ignore: cast_nullable_to_non_nullable
              as double?,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isQuarantine: null == isQuarantine
          ? _self.isQuarantine
          : isQuarantine // ignore: cast_nullable_to_non_nullable
              as bool,
      isStaging: null == isStaging
          ? _self.isStaging
          : isStaging // ignore: cast_nullable_to_non_nullable
              as bool,
      isReceiving: null == isReceiving
          ? _self.isReceiving
          : isReceiving // ignore: cast_nullable_to_non_nullable
              as bool,
      isShipping: null == isShipping
          ? _self.isShipping
          : isShipping // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _self.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _self.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedBy: freezed == updatedBy
          ? _self.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class InventoryLocation implements LocationModel {
  const InventoryLocation(
      {@JsonKey(name: 'location_id') required this.locationId,
      @JsonKey(name: 'location_name') required this.locationName,
      required this.locationType,
      @JsonKey(name: 'temperature_condition')
      required this.temperatureCondition,
      @JsonKey(name: 'storage_capacity') required this.storageCapacity,
      @JsonKey(name: 'current_utilization') required this.currentUtilization,
      @JsonKey(name: 'parent_location_id') this.parentLocationId,
      required this.isActive,
      final String? $type})
      : $type = $type ?? 'inventory';
  factory InventoryLocation.fromJson(Map<String, dynamic> json) =>
      _$InventoryLocationFromJson(json);

  @JsonKey(name: 'location_id')
  final String locationId;
  @override
  @JsonKey(name: 'location_name')
  final String locationName;
  final LocationType locationType;
  @JsonKey(name: 'temperature_condition')
  final String temperatureCondition;
  @JsonKey(name: 'storage_capacity')
  final double storageCapacity;
  @JsonKey(name: 'current_utilization')
  final double currentUtilization;
  @JsonKey(name: 'parent_location_id')
  final String? parentLocationId;
  final bool isActive;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InventoryLocationCopyWith<InventoryLocation> get copyWith =>
      _$InventoryLocationCopyWithImpl<InventoryLocation>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$InventoryLocationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InventoryLocation &&
            (identical(other.locationId, locationId) ||
                other.locationId == locationId) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.locationType, locationType) ||
                other.locationType == locationType) &&
            (identical(other.temperatureCondition, temperatureCondition) ||
                other.temperatureCondition == temperatureCondition) &&
            (identical(other.storageCapacity, storageCapacity) ||
                other.storageCapacity == storageCapacity) &&
            (identical(other.currentUtilization, currentUtilization) ||
                other.currentUtilization == currentUtilization) &&
            (identical(other.parentLocationId, parentLocationId) ||
                other.parentLocationId == parentLocationId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      locationId,
      locationName,
      locationType,
      temperatureCondition,
      storageCapacity,
      currentUtilization,
      parentLocationId,
      isActive);

  @override
  String toString() {
    return 'LocationModel.inventory(locationId: $locationId, locationName: $locationName, locationType: $locationType, temperatureCondition: $temperatureCondition, storageCapacity: $storageCapacity, currentUtilization: $currentUtilization, parentLocationId: $parentLocationId, isActive: $isActive)';
  }
}

/// @nodoc
abstract mixin class $InventoryLocationCopyWith<$Res>
    implements $LocationModelCopyWith<$Res> {
  factory $InventoryLocationCopyWith(
          InventoryLocation value, $Res Function(InventoryLocation) _then) =
      _$InventoryLocationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'location_id') String locationId,
      @JsonKey(name: 'location_name') String locationName,
      LocationType locationType,
      @JsonKey(name: 'temperature_condition') String temperatureCondition,
      @JsonKey(name: 'storage_capacity') double storageCapacity,
      @JsonKey(name: 'current_utilization') double currentUtilization,
      @JsonKey(name: 'parent_location_id') String? parentLocationId,
      bool isActive});
}

/// @nodoc
class _$InventoryLocationCopyWithImpl<$Res>
    implements $InventoryLocationCopyWith<$Res> {
  _$InventoryLocationCopyWithImpl(this._self, this._then);

  final InventoryLocation _self;
  final $Res Function(InventoryLocation) _then;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? locationId = null,
    Object? locationName = null,
    Object? locationType = null,
    Object? temperatureCondition = null,
    Object? storageCapacity = null,
    Object? currentUtilization = null,
    Object? parentLocationId = freezed,
    Object? isActive = null,
  }) {
    return _then(InventoryLocation(
      locationId: null == locationId
          ? _self.locationId
          : locationId // ignore: cast_nullable_to_non_nullable
              as String,
      locationName: null == locationName
          ? _self.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String,
      locationType: null == locationType
          ? _self.locationType
          : locationType // ignore: cast_nullable_to_non_nullable
              as LocationType,
      temperatureCondition: null == temperatureCondition
          ? _self.temperatureCondition
          : temperatureCondition // ignore: cast_nullable_to_non_nullable
              as String,
      storageCapacity: null == storageCapacity
          ? _self.storageCapacity
          : storageCapacity // ignore: cast_nullable_to_non_nullable
              as double,
      currentUtilization: null == currentUtilization
          ? _self.currentUtilization
          : currentUtilization // ignore: cast_nullable_to_non_nullable
              as double,
      parentLocationId: freezed == parentLocationId
          ? _self.parentLocationId
          : parentLocationId // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
