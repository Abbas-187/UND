import 'package:cloud_firestore/cloud_firestore.dart';

class WarehouseLocationModel {
  const WarehouseLocationModel({
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
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  factory WarehouseLocationModel.fromJson(Map<String, dynamic> json) {
    return WarehouseLocationModel(
      id: json['id'] as String?,
      warehouseId: json['warehouseId'] as String,
      locationCode: json['locationCode'] as String,
      locationName: json['locationName'] as String,
      locationType: json['locationType'] as String,
      zone: json['zone'] as String?,
      aisle: json['aisle'] as String?,
      rack: json['rack'] as String?,
      level: json['level'] as String?,
      bin: json['bin'] as String?,
      parentLocationId: json['parentLocationId'] as String?,
      maxWeight: json['maxWeight'] != null
          ? (json['maxWeight'] as num).toDouble()
          : null,
      maxVolume: json['maxVolume'] != null
          ? (json['maxVolume'] as num).toDouble()
          : null,
      currentWeight: json['currentWeight'] != null
          ? (json['currentWeight'] as num).toDouble()
          : null,
      currentVolume: json['currentVolume'] != null
          ? (json['currentVolume'] as num).toDouble()
          : null,
      currentItemCount: json['currentItemCount'] as int?,
      specialHandling:
          (json['specialHandling'] as List<dynamic>?)?.cast<String>(),
      restrictedMaterials:
          (json['restrictedMaterials'] as List<dynamic>?)?.cast<String>(),
      temperatureZone: json['temperatureZone'] as String?,
      minTemperature: json['minTemperature'] != null
          ? (json['minTemperature'] as num).toDouble()
          : null,
      maxTemperature: json['maxTemperature'] != null
          ? (json['maxTemperature'] as num).toDouble()
          : null,
      requiresHumidityControl: json['requiresHumidityControl'] as bool?,
      minHumidity: json['minHumidity'] != null
          ? (json['minHumidity'] as num).toDouble()
          : null,
      maxHumidity: json['maxHumidity'] != null
          ? (json['maxHumidity'] as num).toDouble()
          : null,
      isActive: json['isActive'] as bool? ?? true,
      isQuarantine: json['isQuarantine'] as bool? ?? false,
      isStaging: json['isStaging'] as bool? ?? false,
      isReceiving: json['isReceiving'] as bool? ?? false,
      isShipping: json['isShipping'] as bool? ?? false,
      notes: json['notes'] as String?,
      barcode: json['barcode'] as String?,
      createdBy: json['createdBy'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedBy: json['updatedBy'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  factory WarehouseLocationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WarehouseLocationModel.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      'updatedAt': data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    });
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
  final DateTime? createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;

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
      'createdAt': createdAt?.toIso8601String(),
      'updatedBy': updatedBy,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
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
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedBy': updatedBy,
      'updatedAt':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : Timestamp.now(),
    };
  }

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
}
