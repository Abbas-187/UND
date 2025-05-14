/*import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/mock_data_service.dart';
import '../models/inventory_item_model.dart';
import '../models/inventory_location_model.dart';
import '../models/inventory_movement_model.dart';
import '../models/inventory_movement_type.dart';

/// Provides mock inventory data for all modules
class MockInventoryProvider {
  MockInventoryProvider({required this.mockDataService});

  final MockDataService mockDataService;

  // Get all inventory items
  List<InventoryItemModel> getAllItems() => mockDataService.inventoryItems;

  // Get item by ID
  InventoryItemModel? getItemById(String id) {
    try {
      return mockDataService.inventoryItems.firstWhere(
        (item) => item.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  // Add item
  void addItem(InventoryItemModel item) {
    // Add to central mock data
    mockDataService.inventoryItems.add(item);
  }

  // Update item
  void updateItem(InventoryItemModel item) {
    // Update in central mock data service
    mockDataService.updateInventoryItem(item);
  }

  // Delete item
  void deleteItem(String id) {
    mockDataService.inventoryItems.removeWhere((item) => item.id == id);
  }

  // Get items needing reorder
  List<InventoryItemModel> getItemsNeedingReorder() {
    return mockDataService.inventoryItems
        .where((item) => item.quantity <= item.reorderPoint)
        .toList();
  }

  // Get low stock items
  List<InventoryItemModel> getLowStockItems() {
    return mockDataService.inventoryItems
        .where((item) => item.quantity <= item.minimumQuantity)
        .toList();
  }

  // Get inventory value by category
  Map<String, double> getInventoryValueByCategory() {
    final Map<String, double> result = {};

    for (final item in mockDataService.inventoryItems) {
      if (item.cost != null) {
        final value = item.quantity * item.cost!;
        result[item.category] = (result[item.category] ?? 0) + value;
      }
    }

    return result;
  }

  // Get all locations
  List<InventoryLocationModel> getAllLocations() {
    return mockDataService.inventoryLocations;
  }

  // Get location by ID
  InventoryLocationModel? getLocationById(String id) {
    try {
      return mockDataService.inventoryLocations.firstWhere(
        (location) => location.locationId == id,
      );
    } catch (_) {
      return null;
    }
  }

  // Get inventory movements
  List<InventoryMovementModel> getInventoryMovements() {
    return mockDataService.inventoryMovements;
  }

  // Create inventory movement
  String createInventoryMovement(InventoryMovementModel movement) {
    mockDataService.inventoryMovements.add(movement);

    // Update inventory based on movement
    _processMovementImpact(movement);

    return movement.movementId;
  }

  // Check availability for recipe
  bool checkInventoryForRecipe(String recipeId, double batchSize) {
    return mockDataService.checkInventoryForRecipe(recipeId, batchSize);
  }

  // Get recipe ingredients
  List<Map<String, dynamic>> getRecipeIngredients(String recipeId) {
    return mockDataService.getRecipeIngredients(recipeId);
  }

  // Get forecast for item
  List<Map<String, dynamic>> getInventoryForecast(String itemId) {
    return mockDataService.getInventoryForecast(itemId);
  }

  // Get procurement needs
  List<Map<String, dynamic>> getProcurementNeeds() {
    return mockDataService.getProcurementNeeds();
  }

  // Private helper to process inventory movement impact
  void _processMovementImpact(InventoryMovementModel movement) {
    // Process based on movement type
    switch (movement.movementType) {
      case InventoryMovementType.PO_RECEIPT:
        // Increase inventory for received items
        for (final item in movement.items) {
          mockDataService.adjustQuantity(item.productId, item.quantity,
              'Received from ${movement.sourceLocationName}');
        }
        break;
      case InventoryMovementType.PRODUCTION_ISSUE:
        // Decrease inventory for issued items
        for (final item in movement.items) {
          mockDataService.adjustQuantity(item.productId, -item.quantity,
              'Issued to ${movement.destinationLocationName}');
        }
        break;
      case InventoryMovementType.TRANSFER_IN:
        // No net change in total inventory, just location change
        break;
      case InventoryMovementType.ADJUSTMENT_OTHER:
        // Process each item separately (could be positive or negative)
        for (final item in movement.items) {
          mockDataService.adjustQuantity(
              item.productId, item.quantity, movement.reasonNotes);
        }
        break;
      default:
        break;
    }
  }
}

/// Provider for the mock inventory provider
final mockInventoryProvider = Provider<MockInventoryProvider>((ref) {
  final mockDataService = ref.read(mockDataServiceProvider);
  return MockInventoryProvider(mockDataService: mockDataService);
});
*/
