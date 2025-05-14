import 'package:meta/meta.dart';
import '../../../factory/data/models/material_requisition_item_model.dart'; // Use requisition item model

@immutable
class MaterialRequisitionModel {
  factory MaterialRequisitionModel.fromJson(Map<String, dynamic> json) {
    final materials = (json['materials'] as List<dynamic>)
        .map((e) =>
            MaterialRequisitionItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return MaterialRequisitionModel(
      id: json['id'] as String,
      productionOrderId: json['productionOrderId'] as String,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      materials: materials,
    );
  }
  const MaterialRequisitionModel({
    required this.id,
    required this.productionOrderId,
    required this.scheduledDate,
    required this.materials,
  });

  final String id;
  final String productionOrderId;
  final DateTime scheduledDate;
  final List<MaterialRequisitionItemModel> materials;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productionOrderId': productionOrderId,
      'scheduledDate': scheduledDate.toIso8601String(),
      'materials': materials.map((e) => e.toJson()).toList(),
    };
  }
}
