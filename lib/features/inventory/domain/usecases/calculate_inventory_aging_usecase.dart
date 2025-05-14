import 'package:flutter/material.dart';

import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class CalculateInventoryAgingUsecase {
  CalculateInventoryAgingUsecase({
    required InventoryRepository repository,
  }) : _repository = repository;
  final InventoryRepository _repository;

  /// Calculate inventory aging for the specified warehouse
  ///
  /// Returns a map with age brackets as keys and lists of inventory items in each bracket
  Future<Map<AgeBracket, List<InventoryItem>>> execute(
      String warehouseId) async {
    // Get all inventory items for the warehouse
    final items = await _repository.getItems();

    final now = DateTime.now();
    final Map<AgeBracket, List<InventoryItem>> result = {
      AgeBracket.expiredItems: [],
      AgeBracket.critical: [],
      AgeBracket.warning: [],
      AgeBracket.upcoming: [],
      AgeBracket.good: [],
      AgeBracket.noExpiry: [],
    };

    for (final item in items) {
      if (item.expiryDate == null) {
        result[AgeBracket.noExpiry]!.add(item);
        continue;
      }

      final daysUntilExpiry = item.expiryDate!.difference(now).inDays;

      if (daysUntilExpiry < 0) {
        // Already expired
        result[AgeBracket.expiredItems]!.add(item);
      } else if (daysUntilExpiry <= 7) {
        // Critical - expiring within a week
        result[AgeBracket.critical]!.add(item);
      } else if (daysUntilExpiry <= 30) {
        // Warning - expiring within a month
        result[AgeBracket.warning]!.add(item);
      } else if (daysUntilExpiry <= 90) {
        // Upcoming - expiring within three months
        result[AgeBracket.upcoming]!.add(item);
      } else {
        // Good - expiring after three months
        result[AgeBracket.good]!.add(item);
      }
    }

    return result;
  }
}

/// Enum representing different inventory age brackets
enum AgeBracket {
  expiredItems, // Already expired
  critical, // 0-7 days until expiry
  warning, // 8-30 days until expiry
  upcoming, // 31-90 days until expiry
  good, // 91+ days until expiry
  noExpiry, // No expiry date
}

/// Extension to get display information for an age bracket
extension AgeBracketInfo on AgeBracket {
  String get label {
    switch (this) {
      case AgeBracket.expiredItems:
        return 'Expired Items';
      case AgeBracket.critical:
        return 'Critical (0-7 Days)';
      case AgeBracket.warning:
        return 'Warning (8-30 Days)';
      case AgeBracket.upcoming:
        return 'Upcoming (31-90 Days)';
      case AgeBracket.good:
        return 'Good (91+ Days)';
      case AgeBracket.noExpiry:
        return 'No Expiry Date';
    }
  }

  Color get color {
    switch (this) {
      case AgeBracket.expiredItems:
        return Colors.red;
      case AgeBracket.critical:
        return Colors.deepOrange;
      case AgeBracket.warning:
        return Colors.orange;
      case AgeBracket.upcoming:
        return Colors.amber;
      case AgeBracket.good:
        return Colors.green;
      case AgeBracket.noExpiry:
        return Colors.blue;
    }
  }
}
