import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/inventory_alert.dart';
import '../usecases/get_low_stock_alerts_usecase.dart';
import 'inventory_repository_provider.dart';

/// Provider for the GetLowStockAlertsUseCase
final getAlertsUseCaseProvider = Provider<GetLowStockAlertsUseCase>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return GetLowStockAlertsUseCase(repo);
});

/// Stream provider for all inventory alerts (low stock, reorder, expiring, expired)
final inventoryAlertsStreamProvider =
    StreamProvider.autoDispose<List<InventoryAlert>>((ref) {
  final useCase = ref.watch(getAlertsUseCaseProvider);
  return useCase.watchAlerts().map((lowAlerts) {
    return lowAlerts.map((low) {
      // Map string alertType to enum
      final type = switch (low.alertType) {
        'LOW_STOCK' => AlertType.lowStock,
        'REORDER_NEEDED' => AlertType.lowStock,
        'EXPIRED' => AlertType.expired,
        'EXPIRING_SOON' => AlertType.expiringSoon,
        _ => AlertType.lowStock,
      };
      // Determine severity
      final severity = switch (low.alertType) {
        'EXPIRED' => AlertSeverity.high,
        'EXPIRING_SOON' => AlertSeverity.medium,
        'REORDER_NEEDED' => AlertSeverity.low,
        'LOW_STOCK' => AlertSeverity.medium,
        _ => AlertSeverity.low,
      };
      // Generate a unique ID for the alert
      final id =
          '${low.item.id}-${low.alertType}-${low.timestamp.toIso8601String()}';
      return InventoryAlert(
        id: id,
        itemId: low.item.id,
        itemName: low.item.name,
        alertType: type,
        message: low.message,
        severity: severity,
        timestamp: low.timestamp,
      );
    }).toList();
  });
});
