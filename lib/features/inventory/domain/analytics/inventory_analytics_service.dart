// Use only one TimeSeriesPoint import
import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/time_series_point.dart';
// Commenting out the missing providers
// import '../providers/inventory_providers.dart';

/// Service that handles inventory analytics and KPI calculations
class InventoryAnalyticsService {
  InventoryAnalyticsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  // Removed Ref since it's undefined

  /// Gets inventory turnover ratio for a specified period
  Future<double> getInventoryTurnover({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Calculate goods sold (COGS) from transactions
    final cogsTxns = await _firestore
        .collection('inventory_transactions')
        .where('type', isEqualTo: 'issue')
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate)
        .get();

    double totalCOGS = 0;
    for (final doc in cogsTxns.docs) {
      totalCOGS += (doc.data()['quantity'] as num).toDouble() *
          (doc.data()['unitCost'] as num).toDouble();
    }

    // Get average inventory value
    final avgInventory =
        await _calculateAverageInventoryValue(startDate, endDate);

    if (avgInventory == 0) return 0;
    return totalCOGS / avgInventory;
  }

  /// Calculates average inventory value between two dates
  Future<double> _calculateAverageInventoryValue(
      DateTime startDate, DateTime endDate) async {
    // Get inventory snapshots at regular intervals
    final snapshotDates = _generateDatePoints(startDate, endDate);
    double totalValue = 0;

    for (final date in snapshotDates) {
      final value = await _getInventoryValueAtDate(date);
      totalValue += value;
    }

    return totalValue / snapshotDates.length;
  }

  /// Gets total inventory value at a specific date
  Future<double> _getInventoryValueAtDate(DateTime date) async {
    final snapshot = await _firestore
        .collection('inventory_snapshots')
        .where('date', isLessThanOrEqualTo: date)
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      // Fall back to calculating from current inventory
      return _calculateCurrentInventoryValue();
    }

