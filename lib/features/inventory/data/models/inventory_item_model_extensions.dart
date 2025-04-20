import '../models/inventory_item_model.dart';

/// Extensions for InventoryItemModel to add necessary functionality
/// without modifying the original class
extension InventoryItemModelExtensions on InventoryItemModel {
  /// Create a simplified JSON representation for storage
  Map<String, dynamic> toSimpleJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
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
      'currentTemperature': currentTemperature,
      'storageCondition': storageCondition,
      'overallQualityStatus': overallQualityStatus?.toString().split('.').last,
      'fatContent': fatContent,
      'pasteurized': pasteurized,
      'sourceInfo': sourceInfo,
      'processingDate': processingDate?.toIso8601String(),
    };
  }
}

/// Extension to add fromJson factory to InventoryItemModel
extension InventoryItemModelFactory on InventoryItemModel {
  /// Create an InventoryItemModel from simple JSON representation
  static InventoryItemModel fromJson(Map<String, dynamic> json) {
    // Parse quality status
    QualityStatus? qualityStatus;
    if (json['overallQualityStatus'] != null) {
      try {
        qualityStatus = QualityStatus.values.firstWhere(
          (status) =>
              status.toString().split('.').last == json['overallQualityStatus'],
          orElse: () => QualityStatus.acceptable,
        );
      } catch (e) {
        qualityStatus = QualityStatus.acceptable;
      }
    }

    return InventoryItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
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
      searchTerms: json['searchTerms'] as List<String>?,
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : null,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 5,
      currentTemperature: json['currentTemperature'] != null
          ? (json['currentTemperature'] as num).toDouble()
          : null,
      storageCondition: json['storageCondition'] as String?,
      overallQualityStatus: qualityStatus,
      fatContent: json['fatContent'] != null
          ? (json['fatContent'] as num).toDouble()
          : null,
      pasteurized: json['pasteurized'] as bool? ?? true,
      sourceInfo: json['sourceInfo'] as Map<String, dynamic>?,
      processingDate: json['processingDate'] != null
          ? DateTime.parse(json['processingDate'] as String)
          : null,
    );
  }
}
