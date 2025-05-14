import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/inventory_movement_model.dart';
import '../../data/repositories/inventory_movement_repository.dart';

/// Movements by type
final movementsByTypeProvider =
    FutureProvider.family<List<InventoryMovementModel>, InventoryMovementType>(
        (ref, type) {
  final repo = ref.watch(inventoryMovementRepositoryProvider);
  return repo.getMovementsByType(type);
});

/// Movements by date range (record with start and end)
final movementsByDateRangeProvider = FutureProvider.family<
    List<InventoryMovementModel>,
    ({DateTime start, DateTime end})>((ref, range) {
  final repo = ref.watch(inventoryMovementRepositoryProvider);
  return repo.getMovementsByTimeRange(range.start, range.end);
});

/// Movements by location (source or destination)
final movementsByLocationProvider = FutureProvider.family<
    List<InventoryMovementModel>,
    ({String locationId, bool isSource})>((ref, args) {
  final repo = ref.watch(inventoryMovementRepositoryProvider);
  return repo.getMovementsByLocation(args.locationId, args.isSource);
});

/// Movements by product/material ID
final movementsByProductProvider =
    FutureProvider.family<List<InventoryMovementModel>, String>(
        (ref, productId) {
  final repo = ref.watch(inventoryMovementRepositoryProvider);
  return repo.getMovementsByProduct(productId);
});

/// All movements (unfiltered)
final allMovementsProvider = FutureProvider<List<InventoryMovementModel>>(
  (ref) {
    final repo = ref.watch(inventoryMovementRepositoryProvider);
    return repo.getAllMovements();
  },
);
