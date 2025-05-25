import 'bom_inventory_integration_usecase.dart';
import 'bom_procurement_integration_usecase.dart';
import '../../../procurement/domain/entities/purchase_order.dart';
import '../../../procurement/domain/services/supplier_quote_service.dart';
import '../../../inventory/domain/entities/inventory_alert.dart';
import '../../../inventory/domain/entities/reservation.dart';

class BomOrchestrationUseCase {
  final BomInventoryIntegrationUseCase _inventoryIntegration;
  final BomProcurementIntegrationUseCase _procurementIntegration;

  BomOrchestrationUseCase({
    required BomInventoryIntegrationUseCase inventoryIntegration,
    required BomProcurementIntegrationUseCase procurementIntegration,
  })  : _inventoryIntegration = inventoryIntegration,
        _procurementIntegration = procurementIntegration;

  // Complete BOM production readiness assessment
  Future<BomProductionReadiness> assessProductionReadiness(
    String bomId,
    double batchSize,
    DateTime plannedStartDate, {
    bool includeReservations = true,
    bool includeProcurementAnalysis = true,
    bool optimizeScheduling = true,
  }) async {
    try {
      // Check inventory availability
      final availabilityResult =
          await _inventoryIntegration.checkBomAvailability(
        bomId,
        batchSize,
        includeReservations: includeReservations,
      );

      // Analyze procurement needs if requested
      BomProcurementAnalysis? procurementAnalysis;
      if (includeProcurementAnalysis) {
        procurementAnalysis =
            await _procurementIntegration.analyzeBomProcurement(
          bomId,
          batchSize,
        );
      }

      // Generate procurement schedule if needed
      BomProcurementSchedule? procurementSchedule;
      if (optimizeScheduling &&
          availabilityResult.status != BomAvailabilityStatus.fullyAvailable) {
        procurementSchedule =
            await _procurementIntegration.optimizeProcurementTiming(
          bomId,
          batchSize,
          plannedStartDate,
        );
      }

      // Determine overall readiness status
      final readinessStatus = _determineReadinessStatus(
        availabilityResult,
        procurementAnalysis,
        procurementSchedule,
        plannedStartDate,
      );

      // Generate comprehensive recommendations
      final recommendations = _generateReadinessRecommendations(
        availabilityResult,
        procurementAnalysis,
        procurementSchedule,
        readinessStatus,
      );

      return BomProductionReadiness(
        bomId: bomId,
        batchSize: batchSize,
        plannedStartDate: plannedStartDate,
        readinessStatus: readinessStatus,
        availabilityResult: availabilityResult,
        procurementAnalysis: procurementAnalysis,
        procurementSchedule: procurementSchedule,
        recommendations: recommendations,
        assessedAt: DateTime.now(),
      );
    } catch (e) {
      throw BomOrchestrationException(
          'Failed to assess production readiness: $e');
    }
  }

