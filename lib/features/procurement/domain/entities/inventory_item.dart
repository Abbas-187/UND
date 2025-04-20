import 'package:meta/meta.dart';

/// Represents an inventory item.
@immutable
class InventoryItem {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final double price;
  final double reorderPoint;
  final double minimumQuantity;
  final List<String> supplierIds;

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
