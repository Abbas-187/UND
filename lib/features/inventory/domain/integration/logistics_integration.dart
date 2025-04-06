import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logistics/data/models/delivery_model.dart';
import '../../../logistics/domain/providers/delivery_provider.dart';
import '../providers/inventory_provider.dart';

/// Handles the specific integration between Inventory and Logistics modules
class LogisticsIntegration {
  LogisticsIntegration(this._ref);
  final Ref _ref;

  /// Verifies inventory availability for a planned shipment
  Future<Map<String, dynamic>> verifyShipmentAvailability(
      String shipmentId) async {
    // Get the delivery directly from the repository
    final deliveryProvider = deliveryByIdProvider(shipmentId);
    final DeliveryModel? delivery;

    try {
      delivery = await _ref.read(deliveryProvider.future);
    } catch (e) {
      return {
        'shipmentId': shipmentId,
        'allItemsAvailable': false,
        'error': 'Error fetching delivery: $e',
        'items': <String, dynamic>{}
      };
    }

    final inventoryState = _ref.read(inventoryProvider.notifier);
    final results = <String, dynamic>{};
    var allAvailable = true;

    if (delivery == null) {
      return {
        'shipmentId': shipmentId,
        'allItemsAvailable': false,
        'error': 'Delivery not found',
        'items': results
      };
    }

    // Check each shipment item
    for (final item in delivery.items) {
      // Null safety check here
      final available = await inventoryState.getAvailableStock(item.productId);
      final isAvailable = available >= item.quantity;

      results[item.productId] = {
        'required': item.quantity,
        'available': available,
        'isAvailable': isAvailable,
        'shortage': isAvailable ? 0 : item.quantity - available
      };

      if (!isAvailable) {
        allAvailable = false;
      }
    }

    return {
      'shipmentId': shipmentId,
      'allItemsAvailable': allAvailable,
      'items': results
    };
  }

  /// Generates picking lists for warehouse operations
  Future<Map<String, dynamic>> generatePickingList(String shipmentId) async {
    // Get the delivery directly from the repository
    final deliveryProvider = deliveryByIdProvider(shipmentId);
    final DeliveryModel? delivery;

    try {
      delivery = await _ref.read(deliveryProvider.future);
    } catch (e) {
      return {
        'error': 'Error fetching delivery for shipment ID: $shipmentId - $e',
      };
    }

    final inventoryState = _ref.read(inventoryProvider.notifier);

    if (delivery == null) {
      return {
        'error': 'Delivery not found for shipment ID: $shipmentId',
      };
    }

    final pickingList = <String, dynamic>{};
    final pickingLocations = <String, List<Map<String, dynamic>>>{};

    // Generate optimal picking locations for each item
    for (final item in delivery.items) {
      // Null safety check here
      final locations = await inventoryState.getOptimalPickingLocations(
          itemId: item.productId,
          quantity: item.quantity,
          useFEFO: true // Critical for dairy products
          );

      pickingLocations[item.productId] = locations;
    }

    pickingList['shipmentId'] = shipmentId;
    pickingList['shipmentNumber'] = delivery.id; // Null safety check here
    pickingList['customerName'] =
        delivery.customerName; // Null safety check here
    pickingList['scheduledDate'] =
        delivery.scheduledDate.toIso8601String(); // Null safety check here
    pickingList['items'] = delivery.items // Null safety check here
        .map((item) => {
              'productId': item.productId,
              'productName': item.productName,
              'quantity': item.quantity,
              'uom': item.unit,
              'pickingLocations': pickingLocations[item.productId]
            })
        .toList();

    return pickingList;
  }

  /// Processes inventory for items returned from logistics
  Future<void> processReturnedItems(
      String returnId, List<Map<String, dynamic>> returnedItems) async {
    final inventoryState = _ref.read(inventoryProvider.notifier);

    for (final item in returnedItems) {
      final productId = item['productId'] as String;
      final quantity = item['quantity'] as double;
      // final returnReason = item['reason'] as String; // Reason not used below
      final disposition = item['disposition'] as String;

      // Process based on return disposition
      switch (disposition) {
        case 'ReturnToStock':
          await inventoryState.increaseStock(
              itemId: productId,
              quantity: quantity,
              locationId: item['locationId'] as String,
              reason: 'Return: $returnId', // Added returnId to reason
              referenceId: returnId,
              batchNumber: item['batchNumber'] as String?,
              expiryDate: item['expiryDate'] != null
                  ? DateTime.parse(item['expiryDate'] as String)
                  : null);
          break;

        case 'Damaged':
          await inventoryState.addToDamagedInventory(
              itemId: productId,
              quantity: quantity,
              reason: 'Return: $returnId', // Added returnId to reason
              referenceId: returnId,
              notes: 'Returned from customer');
          break;

        case 'QualityCheck':
          await inventoryState.addToQualityHold(
              itemId: productId,
              quantity: quantity,
              reason: 'Return: $returnId', // Added returnId to reason
              referenceId: returnId,
              batchNumber: item['batchNumber'] as String?);
          break;
      }
    }
  }
}

/// Provider for logistics integration
final logisticsIntegrationProvider = Provider<LogisticsIntegration>((ref) {
  return LogisticsIntegration(ref);
});
