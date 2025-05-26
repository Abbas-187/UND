import '../../data/models/inventory_movement_item_model.dart';
import '../../data/models/inventory_movement_model.dart';
import '../repositories/cycle_count_sheet_repository.dart';
import '../repositories/inventory_repository.dart';

class ApproveCycleCountAdjustmentUseCase {
  ApproveCycleCountAdjustmentUseCase({
    required this.sheetRepository,
    required this.inventoryRepository,
  });
  final CycleCountSheetRepository sheetRepository;
  final InventoryRepository inventoryRepository;

  /// Approves or rejects a cycle count adjustment. Requires sheetId for efficiency.
  Future<void> call({
    required String sheetId,
    required String countItemId,
    required String approverUserId,
    required bool approved,
    String? comments,
  }) async {
    // 1. Fetch the item
    final items = await sheetRepository.getSheetItems(sheetId);
    final item = items.firstWhere((i) => i.countItemId == countItemId,
        orElse: () => throw Exception('Item not found'));
    if (!approved) {
      // Mark as rejected
      await sheetRepository.updateSheetItem(item.copyWith(status: 'Rejected'));
      return;
    }
    // 2. If approved, create adjustment movement
    final discrepancy = item.discrepancyQuantity ??
        ((item.countedQuantity ?? 0) - item.expectedQuantity);
    if (discrepancy == 0) {
      // No adjustment needed
      await sheetRepository.updateSheetItem(item.copyWith(status: 'Adjusted'));
      return;
    }
    final invItem = await inventoryRepository.getItem(item.inventoryItemId);
    final cost = invItem?.cost ?? 0;
    final movementType = discrepancy > 0
        ? InventoryMovementType.adjustmentCycleCountGain
        : InventoryMovementType.adjustmentCycleCountLoss;
    final movement = InventoryMovementModel(
      documentNumber: 'CCADJ-${DateTime.now().millisecondsSinceEpoch}',
      movementDate: DateTime.now(),
      movementType: movementType,
      warehouseId: invItem?.location ?? '',
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
      initiatingEmployeeId: approverUserId,
      status: InventoryMovementStatus.completed,
    );
    final movementId = await inventoryRepository.addMovement(movement);
    await sheetRepository.updateSheetItem(
      item.copyWith(
        status: 'Adjusted',
        adjustmentMovementId: movementId,
      ),
    );
  }
}
