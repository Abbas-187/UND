import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/inventory_item.dart';

part 'inventory_model.g.dart';

@JsonSerializable()
class InventoryModel {

  InventoryModel({
    required this.productId,
    required this.availableQuantity,
    required this.reservedQuantity,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryModelFromJson(json);

  factory InventoryModel.fromEntity(InventoryItem entity) => InventoryModel(
        productId: entity.productId,
        availableQuantity: entity.availableQuantity,
        reservedQuantity: entity.reservedQuantity,
      );
  final String productId;
  final double availableQuantity;
  final double reservedQuantity;
  Map<String, dynamic> toJson() => _$InventoryModelToJson(this);

  InventoryItem toEntity() => InventoryItem(
        productId: productId,
        availableQuantity: availableQuantity,
        reservedQuantity: reservedQuantity,
      );
}