  // Execute complete BOM preparation workflow
  Future<BomPreparationResult> prepareBomForProduction(
    String bomId,
    String productionOrderId,
    double batchSize,
    DateTime requiredDate,
    String requestedBy, {
    bool autoCreatePurchaseOrders = false,
    bool reserveMaterials = true,
    Map<String, String>? supplierPreferences,
    int reservationPriority = 5,
  }) async {
    try {
      final steps = <PreparationStep>[];
      final errors = <String>[];

      // Step 1: Check availability
      steps.add(PreparationStep(
        step: 'availability_check',
        status: PreparationStepStatus.inProgress,
        startedAt: DateTime.now(),
      ));

      final availabilityResult =
          await _inventoryIntegration.checkBomAvailability(
        bomId,
        batchSize,
      );

      steps.last = steps.last.copyWith(
        status: PreparationStepStatus.completed,
        completedAt: DateTime.now(),
        result:
            'Availability: ${availabilityResult.availabilityPercentage.toStringAsFixed(1)}%',
      );

      // Step 2: Reserve available materials if requested
      BomReservationResult? reservationResult;
      if (reserveMaterials) {
        steps.add(PreparationStep(
          step: 'material_reservation',
          status: PreparationStepStatus.inProgress,
          startedAt: DateTime.now(),
        ));

        try {
          reservationResult =
              await _inventoryIntegration.reserveMaterialsForBom(
            bomId,
            productionOrderId,
            batchSize,
            requiredDate,
            requestedBy,
            priority: reservationPriority,
          );

          steps.last = steps.last.copyWith(
            status: reservationResult.isFullyReserved
                ? PreparationStepStatus.completed
                : PreparationStepStatus.partiallyCompleted,
            completedAt: DateTime.now(),
            result: reservationResult.isFullyReserved
                ? 'All materials reserved successfully'
                : 'Partial reservation: ${reservationResult.failures.length} items failed',
          );
        } catch (e) {
          steps.last = steps.last.copyWith(
            status: PreparationStepStatus.failed,
            completedAt: DateTime.now(),
            error: e.toString(),
          );
          errors.add('Material reservation failed: $e');
        }
      }

      // Step 3: Create purchase orders for shortages if requested
      BomPurchaseOrderResult? purchaseOrderResult;
      if (autoCreatePurchaseOrders &&
          availabilityResult.status != BomAvailabilityStatus.fullyAvailable) {
        steps.add(PreparationStep(
          step: 'purchase_order_creation',
          status: PreparationStepStatus.inProgress,
          startedAt: DateTime.now(),
        ));

        try {
          purchaseOrderResult =
              await _procurementIntegration.createPurchaseOrdersFromBom(
            bomId,
            batchSize,
            requestedBy,
            supplierPreferences: supplierPreferences,
          );

          steps.last = steps.last.copyWith(
            status: PreparationStepStatus.completed,
            completedAt: DateTime.now(),
            result:
                '${purchaseOrderResult.purchaseOrders.length} purchase orders created',
          );
        } catch (e) {
          steps.last = steps.last.copyWith(
            status: PreparationStepStatus.failed,
            completedAt: DateTime.now(),
            error: e.toString(),
          );
          errors.add('Purchase order creation failed: $e');
        }
      }

      // Determine overall preparation status
      final overallStatus = _determinePreparationStatus(steps, errors);

      // Generate next steps recommendations
      final nextSteps = _generateNextSteps(
        availabilityResult,
        reservationResult,
        purchaseOrderResult,
        overallStatus,
      );

      return BomPreparationResult(
        bomId: bomId,
        productionOrderId: productionOrderId,
        batchSize: batchSize,
        overallStatus: overallStatus,
        steps: steps,
        availabilityResult: availabilityResult,
        reservationResult: reservationResult,
        purchaseOrderResult: purchaseOrderResult,
        errors: errors,
        nextSteps: nextSteps,
        preparedAt: DateTime.now(),
        preparedBy: requestedBy,
      );
    } catch (e) {
      throw BomOrchestrationException(
          'Failed to prepare BOM for production: $e');
    }
  }

