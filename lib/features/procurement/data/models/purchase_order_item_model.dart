/// Enum representing different statuses a purchase order item can have
enum PurchaseOrderItemStatus { pending, delivered, rejected }

/// Converts [PurchaseOrderItemStatus] enum to string
String purchaseOrderItemStatusToString(PurchaseOrderItemStatus status) {
  return status.toString().split('.').last;
}

/// Converts string to [PurchaseOrderItemStatus] enum
PurchaseOrderItemStatus purchaseOrderItemStatusFromString(String status) {
  return PurchaseOrderItemStatus.values.firstWhere(
    (e) => e.toString().split('.').last == status,
    orElse: () =>
        throw ArgumentError('Invalid purchase order item status: $status'),
  );
}

/// Model class representing a line item in a purchase order
class PurchaseOrderItem {
  /// Unique identifier for the purchase order item
  final String id;

  /// Identifier of the purchase order this item belongs to
  final String purchaseOrderId;

  /// Identifier of the material being ordered
  final String materialId;

  /// Name of the material being ordered
  final String materialName;

  /// Code of the material being ordered
  final String materialCode;

  /// Quantity of material being ordered
  final double quantity;

  /// Unit of measurement (e.g., kg, liters, pieces)
  final String unit;

  /// Price per unit
  final double unitPrice;

  /// Total price (quantity * unitPrice)
  final double totalPrice;

  /// Expected date of delivery for this specific item
  final DateTime expectedDeliveryDate;

  /// Actual date of delivery for this specific item
  final DateTime? actualDeliveryDate;

  /// Quality parameters specific to the material (e.g., fat percentage for milk)
  final Map<String, dynamic> qualityParameters;

  /// Additional notes specific to this item
  final String? notes;

  /// Current status of this item
  final PurchaseOrderItemStatus status;

  /// Creates a new [PurchaseOrderItem] instance
  PurchaseOrderItem({
    required this.id,
    required this.purchaseOrderId,
    required this.materialId,
    required this.materialName,
    required this.materialCode,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    required this.expectedDeliveryDate,
    this.actualDeliveryDate,
    required this.qualityParameters,
    this.notes,
    required this.status,
  });

  /// Creates a copy of this [PurchaseOrderItem] instance with the given fields replaced
  PurchaseOrderItem copyWith({
    String? id,
    String? purchaseOrderId,
    String? materialId,
    String? materialName,
    String? materialCode,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? totalPrice,
    DateTime? expectedDeliveryDate,
    DateTime? actualDeliveryDate,
    Map<String, dynamic>? qualityParameters,
    String? notes,
    PurchaseOrderItemStatus? status,
  }) {
    return PurchaseOrderItem(
      id: id ?? this.id,
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      materialCode: materialCode ?? this.materialCode,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      qualityParameters: qualityParameters ?? Map.from(this.qualityParameters),
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  /// Converts this [PurchaseOrderItem] instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchase_order_id': purchaseOrderId,
      'material_id': materialId,
      'material_name': materialName,
      'material_code': materialCode,
      'quantity': quantity,
      'unit': unit,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'expected_delivery_date': expectedDeliveryDate.toIso8601String(),
      'actual_delivery_date': actualDeliveryDate?.toIso8601String(),
      'quality_parameters': qualityParameters,
      'notes': notes,
      'status': purchaseOrderItemStatusToString(status),
    };
  }

  /// Creates a [PurchaseOrderItem] instance from a JSON map
  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      id: json['id'],
      purchaseOrderId: json['purchase_order_id'],
      materialId: json['material_id'],
      materialName: json['material_name'],
      materialCode: json['material_code'],
      quantity: json['quantity'],
      unit: json['unit'],
      unitPrice: json['unit_price'],
      totalPrice: json['total_price'],
      expectedDeliveryDate: DateTime.parse(json['expected_delivery_date']),
      actualDeliveryDate: json['actual_delivery_date'] != null
          ? DateTime.parse(json['actual_delivery_date'])
          : null,
      qualityParameters: Map<String, dynamic>.from(json['quality_parameters']),
      notes: json['notes'],
      status: purchaseOrderItemStatusFromString(json['status']),
    );
  }

  @override
  String toString() {
    return 'PurchaseOrderItem(id: $id, materialName: $materialName, quantity: $quantity $unit, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PurchaseOrderItem &&
        other.id == id &&
        other.purchaseOrderId == purchaseOrderId &&
        other.materialId == materialId &&
        other.materialName == materialName &&
        other.materialCode == materialCode &&
        other.quantity == quantity &&
        other.unit == unit &&
        other.unitPrice == unitPrice &&
        other.totalPrice == totalPrice &&
        other.expectedDeliveryDate == expectedDeliveryDate &&
        other.actualDeliveryDate == actualDeliveryDate &&
        _mapEquals(other.qualityParameters, qualityParameters) &&
        other.notes == notes &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      purchaseOrderId,
      materialId,
      materialName,
      materialCode,
      quantity,
      unit,
      unitPrice,
      totalPrice,
      expectedDeliveryDate,
      actualDeliveryDate,
      Object.hashAllUnordered(qualityParameters.entries),
      notes,
      status,
    );
  }

  /// Helper method to check equality of maps
  bool _mapEquals(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) return false;
    }
    return true;
  }
}
