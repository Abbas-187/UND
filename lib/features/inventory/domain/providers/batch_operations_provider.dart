import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/inventory_item_model.dart';
import '../repositories/inventory_repository.dart';
import '../services/label_printing_service.dart';
import 'inventory_provider.dart';

part 'batch_operations_provider.g.dart';

@riverpod
class BatchOperationsState extends _$BatchOperationsState {
  late final InventoryRepository _repository;
  late final LabelPrintingService _labelPrintingService;

  @override
  List<String> build() {
    _repository = ref.watch(inventoryRepositoryProvider);
    _labelPrintingService = LabelPrintingService();
    return []; // Start with empty selection
  }

  void toggleItemSelection(String itemId) {
    if (state.contains(itemId)) {
      state = state.where((id) => id != itemId).toList();
    } else {
      state = [...state, itemId];
    }
  }

  void clearSelection() {
    state = [];
  }

  void selectAll(List<String> itemIds) {
    state = itemIds;
  }

  bool isSelected(String itemId) {
    return state.contains(itemId);
  }

  Future<void> transferBatch({
    required String destinationLocationId,
    String? notes,
  }) async {
    if (state.isEmpty) return;

    // Stub implementation as repository doesn't have this method yet
    print('Transferring batch to location: $destinationLocationId');
    print('Items to transfer: $state');
    if (notes != null) {
      print('Transfer notes: $notes');
    }
    // Mock delay to simulate operation
    await Future.delayed(const Duration(milliseconds: 500));

    clearSelection();
  }

  Future<void> adjustBatchQuantity({
    required double adjustmentFactor,
    required String reason,
    String? notes,
  }) async {
    if (state.isEmpty) return;

    // Stub implementation as repository doesn't have this method yet
    print('Adjusting batch quantity by factor: $adjustmentFactor');
    print('Adjustment reason: $reason');
    print('Items to adjust: $state');
    if (notes != null) {
      print('Adjustment notes: $notes');
    }
    // Mock delay to simulate operation
    await Future.delayed(const Duration(milliseconds: 500));

    clearSelection();
  }

  Future<void> removeBatch({
    required String reason,
    String? notes,
  }) async {
    if (state.isEmpty) return;

    // Stub implementation as repository doesn't have this method yet
    print('Removing batch from inventory');
    print('Removal reason: $reason');
    print('Items to remove: $state');
    if (notes != null) {
      print('Removal notes: $notes');
    }
    // Mock delay to simulate operation
    await Future.delayed(const Duration(milliseconds: 500));

    clearSelection();
  }

  Future<void> printBatchLabels() async {
    if (state.isEmpty) return;

    // Get inventory items data
    final inventoryState = ref.read(inventoryProvider);

    // Get the list of inventory items that match the selected IDs
    final List<InventoryItemModel> itemsToPrint = [];

    inventoryState.whenData((items) {
      for (final itemId in state) {
        final matchingItems = items.where((item) => item.id == itemId).toList();
        if (matchingItems.isNotEmpty) {
          itemsToPrint.add(matchingItems.first);
        }
      }
    });

    if (itemsToPrint.isEmpty) {
      // No matching items found
      return;
    }

    // Generate and print PDF labels
    await _labelPrintingService.printLabels(itemsToPrint);

    // Don't clear selection after printing to allow multiple prints
  }

  // Add a method to scan barcodes and add items to the batch
  Future<void> scanToAddToBatch(String scannedItemId) async {
    if (!state.contains(scannedItemId)) {
      toggleItemSelection(scannedItemId);
    }
  }
}
