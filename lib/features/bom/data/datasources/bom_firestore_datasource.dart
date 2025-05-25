import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/bom_model.dart';
import '../models/bom_item_model.dart';

/// Firestore datasource for BOM operations
class BomFirestoreDatasource {
  BomFirestoreDatasource(this._firestore);

  final FirebaseFirestore _firestore;
  static const String _bomsCollection = 'boms';
  static const String _bomItemsCollection = 'bom_items';
  static const String _mrpResultsCollection = 'mrp_results';

  // BOM CRUD Operations
  Future<List<BomModel>> getAllBoms() async {
    final snapshot = await _firestore.collection(_bomsCollection).get();
    return snapshot.docs.map((doc) => BomModel.fromFirestore(doc)).toList();
  }

  Future<BomModel?> getBomById(String id) async {
    final doc = await _firestore.collection(_bomsCollection).doc(id).get();
    if (!doc.exists) return null;
    return BomModel.fromFirestore(doc);
  }

  Future<List<BomModel>> getBomsByProductId(String productId) async {
    final snapshot = await _firestore
        .collection(_bomsCollection)
        .where('productId', isEqualTo: productId)
        .get();
    return snapshot.docs.map((doc) => BomModel.fromFirestore(doc)).toList();
  }

  Future<List<BomModel>> getBomsByType(String bomType) async {
    final snapshot = await _firestore
        .collection(_bomsCollection)
        .where('bomType', isEqualTo: bomType)
        .get();
    return snapshot.docs.map((doc) => BomModel.fromFirestore(doc)).toList();
  }

  Future<List<BomModel>> getBomsByStatus(String status) async {
    final snapshot = await _firestore
        .collection(_bomsCollection)
        .where('status', isEqualTo: status)
        .get();
    return snapshot.docs.map((doc) => BomModel.fromFirestore(doc)).toList();
  }

  Future<String> createBom(BomModel bom) async {
    final docRef =
        await _firestore.collection(_bomsCollection).add(bom.toFirestore());
    return docRef.id;
  }

  Future<void> updateBom(String id, BomModel bom) async {
    await _firestore
        .collection(_bomsCollection)
        .doc(id)
        .update(bom.toFirestore());
  }

