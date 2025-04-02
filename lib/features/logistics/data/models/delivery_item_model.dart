class DeliveryItemModel {
  const DeliveryItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.unitWeightKg,
    this.batchNumber,
    this.expiryDate,
    this.delivered,
    this.inventoryItemId,
    required this.requiresTemperatureControl,
    this.requiredMinTemperature,
    this.requiredMaxTemperature,
    this.notes,
  });

  factory DeliveryItemModel.fromJson(Map<String, dynamic> json) =>
      DeliveryItemModel(
        id: json['id'] as String,
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'] as String,
        unitWeightKg: (json['unitWeightKg'] as num).toDouble(),
        batchNumber: json['batchNumber'] as String?,
        expiryDate: json['expiryDate'] == null
            ? null
            : DateTime.parse(json['expiryDate'] as String),
        delivered: json['delivered'] as bool?,
        inventoryItemId: json['inventoryItemId'] as String?,
        requiresTemperatureControl: json['requiresTemperatureControl'] as bool,
        requiredMinTemperature:
            (json['requiredMinTemperature'] as num?)?.toDouble(),
        requiredMaxTemperature:
            (json['requiredMaxTemperature'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
      );

  final String id;
  final String productId;
  final String productName;
  final double quantity;
  final String unit;
  final double unitWeightKg;
  final String? batchNumber;
  final DateTime? expiryDate;
  final bool? delivered;
  final String? inventoryItemId;
  final bool requiresTemperatureControl;
  final double? requiredMinTemperature;
  final double? requiredMaxTemperature;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'unit': unit,
        'unitWeightKg': unitWeightKg,
        'batchNumber': batchNumber,
        'expiryDate': expiryDate?.toIso8601String(),
        'delivered': delivered,
        'inventoryItemId': inventoryItemId,
        'requiresTemperatureControl': requiresTemperatureControl,
        'requiredMinTemperature': requiredMinTemperature,
        'requiredMaxTemperature': requiredMaxTemperature,
        'notes': notes,
      };

  DeliveryItemModel copyWith({
    String? id,
    String? productId,
    String? productName,
    double? quantity,
    String? unit,
    double? unitWeightKg,
    String? batchNumber,
    DateTime? expiryDate,
    bool? delivered,
    String? inventoryItemId,
    bool? requiresTemperatureControl,
    double? requiredMinTemperature,
    double? requiredMaxTemperature,
    String? notes,
  }) =>
      DeliveryItemModel(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        productName: productName ?? this.productName,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        unitWeightKg: unitWeightKg ?? this.unitWeightKg,
        batchNumber: batchNumber ?? this.batchNumber,
        expiryDate: expiryDate ?? this.expiryDate,
        delivered: delivered ?? this.delivered,
        inventoryItemId: inventoryItemId ?? this.inventoryItemId,
        requiresTemperatureControl:
            requiresTemperatureControl ?? this.requiresTemperatureControl,
        requiredMinTemperature:
            requiredMinTemperature ?? this.requiredMinTemperature,
        requiredMaxTemperature:
            requiredMaxTemperature ?? this.requiredMaxTemperature,
        notes: notes ?? this.notes,
      );
}
