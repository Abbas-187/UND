import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/inventory_alert.dart';
import '../../../domain/services/alerts/inventory_alerts_service.dart';

/// Widget to display inventory alerts
class InventoryAlertsWidget extends StatelessWidget {
  /// List of alerts to display
  final List<InventoryAlert> alerts;

  /// Callback when an alert is acknowledged
  final Function(String alertId)? onAcknowledge;

  /// Callback when an alert is clicked
  final Function(InventoryAlert alert)? onAlertTap;

  /// Service for alert utilities
  final InventoryAlertsService _alertsService = InventoryAlertsService();

  /// DateFormat for formatting timestamps
  final DateFormat _dateFormat = DateFormat('MMM d, yyyy HH:mm');

  InventoryAlertsWidget({
    Key? key,
    required this.alerts,
    this.onAcknowledge,
    this.onAlertTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No alerts at this time.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: alerts.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return _buildAlertCard(context, alert);
      },
    );
  }

  Widget _buildAlertCard(BuildContext context, InventoryAlert alert) {
    final color = _alertsService.getSeverityColor(alert.severity);
    final icon = _alertsService.getAlertTypeIcon(alert.alertType);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: color.withOpacity(0.5), width: 1),
      ),
      child: InkWell(
        onTap: () => onAlertTap?.call(alert),
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          alert.itemName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        _buildSeverityBadge(alert.severity),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.message,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dateFormat.format(alert.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (!alert.isAcknowledged && onAcknowledge != null)
                          TextButton(
                            onPressed: () => onAcknowledge?.call(alert.id),
                            child: const Text('Acknowledge'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(AlertSeverity severity) {
    String label;
    Color color;

    switch (severity) {
      case AlertSeverity.high:
        label = 'High';
        color = Colors.red;
        break;
      case AlertSeverity.medium:
        label = 'Medium';
        color = Colors.orange;
        break;
      case AlertSeverity.low:
        label = 'Low';
        color = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
