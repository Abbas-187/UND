import 'package:flutter/material.dart';
import '../../entities/inventory_alert.dart';
import '../../../data/models/inventory_item_model.dart';

/// Service responsible for managing inventory alerts such as low stock and expiring items
class InventoryAlertsService {
  /// Check for low stock items
  List<InventoryAlert> checkLowStockItems(List<InventoryItemModel> items) {
    final alerts = <InventoryAlert>[];

    for (final item in items) {
      // Check if item quantity is below threshold
      if (item.quantity <= item.lowStockThreshold) {
        alerts.add(
          InventoryAlert(
            id: 'low-stock-${item.id}',
            itemId: item.id,
            itemName: item.name,
            alertType: AlertType.lowStock,
            message:
                'Low stock: ${item.quantity.toInt()} ${item.unit} remaining (below threshold of ${item.lowStockThreshold})',
            severity:
                _getSeverity(item.quantity.toInt(), item.lowStockThreshold),
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    return alerts;
  }

  /// Check for expired or soon-to-expire items
  List<InventoryAlert> checkExpiringItems(List<InventoryItemModel> items) {
    final alerts = <InventoryAlert>[];
    final now = DateTime.now();

    for (final item in items) {
      // Skip items without expiry date
      if (item.expiryDate == null) continue;

      final daysToExpiry = item.expiryDate!.difference(now).inDays;

      // Already expired
      if (daysToExpiry < 0) {
        alerts.add(
          InventoryAlert(
            id: 'expired-${item.id}',
            itemId: item.id,
            itemName: item.name,
            alertType: AlertType.expired,
            message: 'Item expired on ${_formatDate(item.expiryDate!)}',
            severity: AlertSeverity.high,
            timestamp: DateTime.now(),
          ),
        );
      }
      // Expiring soon (within 30 days)
      else if (daysToExpiry <= 30) {
        final severity = daysToExpiry <= 7
            ? AlertSeverity.high
            : daysToExpiry <= 14
                ? AlertSeverity.medium
                : AlertSeverity.low;

        alerts.add(
          InventoryAlert(
            id: 'expiring-soon-${item.id}',
            itemId: item.id,
            itemName: item.name,
            alertType: AlertType.expiringSoon,
            message:
                'Expiring in $daysToExpiry days (${_formatDate(item.expiryDate!)})',
            severity: severity,
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    return alerts;
  }

  /// Get all inventory alerts
  List<InventoryAlert> getAllAlerts(List<InventoryItemModel> items) {
    final lowStockAlerts = checkLowStockItems(items);
    final expiringAlerts = checkExpiringItems(items);

    // Combine all alerts and sort by severity (high to low)
    final allAlerts = [...lowStockAlerts, ...expiringAlerts];
    allAlerts.sort((a, b) => b.severity.index.compareTo(a.severity.index));

    return allAlerts;
  }

  /// Determine alert severity based on current quantity vs threshold
  AlertSeverity _getSeverity(int quantity, int threshold) {
    if (quantity <= 0) {
      return AlertSeverity.high;
    } else if (quantity <= threshold * 0.5) {
      return AlertSeverity.medium;
    } else {
      return AlertSeverity.low;
    }
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get the color associated with an alert severity
  Color getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.high:
        return Colors.red;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.low:
        return Colors.blue;
    }
  }

  /// Get the icon associated with an alert type
  IconData getAlertTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.lowStock:
        return Icons.inventory_2;
      case AlertType.expired:
        return Icons.warning_amber;
      case AlertType.expiringSoon:
        return Icons.access_time;
    }
  }
}
