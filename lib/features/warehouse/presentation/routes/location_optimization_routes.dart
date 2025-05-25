import 'package:flutter/material.dart';

import '../../../inventory/domain/entities/inventory_item.dart';
import '../screens/item_location_details_screen.dart';
import '../screens/location_optimization_screen.dart';

/// Navigation routes for warehouse location optimization features
class LocationOptimizationRoutes {
  /// Route to the main location optimization screen
  static Route<void> locationOptimizationScreen() {
    return MaterialPageRoute(
      builder: (context) => const LocationOptimizationScreen(),
    );
  }

  /// Route to the item location details screen
  static Route<bool> itemLocationDetailsScreen({
    required InventoryItem item,
  }) {
    return MaterialPageRoute<bool>(
      builder: (context) => ItemLocationDetailsScreen(item: item),
    );
  }
}
