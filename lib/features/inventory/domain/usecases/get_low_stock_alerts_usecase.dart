import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../procurement/domain/notifications/procurement_notification_service_provider.dart';
import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class LowStockAlert {
  LowStockAlert({
    required this.item,
    required this.alertType,
    required this.message,
    required this.timestamp,
    this.severity,
  });
  final InventoryItem item;
  final String alertType;
  final String message;
  final DateTime timestamp;
  final String? severity;
}

class GetLowStockAlertsUseCase {
  GetLowStockAlertsUseCase(this.repository, this.ref);
  final InventoryRepository repository;
  final Ref ref;

  /// Configurable expiry warning thresholds in days
  static const int criticalExpiryThreshold = 7;
  static const int warningExpiryThreshold = 30;
  static const int upcomingExpiryThreshold = 90;

  Future<List<LowStockAlert>> execute() async {
    final alerts = <LowStockAlert>[];

    // Get items with low stock
    final lowStockItems = await repository.getLowStockItems();
    for (final item in lowStockItems) {
      alerts.add(
        LowStockAlert(
          item: item,
          alertType: 'LOW_STOCK',
          message:
              'Item ${item.name} is below minimum quantity (${item.quantity} ${item.unit} remaining)',
          timestamp: DateTime.now(),
        ),
      );
    }

    // Get items needing reorder
    final reorderItems = await repository.getItemsNeedingReorder();
    for (final item in reorderItems) {
      alerts.add(
        LowStockAlert(
          item: item,
          alertType: 'REORDER_NEEDED',
          message:
              'Item ${item.name} needs to be reordered (${item.quantity} ${item.unit} remaining)',
          timestamp: DateTime.now(),
        ),
      );
      // --- Procurement notification integration ---
      final procurementNotifier =
          ref.read(procurementNotificationServiceProvider);
      await procurementNotifier.notifyReorderPointReached(
        itemId: item.id,
        itemName: item.name,
        currentQuantity: item.quantity,
        reorderPoint: item.reorderPoint,
        safetyStock:
            (item.additionalAttributes?['safetyStock'] as double?) ?? 0,
        preferredSupplierId:
            item.additionalAttributes?['preferredSupplierId'] as String?,
        suggestedReorderQuantity: (item.reorderPoint +
                ((item.additionalAttributes?['safetyStock'] as double?) ?? 0)) -
            item.quantity,
        unit: item.unit,
        extra: item.additionalAttributes,
      );
    }

    // Get expiring items with more detailed categorization
    final now = DateTime.now();

    // Critical - expiring within 7 days
    final criticalExpiryItems = await repository.getExpiringItems(
      now.add(const Duration(days: 7)),
    );
    for (final item in criticalExpiryItems) {
      if (item.expiryDate != null) {
        final daysUntilExpiry = item.expiryDate!.difference(now).inDays;
        if (daysUntilExpiry >= 0) {
          // Only include non-expired items
          alerts.add(
            LowStockAlert(
              item: item,
              alertType: 'CRITICAL_EXPIRY',
              message:
                  'URGENT: Item ${item.name} will expire in $daysUntilExpiry days',
              timestamp: DateTime.now(),
            ),
          );
        }
      }
    }

    // Warning - expiring within 30 days
    final warningExpiryItems = await repository.getExpiringItems(
      now.add(const Duration(days: 30)),
    );
    for (final item in warningExpiryItems) {
      if (item.expiryDate != null) {
        final daysUntilExpiry = item.expiryDate!.difference(now).inDays;
        // Only include items that expire between 8-30 days
        if (daysUntilExpiry > 7 && daysUntilExpiry <= 30) {
          alerts.add(
            LowStockAlert(
              item: item,
              alertType: 'WARNING_EXPIRY',
              message: 'Item ${item.name} will expire in $daysUntilExpiry days',
              timestamp: DateTime.now(),
            ),
          );
        }
      }
    }

    // Already expired items
    final expiredItems = await repository.getExpiringItems(now);
    for (final item in expiredItems) {
      if (item.expiryDate != null && item.expiryDate!.isBefore(now)) {
        final daysSinceExpiry = now.difference(item.expiryDate!).inDays;
        alerts.add(
          LowStockAlert(
            item: item,
            alertType: 'EXPIRED',
            message: 'Item ${item.name} expired $daysSinceExpiry days ago',
            timestamp: DateTime.now(),
            severity: 'high',
          ),
        );
      }
    }

    // Sort alerts by timestamp
    alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return alerts;
  }

