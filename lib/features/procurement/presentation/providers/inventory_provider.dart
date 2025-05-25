import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../inventory/domain/entities/inventory_item.dart';

/// Provider for all inventory items
final inventoryItemsProvider = FutureProvider<List<InventoryItem>>((ref) async {
  final snapshot =
      await FirebaseFirestore.instance.collection('inventory item').get();
  return snapshot.docs
      .map((doc) => InventoryItem.fromJson(doc.data()))
      .toList();
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
