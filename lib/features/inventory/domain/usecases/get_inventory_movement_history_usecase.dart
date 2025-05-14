import '../../data/models/inventory_movement_model.dart';
import '../../data/repositories/inventory_movement_repository.dart';

class GetInventoryMovementHistoryUseCase {
  GetInventoryMovementHistoryUseCase(this.repository);
  final InventoryMovementRepository repository;

  /// Returns a list of InventoryMovementModel filtered by the provided criteria.
  Future<List<InventoryMovementModel>> execute({
    String? itemId,
    String? batchLotNumber,
    DateTime? startDate,
    DateTime? endDate,
    InventoryMovementType? movementType,
    String? initiatingEmployeeId,
    String? referenceDocument,
    String? locationId,
  }) async {
    // Fetch all movements (for demo; optimize with Firestore queries in production)
    final all = await repository.getAllMovements();
    return all.where((m) {
      if (itemId != null && !m.items.any((i) => i.itemId == itemId)) {
        return false;
      }
      if (batchLotNumber != null &&
          !m.items.any((i) => i.batchLotNumber == batchLotNumber)) {
        return false;
      }
      if (startDate != null && m.timestamp.isBefore(startDate)) return false;
      if (endDate != null && m.timestamp.isAfter(endDate)) return false;
      if (movementType != null && m.movementType != movementType) return false;
      if (initiatingEmployeeId != null &&
          m.initiatingEmployeeId != initiatingEmployeeId) {
        return false;
      }
      if (referenceDocument != null &&
          !m.referenceDocuments.any((ref) => ref.contains(referenceDocument))) {
        return false;
      }
      if (locationId != null &&
          m.sourceLocationId != locationId &&
          m.destinationLocationId != locationId) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
