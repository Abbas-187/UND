import '../models/inventory_item_model.dart';

/// Extensions for InventoryItemModel to add necessary functionality
/// without modifying the original class
extension InventoryItemModelExtensions on InventoryItemModel {
  /// Create a simplified JSON representation for storage
  Map<String, dynamic> toSimpleJson() {
    return {
      'id': id,
      'appItemId': appItemId,
      'sapCode': sapCode,
      'name': name,
      'category': category,
      'subCategory': subCategory,
      'unit': unit,
      'quantity': quantity,
      'minimumQuantity': minimumQuantity,
      'reorderPoint': reorderPoint,
      'location': location,
      'lastUpdated': lastUpdated.toIso8601String(),
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'additionalAttributes': additionalAttributes,
      'cost': cost,
      'lowStockThreshold': lowStockThreshold,
      'supplier': supplier,
    };
  }
}

/// Extension to add fromJson factory to InventoryItemModel
extension InventoryItemModelFactory on InventoryItemModel {
  /// Create an InventoryItemModel from simple JSON representation
  static InventoryItemModel fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'] as String?,
      appItemId: json['appItemId'] as String,
      sapCode: json['sapCode'] as String? ?? '',
      name: json['name'] as String,
      category: json['category'] as String,
      subCategory: json['subCategory'] as String? ?? '',
      unit: json['unit'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      minimumQuantity: (json['minimumQuantity'] as num).toDouble(),
      reorderPoint: (json['reorderPoint'] as num).toDouble(),
      location: json['location'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      additionalAttributes:
          json['additionalAttributes'] as Map<String, dynamic>?,
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : null,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 5,
      supplier: json['supplier'] as String?,
    );
  }
}