  Future<void> deleteBom(String id) async {
    final batch = _firestore.batch();

    // Delete the BOM
    batch.delete(_firestore.collection(_bomsCollection).doc(id));

    // Delete associated BOM items
    final itemsSnapshot = await _firestore
        .collection(_bomItemsCollection)
        .where('bomId', isEqualTo: id)
        .get();

    for (final doc in itemsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<void> updateBomStatus(String id, String status,
      {String? approvedBy}) async {
    final updateData = <String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (approvedBy != null) {
      updateData['approvedBy'] = approvedBy;
      updateData['approvedAt'] = FieldValue.serverTimestamp();
    }

    await _firestore.collection(_bomsCollection).doc(id).update(updateData);
  }

  // BOM Item Operations
  Future<List<BomItemModel>> getBomItems(String bomId) async {
    final snapshot = await _firestore
        .collection(_bomItemsCollection)
        .where('bomId', isEqualTo: bomId)
        .orderBy('sequenceNumber')
        .get();
    return snapshot.docs
        .map((doc) => BomItemModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<BomItemModel?> getBomItem(String bomId, String itemId) async {
    final snapshot = await _firestore
        .collection(_bomItemsCollection)
        .where('bomId', isEqualTo: bomId)
        .where('itemId', isEqualTo: itemId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return BomItemModel.fromJson({...doc.data(), 'id': doc.id});
  }

  Future<String> addBomItem(BomItemModel item) async {
    final docRef =
        await _firestore.collection(_bomItemsCollection).add(item.toJson());
    return docRef.id;
  }

  Future<void> updateBomItem(String id, BomItemModel item) async {
    await _firestore
        .collection(_bomItemsCollection)
        .doc(id)
        .update(item.toJson());
  }

  Future<void> deleteBomItem(String id) async {
    await _firestore.collection(_bomItemsCollection).doc(id).delete();
  }

  Future<void> deleteBomItemsByBomAndItem(String bomId, String itemId) async {
    final snapshot = await _firestore
        .collection(_bomItemsCollection)
        .where('bomId', isEqualTo: bomId)
        .where('itemId', isEqualTo: itemId)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> reorderBomItems(String bomId, List<String> itemIds) async {
    final batch = _firestore.batch();

    for (int i = 0; i < itemIds.length; i++) {
      final itemRef =
          _firestore.collection(_bomItemsCollection).doc(itemIds[i]);
      batch.update(itemRef, {'sequenceNumber': i + 1});
    }

    await batch.commit();
  }

  Future<void> bulkUpdateBomItems(List<BomItemModel> items) async {
    final batch = _firestore.batch();

    for (final item in items) {
      final ref = _firestore.collection(_bomItemsCollection).doc(item.id);
      batch.update(ref, item.toJson());
    }

    await batch.commit();
  }

  // Version Management
  Future<List<BomModel>> getBomVersions(String productId) async {
    final snapshot = await _firestore
        .collection(_bomsCollection)
        .where('productId', isEqualTo: productId)
        .orderBy('version', descending: true)
        .get();
    return snapshot.docs.map((doc) => BomModel.fromFirestore(doc)).toList();
  }

  Future<BomModel?> getActiveBomForProduct(String productId) async {
    final snapshot = await _firestore
        .collection(_bomsCollection)
        .where('productId', isEqualTo: productId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return BomModel.fromFirestore(snapshot.docs.first);
  }

  // Search and Filter
  Future<List<BomModel>> searchBoms(String query) async {
    final snapshot = await _firestore
        .collection(_bomsCollection)
        .where('bomCode', isGreaterThanOrEqualTo: query)
        .where('bomCode', isLessThan: query + 'z')
        .get();
    return snapshot.docs.map((doc) => BomModel.fromFirestore(doc)).toList();
  }

  Future<List<BomModel>> filterBoms({
    String? type,
    String? status,
    String? productCode,
    DateTime? createdAfter,
    DateTime? createdBefore,
  }) async {
    Query query = _firestore.collection(_bomsCollection);

    if (type != null) {
      query = query.where('bomType', isEqualTo: type);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    if (productCode != null) {
      query = query.where('productCode', isEqualTo: productCode);
    }
    if (createdAfter != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: createdAfter);
    }
    if (createdBefore != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: createdBefore);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => BomModel.fromFirestore(doc)).toList();
  }

  // Templates
  Future<List<BomModel>> getBomTemplates() async {
    final snapshot = await _firestore
        .collection(_bomsCollection)
        .where('bomType', isEqualTo: 'template')
        .get();
    return snapshot.docs.map((doc) => BomModel.fromFirestore(doc)).toList();
  }

  // MRP Results
  Future<void> saveMrpResults(Map<String, dynamic> mrpData) async {
    await _firestore.collection(_mrpResultsCollection).add({
      ...mrpData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getMrpResults(String bomId) async {
    final snapshot = await _firestore
        .collection(_mrpResultsCollection)
        .where('bomId', isEqualTo: bomId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return snapshot.docs.first.data();
  }

  // Real-time Streams
  Stream<List<BomModel>> watchAllBoms() {
    return _firestore.collection(_bomsCollection).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => BomModel.fromFirestore(doc)).toList());
  }

  Stream<BomModel> watchBom(String id) {
    return _firestore
        .collection(_bomsCollection)
        .doc(id)
        .snapshots()
        .map((doc) => BomModel.fromFirestore(doc));
  }

  Stream<List<BomItemModel>> watchBomItems(String bomId) {
    return _firestore
        .collection(_bomItemsCollection)
        .where('bomId', isEqualTo: bomId)
        .orderBy('sequenceNumber')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BomItemModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Batch Operations
  Future<void> batchCreateBoms(List<BomModel> boms) async {
    final batch = _firestore.batch();

    for (final bom in boms) {
      final ref = _firestore.collection(_bomsCollection).doc();
      batch.set(ref, bom.toFirestore());
    }

    await batch.commit();
  }

  Future<void> batchUpdateBoms(Map<String, BomModel> bomsById) async {
    final batch = _firestore.batch();

    for (final entry in bomsById.entries) {
      final ref = _firestore.collection(_bomsCollection).doc(entry.key);
      batch.update(ref, entry.value.toFirestore());
    }

    await batch.commit();
  }

  Future<void> batchDeleteBoms(List<String> bomIds) async {
    final batch = _firestore.batch();

    for (final id in bomIds) {
      batch.delete(_firestore.collection(_bomsCollection).doc(id));
    }

    await batch.commit();
  }
}
