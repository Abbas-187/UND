import 'package:cloud_firestore/cloud_firestore.dart';
import 'milk_quality_test_model.dart';

/// Enum representing different types of milk
enum MilkType {
  rawCow,
  rawGoat,
  rawSheep,
  pasteurizedCow,
  pasteurizedGoat,
  pasteurizedSheep,
  other
}

/// Enum representing different types of containers
enum ContainerType { aluminumCan, steelCan, plasticContainer, bulk, other }

/// Enum representing different reception statuses
enum ReceptionStatus { draft, pendingTesting, accepted, rejected }

/// A comprehensive model representing milk reception details in a dairy factory
class MilkReceptionModel {
  /// Creates an empty reception record with default values
  factory MilkReceptionModel.empty() {
    return MilkReceptionModel(
      id: '',
      timestamp: DateTime.now(),
      supplierId: '',
      supplierName: '',
      vehiclePlate: '',
      driverName: '',
      quantityLiters: 0.0,
      milkType: MilkType.rawCow,
      containerType: ContainerType.aluminumCan,
      containerCount: 0,
      initialObservations: '',
      receptionStatus: ReceptionStatus.pendingTesting,
      receivingEmployeeId: '',
      temperatureAtArrival: 4.0,
      smell: 'Normal',
      appearance: 'Normal',
      hasVisibleContamination: false,
      qualityTest: null,
    );
  }