  // Monitor BOM status across all integrated systems
  Future<BomStatusDashboard> getBomStatusDashboard(
    String bomId, {
    bool includeReservations = true,
    bool includeProcurementStatus = true,
    bool includeAlerts = true,
  }) async {
    try {
      // Get inventory status
      final inventoryStatus =
          await _inventoryIntegration.getBomInventoryStatus(bomId);

      // Get active alerts if requested
      List<InventoryAlert> activeAlerts = [];
      if (includeAlerts) {
        // This would need to be implemented with actual alert service
        // For now, showing the structure
      }

      // Get procurement status if requested
      BomProcurementSummary? procurementSummary;
      if (includeProcurementStatus) {
        procurementSummary = await _getProcurementSummary(bomId);
      }

      // Calculate key metrics
      final metrics = _calculateBomMetrics(
        inventoryStatus,
        activeAlerts,
        procurementSummary,
      );

      return BomStatusDashboard(
        bomId: bomId,
        inventoryStatus: inventoryStatus,
        activeAlerts: activeAlerts,
        procurementSummary: procurementSummary,
        metrics: metrics,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw BomOrchestrationException('Failed to get BOM status dashboard: $e');
    }
  }

  // Optimize BOM for cost and availability
  Future<BomOptimizationResult> optimizeBom(
    String bomId,
    double batchSize, {
    OptimizationObjective objective = OptimizationObjective.balanced,
    bool considerAlternatives = true,
    bool optimizeSuppliers = true,
    bool optimizeQuantities = true,
  }) async {
    try {
      final optimizations = <BomOptimization>[];

      // Analyze current state
      final availabilityResult =
          await _inventoryIntegration.checkBomAvailability(bomId, batchSize);
      final procurementAnalysis =
          await _procurementIntegration.analyzeBomProcurement(bomId, batchSize);

      // Supplier optimization
      if (optimizeSuppliers) {
        final supplierOptimization =
            await _optimizeSuppliers(bomId, procurementAnalysis, objective);
        optimizations.add(supplierOptimization);
      }

      // Quantity optimization
      if (optimizeQuantities) {
        final quantityOptimization =
            await _optimizeQuantities(bomId, batchSize, procurementAnalysis);
        optimizations.add(quantityOptimization);
      }

      // Alternative materials optimization
      if (considerAlternatives) {
        final alternativeOptimization =
            await _optimizeAlternatives(bomId, availabilityResult);
        optimizations.add(alternativeOptimization);
      }

      // Calculate potential savings
      final potentialSavings =
          _calculatePotentialSavings(optimizations, procurementAnalysis);

      return BomOptimizationResult(
        bomId: bomId,
        batchSize: batchSize,
        objective: objective,
        optimizations: optimizations,
        potentialSavings: potentialSavings,
        implementationComplexity:
            _assessImplementationComplexity(optimizations),
        optimizedAt: DateTime.now(),
      );
    } catch (e) {
      throw BomOrchestrationException('Failed to optimize BOM: $e');
    }
  }

  // Private helper methods
  ProductionReadinessStatus _determineReadinessStatus(
    BomAvailabilityResult availabilityResult,
    BomProcurementAnalysis? procurementAnalysis,
    BomProcurementSchedule? procurementSchedule,
    DateTime plannedStartDate,
  ) {
    if (availabilityResult.status == BomAvailabilityStatus.fullyAvailable) {
      return ProductionReadinessStatus.ready;
    }

    if (procurementSchedule != null) {
      final canMeetDeadline = procurementSchedule.scheduleItems.every(
          (item) => item.expectedDeliveryDate.isBefore(plannedStartDate));

      if (canMeetDeadline) {
        return ProductionReadinessStatus.readyWithProcurement;
      } else {
        return ProductionReadinessStatus.delayRequired;
      }
    }

    if (availabilityResult.status == BomAvailabilityStatus.criticalShortage) {
      return ProductionReadinessStatus.notReady;
    }

    return ProductionReadinessStatus.partiallyReady;
  }

  List<String> _generateReadinessRecommendations(
    BomAvailabilityResult availabilityResult,
    BomProcurementAnalysis? procurementAnalysis,
    BomProcurementSchedule? procurementSchedule,
    ProductionReadinessStatus readinessStatus,
  ) {
    final recommendations = <String>[];

    switch (readinessStatus) {
      case ProductionReadinessStatus.ready:
        recommendations
            .add('All materials available - proceed with production');
        break;
      case ProductionReadinessStatus.readyWithProcurement:
        recommendations
            .add('Execute procurement plan to meet production schedule');
        break;
      case ProductionReadinessStatus.partiallyReady:
        recommendations
            .add('Consider partial production or alternative materials');
        break;
      case ProductionReadinessStatus.delayRequired:
        recommendations
            .add('Delay production start date or expedite procurement');
        break;
      case ProductionReadinessStatus.notReady:
        recommendations
            .add('Critical shortages detected - review BOM and suppliers');
        break;
    }

    // Add specific recommendations from sub-analyses
    recommendations.addAll(availabilityResult.recommendations);

    if (procurementAnalysis != null) {
      recommendations.addAll(procurementAnalysis.insights);
    }

    return recommendations.toSet().toList(); // Remove duplicates
  }

  PreparationStatus _determinePreparationStatus(
    List<PreparationStep> steps,
    List<String> errors,
  ) {
    if (errors.isNotEmpty) {
      return PreparationStatus.failed;
    }

    final completedSteps =
        steps.where((s) => s.status == PreparationStepStatus.completed).length;
    final totalSteps = steps.length;

    if (completedSteps == totalSteps) {
      return PreparationStatus.completed;
    } else if (completedSteps > 0) {
      return PreparationStatus.partiallyCompleted;
    } else {
      return PreparationStatus.failed;
    }
  }

  List<String> _generateNextSteps(
    BomAvailabilityResult availabilityResult,
    BomReservationResult? reservationResult,
    BomPurchaseOrderResult? purchaseOrderResult,
    PreparationStatus overallStatus,
  ) {
    final nextSteps = <String>[];

    if (overallStatus == PreparationStatus.completed) {
      nextSteps.add('Ready to start production');
    } else {
      if (reservationResult != null && !reservationResult.isFullyReserved) {
        nextSteps.add('Resolve reservation failures before production');
      }

      if (purchaseOrderResult != null) {
        nextSteps.add('Monitor purchase order deliveries');
        nextSteps.add('Update production schedule based on delivery dates');
      }

      if (availabilityResult.status == BomAvailabilityStatus.criticalShortage) {
        nextSteps.add('Review BOM for alternative materials');
      }
    }

    return nextSteps;
  }

  BomMetrics _calculateBomMetrics(
    BomInventoryStatus inventoryStatus,
    List<InventoryAlert> activeAlerts,
    BomProcurementSummary? procurementSummary,
  ) {
    final highSeverityAlerts =
        activeAlerts.where((a) => a.severity == AlertSeverity.high).length;
    final mediumSeverityAlerts =
        activeAlerts.where((a) => a.severity == AlertSeverity.medium).length;

    return BomMetrics(
      totalItems: inventoryStatus.itemStatuses.length,
      fullyAvailableItems: inventoryStatus.itemStatuses
          .where((item) => item.availableQuantity >= item.requiredQuantity)
          .length,
      totalActiveReservations: inventoryStatus.totalActiveReservations,
      highSeverityAlerts: highSeverityAlerts,
      mediumSeverityAlerts: mediumSeverityAlerts,
      activePurchaseOrders: procurementSummary?.activePurchaseOrders ?? 0,
      pendingProcurementValue: procurementSummary?.pendingValue ?? 0.0,
    );
  }

  // Placeholder methods for optimization features
  Future<BomOptimization> _optimizeSuppliers(
    String bomId,
    BomProcurementAnalysis procurementAnalysis,
    OptimizationObjective objective,
  ) async {
    // Implementation would analyze supplier alternatives and recommend changes
    return BomOptimization(
      type: OptimizationType.supplier,
      description: 'Supplier optimization analysis',
      potentialSavings: 0.0,
      implementationEffort: ImplementationEffort.medium,
      recommendations: ['Analyze supplier alternatives'],
    );
  }

  Future<BomOptimization> _optimizeQuantities(
    String bomId,
    double batchSize,
    BomProcurementAnalysis procurementAnalysis,
  ) async {
    // Implementation would analyze EOQ and bulk discounts
    return BomOptimization(
      type: OptimizationType.quantity,
      description: 'Quantity optimization analysis',
      potentialSavings: 0.0,
      implementationEffort: ImplementationEffort.low,
      recommendations: ['Consider bulk purchasing for high-value items'],
    );
  }

  Future<BomOptimization> _optimizeAlternatives(
    String bomId,
    BomAvailabilityResult availabilityResult,
  ) async {
    // Implementation would analyze alternative materials
    return BomOptimization(
      type: OptimizationType.alternative,
      description: 'Alternative materials analysis',
      potentialSavings: 0.0,
      implementationEffort: ImplementationEffort.high,
      recommendations: ['Review alternative materials for shortage items'],
    );
  }

  double _calculatePotentialSavings(
    List<BomOptimization> optimizations,
    BomProcurementAnalysis procurementAnalysis,
  ) {
    return optimizations.fold(0.0, (sum, opt) => sum + opt.potentialSavings);
  }

  ImplementationComplexity _assessImplementationComplexity(
    List<BomOptimization> optimizations,
  ) {
    final maxEffort = optimizations
        .map((opt) => opt.implementationEffort)
        .reduce((a, b) => a.index > b.index ? a : b);

    switch (maxEffort) {
      case ImplementationEffort.low:
        return ImplementationComplexity.simple;
      case ImplementationEffort.medium:
        return ImplementationComplexity.moderate;
      case ImplementationEffort.high:
        return ImplementationComplexity.complex;
    }
  }

  Future<BomProcurementSummary> _getProcurementSummary(String bomId) async {
    // Implementation would fetch procurement status from procurement service
    return BomProcurementSummary(
      activePurchaseOrders: 0,
      pendingValue: 0.0,
      averageLeadTime: 0,
    );
  }
}

// Supporting classes and enums
class BomProductionReadiness {
  final String bomId;
  final double batchSize;
  final DateTime plannedStartDate;
  final ProductionReadinessStatus readinessStatus;
  final BomAvailabilityResult availabilityResult;
  final BomProcurementAnalysis? procurementAnalysis;
  final BomProcurementSchedule? procurementSchedule;
  final List<String> recommendations;
  final DateTime assessedAt;

