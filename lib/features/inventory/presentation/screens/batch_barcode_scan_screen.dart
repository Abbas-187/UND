import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/widgets/barcode_scanner_widget.dart';
import '../../domain/services/barcode_scanner_service.dart';
import '../../domain/providers/batch_operations_provider.dart';
import '../../domain/providers/inventory_provider.dart';

class BatchBarcodeScanScreen extends ConsumerWidget {
  const BatchBarcodeScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BarcodeScannerWidget(
      scanMode: ScanMode.item,
      instructionText: 'Scan an item barcode to add to batch',
      onBarcodeDetected: (value) async {
        // Extract the item ID from the barcode value
        // Format is expected to be "ITEM-{id}"
        if (value.startsWith('ITEM-')) {
          final itemId = value.substring(5); // Remove the "ITEM-" prefix

          // Check if this item exists in inventory
          final inventoryItemAsync = ref.read(inventoryItemProvider(itemId));

          // Get the current state of itemExists
          bool itemExists = false;
          await inventoryItemAsync.when(
            data: (item) {
              itemExists = item != null;
            },
            loading: () => null,
            error: (_, __) => null,
          );

          if (itemExists) {
            // Add the item to the batch
            await ref
                .read(batchOperationsStateProvider.notifier)
                .scanToAddToBatch(itemId);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added item $itemId to batch'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Item $itemId not found in inventory'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid item barcode format'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      },
    );
  }
}
