import 'package:collection/collection.dart';

import 'equipment_model.dart';
import 'maintenance_models.dart';

/// Model for maintenance records of dairy equipment
class MaintenanceRecordModel {
  const MaintenanceRecordModel({
    required this.id,
    required this.equipmentId,
    required this.equipmentName,
    required this.equipmentType,
    required this.scheduledDate,
    this.completionDate,
    required this.maintenanceType,
    required this.description,
    required this.status,
    required this.performedById,
    required this.performedByName,
    this.notes,
    this.partsReplaced,
    this.downtimeHours,
    required this.metadata,
  });

  factory MaintenanceRecordModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceRecordModel(
      id: json['id'] as String,
      equipmentId: json['equipmentId'] as String,
      equipmentName: json['equipmentName'] as String,
      equipmentType: EquipmentType.values.firstWhere(
          (e) => e.toString().split('.').last == json['equipmentType'],
          orElse: () => EquipmentType.other),
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'] as String)
          : null,
      maintenanceType: MaintenanceType.values.firstWhere(
        (e) => e.toString().split('.').last == json['maintenanceType'],
        orElse: () => MaintenanceType.preventive,
      ),
      description: json['description'] as String,
      status: MaintenanceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => MaintenanceStatus.scheduled,
      ),
      performedById: json['performedById'] as String,
      performedByName: json['performedByName'] as String,
      notes: json['notes'] as String?,
      partsReplaced: (json['partsReplaced'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      downtimeHours: (json['downtimeHours'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }
  final String id;
  final String equipmentId;
  final String equipmentName;
  // Assuming these enums are defined elsewhere in the project.
  final EquipmentType equipmentType;
  final DateTime scheduledDate;
  final DateTime? completionDate;
  final MaintenanceType maintenanceType;
  final String description;
  final MaintenanceStatus status;
  final String performedById;
  final String performedByName;
  final String? notes;
  final List<String>? partsReplaced;
  final double? downtimeHours;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'equipmentId': equipmentId,
      'equipmentName': equipmentName,
      'equipmentType': equipmentType.toString().split('.').last,
      'scheduledDate': scheduledDate.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'maintenanceType': maintenanceType.toString().split('.').last,
      'description': description,
      'status': status.toString().split('.').last,
      'performedById': performedById,
      'performedByName': performedByName,
      'notes': notes,
      'partsReplaced': partsReplaced,
      'downtimeHours': downtimeHours,
      'metadata': metadata,
    };
  }

  MaintenanceRecordModel copyWith({
    String? id,
    String? equipmentId,
    String? equipmentName,
    EquipmentType? equipmentType,
    DateTime? scheduledDate,
    DateTime? completionDate,
    MaintenanceType? maintenanceType,
    String? description,
    MaintenanceStatus? status,
    String? performedById,
    String? performedByName,
    String? notes,
    List<String>? partsReplaced,
    double? downtimeHours,
    Map<String, dynamic>? metadata,
  }) {
    return MaintenanceRecordModel(
      id: id ?? this.id,
      equipmentId: equipmentId ?? this.equipmentId,
      equipmentName: equipmentName ?? this.equipmentName,
      equipmentType: equipmentType ?? this.equipmentType,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completionDate: completionDate ?? this.completionDate,
      maintenanceType: maintenanceType ?? this.maintenanceType,
      description: description ?? this.description,
      status: status ?? this.status,
      performedById: performedById ?? this.performedById,
      performedByName: performedByName ?? this.performedByName,
      notes: notes ?? this.notes,
      partsReplaced: partsReplaced ?? this.partsReplaced,
      downtimeHours: downtimeHours ?? this.downtimeHours,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MaintenanceRecordModel &&
        other.id == id &&
        other.equipmentId == equipmentId &&
        other.equipmentName == equipmentName &&
        other.equipmentType == equipmentType &&
        other.scheduledDate == scheduledDate &&
        other.completionDate == completionDate &&
        other.maintenanceType == maintenanceType &&
        other.description == description &&
        other.status == status &&
        other.performedById == performedById &&
        other.performedByName == performedByName &&
        other.notes == notes &&
        other.partsReplaced == partsReplaced &&
        other.downtimeHours == downtimeHours &&
        // Deep comparison for metadata
        const DeepCollectionEquality().equals(other.metadata, metadata);
    // identical(other.metadata, metadata); // This was causing issues
  }

  @override
  int get hashCode {
    return id.hashCode ^
        equipmentId.hashCode ^
        equipmentName.hashCode ^
        equipmentType.hashCode ^
        scheduledDate.hashCode ^
        completionDate.hashCode ^
        maintenanceType.hashCode ^
        description.hashCode ^
        status.hashCode ^
        performedById.hashCode ^
        performedByName.hashCode ^
        notes.hashCode ^
        partsReplaced.hashCode ^
        downtimeHours.hashCode ^
        metadata.hashCode;
  }
}
