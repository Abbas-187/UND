import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../factory/data/models/production_order_model.dart';
import '../../../factory/domain/providers/production_provider.dart';
import '../../../logistics/domain/providers/delivery_provider.dart';
import '../../../sales/data/models/order_model.dart';
import '../../../sales/domain/providers/order_provider.dart';
import '../../data/repositories/inventory_repository.dart';
import '../../domain/providers/inventory_provider.dart';
import '../entities/inventory_item.dart';

/// Service that handles integration between Inventory and other modules
class ModuleIntegrationService {

  ModuleIntegrationService(this._ref, this._repository);
  final Ref _ref;
  final InventoryRepository _repository;

  /// Updates inventory based on production completion
  Future<void> handleProductionCompletion(String productionOrderId) async {
    final order =
        await _ref.read(productionOrderByIdProvider(productionOrderId).future);

    // Decrease raw material inventory
    for (final material
        in order.requiredMaterials ?? <ProductionOrderRequiredMaterial>[]) {
      await _adjustInventoryQuantity(
        material.materialId,
        -material.requiredQuantity,
        'Production consumption: ${order.orderNumber}',
        referenceId: productionOrderId,
      );
    }

    // Increase finished goods inventory
    await _adjustInventoryQuantity(
      order.productId,
      order.quantity,
      'Production completion: ${order.orderNumber}',
      referenceId: productionOrderId,
      batchNumber: 'BATCH-${DateTime.now().millisecondsSinceEpoch}',
      expiryDate: DateTime.now()
          .add(const Duration(days: 365)), // Default 1 year expiry
    );
  }

  /// Updates inventory based on shipment creation
  Future<void> handleShipmentCreation(String shipmentId) async {
    final shipment = await _ref.read(deliveryByIdProvider(shipmentId).future);
    if (shipment == null) return;

    // Reserve inventory items for shipment
    for (final item in shipment.items ?? []) {
      await _reserveInventory(
        item['productId'],
        item['quantity'],
        'Shipment reservation: $shipmentId',
        referenceId: shipmentId,
      );
    }
  }

  /// Updates inventory based on shipment completion (goods issue)
  Future<void> handleShipmentCompletion(String shipmentId) async {
    final shipment = await _ref.read(deliveryByIdProvider(shipmentId).future);
    if (shipment == null) return;

    // Decrease inventory for shipped items
    for (final item in shipment.items ?? []) {
      await _adjustInventoryQuantity(
        item['productId'],
        -item['quantity'],
        'Shipment completion: $shipmentId',
        referenceId: shipmentId,
      );
    }
  }

  /// Updates inventory and material planning based on sales order creation
  Future<void> handleSalesOrderCreation(String orderId) async {
    final order = await _ref.read(orderDetailsProvider(orderId).future);

    // Check inventory availability for order items
    bool needsProduction = false;

    for (final item in order.items) {
      final inventoryItem = await _getInventoryItem(item.productId);
      if (inventoryItem.quantity < item.quantity) {
        needsProduction = true;
        break;
      }
    }

    if (needsProduction) {
      await _triggerProductionPlanning(order);
    } else {
      // Reserve inventory for the order
      for (final item in order.items) {
        await _reserveInventory(
          item.productId,
          item.quantity,
          'Sales order reservation: ${order.orderNumber}',
          referenceId: orderId,
        );
      }
    }
  }

