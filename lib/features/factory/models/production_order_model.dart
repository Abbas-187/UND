import 'package:meta/meta.dart';
import 'material_model.dart'; // Importing MaterialModel

@immutable
class ProductionOrderModel {
  const ProductionOrderModel({
    required this.id,
    required this.requiredMaterials,
    required this.scheduledDate,
  });

  final String id;
  final List<MaterialModel> requiredMaterials;

  final DateTime scheduledDate;

  factory ProductionOrderModel.fromJson(Map<String, dynamic> json) {
    final materials = (json['requiredMaterials'] as List<dynamic>)
        .map((e) => MaterialModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return ProductionOrderModel(
      id: json['id'] as String,
      requiredMaterials: materials,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requiredMaterials': requiredMaterials.map((e) => e.toJson()).toList(),
      'scheduledDate': scheduledDate.toIso8601String(),
    };
  }
}