  Stream<List<LowStockAlert>> watchAlerts() {
    return repository.watchAllItems().map((items) {
      final alerts = <LowStockAlert>[];
      final now = DateTime.now();
      for (final item in items) {
        // Use dynamic reorder point and supplier data if available
        final dynamicRop =
            (item.additionalAttributes?['dynamicReorderPoint'] as double?) ??
                item.reorderPoint;
        final safetyStock =
            (item.additionalAttributes?['safetyStock'] as double?) ?? 0;
        final preferredSupplier =
            item.additionalAttributes?['preferredSupplierId'] as String? ??
                item.supplier;
        final reorderThreshold = dynamicRop;
        final needsReorder = item.quantity <= reorderThreshold;
        final isLowStock = item.quantity <= item.minimumQuantity;

        if (isLowStock) {
          alerts.add(
            LowStockAlert(
              item: item,
              alertType: 'LOW_STOCK',
              message:
                  'Item ${item.name} is below minimum (${item.quantity} ${item.unit} remaining, min: ${item.minimumQuantity}).',
              timestamp: now,
              severity: 'medium',
            ),
          );
        }
        if (needsReorder) {
          final suggestedQty = (dynamicRop + safetyStock) - item.quantity;
          alerts.add(
            LowStockAlert(
              item: item,
              alertType: 'REORDER_NEEDED',
              message:
                  'Item ${item.name} needs reorder: ${item.quantity} ${item.unit} (ROP: $dynamicRop, Safety Stock: $safetyStock, Preferred Supplier: ${preferredSupplier ?? "N/A"}, Suggested Qty: ${suggestedQty > 0 ? suggestedQty.toStringAsFixed(2) : "0"})',
              timestamp: now,
              severity: 'medium',
            ),
          );
        }
        if (item.expiryDate != null) {
          if (item.expiryDate!.isBefore(now)) {
            // Already expired
            final daysSinceExpiry = now.difference(item.expiryDate!).inDays;
            alerts.add(
              LowStockAlert(
                item: item,
                alertType: 'EXPIRED',
                message: 'Item ${item.name} expired $daysSinceExpiry days ago',
                timestamp: now,
                severity: 'high',
              ),
            );
          } else {
            final daysUntilExpiry = item.expiryDate!.difference(now).inDays;
            if (daysUntilExpiry <= criticalExpiryThreshold) {
              // Critical - expiring soon (within 7 days)
              alerts.add(
                LowStockAlert(
                  item: item,
                  alertType: 'CRITICAL_EXPIRY',
                  message:
                      'URGENT: Item ${item.name} will expire in $daysUntilExpiry days',
                  timestamp: now,
                  severity: 'high',
                ),
              );
            } else if (daysUntilExpiry <= warningExpiryThreshold) {
              // Warning - expiring within 30 days
              alerts.add(
                LowStockAlert(
                  item: item,
                  alertType: 'WARNING_EXPIRY',
                  message:
                      'Item ${item.name} will expire in $daysUntilExpiry days',
                  timestamp: now,
                  severity: 'medium',
                ),
              );
            } else if (daysUntilExpiry <= upcomingExpiryThreshold) {
              // Upcoming - expiring within 90 days
              alerts.add(
                LowStockAlert(
                  item: item,
                  alertType: 'UPCOMING_EXPIRY',
                  message:
                      'Item ${item.name} will expire in $daysUntilExpiry days',
                  timestamp: now,
                  severity: 'low',
                ),
              );
            }
          }
        }
      }

      // Sort alerts by severity and timestamp
      alerts.sort((a, b) {
        // First by severity (high, medium, low)
        if (a.severity != b.severity) {
          if (a.severity == 'high') return -1;
          if (b.severity == 'high') return 1;
          if (a.severity == 'medium') return -1;
          if (b.severity == 'medium') return 1;
        }
        // Then by timestamp (most recent first)
        return b.timestamp.compareTo(a.timestamp);
      });

      return alerts;
    });
  }
}
