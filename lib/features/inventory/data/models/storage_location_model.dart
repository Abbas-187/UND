class StorageLocationModel {
  const StorageLocationModel({
    required this.locationId,
    required this.locationName,
    required this.quantity,
    this.zone,
    this.aisle,
    this.rack,
    this.bin,
    this.notes,
  });

  factory StorageLocationModel.fromJson(Map<String, dynamic> json) {
    return StorageLocationModel(
      locationId: json['locationId'] as String,
      locationName: json['locationName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      zone: json['zone'] as String?,
      aisle: json['aisle'] as String?,
      rack: json['rack'] as String?,
      bin: json['bin'] as String?,
      notes: json['notes'] as String?,
    );
  }
  final String locationId;
  final String locationName;
  final double quantity;
  final String? zone;
  final String? aisle;
  final String? rack;
  final String? bin;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'locationId': locationId,
      'locationName': locationName,
      'quantity': quantity,
      'zone': zone,
      'aisle': aisle,
      'rack': rack,
      'bin': bin,
      'notes': notes,
    };
  }

  StorageLocationModel copyWith({
    String? locationId,
    String? locationName,
    double? quantity,
    String? zone,
    String? aisle,
    String? rack,
    String? bin,
    String? notes,
  }) {
    return StorageLocationModel(
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      quantity: quantity ?? this.quantity,
      zone: zone ?? this.zone,
      aisle: aisle ?? this.aisle,
      rack: rack ?? this.rack,
      bin: bin ?? this.bin,
      notes: notes ?? this.notes,
    );
  }
}
