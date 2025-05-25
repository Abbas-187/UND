import '../entities/inventory_alert.dart';
import '../entities/reservation.dart';

class BomAvailabilityService {
  // Calculate availability percentage for a BOM batch
  Future<double> calculateAvailabilityPercentage(
    String bomId,
    double batchSize,
  ) async {
    final bomItems = await _getBomItems(bomId);
    if (bomItems.isEmpty) return 0.0;

    double totalAvailabilityScore = 0.0;

    for (final item in bomItems) {
      final requiredQuantity = item.quantity * batchSize;
      final availableStock = await _getAvailableStock(item.itemId);
      final reservedQuantity = await _getReservedQuantity(item.itemId);
      final effectiveAvailable = availableStock - reservedQuantity;

      final itemAvailability = effectiveAvailable >= requiredQuantity
          ? 1.0
          : (effectiveAvailable / requiredQuantity).clamp(0.0, 1.0);

      totalAvailabilityScore += itemAvailability;
    }

    return (totalAvailabilityScore / bomItems.length * 100).clamp(0.0, 100.0);
  }

  // Predict when shortage will be resolved
  Future<DateTime?> predictResolutionDate(
    String itemId,
    double shortageQuantity,
  ) async {
    // Check incoming purchase orders
    final incomingPOs = await _getIncomingPurchaseOrders(itemId);
    double cumulativeIncoming = 0.0;

    for (final po in incomingPOs) {
      cumulativeIncoming += po.quantity;
      if (cumulativeIncoming >= shortageQuantity) {
        return po.expectedDeliveryDate;
      }
    }

    // Check production orders that will produce this item
    final incomingProduction = await _getIncomingProduction(itemId);
    for (final production in incomingProduction) {
      cumulativeIncoming += production.quantity;
      if (cumulativeIncoming >= shortageQuantity) {
        return production.expectedCompletionDate;
      }
    }

    // If no incoming supply, estimate based on average lead time
    final avgLeadTime = await _getAverageLeadTime(itemId);
    if (avgLeadTime != null) {
      return DateTime.now().add(Duration(days: avgLeadTime));
    }

    return null; // Cannot predict resolution
  }

  // Generate suggested actions for shortage resolution
  Future<List<String>> generateSuggestedActions(
    String itemId,
    double shortageQuantity,
    String itemCode,
    String itemName,
  ) async {
    final suggestions = <String>[];

    // Check if item has alternatives
    final alternatives = await _getAlternativeItems(itemId);
    if (alternatives.isNotEmpty) {
      suggestions.add(
          'Consider alternative items: ${alternatives.take(3).join(", ")}');
    }

    // Check supplier availability
    final suppliers = await _getItemSuppliers(itemId);
    if (suppliers.isNotEmpty) {
      suggestions.add('Contact suppliers: ${suppliers.take(2).join(", ")}');
    }

    // Check if partial production is viable
    final availableStock = await _getAvailableStock(itemId);
    if (availableStock > 0) {
      final possibleBatches = (availableStock / shortageQuantity).floor();
      if (possibleBatches > 0) {
        suggestions.add(
            'Consider partial production: $possibleBatches smaller batches possible');
      }
    }

    // Check if item can be expedited
    final canExpedite = await _canExpediteItem(itemId);
    if (canExpedite) {
      suggestions.add('Request expedited delivery from supplier');
    }

    // Check if item is in other warehouses
    final warehouseStock = await _getMultiWarehouseStock(itemId);
    final otherWarehouses = warehouseStock.entries
        .where((entry) => entry.value > 0)
        .map((entry) => entry.key)
        .toList();
    if (otherWarehouses.isNotEmpty) {
      suggestions
          .add('Transfer from warehouses: ${otherWarehouses.join(", ")}');
    }

    // Default suggestions
    if (suggestions.isEmpty) {
      suggestions.addAll([
        'Create emergency purchase order',
        'Review BOM for possible substitutions',
        'Consider adjusting production schedule',
      ]);
    }

    return suggestions;
  }

  // Get alternative items for a given item
  Future<List<String>> getAlternativeItems(String itemId) async {
    return await _getAlternativeItems(itemId);
  }

  // Check availability across multiple warehouses
  Future<Map<String, double>> checkMultiWarehouseAvailability(
      String itemId) async {
    return await _getMultiWarehouseStock(itemId);
  }

