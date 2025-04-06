import 'package:meta/meta.dart';

@immutable
class MaterialModel {

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      materialId: json['materialId'] as String,
      requiredQuantity: (json['requiredQuantity'] as num).toDouble(),
    );
  }
  const MaterialModel({
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
