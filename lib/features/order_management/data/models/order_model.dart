import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order_entity.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel {

  OrderModel({
    required this.id,
    required this.customerName,
    required this.date,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  factory OrderModel.fromEntity(OrderEntity entity) => OrderModel(
        id: entity.id,
        customerName: entity.customerName,
        date: entity.date,
        items: entity.items,
      );
  final String id;
  final String customerName;
  final DateTime date;
  final List<dynamic> items;
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  OrderEntity toEntity() => OrderEntity(
        id: id,
        customerName: customerName,
        date: date,
        items: items,
      );
}

class OrderItem {

  OrderItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.productId,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        name: json['name'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'] as String,
        productId: json['productId'] as String,
      );
  final String name;
  final double quantity;
  final String unit;
  final String productId;

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'productId': productId,
      };
}
