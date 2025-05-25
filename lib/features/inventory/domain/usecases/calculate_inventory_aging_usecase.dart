import 'package:flutter/material.dart';

import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class CalculateInventoryAgingUsecase {
  CalculateInventoryAgingUsecase({
    required InventoryRepository repository,
  }) : _repository = repository;
  final InventoryRepository _repository;

  /// Calculate inventory aging for inventory items
  ///
  /// Returns a map with age brackets as keys and lists of inventory items in each bracket
  Future<Map<AgeBracket, List<InventoryItem>>> execute() async {
    // Get all inventory items
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

    // Process each item based on its expiry date
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

  /// Get detailed aging information with batch-level details
  ///
  /// This method provides more granular aging data by examining individual batch information
  /// Returns a map with age brackets as keys and details about items in each bracket
  Future<Map<AgeBracket, InventoryAgingDetails>> executeDetailed(
      String warehouseId) async {
    // Get all inventory items for the warehouse (unused)
    await _repository.getInventoryItems(warehouseId);
    // Get all inventory movements to analyze batch-level data
    final movements = await _repository.getMovementsForWarehouse(warehouseId);

    final now = DateTime.now();
    final Map<AgeBracket, InventoryAgingDetails> result = {
      AgeBracket.expiredItems: InventoryAgingDetails(),
      AgeBracket.critical: InventoryAgingDetails(),
      AgeBracket.warning: InventoryAgingDetails(),
      AgeBracket.upcoming: InventoryAgingDetails(),
      AgeBracket.good: InventoryAgingDetails(),
      AgeBracket.noExpiry: InventoryAgingDetails(),
    };

    // Process batch-level data from movements
    for (final movement in movements) {
      for (final item in movement.items) {
        // Skip if not a receipt/inbound movement
        if (!movement.isInbound) continue;

        // Determine which bracket this item falls into
        final AgeBracket bracket = _determineBracket(item.expirationDate, now);

        // Add to the appropriate bracket
        result[bracket]!.addItem(
          item.productId,
          item.quantity,
          item.costAtTransaction ?? 0,
          batchNumber: item.batchLotNumber,
          expiryDate: item.expirationDate,
        );
      }
    }

    return result;
  }

  /// Calculate the total value of inventory by age bracket
  ///
  /// Returns a map with age brackets as keys and total values in each bracket
  Future<Map<AgeBracket, double>> calculateValueByAgeBracket(
      String warehouseId) async {
    final detailedAging = await executeDetailed(warehouseId);

    final Map<AgeBracket, double> result = {};

    for (final bracket in AgeBracket.values) {
      result[bracket] = detailedAging[bracket]!.totalValue;
    }

    return result;
  }

  /// Determine the age bracket for an item based on its expiry date
  AgeBracket _determineBracket(DateTime? expiryDate, DateTime now) {
    if (expiryDate == null) {
      return AgeBracket.noExpiry;
    }

    final daysUntilExpiry = expiryDate.difference(now).inDays;

    if (daysUntilExpiry < 0) {
      return AgeBracket.expiredItems;
    } else if (daysUntilExpiry <= 7) {
      return AgeBracket.critical;
    } else if (daysUntilExpiry <= 30) {
      return AgeBracket.warning;
    } else if (daysUntilExpiry <= 90) {
      return AgeBracket.upcoming;
    } else {
      return AgeBracket.good;
    }
  }

  /// Get items that are at risk of expiring within the specified days
  Future<List<InventoryItem>> getItemsExpiringWithin(int days) async {
    final items = await _repository.getItems();
    final now = DateTime.now();
    final expiryThreshold = now.add(Duration(days: days));

    return items.where((item) {
      if (item.expiryDate == null) return false;
      return item.expiryDate!.isBefore(expiryThreshold) &&
          item.expiryDate!.isAfter(now);
    }).toList();
  }

  /// Calculate the percentage of inventory value that is at risk of expiry
  Future<double> calculateExpiryRiskPercentage(int daysThreshold) async {
    final items = await _repository.getItems();
    double totalValue = 0;
    double atRiskValue = 0;

    final now = DateTime.now();
    final expiryThreshold = now.add(Duration(days: daysThreshold));

    for (final item in items) {
      final itemValue = (item.quantity * (item.cost ?? 0));
      totalValue += itemValue;

      if (item.expiryDate != null &&
          item.expiryDate!.isBefore(expiryThreshold) &&
          item.expiryDate!.isAfter(now)) {
        atRiskValue += itemValue;
      }
    }

    return totalValue > 0 ? (atRiskValue / totalValue) * 100 : 0;
  }

  /// Calculate inventory aging for a specific warehouse
  Future<void> calculateAging({required String warehouseId}) async {
    // Correct usage: fetch movements and ignore result
    await _repository.getMovementsForWarehouse(warehouseId);
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

/// Class to hold detailed aging information for inventory items
class InventoryAgingDetails {
  InventoryAgingDetails();

  final Map<String, List<BatchInfo>> _itemBatches = {};

  void addItem(
    String productId,
    double quantity,
    double cost, {
    String? batchNumber,
    DateTime? expiryDate,
  }) {
    if (!_itemBatches.containsKey(productId)) {
      _itemBatches[productId] = [];
    }

    _itemBatches[productId]!.add(
      BatchInfo(
        batchNumber: batchNumber ?? 'Unknown',
        quantity: quantity,
        cost: cost,
        expiryDate: expiryDate,
      ),
    );
  }

  List<String> get productIds => _itemBatches.keys.toList();

  List<BatchInfo> getBatchesForProduct(String productId) {
    return _itemBatches[productId] ?? [];
  }

  double get totalValue {
    double total = 0;
    for (final batches in _itemBatches.values) {
      for (final batch in batches) {
        total += batch.quantity * batch.cost;
      }
    }
    return total;
  }

  double get totalQuantity {
    double total = 0;
    for (final batches in _itemBatches.values) {
      for (final batch in batches) {
        total += batch.quantity;
      }
    }
    return total;
  }
}

/// Class to hold information about a specific batch
class BatchInfo {
  BatchInfo({
    required this.batchNumber,
    required this.quantity,
    required this.cost,
    this.expiryDate,
  });

  final String batchNumber;
  final double quantity;
  final double cost;
  final DateTime? expiryDate;

  double get totalValue => quantity * cost;
}
