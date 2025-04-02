enum VehicleType {
  truck,
  van,
  refrigeratedTruck,
  refrigeratedVan,
  motorcycle,
  car,
  other
}

class VehicleModel {
  VehicleModel({
    required this.id,
    required this.registrationNumber,
    required this.vehicleType,
    required this.maxCapacityKg,
    required this.maxVolumeM3,
    required this.hasTemperatureControl,
    this.minTemperature,
    this.maxTemperature,
    required this.isActive,
    this.currentDriverId,
    this.currentLocationDescription,
    this.lastLatitude,
    this.lastLongitude,
    this.lastLocationUpdate,
    this.temperatureSensorIds,
    required this.maintenanceDueDate,
    this.notes,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        id: json['id'] as String,
        registrationNumber: json['registrationNumber'] as String,
        vehicleType: VehicleType.values.firstWhere(
            (e) => e.toString() == 'VehicleType.${json['vehicleType']}'),
        maxCapacityKg: (json['maxCapacityKg'] as num).toDouble(),
        maxVolumeM3: (json['maxVolumeM3'] as num).toDouble(),
        hasTemperatureControl: json['hasTemperatureControl'] as bool,
        minTemperature: (json['minTemperature'] as num?)?.toDouble(),
        maxTemperature: (json['maxTemperature'] as num?)?.toDouble(),
        isActive: json['isActive'] as bool,
        currentDriverId: json['currentDriverId'] as String?,
        currentLocationDescription:
            json['currentLocationDescription'] as String?,
        lastLatitude: (json['lastLatitude'] as num?)?.toDouble(),
        lastLongitude: (json['lastLongitude'] as num?)?.toDouble(),
        lastLocationUpdate: json['lastLocationUpdate'] == null
            ? null
            : DateTime.parse(json['lastLocationUpdate'] as String),
        temperatureSensorIds: (json['temperatureSensorIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        maintenanceDueDate:
            DateTime.parse(json['maintenanceDueDate'] as String),
        notes: json['notes'] as String?,
      );

  final String id;
  final String registrationNumber;
  final VehicleType vehicleType;
  final double maxCapacityKg;
  final double maxVolumeM3;
  final bool hasTemperatureControl;
  final double? minTemperature;
  final double? maxTemperature;
  final bool isActive;
  final String? currentDriverId;
  final String? currentLocationDescription;
  final double? lastLatitude;
  final double? lastLongitude;
  final DateTime? lastLocationUpdate;
  final List<String>? temperatureSensorIds;
  final DateTime maintenanceDueDate;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'registrationNumber': registrationNumber,
        'vehicleType': vehicleType.toString().split('.').last,
        'maxCapacityKg': maxCapacityKg,
        'maxVolumeM3': maxVolumeM3,
        'hasTemperatureControl': hasTemperatureControl,
        'minTemperature': minTemperature,
        'maxTemperature': maxTemperature,
        'isActive': isActive,
        'currentDriverId': currentDriverId,
        'currentLocationDescription': currentLocationDescription,
        'lastLatitude': lastLatitude,
        'lastLongitude': lastLongitude,
        'lastLocationUpdate': lastLocationUpdate?.toIso8601String(),
        'temperatureSensorIds': temperatureSensorIds,
        'maintenanceDueDate': maintenanceDueDate.toIso8601String(),
        'notes': notes,
      };

  VehicleModel copyWith({
    String? id,
    String? registrationNumber,
    VehicleType? vehicleType,
    double? maxCapacityKg,
    double? maxVolumeM3,
    bool? hasTemperatureControl,
    double? minTemperature,
    double? maxTemperature,
    bool? isActive,
    String? currentDriverId,
    String? currentLocationDescription,
    double? lastLatitude,
    double? lastLongitude,
    DateTime? lastLocationUpdate,
    List<String>? temperatureSensorIds,
    DateTime? maintenanceDueDate,
    String? notes,
  }) =>
      VehicleModel(
        id: id ?? this.id,
        registrationNumber: registrationNumber ?? this.registrationNumber,
        vehicleType: vehicleType ?? this.vehicleType,
        maxCapacityKg: maxCapacityKg ?? this.maxCapacityKg,
        maxVolumeM3: maxVolumeM3 ?? this.maxVolumeM3,
        hasTemperatureControl:
            hasTemperatureControl ?? this.hasTemperatureControl,
        minTemperature: minTemperature ?? this.minTemperature,
        maxTemperature: maxTemperature ?? this.maxTemperature,
        isActive: isActive ?? this.isActive,
        currentDriverId: currentDriverId ?? this.currentDriverId,
        currentLocationDescription:
            currentLocationDescription ?? this.currentLocationDescription,
        lastLatitude: lastLatitude ?? this.lastLatitude,
        lastLongitude: lastLongitude ?? this.lastLongitude,
        lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
        temperatureSensorIds: temperatureSensorIds ?? this.temperatureSensorIds,
        maintenanceDueDate: maintenanceDueDate ?? this.maintenanceDueDate,
        notes: notes ?? this.notes,
      );
}
