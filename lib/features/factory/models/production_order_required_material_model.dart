import 'package:meta/meta.dart';

@immutable
class ProductionOrderRequiredMaterial {

  factory ProductionOrderRequiredMaterial.fromJson(Map<String, dynamic> json) {
    return ProductionOrderRequiredMaterial(
      materialId: json['materialId'] as String,
      requiredQuantity: (json['requiredQuantity'] as num).toDouble(),
    );
  }
  const ProductionOrderRequiredMaterial({
    required this.materialId,
    required this.requiredQuantity,
  });

  final String materialId;
  final double requiredQuantity;

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'requiredQuantity': requiredQuantity,
    };
  }
}
