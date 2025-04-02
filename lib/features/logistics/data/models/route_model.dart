enum RouteStatus { pending, inProgress, completed, cancelled }

class RouteModel {
  RouteModel({
    required this.id,
    required this.name,
    required this.date,
    required this.vehicleId,
    required this.driverId,
    required this.deliveryIds,
    required this.status,
    required this.estimatedDistanceKm,
    required this.estimatedDurationMinutes,
    this.startTime,
    this.endTime,
    this.actualDistanceKm,
    this.actualDurationMinutes,
    this.waypoints,
    this.notes,
    required this.isOptimized,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
        id: json['id'] as String,
        name: json['name'] as String,
        date: DateTime.parse(json['date'] as String),
        vehicleId: json['vehicleId'] as String,
        driverId: json['driverId'] as String,
        deliveryIds: (json['deliveryIds'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        status: RouteStatus.values
            .firstWhere((e) => e.toString() == 'RouteStatus.${json['status']}'),
        estimatedDistanceKm: (json['estimatedDistanceKm'] as num).toDouble(),
        estimatedDurationMinutes: json['estimatedDurationMinutes'] as int,
        startTime: json['startTime'] == null
            ? null
            : DateTime.parse(json['startTime'] as String),
        endTime: json['endTime'] == null
            ? null
            : DateTime.parse(json['endTime'] as String),
        actualDistanceKm: (json['actualDistanceKm'] as num?)?.toDouble(),
        actualDurationMinutes: json['actualDurationMinutes'] as int?,
        waypoints: (json['waypoints'] as List<dynamic>?)
            ?.map((e) => GeoWaypoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        notes: json['notes'] as String?,
        isOptimized: json['isOptimized'] as bool,
      );

  final String id;
  final String name;
  final DateTime date;
  final String vehicleId;
  final String driverId;
  final List<String> deliveryIds;
  final RouteStatus status;
  final double estimatedDistanceKm;
  final int estimatedDurationMinutes;
  final DateTime? startTime;
  final DateTime? endTime;
  final double? actualDistanceKm;
  final int? actualDurationMinutes;
  final List<GeoWaypoint>? waypoints;
  final String? notes;
  final bool isOptimized;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date.toIso8601String(),
        'vehicleId': vehicleId,
        'driverId': driverId,
        'deliveryIds': deliveryIds,
        'status': status.toString().split('.').last,
        'estimatedDistanceKm': estimatedDistanceKm,
        'estimatedDurationMinutes': estimatedDurationMinutes,
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'actualDistanceKm': actualDistanceKm,
        'actualDurationMinutes': actualDurationMinutes,
        'waypoints': waypoints?.map((e) => e.toJson()).toList(),
        'notes': notes,
        'isOptimized': isOptimized,
      };

  RouteModel copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? vehicleId,
    String? driverId,
    List<String>? deliveryIds,
    RouteStatus? status,
    double? estimatedDistanceKm,
    int? estimatedDurationMinutes,
    DateTime? startTime,
    DateTime? endTime,
    double? actualDistanceKm,
    int? actualDurationMinutes,
    List<GeoWaypoint>? waypoints,
    String? notes,
    bool? isOptimized,
  }) =>
      RouteModel(
        id: id ?? this.id,
        name: name ?? this.name,
        date: date ?? this.date,
        vehicleId: vehicleId ?? this.vehicleId,
        driverId: driverId ?? this.driverId,
        deliveryIds: deliveryIds ?? this.deliveryIds,
        status: status ?? this.status,
        estimatedDistanceKm: estimatedDistanceKm ?? this.estimatedDistanceKm,
        estimatedDurationMinutes:
            estimatedDurationMinutes ?? this.estimatedDurationMinutes,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        actualDistanceKm: actualDistanceKm ?? this.actualDistanceKm,
        actualDurationMinutes:
            actualDurationMinutes ?? this.actualDurationMinutes,
        waypoints: waypoints ?? this.waypoints,
        notes: notes ?? this.notes,
        isOptimized: isOptimized ?? this.isOptimized,
      );
}

class GeoWaypoint {
  GeoWaypoint({
    required this.latitude,
    required this.longitude,
    required this.name,
    this.deliveryId,
    required this.isStop,
    this.estimatedArrival,
    this.actualArrival,
  });

  factory GeoWaypoint.fromJson(Map<String, dynamic> json) => GeoWaypoint(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        name: json['name'] as String,
        deliveryId: json['deliveryId'] as String?,
        isStop: json['isStop'] as bool,
        estimatedArrival: json['estimatedArrival'] == null
            ? null
            : DateTime.parse(json['estimatedArrival'] as String),
        actualArrival: json['actualArrival'] == null
            ? null
            : DateTime.parse(json['actualArrival'] as String),
      );

  final double latitude;
  final double longitude;
  final String name;
  final String? deliveryId;
  final bool isStop;
  final DateTime? estimatedArrival;
  final DateTime? actualArrival;

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'name': name,
        'deliveryId': deliveryId,
        'isStop': isStop,
        'estimatedArrival': estimatedArrival?.toIso8601String(),
        'actualArrival': actualArrival?.toIso8601String(),
      };

  GeoWaypoint copyWith({
    double? latitude,
    double? longitude,
    String? name,
    String? deliveryId,
    bool? isStop,
    DateTime? estimatedArrival,
    DateTime? actualArrival,
  }) =>
      GeoWaypoint(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        name: name ?? this.name,
        deliveryId: deliveryId ?? this.deliveryId,
        isStop: isStop ?? this.isStop,
        estimatedArrival: estimatedArrival ?? this.estimatedArrival,
        actualArrival: actualArrival ?? this.actualArrival,
      );
}
