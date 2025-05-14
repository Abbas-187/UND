import 'package:equatable/equatable.dart';

class InventoryItem extends Equatable {

  const InventoryItem({
    required this.productId,
    required this.availableQuantity,
    required this.reservedQuantity,
  });
  final String productId;
  final double availableQuantity;
  final double reservedQuantity;

  @override
  List<Object?> get props => [productId, availableQuantity, reservedQuantity];
}
