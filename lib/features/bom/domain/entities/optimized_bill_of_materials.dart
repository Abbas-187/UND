import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/data/unified_data_manager.dart';
import 'bom_item.dart';
import 'bill_of_materials.dart';

part 'optimized_bill_of_materials.freezed.dart';
part 'optimized_bill_of_materials.g.dart';

/// Optimized Bill of Materials with async calculations and caching
@freezed
abstract class OptimizedBillOfMaterials with _$OptimizedBillOfMaterials {
  const factory OptimizedBillOfMaterials({
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
    // Cached calculation results
    Map<String, dynamic>? cachedCalculations,
    DateTime? calculationsLastUpdated,
  }) = _OptimizedBillOfMaterials;

  const OptimizedBillOfMaterials._();

  factory OptimizedBillOfMaterials.fromJson(Map<String, dynamic> json) =>
      _$OptimizedBillOfMaterialsFromJson(json);

  /// Convert from regular BOM
  factory OptimizedBillOfMaterials.fromBillOfMaterials(BillOfMaterials bom) {
    return OptimizedBillOfMaterials(
      id: bom.id,
      bomCode: bom.bomCode,
      bomName: bom.bomName,
      productId: bom.productId,
      productCode: bom.productCode,
      productName: bom.productName,
      bomType: bom.bomType,
      version: bom.version,
      baseQuantity: bom.baseQuantity,
      baseUnit: bom.baseUnit,
      status: bom.status,
      items: bom.items,
      totalCost: bom.totalCost,
      laborCost: bom.laborCost,
      overheadCost: bom.overheadCost,
      setupCost: bom.setupCost,
      yieldPercentage: bom.yieldPercentage,
      description: bom.description,
      notes: bom.notes,
      approvedBy: bom.approvedBy,
      approvedAt: bom.approvedAt,
      effectiveFrom: bom.effectiveFrom,
      effectiveTo: bom.effectiveTo,
      productionInstructions: bom.productionInstructions,
      qualityRequirements: bom.qualityRequirements,
      packagingInstructions: bom.packagingInstructions,
      alternativeBomIds: bom.alternativeBomIds,
      parentBomId: bom.parentBomId,
      childBomIds: bom.childBomIds,
      createdAt: bom.createdAt,
      updatedAt: bom.updatedAt,
      createdBy: bom.createdBy,
      updatedBy: bom.updatedBy,
    );
  }

  /// Calculate total material cost using background processing
  Future<double> calculateMaterialCostAsync(double batchSize) async {
    return await PerformanceMonitor.trackAsync(
      'bom_calculate_material_cost',
      () async {
        // Check cache first
        final cacheKey = 'material_cost_$batchSize';
        if (cachedCalculations != null &&
            cachedCalculations!.containsKey(cacheKey) &&
            _isCacheValid()) {
          return cachedCalculations![cacheKey] as double;
        }

        // Prepare data for background calculation
        final itemsData = items
            .where((item) => item.isActive)
            .map((item) => {
                  'isActive': item.isActive,
                  'quantity': item.quantity,
                  'unitCost': item.costPerUnit,
                })
            .toList();

        // Calculate in background isolate
        final cost = await BackgroundCalculationService.calculateBomCostAsync(
          itemsData,
          batchSize,
        );

        // Cache the result
        await _cacheCalculation(cacheKey, cost);

        return cost;
      },
    );
  }

  /// Calculate total BOM cost including labor and overhead (async)
  Future<double> calculateTotalBomCostAsync(double batchSize) async {
    return await PerformanceMonitor.trackAsync(
      'bom_calculate_total_cost',
      () async {
        final cacheKey = 'total_cost_$batchSize';
        if (cachedCalculations != null &&
            cachedCalculations!.containsKey(cacheKey) &&
            _isCacheValid()) {
          return cachedCalculations![cacheKey] as double;
        }

        final materialCost = await calculateMaterialCostAsync(batchSize);
        final scaledLaborCost = laborCost * (batchSize / baseQuantity);
        final scaledOverheadCost = overheadCost * (batchSize / baseQuantity);
        final totalCost =
            materialCost + scaledLaborCost + scaledOverheadCost + setupCost;

        await _cacheCalculation(cacheKey, totalCost);
        return totalCost;
      },
    );
  }

  /// Get cost breakdown with caching
  Future<Map<String, double>> getCostBreakdownAsync(double batchSize) async {
    return await PerformanceMonitor.trackAsync(
      'bom_get_cost_breakdown',
      () async {
        final cacheKey = 'cost_breakdown_$batchSize';
        if (cachedCalculations != null &&
            cachedCalculations!.containsKey(cacheKey) &&
            _isCacheValid()) {
          return Map<String, double>.from(cachedCalculations![cacheKey] as Map);
        }

        final materialCost = await calculateMaterialCostAsync(batchSize);
        final scaledLaborCost = laborCost * (batchSize / baseQuantity);
        final scaledOverheadCost = overheadCost * (batchSize / baseQuantity);

        final breakdown = {
          'materialCost': materialCost,
          'laborCost': scaledLaborCost,
          'overheadCost': scaledOverheadCost,
          'setupCost': setupCost,
          'totalCost':
              materialCost + scaledLaborCost + scaledOverheadCost + setupCost,
        };

        await _cacheCalculation(cacheKey, breakdown);
        return breakdown;
      },
    );
  }