  // Generate BOM-specific shortage alerts with enhanced information
  Future<List<InventoryAlert>> generateBomShortageAlerts(
    String bomId,
    double batchSize,
  ) async {
    final alerts = <InventoryAlert>[];
    final bomItems = await _getBomItems(bomId);

    for (final item in bomItems) {
      final requiredQuantity = item.quantity * batchSize;
      final availableStock = await _getAvailableStock(item.itemId);
      final reservedQuantity = await _getReservedQuantity(item.itemId);
      final effectiveAvailable = availableStock - reservedQuantity;

      if (effectiveAvailable < requiredQuantity) {
        final shortageQuantity = requiredQuantity - effectiveAvailable;
        final resolutionDate =
            await predictResolutionDate(item.itemId, shortageQuantity);
        final suggestedActions = await generateSuggestedActions(
          item.itemId,
          shortageQuantity,
          item.itemCode,
          item.itemName,
        );
        final alternatives = await getAlternativeItems(item.itemId);
        final warehouseStock =
            await checkMultiWarehouseAvailability(item.itemId);

        // Calculate confidence score based on data quality
        final confidenceScore = _calculateConfidenceScore(
          resolutionDate != null,
          suggestedActions.isNotEmpty,
          alternatives.isNotEmpty,
          warehouseStock.isNotEmpty,
        );

        alerts.add(InventoryAlert(
          id: _generateAlertId(),
          itemId: item.itemId,
          itemName: item.itemName,
          alertType: AlertType.lowStock,
          message:
              'Shortage for BOM $bomId: ${shortageQuantity.toStringAsFixed(2)} ${item.unit} needed',
          severity: _calculateSeverity(shortageQuantity, requiredQuantity),
          timestamp: DateTime.now(),
          isAcknowledged: false,
          // Enhanced fields from BOM Phase 2
          expectedResolutionDate: resolutionDate,
          suggestedActions: suggestedActions,
          alternativeItems: alternatives,
          warehouseStock: warehouseStock,
          confidenceScore: confidenceScore,
        ));
      }
    }

    return alerts;
  }

  // Predict future shortages based on consumption patterns
  Future<List<InventoryAlert>> predictFutureShortages(
    String bomId,
    double batchSize,
    int daysAhead,
  ) async {
    final alerts = <InventoryAlert>[];
    final bomItems = await _getBomItems(bomId);
    final futureDate = DateTime.now().add(Duration(days: daysAhead));

    for (final item in bomItems) {
      final requiredQuantity = item.quantity * batchSize;
      final currentStock = await _getAvailableStock(item.itemId);
      final avgDailyConsumption =
          await _getAverageDailyConsumption(item.itemId);

      if (avgDailyConsumption > 0) {
        final projectedStock = currentStock - (avgDailyConsumption * daysAhead);

        if (projectedStock < requiredQuantity) {
          final shortageQuantity = requiredQuantity - projectedStock;
          final suggestedActions = await generateSuggestedActions(
            item.itemId,
            shortageQuantity,
            item.itemCode,
            item.itemName,
          );

          alerts.add(InventoryAlert(
            id: _generateAlertId(),
            itemId: item.itemId,
            itemName: item.itemName,
            alertType: AlertType.lowStock,
            message:
                'Predicted shortage in $daysAhead days: ${shortageQuantity.toStringAsFixed(2)} ${item.unit}',
            severity: _calculateSeverity(shortageQuantity, requiredQuantity),
            timestamp: DateTime.now(),
            isAcknowledged: false,
            expectedResolutionDate: futureDate,
            suggestedActions: suggestedActions,
            confidenceScore:
                _calculatePredictionConfidence(avgDailyConsumption, daysAhead),
          ));
        }
      }
    }

    return alerts;
  }

  // Calculate batch/lot expiry impact on BOM availability
  Future<List<InventoryAlert>> checkBatchExpiryImpact(
    String bomId,
    double batchSize,
    int daysAhead,
  ) async {
    final alerts = <InventoryAlert>[];
    final bomItems = await _getBomItems(bomId);
    final cutoffDate = DateTime.now().add(Duration(days: daysAhead));

    for (final item in bomItems) {
      final requiredQuantity = item.quantity * batchSize;
      final expiringBatches =
          await _getExpiringBatches(item.itemId, cutoffDate);

      double expiringQuantity = 0.0;
      for (final batch in expiringBatches) {
        expiringQuantity += batch.quantity;
      }

      if (expiringQuantity >= requiredQuantity * 0.5) {
        // 50% threshold
        final suggestedActions = [
          'Use expiring batches first',
          'Consider accelerating production schedule',
          'Review batch rotation policy',
        ];

        alerts.add(InventoryAlert(
          id: _generateAlertId(),
          itemId: item.itemId,
          itemName: item.itemName,
          alertType: AlertType.expiringSoon,
          message:
              'Expiring batches may affect BOM availability: ${expiringQuantity.toStringAsFixed(2)} ${item.unit}',
          severity: AlertSeverity.medium,
          timestamp: DateTime.now(),
          isAcknowledged: false,
          suggestedActions: suggestedActions,
          confidenceScore: 0.9, // High confidence for expiry dates
        ));
      }
    }

    return alerts;
  }

