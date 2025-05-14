import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/expiry_alerts_provider.dart';
import '../widgets/alerts/inventory_alerts_widget.dart';
import 'inventory_item_details_screen.dart';

/// Screen to display all inventory alerts
class InventoryAlertsScreen extends ConsumerWidget {
  const InventoryAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(inventoryAlertsStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Alerts')),
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (alerts) => InventoryAlertsWidget(
          alerts: alerts,
          onAcknowledge: (id) async {
            // Persist acknowledgment in Firestore
            await FirebaseFirestore.instance
                .collection('inventory_alerts')
                .doc(id)
                .set({'isAcknowledged': true}, SetOptions(merge: true));
          },
          onAlertTap: (alert) {
            // Navigate to item detail screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    InventoryItemDetailsScreen(itemId: alert.itemId),
              ),
            );
          },
        ),
      ),
    );
  }
}