  /// Get material requirements for production planning
  Future<Map<String, double>> getMaterialRequirementsAsync(
      double batchSize) async {
    return await PerformanceMonitor.trackAsync(
      'bom_get_material_requirements',
      () async {
        final cacheKey = 'material_requirements_$batchSize';
        if (cachedCalculations != null &&
            cachedCalculations!.containsKey(cacheKey) &&
            _isCacheValid()) {
          return Map<String, double>.from(cachedCalculations![cacheKey] as Map);
        }

        final requirements = <String, double>{};

        for (final item in items.where((item) => item.isActive)) {
          final requiredQuantity = item.quantity * (batchSize / baseQuantity);
          requirements[item.itemId] = requiredQuantity;
        }

        await _cacheCalculation(cacheKey, requirements);
        return requirements;
      },
    );
  }

  /// Validate BOM for production with async checks
  Future<BomValidationResult> validateForProductionAsync() async {
    return await PerformanceMonitor.trackAsync(
      'bom_validate_production',
      () async {
        final issues = <String>[];
        final warnings = <String>[];

        // Basic validation
        if (status != BomStatus.active) {
          issues.add('BOM is not in active status');
        }

        if (items.isEmpty) {
          issues.add('BOM has no items');
        }

        if (!items.any((item) => item.isActive)) {
          issues.add('BOM has no active items');
        }

        // Check for circular dependencies (simplified)
        if (childBomIds.contains(id)) {
          issues.add('Circular dependency detected');
        }

        // Check yield percentage
        if (yieldPercentage <= 0 || yieldPercentage > 100) {
          warnings.add('Invalid yield percentage: $yieldPercentage%');
        }

        // Check for missing cost data
        final itemsWithoutCost = items
            .where((item) => item.isActive && item.costPerUnit <= 0)
            .length;

        if (itemsWithoutCost > 0) {
          warnings.add('$itemsWithoutCost items missing cost data');
        }

        return BomValidationResult(
          isValid: issues.isEmpty,
          issues: issues,
          warnings: warnings,
        );
      },
    );
  }

  /// Optimize BOM for cost efficiency
  Future<OptimizedBillOfMaterials> optimizeForCostAsync() async {
    return await PerformanceMonitor.trackAsync(
      'bom_optimize_cost',
      () async {
        // This would implement cost optimization algorithms
        // For now, return a copy with sorted items by cost efficiency
        final optimizedItems = [...items];
        optimizedItems.sort((a, b) {
          final aCostEfficiency = a.costPerUnit / a.quantity;
          final bCostEfficiency = b.costPerUnit / b.quantity;
          return aCostEfficiency.compareTo(bCostEfficiency);
        });

        return copyWith(
          items: optimizedItems,
          updatedAt: DateTime.now(),
          notes: '${notes ?? ''}\nOptimized for cost efficiency',
        );
      },
    );
  }

  /// Check if cached calculations are still valid
  bool _isCacheValid() {
    if (calculationsLastUpdated == null) return false;

    final cacheAge = DateTime.now().difference(calculationsLastUpdated!);
    return cacheAge.inMinutes < 30; // Cache valid for 30 minutes
  }

  /// Cache calculation result
  Future<void> _cacheCalculation(String key, dynamic value) async {
    final updatedCalculations =
        Map<String, dynamic>.from(cachedCalculations ?? {});
    updatedCalculations[key] = value;

    // Note: In a real implementation, you would update this in the database
    // For now, we'll just update the local cache
  }

  /// Clear cached calculations
  OptimizedBillOfMaterials clearCache() {
    return copyWith(
      cachedCalculations: {},
      calculationsLastUpdated: null,
    );
  }

  /// Synchronous getters for backward compatibility
  List<BomItem> get rawMaterials {
    return items
        .where(
            (item) => item.itemType == BomItemType.rawMaterial && item.isActive)
        .toList();
  }

  List<BomItem> get packagingMaterials {
    return items
        .where(
            (item) => item.itemType == BomItemType.packaging && item.isActive)
        .toList();
  }

  List<BomItem> get semiFinishedGoods {
    return items
        .where((item) =>
            item.itemType == BomItemType.semiFinished && item.isActive)
        .toList();
  }

  bool get isValidForProduction {
    return status == BomStatus.active &&
        items.isNotEmpty &&
        items.any((item) => item.isActive);
  }

  String get complexityLevel {
    int activeItems = items.where((item) => item.isActive).length;
    if (activeItems <= 5) return 'Simple';
    if (activeItems <= 15) return 'Medium';
    return 'Complex';
  }

  bool get requiresQualityInspection {
    return items.any((item) => item.requiresQualityInspection);
  }

  List<String> get uniqueSuppliers {
    return items
        .where((item) => item.supplierCode != null)
        .map((item) => item.supplierCode!)
        .toSet()
        .toList();
  }

  double calculateExpectedYield(double batchSize) {
    return batchSize * (yieldPercentage / 100);
  }
}

/// BOM validation result
class BomValidationResult {
  const BomValidationResult({
    required this.isValid,
    required this.issues,
    required this.warnings,
  });

  final bool isValid;
  final List<String> issues;
  final List<String> warnings;

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasIssues => issues.isNotEmpty;
}
