// Utility functions for inventory/procurement reporting
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import '../../crm/models/customer.dart';
import '../../crm/models/interaction_log.dart';
import '../../crm/models/order.dart' as crm;
import '../../inventory/data/models/inventory_item_model.dart';

class ReportAggregators {
  ReportAggregators(this.firestore);
  final FirebaseFirestore firestore;

  /// Stock by item (for table/chart)
  Future<List<Map<String, dynamic>>> stockByItem() async {
    final inventorySnapshot =
        await firestore.collection('inventory_items').get();
    return inventorySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'name': data['name'] ?? '',
        'category': data['category'] ?? '',
        'quantity': data['quantity'] ?? 0.0,
        'unit': data['unit'] ?? '',
      };
    }).toList();
  }

  /// Stock by category (for chart)
  Future<List<Map<String, dynamic>>> stockByCategory() async {
    final inventorySnapshot =
        await firestore.collection('inventory_items').get();
    final items = inventorySnapshot.docs
        .map((doc) => InventoryItemModel.fromFirestore(doc))
        .toList();

    final grouped = groupBy(items, (InventoryItemModel i) => i.category);
    return grouped.entries
        .map((e) => {
              'category': e.key,
              'quantity': e.value.fold(0.0, (sum, i) => sum + (i.quantity)),
            })
        .toList();
  }

  /// Expiry status breakdown (for table/chart)
  Future<List<Map<String, dynamic>>> expiryStatus(
      {int expiringSoonDays = 7}) async {
    final inventorySnapshot =
        await firestore.collection('inventory_items').get();
    final items = inventorySnapshot.docs
        .map((doc) => InventoryItemModel.fromFirestore(doc))
        .toList();

    final now = DateTime.now();
    return items.map((item) {
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
  Future<Map<String, int>> expiryStatusCounts(
      {int expiringSoonDays = 7}) async {
    final statusList = await expiryStatus(expiringSoonDays: expiringSoonDays);
    final Map<String, int> counts = {};
    for (final row in statusList) {
      counts[row['status']] = (counts[row['status']] ?? 0) + 1;
    }
    return counts;
  }

  /// Valuation by item (for table/chart)
  Future<List<Map<String, dynamic>>> valuationByItem() async {
    final inventorySnapshot =
        await firestore.collection('inventory_items').get();
    final items = inventorySnapshot.docs
        .map((doc) => InventoryItemModel.fromFirestore(doc))
        .toList();

    return items
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
  Future<List<Map<String, dynamic>>> valuationByCategory() async {
    final inventorySnapshot =
        await firestore.collection('inventory_items').get();
    final items = inventorySnapshot.docs
        .map((doc) => InventoryItemModel.fromFirestore(doc))
        .toList();

    final grouped = groupBy(items, (InventoryItemModel i) => i.category);
    return grouped.entries
        .map((e) => {
              'category': e.key,
              'totalValue': e.value
                  .fold(0.0, (sum, i) => sum + (i.quantity * (i.cost ?? 0))),
            })
        .toList();
  }

  /// Movement breakdown by type (for chart)
  Future<Map<String, int>> movementCountByType() async {
    final movementsSnapshot =
        await firestore.collection('inventory_movements').get();
    final Map<String, int> counts = {};

    for (final doc in movementsSnapshot.docs) {
      final data = doc.data();
      final type = data['movementType'] ?? 'unknown';
      counts[type] = (counts[type] ?? 0) + 1;
    }

    return counts;
  }

  /// Movement breakdown by status (for chart)
  Future<Map<String, int>> movementCountByStatus() async {
    final movementsSnapshot =
        await firestore.collection('inventory_movements').get();
    final Map<String, int> counts = {};

    for (final doc in movementsSnapshot.docs) {
      final data = doc.data();
      final status = data['approvalStatus'] ?? 'unknown';
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return counts;
  }

  /// Movement breakdown by date (for chart)
  Future<Map<String, int>> movementCountByDate() async {
    final movementsSnapshot =
        await firestore.collection('inventory_movements').get();
    final Map<String, int> counts = {};

    for (final doc in movementsSnapshot.docs) {
      final data = doc.data();
      final timestamp = data['timestamp'] as Timestamp?;
      if (timestamp != null) {
        final date = timestamp.toDate().toIso8601String().substring(0, 10);
        counts[date] = (counts[date] ?? 0) + 1;
      }
    }

    return counts;
  }

  /// Movements table (for reporting)
  Future<List<Map<String, dynamic>>> movementTable() async {
    final movementsSnapshot =
        await firestore.collection('inventory_movements').get();
    final List<Map<String, dynamic>> result = [];

    for (final doc in movementsSnapshot.docs) {
      final data = doc.data();
      final items = data['items'] as List<dynamic>? ?? [];

      for (final item in items) {
        result.add({
          'movementId': data['movementId'] ?? '',
          'timestamp': data['timestamp'] != null
              ? (data['timestamp'] as Timestamp).toDate()
              : DateTime.now(),
          'type': data['movementType'] ?? '',
          'status': data['approvalStatus'] ?? '',
          'item': item['productName'] ?? '',
          'quantity': item['quantity'] ?? 0,
          'unit': item['unitOfMeasurement'] ?? '',
          'source': data['sourceLocationName'] ?? '',
          'destination': data['destinationLocationName'] ?? '',
        });
      }
    }

    return result;
  }
}

class CrmReportAggregator {
  CrmReportAggregator({
    required this.customers,
    required this.interactions,
    required this.orders,
  });
  final List<Customer> customers;
  final List<InteractionLog> interactions;
  final List<crm.Order> orders;

  /// Customer count by segment/tag
  Map<String, int> customerCountByTag() {
    final Map<String, int> tagCounts = {};
    for (final customer in customers) {
      for (final tag in customer.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
    return tagCounts;
  }

  /// Interactions per customer
  Map<String, int> interactionsPerCustomer() {
    final Map<String, int> counts = {};
    for (final log in interactions) {
      counts[log.customerId] = (counts[log.customerId] ?? 0) + 1;
    }
    return counts;
  }

  /// Orders per customer
  Map<String, int> ordersPerCustomer() {
    final Map<String, int> counts = {};
    for (final order in orders) {
      counts[order.customerId] = (counts[order.customerId] ?? 0) + 1;
    }
    return counts;
  }

  /// Customer growth over time (by month)
  Map<String, int> customerGrowthByMonth() {
    final Map<String, int> growth = {};
    for (final customer in customers) {
      final month =
          '${customer.createdAt.year}-${customer.createdAt.month.toString().padLeft(2, '0')}';
      growth[month] = (growth[month] ?? 0) + 1;
    }
    return growth;
  }
}
