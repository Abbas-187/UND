import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../data/repositories/inventory_movement_repository.dart';
import '../data/repositories/inventory_movement_repository_impl.dart';
import '../data/models/inventory_movement_model.dart';
import '../data/models/inventory_movement_type.dart';

/// Provider for the Logger instance
final loggerProvider = Provider<Logger>((ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
});

/// Provider for the Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for the inventory movement repository
final inventoryMovementRepositoryProvider =
    Provider<InventoryMovementRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final logger = ref.watch(loggerProvider);

  return InventoryMovementRepositoryImpl(
    firestore: firestore,
    logger: logger,
  );
});

/// Provider for a specific inventory movement by ID
final inventoryMovementProvider =
    FutureProvider.family<InventoryMovementModel, String>(
  (ref, id) async {
    final repository = ref.watch(inventoryMovementRepositoryProvider);
    return repository.getMovementById(id);
  },
);

/// Provider for all movements of a specific type
final movementsByTypeProvider =
    FutureProvider.family<List<InventoryMovementModel>, InventoryMovementType>(
  (ref, type) async {
    final repository = ref.watch(inventoryMovementRepositoryProvider);
    return repository.getMovementsByType(type);
  },
);

/// Provider for movements in a date range
final movementsByDateRangeProvider = FutureProvider.family<
    List<InventoryMovementModel>, ({DateTime start, DateTime end})>(
  (ref, dateRange) async {
    final repository = ref.watch(inventoryMovementRepositoryProvider);
    return repository.getMovementsByTimeRange(dateRange.start, dateRange.end);
  },
);

/// Provider for movements by location
final movementsByLocationProvider = FutureProvider.family<
    List<InventoryMovementModel>, ({String locationId, bool isSource})>(
  (ref, params) async {
    final repository = ref.watch(inventoryMovementRepositoryProvider);
    return repository.getMovementsByLocation(
        params.locationId, params.isSource);
  },
);

/// Provider for movements by product
final movementsByProductProvider =
    FutureProvider.family<List<InventoryMovementModel>, String>(
  (ref, productId) async {
    final repository = ref.watch(inventoryMovementRepositoryProvider);
    return repository.getMovementsByProduct(productId);
  },
);
