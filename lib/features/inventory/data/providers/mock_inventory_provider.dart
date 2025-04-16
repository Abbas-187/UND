import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/inventory_item_model.dart';
import '../models/inventory_movement_model.dart';
import '../models/inventory_location_model.dart';
import '../models/inventory_movement_type.dart';

class MockInventoryProvider {
  // Mock data
  final List<InventoryItemModel> _mockItems = [
    InventoryItemModel(
      id: '1',
      name: 'Fresh Milk',
      category: 'Dairy',
      unit: 'Liters',
      quantity: 100.0,
      minimumQuantity: 20.0,
      reorderPoint: 30.0,
      location: 'Cold Storage A',
      lastUpdated: DateTime.now(),
      batchNumber: 'BATCH001',
      expiryDate: DateTime.now().add(const Duration(days: 7)),
      cost: 2.5,
      currentTemperature: 4.0,
      storageCondition: 'refrigerated',
      overallQualityStatus: QualityStatus.excellent,
    ),
    InventoryItemModel(
      id: '2',
      name: 'Yogurt',
      category: 'Dairy',
      unit: 'Units',
      quantity: 50.0,
      minimumQuantity: 10.0,
      reorderPoint: 15.0,
      location: 'Cold Storage B',
      lastUpdated: DateTime.now(),
      batchNumber: 'BATCH002',
      expiryDate: DateTime.now().add(const Duration(days: 14)),
      cost: 1.8,
      currentTemperature: 4.0,
      storageCondition: 'refrigerated',
      overallQualityStatus: QualityStatus.good,
    ),
    // Add more mock items as needed
  ];

  final List<InventoryLocationModel> _mockLocations = [
    InventoryLocationModel(
      locationId: '1',
      locationName: 'Cold Storage A',
      locationType: LocationType.COLD_STORAGE,
      temperatureCondition: '4°C',
      storageCapacity: 1000.0,
      currentUtilization: 500.0,
      isActive: true,
    ),
    InventoryLocationModel(
      locationId: '2',
      locationName: 'Cold Storage B',
      locationType: LocationType.COLD_STORAGE,
      temperatureCondition: '4°C',
      storageCapacity: 800.0,
      currentUtilization: 400.0,
      isActive: true,
    ),
  ];

  // Get all inventory items
  List<InventoryItemModel> getAllItems() => _mockItems;

  // Get item by ID
  InventoryItemModel? getItemById(String id) {
    try {
      return _mockItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add new item
  void addItem(InventoryItemModel item) {
    _mockItems.add(item);
  }

  // Update item
  void updateItem(InventoryItemModel updatedItem) {
    final index = _mockItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _mockItems[index] = updatedItem;
    }
  }

  // Delete item
  void deleteItem(String id) {
    _mockItems.removeWhere((item) => item.id == id);
  }

  // Get items by category
  List<InventoryItemModel> getItemsByCategory(String category) {
    return _mockItems.where((item) => item.category == category).toList();
  }

  // Get low stock items
  List<InventoryItemModel> getLowStockItems() {
    return _mockItems
        .where((item) => item.quantity <= item.minimumQuantity)
        .toList();
  }

  // Get expiring items
  List<InventoryItemModel> getExpiringItems({int days = 7}) {
    final threshold = DateTime.now().add(Duration(days: days));
    return _mockItems
        .where((item) =>
            item.expiryDate != null && item.expiryDate!.isBefore(threshold))
        .toList();
  }

  // Get items by location
  List<InventoryItemModel> getItemsByLocation(String location) {
    return _mockItems.where((item) => item.location == location).toList();
  }

  // Get all locations
  List<InventoryLocationModel> getAllLocations() => _mockLocations;

  // Get location by ID
  InventoryLocationModel? getLocationById(String id) {
    try {
      return _mockLocations.firstWhere((location) => location.locationId == id);
    } catch (e) {
      return null;
    }
  }

  // Add new location
  void addLocation(InventoryLocationModel location) {
    _mockLocations.add(location);
  }

  // Update location
  void updateLocation(InventoryLocationModel updatedLocation) {
    final index = _mockLocations.indexWhere(
        (location) => location.locationId == updatedLocation.locationId);
    if (index != -1) {
      _mockLocations[index] = updatedLocation;
    }
  }

  // Delete location
  void deleteLocation(String id) {
    _mockLocations.removeWhere((location) => location.locationId == id);
  }

  // Transfer items between locations
  void transferItems(
    String sourceLocationId,
    String destinationLocationId,
    List<InventoryItemModel> items,
    String reason,
  ) {
    // Implementation for transferring items between locations
    // This would typically involve:
    // 1. Validating the transfer
    // 2. Updating item locations
    // 3. Creating a movement record
    // 4. Updating location utilization
  }

  // Adjust item quantity
  void adjustQuantity(String itemId, double adjustment, String reason) {
    final item = getItemById(itemId);
    if (item != null) {
      final updatedItem = item.copyWith(
        quantity: item.quantity + adjustment,
        lastUpdated: DateTime.now(),
      );
      updateItem(updatedItem);
    }
  }

  // Get inventory value by category
  Map<String, double> getInventoryValueByCategory() {
    final Map<String, double> values = {};
    for (final item in _mockItems) {
      if (item.cost != null) {
        values[item.category] =
            (values[item.category] ?? 0) + (item.quantity * item.cost!);
      }
    }
    return values;
  }

  // Get items needing reorder
  List<InventoryItemModel> getItemsNeedingReorder() {
    return _mockItems
        .where((item) => item.quantity <= item.reorderPoint)
        .toList();
  }

  // Search items
  List<InventoryItemModel> searchItems(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _mockItems.where((item) {
      return item.name.toLowerCase().contains(lowercaseQuery) ||
          item.category.toLowerCase().contains(lowercaseQuery) ||
          item.batchNumber?.toLowerCase().contains(lowercaseQuery) == true;
    }).toList();
  }
}

// Provider for the mock inventory
final mockInventoryProvider = Provider<MockInventoryProvider>((ref) {
  return MockInventoryProvider();
});
