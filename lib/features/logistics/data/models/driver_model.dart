class DriverModel {
  DriverModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.licenseNumber,
    required this.licenseExpiryDate,
    required this.isAvailable,
    this.currentVehicleId,
    this.currentRouteId,
    this.profileImageUrl,
    required this.hasDairyTransportTraining,
    required this.lastTrainingDate,
    this.lastRestBreak,
    required this.totalDrivingMinutesToday,
    required this.maxDrivingMinutesAllowed,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) => DriverModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        name: json['name'] as String,
        phoneNumber: json['phoneNumber'] as String,
        licenseNumber: json['licenseNumber'] as String,
        licenseExpiryDate: DateTime.parse(json['licenseExpiryDate'] as String),
        isAvailable: json['isAvailable'] as bool,
        currentVehicleId: json['currentVehicleId'] as String?,
        currentRouteId: json['currentRouteId'] as String?,
        profileImageUrl: json['profileImageUrl'] as String?,
        hasDairyTransportTraining: json['hasDairyTransportTraining'] as bool,
        lastTrainingDate: DateTime.parse(json['lastTrainingDate'] as String),
        lastRestBreak: json['lastRestBreak'] == null
            ? null
            : DateTime.parse(json['lastRestBreak'] as String),
        totalDrivingMinutesToday: json['totalDrivingMinutesToday'] as int,
        maxDrivingMinutesAllowed: json['maxDrivingMinutesAllowed'] as int,
      );

  final String id;
  final String userId;
  final String name;
  final String phoneNumber;
  final String licenseNumber;
  final DateTime licenseExpiryDate;
  final bool isAvailable;
  final String? currentVehicleId;
  final String? currentRouteId;
  final String? profileImageUrl;
  final bool hasDairyTransportTraining;
  final DateTime lastTrainingDate;
  final DateTime? lastRestBreak;
  final int totalDrivingMinutesToday;
  final int maxDrivingMinutesAllowed;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'phoneNumber': phoneNumber,
        'licenseNumber': licenseNumber,
        'licenseExpiryDate': licenseExpiryDate.toIso8601String(),
        'isAvailable': isAvailable,
        'currentVehicleId': currentVehicleId,
        'currentRouteId': currentRouteId,
        'profileImageUrl': profileImageUrl,
        'hasDairyTransportTraining': hasDairyTransportTraining,
        'lastTrainingDate': lastTrainingDate.toIso8601String(),
        'lastRestBreak': lastRestBreak?.toIso8601String(),
        'totalDrivingMinutesToday': totalDrivingMinutesToday,
        'maxDrivingMinutesAllowed': maxDrivingMinutesAllowed,
      };
}

// The rest of the file likely contained the implementation details generated by freezed/json_serializable, which should be removed if present.
// Assuming the original content starting from 'DriverModel.fromJson(Map<String, dynamic> json) => ...' down to the end was either old code or generated code, it should be replaced by the factory constructors above.
