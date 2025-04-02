import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../models/inventory_item_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'inventory';

  InventoryRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _inventoryCollection =>
      _firestore.collection(_collection);

  CollectionReference<Map<String, dynamic>> _getMovementCollection(
          String itemId) =>
      _inventoryCollection.doc(itemId).collection('movements');

  @override
  Future<InventoryItem> getItem(String id) async {
    final doc = await _inventoryCollection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Item not found');
    }
    return InventoryItemModel.fromFirestore(doc).toDomain();
  }

  @override
  Future<List<InventoryItem>> getAllItems() async {
    final snapshot = await _inventoryCollection.get();
    return snapshot.docs
        .map((doc) => InventoryItemModel.fromFirestore(doc).toDomain())
        .toList();
  }

  @override
  Future<List<InventoryItem>> getItemsByCategory(String category) async {
    final snapshot =
        await _inventoryCollection.where('category', isEqualTo: category).get();
    return snapshot.docs
        .map((doc) => InventoryItemModel.fromFirestore(doc).toDomain())
        .toList();
  }

  @override
  Future<InventoryItem> addItem(InventoryItem item) async {
    final model = InventoryItemModel.fromDomain(item);
    final docRef = _inventoryCollection.doc();
    final modelWithId = model.copyWith(id: docRef.id);
    await docRef.set(modelWithId.toJson());

    // Record initial stock as a movement
    await _recordMovement(
      docRef.id,
      item.quantity,
      'Initial stock',
      DateTime.now(),
    );

    return modelWithId.toDomain();
  }

  @override
  Future<InventoryItem> updateItem(InventoryItem item) async {
    final model = InventoryItemModel.fromDomain(item);
    await _inventoryCollection.doc(item.id).update(model.toJson());
    return item;
  }

  @override
  Future<void> deleteItem(String id) async {
    await _inventoryCollection.doc(id).delete();
  }

  @override
  Future<InventoryItem> adjustQuantity(
    String id,
    double adjustment,
    String reason,
  ) async {
    final docRef = _inventoryCollection.doc(id);

    return _firestore.runTransaction<InventoryItem>((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) {
        throw Exception('Item not found');
      }

      final item = InventoryItemModel.fromFirestore(doc);
      final newQuantity = item.quantity + adjustment;

      if (newQuantity < 0) {
        throw Exception('Quantity cannot be negative');
      }

      final updatedItem = item.copyWith(
        quantity: newQuantity,
        lastUpdated: DateTime.now(),
      );

      transaction.update(docRef, updatedItem.toJson());

      // Log the adjustment in a separate collection
      final adjustmentRef =
          _firestore.collection('inventory_adjustments').doc();
      transaction.set(adjustmentRef, {
        'itemId': id,
        'adjustment': adjustment,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
        'previousQuantity': item.quantity,
        'newQuantity': newQuantity,
      });

      return updatedItem.toDomain();
    });
  }

  Future<void> _recordMovement(
    String itemId,
    double quantity,
    String reason,
    DateTime timestamp,
  ) async {
    await _getMovementCollection(itemId).add({
      'quantity': quantity,
      'reason': reason,
      'timestamp': Timestamp.fromDate(timestamp),
    });
  }

  @override
  Future<List<dynamic>> getItemMovementHistory(String id) async {
    final snapshot = await _getMovementCollection(id)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'quantity': data['quantity'],
        'reason': data['reason'],
        'timestamp': (data['timestamp'] as Timestamp).toDate(),
      };
    }).toList();
  }

  @override
  Future<List<InventoryItem>> getLowStockItems() async {
    final snapshot = await _inventoryCollection
        .where('quantity', isLessThanOrEqualTo: 'minimumQuantity')
        .get();
    return snapshot.docs
        .map((doc) => InventoryItemModel.fromFirestore(doc).toDomain())
        .toList();
  }

  @override
  Future<List<InventoryItem>> getItemsNeedingReorder() async {
    final snapshot = await _inventoryCollection
        .where('quantity', isLessThanOrEqualTo: 'reorderPoint')
        .get();
    return snapshot.docs
        .map((doc) => InventoryItemModel.fromFirestore(doc).toDomain())
        .toList();
  }

  @override
  Future<List<InventoryItem>> getExpiringItems(DateTime before) async {
    final snapshot = await _inventoryCollection
        .where('expiryDate', isLessThanOrEqualTo: before)
        .where('expiryDate', isGreaterThan: DateTime.now())
        .get();
    return snapshot.docs
        .map((doc) => InventoryItemModel.fromFirestore(doc).toDomain())
        .toList();
  }

  @override
  Future<List<InventoryItem>> searchItems(String query) async {
    // Note: This is a simple implementation. In production, you might want to use
    // a more sophisticated search solution like Algolia or ElasticSearch
    final normalizedQuery = query.toLowerCase();
    final snapshot = await _inventoryCollection
        .where('searchTerms', arrayContains: normalizedQuery)
        .get();
    return snapshot.docs
        .map((doc) => InventoryItemModel.fromFirestore(doc).toDomain())
        .toList();
  }

  @override
  Future<List<InventoryItem>> filterItems({
    String? category,
    String? location,
    bool? lowStock,
    bool? needsReorder,
    bool? expired,
  }) async {
    Query<Map<String, dynamic>> query = _inventoryCollection;

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (location != null) {
      query = query.where('location', isEqualTo: location);
    }
    if (lowStock == true) {
      query = query.where('quantity', isLessThanOrEqualTo: 'minimumQuantity');
    }
    if (needsReorder == true) {
      query = query.where('quantity', isLessThanOrEqualTo: 'reorderPoint');
    }
    if (expired == true) {
      query = query.where('expiryDate', isLessThan: DateTime.now());
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => InventoryItemModel.fromFirestore(doc).toDomain())
        .toList();
  }

  @override
  Future<void> batchUpdateItems(List<InventoryItem> items) async {
    final batch = _firestore.batch();
    for (final item in items) {
      final model = InventoryItemModel.fromDomain(item);
      batch.update(_inventoryCollection.doc(item.id), model.toJson());
    }
    await batch.commit();
  }

  @override
  Future<void> batchDeleteItems(List<String> ids) async {
    final batch = _firestore.batch();
    for (final id in ids) {
      batch.delete(_inventoryCollection.doc(id));
    }
    await batch.commit();
  }

  @override
  Future<Map<String, double>> getInventoryValueByCategory() async {
    final snapshot = await _inventoryCollection.get();
    final Map<String, double> categoryValues = {};

    for (final doc in snapshot.docs) {
      final item = InventoryItemModel.fromFirestore(doc);
      final value =
          item.quantity * (item.additionalAttributes?['unitValue'] ?? 0.0);
      categoryValues.update(
        item.category,
        (existing) => existing + value,
        ifAbsent: () => value,
      );
    }

    return categoryValues;
  }

  @override
  Future<List<InventoryItem>> getTopMovingItems(int limit) async {
    // This would typically require tracking movement history
    // For now, we'll just return items with highest quantity changes
    final snapshot = await _inventoryCollection
        .orderBy('quantityChanged', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => InventoryItemModel.fromFirestore(doc).toDomain())
        .toList();
  }

  @override
  Future<List<InventoryItem>> getSlowMovingItems(int limit) async {
    final snapshot = await _inventoryCollection
        .orderBy('quantityChanged')
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => InventoryItemModel.fromFirestore(doc).toDomain())
        .toList();
  }

  @override
  Stream<List<InventoryItem>> watchAllItems() {
    return _inventoryCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => InventoryItemModel.fromFirestore(doc).toDomain())
        .toList());
  }

  @override
  Stream<InventoryItem> watchItem(String id) {
    return _inventoryCollection.doc(id).snapshots().map(
          (doc) => InventoryItemModel.fromFirestore(doc).toDomain(),
        );
  }

  @override
  Stream<List<InventoryItem>> watchLowStockItems() {
    return _inventoryCollection
        .where('quantity', isLessThanOrEqualTo: 'minimumQuantity')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryItemModel.fromFirestore(doc).toDomain())
            .toList());
  }
}
