import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class LowStockAlert {
  LowStockAlert({
    required this.item,
    required this.alertType,
    required this.message,
    required this.timestamp,
  });
  final InventoryItem item;
  final String alertType;
  final String message;
  final DateTime timestamp;
}

class GetLowStockAlertsUseCase {
  GetLowStockAlertsUseCase(this.repository);
  final InventoryRepository repository;

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
    }

    // Get expiring items (within next 30 days)
    final expiringItems = await repository.getExpiringItems(
      DateTime.now().add(const Duration(days: 30)),
    );
    for (final item in expiringItems) {
      if (item.expiryDate != null) {
        final daysUntilExpiry =
            item.expiryDate!.difference(DateTime.now()).inDays;
        alerts.add(
          LowStockAlert(
            item: item,
            alertType: 'EXPIRING_SOON',
            message: 'Item ${item.name} will expire in $daysUntilExpiry days',
            timestamp: DateTime.now(),
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
        if (item.isLowStock) {
          alerts.add(
            LowStockAlert(
              item: item,
              alertType: 'LOW_STOCK',
              message:
                  'Item ${item.name} is below minimum quantity (${item.quantity} ${item.unit} remaining)',
              timestamp: now,
            ),
          );
        }
        if (item.needsReorder) {
          alerts.add(
            LowStockAlert(
              item: item,
              alertType: 'REORDER_NEEDED',
              message:
                  'Item ${item.name} needs to be reordered (${item.quantity} ${item.unit} remaining)',
              timestamp: now,
            ),
          );
        }
        if (item.expiryDate != null) {
          if (item.expiryDate!.isBefore(now)) {
            alerts.add(
              LowStockAlert(
                item: item,
                alertType: 'EXPIRED',
                message: 'Item ${item.name} has expired',
                timestamp: now,
              ),
            );
          } else if (item.expiryDate!.difference(now).inDays <= 30) {
            final days = item.expiryDate!.difference(now).inDays;
            alerts.add(
              LowStockAlert(
                item: item,
                alertType: 'EXPIRING_SOON',
                message: 'Item ${item.name} will expire in $days days',
                timestamp: now,
              ),
            );
          }
        }
      }

      // Sort alerts by timestamp
      alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return alerts;
    });
  }
}
