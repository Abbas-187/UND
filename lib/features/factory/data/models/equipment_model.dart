import 'package:cloud_firestore/cloud_firestore.dart';

class EquipmentModel {
  const EquipmentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.model,
    required this.serialNumber,
    required this.manufacturer,
    required this.purchaseDate,
    required this.installationDate,
    required this.location,
    required this.isOperational,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    this.maintenanceHistory,
    this.specifications,
    this.notes,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      model: json['model'] as String,
      serialNumber: json['serialNumber'] as String,
      manufacturer: json['manufacturer'] as String,
      purchaseDate: (json['purchaseDate'] as Timestamp).toDate(),
      installationDate: (json['installationDate'] as Timestamp).toDate(),
      location: json['location'] as String,
      isOperational: json['isOperational'] as bool,
      lastMaintenanceDate: json['lastMaintenanceDate'] != null
          ? (json['lastMaintenanceDate'] as Timestamp).toDate()
          : null,
      nextMaintenanceDate: json['nextMaintenanceDate'] != null
          ? (json['nextMaintenanceDate'] as Timestamp).toDate()
          : null,
      maintenanceHistory: (json['maintenanceHistory'] as List<dynamic>?)
          ?.map((e) => MaintenanceRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      specifications: json['specifications'] != null
          ? Map<String, dynamic>.from(json['specifications'] as Map)
          : null,
      notes: json['notes'] as String?,
    );
  }

  final String id;
  final String name;
  final String type;
  final String model;
  final String serialNumber;
  final String manufacturer;
  final DateTime purchaseDate;
  final DateTime installationDate;
  final String location;
  final bool isOperational;
  final DateTime? lastMaintenanceDate;
  final DateTime? nextMaintenanceDate;
  final List<MaintenanceRecord>? maintenanceHistory;
  final Map<String, dynamic>? specifications;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'model': model,
      'serialNumber': serialNumber,
      'manufacturer': manufacturer,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'installationDate': Timestamp.fromDate(installationDate),
      'location': location,
      'isOperational': isOperational,
      'lastMaintenanceDate': lastMaintenanceDate != null
          ? Timestamp.fromDate(lastMaintenanceDate!)
          : null,
      'nextMaintenanceDate': nextMaintenanceDate != null
          ? Timestamp.fromDate(nextMaintenanceDate!)
          : null,
      'maintenanceHistory':
          maintenanceHistory?.map((record) => record.toJson()).toList(),
      'specifications': specifications,
      'notes': notes,
    };
  }

  EquipmentModel copyWith({
    String? id,
    String? name,
    String? type,
    String? model,
    String? serialNumber,
    String? manufacturer,
    DateTime? purchaseDate,
    DateTime? installationDate,
    String? location,
    bool? isOperational,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    List<MaintenanceRecord>? maintenanceHistory,
    Map<String, dynamic>? specifications,
    String? notes,
  }) {
    return EquipmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      manufacturer: manufacturer ?? this.manufacturer,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      installationDate: installationDate ?? this.installationDate,
      location: location ?? this.location,
      isOperational: isOperational ?? this.isOperational,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      maintenanceHistory: maintenanceHistory ?? this.maintenanceHistory,
      specifications: specifications ?? this.specifications,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'EquipmentModel(id: $id, name: $name, type: $type, model: $model, serialNumber: $serialNumber, manufacturer: $manufacturer, purchaseDate: $purchaseDate, installationDate: $installationDate, location: $location, isOperational: $isOperational, lastMaintenanceDate: $lastMaintenanceDate, nextMaintenanceDate: $nextMaintenanceDate, maintenanceHistory: $maintenanceHistory, specifications: $specifications, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EquipmentModel &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.model == model &&
        other.serialNumber == serialNumber &&
        other.manufacturer == manufacturer &&
        other.purchaseDate == purchaseDate &&
        other.installationDate == installationDate &&
        other.location == location &&
        other.isOperational == isOperational &&
        other.lastMaintenanceDate == lastMaintenanceDate &&
        other.nextMaintenanceDate == nextMaintenanceDate &&
        other.maintenanceHistory == maintenanceHistory &&
        other.specifications == specifications &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        type.hashCode ^
        model.hashCode ^
        serialNumber.hashCode ^
        manufacturer.hashCode ^
        purchaseDate.hashCode ^
        installationDate.hashCode ^
        location.hashCode ^
        isOperational.hashCode ^
        lastMaintenanceDate.hashCode ^
        nextMaintenanceDate.hashCode ^
        maintenanceHistory.hashCode ^
        specifications.hashCode ^
        notes.hashCode;
  }
}

class MaintenanceRecord {
  const MaintenanceRecord({
    required this.date,
    required this.type,
    required this.description,
    required this.performedBy,
    this.cost,
    this.parts,
    this.notes,
  });

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) {
    return MaintenanceRecord(
      date: (json['date'] as Timestamp).toDate(),
      type: json['type'] as String,
      description: json['description'] as String,
      performedBy: json['performedBy'] as String,
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : null,
      parts: json['parts'] != null
          ? List<String>.from(json['parts'] as List)
          : null,
      notes: json['notes'] as String?,
    );
  }

  final DateTime date;
  final String type;
  final String description;
  final String performedBy;
  final double? cost;
  final List<String>? parts;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'date': Timestamp.fromDate(date),
      'type': type,
      'description': description,
      'performedBy': performedBy,
      'cost': cost,
      'parts': parts,
      'notes': notes,
    };
  }

  MaintenanceRecord copyWith({
    DateTime? date,
    String? type,
    String? description,
    String? performedBy,
    double? cost,
    List<String>? parts,
    String? notes,
  }) {
    return MaintenanceRecord(
      date: date ?? this.date,
      type: type ?? this.type,
      description: description ?? this.description,
      performedBy: performedBy ?? this.performedBy,
      cost: cost ?? this.cost,
      parts: parts ?? this.parts,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'MaintenanceRecord(date: $date, type: $type, description: $description, performedBy: $performedBy, cost: $cost, parts: $parts, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MaintenanceRecord &&
        other.date == date &&
        other.type == type &&
        other.description == description &&
        other.performedBy == performedBy &&
        other.cost == cost &&
        other.parts == parts &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return date.hashCode ^
        type.hashCode ^
        description.hashCode ^
        performedBy.hashCode ^
        cost.hashCode ^
        parts.hashCode ^
        notes.hashCode;
  }
}
