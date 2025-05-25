import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../factory/data/models/production_order_model.dart';
import '../../../factory/domain/providers/production_provider.dart';
import '../../../logistics/domain/providers/delivery_provider.dart';
import '../../../order_management/data/models/order_model.dart';
import '../../../order_management/presentation/providers/order_provider.dart';
import '../../../order_management/domain/providers/order_usecase_providers.dart';
import '../../domain/providers/inventory_provider.dart' as inventory_domain;
import '../entities/inventory_item.dart';
import 'production_integration_service.dart';

/// Service that handles integration between Inventory and other modules
class ModuleIntegrationService {
  ModuleIntegrationService(this._ref);
  final Ref _ref;

  /// Updates inventory based on production start (material issuance)
  Future<ProductionIntegrationResult> handleProductionStart({
    required String productionOrderId,
    required String issuedBy,
    String warehouseId = 'MAIN',
    bool allowPartialIssuance = false,
    String? notes,
  }) async {
    final productionIntegrationService =
        _ref.read(productionIntegrationServiceProvider);

    return await productionIntegrationService.handleProductionStart(
      productionOrderId: productionOrderId,
      issuedBy: issuedBy,
      warehouseId: warehouseId,
      allowPartialIssuance: allowPartialIssuance,
      notes: notes,
    );
  }

  /// Updates inventory based on production completion (finished goods receipt)
  Future<ProductionIntegrationResult> handleProductionCompletion({
    required String productionOrderId,
    required double quantityProduced,
    required String receivedBy,
    String warehouseId = 'MAIN',
    double? laborCost,
    double? overheadCost,
    String? qualityStatus,
    String? notes,
  }) async {
    final productionIntegrationService =
        _ref.read(productionIntegrationServiceProvider);

    return await productionIntegrationService.handleProductionCompletion(
      productionOrderId: productionOrderId,
      quantityProduced: quantityProduced,
      receivedBy: receivedBy,
      warehouseId: warehouseId,
      laborCost: laborCost,
      overheadCost: overheadCost,
      qualityStatus: qualityStatus,
      notes: notes,
    );
  }

  /// Handle complete production cycle (legacy method for backward compatibility)
  Future<void> handleProductionCompletionLegacy(
      String productionOrderId) async {
    try {
      final order = await _ref
          .read(productionOrderByIdProvider(productionOrderId).future);

      // Use the new production integration service
      final productionIntegrationService =
          _ref.read(productionIntegrationServiceProvider);

      // Handle complete production cycle with default values
      final result =
          await productionIntegrationService.handleCompleteProductionCycle(
        productionOrderId: productionOrderId,
        quantityProduced: order.quantity,
        operatorId: 'SYSTEM', // Default operator
        warehouseId: 'MAIN',
        allowPartialIssuance: true,
        qualityStatus: 'AVAILABLE',
        notes: 'Legacy production completion',
      );

      if (!result.success) {
        throw Exception(
            'Production integration failed: ${result.errors.join(', ')}');
      }
    } catch (e) {
      throw Exception('Failed to handle production completion: $e');
    }
  }

  /// Check material availability for production order
  Future<Map<String, dynamic>> checkMaterialAvailability({
    required String productionOrderId,
    String warehouseId = 'MAIN',
  }) async {
    final productionIntegrationService =
        _ref.read(productionIntegrationServiceProvider);

    return await productionIntegrationService.checkMaterialAvailability(
      productionOrderId: productionOrderId,
      warehouseId: warehouseId,
    );
  }

  /// Updates inventory based on shipment creation
  Future<void> handleShipmentCreation(String shipmentId) async {
    final shipment = await _ref.read(deliveryByIdProvider(shipmentId).future);
    if (shipment == null) return;

    // Reserve inventory items for shipment
    for (final item in shipment.items) {
      await _reserveInventory(
        item.productId,
        item.quantity,
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
    for (final item in shipment.items) {
      await _adjustInventoryQuantity(
        item.productId,
        -item.quantity,
        'Shipment completion: $shipmentId',
        referenceId: shipmentId,
      );
    }
  }

  /// Updates inventory and material planning based on sales order creation
  Future<void> handleSalesOrderCreation(String orderId) async {
    final getOrderById = _ref.read(getOrderByIdUseCaseProvider);
    final orderEntity = await getOrderById.execute(orderId);
    final order = OrderModel.fromEntity(orderEntity);

    // Check inventory availability for order items
    bool needsProduction = false;

    for (final item in order.items) {
      final inventoryItem =
          await _getInventoryItem(item['productId'] ?? item.productId);
      final itemQuantity = item['quantity'] ?? item.quantity;
      if (inventoryItem.quantity < itemQuantity) {
        needsProduction = true;
        break;
      }
    }

    // If production is needed, create production orders
    if (needsProduction) {
      await _createProductionOrdersForSalesOrder(order);
    }
  }

  /// Create production orders for sales order items that need production
  Future<void> _createProductionOrdersForSalesOrder(OrderModel order) async {
    final dueDate = order.requiredDeliveryDate ??
        DateTime.now().add(const Duration(days: 7));

    for (final item in order.items) {
      final productionOrder = ProductionOrderModel(
        orderNumber: 'PO-${const Uuid().v4().substring(0, 8)}',
        productId: item['productId'] ?? item.productId,
        productName: item['productName'] ?? item.productName,
        quantity: item['quantity'] ?? item.quantity,
        unit: item['uom'] ?? item.unit,
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

  /// Helper method to get inventory item
  Future<InventoryItem> _getInventoryItem(String itemId) async {
    final repository = _ref.read(inventory_domain.inventoryRepositoryProvider);
    final item = await repository.getItem(itemId);
    if (item == null) {
      throw Exception('Inventory item not found: $itemId');
    }
    return item;
  }

  /// Helper method to adjust inventory quantity
  Future<void> _adjustInventoryQuantity(
    String itemId,
    double quantityChange,
    String reason, {
    String? referenceId,
    String? batchNumber,
    DateTime? expiryDate,
  }) async {
    final repository = _ref.read(inventory_domain.inventoryRepositoryProvider);

    // Use the repository's adjustQuantity method
    await repository.adjustQuantity(
      itemId,
      quantityChange,
      reason,
      'SYSTEM', // Default employee ID
    );
  }

  /// Helper method to reserve inventory
  Future<void> _reserveInventory(
    String itemId,
    double quantity,
    String reason, {
    String? referenceId,
  }) async {
    final inventoryState =
        _ref.read(inventory_domain.inventoryProvider.notifier);

    await inventoryState.reserveStock(
      itemId: itemId,
      quantity: quantity,
      reason: reason,
      referenceId: referenceId ?? 'RESERVATION-${const Uuid().v4()}',
    );
  }
}

/// Provider for the module integration service
final moduleIntegrationServiceProvider =
    Provider<ModuleIntegrationService>((ref) {
  return ModuleIntegrationService(ref);
});