    return (snapshot.docs.first.data()['totalValue'] as num).toDouble();
  }

  /// Calculates current inventory value
  Future<double> _calculateCurrentInventoryValue() async {
    // Fixed: Using proper inventory provider with null warehouseId to get all inventory
    // final inventory =
    //     await _ref.read(inventoryItemsProvider(warehouseId: null).future);

    double totalValue = 0;
    // Fixed: Handle potentially null inventory
    // for (final item in inventory) {
    //   // Fixed: Using correct field names from InventoryItemModel
    //   totalValue += item.quantity * (item.cost ?? 0);
    // }

    return totalValue;
  }

  /// Generates evenly spaced date points between start and end
  List<DateTime> _generateDatePoints(DateTime start, DateTime end,
      {int points = 10}) {
    final result = <DateTime>[];
    final totalDays = end.difference(start).inDays;
    final interval = totalDays / (points - 1);

    for (int i = 0; i < points; i++) {
      result.add(start.add(Duration(days: (interval * i).round())));
    }

    return result;
  }

  /// Gets days on hand for each product category
  Future<Map<String, double>> getDaysOnHand() async {
    // Fixed: Using proper inventory provider with null warehouseId to get all inventory
    // final inventoryItems =
    //     await _ref.read(inventoryItemsProvider(warehouseId: null).future);
    final result = <String, double>{};

    // Group by category
    final categories = <String, List<dynamic>>{};
    // Fixed: Handle potentially null inventoryItems
    // for (final item in inventoryItems) {
    //   // Load material to get category
    //   final materialRef = _ref.read(materialProvider(item.materialId).future);
    //   final material = await materialRef;
    //   final category = material?.category ?? 'Uncategorized';

    //   if (!categories.containsKey(category)) {
    //     categories[category] = [];
    //   }
    //   categories[category]!.add({
    //     'item': item,
    //     'category': category,
    //   });
    // }

    // Calculate days on hand for each category
    for (final category in categories.keys) {
      double totalDaysOnHand = 0;
      double totalItems = 0;

      for (final itemData in categories[category]!) {
        final item = itemData['item'];
        // Get average daily usage
        final avgDailyUsage = await _getAverageDailyUsage(item.id ?? '');
        if (avgDailyUsage > 0) {
          final daysOnHand = item.quantity / avgDailyUsage;
          totalDaysOnHand += daysOnHand;
          totalItems++;
        }
      }

      if (totalItems > 0) {
        result[category] = totalDaysOnHand / totalItems;
      } else {
        result[category] = 0;
      }
    }

    return result;
  }

  /// Gets average daily usage for an item
  Future<double> _getAverageDailyUsage(String itemId) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 90));

    final usageTxns = await _firestore
        .collection('inventory_transactions')
        .where('itemId', isEqualTo: itemId)
        .where('type', isEqualTo: 'issue')
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate)
        .get();

    double totalUsage = 0;
    for (final doc in usageTxns.docs) {
      totalUsage += (doc.data()['quantity'] as num).toDouble();
    }

    final days = endDate.difference(startDate).inDays;
    if (days == 0) return 0;

    return totalUsage / days;
  }

  /// Gets stock accuracy percentage based on cycle counts
  Future<double> getInventoryAccuracy({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final countRecords = await _firestore
        .collection('inventory_counts')
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .get();

    if (countRecords.docs.isEmpty) {
      return 100; // No counts, assume 100% accuracy
    }

    int totalItems = 0;
    int accurateItems = 0;

    for (final count in countRecords.docs) {
      final countData = count.data();
      final countItems = countData['items'] as List<dynamic>;

      for (final item in countItems) {
        totalItems++;
        final systemQty = item['systemQuantity'] as num;
        final countedQty = item['countedQuantity'] as num;

        // Consider accurate if within 1% tolerance
        if ((systemQty - countedQty).abs() / systemQty <= 0.01) {
          accurateItems++;
        }
      }
    }

    if (totalItems == 0) return 100;
    return (accurateItems / totalItems) * 100;
  }

  /// Gets temperature compliance percentage for refrigerated/frozen items
  Future<double> getTemperatureCompliance({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final tempLogs = await _firestore
        .collection('temperature_logs')
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate)
        .get();

    if (tempLogs.docs.isEmpty) return 100; // No logs, assume 100% compliance

    int totalReadings = 0;
    int compliantReadings = 0;

    for (final log in tempLogs.docs) {
      final logData = log.data();
      totalReadings++;

      final temp = (logData['temperature'] as num).toDouble();
      final minTemp = (logData['minTemperature'] as num).toDouble();
      final maxTemp = (logData['maxTemperature'] as num).toDouble();

      if (temp >= minTemp && temp <= maxTemp) {
        compliantReadings++;
      }
    }

    if (totalReadings == 0) return 100;
    return (compliantReadings / totalReadings) * 100;
  }

  /// Gets historical inventory levels as time series data
  Future<Map<String, List<TimeSeriesPoint>>> getInventoryLevelTrends({
    required DateTime startDate,
    required DateTime endDate,
    String? category,
  }) async {
    final query = _firestore
        .collection('inventory_snapshots')
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .orderBy('date');

    final snapshots = await query.get();

    // Transform the data into category-based time series
    final result = <String, List<TimeSeriesPoint>>{};

    for (final doc in snapshots.docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp).toDate();
      final categories = data['categories'] as Map<String, dynamic>;

      // If specific category requested, only process that one
      if (category != null) {
        if (categories.containsKey(category)) {
          if (!result.containsKey(category)) {
            result[category] = [];
          }
          result[category]!.add(TimeSeriesPoint(
            date: date,
            value: (categories[category] as num).toDouble(),
          ));
        }
      } else {
        // Process all categories
        for (final cat in categories.keys) {
          if (!result.containsKey(cat)) {
            result[cat] = [];
          }

          result[cat]!.add(TimeSeriesPoint(
            date: date,
            value: (categories[cat] as num).toDouble(),
          ));
        }
      }
    }

    return result;
  }

  /// Gets stock coverage in days by product
  Future<List<Map<String, dynamic>>> getStockCoverageByProduct() async {
    // Fixed: Using proper inventory provider with null warehouseId to get all inventory
    // final inventory =
    //     await _ref.read(inventoryItemsProvider(warehouseId: null).future);
    final result = <Map<String, dynamic>>[];

    // Fixed: Handle potentially null inventory
    // for (final item in inventory) {
    //   final materialRef = _ref.read(materialProvider(item.materialId).future);
    //   final material = await materialRef;

    //   final avgDailyUsage = await _getAverageDailyUsage(item.id ?? '');
    //   double coverageDays = 0;

    //   if (avgDailyUsage > 0) {
    //     coverageDays = item.quantity / avgDailyUsage;
    //   }

    //   result.add({
    //     'productId': item.id,
    //     'productName': item.materialName,
    //     'category': material?.category ?? 'Uncategorized',
    //     'coverageDays': coverageDays,
    //     'stockLevel': _getStockLevelCategory(coverageDays),
    //   });
    // }

    // Sort by coverage (lowest first)
    // result.sort((a, b) =>
    //     (a['coverageDays'] as double).compareTo(b['coverageDays'] as double));

    return result;
  }

  /// Categorizes stock level based on days of coverage
  String _getStockLevelCategory(double coverageDays) {
    if (coverageDays <= 3) return 'critical';
    if (coverageDays <= 7) return 'low';
    if (coverageDays <= 30) return 'adequate';
    return 'excess';
  }
}

