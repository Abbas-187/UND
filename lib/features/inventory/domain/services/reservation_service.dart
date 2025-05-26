import '../entities/reservation.dart';

class ReservationService {
  // Core reservation operations
  Future<ReservationResult> createReservation(
      ReservationRequest request) async {
    try {
      // Get BOM items and calculate requirements
      final bomItems = await _getBomItems(request.bomId);
      final requirements = _calculateRequirements(bomItems, request.batchSize);

      final reservations = <Reservation>[];
      final failures = <ReservationFailure>[];

      for (final requirement in requirements) {
        final result = await _reserveItem(
          requirement,
          request,
        );

        if (result.reservation != null) {
          reservations.add(result.reservation!);
        } else {
          failures.add(result.failure!);
        }
      }

      return ReservationResult(
        requestId: _generateRequestId(),
        isFullyReserved: failures.isEmpty,
        reservations: reservations,
        failures: failures,
        processedAt: DateTime.now(),
        notes: failures.isEmpty
            ? 'All items successfully reserved'
            : 'Partial reservation completed with ${failures.length} failures',
      );
    } catch (e) {
      throw Exception('Failed to create reservation: $e');
    }
  }

  Future<List<ReservationConflict>> detectConflicts(
    List<ReservationRequest> requests,
  ) async {
    final conflicts = <ReservationConflict>[];
    final itemRequirements = <String, List<_ItemRequirement>>{};

    // Group requirements by item
    for (final request in requests) {
      final bomItems = await _getBomItems(request.bomId);
      final requirements = _calculateRequirements(bomItems, request.batchSize);

      for (final requirement in requirements) {
        itemRequirements.putIfAbsent(requirement.itemId, () => []);
        itemRequirements[requirement.itemId]!.add(requirement);
      }
    }

    // Check for conflicts
    for (final entry in itemRequirements.entries) {
      final itemId = entry.key;
      final requirements = entry.value;

      if (requirements.length > 1) {
        final totalRequired = requirements.fold<double>(
          0,
          (sum, req) => sum + req.quantity,
        );

        final availableStock = await _getAvailableStock(itemId);

        if (totalRequired > availableStock) {
          final existingReservations = await _getActiveReservations(itemId);

          conflicts.add(ReservationConflict(
            itemId: itemId,
            itemCode: requirements.first.itemCode,
            itemName: requirements.first.itemName,
            requiredQuantity: totalRequired,
            availableQuantity: availableStock,
            conflictingReservations: existingReservations,
            conflictType: _determineConflictType(totalRequired, availableStock),
          ));
        }
      }
    }

    return conflicts;
  }

  Future<ReservationOptimization> optimizeReservations(
    List<ReservationRequest> requests,
  ) async {
    // Sort requests by priority and required date
    final sortedRequests = List<ReservationRequest>.from(requests)
      ..sort((a, b) {
        final priorityComparison = (b.priority ?? 0).compareTo(a.priority ?? 0);
        if (priorityComparison != 0) return priorityComparison;
        return a.requiredDate.compareTo(b.requiredDate);
      });

    final optimizedAllocations = <OptimizedAllocation>[];
    final unallocatedRequests = <ReservationRequest>[];
    final reservedItems = <String, double>{}; // itemId -> reserved quantity

    for (final request in sortedRequests) {
      final result = await _tryOptimizedAllocation(request, reservedItems);

      if (result.result.isFullyReserved) {
        optimizedAllocations.add(result);

        // Update reserved quantities
        for (final reservation in result.result.reservations) {
          reservedItems[reservation.itemId] =
              (reservedItems[reservation.itemId] ?? 0) +
                  reservation.reservedQuantity;
        }
      } else {
        unallocatedRequests.add(request);
      }
    }

    final optimizationScore = _calculateOptimizationScore(
      optimizedAllocations,
      unallocatedRequests,
      requests.length,
    );

    return ReservationOptimization(
      optimizedAllocations: optimizedAllocations,
      unallocatedRequests: unallocatedRequests,
      optimizationScore: optimizationScore,
      processedAt: DateTime.now(),
    );
  }

  Future<void> releaseReservation(String reservationId) async {
    final reservation = await _getReservation(reservationId);
    if (reservation == null) {
      throw Exception('Reservation not found: $reservationId');
    }

    if (reservation.status != ReservationStatus.active) {
      throw Exception(
          'Cannot release reservation with status: ${reservation.status}');
    }

    await _updateReservationStatus(
      reservationId,
      ReservationStatus.released,
      releaseDate: DateTime.now(),
    );

    // Return stock to available inventory
    await _returnStockToInventory(reservation);
  }

