import '../entities/cycle_count_item.dart';
import '../entities/cycle_count_sheet.dart';

abstract class CycleCountSheetRepository {
  Future<List<CycleCountSheet>> getSheets({String? assignedUserId});
  Future<CycleCountSheet?> getSheet(String sheetId);
  Future<CycleCountSheet> createSheet(
      CycleCountSheet sheet, List<CycleCountItem> items);
  Future<void> updateSheet(CycleCountSheet sheet);
  Future<void> deleteSheet(String sheetId);
  Future<List<CycleCountItem>> getSheetItems(String sheetId);
  Future<void> updateSheetItem(CycleCountItem item);
}
