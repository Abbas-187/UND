import 'package:cloud_firestore/cloud_firestore.dart';

/// Temperature compliance status
enum TemperatureComplianceStatus { inRange, warning, violation, notApplicable }

/// Equipment or location type
enum LocationType {
  storageRoom,
  refrigerator,
  freezer,
  productionLine,
  transportVehicle,
  receivingArea,
  other
}

/// Immutable temperature log model for dairy factory
class TemperatureLogModel {

  const TemperatureLogModel({
    this.id,
    required this.timestamp,
    required this.temperatureValue,
    required this.locationId,
    this.locationType,
    this.locationName,
    this.userId,
    this.deviceId,
    required this.complianceStatus,
    this.minThreshold,
    this.maxThreshold,
    this.targetTemperature,
    this.notes,
    this.additionalData,
    this.productBatchId,
    this.materialId,
    this.alertId,
    this.alertsGenerated,
    required this.createdBy,
    required this.createdAt,
  });

  /// Create an instance from JSON
  factory TemperatureLogModel.fromJson(Map<String, dynamic> json) {
    // Handle DateTime conversion
    final timestamp = json['timestamp'] is Timestamp
        ? (json['timestamp'] as Timestamp).toDate()
        : DateTime.parse(json['timestamp'].toString());

    final createdAt = json['createdAt'] is Timestamp
        ? (json['createdAt'] as Timestamp).toDate()
        : DateTime.parse(json['createdAt'].toString());

    // Handle enum conversion
    final complianceStatusString = json['complianceStatus'] as String;
    final complianceStatus = TemperatureComplianceStatus.values.firstWhere(
      (e) => e.toString().split('.').last == complianceStatusString,
      orElse: () => TemperatureComplianceStatus.notApplicable,
    );

    // Handle location type
    LocationType? locationType;
    if (json['locationType'] != null) {
      final locationTypeString = json['locationType'] as String;
      locationType = LocationType.values.firstWhere(
        (e) => e.toString().split('.').last == locationTypeString,
        orElse: () => LocationType.other,
      );
    }

    return TemperatureLogModel(
      id: json['id'],
      timestamp: timestamp,
      temperatureValue: (json['temperatureValue'] as num).toDouble(),
      locationId: json['locationId'] as String,
      locationType: locationType,
      locationName: json['locationName'] as String?,
      userId: json['userId'] as String?,
      deviceId: json['deviceId'] as String?,
      complianceStatus: complianceStatus,
      minThreshold: json['minThreshold'] != null
          ? (json['minThreshold'] as num).toDouble()
          : null,
      maxThreshold: json['maxThreshold'] != null
          ? (json['maxThreshold'] as num).toDouble()
          : null,
      targetTemperature: json['targetTemperature'] != null
          ? (json['targetTemperature'] as num).toDouble()
          : null,
      notes: json['notes'] as String?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
      productBatchId: json['productBatchId'] as String?,
      materialId: json['materialId'] as String?,
      alertId: json['alertId'] as String?,
      alertsGenerated: json['alertsGenerated'] as bool?,
      createdBy: json['createdBy'] as String,
      createdAt: createdAt,
    );
  }

  /// Factory method to convert from Firestore document
  factory TemperatureLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Convert Timestamp to DateTime
    final timestamp = data['timestamp'] is Timestamp
        ? (data['timestamp'] as Timestamp).toDate()
        : DateTime.now();

    final createdAt = data['createdAt'] is Timestamp
        ? (data['createdAt'] as Timestamp).toDate()
        : DateTime.now();

    // Convert compliance status string to enum
    final complianceStatusString =
        data['complianceStatus'] as String? ?? 'notApplicable';
    final complianceStatus = TemperatureComplianceStatus.values.firstWhere(
      (e) => e.toString().split('.').last == complianceStatusString,
      orElse: () => TemperatureComplianceStatus.notApplicable,
    );

    // Convert location type string to enum if available
    LocationType? locationType;
    if (data['locationType'] != null) {
      final locationTypeString = data['locationType'] as String;
      locationType = LocationType.values.firstWhere(
        (e) => e.toString().split('.').last == locationTypeString,
        orElse: () => LocationType.other,
      );
    }

