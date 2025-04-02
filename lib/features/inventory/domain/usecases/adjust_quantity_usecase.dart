import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class AdjustQuantityUseCase {
  final InventoryRepository repository;

  AdjustQuantityUseCase(this.repository);

  Future<InventoryItem> execute(
      String itemId, double adjustment, String reason) async {
    if (adjustment == 0) {
      throw Exception('Adjustment quantity cannot be zero');
    }

    // Get current item to validate adjustment
    final item = await repository.getItem(itemId);

    // Validate resulting quantity won't be negative
    if (item.quantity + adjustment < 0) {
      throw Exception('Cannot adjust quantity below zero');
    }

    // Validate adjustment size
    if (adjustment.abs() > item.quantity * 2) {
      throw Exception(
        'Large quantity adjustment detected. Please verify the adjustment amount.',
      );
    }

    // Perform the adjustment
    return await repository.adjustQuantity(itemId, adjustment, reason);
  }
}
