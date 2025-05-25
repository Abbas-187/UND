import '../entities/cycle_count_sheet.dart';
import '../entities/cycle_count_item.dart';
import '../entities/inventory_item.dart';
import '../repositories/cycle_count_sheet_repository.dart';
import '../repositories/cycle_count_schedule_repository.dart';
import '../repositories/inventory_repository.dart';

class GenerateCycleCountSheetUseCase {
  GenerateCycleCountSheetUseCase({
    required this.sheetRepository,
    required this.scheduleRepository,
    required this.inventoryRepository,
  });
  final CycleCountSheetRepository sheetRepository;
  final CycleCountScheduleRepository scheduleRepository;
  final InventoryRepository inventoryRepository;

  Future<CycleCountSheet> call({
    String? scheduleId,
    required String assignedUserId,
    required DateTime dueDate,
    required String warehouseId,
    Map<String, dynamic>? adHocCriteria,
  }) async {
    // 1. Determine item selection criteria
    Map<String, dynamic> criteria = {};
    if (scheduleId != null) {
      final schedule = await scheduleRepository.getSchedule(scheduleId);
      if (schedule != null) {
        criteria = schedule.itemSelectionCriteria;
      }
    } else if (adHocCriteria != null) {
      criteria = adHocCriteria;
    }

    // 2. Select items based on criteria
    List<InventoryItem> allItems = await inventoryRepository.getItems();
    List<InventoryItem> selectedItems = allItems;
    // ABC selection
    if (criteria['abcClass'] != null) {
      selectedItems = selectedItems
          .where((item) =>
              item.additionalAttributes != null &&
              item.additionalAttributes!['abcClass'] == criteria['abcClass'])
          .toList();
    }
    // Location filter
    if (criteria['location'] != null) {
      selectedItems = selectedItems
          .where((item) => item.location == criteria['location'])
          .toList();
    }
    // Category filter
    if (criteria['category'] != null) {
      selectedItems = selectedItems
          .where((item) => item.category == criteria['category'])
          .toList();
    }
    // Velocity filter (top N by movement)
    if (criteria['velocityTopN'] != null) {
      final topMoving =
          await inventoryRepository.getTopMovingItems(criteria['velocityTopN']);
      selectedItems = selectedItems
          .where((item) => topMoving.map((e) => e.id).contains(item.id))
          .toList();
    }
    // Random selection (percentage)
    if (criteria['randomPercent'] != null) {
      selectedItems.shuffle();
      final count =
          (selectedItems.length * (criteria['randomPercent'] / 100)).round();
      selectedItems = selectedItems.take(count).toList();
    }
    // Ad-hoc item IDs
    if (criteria['itemIds'] != null && criteria['itemIds'] is List) {
      final ids = List<String>.from(criteria['itemIds']);
      selectedItems =
          selectedItems.where((item) => ids.contains(item.id)).toList();
    }

    // 3. Generate CycleCountItem list with frozen expectedQuantity
    final now = DateTime.now();
    final items = selectedItems
        .map((item) => CycleCountItem(
              countItemId: '${item.id}_${now.millisecondsSinceEpoch}',
              sheetId: '', // Will be set after sheet creation
              inventoryItemId: item.id,
              batchLotNumber: item.batchNumber,
              expectedQuantity: item.quantity,
              countedQuantity: null,
              countTimestamp: null,
              discrepancyQuantity: null,
              discrepancyReasonCodeId: null,
              status: 'Pending Count',
              adjustmentMovementId: null,
            ))
        .toList();

    // 4. Create sheet
    final sheet = CycleCountSheet(
      sheetId: DateTime.now().millisecondsSinceEpoch.toString(),
      scheduleId: scheduleId,
      creationDate: now,
      assignedUserId: assignedUserId,
      dueDate: dueDate,
      status: 'Pending',
      warehouseId: warehouseId,
      notes: null,
    );
    // 5. Save sheet and items
    await sheetRepository.createSheet(sheet, items);
    return sheet;
  }
}
