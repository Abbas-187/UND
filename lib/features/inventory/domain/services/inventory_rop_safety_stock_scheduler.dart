import 'dart:async';

import '../../data/models/inventory_movement_model.dart';
import '../../data/repositories/inventory_movement_repository.dart';
import '../repositories/inventory_repository.dart';
import '../usecases/apply_dynamic_reorder_point_usecase.dart';
import '../usecases/get_inventory_movement_history_usecase.dart';

/// Service to periodically recalculate ROP and safety stock for all inventory items
class InventoryRopSafetyStockScheduler {
  InventoryRopSafetyStockScheduler({
    required this.ref,
    required this.inventoryRepository,
    required this.applyDynamicRopUseCase,
  });

  final dynamic ref; // Accepts Ref or ProviderContainer
  final InventoryRepository inventoryRepository;
  final ApplyDynamicReorderPointUseCase applyDynamicRopUseCase;
  Timer? _timer;

  /// Call this in app startup to schedule monthly recalculation
  void start() {
    _scheduleNextRun();
  }

  void _scheduleNextRun() {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final duration = nextMonth.difference(now);
    _timer = Timer(duration, _runAndReschedule);
  }

  Future<void> _runAndReschedule() async {
    await recalculateRopSafetyStockForAllItems();
    _scheduleNextRun();
  }

  Future<void> recalculateRopSafetyStockForAllItems() async {
    final now = DateTime.now();
    final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
    final items = await inventoryRepository.getItems();
    // Get movement repository and use case
    final movementRepo = ref.read(inventoryMovementRepositoryProvider);
    final movementHistoryUseCase =
        GetInventoryMovementHistoryUseCase(movementRepo);
    for (final item in items) {
      // Fetch all outbound/consumption movements for this item in the last 3 months
      final movements = await movementHistoryUseCase.execute(
        itemId: item.id,
        startDate: threeMonthsAgo,
        endDate: now,
        movementType: InventoryMovementType.consumption,
      );
      // Aggregate daily consumption
      final Map<DateTime, double> dailyConsumption = {};
      for (final m in movements) {
        for (final line in m.items) {
          if (line.itemId == item.id) {
            final day =
                DateTime(m.timestamp.year, m.timestamp.month, m.timestamp.day);
            dailyConsumption[day] =
                (dailyConsumption[day] ?? 0) + line.quantity.abs();
          }
        }
      }
      // Fill missing days with 0 consumption
      final List<double> demandHistory = [];
      for (int i = 0; i < 90; i++) {
        final day = now.subtract(Duration(days: 89 - i));
        final key = DateTime(day.year, day.month, day.day);
        demandHistory.add(dailyConsumption[key] ?? 0);
      }
      // Use real demand history for calculation
      final leadTime = 7.0;
      final serviceLevel = 0.95;
      final orderingCost = 100.0;
      final holdingCostPercentage = 0.2;
      final unitCost = item.cost ?? 1.0;
      try {
        await applyDynamicRopUseCase.execute(
          itemId: item.id,
          warehouseId: item.location,
          leadTime: leadTime,
          serviceLevel: serviceLevel,
          orderingCost: orderingCost,
          holdingCostPercentage: holdingCostPercentage,
          unitCost: unitCost,
          demandHistoryOverride: demandHistory,
        );
      } catch (e) {
        // Log error or handle as needed
      }
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
