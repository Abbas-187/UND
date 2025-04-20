import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../inventory/data/models/inventory_transaction_model.dart';
import '../../../inventory/domain/entities/inventory_item.dart';
import '../../../inventory/domain/entities/stock_level.dart';
import '../../../inventory/domain/providers/forecasting_provider.dart';
import '../../../inventory/domain/providers/inventory_provider.dart';
import '../../../inventory/domain/providers/inventory_repository_provider.dart'
    as domain_repo;
import '../../../inventory/domain/providers/stock_level_provider.dart';
import '../../data/models/purchase_order_model.dart';
import '../providers/purchase_order_provider.dart';

/// Integration service to connect procurement with inventory
class ProcurementInventoryIntegration {
  ProcurementInventoryIntegration(this._ref);
  final Ref _ref;

  /// Converts a received purchase order to inventory items
  Future<List<String>> convertPOToInventory(String purchaseOrderId) async {
    final purchaseOrder =
        await _ref.read(purchaseOrderByIdProvider(purchaseOrderId).future);
    final inventoryState = _ref.read(inventoryProvider.notifier);
    final createdItemIds = <String>[];

    // Ensure PO is in completed status
    if (purchaseOrder?.status.toString().toLowerCase() != 'received') {
      throw Exception(
          'Only received purchase orders can be added to inventory');
    }

    // Process each PO item and add to inventory
    for (final item in purchaseOrder?.items ?? []) {
      final inventoryId = await _addToInventory(
        item: item,
        poId: purchaseOrderId,
        poNumber: purchaseOrder?.poNumber ?? '',
        supplierId: purchaseOrder?.supplierId ?? '',
        supplierName: purchaseOrder?.supplierName ?? '',
        deliveryDate: purchaseOrder?.deliveryDate ?? DateTime.now(),
      );

      createdItemIds.add(inventoryId);
    }

    // Refresh inventory after additions
    await inventoryState.loadInventory();

    return createdItemIds;
  }

  /// Adds specific PO item to inventory
  Future<String> _addToInventory({
    required PurchaseOrderItemModel item,
    required String poId,
    required String poNumber,
    required String supplierId,
    required String supplierName,
    required DateTime deliveryDate,
  }) async {
    final inventoryRepository =
        _ref.read(domain_repo.inventoryRepositoryProvider);

    // Create the inventory item
    final inventoryItem = InventoryItem(
      id: '', // Will be set by the repository
      name: item.itemName,
      category: 'procurement',
      unit: item.unit,
      quantity: item.quantity,
      minimumQuantity: 0,
      reorderPoint: 0,
      location: 'receiving/zone-a', // Default receiving location
      lastUpdated: DateTime.now(),
      batchNumber: 'LOT-${DateTime.now().millisecondsSinceEpoch}',
      additionalAttributes: {
        'supplierInfo': '$supplierId - $supplierName',
        'purchaseOrderId': poId,
        'purchaseOrderNumber': poNumber,
      },
    );

    // Create inventory transaction record
    final transaction = InventoryTransactionModel(
      materialId: item.itemId,
      materialName: item.itemName,
      warehouseId: 'receiving',
      transactionType: TransactionType.receipt,
      quantity: item.quantity,
      uom: item.unit,
      referenceNumber: poNumber,
      referenceType: 'purchase_order',
      reason: 'PO Receipt: $poNumber',
      transactionDate: DateTime.now(),
    );

    // Add item to inventory with transaction
    final addedItem = await inventoryRepository.addItem(inventoryItem);
    return addedItem.id;
  }

  /// Checks stock levels and suggests reordering
  Future<List<Map<String, dynamic>>> checkStockLevelsForReordering() async {
    final stockLevelState = _ref.read(stockLevelProvider.notifier);

    // Get items below reorder level
    final itemsBelowReorderLevel =
        await stockLevelState.getItemsBelowReorderLevel() as List<StockLevel>;

    // Format results with reordering suggestion
    final reorderSuggestions = itemsBelowReorderLevel.map((item) {
      final reorderQuantity = _calculateReorderQuantity(
        currentLevel: item.currentLevel,
        minLevel: item.minLevel,
        maxLevel: item.maxLevel,
        leadTime: item.leadTimeDays,
      );

      return {
        'materialId': item.materialId,
        'materialName': item.materialName,
        'currentStock': item.currentLevel,
        'minLevel': item.minLevel,
        'suggestedReorderQuantity': reorderQuantity,
        'urgency': item.currentLevel <= item.criticalLevel ? 'high' : 'normal',
        'unit': item.unit,
      };
    }).toList();

    return reorderSuggestions;
  }

  /// Calculates appropriate reorder quantity
  double _calculateReorderQuantity({
    required double currentLevel,
    required double minLevel,
    required double maxLevel,
    required int leadTime,
  }) {
    // Simple EOQ calculation
    final deficit = maxLevel - currentLevel;
    final safetyStock = minLevel * 0.25; // 25% of min as safety stock

    return deficit + safetyStock;
  }

  /// Sends notifications for low stock items
  Future<List<String>> triggerLowStockNotifications() async {
    final stockLevelState = _ref.read(stockLevelProvider.notifier);
    final notificationIds = <String>[];

    // Get critical stock items
    final criticalItems =
        await stockLevelState.getItemsAtCriticalLevel() as List<StockLevel>;

    for (final item in criticalItems) {
      // Generate notification for each critical item
      final notificationId = await _createStockNotification(
        materialId: item.materialId,
        materialName: item.materialName,
        currentLevel: item.currentLevel,
        criticalLevel: item.criticalLevel,
        unit: item.unit,
      );

      notificationIds.add(notificationId);
    }

    return notificationIds;
  }

  /// Creates stock notification
  Future<String> _createStockNotification({
    required String materialId,
    required String materialName,
    required double currentLevel,
    required double criticalLevel,
    required String unit,
  }) async {
    // Code to create and send notification would go here
    // This is a placeholder for the actual implementation

    return 'notification-$materialId-${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Gets demand forecast for inventory planning
  Future<Map<String, dynamic>> getInventoryForecast(String materialId,
      {int daysAhead = 30}) async {
    final forecastingState = _ref.read(forecastingProvider.notifier);

    // Get forecasted demand
    final forecast = await forecastingState.getForecastForMaterial(
      materialId: materialId,
      periodDays: daysAhead,
    );

    // Get current stock levels
    final inventoryState = _ref.read(inventoryProvider.notifier);
    final currentStock = await inventoryState.getAvailableStock(materialId);

    // Combine data for procurement planning
    return {
      'materialId': materialId,
      'currentStock': currentStock,
      'forecastedDemand': forecast['totalDemand'],
      'suggestedPurchaseQuantity': _calculateSuggestedPurchase(
        currentStock: currentStock,
        forecastDemand: forecast['totalDemand'],
        safetyFactor: 1.2, // 20% safety factor
      ),
      'dailyForecast': forecast['dailyDemand'],
      'forecastConfidence': forecast['confidenceScore'],
      'dataPoints': forecast['dataPoints'],
    };
  }

  /// Calculates suggested purchase quantity based on forecast
  double _calculateSuggestedPurchase({
    required double currentStock,
    required double forecastDemand,
    required double safetyFactor,
  }) {
    final suggestedQuantity = (forecastDemand * safetyFactor) - currentStock;
    return suggestedQuantity > 0 ? suggestedQuantity : 0;
  }
}

/// Provider for procurement-inventory integration
final procurementInventoryIntegrationProvider =
    Provider<ProcurementInventoryIntegration>((ref) {
  return ProcurementInventoryIntegration(ref);
});
