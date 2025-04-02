import 'package:cloud_firestore/cloud_firestore.dart';

class TemperatureSettingsModel {
  TemperatureSettingsModel({
    this.id,
    required this.locationId,
    required this.locationName,
    required this.minTemperature,
    required this.maxTemperature,
    required this.minHumidity,
    required this.maxHumidity,
    this.alertsEnabled = true,
    this.alertRecipients,
    this.createdBy,
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  factory TemperatureSettingsModel.fromJson(Map<String, dynamic> json) {
    return TemperatureSettingsModel(
      id: json['id'],
      locationId: json['locationId'] ?? '',
      locationName: json['locationName'] ?? '',
      minTemperature: json['minTemperature']?.toDouble() ?? 0.0,
      maxTemperature: json['maxTemperature']?.toDouble() ?? 0.0,
      minHumidity: json['minHumidity']?.toDouble() ?? 0.0,
      maxHumidity: json['maxHumidity']?.toDouble() ?? 0.0,
      alertsEnabled: json['alertsEnabled'] ?? true,
      alertRecipients: json['alertRecipients'] != null
          ? List<String>.from(json['alertRecipients'])
          : null,
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.parse(json['createdAt']))
          : DateTime.now(),
      updatedBy: json['updatedBy'],
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(json['updatedAt']))
          : null,
    );
  }
  final String? id;
  final String locationId;
  final String locationName;
  final double minTemperature;
  final double maxTemperature;
  final double minHumidity;
  final double maxHumidity;
  final bool alertsEnabled;
  final List<String>? alertRecipients;
  final String? createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'locationId': locationId,
      'locationName': locationName,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'minHumidity': minHumidity,
      'maxHumidity': maxHumidity,
      'alertsEnabled': alertsEnabled,
      'alertRecipients': alertRecipients,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedBy': updatedBy,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  TemperatureSettingsModel copyWith({
    String? id,
    String? locationId,
    String? locationName,
    double? minTemperature,
    double? maxTemperature,
    double? minHumidity,
    double? maxHumidity,
    bool? alertsEnabled,
    List<String>? alertRecipients,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return TemperatureSettingsModel(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      minTemperature: minTemperature ?? this.minTemperature,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      minHumidity: minHumidity ?? this.minHumidity,
      maxHumidity: maxHumidity ?? this.maxHumidity,
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
      alertRecipients: alertRecipients ?? this.alertRecipients,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
