import 'package:cloud_firestore/cloud_firestore.dart';

class WarehouseLocationModel {
  WarehouseLocationModel({
    this.id,
    required this.warehouseId,
    required this.locationCode,
    required this.locationName,
    required this.locationType,
    this.zone,
    this.aisle,
    this.rack,
    this.level,
    this.bin,
    this.parentLocationId,
    this.maxWeight,
    this.maxVolume,
    this.currentWeight,
    this.currentVolume,
    this.currentItemCount,
    this.specialHandling,
    this.restrictedMaterials,
    this.temperatureZone,
    this.minTemperature,
    this.maxTemperature,
    this.requiresHumidityControl,
    this.minHumidity,
    this.maxHumidity,
    this.isActive = true,
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
  });

  // Manually implement fromJson factory
  factory WarehouseLocationModel.fromJson(Map<String, dynamic> json) {
    return WarehouseLocationModel(
      id: json['id'],
      warehouseId: json['warehouseId'],
      locationCode: json['locationCode'],
      locationName: json['locationName'],
      locationType: json['locationType'],
      zone: json['zone'],
      aisle: json['aisle'],
      rack: json['rack'],
      level: json['level'],
      bin: json['bin'],
      parentLocationId: json['parentLocationId'],
      maxWeight: json['maxWeight']?.toDouble(),
      maxVolume: json['maxVolume']?.toDouble(),
      currentWeight: json['currentWeight']?.toDouble(),
      currentVolume: json['currentVolume']?.toDouble(),
      currentItemCount: json['currentItemCount'],
      specialHandling: json['specialHandling'] != null
          ? List<String>.from(json['specialHandling'])
          : null,
      restrictedMaterials: json['restrictedMaterials'] != null
          ? List<String>.from(json['restrictedMaterials'])
          : null,
      temperatureZone: json['temperatureZone'],
      minTemperature: json['minTemperature']?.toDouble(),
      maxTemperature: json['maxTemperature']?.toDouble(),
      requiresHumidityControl: json['requiresHumidityControl'],
      minHumidity: json['minHumidity']?.toDouble(),
      maxHumidity: json['maxHumidity']?.toDouble(),
      isActive: json['isActive'] ?? true,
      isQuarantine: json['isQuarantine'] ?? false,
      isStaging: json['isStaging'] ?? false,
      isReceiving: json['isReceiving'] ?? false,
      isShipping: json['isShipping'] ?? false,
      notes: json['notes'],
      barcode: json['barcode'],
      createdBy: json['createdBy'],
      createdAt: (json['createdAt'] != null)
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedBy: json['updatedBy'],
      updatedAt: (json['updatedAt'] != null)
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
  final String? id;
  final String warehouseId;
  final String locationCode;
  final String locationName;
  final String locationType;
  final String? zone;
  final String? aisle;
  final String? rack;
  final String? level;
  final String? bin;
  final String? parentLocationId;
  final double? maxWeight;
  final double? maxVolume;
  final double? currentWeight;
  final double? currentVolume;
  final int? currentItemCount;
  final List<String>? specialHandling;
  final List<String>? restrictedMaterials;
  final String? temperatureZone;
  final double? minTemperature;
  final double? maxTemperature;
  final bool? requiresHumidityControl;
  final double? minHumidity;
  final double? maxHumidity;
  final bool isActive;
  final bool isQuarantine;
  final bool isStaging;
  final bool isReceiving;
  final bool isShipping;
  final String? notes;
  final String? barcode;
  final String? createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;

  // Manually implement toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'warehouseId': warehouseId,
      'locationCode': locationCode,
      'locationName': locationName,
      'locationType': locationType,
      'zone': zone,
      'aisle': aisle,
      'rack': rack,
      'level': level,
      'bin': bin,
      'parentLocationId': parentLocationId,
      'maxWeight': maxWeight,
      'maxVolume': maxVolume,
      'currentWeight': currentWeight,
      'currentVolume': currentVolume,
      'currentItemCount': currentItemCount,
      'specialHandling': specialHandling,
      'restrictedMaterials': restrictedMaterials,
      'temperatureZone': temperatureZone,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'requiresHumidityControl': requiresHumidityControl,
      'minHumidity': minHumidity,
      'maxHumidity': maxHumidity,
      'isActive': isActive,
      'isQuarantine': isQuarantine,
      'isStaging': isStaging,
      'isReceiving': isReceiving,
      'isShipping': isShipping,
      'notes': notes,
      'barcode': barcode,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedBy': updatedBy,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Add copyWith method for immutability
  WarehouseLocationModel copyWith({
    String? id,
    String? warehouseId,
    String? locationCode,
    String? locationName,
    String? locationType,
    String? zone,
    String? aisle,
    String? rack,
    String? level,
    String? bin,
    String? parentLocationId,
    double? maxWeight,
    double? maxVolume,
    double? currentWeight,
    double? currentVolume,
    int? currentItemCount,
    List<String>? specialHandling,
    List<String>? restrictedMaterials,
    String? temperatureZone,
    double? minTemperature,
    double? maxTemperature,
    bool? requiresHumidityControl,
    double? minHumidity,
    double? maxHumidity,
    bool? isActive,
    bool? isQuarantine,
    bool? isStaging,
    bool? isReceiving,
    bool? isShipping,
    String? notes,
    String? barcode,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return WarehouseLocationModel(
      id: id ?? this.id,
      warehouseId: warehouseId ?? this.warehouseId,
      locationCode: locationCode ?? this.locationCode,
      locationName: locationName ?? this.locationName,
      locationType: locationType ?? this.locationType,
      zone: zone ?? this.zone,
      aisle: aisle ?? this.aisle,
      rack: rack ?? this.rack,
      level: level ?? this.level,
      bin: bin ?? this.bin,
      parentLocationId: parentLocationId ?? this.parentLocationId,
      maxWeight: maxWeight ?? this.maxWeight,
      maxVolume: maxVolume ?? this.maxVolume,
      currentWeight: currentWeight ?? this.currentWeight,
      currentVolume: currentVolume ?? this.currentVolume,
      currentItemCount: currentItemCount ?? this.currentItemCount,
      specialHandling: specialHandling ?? this.specialHandling,
      restrictedMaterials: restrictedMaterials ?? this.restrictedMaterials,
      temperatureZone: temperatureZone ?? this.temperatureZone,
      minTemperature: minTemperature ?? this.minTemperature,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      requiresHumidityControl:
          requiresHumidityControl ?? this.requiresHumidityControl,
      minHumidity: minHumidity ?? this.minHumidity,
      maxHumidity: maxHumidity ?? this.maxHumidity,
      isActive: isActive ?? this.isActive,
      isQuarantine: isQuarantine ?? this.isQuarantine,
      isStaging: isStaging ?? this.isStaging,
      isReceiving: isReceiving ?? this.isReceiving,
      isShipping: isShipping ?? this.isShipping,
      notes: notes ?? this.notes,
      barcode: barcode ?? this.barcode,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WarehouseLocationModel &&
          id == other.id &&
          warehouseId == other.warehouseId &&
          locationCode == other.locationCode;

  @override
  int get hashCode =>
      id.hashCode ^ warehouseId.hashCode ^ locationCode.hashCode;
}
