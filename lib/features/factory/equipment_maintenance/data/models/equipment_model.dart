/// This model is a regular immutable class rather than a freezed model to
/// simplify the implementation.
library;

import 'package:meta/meta.dart';

enum EquipmentType {
  pasteurizer,
  homogenizer,
  separator,
  tank,
  vat,
  packagingMachine,
  coolingSystem,
  cIP, // Clean-In-Place
  pump,
  butter_churn,
  cheese_vat,
  cheese_press,
  incubator,
  refrigerator,
  laboratory,
  other,
}

enum EquipmentStatus {
  operational,
  maintenance,
  repair,
  sanitization,
  inactive,
  retired,
  standby,
}

/// Equipment model for dairy processing equipment
@immutable
class EquipmentModel {
  const EquipmentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.locationId,
    required this.locationName,
    required this.manufacturer,
    required this.model,
    required this.serialNumber,
    required this.installDate,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    required this.maintenanceIntervalDays,
    this.responsiblePersonId,
    this.responsiblePersonName,
    this.lastSanitizationDate,
    required this.sanitizationIntervalHours,
    required this.requiresSanitization,
    required this.runningHoursTotal,
    this.runningHoursSinceLastMaintenance,
    required this.specifications,
    required this.metadata,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: EquipmentType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => EquipmentType.other,
      ),
      status: EquipmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => EquipmentStatus.inactive,
      ),
      locationId: json['locationId'] as String,
      locationName: json['locationName'] as String,
      manufacturer: json['manufacturer'] as String,
      model: json['model'] as String,
      serialNumber: json['serialNumber'] as String,
      installDate: DateTime.parse(json['installDate'] as String),
      lastMaintenanceDate: json['lastMaintenanceDate'] != null
          ? DateTime.parse(json['lastMaintenanceDate'] as String)
          : null,
      nextMaintenanceDate: json['nextMaintenanceDate'] != null
          ? DateTime.parse(json['nextMaintenanceDate'] as String)
          : null,
      maintenanceIntervalDays: json['maintenanceIntervalDays'] as int,
      responsiblePersonId: json['responsiblePersonId'] as String?,
      responsiblePersonName: json['responsiblePersonName'] as String?,
      lastSanitizationDate: json['lastSanitizationDate'] != null
          ? DateTime.parse(json['lastSanitizationDate'] as String)
          : null,
      sanitizationIntervalHours: json['sanitizationIntervalHours'] as int,
      requiresSanitization: json['requiresSanitization'] as bool,
      runningHoursTotal: (json['runningHoursTotal'] as num).toDouble(),
      runningHoursSinceLastMaintenance:
          json['runningHoursSinceLastMaintenance'] != null
              ? (json['runningHoursSinceLastMaintenance'] as num).toDouble()
              : null,
      specifications: json['specifications'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }

  static EquipmentModel dummy() {
    return EquipmentModel(
      id: 'dummy',
      name: 'Dummy Equipment',
      type: EquipmentType.other,
      status: EquipmentStatus.inactive,
      locationId: 'dummy-location',
      locationName: 'Dummy Location',
      manufacturer: 'Dummy Manufacturer',
      model: 'Dummy Model',
      serialNumber: '0000',
      installDate: DateTime(2000, 1, 1),
      lastMaintenanceDate: null,
      nextMaintenanceDate: null,
      maintenanceIntervalDays: 30,
      responsiblePersonId: null,
      responsiblePersonName: null,
      lastSanitizationDate: null,
      sanitizationIntervalHours: 24,
      requiresSanitization: false,
      runningHoursTotal: 0.0,
      runningHoursSinceLastMaintenance: null,
      specifications: const {},
      metadata: const {},
    );
  }

  final String id;
  final String name;
  final EquipmentType type;
  final EquipmentStatus status;
  final String locationId;
  final String locationName;
  final String manufacturer;
  final String model;
  final String serialNumber;
  final DateTime installDate;
  final DateTime? lastMaintenanceDate;
  final DateTime? nextMaintenanceDate;
  final int maintenanceIntervalDays;
  final String? responsiblePersonId;
  final String? responsiblePersonName;
  final DateTime? lastSanitizationDate;
  final int sanitizationIntervalHours;
  final bool requiresSanitization;
  final double runningHoursTotal;
  final double? runningHoursSinceLastMaintenance;
  final Map<String, dynamic> specifications;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'locationId': locationId,
      'locationName': locationName,
      'manufacturer': manufacturer,
      'model': model,
      'serialNumber': serialNumber,
      'installDate': installDate.toIso8601String(),
      'lastMaintenanceDate': lastMaintenanceDate?.toIso8601String(),
      'nextMaintenanceDate': nextMaintenanceDate?.toIso8601String(),
      'maintenanceIntervalDays': maintenanceIntervalDays,
      'responsiblePersonId': responsiblePersonId,
      'responsiblePersonName': responsiblePersonName,
      'lastSanitizationDate': lastSanitizationDate?.toIso8601String(),
      'sanitizationIntervalHours': sanitizationIntervalHours,
      'requiresSanitization': requiresSanitization,
      'runningHoursTotal': runningHoursTotal,
      'runningHoursSinceLastMaintenance': runningHoursSinceLastMaintenance,
      'specifications': specifications,
      'metadata': metadata,
    };
  }

  EquipmentModel copyWith({
    String? id,
    String? name,
    EquipmentType? type,
    EquipmentStatus? status,
    String? locationId,
    String? locationName,
    String? manufacturer,
    String? model,
    String? serialNumber,
    DateTime? installDate,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    int? maintenanceIntervalDays,
    String? responsiblePersonId,
    String? responsiblePersonName,
    DateTime? lastSanitizationDate,
    int? sanitizationIntervalHours,
    bool? requiresSanitization,
    double? runningHoursTotal,
    double? runningHoursSinceLastMaintenance,
    Map<String, dynamic>? specifications,
    Map<String, dynamic>? metadata,
  }) {
    return EquipmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      installDate: installDate ?? this.installDate,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      maintenanceIntervalDays:
          maintenanceIntervalDays ?? this.maintenanceIntervalDays,
      responsiblePersonId: responsiblePersonId ?? this.responsiblePersonId,
      responsiblePersonName:
          responsiblePersonName ?? this.responsiblePersonName,
      lastSanitizationDate: lastSanitizationDate ?? this.lastSanitizationDate,
      sanitizationIntervalHours:
          sanitizationIntervalHours ?? this.sanitizationIntervalHours,
      requiresSanitization: requiresSanitization ?? this.requiresSanitization,
      runningHoursTotal: runningHoursTotal ?? this.runningHoursTotal,
      runningHoursSinceLastMaintenance: runningHoursSinceLastMaintenance ??
          this.runningHoursSinceLastMaintenance,
      specifications: specifications ?? this.specifications,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EquipmentModel &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.status == status &&
        other.locationId == locationId &&
        other.locationName == locationName &&
        other.manufacturer == manufacturer &&
        other.model == model &&
        other.serialNumber == serialNumber &&
        other.installDate == installDate &&
        other.lastMaintenanceDate == lastMaintenanceDate &&
        other.nextMaintenanceDate == nextMaintenanceDate &&
        other.maintenanceIntervalDays == maintenanceIntervalDays &&
        other.responsiblePersonId == responsiblePersonId &&
        other.responsiblePersonName == responsiblePersonName &&
        other.lastSanitizationDate == lastSanitizationDate &&
        other.sanitizationIntervalHours == sanitizationIntervalHours &&
        other.requiresSanitization == requiresSanitization &&
        other.runningHoursTotal == runningHoursTotal &&
        other.runningHoursSinceLastMaintenance ==
            runningHoursSinceLastMaintenance;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        type.hashCode ^
        status.hashCode ^
        locationId.hashCode ^
        locationName.hashCode ^
        manufacturer.hashCode ^
        model.hashCode ^
        serialNumber.hashCode ^
        installDate.hashCode ^
        lastMaintenanceDate.hashCode ^
        nextMaintenanceDate.hashCode ^
        maintenanceIntervalDays.hashCode ^
        responsiblePersonId.hashCode ^
        responsiblePersonName.hashCode ^
        lastSanitizationDate.hashCode ^
        sanitizationIntervalHours.hashCode ^
        requiresSanitization.hashCode ^
        runningHoursTotal.hashCode ^
        runningHoursSinceLastMaintenance.hashCode;
  }
}
