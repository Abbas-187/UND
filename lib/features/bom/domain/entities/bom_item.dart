import 'package:freezed_annotation/freezed_annotation.dart';

part 'bom_item.freezed.dart';
part 'bom_item.g.dart';

/// Enumeration for BOM item types
enum BomItemType {
  rawMaterial,
  semiFinished,
  finishedGood,
  packaging,
  consumable,
  byProduct,
  coProduct,
}

/// Enumeration for BOM item status
enum BomItemStatus {
  active,
  inactive,
  obsolete,
  pending,
  approved,
  rejected,
}

/// Enumeration for consumption types
enum ConsumptionType {
  fixed, // Fixed quantity regardless of batch size
  variable, // Variable based on batch size
  optional, // Optional ingredient
  alternative, // Alternative ingredient
}

/// BOM Item entity representing a component in a Bill of Materials
@freezed
abstract class BomItem with _$BomItem {
  const factory BomItem({
    required String id,
    required String bomId,
    required String itemId,
    required String itemCode,
    required String itemName,
    required String itemDescription,
    required BomItemType itemType,
    required double quantity,
    required String unit,
    required ConsumptionType consumptionType,
    required int sequenceNumber,
    @Default(0.0) double wastagePercentage,
    @Default(0.0) double yieldPercentage,
    @Default(0.0) double costPerUnit,
    @Default(0.0) double totalCost,
    String? alternativeItemId,
    String? supplierCode,
    String? batchNumber,
    DateTime? expiryDate,
    String? qualityGrade,
    String? storageLocation,
    Map<String, dynamic>? specifications,
    Map<String, dynamic>? qualityParameters,
    @Default(BomItemStatus.active) BomItemStatus status,
    String? notes,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? createdBy,
    String? updatedBy,
  }) = _BomItem;

  const BomItem._();

  factory BomItem.fromJson(Map<String, dynamic> json) =>
      _$BomItemFromJson(json);

  /// Calculate actual quantity needed based on batch size and wastage
  double calculateActualQuantity(double batchSize) {
    double baseQuantity = consumptionType == ConsumptionType.fixed
        ? quantity
        : quantity * batchSize;

    // Add wastage
    double wastageAmount = baseQuantity * (wastagePercentage / 100);
    return baseQuantity + wastageAmount;
  }

  /// Calculate total cost for this item
  double calculateTotalCost(double batchSize) {
    double actualQuantity = calculateActualQuantity(batchSize);
    return actualQuantity * costPerUnit;
  }

  /// Check if item is active and within effective dates
  bool get isActive {
    if (status != BomItemStatus.active) return false;

    final now = DateTime.now();
    if (effectiveFrom != null && now.isBefore(effectiveFrom!)) return false;
    if (effectiveTo != null && now.isAfter(effectiveTo!)) return false;

    return true;
  }

  /// Check if item needs quality inspection
  bool get requiresQualityInspection {
    return qualityParameters != null && qualityParameters!.isNotEmpty;
  }

  /// Get formatted display name
  String get displayName => '$itemCode - $itemName';
}