  // Private helper methods
  double _calculateConfidenceScore(
    bool hasResolutionDate,
    bool hasSuggestions,
    bool hasAlternatives,
    bool hasWarehouseData,
  ) {
    double score = 0.4; // Base confidence
    if (hasResolutionDate) score += 0.3;
    if (hasSuggestions) score += 0.1;
    if (hasAlternatives) score += 0.1;
    if (hasWarehouseData) score += 0.1;
    return score.clamp(0.0, 1.0);
  }

  double _calculatePredictionConfidence(double avgConsumption, int daysAhead) {
    // Confidence decreases with prediction distance
    final baseConfidence = 0.8;
    final decayFactor = 0.02 * daysAhead; // 2% decay per day
    return (baseConfidence - decayFactor).clamp(0.1, 1.0);
  }

  AlertSeverity _calculateSeverity(
      double shortageQuantity, double requiredQuantity) {
    final shortagePercentage = (shortageQuantity / requiredQuantity) * 100;

    if (shortagePercentage >= 75) return AlertSeverity.high;
    if (shortagePercentage >= 50) return AlertSeverity.medium;
    return AlertSeverity.low;
  }

  String _generateAlertId() =>
      'BOM_ALERT_${DateTime.now().millisecondsSinceEpoch}';

  // Repository integration methods (to be implemented)
  Future<List<_BomItem>> _getBomItems(String bomId) async {
    throw UnimplementedError('BOM service integration needed');
  }

  Future<double> _getAvailableStock(String itemId) async {
    throw UnimplementedError('Inventory repository integration needed');
  }

  Future<double> _getReservedQuantity(String itemId) async {
    throw UnimplementedError('Reservation service integration needed');
  }

  Future<List<_IncomingPO>> _getIncomingPurchaseOrders(String itemId) async {
    throw UnimplementedError('Procurement service integration needed');
  }

  Future<List<_IncomingProduction>> _getIncomingProduction(
      String itemId) async {
    throw UnimplementedError('Production service integration needed');
  }

  Future<int?> _getAverageLeadTime(String itemId) async {
    throw UnimplementedError('Supplier service integration needed');
  }

  Future<List<String>> _getAlternativeItems(String itemId) async {
    throw UnimplementedError('Item master service integration needed');
  }

  Future<List<String>> _getItemSuppliers(String itemId) async {
    throw UnimplementedError('Supplier service integration needed');
  }

  Future<bool> _canExpediteItem(String itemId) async {
    throw UnimplementedError('Supplier service integration needed');
  }

  Future<Map<String, double>> _getMultiWarehouseStock(String itemId) async {
    throw UnimplementedError('Warehouse service integration needed');
  }

  Future<double> _getAverageDailyConsumption(String itemId) async {
    throw UnimplementedError('Analytics service integration needed');
  }

  Future<List<_ExpiringBatch>> _getExpiringBatches(
      String itemId, DateTime cutoffDate) async {
    throw UnimplementedError('Batch tracking service integration needed');
  }
}

// Helper classes
class _BomItem {
  final String itemId;
  final String itemCode;
  final String itemName;
  final double quantity;
  final String unit;

  _BomItem({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.quantity,
    required this.unit,
  });
}

class _IncomingPO {
  final double quantity;
  final DateTime expectedDeliveryDate;

  _IncomingPO({
    required this.quantity,
    required this.expectedDeliveryDate,
  });
}

class _IncomingProduction {
  final double quantity;
  final DateTime expectedCompletionDate;

  _IncomingProduction({
    required this.quantity,
    required this.expectedCompletionDate,
  });
}

class _ExpiringBatch {
  final String batchNumber;
  final double quantity;
  final DateTime expiryDate;

  _ExpiringBatch({
    required this.batchNumber,
    required this.quantity,
    required this.expiryDate,
  });
}
