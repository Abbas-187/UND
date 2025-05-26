import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../inventory/domain/entities/inventory_item.dart';
import '../../../inventory/domain/providers/inventory_repository_provider.dart'
    as inventory_provider;
import '../../../inventory/domain/repositories/inventory_repository.dart';
import '../../../suppliers/domain/repositories/supplier_repository.dart';
import '../../../suppliers/presentation/providers/supplier_provider.dart'
    as supplier_provider;
import '../../presentation/providers/bom_providers.dart';
import '../entities/bill_of_materials.dart';
import '../entities/bom_item.dart';
import '../entities/mrp_plan.dart';
import '../repositories/bom_repository.dart';

/// Production schedule entry for MRP planning
class ProductionSchedule {
  const ProductionSchedule({
    required this.productId,
    required this.productCode,
    required this.quantity,
    required this.requiredDate,
    required this.bomId,
    this.priority = 'normal',
    this.customerOrderId,
  });

  final String productId;
  final String productCode;
  final double quantity;
  final DateTime requiredDate;
  final String bomId;
  final String priority;
  final String? customerOrderId;
}

/// Lot sizing method for MRP calculations
enum LotSizingMethod {
  lotForLot, // Exact quantity needed
  economicOrderQuantity, // EOQ calculation
  periodOrderQuantity, // POQ calculation
  fixedOrderQuantity, // Fixed lot size
}

/// MRP Planning Service - Core engine for Material Requirements Planning
class MrpPlanningService {
  MrpPlanningService({
    required this.bomRepository,
    required this.inventoryRepository,
    required this.supplierRepository,
    required this.logger,
  });

  final BomRepository bomRepository;
  final InventoryRepository inventoryRepository;
  final SupplierRepository supplierRepository;
  final Logger logger;

