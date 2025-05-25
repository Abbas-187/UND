import 'package:flutter/foundation.dart';

/// Repository for getting supplier lead time information
abstract class SupplierLeadTimeRepository {
  /// Get lead time information for a specific supplier and item
  /// Returns a map with averageLeadTimeDays, leadTimeVariability, and maxLeadTimeDays
  Future<Map<String, double>> getLeadTimeInfo({
    required String supplierId,
    required String itemId,
  });

  /// Get the default lead time information for an item based on historical data
  /// across all suppliers, used when supplier-specific data is not available
  Future<Map<String, double>> getDefaultLeadTimeInfo({
    required String itemId,
  });

  /// Store actual lead time information after goods are received
  /// This helps build more accurate data over time
  Future<void> recordActualLeadTime({
    required String supplierId,
    required String itemId,
    required double actualLeadTimeDays,
    @required String? purchaseOrderId,
  });
}
