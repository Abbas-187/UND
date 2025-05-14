import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/app_providers.dart';
import '../../../../providers/firebase_providers.dart';
import '../models/inventory_movement_model.dart';
import 'inventory_movement_repository_impl.dart';

/// Repository interface for inventory movements
abstract class InventoryMovementRepository {
  Future<InventoryMovementModel> createMovement(
      InventoryMovementModel movement);
  Future<InventoryMovementModel> getMovementById(String id);
  Future<List<InventoryMovementModel>> getAllMovements();
  Future<List<InventoryMovementModel>> getMovementsByType(
      InventoryMovementType type);
  Future<List<InventoryMovementModel>> getMovementsByTimeRange(
      DateTime start, DateTime end);
  Future<List<InventoryMovementModel>> getMovementsByLocation(
      String locationId, bool isSource);
  Future<List<InventoryMovementModel>> getMovementsByProduct(String productId);
}

// Provider definition for dependency injection
final inventoryMovementRepositoryProvider =
    Provider<InventoryMovementRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final logger = ref.watch(loggerProvider);
  return InventoryMovementRepositoryImpl(
    firestore: firestore,
    logger: logger,
  );
});