  BomProductionReadiness({
    required this.bomId,
    required this.batchSize,
    required this.plannedStartDate,
    required this.readinessStatus,
    required this.availabilityResult,
    this.procurementAnalysis,
    this.procurementSchedule,
    required this.recommendations,
    required this.assessedAt,
  });
}

class BomPreparationResult {
  final String bomId;
  final String productionOrderId;
  final double batchSize;
  final PreparationStatus overallStatus;
  final List<PreparationStep> steps;
  final BomAvailabilityResult availabilityResult;
  final BomReservationResult? reservationResult;
  final BomPurchaseOrderResult? purchaseOrderResult;
  final List<String> errors;
  final List<String> nextSteps;
  final DateTime preparedAt;
  final String preparedBy;

  BomPreparationResult({
    required this.bomId,
    required this.productionOrderId,
    required this.batchSize,
    required this.overallStatus,
    required this.steps,
    required this.availabilityResult,
    this.reservationResult,
    this.purchaseOrderResult,
    required this.errors,
    required this.nextSteps,
    required this.preparedAt,
    required this.preparedBy,
  });
}

class BomStatusDashboard {
  final String bomId;
  final BomInventoryStatus inventoryStatus;
  final List<InventoryAlert> activeAlerts;
  final BomProcurementSummary? procurementSummary;
  final BomMetrics metrics;
  final DateTime lastUpdated;

