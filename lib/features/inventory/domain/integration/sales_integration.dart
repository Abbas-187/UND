import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../forecasting/domain/providers/production_planning_provider.dart';
import '../../../order_management/domain/providers/order_usecase_providers.dart';
import '../providers/inventory_provider.dart';

/// Handles the specific integration between Inventory and Sales modules
class SalesIntegration {
  SalesIntegration(this.ref);
  final Ref ref;
}

class SalesIntegrationNotifier extends StateNotifier<void> {
  SalesIntegrationNotifier(this.ref) : super(null);

  final Ref ref;

  /// Checks product availability for a sales order
  Future<Map<String, dynamic>> checkOrderAvailability(String orderId) async {
    final getOrderById = ref.read(getOrderByIdUseCaseProvider);
    final orderAsync = await getOrderById.execute(orderId);
    final inventoryState = ref.read(inventoryProvider.notifier);

    final results = <String, dynamic>{};
    var allAvailable = true;
    var partiallyAvailable = false;

    // Check each order item
    for (final item in orderAsync.items ?? []) {
      final available =
          await inventoryState.getAvailableStock(item['productId']);
      final isFullyAvailable = available >= item['quantity'];
      final isPartiallyAvailable =
          available > 0 && available < item['quantity'];

      results[item['productId']] = {
        'ordered': item['quantity'],
        'available': available,
        'isFullyAvailable': isFullyAvailable,
        'isPartiallyAvailable': isPartiallyAvailable,
        'shortage': isFullyAvailable ? 0 : item['quantity'] - available
      };

      if (!isFullyAvailable) {
        allAvailable = false;
      }

      if (isPartiallyAvailable) {
        partiallyAvailable = true;
      }
    }

    return {
      'orderId': orderId,
      'allItemsAvailable': allAvailable,
      'partiallyAvailable': partiallyAvailable,
      'items': results
    };
  }

  /// Calculates estimated shipment dates based on inventory availability
  Future<Map<String, DateTime>> calculateEstimatedShipmentDates(
      String orderId) async {
    final getOrderById = ref.read(getOrderByIdUseCaseProvider);
    final orderAsync = await getOrderById.execute(orderId);
    final inventoryState = ref.read(inventoryProvider.notifier);
    final productionProvider = ref.read(productionPlanningProvider.notifier);

    final shipmentDates = <String, DateTime>{};

    for (final item in orderAsync.items ?? []) {
      final available =
          await inventoryState.getAvailableStock(item['productId']);

      if (available >= item['quantity']) {
        // Can ship immediately (or based on standard processing time)
        shipmentDates[item['productId']] =
            DateTime.now().add(const Duration(days: 1));
      } else {
        // Need production - estimate based on production schedule
        final productionTime =
            await productionProvider.generateProductionSchedule([
          {
            'productId': item['productId'],
            'quantity': item['quantity'] - available,
            'date': DateTime.now()
          }
        ], {
          'labor': 10,
          'machine': 5
        });

        // Use a default value for simplicity if no production time available
        final estimatedDays = productionTime.isNotEmpty ? 5 : 7;

        shipmentDates[item['productId']] =
            DateTime.now().add(Duration(days: estimatedDays));
      }
    }

    return shipmentDates;
  }

  /// Provides real-time inventory availability for the sales module
  Stream<Map<String, double>> getInventoryAvailabilityStream(
      List<String> productIds) {
    // Implementation of real-time inventory availability stream
    // This would typically connect to a repository that provides a stream
    // For now, simulate with a simple mock stream
    return Stream.value(
      Map.fromEntries(
        productIds.map((id) => MapEntry(id, 0.0)),
      ),
    );
  }
}

/// Provider for sales integration
final salesIntegrationProvider =
    StateNotifierProvider<SalesIntegrationNotifier, void>((ref) {
  return SalesIntegrationNotifier(ref);
});
