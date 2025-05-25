import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../inventory/data/models/inventory_movement_item_model.dart';
import '../../../inventory/data/models/inventory_movement_model.dart';
import '../../../inventory/data/repositories/inventory_movement_repository.dart';
import '../../domain/entities/order_entity.dart';

/// Service for integrating orders with the inventory system
class OrderInventoryIntegrationService {
  OrderInventoryIntegrationService({
    required InventoryMovementRepository inventoryRepository,
  }) : _inventoryRepository = inventoryRepository;

  final InventoryMovementRepository _inventoryRepository;

  Future<Map<String, bool>> checkInventoryAvailability(
      OrderEntity order) async {
    // For each item in the order, check if available stock >= requested quantity
    final Map<String, bool> result = {};
    for (final item in order.items) {
      final productId = item['productId'] ?? item['itemId'];
      final quantity = (item['quantity'] as num).toDouble();
      try {
        // Query inventory items collection for available quantity
        // (Assume Firestore is used, or delegate to a provider/service)
        // Here, we use the repository to get all movements for the product and sum up
        final movements =
            await _inventoryRepository.getMovementsByProduct(productId);
        double available = 0;
        for (final m in movements) {
          for (final mi in m.items) {
            if (mi.itemId == productId) {
              available += mi.quantity;
            }
          }
        }
        result[productId] = available >= quantity;
      } catch (_) {
        result[productId] = false;
      }
    }
    return result;
  }

  Future<bool> reserveInventory(OrderEntity order) async {
    // For each item, attempt to reserve the requested quantity
    // Returns true if all reservations succeed, false otherwise
    try {
      for (final item in order.items) {
        final productId = item['productId'] ?? item['itemId'];
        final quantity = (item['quantity'] as num).toDouble();
        // Create a reservation movement (type: reservationAdjustment)
        final movement = InventoryMovementModel(
          documentNumber:
              'RES-${order.id}-${DateTime.now().millisecondsSinceEpoch}',
          movementDate: DateTime.now(),
          movementType: InventoryMovementType.reservationAdjustment,
          warehouseId: item['warehouseId'] ?? '',
          items: [
            InventoryMovementItemModel(
              itemId: productId,
              itemCode: item['itemCode'] ?? '',
              itemName: item['name'] ?? '',
              uom: item['unit'] ?? '',
              quantity: -quantity, // Negative for reservation
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          initiatingEmployeeId: 'system',
        );
        await _inventoryRepository.createMovement(movement);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> releaseInventory(OrderEntity order) async {
    // For each item, attempt to release the reserved quantity
    // Returns true if all releases succeed, false otherwise
    try {
      for (final item in order.items) {
        final productId = item['productId'] ?? item['itemId'];
        final quantity = (item['quantity'] as num).toDouble();
        // Create a release movement (type: reservationAdjustment, positive quantity)
        final movement = InventoryMovementModel(
          documentNumber:
              'REL-${order.id}-${DateTime.now().millisecondsSinceEpoch}',
          movementDate: DateTime.now(),
          movementType: InventoryMovementType.reservationAdjustment,
          warehouseId: item['warehouseId'] ?? '',
          items: [
            InventoryMovementItemModel(
              itemId: productId,
              itemCode: item['itemCode'] ?? '',
              itemName: item['name'] ?? '',
              uom: item['unit'] ?? '',
              quantity: quantity, // Positive for release
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          initiatingEmployeeId: 'system',
        );
        await _inventoryRepository.createMovement(movement);
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}

final orderInventoryIntegrationProvider =
    Provider<OrderInventoryIntegrationService>((ref) {
  final repo = ref.watch(inventoryMovementRepositoryProvider);
  return OrderInventoryIntegrationService(inventoryRepository: repo);
});
