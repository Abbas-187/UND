import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/cycle_count_item.dart';
import '../../domain/entities/cycle_count_sheet.dart';
import '../../domain/repositories/cycle_count_sheet_repository.dart';

class CycleCountSheetRepositoryImpl implements CycleCountSheetRepository {
  CycleCountSheetRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _sheetCollection =>
      _firestore.collection('cycle_count_sheets');
  CollectionReference<Map<String, dynamic>> get _itemCollection =>
      _firestore.collection('cycle_count_items');

  @override
  Future<List<CycleCountSheet>> getSheets({String? assignedUserId}) async {
    Query<Map<String, dynamic>> query = _sheetCollection;
    if (assignedUserId != null) {
      query = query.where('assignedUserId', isEqualTo: assignedUserId);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => _fromSheetDoc(doc)).toList();
  }

  @override
  Future<CycleCountSheet?> getSheet(String sheetId) async {
    final doc = await _sheetCollection.doc(sheetId).get();
    if (!doc.exists) return null;
    return _fromSheetDoc(doc);
  }

  @override
  Future<CycleCountSheet> createSheet(
      CycleCountSheet sheet, List<CycleCountItem> items) async {
    await _sheetCollection.doc(sheet.sheetId).set(_toSheetMap(sheet));
    for (final item in items) {
      await _itemCollection.doc(item.countItemId).set(_toItemMap(item));
    }
    return sheet;
  }

  @override
  Future<void> updateSheet(CycleCountSheet sheet) async {
    await _sheetCollection.doc(sheet.sheetId).update(_toSheetMap(sheet));
  }

  @override
  Future<void> deleteSheet(String sheetId) async {
    await _sheetCollection.doc(sheetId).delete();
    // Optionally, delete all items for this sheet
    final items = await getSheetItems(sheetId);
    for (final item in items) {
      await _itemCollection.doc(item.countItemId).delete();
    }
  }

  @override
  Future<List<CycleCountItem>> getSheetItems(String sheetId) async {
    final snapshot =
        await _itemCollection.where('sheetId', isEqualTo: sheetId).get();
    return snapshot.docs.map((doc) => _fromItemDoc(doc)).toList();
  }

  @override
  Future<void> updateSheetItem(CycleCountItem item) async {
    await _itemCollection.doc(item.countItemId).update(_toItemMap(item));
  }

  CycleCountSheet _fromSheetDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CycleCountSheet(
      sheetId: doc.id,
      scheduleId: data['scheduleId'] as String?,
      creationDate: (data['creationDate'] as Timestamp).toDate(),
      assignedUserId: data['assignedUserId'] as String,
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      status: data['status'] as String,
      warehouseId: data['warehouseId'] as String,
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> _toSheetMap(CycleCountSheet sheet) {
    return {
      'scheduleId': sheet.scheduleId,
      'creationDate': sheet.creationDate,
      'assignedUserId': sheet.assignedUserId,
      'dueDate': sheet.dueDate,
      'status': sheet.status,
      'warehouseId': sheet.warehouseId,
      'notes': sheet.notes,
    };
  }

  CycleCountItem _fromItemDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CycleCountItem(
      countItemId: doc.id,
      sheetId: data['sheetId'] as String,
      inventoryItemId: data['inventoryItemId'] as String,
      batchLotNumber: data['batchLotNumber'] as String?,
      expectedQuantity: (data['expectedQuantity'] as num).toDouble(),
      countedQuantity: (data['countedQuantity'] as num?)?.toDouble(),
      countTimestamp: data['countTimestamp'] != null
          ? (data['countTimestamp'] as Timestamp).toDate()
          : null,
      discrepancyQuantity: (data['discrepancyQuantity'] as num?)?.toDouble(),
      discrepancyReasonCodeId: data['discrepancyReasonCodeId'] as String?,
      status: data['status'] as String,
      adjustmentMovementId: data['adjustmentMovementId'] as String?,
    );
  }

  Map<String, dynamic> _toItemMap(CycleCountItem item) {
    return {
      'sheetId': item.sheetId,
      'inventoryItemId': item.inventoryItemId,
      'batchLotNumber': item.batchLotNumber,
      'expectedQuantity': item.expectedQuantity,
      'countedQuantity': item.countedQuantity,
      'countTimestamp': item.countTimestamp,
      'discrepancyQuantity': item.discrepancyQuantity,
      'discrepancyReasonCodeId': item.discrepancyReasonCodeId,
      'status': item.status,
      'adjustmentMovementId': item.adjustmentMovementId,
    };
  }
}
