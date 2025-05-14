import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/inventory_adjustment.dart';
import '../../domain/repositories/inventory_adjustment_repository.dart';

/// Firestore implementation of InventoryAdjustmentRepository
class InventoryAdjustmentRepositoryImpl
    implements InventoryAdjustmentRepository {
  InventoryAdjustmentRepositoryImpl({
    FirebaseFirestore? firestore,
    Logger? logger,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _logger = logger ?? Logger();

  final FirebaseFirestore _firestore;
  final Logger _logger;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('inventory_adjustments');

  InventoryAdjustment _docToEntity(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return InventoryAdjustment(
      id: doc.id,
      itemId: data['itemId'] as String,
      itemName: data['itemName'] as String,
      adjustmentType: AdjustmentType.values.firstWhere(
          (e) => e.toString().split('.').last == data['adjustmentType']),
      quantity: (data['quantity'] as num).toDouble(),
      previousQuantity: (data['previousQuantity'] as num).toDouble(),
      adjustedQuantity: (data['adjustedQuantity'] as num).toDouble(),
      reason: data['reason'] as String,
      performedBy: data['performedBy'] as String,
      performedAt: (data['performedAt'] as Timestamp).toDate(),
      notes: data['notes'] as String?,
      categoryId: data['categoryId'] as String,
      categoryName: data['categoryName'] as String,
      approvalStatus: data['approvalStatus'] != null
          ? AdjustmentApprovalStatus.values.firstWhere(
              (e) => e.toString().split('.').last == data['approvalStatus'])
          : null,
      approvedBy: data['approvedBy'] as String?,
      approvedAt: data['approvedAt'] != null
          ? (data['approvedAt'] as Timestamp).toDate()
          : null,
      documentReference: data['documentReference'] as String?,
    );
  }

  Map<String, dynamic> _entityToMap(InventoryAdjustment adj) {
    return {
      'itemId': adj.itemId,
      'itemName': adj.itemName,
      'adjustmentType': adj.adjustmentType.toString().split('.').last,
      'quantity': adj.quantity,
      'previousQuantity': adj.previousQuantity,
      'adjustedQuantity': adj.adjustedQuantity,
      'reason': adj.reason,
      'performedBy': adj.performedBy,
      'performedAt': FieldValue.serverTimestamp(),
      if (adj.notes != null) 'notes': adj.notes,
      'categoryId': adj.categoryId,
      'categoryName': adj.categoryName,
      if (adj.approvalStatus != null)
        'approvalStatus': adj.approvalStatus.toString().split('.').last,
      if (adj.approvedBy != null) 'approvedBy': adj.approvedBy,
      if (adj.approvedAt != null) 'approvedAt': adj.approvedAt,
      if (adj.documentReference != null)
        'documentReference': adj.documentReference,
    };
  }

  @override
  Future<List<InventoryAdjustment>> getAdjustments({
    DateTime? startDate,
    DateTime? endDate,
    AdjustmentType? type,
    String? itemId,
    String? categoryId,
    AdjustmentApprovalStatus? status,
  }) async {
    try {
      final snapshot = await _collection.get();
      var list = snapshot.docs.map(_docToEntity).toList();
      if (startDate != null) {
        list = list.where((a) => a.performedAt.isAfter(startDate)).toList();
      }
      if (endDate != null) {
        list = list.where((a) => a.performedAt.isBefore(endDate)).toList();
      }
      if (type != null) {
        list = list.where((a) => a.adjustmentType == type).toList();
      }
      if (itemId != null) {
        list = list.where((a) => a.itemId == itemId).toList();
      }
      if (categoryId != null) {
        list = list.where((a) => a.categoryId == categoryId).toList();
      }
      if (status != null) {
        list = list.where((a) => a.approvalStatus == status).toList();
      }
      return list;
    } catch (e, st) {
      _logger.e('Error fetching adjustments', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<InventoryAdjustment?> getAdjustment(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) return null;
      return _docToEntity(doc);
    } catch (e, st) {
      _logger.e('Error fetching adjustment $id', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<InventoryAdjustment> createAdjustment(
      InventoryAdjustment adjustment) async {
    try {
      final docRef = adjustment.id.isEmpty
          ? _collection.doc()
          : _collection.doc(adjustment.id);
      final data = _entityToMap(adjustment);
      await docRef.set(data);
      return adjustment.id.isEmpty
          ? adjustment.copyWith(id: docRef.id)
          : adjustment;
    } catch (e, st) {
      _logger.e('Error creating adjustment', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<List<InventoryAdjustment>> getAdjustmentsForItem(String itemId) async {
    final snapshot = await _collection.where('itemId', isEqualTo: itemId).get();
    return snapshot.docs.map(_docToEntity).toList();
  }

  @override
  Future<List<InventoryAdjustment>> getPendingAdjustments() async {
    final snapshot =
        await _collection.where('approvalStatus', isEqualTo: 'pending').get();
    return snapshot.docs.map(_docToEntity).toList();
  }

  @override
  Future<Map<AdjustmentType, int>> getAdjustmentStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final list = await getAdjustments(startDate: startDate, endDate: endDate);
    final stats = <AdjustmentType, int>{};
    for (var type in AdjustmentType.values) {
      stats[type] = list.where((a) => a.adjustmentType == type).length;
    }
    return stats;
  }

  @override
  Future<Map<AdjustmentType, double>> getTotalQuantityByType({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final list = await getAdjustments(startDate: startDate, endDate: endDate);
    final totals = <AdjustmentType, double>{};
    for (var type in AdjustmentType.values) {
      totals[type] = list
          .where((a) => a.adjustmentType == type)
          .fold(0.0, (sum, a) => sum + a.quantity);
    }
    return totals;
  }

  @override
  Future<void> updateAdjustmentStatus(
      String id, AdjustmentApprovalStatus status, String approverName) async {
    await _collection.doc(id).update({
      'approvalStatus': status.toString().split('.').last,
      'approvedBy': approverName,
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }
}
