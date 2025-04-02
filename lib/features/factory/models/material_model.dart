import 'package:meta/meta.dart';

@immutable
class MaterialModel {
  const MaterialModel({
    required this.materialId,
    required this.requiredQuantity,
  });

  final String materialId;
  final double requiredQuantity;

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      materialId: json['materialId'] as String,
      requiredQuantity: (json['requiredQuantity'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'requiredQuantity': requiredQuantity,
    };
  }
}