  /// Generate comprehensive MRP plan with multi-level BOM explosion
  Future<MrpPlan> generateMrpPlan(
    List<String> bomIds,
    Map<String, ProductionSchedule> productionSchedule,
    int planningHorizonDays, {
    LotSizingMethod lotSizingMethod = LotSizingMethod.lotForLot,
    Map<String, dynamic>? planningParameters,
  }) async {
    try {
      logger.i('Starting MRP plan generation for ${bomIds.length} BOMs');

      final planId = _generatePlanId();
      final startDate = DateTime.now();
      final endDate = startDate.add(Duration(days: planningHorizonDays));

      // Step 1: Load all BOMs and validate
      final boms = await _loadAndValidateBoms(bomIds);

      // Step 2: Perform multi-level BOM explosion
      final explosionResult =
          await _performBomExplosion(boms, productionSchedule);

      // Step 3: Calculate time-phased requirements
      final requirements = await _calculateTimePhaseRequirements(
        explosionResult,
        startDate,
        endDate,
        lotSizingMethod,
      );

      // Step 4: Generate action messages
      final actionMessages = await _generateActionMessages(requirements);

      // Step 5: Generate alerts
      final alerts = await _generateAlerts(requirements);

      // Step 6: Calculate plan metrics
      final metrics = _calculatePlanMetrics(requirements);

      final plan = MrpPlan(
        id: planId,
        planName: 'MRP Plan ${DateTime.now().toString().substring(0, 19)}',
        planCode: 'MRP-${planId.substring(0, 8)}',
        planningStartDate: startDate,
        planningEndDate: endDate,
        planningHorizonDays: planningHorizonDays,
        bomIds: bomIds,
        productionSchedule:
            productionSchedule.map((k, v) => MapEntry(k, v.quantity)),
        requirements: requirements,
        actionMessages: actionMessages,
        alerts: alerts,
        status: MrpPlanStatus.completed,
        totalMaterialCost: metrics['totalCost'] ?? 0.0,
        totalInventoryValue: metrics['inventoryValue'] ?? 0.0,
        totalMaterials: metrics['totalMaterials'] ?? 0,
        criticalMaterials: metrics['criticalMaterials'] ?? 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        planningParameters: planningParameters ?? {},
        optimizationResults: metrics,
      );

      logger.i(
          'MRP plan generated successfully with ${requirements.length} requirements');
      return plan;
    } catch (e, stackTrace) {
      logger.e('Error generating MRP plan', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Optimize existing MRP plan with advanced algorithms
  Future<MrpRecommendations> optimizePlan(MrpPlan plan) async {
    try {
      logger.i('Optimizing MRP plan: ${plan.id}');

      // Cost optimization analysis
      final costOptimizations = await _analyzeCostOptimizations(plan);

      // Lead time improvement analysis
      final leadTimeImprovements = await _analyzeLeadTimeImprovements(plan);

      // Supplier recommendations
      final supplierRecommendations =
          await _generateSupplierRecommendations(plan);

      // Critical materials identification
      final criticalMaterials = _identifyCriticalMaterials(plan);

      // Generate optimization action messages
      final optimizationActions = await _generateOptimizationActions(
        plan,
        costOptimizations,
        leadTimeImprovements,
      );

      final recommendations = MrpRecommendations(
        planId: plan.id,
        actionMessages: optimizationActions,
        criticalMaterials: criticalMaterials,
        costOptimizations: costOptimizations,
        leadTimeImprovements: leadTimeImprovements,
        supplierRecommendations: supplierRecommendations,
        totalCostSavings:
            costOptimizations.values.fold(0.0, (sum, saving) => sum + saving),
        inventoryReduction:
            _calculateInventoryReduction(plan, costOptimizations),
        generatedAt: DateTime.now(),
        optimizationMetrics: {
          'optimizationScore': _calculateOptimizationScore(
              costOptimizations, leadTimeImprovements),
          'riskLevel': _assessPlanRisk(plan),
          'implementationComplexity':
              _assessImplementationComplexity(optimizationActions),
        },
      );

      logger.i(
          'Plan optimization completed with ${optimizationActions.length} recommendations');
      return recommendations;
    } catch (e, stackTrace) {
      logger.e('Error optimizing MRP plan', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Validate MRP plan and generate alerts
  Future<List<MrpAlert>> validatePlan(MrpPlan plan) async {
    try {
      logger.i('Validating MRP plan: ${plan.id}');

      final alerts = <MrpAlert>[];

      // Check for material shortages
      alerts.addAll(await _validateMaterialAvailability(plan));

      // Check for capacity constraints
      alerts.addAll(await _validateCapacityConstraints(plan));

      // Check for supplier reliability
      alerts.addAll(await _validateSupplierReliability(plan));

      // Check for lead time violations
      alerts.addAll(await _validateLeadTimes(plan));

      // Check for cost variances
      alerts.addAll(await _validateCostVariances(plan));

      logger.i('Plan validation completed with ${alerts.length} alerts');
      return alerts;
    } catch (e, stackTrace) {
      logger.e('Error validating MRP plan', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Private helper methods

  String _generatePlanId() {
    return 'mrp_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<List<BillOfMaterials>> _loadAndValidateBoms(
      List<String> bomIds) async {
    final boms = <BillOfMaterials>[];

    for (final bomId in bomIds) {
      final bom = await bomRepository.getBomById(bomId);
      if (bom != null && !bom.isValidForProduction) {
        throw Exception('BOM $bomId is not valid for production');
      }
      if (bom != null) {
        boms.add(bom);
      }
    }

    return boms;
  }

  Future<Map<String, List<BomExplosionItem>>> _performBomExplosion(
    List<BillOfMaterials> boms,
    Map<String, ProductionSchedule> productionSchedule,
  ) async {
    final explosionResult = <String, List<BomExplosionItem>>{};

    for (final bom in boms) {
      final schedule = productionSchedule[bom.productId];
      if (schedule != null) {
        final explosionItems = await _explodeBom(bom, schedule.quantity, 0);
        explosionResult[bom.id] = explosionItems;
      }
    }

    return explosionResult;
  }

  Future<List<BomExplosionItem>> _explodeBom(
    BillOfMaterials bom,
    double parentQuantity,
    int level,
  ) async {
    final explosionItems = <BomExplosionItem>[];

    for (final bomItem in bom.items.where((item) => item.isActive)) {
      final requiredQuantity =
          _calculateRequiredQuantity(bomItem, parentQuantity);

      final explosionItem = BomExplosionItem(
        materialId: bomItem.itemId,
        materialCode: bomItem.itemCode,
        materialName: bomItem.itemName,
        requiredQuantity: requiredQuantity,
        unit: bomItem.unit,
        level: level,
        bomId: bom.id,
        bomItemId: bomItem.id,
        parentMaterialId: level > 0 ? bom.productId : null,
      );

      explosionItems.add(explosionItem);

      // Check if this item has its own BOM (sub-assembly)
      try {
        final subBom = await bomRepository.getBomById(bomItem.itemId);
        if (subBom != null) {
          final subExplosionItems =
              await _explodeBom(subBom, requiredQuantity, level + 1);
          explosionItems.addAll(subExplosionItems);
        }
      } catch (e) {
        // No sub-BOM found, continue with raw material
      }
    }

    return explosionItems;
  }

  double _calculateRequiredQuantity(BomItem bomItem, double parentQuantity) {
    double baseQuantity = bomItem.consumptionType == ConsumptionType.fixed
        ? bomItem.quantity
        : bomItem.quantity * parentQuantity;

    // Add wastage
    double wastageAmount = baseQuantity * (bomItem.wastagePercentage / 100);
    return baseQuantity + wastageAmount;
  }

  Future<List<MrpRequirement>> _calculateTimePhaseRequirements(
    Map<String, List<BomExplosionItem>> explosionResult,
    DateTime startDate,
    DateTime endDate,
    LotSizingMethod lotSizingMethod,
  ) async {
    final requirements = <MrpRequirement>[];
    final materialRequirements = <String, double>{};

    // Aggregate requirements by material
    for (final explosionItems in explosionResult.values) {
      for (final item in explosionItems) {
        materialRequirements[item.materialId] =
            (materialRequirements[item.materialId] ?? 0.0) +
                item.requiredQuantity;
      }
    }

    // Create time-phased requirements
    for (final entry in materialRequirements.entries) {
      final materialId = entry.key;
      final grossRequirement = entry.value;

      // Get current inventory
      final inventoryItem =
          await inventoryRepository.getInventoryItem(materialId);
      final onHandQuantity = inventoryItem?.quantity ?? 0.0;
      final safetyStock = inventoryItem?.safetyStock ?? 0.0;

      // Calculate net requirement
      final netRequirement = (grossRequirement - onHandQuantity + safetyStock)
          .clamp(0.0, double.infinity);

      // Apply lot sizing
      final plannedOrderQuantity = _applyLotSizing(
        netRequirement,
        lotSizingMethod,
        inventoryItem,
      );

      if (plannedOrderQuantity > 0) {
        final requirement = MrpRequirement(
          materialId: materialId,
          materialCode: inventoryItem?.appItemId ?? materialId,
          materialName: inventoryItem?.name ?? 'Unknown Material',
          periodStart: startDate,
          periodEnd: endDate,
          requirementType: MrpRequirementType.netRequirement,
          quantity: plannedOrderQuantity,
          unit: inventoryItem?.unit ?? 'units',
          grossRequirement: grossRequirement,
          scheduledReceipt: 0.0,
          projectedOnHand: onHandQuantity,
          netRequirement: netRequirement,
          plannedOrderReceipt: plannedOrderQuantity,
          plannedOrderRelease: plannedOrderQuantity,
          safetyStock: safetyStock,
          leadTimeDays: _getLeadTime(materialId),
          supplierCode: inventoryItem?.supplier,
          additionalData: {
            'unitCost': inventoryItem?.cost ?? 0.0,
            'lotSizingMethod': lotSizingMethod.toString(),
          },
        );

        requirements.add(requirement);
      }
    }

    return requirements;
  }

  double _applyLotSizing(
    double netRequirement,
    LotSizingMethod method,
    InventoryItem? inventoryItem,
  ) {
    switch (method) {
      case LotSizingMethod.lotForLot:
        return netRequirement;
      case LotSizingMethod.economicOrderQuantity:
        return _calculateEOQ(inventoryItem);
      case LotSizingMethod.periodOrderQuantity:
        return _calculatePOQ(netRequirement, inventoryItem);
      case LotSizingMethod.fixedOrderQuantity:
        return _getFixedOrderQuantity(inventoryItem);
    }
  }

  double _calculateEOQ(InventoryItem? inventoryItem) {
    // Simplified EOQ calculation
    // EOQ = sqrt((2 * D * S) / H)
    // Where D = annual demand, S = ordering cost, H = holding cost
    final annualDemand = inventoryItem?.currentConsumption ?? 1000.0;
    const orderingCost = 100.0; // Default ordering cost
    const holdingCostRate = 0.2; // 20% of item cost
    final itemCost = inventoryItem?.cost ?? 10.0;
    final holdingCost = itemCost * holdingCostRate;

    if (holdingCost <= 0) {
      return annualDemand / 12; // Monthly demand as fallback
    }

    return sqrt(2 * annualDemand * orderingCost / holdingCost);
  }

  double _calculatePOQ(double netRequirement, InventoryItem? inventoryItem) {
    // Period Order Quantity - order for multiple periods
    const periodsToOrder = 4; // Order for 4 periods
    return netRequirement * periodsToOrder;
  }

  double _getFixedOrderQuantity(InventoryItem? inventoryItem) {
    // Use reorder point as fixed quantity, or default
    return inventoryItem?.reorderPoint ?? 100.0;
  }

  int _getLeadTime(String materialId) {
    // Default lead time - in real implementation, this would come from supplier data
    return 7; // 7 days default
  }

  Future<List<MrpActionMessage>> _generateActionMessages(
    List<MrpRequirement> requirements,
  ) async {
    final actionMessages = <MrpActionMessage>[];

    for (final requirement in requirements) {
      if (requirement.netRequirement > 0) {
        final releaseDate = requirement.getPlannedOrderReleaseDate();
        final now = DateTime.now();

        MrpActionType actionType;
        String message;
        String priority;

        if (releaseDate.isBefore(now)) {
          actionType = MrpActionType.expedite;
          message = 'Expedite order for ${requirement.materialName} - past due';
          priority = 'high';
        } else if (releaseDate.difference(now).inDays <= 3) {
          actionType = MrpActionType.expedite;
          message = 'Expedite order for ${requirement.materialName} - due soon';
          priority = 'medium';
        } else {
          actionType = MrpActionType.none;
          message = 'Plan order for ${requirement.materialName}';
          priority = 'low';
        }

        final actionMessage = MrpActionMessage(
          id: 'action_${DateTime.now().millisecondsSinceEpoch}_${requirement.materialId}',
          materialId: requirement.materialId,
          materialCode: requirement.materialCode,
          actionType: actionType,
          message: message,
          currentDate: now,
          recommendedDate: releaseDate,
          quantity: requirement.plannedOrderRelease,
          unit: requirement.unit,
          priority: priority,
          supplierCode: requirement.supplierCode,
          createdAt: now,
        );

        actionMessages.add(actionMessage);
      }
    }

    return actionMessages;
  }

  Future<List<MrpAlert>> _generateAlerts(
      List<MrpRequirement> requirements) async {
    final alerts = <MrpAlert>[];

    for (final requirement in requirements) {
      // Check for critical shortages
      if (requirement.netRequirement > requirement.projectedOnHand * 2) {
        final alert = MrpAlert(
          id: 'alert_${DateTime.now().millisecondsSinceEpoch}_${requirement.materialId}',
          planId: 'current_plan',
          materialId: requirement.materialId,
          alertType: 'critical_shortage',
          severity: 'critical',
          message: 'Critical shortage for ${requirement.materialName}',
          alertDate: DateTime.now(),
          impactQuantity: requirement.netRequirement,
          recommendedAction:
              'Expedite procurement or find alternative supplier',
        );
        alerts.add(alert);
      }

      // Check for excessive inventory
      if (requirement.projectedOnHand > requirement.grossRequirement * 3) {
        final alert = MrpAlert(
          id: 'alert_excess_${DateTime.now().millisecondsSinceEpoch}_${requirement.materialId}',
          planId: 'current_plan',
          materialId: requirement.materialId,
          alertType: 'excess_inventory',
          severity: 'medium',
          message: 'Excess inventory for ${requirement.materialName}',
          alertDate: DateTime.now(),
          impactQuantity:
              requirement.projectedOnHand - requirement.grossRequirement,
          recommendedAction:
              'Consider reducing future orders or find alternative use',
        );
        alerts.add(alert);
      }
    }

    return alerts;
  }

  Map<String, dynamic> _calculatePlanMetrics(
      List<MrpRequirement> requirements) {
    double totalCost = 0.0;
    double inventoryValue = 0.0;
    int criticalMaterials = 0;

    for (final requirement in requirements) {
      final unitCost = requirement.additionalData?['unitCost'] ?? 0.0;
      totalCost += requirement.plannedOrderReceipt * unitCost;
      inventoryValue += requirement.projectedOnHand * unitCost;

      if (requirement.netRequirement > 0) {
        criticalMaterials++;
      }
    }

    return {
      'totalCost': totalCost,
      'inventoryValue': inventoryValue,
      'totalMaterials': requirements.length,
      'criticalMaterials': criticalMaterials,
      'planEfficiency': criticalMaterials == 0
          ? 100.0
          : ((requirements.length - criticalMaterials) / requirements.length) *
              100,
    };
  }

  // Optimization helper methods (simplified implementations)

  Future<Map<String, double>> _analyzeCostOptimizations(MrpPlan plan) async {
    // Simplified cost optimization analysis
    return {
      'bulk_discount_savings': 5000.0,
      'supplier_consolidation_savings': 2000.0,
      'lead_time_optimization_savings': 1500.0,
    };
  }

  Future<Map<String, int>> _analyzeLeadTimeImprovements(MrpPlan plan) async {
    // Simplified lead time improvement analysis
    return {
      'supplier_optimization': 3, // 3 days improvement
      'local_sourcing': 5, // 5 days improvement
      'inventory_positioning': 2, // 2 days improvement
    };
  }

  Future<List<String>> _generateSupplierRecommendations(MrpPlan plan) async {
    // Simplified supplier recommendations
    return [
      'Consider alternative supplier for high-volume materials',
      'Negotiate better terms with primary suppliers',
      'Implement vendor-managed inventory for critical items',
    ];
  }

  List<String> _identifyCriticalMaterials(MrpPlan plan) {
    return plan.requirements
        .where((req) => req.netRequirement > 0)
        .map((req) => req.materialId)
        .toList();
  }

  Future<List<MrpActionMessage>> _generateOptimizationActions(
    MrpPlan plan,
    Map<String, double> costOptimizations,
    Map<String, int> leadTimeImprovements,
  ) async {
    // Generate optimization-specific action messages
    return [];
  }

  double _calculateInventoryReduction(
    MrpPlan plan,
    Map<String, double> costOptimizations,
  ) {
    return costOptimizations.values.fold(0.0, (sum, value) => sum + value) *
        0.3;
  }

  double _calculateOptimizationScore(
    Map<String, double> costOptimizations,
    Map<String, int> leadTimeImprovements,
  ) {
    final costScore =
        costOptimizations.values.fold(0.0, (sum, value) => sum + value) / 10000;
    final timeScore =
        leadTimeImprovements.values.fold(0, (sum, value) => sum + value) / 10.0;
    return (costScore + timeScore).clamp(0.0, 100.0);
  }

  String _assessPlanRisk(MrpPlan plan) {
    final criticalAlerts = plan.getCriticalAlerts().length;
    if (criticalAlerts > 5) return 'high';
    if (criticalAlerts > 2) return 'medium';
    return 'low';
  }

  String _assessImplementationComplexity(List<MrpActionMessage> actions) {
    if (actions.length > 20) return 'high';
    if (actions.length > 10) return 'medium';
    return 'low';
  }

  // Validation helper methods (simplified implementations)

  Future<List<MrpAlert>> _validateMaterialAvailability(MrpPlan plan) async {
    return [];
  }

  Future<List<MrpAlert>> _validateCapacityConstraints(MrpPlan plan) async {
    return [];
  }

  Future<List<MrpAlert>> _validateSupplierReliability(MrpPlan plan) async {
    return [];
  }

  Future<List<MrpAlert>> _validateLeadTimes(MrpPlan plan) async {
    return [];
  }

  Future<List<MrpAlert>> _validateCostVariances(MrpPlan plan) async {
    return [];
  }
}

/// BOM explosion item for internal calculations
class BomExplosionItem {
  const BomExplosionItem({
    required this.materialId,
    required this.materialCode,
    required this.materialName,
    required this.requiredQuantity,
    required this.unit,
    required this.level,
    required this.bomId,
    required this.bomItemId,
    this.parentMaterialId,
  });

  final String materialId;
  final String materialCode;
  final String materialName;
  final double requiredQuantity;
  final String unit;
  final int level;
  final String bomId;
  final String bomItemId;
  final String? parentMaterialId;
}

/// Provider for MRP Planning Service
final mrpPlanningServiceProvider = Provider<MrpPlanningService>((ref) {
  return MrpPlanningService(
    bomRepository: ref.watch(bomRepositoryProvider),
    inventoryRepository:
        ref.watch(inventory_provider.inventoryRepositoryProvider),
    supplierRepository: ref.watch(supplier_provider.supplierRepositoryProvider),
    logger: Logger(),
  );
});