  Future<void> consumeReservation(
    String reservationId,
    double consumedQuantity,
  ) async {
    final reservation = await _getReservation(reservationId);
    if (reservation == null) {
      throw Exception('Reservation not found: $reservationId');
    }

    if (reservation.status != ReservationStatus.active) {
      throw Exception(
          'Cannot consume reservation with status: ${reservation.status}');
    }

    if (consumedQuantity > reservation.reservedQuantity) {
      throw Exception('Cannot consume more than reserved quantity');
    }

    if (consumedQuantity == reservation.reservedQuantity) {
      await _updateReservationStatus(
        reservationId,
        ReservationStatus.consumed,
      );
    } else {
      // Partial consumption - update quantity and create new reservation for remainder
      await _updateReservationQuantity(reservationId, consumedQuantity);
      await _updateReservationStatus(
        reservationId,
        ReservationStatus.partial,
      );
    }

    // Update inventory consumption
    await _recordInventoryConsumption(reservation, consumedQuantity);
  }

  Future<void> cleanupExpiredReservations() async {
    final expiredReservations = await _getExpiredReservations();

    for (final reservation in expiredReservations) {
      await _updateReservationStatus(
        reservation.id,
        ReservationStatus.expired,
      );

      // Return stock to available inventory
      await _returnStockToInventory(reservation);
    }
  }

  Future<List<Reservation>> getActiveReservations({
    String? bomId,
    String? productionOrderId,
    String? itemId,
  }) async {
    return await _getReservationsWithFilters(
      status: ReservationStatus.active,
      bomId: bomId,
      productionOrderId: productionOrderId,
      itemId: itemId,
    );
  }

  Future<Map<String, double>> getReservedQuantities(
      List<String> itemIds) async {
    final reservedQuantities = <String, double>{};

    for (final itemId in itemIds) {
      final reservations = await _getActiveReservations(itemId);
      final totalReserved = reservations.fold<double>(
        0,
        (sum, reservation) => sum + reservation.reservedQuantity,
      );
      reservedQuantities[itemId] = totalReserved;
    }

    return reservedQuantities;
  }

  // Private helper methods
  Future<List<_BomItem>> _getBomItems(String bomId) async {
    // Implementation would fetch BOM items from BOM service
    throw UnimplementedError('BOM service integration needed');
  }

  List<_ItemRequirement> _calculateRequirements(
    List<_BomItem> bomItems,
    double batchSize,
  ) {
    return bomItems
        .map((item) => _ItemRequirement(
              itemId: item.itemId,
              itemCode: item.itemCode,
              itemName: item.itemName,
              quantity: item.quantity * batchSize,
              unit: item.unit,
            ))
        .toList();
  }

  Future<_ReservationAttempt> _reserveItem(
    _ItemRequirement requirement,
    ReservationRequest request,
  ) async {
    final availableStock = await _getAvailableStock(requirement.itemId);

    if (availableStock < requirement.quantity) {
      return _ReservationAttempt(
        failure: ReservationFailure(
          itemId: requirement.itemId,
          itemCode: requirement.itemCode,
          requestedQuantity: requirement.quantity,
          availableQuantity: availableStock,
          reason: 'Insufficient stock available',
          failureType: FailureType.insufficientStock,
          suggestedActions: [
            'Check alternative suppliers',
            'Consider partial production',
            'Review BOM alternatives',
          ],
        ),
      );
    }

    // Select best batch/lot based on preferences
    final selectedBatch = await _selectOptimalBatch(
      requirement.itemId,
      requirement.quantity,
      request.itemPreferences?[requirement.itemId],
    );

    final reservation = Reservation(
      id: _generateReservationId(),
      bomId: request.bomId,
      productionOrderId: request.productionOrderId,
      itemId: requirement.itemId,
      itemCode: requirement.itemCode,
      itemName: requirement.itemName,
      reservedQuantity: requirement.quantity,
      unit: requirement.unit,
      status: ReservationStatus.active,
      reservationDate: DateTime.now(),
      expiryDate: _calculateExpiryDate(request.requiredDate),
      reservedBy: request.requestedBy,
      warehouseId: selectedBatch?.warehouseId,
      batchNumber: selectedBatch?.batchNumber,
      lotNumber: selectedBatch?.lotNumber,
      priority: request.priority,
      notes: request.notes,
    );

    await _saveReservation(reservation);
    await _updateInventoryReservation(requirement.itemId, requirement.quantity);

    return _ReservationAttempt(reservation: reservation);
  }

  Future<OptimizedAllocation> _tryOptimizedAllocation(
    ReservationRequest request,
    Map<String, double> reservedItems,
  ) async {
    final result = await createReservation(request);
    final allocationScore = _calculateAllocationScore(result, request);

    return OptimizedAllocation(
      request: request,
      result: result,
      allocationScore: allocationScore,
    );
  }

