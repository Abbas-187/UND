class DeliveryItemModel {
  final String id;
  final String productId;
  final String productName;
  final double quantity;
  final String unit;
  final double weightKg;

  DeliveryItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.weightKg,
  });

  factory DeliveryItemModel.fromJson(Map<String, dynamic> json) {
    return DeliveryItemModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      weightKg: (json['weightKg'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
      'weightKg': weightKg,
    };
  }
}

class DeliveryModel {
  final String id;
  final String? customerName;
  final DateTime? scheduledDate;
  final List<DeliveryItemModel>? items;

  DeliveryModel(
      {required this.id, this.customerName, this.scheduledDate, this.items});
}
