import 'package:cloud_firestore/cloud_firestore.dart';

class TemperatureLogModel {
  TemperatureLogModel({
    this.id,
    required this.logDate,
    required this.locationId,
    required this.locationName,
    required this.sensorId,
    required this.temperature,
    required this.humidity,
    required this.timestamp,
    this.recordedByUserId,
    this.notes,
    this.isAlert = false,
  });

  factory TemperatureLogModel.fromJson(Map<String, dynamic> json) {
    return TemperatureLogModel(
      id: json['id'],
      logDate: json['logDate'] != null
          ? (json['logDate'] is Timestamp
              ? (json['logDate'] as Timestamp).toDate()
              : DateTime.parse(json['logDate']))
          : DateTime.now(),
      locationId: json['locationId'] ?? '',
      locationName: json['locationName'] ?? '',
      sensorId: json['sensorId'] ?? '',
      temperature: json['temperature']?.toDouble() ?? 0.0,
      humidity: json['humidity']?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] is Timestamp
              ? (json['timestamp'] as Timestamp).toDate()
              : DateTime.parse(json['timestamp']))
          : DateTime.now(),
      recordedByUserId: json['recordedByUserId'],
      notes: json['notes'],
      isAlert: json['isAlert'] ?? false,
    );
  }
  final String? id;
  final DateTime logDate;
  final String locationId;
  final String locationName;
  final String sensorId;
  final double temperature;
  final double humidity;
  final DateTime timestamp;
  final String? recordedByUserId;
  final String? notes;
  final bool isAlert;

  Map<String, dynamic> toJson() {
    return {
      'logDate': Timestamp.fromDate(logDate),
      'locationId': locationId,
      'locationName': locationName,
      'sensorId': sensorId,
      'temperature': temperature,
      'humidity': humidity,
      'timestamp': Timestamp.fromDate(timestamp),
      'recordedByUserId': recordedByUserId,
      'notes': notes,
      'isAlert': isAlert,
    };
  }

  TemperatureLogModel copyWith({
    String? id,
    DateTime? logDate,
    String? locationId,
    String? locationName,
    String? sensorId,
    double? temperature,
    double? humidity,
    DateTime? timestamp,
    String? recordedByUserId,
    String? notes,
    bool? isAlert,
  }) {
    return TemperatureLogModel(
      id: id ?? this.id,
      logDate: logDate ?? this.logDate,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      sensorId: sensorId ?? this.sensorId,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      timestamp: timestamp ?? this.timestamp,
      recordedByUserId: recordedByUserId ?? this.recordedByUserId,
      notes: notes ?? this.notes,
      isAlert: isAlert ?? this.isAlert,
    );
  }
}