    return TemperatureLogModel(
      id: doc.id,
      timestamp: timestamp,
      temperatureValue: (data['temperatureValue'] as num?)?.toDouble() ?? 0.0,
      locationId: data['locationId'] as String? ?? '',
      locationType: locationType,
      locationName: data['locationName'] as String?,
      userId: data['userId'] as String?,
      deviceId: data['deviceId'] as String?,
      complianceStatus: complianceStatus,
      minThreshold: (data['minThreshold'] as num?)?.toDouble(),
      maxThreshold: (data['maxThreshold'] as num?)?.toDouble(),
      targetTemperature: (data['targetTemperature'] as num?)?.toDouble(),
      notes: data['notes'] as String?,
      additionalData: data['additionalData'] as Map<String, dynamic>?,
      productBatchId: data['productBatchId'] as String?,
      materialId: data['materialId'] as String?,
      alertId: data['alertId'] as String?,
      alertsGenerated: data['alertsGenerated'] as bool?,
      createdBy: data['createdBy'] as String? ?? 'system',
      createdAt: createdAt,
    );
  }
  final String? id;
  final DateTime timestamp;
  final double temperatureValue;
  final String locationId;
  final LocationType? locationType;
  final String? locationName;
  final String? userId;
  final String? deviceId;
  final TemperatureComplianceStatus complianceStatus;
  final double? minThreshold;
  final double? maxThreshold;
  final double? targetTemperature;
  final String? notes;
  final Map<String, dynamic>? additionalData;
  final String? productBatchId;
  final String? materialId;
  final String? alertId;
  final bool? alertsGenerated;
  final String createdBy;
  final DateTime createdAt;

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'temperatureValue': temperatureValue,
      'locationId': locationId,
      'locationType': locationType?.toString().split('.').last,
      'locationName': locationName,
      'userId': userId,
      'deviceId': deviceId,
      'complianceStatus': complianceStatus.toString().split('.').last,
      'minThreshold': minThreshold,
      'maxThreshold': maxThreshold,
      'targetTemperature': targetTemperature,
      'notes': notes,
      'additionalData': additionalData,
      'productBatchId': productBatchId,
      'materialId': materialId,
      'alertId': alertId,
      'alertsGenerated': alertsGenerated,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    // Convert DateTime to Timestamp
    final timestampValue = Timestamp.fromDate(timestamp);
    final createdAtTimestamp = Timestamp.fromDate(createdAt);

    // Convert enum values to strings
    final complianceStatusString = complianceStatus.toString().split('.').last;
    final locationTypeString = locationType?.toString().split('.').last;

    return {
      'timestamp': timestampValue,
      'temperatureValue': temperatureValue,
      'locationId': locationId,
      'locationType': locationTypeString,
      'locationName': locationName,
      'userId': userId,
      'deviceId': deviceId,
      'complianceStatus': complianceStatusString,
      'minThreshold': minThreshold,
      'maxThreshold': maxThreshold,
      'targetTemperature': targetTemperature,
      'notes': notes,
      'additionalData': additionalData,
      'productBatchId': productBatchId,
      'materialId': materialId,
      'alertId': alertId,
      'alertsGenerated': alertsGenerated,
      'createdBy': createdBy,
      'createdAt': createdAtTimestamp,
    };
  }

  /// Create a copy with modified values
  TemperatureLogModel copyWith({
    String? id,
    DateTime? timestamp,
    double? temperatureValue,
    String? locationId,
    LocationType? locationType,
    String? locationName,
    String? userId,
    String? deviceId,
    TemperatureComplianceStatus? complianceStatus,
    double? minThreshold,
    double? maxThreshold,
    double? targetTemperature,
    String? notes,
    Map<String, dynamic>? additionalData,
    String? productBatchId,
    String? materialId,
    String? alertId,
    bool? alertsGenerated,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return TemperatureLogModel(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      temperatureValue: temperatureValue ?? this.temperatureValue,
      locationId: locationId ?? this.locationId,
      locationType: locationType ?? this.locationType,
      locationName: locationName ?? this.locationName,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      complianceStatus: complianceStatus ?? this.complianceStatus,
      minThreshold: minThreshold ?? this.minThreshold,
      maxThreshold: maxThreshold ?? this.maxThreshold,
      targetTemperature: targetTemperature ?? this.targetTemperature,
      notes: notes ?? this.notes,
      additionalData: additionalData ?? this.additionalData,
      productBatchId: productBatchId ?? this.productBatchId,
      materialId: materialId ?? this.materialId,
      alertId: alertId ?? this.alertId,
      alertsGenerated: alertsGenerated ?? this.alertsGenerated,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemperatureLogModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          timestamp == other.timestamp &&
          locationId == other.locationId;

  @override
  int get hashCode => id.hashCode ^ timestamp.hashCode ^ locationId.hashCode;
}

/// Analytics functions for temperature logs
extension TemperatureLogAnalytics on List<TemperatureLogModel> {
  /// Calculate average temperature for a location within a time range
  double calculateAverageTemperature() {
    if (isEmpty) return 0.0;

    final sum = fold<double>(0.0, (sum, log) => sum + log.temperatureValue);
    return sum / length;
  }

  /// Count compliance violations
  int countViolations() {
    return where((log) =>
        log.complianceStatus == TemperatureComplianceStatus.violation).length;
  }

  /// Get temperature trend (increasing, decreasing, stable)
  String getTemperatureTrend() {
    if (length < 2) return 'insufficient_data';

    // Sort by timestamp
    final sortedLogs = List<TemperatureLogModel>.from(this)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate trend using linear regression
    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumXX = 0;

    // Use timestamp in milliseconds as X value
    for (int i = 0; i < sortedLogs.length; i++) {
      final x = i.toDouble(); // Use index for simplicity
      final y = sortedLogs[i].temperatureValue;

      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumXX += x * x;
    }

    final n = sortedLogs.length.toDouble();
    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);

    if (slope > 0.1) {
      return 'increasing';
    } else if (slope < -0.1) {
      return 'decreasing';
    } else {
      return 'stable';
    }
  }
}