  double _calculateOptimizationScore(
    List<OptimizedAllocation> allocations,
    List<ReservationRequest> unallocated,
    int totalRequests,
  ) {
    if (totalRequests == 0) return 1.0;

    final successRate = allocations.length / totalRequests;
    final avgAllocationScore = allocations.isEmpty
        ? 0.0
        : allocations.fold<double>(
                0, (sum, alloc) => sum + alloc.allocationScore) /
            allocations.length;

    return (successRate * 0.7) + (avgAllocationScore * 0.3);
  }

  double _calculateAllocationScore(
    ReservationResult result,
    ReservationRequest request,
  ) {
    if (!result.isFullyReserved) return 0.0;

    double score = 1.0;

    // Bonus for preferred batches/lots
    for (final reservation in result.reservations) {
      final preferredBatch = request.itemPreferences?[reservation.itemId];
      if (preferredBatch != null &&
          (reservation.batchNumber == preferredBatch ||
              reservation.lotNumber == preferredBatch)) {
        score += 0.1;
      }
    }

    // Penalty for using multiple warehouses
    final warehouses = result.reservations
        .map((r) => r.warehouseId)
        .where((w) => w != null)
        .toSet();
    if (warehouses.length > 1) {
      score -= 0.05 * (warehouses.length - 1);
    }

    return score.clamp(0.0, 1.0);
  }

  ConflictType _determineConflictType(double required, double available) {
    if (available == 0) return ConflictType.insufficientStock;
    if (required > available * 2) return ConflictType.priorityConflict;
    return ConflictType.dateConflict;
  }

  DateTime _calculateExpiryDate(DateTime requiredDate) {
    // Default expiry is 7 days after required date
    return requiredDate.add(const Duration(days: 7));
  }

  String _generateRequestId() => 'REQ_${DateTime.now().millisecondsSinceEpoch}';
  String _generateReservationId() =>
      'RES_${DateTime.now().millisecondsSinceEpoch}';

  // Repository methods (to be implemented with actual data layer)
  Future<double> _getAvailableStock(String itemId) async {
    throw UnimplementedError('Inventory repository integration needed');
  }

  Future<List<Reservation>> _getActiveReservations(String itemId) async {
    throw UnimplementedError('Reservation repository integration needed');
  }

  Future<Reservation?> _getReservation(String reservationId) async {
    throw UnimplementedError('Reservation repository integration needed');
  }

  Future<List<Reservation>> _getExpiredReservations() async {
    throw UnimplementedError('Reservation repository integration needed');
  }

  Future<List<Reservation>> _getReservationsWithFilters({
    ReservationStatus? status,
    String? bomId,
    String? productionOrderId,
    String? itemId,
  }) async {
    throw UnimplementedError('Reservation repository integration needed');
  }

  Future<void> _saveReservation(Reservation reservation) async {
    throw UnimplementedError('Reservation repository integration needed');
  }

  Future<void> _updateReservationStatus(
    String reservationId,
    ReservationStatus status, {
    DateTime? releaseDate,
  }) async {
    throw UnimplementedError('Reservation repository integration needed');
  }

  Future<void> _updateReservationQuantity(
    String reservationId,
    double newQuantity,
  ) async {
    throw UnimplementedError('Reservation repository integration needed');
  }

  Future<void> _updateInventoryReservation(
      String itemId, double quantity) async {
    throw UnimplementedError('Inventory repository integration needed');
  }

  Future<void> _returnStockToInventory(Reservation reservation) async {
    throw UnimplementedError('Inventory repository integration needed');
  }

  Future<void> _recordInventoryConsumption(
    Reservation reservation,
    double consumedQuantity,
  ) async {
    throw UnimplementedError('Inventory repository integration needed');
  }

  Future<_BatchSelection?> _selectOptimalBatch(
    String itemId,
    double quantity,
    String? preferredBatch,
  ) async {
    throw UnimplementedError('Batch selection logic needed');
  }
}

// Helper classes
class _ItemRequirement {
  _ItemRequirement({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.quantity,
    required this.unit,
  });
  final String itemId;
  final String itemCode;
  final String itemName;
  final double quantity;
  final String unit;
}

class _BomItem {
  _BomItem({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.quantity,
    required this.unit,
  });
  final String itemId;
  final String itemCode;
  final String itemName;
  final double quantity;
  final String unit;
}

class _ReservationAttempt {
  _ReservationAttempt({this.reservation, this.failure});
  final Reservation? reservation;
  final ReservationFailure? failure;
}

class _BatchSelection {
  _BatchSelection({
    this.warehouseId,
    this.batchNumber,
    this.lotNumber,
  });

  final String? warehouseId;
  final String? batchNumber;
  final String? lotNumber;
}
