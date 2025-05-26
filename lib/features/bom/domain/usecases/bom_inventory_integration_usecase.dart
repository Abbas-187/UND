import '../../../inventory/domain/entities/inventory_alert.dart';
import '../../../inventory/domain/entities/reservation.dart';
import '../../../inventory/domain/services/bom_availability_service.dart';
import '../../../inventory/domain/services/reservation_service.dart';

class BomInventoryIntegrationUseCase {

  BomInventoryIntegrationUseCase({
    required BomAvailabilityService availabilityService,
    required ReservationService reservationService,
  })  : _availabilityService = availabilityService,
        _reservationService = reservationService;
  final BomAvailabilityService _availabilityService;
  final ReservationService _reservationService;

  // Check complete BOM availability with detailed analysis
  Future<BomAvailabilityResult> checkBomAvailability(
    String bomId,
    double batchSize, {
    int futureDays = 30,
    bool includeReservations = true,
  }) async {
    try {
      // Calculate overall availability percentage
      final availabilityPercentage = await _availabilityService
          .calculateAvailabilityPercentage(bomId, batchSize);

      // Generate shortage alerts
      final shortageAlerts = await _availabilityService
          .generateBomShortageAlerts(bomId, batchSize);

      // Predict future shortages
      final futureShortages = await _availabilityService.predictFutureShortages(
          bomId, batchSize, futureDays);

      // Check batch expiry impact
      final expiryAlerts = await _availabilityService.checkBatchExpiryImpact(
          bomId, batchSize, futureDays);

      // Get current reservations if requested
      List<Reservation> currentReservations = [];
      if (includeReservations) {
        currentReservations =
            await _reservationService.getActiveReservations(bomId: bomId);
      }

      // Determine overall status
      final status = _determineAvailabilityStatus(
        availabilityPercentage,
        shortageAlerts,
        futureShortages,
      );

      return BomAvailabilityResult(
        bomId: bomId,
        batchSize: batchSize,
        availabilityPercentage: availabilityPercentage,
        status: status,
        shortageAlerts: shortageAlerts,
        futureShortages: futureShortages,
        expiryAlerts: expiryAlerts,
        currentReservations: currentReservations,
        checkedAt: DateTime.now(),
        recommendations: _generateAvailabilityRecommendations(
          availabilityPercentage,
          shortageAlerts,
          futureShortages,
          expiryAlerts,
        ),
      );
    } catch (e) {
      throw BomInventoryException('Failed to check BOM availability: $e');
    }
  }

  // Reserve materials for BOM production with optimization
  Future<BomReservationResult> reserveMaterialsForBom(
    String bomId,
    String productionOrderId,
    double batchSize,
    DateTime requiredDate,
    String requestedBy, {
    Map<String, String>? itemPreferences,
    int priority = 5,
    bool optimizeAllocation = true,
  }) async {
    try {
      // Create reservation request
      final request = ReservationRequest(
        bomId: bomId,
        productionOrderId: productionOrderId,
        batchSize: batchSize,
        requiredDate: requiredDate,
        requestedBy: requestedBy,
        itemPreferences: itemPreferences,
        priority: priority,
        notes: 'BOM production reservation - Batch size: $batchSize',
      );

      // Attempt reservation
      final reservationResult =
          await _reservationService.createReservation(request);

      // If not fully reserved and optimization requested, try alternatives
      if (!reservationResult.isFullyReserved && optimizeAllocation) {
        final optimizedResult = await _tryOptimizedReservation(
          request,
          reservationResult,
        );
        if (optimizedResult != null) {
          return optimizedResult;
        }
      }

      // Generate recommendations for failures
      final recommendations = await _generateReservationRecommendations(
        reservationResult.failures,
      );

      return BomReservationResult(
        bomId: bomId,
        productionOrderId: productionOrderId,
        batchSize: batchSize,
        isFullyReserved: reservationResult.isFullyReserved,
        reservations: reservationResult.reservations,
        failures: reservationResult.failures,
        recommendations: recommendations,
        processedAt: reservationResult.processedAt,
      );
    } catch (e) {
      throw BomInventoryException('Failed to reserve materials: $e');
    }
  }

  // Release all reservations for a BOM/production order
  Future<void> releaseBomReservations(
    String bomId,
    String productionOrderId,
  ) async {
    try {
      final reservations = await _reservationService.getActiveReservations(
        bomId: bomId,
        productionOrderId: productionOrderId,
      );

      for (final reservation in reservations) {
        await _reservationService.releaseReservation(reservation.id);
      }
    } catch (e) {
      throw BomInventoryException('Failed to release BOM reservations: $e');
    }
  }

