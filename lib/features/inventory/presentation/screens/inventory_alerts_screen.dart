import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/inventory_alert.dart';
import '../widgets/alerts/inventory_alerts_widget.dart';
import '../../../../l10n/app_localizations.dart';

/// Screen to display all inventory alerts
class InventoryAlertsScreen extends ConsumerWidget {
  const InventoryAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    // In a real app, this would come from a provider that fetches alerts
    // from a repository
    final mockAlerts = _getMockAlerts();

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.inventoryAlerts),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAlertsSummary(context, mockAlerts),
          Expanded(
            child: InventoryAlertsWidget(
              alerts: mockAlerts,
              onAcknowledge: (alertId) {
                // In a real app, this would update the alert in the database
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(localizations.alertAcknowledged(alertId))),
                );
              },
              onAlertTap: (alert) {
                // Navigate to item details
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          localizations.viewingDetailsFor(alert.itemName))),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // In a real app, this would refresh alerts from the repository
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.refreshingAlerts)),
          );
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildAlertsSummary(
      BuildContext context, List<InventoryAlert> alerts) {
    final localizations = AppLocalizations.of(context);
    final highCount =
        alerts.where((a) => a.severity == AlertSeverity.high).length;
    final mediumCount =
        alerts.where((a) => a.severity == AlertSeverity.medium).length;
    final lowCount =
        alerts.where((a) => a.severity == AlertSeverity.low).length;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAlertCounter(localizations.high, highCount, Colors.red),
          _buildAlertCounter(localizations.medium, mediumCount, Colors.orange),
          _buildAlertCounter(localizations.low, lowCount, Colors.blue),
          _buildAlertCounter(
              localizations.total, alerts.length, Colors.grey.shade700),
        ],
      ),
    );
  }

  Widget _buildAlertCounter(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.filterAlerts),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterCheckbox(localizations.showHighPriority, true),
              _buildFilterCheckbox(localizations.showMediumPriority, true),
              _buildFilterCheckbox(localizations.showLowPriority, true),
              const Divider(),
              _buildFilterCheckbox(localizations.lowStock, true),
              _buildFilterCheckbox(localizations.expiredItems, true),
              _buildFilterCheckbox(localizations.expiringSoon, true),
              const Divider(),
              _buildFilterCheckbox(localizations.showAcknowledged, false),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.apply),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterCheckbox(String label, bool initialValue) {
    return StatefulBuilder(
      builder: (context, setState) {
        return CheckboxListTile(
          title: Text(label),
          value: initialValue,
          onChanged: (value) {
            // In a real app, this would update state
            setState(() {});
          },
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
        );
      },
    );
  }

  // Mock data for demo purposes
  List<InventoryAlert> _getMockAlerts() {
    return [
      InventoryAlert(
        id: '1',
        itemId: '101',
        itemName: 'Whole Milk',
        alertType: AlertType.lowStock,
        message: 'Low stock: 20 liters remaining (below threshold of 50)',
        severity: AlertSeverity.high,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      InventoryAlert(
        id: '2',
        itemId: '102',
        itemName: 'Skim Milk',
        alertType: AlertType.lowStock,
        message: 'Low stock: 15 liters remaining (below threshold of 40)',
        severity: AlertSeverity.medium,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      InventoryAlert(
        id: '3',
        itemId: '103',
        itemName: 'Cheese Culture',
        alertType: AlertType.expiringSoon,
        message: 'Expiring in 15 days (10/11/2023)',
        severity: AlertSeverity.low,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      InventoryAlert(
        id: '4',
        itemId: '104',
        itemName: 'Yogurt Culture',
        alertType: AlertType.expired,
        message: 'Item expired on 09/20/2023',
        severity: AlertSeverity.high,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      InventoryAlert(
        id: '5',
        itemId: '105',
        itemName: 'Butter',
        alertType: AlertType.expiringSoon,
        message: 'Expiring in 7 days (10/03/2023)',
        severity: AlertSeverity.medium,
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
      ),
    ];
  }
}
