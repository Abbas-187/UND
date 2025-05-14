// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorageLocation _$StorageLocationFromJson(Map<String, dynamic> json) =>
    StorageLocation(
      locationId: json['location_id'] as String,
      locationName: json['location_name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      zone: json['zone'] as String?,
      aisle: json['aisle'] as String?,
      rack: json['rack'] as String?,
      bin: json['bin'] as String?,
      notes: json['notes'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$StorageLocationToJson(StorageLocation instance) =>
    <String, dynamic>{
      'location_id': instance.locationId,
      'location_name': instance.locationName,
      'quantity': instance.quantity,
      'zone': instance.zone,
      'aisle': instance.aisle,
      'rack': instance.rack,
      'bin': instance.bin,
      'notes': instance.notes,
      'runtimeType': instance.$type,
    };

WarehouseLocation _$WarehouseLocationFromJson(Map<String, dynamic> json) =>
    WarehouseLocation(
      id: json['id'] as String?,
      warehouseId: json['warehouse_id'] as String,
      locationCode: json['location_code'] as String,
      locationName: json['location_name'] as String,
      locationType: json['location_type'] as String,
      zone: json['zone'] as String?,
      aisle: json['aisle'] as String?,
      rack: json['rack'] as String?,
      level: json['level'] as String?,
      bin: json['bin'] as String?,
      parentLocationId: json['parent_location_id'] as String?,
      maxWeight: (json['max_weight'] as num?)?.toDouble(),
      maxVolume: (json['max_volume'] as num?)?.toDouble(),
      currentWeight: (json['current_weight'] as num?)?.toDouble(),
      currentVolume: (json['current_volume'] as num?)?.toDouble(),
      currentItemCount: (json['current_item_count'] as num?)?.toInt(),
      specialHandling: (json['special_handling'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      restrictedMaterials: (json['restricted_materials'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      temperatureZone: json['temperature_zone'] as String?,
      minTemperature: (json['min_temperature'] as num?)?.toDouble(),
      maxTemperature: (json['max_temperature'] as num?)?.toDouble(),
      requiresHumidityControl:
          json['requires_humidity_control'] as bool? ?? false,
      minHumidity: (json['min_humidity'] as num?)?.toDouble(),
      maxHumidity: (json['max_humidity'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool,
      isQuarantine: json['is_quarantine'] as bool? ?? false,
      isStaging: json['is_staging'] as bool? ?? false,
      isReceiving: json['is_receiving'] as bool? ?? false,
      isShipping: json['is_shipping'] as bool? ?? false,
      notes: json['notes'] as String?,
      barcode: json['barcode'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedBy: json['updated_by'] as String?,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$WarehouseLocationToJson(WarehouseLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'warehouse_id': instance.warehouseId,
      'location_code': instance.locationCode,
      'location_name': instance.locationName,
      'location_type': instance.locationType,
      'zone': instance.zone,
      'aisle': instance.aisle,
      'rack': instance.rack,
      'level': instance.level,
      'bin': instance.bin,
      'parent_location_id': instance.parentLocationId,
      'max_weight': instance.maxWeight,
      'max_volume': instance.maxVolume,
      'current_weight': instance.currentWeight,
      'current_volume': instance.currentVolume,
      'current_item_count': instance.currentItemCount,
      'special_handling': instance.specialHandling,
      'restricted_materials': instance.restrictedMaterials,
      'temperature_zone': instance.temperatureZone,
      'min_temperature': instance.minTemperature,
      'max_temperature': instance.maxTemperature,
      'requires_humidity_control': instance.requiresHumidityControl,
      'min_humidity': instance.minHumidity,
      'max_humidity': instance.maxHumidity,
      'is_active': instance.isActive,
      'is_quarantine': instance.isQuarantine,
      'is_staging': instance.isStaging,
      'is_receiving': instance.isReceiving,
      'is_shipping': instance.isShipping,
      'notes': instance.notes,
      'barcode': instance.barcode,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_by': instance.updatedBy,
      'updated_at': instance.updatedAt?.toIso8601String(),
      'runtimeType': instance.$type,
    };

InventoryLocation _$InventoryLocationFromJson(Map<String, dynamic> json) =>
    InventoryLocation(
      locationId: json['location_id'] as String,
      locationName: json['location_name'] as String,
      locationType: $enumDecode(_$LocationTypeEnumMap, json['location_type']),
      temperatureCondition: json['temperature_condition'] as String,
      storageCapacity: (json['storage_capacity'] as num).toDouble(),
      currentUtilization: (json['current_utilization'] as num).toDouble(),
      parentLocationId: json['parent_location_id'] as String?,
      isActive: json['is_active'] as bool,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$InventoryLocationToJson(InventoryLocation instance) =>
    <String, dynamic>{
      'location_id': instance.locationId,
      'location_name': instance.locationName,
      'location_type': _$LocationTypeEnumMap[instance.locationType]!,
      'temperature_condition': instance.temperatureCondition,
      'storage_capacity': instance.storageCapacity,
      'current_utilization': instance.currentUtilization,
      'parent_location_id': instance.parentLocationId,
      'is_active': instance.isActive,
      'runtimeType': instance.$type,
    };

const _$LocationTypeEnumMap = {
  LocationType.coldStorage: 'coldStorage',
  LocationType.dryStorage: 'dryStorage',
  LocationType.freezer: 'freezer',
  LocationType.productionArea: 'productionArea',
  LocationType.qualityControl: 'qualityControl',
  LocationType.dispatchArea: 'dispatchArea',
};
