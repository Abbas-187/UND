enum DeliveryStatus { pending, inTransit, delivered, failed, cancelled }

class DeliveryItemModel {
  DeliveryItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.weightKg,
  });

  factory DeliveryItemModel.fromJson(Map<String, dynamic> json) =>
      DeliveryItemModel(
        id: json['id'] as String,
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'] as String,
        weightKg: (json['weightKg'] as num).toDouble(),
      );

  final String id;
  final String productId;
  final String productName;
  final double quantity;
  final String unit;
  final double weightKg;

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'unit': unit,
        'weightKg': weightKg,
      };
}

class DeliveryModel {
  DeliveryModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.deliveryAddress,
    required this.scheduledDate,
    required this.vehicleId,
    this.driverId,
    required this.items,
    required this.status,
    this.actualDeliveryTime,
    this.notes,
    required this.totalWeightKg,
    this.customerSignature,
    this.proofOfDeliveryImage,
    this.temperatureLogIds,
    this.routeId,
    this.routeSequence,
    this.latitude,
    this.longitude,
    this.dispatchTime,
    required this.requiresTemperatureControl,
    this.requiredMinTemperature,
    this.requiredMaxTemperature,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) => DeliveryModel(
        id: json['id'] as String,
        customerId: json['customerId'] as String,
        customerName: json['customerName'] as String,
        deliveryAddress: json['deliveryAddress'] as String,
        scheduledDate: DateTime.parse(json['scheduledDate'] as String),
        vehicleId: json['vehicleId'] as String,
        driverId: json['driverId'] as String?,
        items: (json['items'] as List<dynamic>)
            .map((e) => DeliveryItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        status: DeliveryStatus.values.firstWhere(
            (e) => e.toString() == 'DeliveryStatus.${json['status']}'),
        actualDeliveryTime: json['actualDeliveryTime'] == null
            ? null
            : DateTime.parse(json['actualDeliveryTime'] as String),
        notes: json['notes'] as String?,
        totalWeightKg: (json['totalWeightKg'] as num).toDouble(),
        customerSignature: json['customerSignature'] as String?,
        proofOfDeliveryImage: json['proofOfDeliveryImage'] as String?,
        temperatureLogIds: (json['temperatureLogIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        routeId: json['routeId'] as String?,
        routeSequence: json['routeSequence'] as int?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        dispatchTime: json['dispatchTime'] == null
            ? null
            : DateTime.parse(json['dispatchTime'] as String),
        requiresTemperatureControl:
            json['requiresTemperatureControl'] as bool? ?? false,
        requiredMinTemperature:
            (json['requiredMinTemperature'] as num?)?.toDouble(),
        requiredMaxTemperature:
            (json['requiredMaxTemperature'] as num?)?.toDouble(),
      );

  final String id;
  final String customerId;
  final String customerName;
  final String deliveryAddress;
  final DateTime scheduledDate;
  final String vehicleId;
  final String? driverId;
  final List<DeliveryItemModel> items;
  final DeliveryStatus status;
  final DateTime? actualDeliveryTime;
  final String? notes;
  final double totalWeightKg;
  final String? customerSignature;
  final String? proofOfDeliveryImage;
  final List<String>? temperatureLogIds;
  final String? routeId;
  final int? routeSequence;
  final double? latitude;
  final double? longitude;
  final DateTime? dispatchTime;
  final bool requiresTemperatureControl;
  final double? requiredMinTemperature;
  final double? requiredMaxTemperature;

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'customerName': customerName,
        'deliveryAddress': deliveryAddress,
        'scheduledDate': scheduledDate.toIso8601String(),
        'vehicleId': vehicleId,
        'driverId': driverId,
        'items': items.map((e) => e.toJson()).toList(),
        'status': status.toString().split('.').last,
        'actualDeliveryTime': actualDeliveryTime?.toIso8601String(),
        'notes': notes,
        'totalWeightKg': totalWeightKg,
        'customerSignature': customerSignature,
        'proofOfDeliveryImage': proofOfDeliveryImage,
        'temperatureLogIds': temperatureLogIds,
        'routeId': routeId,
        'routeSequence': routeSequence,
        'latitude': latitude,
        'longitude': longitude,
        'dispatchTime': dispatchTime?.toIso8601String(),
        'requiresTemperatureControl': requiresTemperatureControl,
        'requiredMinTemperature': requiredMinTemperature,
        'requiredMaxTemperature': requiredMaxTemperature,
      };

  DeliveryModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? deliveryAddress,
    DateTime? scheduledDate,
    String? vehicleId,
    String? driverId,
    List<DeliveryItemModel>? items,
    DeliveryStatus? status,
    DateTime? actualDeliveryTime,
    String? notes,
    double? totalWeightKg,
    String? customerSignature,
    String? proofOfDeliveryImage,
    List<String>? temperatureLogIds,
    String? routeId,
    int? routeSequence,
    double? latitude,
    double? longitude,
    DateTime? dispatchTime,
    bool? requiresTemperatureControl,
    double? requiredMinTemperature,
    double? requiredMaxTemperature,
  }) =>
      DeliveryModel(
        id: id ?? this.id,
        customerId: customerId ?? this.customerId,
        customerName: customerName ?? this.customerName,
        deliveryAddress: deliveryAddress ?? this.deliveryAddress,
        scheduledDate: scheduledDate ?? this.scheduledDate,
        vehicleId: vehicleId ?? this.vehicleId,
        driverId: driverId ?? this.driverId,
        items: items ?? this.items,
        status: status ?? this.status,
        actualDeliveryTime: actualDeliveryTime ?? this.actualDeliveryTime,
        notes: notes ?? this.notes,
        totalWeightKg: totalWeightKg ?? this.totalWeightKg,
        customerSignature: customerSignature ?? this.customerSignature,
        proofOfDeliveryImage: proofOfDeliveryImage ?? this.proofOfDeliveryImage,
        temperatureLogIds: temperatureLogIds ?? this.temperatureLogIds,
        routeId: routeId ?? this.routeId,
        routeSequence: routeSequence ?? this.routeSequence,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        dispatchTime: dispatchTime ?? this.dispatchTime,
        requiresTemperatureControl:
            requiresTemperatureControl ?? this.requiresTemperatureControl,
        requiredMinTemperature:
            requiredMinTemperature ?? this.requiredMinTemperature,
        requiredMaxTemperature:
            requiredMaxTemperature ?? this.requiredMaxTemperature,
      );
}
