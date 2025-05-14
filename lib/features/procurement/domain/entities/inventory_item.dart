import 'package:meta/meta.dart';

/// Represents an inventory item.
@immutable
class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.reorderPoint,
    required this.minimumQuantity,
    required this.supplierIds,
  });
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final double price;
  final double reorderPoint;
  final double minimumQuantity;
  final List<String> supplierIds;

  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    double? price,
    double? reorderPoint,
    double? minimumQuantity,
    List<String>? supplierIds,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      minimumQuantity: minimumQuantity ?? this.minimumQuantity,
      supplierIds: supplierIds ?? this.supplierIds,
    );
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      reorderPoint: (json['reorderPoint'] as num?)?.toDouble() ?? 0.0,
      minimumQuantity: (json['minimumQuantity'] as num?)?.toDouble() ?? 0.0,
      supplierIds: (json['supplierIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          category == other.category &&
          quantity == other.quantity &&
          unit == other.unit &&
          price == other.price &&
          reorderPoint == other.reorderPoint &&
          minimumQuantity == other.minimumQuantity;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      category.hashCode ^
      quantity.hashCode ^
      unit.hashCode ^
      price.hashCode ^
      reorderPoint.hashCode ^
      minimumQuantity.hashCode;
}