  /// Creates a model from Firestore document
  factory MilkReceptionModel.fromJson(Map<String, dynamic> json) {
    return MilkReceptionModel(
      id: json['id'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String,
      vehiclePlate: json['vehiclePlate'] as String,
      driverName: json['driverName'] as String,
      quantityLiters: (json['quantityLiters'] as num).toDouble(),
      milkType: MilkType.values.firstWhere(
        (e) => e.toString() == json['milkType'],
        orElse: () => MilkType.rawCow,
      ),
      containerType: ContainerType.values.firstWhere(
        (e) => e.toString() == json['containerType'],
        orElse: () => ContainerType.aluminumCan,
      ),
      containerCount: json['containerCount'] as int,
      initialObservations: json['initialObservations'] as String,
      receptionStatus: ReceptionStatus.values.firstWhere(
        (e) => e.toString() == json['receptionStatus'],
        orElse: () => ReceptionStatus.pendingTesting,
      ),
      receivingEmployeeId: json['receivingEmployeeId'] as String,
      temperatureAtArrival: (json['temperatureAtArrival'] as num).toDouble(),
      phValue:
          json['phValue'] != null ? (json['phValue'] as num).toDouble() : null,
      smell: json['smell'] as String,
      appearance: json['appearance'] as String,
      hasVisibleContamination: json['hasVisibleContamination'] as bool,
      contaminationDescription: json['contaminationDescription'] as String?,
      notes: json['notes'] as String?,
      photoUrls: (json['photoUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      geoLocation: json['geoLocation'] as GeoPoint?,
      qualityTest: json['qualityTest'] != null
          ? MilkQualityTestModel.fromJson(
              json['qualityTest'] as Map<String, dynamic>)
          : null,
    );
  }
  const MilkReceptionModel({
    required this.id,
    required this.timestamp,
    required this.supplierId,
    required this.supplierName,
    required this.vehiclePlate,
    required this.driverName,
    required this.quantityLiters,
    required this.milkType,
    required this.containerType,
    required this.containerCount,
    required this.initialObservations,
    required this.receptionStatus,
    required this.receivingEmployeeId,
    required this.temperatureAtArrival,
    this.phValue,
    required this.smell,
    required this.appearance,
    required this.hasVisibleContamination,
    this.contaminationDescription,
    this.notes,
    this.photoUrls = const [],
    this.geoLocation,
    this.qualityTest,
  });

  /// Unique identifier for this reception
  final String id;

  /// Time when the milk was received
  final DateTime timestamp;

  /// ID of the supplying entity
  final String supplierId;

  /// Name of the supplying entity
  final String supplierName;

  /// License plate of the delivery vehicle
  final String vehiclePlate;

  /// Name of the driver delivering the milk
  final String driverName;

  /// Quantity of milk received in liters
  final double quantityLiters;

  /// Type of milk received
  final MilkType milkType;

  /// Type of container used for milk transport
  final ContainerType containerType;

  /// Number of containers delivered
  final int containerCount;

  /// Initial visual observations about the milk
  final String initialObservations;

  /// Current status of the reception
  final ReceptionStatus receptionStatus;

  /// ID of the employee who received the milk
  final String receivingEmployeeId;

  /// Temperature of milk when it arrived (°C)
  final double temperatureAtArrival;

  /// pH value if measured on arrival
  final double? phValue;

  /// Description of the milk's smell
  final String smell;

  /// Description of the milk's appearance
  final String appearance;

  /// Whether any visible contamination was detected
  final bool hasVisibleContamination;

  /// Description of contamination if detected
  final String? contaminationDescription;

  /// Additional notes or comments
  final String? notes;

  /// List of URLs to photos taken during reception
  final List<String> photoUrls;

  /// Geo-location where the reception took place
  final GeoPoint? geoLocation;

  /// Quality test results for this reception
  final MilkQualityTestModel? qualityTest;

  /// Converts model to a JSON map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': Timestamp.fromDate(timestamp),
      'supplierId': supplierId,
      'supplierName': supplierName,
      'vehiclePlate': vehiclePlate,
      'driverName': driverName,
      'quantityLiters': quantityLiters,
      'milkType': milkType.toString(),
      'containerType': containerType.toString(),
      'containerCount': containerCount,
      'initialObservations': initialObservations,
      'receptionStatus': receptionStatus.toString(),
      'receivingEmployeeId': receivingEmployeeId,
      'temperatureAtArrival': temperatureAtArrival,
      'phValue': phValue,
      'smell': smell,
      'appearance': appearance,
      'hasVisibleContamination': hasVisibleContamination,
      'contaminationDescription': contaminationDescription,
      'notes': notes,
      'photoUrls': photoUrls,
      'geoLocation': geoLocation,
      'qualityTest': qualityTest?.toJson(),
    };
  }

  /// Creates a copy of this model with specified fields replaced
  MilkReceptionModel copyWith({
    String? id,
    DateTime? timestamp,
    String? supplierId,
    String? supplierName,
    String? vehiclePlate,
    String? driverName,
    double? quantityLiters,
    MilkType? milkType,
    ContainerType? containerType,
    int? containerCount,
    String? initialObservations,
    ReceptionStatus? receptionStatus,
    String? receivingEmployeeId,
    double? temperatureAtArrival,
    double? phValue,
    String? smell,
    String? appearance,
    bool? hasVisibleContamination,
    String? contaminationDescription,
    String? notes,
    List<String>? photoUrls,
    GeoPoint? geoLocation,
    MilkQualityTestModel? qualityTest,
  }) {
    return MilkReceptionModel(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      driverName: driverName ?? this.driverName,
      quantityLiters: quantityLiters ?? this.quantityLiters,
      milkType: milkType ?? this.milkType,
      containerType: containerType ?? this.containerType,
      containerCount: containerCount ?? this.containerCount,
      initialObservations: initialObservations ?? this.initialObservations,
      receptionStatus: receptionStatus ?? this.receptionStatus,
      receivingEmployeeId: receivingEmployeeId ?? this.receivingEmployeeId,
      temperatureAtArrival: temperatureAtArrival ?? this.temperatureAtArrival,
      phValue: phValue ?? this.phValue,
      smell: smell ?? this.smell,
      appearance: appearance ?? this.appearance,
      hasVisibleContamination:
          hasVisibleContamination ?? this.hasVisibleContamination,
      contaminationDescription:
          contaminationDescription ?? this.contaminationDescription,
      notes: notes ?? this.notes,
      photoUrls: photoUrls ?? this.photoUrls,
      geoLocation: geoLocation ?? this.geoLocation,
      qualityTest: qualityTest ?? this.qualityTest,
    );
  }

  /// Validates if temperature is within acceptable range (2-6°C)
  bool isTemperatureValid() {
    return temperatureAtArrival >= 2.0 && temperatureAtArrival <= 6.0;
  }

  /// Validates if quantity is positive and reasonable (< 50,000 liters)
  bool isQuantityValid() {
    return quantityLiters > 0.0 && quantityLiters < 50000.0;
  }

  /// Validates if all required fields are non-null and non-empty
  bool areRequiredFieldsValid() {
    return id.isNotEmpty &&
        supplierId.isNotEmpty &&
        supplierName.isNotEmpty &&
        vehiclePlate.isNotEmpty &&
        driverName.isNotEmpty &&
        receivingEmployeeId.isNotEmpty &&
        initialObservations.isNotEmpty &&
        smell.isNotEmpty &&
        appearance.isNotEmpty;
  }

  /// Comprehensive validation of the model
  bool isValid() {
    return isTemperatureValid() &&
        isQuantityValid() &&
        areRequiredFieldsValid();
  }
}
