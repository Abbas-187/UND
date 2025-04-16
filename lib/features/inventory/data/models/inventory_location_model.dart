import 'package:meta/meta.dart';

enum LocationType {
  COLD_STORAGE,
  DRY_STORAGE,
  FREEZER,
  PRODUCTION_AREA,
  QUALITY_CONTROL,
  DISPATCH_AREA
}

@immutable
class InventoryLocationModel {
  const InventoryLocationModel({
    required this.locationId,
    required this.locationName,
    required this.locationType,
    required this.temperatureCondition,
    required this.storageCapacity,
    required this.currentUtilization,
    this.parentLocationId,
    required this.isActive,
  });

  final String locationId;
  final String locationName;
  final LocationType locationType;
  final String temperatureCondition;
  final double storageCapacity;
  final double currentUtilization;
  final String? parentLocationId;
  final bool isActive;

  double get utilizationPercentage =>
      storageCapacity > 0 ? (currentUtilization / storageCapacity) * 100 : 0;

  Map<String, dynamic> toJson() {
    return {
      'locationId': locationId,
      'locationName': locationName,
      'locationType': locationType.toString().split('.').last,
      'temperatureCondition': temperatureCondition,
      'storageCapacity': storageCapacity,
      'currentUtilization': currentUtilization,
      'parentLocationId': parentLocationId,
      'isActive': isActive,
    };
  }

  factory InventoryLocationModel.fromJson(Map<String, dynamic> json) {
    return InventoryLocationModel(
      locationId: json['locationId'] as String,
      locationName: json['locationName'] as String,
      locationType: LocationType.values.firstWhere(
        (e) => e.toString() == 'LocationType.${json['locationType']}',
        orElse: () => LocationType.COLD_STORAGE,
      ),
      temperatureCondition: json['temperatureCondition'] as String,
      storageCapacity: (json['storageCapacity'] as num).toDouble(),
      currentUtilization: (json['currentUtilization'] as num).toDouble(),
      parentLocationId: json['parentLocationId'] as String?,
      isActive: json['isActive'] as bool,
    );
  }
}