  // Consume materials during production
  Future<MaterialConsumptionResult> consumeBomMaterials(
    String bomId,
    String productionOrderId,
    Map<String, double> actualConsumption, // itemId -> consumed quantity
  ) async {
    try {
      final reservations = await _reservationService.getActiveReservations(
        bomId: bomId,
        productionOrderId: productionOrderId,
      );

      final consumptionResults = <MaterialConsumption>[];
      final failures = <ConsumptionFailure>[];

      for (final entry in actualConsumption.entries) {
        final itemId = entry.key;
        final consumedQuantity = entry.value;

        // Find reservation for this item
        final reservation =
            reservations.where((r) => r.itemId == itemId).firstOrNull;

        if (reservation != null) {
          try {
            await _reservationService.consumeReservation(
              reservation.id,
              consumedQuantity,
            );

            consumptionResults.add(MaterialConsumption(
              itemId: itemId,
              reservationId: reservation.id,
              reservedQuantity: reservation.reservedQuantity,
              consumedQuantity: consumedQuantity,
              consumedAt: DateTime.now(),
            ));
          } catch (e) {
            failures.add(ConsumptionFailure(
              itemId: itemId,
              reservationId: reservation.id,
              requestedQuantity: consumedQuantity,
              availableQuantity: reservation.reservedQuantity,
              reason: e.toString(),
            ));
          }
        } else {
          failures.add(ConsumptionFailure(
            itemId: itemId,
            reservationId: null,
            requestedQuantity: consumedQuantity,
            availableQuantity: 0,
            reason: 'No active reservation found for item',
          ));
        }
      }

      return MaterialConsumptionResult(
        bomId: bomId,
        productionOrderId: productionOrderId,
        consumptions: consumptionResults,
        failures: failures,
        processedAt: DateTime.now(),
      );
    } catch (e) {
      throw BomInventoryException('Failed to consume BOM materials: $e');
    }
  }

  // Get comprehensive BOM inventory status
  Future<BomInventoryStatus> getBomInventoryStatus(String bomId) async {
    try {
      final activeReservations =
          await _reservationService.getActiveReservations(bomId: bomId);

      final reservationsByItem = <String, List<Reservation>>{};
      for (final reservation in activeReservations) {
        reservationsByItem.putIfAbsent(reservation.itemId, () => []);
        reservationsByItem[reservation.itemId]!.add(reservation);
      }

      final itemStatuses = <BomItemStatus>[];

      // This would need to be implemented with actual BOM service integration
      // For now, showing the structure

      return BomInventoryStatus(
        bomId: bomId,
        itemStatuses: itemStatuses,
        totalActiveReservations: activeReservations.length,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw BomInventoryException('Failed to get BOM inventory status: $e');
    }
  }

  // Private helper methods
  BomAvailabilityStatus _determineAvailabilityStatus(
    double availabilityPercentage,
    List<InventoryAlert> shortageAlerts,
    List<InventoryAlert> futureShortages,
  ) {
    if (availabilityPercentage >= 100.0 && shortageAlerts.isEmpty) {
      return BomAvailabilityStatus.fullyAvailable;
    } else if (availabilityPercentage >= 80.0 &&
        shortageAlerts.where((a) => a.severity == AlertSeverity.high).isEmpty) {
      return BomAvailabilityStatus.mostlyAvailable;
    } else if (availabilityPercentage >= 50.0) {
      return BomAvailabilityStatus.partiallyAvailable;
    } else {
      return BomAvailabilityStatus.criticalShortage;
    }
  }

  List<String> _generateAvailabilityRecommendations(
    double availabilityPercentage,
    List<InventoryAlert> shortageAlerts,
    List<InventoryAlert> futureShortages,
    List<InventoryAlert> expiryAlerts,
  ) {
    final recommendations = <String>[];

    if (availabilityPercentage < 100.0) {
      recommendations.add('Review shortage alerts and take corrective actions');
    }

    if (futureShortages.isNotEmpty) {
      recommendations
          .add('Plan ahead for predicted shortages in the next 30 days');
    }

    if (expiryAlerts.isNotEmpty) {
      recommendations.add('Prioritize production to use expiring materials');
    }

    final highSeverityAlerts =
        shortageAlerts.where((a) => a.severity == AlertSeverity.high).length;
    if (highSeverityAlerts > 0) {
      recommendations.add(
          'Immediate action required for $highSeverityAlerts critical shortages');
    }

    if (recommendations.isEmpty) {
      recommendations.add('All materials available - ready for production');
    }

    return recommendations;
  }

  Future<BomReservationResult?> _tryOptimizedReservation(
    ReservationRequest originalRequest,
    ReservationResult failedResult,
  ) async {
    // Try with lower priority to see if conflicts can be resolved
    if (originalRequest.priority != null && originalRequest.priority! > 1) {
      final optimizedRequest = ReservationRequest(
        bomId: originalRequest.bomId,
        productionOrderId: originalRequest.productionOrderId,
        batchSize: originalRequest.batchSize,
        requiredDate: originalRequest.requiredDate,
        requestedBy: originalRequest.requestedBy,
        itemPreferences: originalRequest.itemPreferences,
        priority: originalRequest.priority! - 1,
        notes: '${originalRequest.notes} - Optimized attempt',
      );

      final optimizedResult =
          await _reservationService.createReservation(optimizedRequest);

      if (optimizedResult.isFullyReserved) {
        return BomReservationResult(
          bomId: originalRequest.bomId,
          productionOrderId: originalRequest.productionOrderId,
          batchSize: originalRequest.batchSize,
          isFullyReserved: true,
          reservations: optimizedResult.reservations,
          failures: [],
          recommendations: ['Successfully reserved with optimized priority'],
          processedAt: optimizedResult.processedAt,
        );
      }
    }

    return null;
  }

  Future<List<String>> _generateReservationRecommendations(
    List<ReservationFailure> failures,
  ) async {
    final recommendations = <String>[];

    for (final failure in failures) {
      switch (failure.failureType) {
        case FailureType.insufficientStock:
          recommendations.add('Create purchase order for ${failure.itemCode}');
          break;
        case FailureType.itemUnavailable:
          recommendations
              .add('Check alternative suppliers for ${failure.itemCode}');
          break;
        case FailureType.qualityIssue:
          recommendations.add('Review quality status of ${failure.itemCode}');
          break;
        case FailureType.expired:
          recommendations
              .add('Remove expired stock and reorder ${failure.itemCode}');
          break;
        case FailureType.systemError:
          recommendations
              .add('Contact system administrator for ${failure.itemCode}');
          break;
      }
    }

    return recommendations.toSet().toList(); // Remove duplicates
  }
}

// Supporting classes
class BomAvailabilityResult {

