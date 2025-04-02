import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/inventory_alert.dart';
import '../widgets/alerts/inventory_alerts_widget.dart';

/// Screen to display all inventory alerts
class InventoryAlertsScreen extends ConsumerWidget {
  const InventoryAlertsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, this would come from a provider that fetches alerts
    // from a repository
    final mockAlerts = _getMockAlerts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAlertsSummary(mockAlerts),
          Expanded(
            child: InventoryAlertsWidget(
              alerts: mockAlerts,
              onAcknowledge: (alertId) {
                // In a real app, this would update the alert in the database
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Alert $alertId acknowledged')),
                );
              },
              onAlertTap: (alert) {
                // Navigate to item details
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Viewing details for ${alert.itemName}')),
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
            const SnackBar(content: Text('Refreshing alerts...')),
          );
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildAlertsSummary(List<InventoryAlert> alerts) {
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
          _buildAlertCounter('High', highCount, Colors.red),
          _buildAlertCounter('Medium', mediumCount, Colors.orange),
          _buildAlertCounter('Low', lowCount, Colors.blue),
          _buildAlertCounter('Total', alerts.length, Colors.grey.shade700),
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Alerts'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterCheckbox('Show High Priority', true),
              _buildFilterCheckbox('Show Medium Priority', true),
              _buildFilterCheckbox('Show Low Priority', true),
              const Divider(),
              _buildFilterCheckbox('Low Stock', true),
              _buildFilterCheckbox('Expired Items', true),
              _buildFilterCheckbox('Expiring Soon', true),
              const Divider(),
              _buildFilterCheckbox('Show Acknowledged', false),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply'),
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
        itemName: 'Laptop Model X',
        alertType: AlertType.lowStock,
        message: 'Low stock: 2 units remaining (below threshold of 5)',
        severity: AlertSeverity.high,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      InventoryAlert(
        id: '2',
        itemId: '102',
        itemName: 'Office Chair',
        alertType: AlertType.lowStock,
        message: 'Low stock: 3 units remaining (below threshold of 10)',
        severity: AlertSeverity.medium,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      InventoryAlert(
        id: '3',
        itemId: '103',
        itemName: 'Printer Ink Cartridge',
        alertType: AlertType.expiringSoon,
        message: 'Expiring in 15 days (10/11/2023)',
        severity: AlertSeverity.low,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      InventoryAlert(
        id: '4',
        itemId: '104',
        itemName: 'Coffee Beans',
        alertType: AlertType.expired,
        message: 'Item expired on 09/20/2023',
        severity: AlertSeverity.high,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      InventoryAlert(
        id: '5',
        itemId: '105',
        itemName: 'Sanitizing Wipes',
        alertType: AlertType.expiringSoon,
        message: 'Expiring in 7 days (10/03/2023)',
        severity: AlertSeverity.medium,
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
      ),
    ];
  }
}