  /// Handle inventory returns from customers
  Future<void> handleCustomerReturn(
      String returnId, List<Map<String, dynamic>> returnItems) async {
    for (final item in returnItems) {
      final String productId = item['productId'];
      final double quantity = item['quantity'];
      final String disposition = item['disposition'] ?? 'Stock';

      switch (disposition) {
        case 'Stock':
          // Return to stock
          await _adjustInventoryQuantity(
            productId,
            quantity,
            'Customer return: $returnId',
            referenceId: returnId,
            batchNumber: item['batchNumber'],
            expiryDate: item['expiryDate'] != null
                ? DateTime.parse(item['expiryDate'])
                : null,
          );
          break;

        case 'Damaged':
          // Add to damaged inventory
          await _ref.read(inventoryProvider.notifier).addToDamagedInventory(
                itemId: productId,
                quantity: quantity,
                reason: 'Customer return: $returnId',
                referenceId: returnId,
                notes: item['notes'] ?? 'Returned from customer',
                batchNumber: item['batchNumber'],
              );
          break;

        case 'QualityCheck':
          // Add to quality hold for inspection
          await _ref.read(inventoryProvider.notifier).addToQualityHold(
                itemId: productId,
                quantity: quantity,
                reason: 'Customer return: $returnId',
                referenceId: returnId,
                batchNumber: item['batchNumber'],
              );
          break;
      }
    }
  }

  /// Helper method to get inventory item
  Future<InventoryItem> _getInventoryItem(String productId) async {
    final itemAsync = await _ref.read(inventoryItemProvider(productId).future);

    if (itemAsync != null) {
      return itemAsync.toDomain();
    }

    // Return empty item if not found
    return InventoryItem(
      id: productId,
      name: 'Unknown Item',
      category: 'Unknown',
      unit: 'each',
      quantity: 0,
      minimumQuantity: 0,
      reorderPoint: 0,
      location: '',
      lastUpdated: DateTime.now(),
    );
  }

  /// Helper method to adjust inventory quantity
  Future<void> _adjustInventoryQuantity(
    String itemId,
    double quantity,
    String reason, {
    String? referenceId,
    String? batchNumber,
    DateTime? expiryDate,
    String? locationId,
  }) async {
    try {
      final inventoryNotifier = _ref.read(inventoryProvider.notifier);

      if (quantity > 0) {
        // Increase stock
        await inventoryNotifier.increaseStock(
          itemId: itemId,
          quantity: quantity,
          reason: reason,
          referenceId: referenceId,
          batchNumber: batchNumber,
          expiryDate: expiryDate,
          locationId: locationId,
        );
      } else if (quantity < 0) {
        // Decrease stock (use absolute value)
        await inventoryNotifier.decreaseStock(
          itemId: itemId,
          quantity: quantity.abs(),
          reason: reason,
          referenceId: referenceId,
          locationId: locationId,
          batchNumber: batchNumber,
        );
      }
    } catch (e) {
      print('Error adjusting inventory: $e');
      rethrow;
    }
  }

  /// Helper method to reserve inventory
  Future<void> _reserveInventory(
    String itemId,
    double quantity,
    String reason, {
    String? referenceId,
  }) async {
    try {
      await _ref.read(inventoryProvider.notifier).reserveStock(
            itemId: itemId,
            quantity: quantity,
            reason: reason,
            referenceId: referenceId ?? 'RESERVATION-${const Uuid().v4()}',
          );
    } catch (e) {
      print('Error reserving inventory: $e');
      rethrow;
    }
  }

  /// Triggers production planning for products with insufficient inventory
  Future<void> _triggerProductionPlanning(OrderModel order) async {
    final dueDate = order.requiredDeliveryDate ??
        DateTime.now().add(const Duration(days: 7));

    for (final item in order.items) {
      final productionOrder = ProductionOrderModel(
        orderNumber: 'PO-${const Uuid().v4().substring(0, 8)}',
        productId: item.productId,
        productName: item.productName,
        quantity: item.quantity,
        unit: item.uom,
        scheduledDate: DateTime.now(),
        dueDate: dueDate,
        status: 'planned',
        relatedSalesOrderIds: [order.id],
        notes: 'Auto-generated from sales order ${order.orderNumber}',
        createdAt: DateTime.now(),
      );

      await _ref
          .read(productionOrdersProvider.notifier)
          .createProductionOrder(productionOrder);
    }
  }
}

/// Provider for the module integration service
final moduleIntegrationServiceProvider =
    Provider<ModuleIntegrationService>((ref) {
  return ModuleIntegrationService(ref, ref.read(inventoryRepositoryProvider));
});
