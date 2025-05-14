import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_model.freezed.dart';
part 'location_model.g.dart';

/// Types of locations for storage, warehouse, and inventory
enum LocationType {
  coldStorage,
  dryStorage,
  freezer,
  productionArea,
  qualityControl,
  dispatchArea
}

@freezed
abstract class LocationModel with _$LocationModel {

  /// Storage location variant
  const factory LocationModel.storage({
    @JsonKey(name: 'location_id') required String locationId,
    @JsonKey(name: 'location_name') required String locationName,
    required double quantity,
    String? zone,
    String? aisle,
    String? rack,
    String? bin,
    String? notes,
  }) = StorageLocation;

  /// Warehouse location variant
  const factory LocationModel.warehouse({
    String? id,
    @JsonKey(name: 'warehouse_id') required String warehouseId,
    @JsonKey(name: 'location_code') required String locationCode,
    @JsonKey(name: 'location_name') required String locationName,
    @JsonKey(name: 'location_type') required String locationType,
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
    @Default(false) bool requiresHumidityControl,
    @JsonKey(name: 'min_humidity') double? minHumidity,
    @JsonKey(name: 'max_humidity') double? maxHumidity,
    required bool isActive,
    @Default(false) bool isQuarantine,
    @Default(false) bool isStaging,
    @Default(false) bool isReceiving,
    @Default(false) bool isShipping,
    String? notes,
    String? barcode,
    String? createdBy,
    required DateTime createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) = WarehouseLocation;

  /// Inventory-specific location variant
  const factory LocationModel.inventory({
    @JsonKey(name: 'location_id') required String locationId,
    @JsonKey(name: 'location_name') required String locationName,
    required LocationType locationType,
    @JsonKey(name: 'temperature_condition')
    required String temperatureCondition,
    @JsonKey(name: 'storage_capacity') required double storageCapacity,
    @JsonKey(name: 'current_utilization') required double currentUtilization,
    @JsonKey(name: 'parent_location_id') String? parentLocationId,
    required bool isActive,
  }) = InventoryLocation;

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);
  @override
  String get locationName;
}
