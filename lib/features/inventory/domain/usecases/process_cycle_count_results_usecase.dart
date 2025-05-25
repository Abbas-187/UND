import '../entities/cycle_count_sheet.dart';
import '../entities/cycle_count_item.dart';
import '../repositories/cycle_count_sheet_repository.dart';
import '../repositories/inventory_repository.dart';
import '../../data/models/inventory_movement_model.dart';
import '../../data/models/inventory_movement_item_model.dart';

class ProcessCycleCountResultsUseCase {
  // e.g., 1000.0 for $1000

  ProcessCycleCountResultsUseCase({
    required this.sheetRepository,
    required this.inventoryRepository,
    this.approvalThreshold = 1000.0, // can be made configurable
  });
  final CycleCountSheetRepository sheetRepository;
  final InventoryRepository inventoryRepository;
  final double approvalThreshold;

  Future<void> call(String sheetId) async {
    final sheet = await sheetRepository.getSheet(sheetId);
    if (sheet == null) throw Exception('Sheet not found');
    final items = await sheetRepository.getSheetItems(sheetId);
    bool anyRequiresReview = false;
    for (final item in items) {
      if (item.countedQuantity != null) {
        final discrepancy = item.countedQuantity! - item.expectedQuantity;
        if (discrepancy == 0) {
          await sheetRepository.updateSheetItem(
            item.copyWith(
              discrepancyQuantity: 0,
              status: 'Counted',
            ),
          );
          continue;
        }
        // Get item cost for threshold check
        final invItem = await inventoryRepository.getItem(item.inventoryItemId);
        final cost = invItem?.cost ?? 0;
        final discrepancyValue = (discrepancy * cost).abs();
        if (discrepancyValue >= approvalThreshold) {
          // Flag for approval
          anyRequiresReview = true;
          await sheetRepository.updateSheetItem(
            item.copyWith(
              discrepancyQuantity: discrepancy,
              status: 'Requires Review',
            ),
          );
        } else {
          // Auto-adjust: create adjustment movement
          final movementType = discrepancy > 0
              ? InventoryMovementType.adjustmentCycleCountGain
              : InventoryMovementType.adjustmentCycleCountLoss;
          final movement = InventoryMovementModel(
            documentNumber: 'CCADJ-${DateTime.now().millisecondsSinceEpoch}',
            movementDate: DateTime.now(),
            movementType: movementType,
            warehouseId: sheet.warehouseId,
            items: [
              InventoryMovementItemModel(
                itemId: item.inventoryItemId,
                itemCode: invItem?.appItemId ?? '',
                itemName: invItem?.name ?? '',
                uom: invItem?.unit ?? '',
                quantity: discrepancy,
                batchLotNumber: item.batchLotNumber,
                costAtTransaction: cost,
              ),
            ],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            initiatingEmployeeId: sheet.assignedUserId,
            status: InventoryMovementStatus.completed,
          );
          final movementId = await inventoryRepository.addMovement(movement);
          await sheetRepository.updateSheetItem(
            item.copyWith(
              discrepancyQuantity: discrepancy,
              status: 'Adjusted',
              adjustmentMovementId: movementId,
            ),
          );
        }
      }
    }
    // Update sheet status
    await sheetRepository.updateSheet(sheet.copyWith(
      status: anyRequiresReview ? 'Requires Review' : 'Adjusted',
    ));
  }
}
