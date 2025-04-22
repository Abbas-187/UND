// Utility functions for inventory/procurement reporting
import 'package:collection/collection.dart';
import '../../../core/services/mock_data_service.dart';
import '../../inventory/data/models/inventory_item_model.dart';
import '../../inventory/data/models/inventory_movement_model.dart';

class ReportAggregators {
  final MockDataService dataService;
  ReportAggregators(this.dataService);

  /// Stock by item (for table/chart)
  List<Map<String, dynamic>> stockByItem() {
    return dataService.inventoryItems
        .map((item) => {
              'name': item.name,
              'category': item.category,
              'quantity': item.quantity,
              'unit': item.unit,
            })
        .toList();
  }

  /// Stock by category (for chart)
  List<Map<String, dynamic>> stockByCategory() {
    final grouped = groupBy(
        dataService.inventoryItems, (InventoryItemModel i) => i.category);
    return grouped.entries
        .map((e) => {
              'category': e.key,
              'quantity': e.value.fold(0.0, (sum, i) => sum + i.quantity),
            })
        .toList();
  }

  /// Expiry status breakdown (for table/chart)
  List<Map<String, dynamic>> expiryStatus({int expiringSoonDays = 7}) {
    final now = DateTime.now();
    return dataService.inventoryItems.map((item) {
      String status;
      if (item.expiryDate == null) {
        status = 'no_expiry';
      } else if (item.expiryDate!.isBefore(now)) {
        status = 'expired';
      } else if (item.expiryDate!.difference(now).inDays <= expiringSoonDays) {
        status = 'expiring_soon';
      } else {
        status = 'safe';
      }
      return {
        'name': item.name,
        'expiryDate': item.expiryDate,
        'status': status,
      };
    }).toList();
  }

  /// Expiry status pie chart data
  Map<String, int> expiryStatusCounts({int expiringSoonDays = 7}) {
    final statusList = expiryStatus(expiringSoonDays: expiringSoonDays);
    final Map<String, int> counts = {};
    for (final row in statusList) {
      counts[row['status']] = (counts[row['status']] ?? 0) + 1;
    }
    return counts;
  }

  /// Valuation by item (for table/chart)
  List<Map<String, dynamic>> valuationByItem() {
    return dataService.inventoryItems
        .where((item) => item.cost != null)
        .map((item) => {
              'name': item.name,
              'category': item.category,
              'quantity': item.quantity,
              'unit': item.unit,
              'unitCost': item.cost,
              'totalValue': item.quantity * (item.cost ?? 0),
            })
        .toList();
  }

  /// Valuation by category (for chart)
  List<Map<String, dynamic>> valuationByCategory() {
    final grouped = groupBy(
        dataService.inventoryItems, (InventoryItemModel i) => i.category);
    return grouped.entries
        .map((e) => {
              'category': e.key,
              'totalValue': e.value
                  .fold(0.0, (sum, i) => sum + (i.quantity * (i.cost ?? 0))),
            })
        .toList();
  }

  /// Movement breakdown by type (for chart)
  Map<String, int> movementCountByType() =>
      dataService.getMovementCountByType();

  /// Movement breakdown by status (for chart)
  Map<String, int> movementCountByStatus() =>
      dataService.getMovementCountByStatus();

  /// Movement breakdown by date (for chart)
  Map<String, int> movementCountByDate() =>
      dataService.getMovementCountByDate();

  /// Movements table (for reporting)
  List<Map<String, dynamic>> movementTable() {
    return dataService.inventoryMovements
        .expand((mov) => mov.items.map((item) => {
              'movementId': mov.movementId,
              'timestamp': mov.timestamp,
              'type': mov.movementType.toString().split('.').last,
              'status': mov.approvalStatus.toString().split('.').last,
              'item': item.productName,
              'quantity': item.quantity,
              'unit': item.unitOfMeasurement,
              'source': mov.sourceLocationName,
              'destination': mov.destinationLocationName,
            }))
        .toList();
  }
}
