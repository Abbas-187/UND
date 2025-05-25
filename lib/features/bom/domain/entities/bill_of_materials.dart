import 'package:freezed_annotation/freezed_annotation.dart';
import 'bom_item.dart';

part 'bill_of_materials.freezed.dart';
part 'bill_of_materials.g.dart';

/// Enumeration for BOM types
enum BomType {
  production, // Production BOM for manufacturing
  engineering, // Engineering BOM for design
  sales, // Sales BOM for customer quotes
  costing, // Costing BOM for financial analysis
  planning, // Planning BOM for MRP
}

/// Enumeration for BOM status
enum BomStatus {
  draft,
  active,
  inactive,
  obsolete,
  underReview,
  approved,
  rejected,
}

/// Bill of Materials entity representing a complete product structure
@freezed
abstract class BillOfMaterials with _$BillOfMaterials {
  const factory BillOfMaterials({
    required String id,
    required String bomCode,
    required String bomName,
    required String productId,
    required String productCode,
    required String productName,
    required BomType bomType,
    required String version,
    required double baseQuantity,
    required String baseUnit,
    @Default(BomStatus.draft) BomStatus status,
    @Default([]) List<BomItem> items,
    @Default(0.0) double totalCost,
    @Default(0.0) double laborCost,
    @Default(0.0) double overheadCost,
    @Default(0.0) double setupCost,
    @Default(0.0) double yieldPercentage,
    String? description,
    String? notes,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
    Map<String, dynamic>? productionInstructions,
    Map<String, dynamic>? qualityRequirements,
    Map<String, dynamic>? packagingInstructions,
    List<String>? alternativeBomIds,
    String? parentBomId,
    @Default([]) List<String> childBomIds,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? createdBy,
    String? updatedBy,
  }) = _BillOfMaterials;

  const BillOfMaterials._();

  factory BillOfMaterials.fromJson(Map<String, dynamic> json) =>
      _$BillOfMaterialsFromJson(json);

  /// Calculate total material cost for given batch size
  double calculateMaterialCost(double batchSize) {
    double materialCost = 0.0;
    for (final item in items) {
      if (item.isActive) {
        materialCost += item.calculateTotalCost(batchSize);
      }
    }
    return materialCost;
  }

  /// Calculate total BOM cost including labor and overhead
  double calculateTotalBomCost(double batchSize) {
    double materialCost = calculateMaterialCost(batchSize);
    double scaledLaborCost = laborCost * (batchSize / baseQuantity);
    double scaledOverheadCost = overheadCost * (batchSize / baseQuantity);
    return materialCost + scaledLaborCost + scaledOverheadCost + setupCost;
  }

  /// Get all raw materials from BOM
  List<BomItem> get rawMaterials {
    return items
        .where(
            (item) => item.itemType == BomItemType.rawMaterial && item.isActive)
        .toList();
  }

  /// Get all packaging materials from BOM
  List<BomItem> get packagingMaterials {
    return items
        .where(
            (item) => item.itemType == BomItemType.packaging && item.isActive)
        .toList();
  }

  /// Get all semi-finished goods from BOM
  List<BomItem> get semiFinishedGoods {
    return items
        .where((item) =>
            item.itemType == BomItemType.semiFinished && item.isActive)
        .toList();
  }

  /// Check if BOM is valid for production
  bool get isValidForProduction {
    return status == BomStatus.active &&
        items.isNotEmpty &&
        items.any((item) => item.isActive);
  }

  /// Get BOM complexity level
  String get complexityLevel {
    int activeItems = items.where((item) => item.isActive).length;
    if (activeItems <= 5) return 'Simple';
    if (activeItems <= 15) return 'Medium';
    return 'Complex';
  }

  /// Check if BOM requires quality inspection
  bool get requiresQualityInspection {
    return items.any((item) => item.requiresQualityInspection);
  }

  /// Get all unique suppliers from BOM items
  List<String> get uniqueSuppliers {
    return items
        .where((item) => item.supplierCode != null)
        .map((item) => item.supplierCode!)
        .toSet()
        .toList();
  }

  /// Calculate expected yield quantity
  double calculateExpectedYield(double batchSize) {
    return batchSize * (yieldPercentage / 100);
  }

  /// Get critical path items (items with longest lead times)
  List<BomItem> getCriticalPathItems() {
    // This would typically involve lead time data
    // For now, return items sorted by sequence number
    return items.where((item) => item.isActive).toList()
      ..sort((a, b) => a.sequenceNumber.compareTo(b.sequenceNumber));
  }
}