  BomAvailabilityResult({
    required this.bomId,
    required this.batchSize,
    required this.availabilityPercentage,
    required this.status,
    required this.shortageAlerts,
    required this.futureShortages,
    required this.expiryAlerts,
    required this.currentReservations,
    required this.checkedAt,
    required this.recommendations,
  });
  final String bomId;
  final double batchSize;
  final double availabilityPercentage;
  final BomAvailabilityStatus status;
  final List<InventoryAlert> shortageAlerts;
  final List<InventoryAlert> futureShortages;
  final List<InventoryAlert> expiryAlerts;
  final List<Reservation> currentReservations;
  final DateTime checkedAt;
  final List<String> recommendations;
}

class BomReservationResult {

  BomReservationResult({
    required this.bomId,
    required this.productionOrderId,
    required this.batchSize,
    required this.isFullyReserved,
    required this.reservations,
    required this.failures,
    required this.recommendations,
    required this.processedAt,
  });
  final String bomId;
  final String productionOrderId;
  final double batchSize;
  final bool isFullyReserved;
  final List<Reservation> reservations;
  final List<ReservationFailure> failures;
  final List<String> recommendations;
  final DateTime processedAt;
}

class MaterialConsumptionResult {

  MaterialConsumptionResult({
    required this.bomId,
    required this.productionOrderId,
    required this.consumptions,
    required this.failures,
    required this.processedAt,
  });
  final String bomId;
  final String productionOrderId;
  final List<MaterialConsumption> consumptions;
  final List<ConsumptionFailure> failures;
  final DateTime processedAt;
}

class BomInventoryStatus {

  BomInventoryStatus({
    required this.bomId,
    required this.itemStatuses,
    required this.totalActiveReservations,
    required this.lastUpdated,
  });
  final String bomId;
  final List<BomItemStatus> itemStatuses;
  final int totalActiveReservations;
  final DateTime lastUpdated;
}

class BomItemStatus {

  BomItemStatus({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.requiredQuantity,
    required this.availableQuantity,
    required this.reservedQuantity,
    required this.activeReservations,
  });
  final String itemId;
  final String itemCode;
  final String itemName;
  final double requiredQuantity;
  final double availableQuantity;
  final double reservedQuantity;
  final List<Reservation> activeReservations;
}

class MaterialConsumption {

  MaterialConsumption({
    required this.itemId,
    required this.reservationId,
    required this.reservedQuantity,
    required this.consumedQuantity,
    required this.consumedAt,
  });
  final String itemId;
  final String reservationId;
  final double reservedQuantity;
  final double consumedQuantity;
  final DateTime consumedAt;
}

class ConsumptionFailure {

  ConsumptionFailure({
    required this.itemId,
    required this.reservationId,
    required this.requestedQuantity,
    required this.availableQuantity,
    required this.reason,
  });
  final String itemId;
  final String? reservationId;
  final double requestedQuantity;
  final double availableQuantity;
  final String reason;
}

enum BomAvailabilityStatus {
  fullyAvailable,
  mostlyAvailable,
  partiallyAvailable,
  criticalShortage,
}

class BomInventoryException implements Exception {
  BomInventoryException(this.message);
  final String message;

  @override
  String toString() => 'BomInventoryException: $message';
}
