import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class TransferStockUseCase {

  TransferStockUseCase(this.repository);
  final InventoryRepository repository;

  Future<List<InventoryItem>> execute({
    required String sourceItemId,
    required String destinationItemId,
    required double quantity,
    required String reason,
  }) async {
    if (quantity <= 0) {
      throw Exception('Transfer quantity must be greater than zero');
    }

    // Get source and destination items
    final sourceItem = await repository.getItem(sourceItemId);
    final destinationItem = await repository.getItem(destinationItemId);

    // Check for null items
    if (sourceItem == null) {
      throw Exception('Source item not found');
    }

    if (destinationItem == null) {
      throw Exception('Destination item not found');
    }

    // Validate items are the same type
    if (sourceItem.name != destinationItem.name ||
        sourceItem.category != destinationItem.category ||
        sourceItem.unit != destinationItem.unit) {
      throw Exception('Source and destination items must be of the same type');
    }

    // Validate source has enough quantity
    if (sourceItem.quantity < quantity) {
      throw Exception('Insufficient quantity in source location');
    }

    // Perform the transfer using batch update
    final updatedSource = sourceItem.copyWith(
      quantity: sourceItem.quantity - quantity,
      lastUpdated: DateTime.now(),
    );

    final updatedDestination = destinationItem.copyWith(
      quantity: destinationItem.quantity + quantity,
      lastUpdated: DateTime.now(),
    );

    await repository.batchUpdateItems([updatedSource, updatedDestination]);

    // Log the transfer in both locations
    await repository.adjustQuantity(
      sourceItemId,
      -quantity,
      'Transfer to ${destinationItem.location}: $reason',
    );
    await repository.adjustQuantity(
      destinationItemId,
      quantity,
      'Transfer from ${sourceItem.location}: $reason',
    );

    return [updatedSource, updatedDestination];
  }
}