  BomStatusDashboard({
    required this.bomId,
    required this.inventoryStatus,
    required this.activeAlerts,
    this.procurementSummary,
    required this.metrics,
    required this.lastUpdated,
  });
}

class BomOptimizationResult {
  final String bomId;
  final double batchSize;
  final OptimizationObjective objective;
  final List<BomOptimization> optimizations;
  final double potentialSavings;
  final ImplementationComplexity implementationComplexity;
  final DateTime optimizedAt;

  BomOptimizationResult({
    required this.bomId,
    required this.batchSize,
    required this.objective,
    required this.optimizations,
    required this.potentialSavings,
    required this.implementationComplexity,
    required this.optimizedAt,
  });
}

class PreparationStep {
  final String step;
  final PreparationStepStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? result;
  final String? error;

  PreparationStep({
    required this.step,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.result,
    this.error,
  });

  PreparationStep copyWith({
    String? step,
    PreparationStepStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    String? result,
    String? error,
  }) {
    return PreparationStep(
      step: step ?? this.step,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }
}

class BomMetrics {
  final int totalItems;
  final int fullyAvailableItems;
  final int totalActiveReservations;
  final int highSeverityAlerts;
  final int mediumSeverityAlerts;
  final int activePurchaseOrders;
  final double pendingProcurementValue;

  BomMetrics({
    required this.totalItems,
    required this.fullyAvailableItems,
    required this.totalActiveReservations,
    required this.highSeverityAlerts,
    required this.mediumSeverityAlerts,
    required this.activePurchaseOrders,
    required this.pendingProcurementValue,
  });
}

class BomProcurementSummary {
  final int activePurchaseOrders;
  final double pendingValue;
  final int averageLeadTime;

  BomProcurementSummary({
    required this.activePurchaseOrders,
    required this.pendingValue,
    required this.averageLeadTime,
  });
}

class BomOptimization {
  final OptimizationType type;
  final String description;
  final double potentialSavings;
  final ImplementationEffort implementationEffort;
  final List<String> recommendations;

  BomOptimization({
    required this.type,
    required this.description,
    required this.potentialSavings,
    required this.implementationEffort,
    required this.recommendations,
  });
}

enum ProductionReadinessStatus {
  ready,
  readyWithProcurement,
  partiallyReady,
  delayRequired,
  notReady,
}

enum PreparationStatus {
  completed,
  partiallyCompleted,
  failed,
}

enum PreparationStepStatus {
  inProgress,
  completed,
  partiallyCompleted,
  failed,
}

enum OptimizationObjective {
  cost,
  availability,
  leadTime,
  balanced,
}

enum OptimizationType {
  supplier,
  quantity,
  alternative,
  timing,
}

enum ImplementationEffort {
  low,
  medium,
  high,
}

enum ImplementationComplexity {
  simple,
  moderate,
  complex,
}

class BomOrchestrationException implements Exception {
  final String message;
  BomOrchestrationException(this.message);

  @override
  String toString() => 'BomOrchestrationException: $message';
}
