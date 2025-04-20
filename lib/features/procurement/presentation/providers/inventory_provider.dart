import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/inventory_item.dart';

/// Provider for all inventory items
final inventoryItemsProvider = FutureProvider<List<InventoryItem>>((ref) async {
  // In a real app, this would fetch from a repository
  await Future.delayed(
      const Duration(milliseconds: 500)); // Simulate network delay

  return [
    InventoryItem(
      id: 'item-1',
      name: 'Raw Milk',
      category: 'Raw Materials',
      quantity: 1000,
      unit: 'liters',
      price: 1.2,
      reorderPoint: 200,
      minimumQuantity: 100,
      supplierIds: ['supplier-1'],
    ),
    InventoryItem(
      id: 'item-2',
      name: 'Sugar',
      category: 'Raw Materials',
      quantity: 500,
      unit: 'kg',
      price: 2.0,
      reorderPoint: 100,
      minimumQuantity: 50,
      supplierIds: ['supplier-1', 'supplier-2'],
    ),
    InventoryItem(
      id: 'item-3',
      name: 'Plastic Bottles',
      category: 'Packaging',
      quantity: 5000,
      unit: 'pieces',
      price: 0.15,
      reorderPoint: 1000,
      minimumQuantity: 500,
      supplierIds: ['supplier-2'],
    ),
  ];
});

/// Mock usage rate provider
class UsageRateProvider {
  /// Get usage rates for items (monthly usage)
  Future<Map<String, double>> getItemUsageRates(List<String> itemIds) async {
    // In a real app, this would calculate from historical data
    await Future.delayed(const Duration(milliseconds: 300));

    return {
      'item-1': 500.0, // 500 liters per month
      'item-2': 200.0, // 200 kg per month
      'item-3': 2000.0, // 2000 pieces per month
    };
  }
}

/// Provider for the usage rate service
final usageRateProvider = Provider<UsageRateProvider>((ref) {
  return UsageRateProvider();
});