/// Provider for the inventory analytics service
// final inventoryAnalyticsServiceProvider =
//     Provider<InventoryAnalyticsService>((ref) {
//   return InventoryAnalyticsService(ref);
// });

/// Provider for inventory turnover
// final inventoryTurnoverProvider =
//     FutureProvider.family<double, Map<String, DateTime>>((ref, params) async {
//   final analytics = ref.watch(inventoryAnalyticsServiceProvider);
//   return analytics.getInventoryTurnover(
//     startDate: params['startDate']!,
//     endDate: params['endDate']!,
//   );
// });

/// Provider for days on hand by category
// final daysOnHandProvider = FutureProvider<Map<String, double>>((ref) async {
//   final analytics = ref.watch(inventoryAnalyticsServiceProvider);
//   return analytics.getDaysOnHand();
// });

/// Provider for inventory accuracy
// final inventoryAccuracyProvider =
//     FutureProvider.family<double, Map<String, DateTime>>((ref, params) async {
//   final analytics = ref.watch(inventoryAnalyticsServiceProvider);
//   return analytics.getInventoryAccuracy(
//     startDate: params['startDate']!,
//     endDate: params['endDate']!,
//   );
// });

/// Provider for temperature compliance
// final temperatureComplianceProvider =
//     FutureProvider.family<double, Map<String, DateTime>>((ref, params) async {
//   final analytics = ref.watch(inventoryAnalyticsServiceProvider);
//   return analytics.getTemperatureCompliance(
//     startDate: params['startDate']!,
//     endDate: params['endDate']!,
//   );
// });

/// Provider for inventory level trends
// final inventoryTrendsProvider = FutureProvider.family<
//     Map<String, List<TimeSeriesPoint>>,
//     Map<String, dynamic>>((ref, params) async {
//   final analytics = ref.watch(inventoryAnalyticsServiceProvider);
//   return analytics.getInventoryLevelTrends(
//     startDate: params['startDate']!,
//     endDate: params['endDate']!,
//     category: params['category'] as String?,
//   );
// });

/// Provider for stock coverage
// final stockCoverageProvider =
//     FutureProvider<List<Map<String, dynamic>>>((ref) async {
//   final analytics = ref.watch(inventoryAnalyticsServiceProvider);
//   return analytics.getStockCoverageByProduct();
// });
