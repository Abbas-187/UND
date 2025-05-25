import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../inventory/presentation/providers/inventory_item_picker_provider.dart';
import '../../inventory/presentation/providers/inventory_movement_providers.dart';
import '../utils/inventory_report_aggregators.dart';
import 'report_screen.dart';

class InventoryReportScreen extends ConsumerWidget {
  const InventoryReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the robust inventory items provider
    final itemsAsync = ref.watch(inventoryItemsProvider);
    // Fetch all movements for a comprehensive report
    final movementsAsync = ref.watch(allMovementsProvider);

    return itemsAsync.when(
      data: (items) => movementsAsync.when(
        data: (movements) {
          final aggregators = InventoryReportAggregators(
            firestore: FirebaseFirestore.instance,
          );
          return ReportScreen(aggregators: aggregators);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading movements: $e')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading items: $e')),
    );
  }
}
