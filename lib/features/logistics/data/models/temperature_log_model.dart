class TemperatureLogModel {
  TemperatureLogModel({
    required this.id,
    required this.sensorId,
    required this.vehicleId,
    this.deliveryId,
    required this.timestamp,
    required this.temperature,
    required this.latitude,
    required this.longitude,
    required this.isAlertTriggered,
    this.minAllowedTemperature,
    this.maxAllowedTemperature,
    this.notes,
  });

  factory TemperatureLogModel.fromJson(Map<String, dynamic> json) =>
      TemperatureLogModel(
        id: json['id'] as String,
        sensorId: json['sensorId'] as String,
        vehicleId: json['vehicleId'] as String,
        deliveryId: json['deliveryId'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
        temperature: (json['temperature'] as num).toDouble(),
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        isAlertTriggered: json['isAlertTriggered'] as bool,
        minAllowedTemperature:
            (json['minAllowedTemperature'] as num?)?.toDouble(),
        maxAllowedTemperature:
            (json['maxAllowedTemperature'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
      );

  final String id;
  final String sensorId;
  final String vehicleId;
  final String? deliveryId;
  final DateTime timestamp;
  final double temperature;
  final double latitude;
  final double longitude;
  final bool isAlertTriggered;
  final double? minAllowedTemperature;
  final double? maxAllowedTemperature;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'sensorId': sensorId,
        'vehicleId': vehicleId,
        'deliveryId': deliveryId,
        'timestamp': timestamp.toIso8601String(),
        'temperature': temperature,
        'latitude': latitude,
        'longitude': longitude,
        'isAlertTriggered': isAlertTriggered,
        'minAllowedTemperature': minAllowedTemperature,
        'maxAllowedTemperature': maxAllowedTemperature,
        'notes': notes,
      };
}
