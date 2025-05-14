import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/logging/logging_service.dart';
import '../../domain/entities/cost_layer.dart';
import '../../domain/entities/cost_method_setting.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../models/inventory_item_model.dart';
import '../models/inventory_movement_model.dart';

/// Implementation of the [InventoryRepository] interface using Firebase Firestore
class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl({
    LoggingService? loggingService,
    FirebaseFirestore? firestore,
  })  : _loggingService = loggingService ??
            LoggingService(Logger(printer: PrettyPrinter()), AppConfig()),
        _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  final LoggingService _loggingService;

  CollectionReference<Map<String, dynamic>> get _inventoryCollection =>
      _firestore.collection('inventoryItems');

  CollectionReference get _movementsCollection =>
      _firestore.collection('inventory_movements');

  CollectionReference get _costLayersCollection =>
      _firestore.collection('inventory_cost_layers');

  @override
  Future<List<InventoryItem>> getItems() async {
    try {
      final snapshot = await _inventoryCollection.get();
      return snapshot.docs
          .map((doc) => InventoryItemModel.fromFirestore(doc).toDomain())
          .toList();
    } catch (e, stackTrace) {
      _loggingService.error('Failed to get inventory items', e, stackTrace);
      return [];
    }
  }

  @override
  Future<InventoryItem?> getItem(String id) async {
    try {
      final doc = await _inventoryCollection.doc(id).get();
      if (!doc.exists) return null;
      return InventoryItemModel.fromFirestore(
        doc,
      ).toDomain();
    } catch (e, stackTrace) {
      _loggingService.error('Failed to get inventory item: $id', e, stackTrace);
      return null;
    }
  }

  @override
  Future<InventoryItem> addItem(InventoryItem item) async {
    try {
      final model = InventoryItemModel.fromDomain(item);
      final docRef = item.id.isEmpty
          ? _inventoryCollection.doc()
          : _inventoryCollection.doc(item.id);

      await docRef.set(model.toJson());

      // Update the ID if it was auto-generated
      final updatedItem = item.id.isEmpty ? item.copyWith(id: docRef.id) : item;

      return updatedItem;
    } catch (e, stackTrace) {
      _loggingService.error('Failed to add inventory item', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> updateItem(InventoryItem item) async {
    try {
      final model = InventoryItemModel.fromDomain(item);
      await _inventoryCollection.doc(item.id).update(model.toJson());
    } catch (e, stackTrace) {
      _loggingService.error('Failed to update inventory item', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      await _inventoryCollection.doc(id).delete();
    } catch (e, stackTrace) {
      _loggingService.error('Failed to delete inventory item', e, stackTrace);
      rethrow;
    }
  }

  @override
  Stream<List<InventoryItem>> watchAllItems() {
    try {
      return _inventoryCollection.snapshots().map(
            (snapshot) => snapshot.docs
                .map((doc) => InventoryItemModel.fromFirestore(
                        doc as DocumentSnapshot<Map<String, dynamic>>)
                    .toDomain())
                .toList(),
          );
    } catch (e, stackTrace) {
      _loggingService.error('Failed to watch inventory items', e, stackTrace);
      return Stream.value([]);
    }
  }

  @override
  Stream<InventoryItem> watchItem(String id) {
    try {
      return _inventoryCollection.doc(id).snapshots().map(
            (doc) => InventoryItemModel.fromFirestore(
              doc,
            ).toDomain(),
          );
    } catch (e, stackTrace) {
      _loggingService.error('Failed to watch inventory item', e, stackTrace);
      return Stream.empty();
    }
  }

  @override
  Future<InventoryItem> adjustQuantity(String id, double adjustment,
      String reason, String initiatingEmployeeId) async {
    try {
      // Get current item
      final itemSnapshot = await _inventoryCollection.doc(id).get();
      if (!itemSnapshot.exists) {
        throw Exception('Item not found: $id');
      }

      final item = InventoryItemModel.fromFirestore(itemSnapshot).toDomain();

      // Calculate new quantity
      final newQuantity = item.quantity + adjustment;
      if (newQuantity < 0) {
        throw Exception('Adjustment would result in negative quantity');
      }

      // Update item with new quantity
      final updatedItem = item.copyWith(
        quantity: newQuantity,
        lastUpdated: DateTime.now(),
      );

      await updateItem(updatedItem);

      // Record the adjustment in a separate collection for audit trail
      await _firestore.collection('inventory_adjustments').add({
        'itemId': id,
        'itemName': item.name,
        'previousQuantity': item.quantity,
        'adjustment': adjustment,
        'newQuantity': newQuantity,
        'reason': reason,
        'initiatingEmployeeId': initiatingEmployeeId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return updatedItem;
    } catch (e, stackTrace) {
      _loggingService.error('Failed to adjust quantity', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<InventoryItem>> getLowStockItems() async {
    try {
      final items = await getItems();
      return items
          .where((item) => item.quantity <= item.lowStockThreshold)
          .toList();
    } catch (e, stackTrace) {
      _loggingService.error('Failed to get low stock items', e, stackTrace);
      return [];
    }
  }

  @override
  Future<List<InventoryItem>> getItemsNeedingReorder() async {
    try {
      final items = await getItems();
      return items.where((item) => item.quantity <= item.reorderPoint).toList();
    } catch (e, stackTrace) {
      _loggingService.error(
          'Failed to get items needing reorder', e, stackTrace);
      return [];
    }
  }

  @override
  Future<List<InventoryItem>> getExpiringItems(DateTime before) async {
    try {
      final items = await getItems();
      return items
          .where((item) =>
              item.expiryDate != null && item.expiryDate!.isBefore(before))
          .toList();
    } catch (e, stackTrace) {
      _loggingService.error('Failed to get expiring items', e, stackTrace);
      return [];
    }
  }

  @override
  Future<List<dynamic>> getItemMovementHistory(String id) async {
    try {
      final adjustments = await _firestore
          .collection('inventory_adjustments')
          .where('itemId', isEqualTo: id)
          .orderBy('timestamp', descending: true)
          .get();

      return adjustments.docs.map((doc) => doc.data()).toList();
    } catch (e, stackTrace) {
      _loggingService.error(
          'Failed to get item movement history', e, stackTrace);
      return [];
    }
  }

  @override
  Future<List<InventoryItem>> searchItems(String query) async {
    try {
      if (query.isEmpty) return getItems();

      final lowercaseQuery = query.toLowerCase();
      final items = await getItems();

      return items.where((item) {
        return item.name.toLowerCase().contains(lowercaseQuery) ||
            item.category.toLowerCase().contains(lowercaseQuery) ||
            item.location.toLowerCase().contains(lowercaseQuery) ||
            (item.batchNumber != null &&
                item.batchNumber!.toLowerCase().contains(lowercaseQuery));
      }).toList();
    } catch (e, stackTrace) {
      _loggingService.error('Failed to search items', e, stackTrace);
      return [];
    }
  }

  @override
  Future<List<InventoryItem>> filterItems({
    String? category,
    String? subCategory,
    String? location,
    String? supplier,
    bool? lowStock,
    bool? needsReorder,
    bool? expired,
  }) async {
    try {
      // Build Firestore query for equality filters
      Query<Map<String, dynamic>> query = _inventoryCollection;
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }
      if (subCategory != null && subCategory.isNotEmpty) {
        query = query.where('subCategory', isEqualTo: subCategory);
      }
      if (location != null && location.isNotEmpty) {
        query = query.where('location', isEqualTo: location);
      }
      if (supplier != null && supplier.isNotEmpty) {
        query = query.where('supplier', isEqualTo: supplier);
      }
      if (expired == true) {
        final nowTs = Timestamp.fromDate(DateTime.now());
        query = query.where('expiryDate', isLessThan: nowTs);
      }
      // Execute server-side query
      final snapshot = await query.get();
      var items = snapshot.docs
          .map((doc) => InventoryItemModel.fromFirestore(doc).toDomain())
          .toList();
      // Client-side filters
      if (lowStock == true) {
        items = items
            .where((item) => item.quantity <= item.lowStockThreshold)
            .toList();
      }
      if (needsReorder == true) {
        items =
            items.where((item) => item.quantity <= item.reorderPoint).toList();
      }
      return items;
    } catch (e, stackTrace) {
      _loggingService.error('Failed to filter items', e, stackTrace);
      return [];
    }
  }

  @override
  Future<void> batchUpdateItems(List<InventoryItem> items) async {
    try {
      final batch = _firestore.batch();

      for (final item in items) {
        final model = InventoryItemModel.fromDomain(item);
        batch.set(_inventoryCollection.doc(item.id), model.toJson());
      }

      await batch.commit();
    } catch (e, stackTrace) {
      _loggingService.error('Failed to batch update items', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> batchDeleteItems(List<String> ids) async {
    try {
      final batch = _firestore.batch();

      for (final id in ids) {
        batch.delete(_inventoryCollection.doc(id));
      }

      await batch.commit();
    } catch (e, stackTrace) {
      _loggingService.error('Failed to batch delete items', e, stackTrace);
      rethrow;
    }
  }

  @override
  Stream<List<InventoryItem>> watchLowStockItems() {
    try {
      // This is a client-side filter since Firestore doesn't support
      // dynamic field comparisons
      return watchAllItems().map((items) => items
          .where((item) => item.quantity <= item.lowStockThreshold)
          .toList());
    } catch (e, stackTrace) {
      _loggingService.error('Failed to watch low stock items', e, stackTrace);
      return Stream.value([]);
    }
  }

  @override
  Future<List<InventoryItem>> getItemsAtCriticalLevel() async {
    try {
      final items = await getItems();
      // Define critical as items below half of their reorder point
      return items
          .where((item) => item.quantity <= item.reorderPoint / 2)
          .toList();
    } catch (e, stackTrace) {
      _loggingService.error(
          'Failed to get items at critical level', e, stackTrace);
      return [];
    }
  }

  @override
  Future<List<InventoryItem>> getItemsBelowReorderLevel() async {
    try {
      final items = await getItems();
      return items.where((item) => item.quantity <= item.reorderPoint).toList();
    } catch (e, stackTrace) {
      _loggingService.error(
          'Failed to get items below reorder level', e, stackTrace);
      return [];
    }
  }

  @override
  Future<Map<String, double>> getInventoryValueByCategory() async {
    try {
      final items = await getItems();
      final valueByCategory = <String, double>{};

      for (final item in items) {
        final value = (item.cost ?? 0) * item.quantity;
        valueByCategory[item.category] =
            (valueByCategory[item.category] ?? 0) + value;
      }

      return valueByCategory;
    } catch (e, stackTrace) {
      _loggingService.error(
          'Failed to get inventory value by category', e, stackTrace);
      return {};
    }
  }

  @override
  Future<List<InventoryItem>> getTopMovingItems(int limit) async {
    try {
      // This would typically need movement data, but for now we'll just return
      // items sorted by value (cost * quantity) as a placeholder
      final items = await getItems();
      items.sort((a, b) {
        final aValue = (a.cost ?? 0) * a.quantity;
        final bValue = (b.cost ?? 0) * b.quantity;
        return bValue.compareTo(aValue); // Descending order
      });

      return items.take(limit).toList();
    } catch (e, stackTrace) {
      _loggingService.error('Failed to get top moving items', e, stackTrace);
      return [];
    }
  }

  @override
  Future<List<InventoryItem>> getSlowMovingItems(int limit) async {
    try {
      // This would typically need movement data, but for now we'll just return
      // items sorted by value (cost * quantity) in ascending order as a placeholder
      final items = await getItems();
      items.sort((a, b) {
        final aValue = (a.cost ?? 0) * a.quantity;
        final bValue = (b.cost ?? 0) * b.quantity;
        return aValue.compareTo(bValue); // Ascending order
      });

      return items.take(limit).toList();
    } catch (e, stackTrace) {
      _loggingService.error('Failed to get slow moving items', e, stackTrace);
      return [];
    }
  }

  @override
  Future<List<InventoryItem>> getMostExpensiveItems(int limit) async {
    try {
      final snapshot = await _inventoryCollection
          .orderBy('cost', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => InventoryItemModel.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>)
              .toDomain())
          .toList();
    } catch (e, stackTrace) {
      _loggingService.error(
          'Failed to get most expensive items', e, stackTrace);
      return [];
    }
  }

  @override
  Future<int> countItemsBySupplier(String supplier) async {
    try {
      final snapshot = await _inventoryCollection
          .where('supplier', isEqualTo: supplier)
          .get();
      return snapshot.size;
    } catch (e, stackTrace) {
      _loggingService.error('Failed to count items by supplier', e, stackTrace);
      return 0;
    }
  }

  @override
  Future<int> countRecipesUsingItem(String itemId) async {
    try {
      final snapshot = await _firestore
          .collection('recipes')
          .where('ingredientIds', arrayContains: itemId)
          .get();
      return snapshot.size;
    } catch (e, stackTrace) {
      _loggingService.error(
          'Failed to count recipes using item', e, stackTrace);
      return 0;
    }
  }

  @override
  Future<String> addMovement(InventoryMovementModel movement) async {
    try {
      final docRef = movement.id != null
          ? _movementsCollection.doc(movement.id)
          : _movementsCollection.doc();

      final movementWithId =
          movement.id != null ? movement : movement.copyWith(id: docRef.id);

      await docRef.set(movementWithId.toFirestore());

      if ([
            InventoryMovementType.receipt,
            InventoryMovementType.return_,
            InventoryMovementType.adjustment,
          ].contains(movement.movementType) &&
          movement.items.any((item) => item.quantity > 0)) {
        for (final item in movement.items.where((i) => i.quantity > 0)) {
          final costLayer = CostLayer(
            id: '', // Firestore will generate the ID, or you can use docRef.id if available
            itemId: item.itemId,
            warehouseId: movement.warehouseId ?? '',
            batchLotNumber: item.batchLotNumber ?? 'unknown-batch',
            initialQuantity: item.quantity,
            remainingQuantity: item.quantity,
            costAtTransaction: item.costAtTransaction ?? 0.0,
            movementId: movementWithId.id,
            movementDate: movement.movementDate,
            expirationDate: item.expirationDate,
            productionDate: item.productionDate,
            createdAt: DateTime.now(),
          );

          await _costLayersCollection.add({
            'itemId': costLayer.itemId,
            'warehouseId': costLayer.warehouseId,
            'batchLotNumber': costLayer.batchLotNumber,
            'initialQuantity': costLayer.initialQuantity,
            'remainingQuantity': costLayer.remainingQuantity,
            'costAtTransaction': costLayer.costAtTransaction,
            'movementId': costLayer.movementId,
            'movementDate': Timestamp.fromDate(costLayer.movementDate),
            'expirationDate': costLayer.expirationDate != null
                ? Timestamp.fromDate(costLayer.expirationDate!)
                : null,
            'productionDate': costLayer.productionDate != null
                ? Timestamp.fromDate(costLayer.productionDate!)
                : null,
            'createdAt': Timestamp.now(),
          });

          final itemDoc = await _inventoryCollection.doc(item.itemId).get();
          if (itemDoc.exists) {
            await _inventoryCollection.doc(item.itemId).update({
              'cost': item.costAtTransaction,
              'updatedAt': Timestamp.now(),
            });
          }
        }
      }

      if ([
            InventoryMovementType.issue,
            InventoryMovementType.consumption,
            InventoryMovementType.adjustment,
          ].contains(movement.movementType) &&
          movement.items.any((item) => item.quantity < 0)) {
        for (final _ in movement.items.where((i) => i.quantity < 0)) {
          // Implementation of cost layer consumption would go here
        }
      }

      return docRef.id;
    } catch (e, stackTrace) {
      _loggingService.error('Failed to add movement', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<InventoryMovementModel?> getMovement(String movementId) async {
    try {
      final doc = await _movementsCollection.doc(movementId).get();
      if (!doc.exists) return null;
      return InventoryMovementModel.fromJson(
          doc.data() as Map<String, dynamic>);
    } catch (e, stackTrace) {
      _loggingService.error('Failed to get movement', e, stackTrace);
      return null;
    }
  }

  @override
  Future<List<InventoryMovementModel>> getMovementsForItem(
      String itemId) async {
    try {
      final query = _movementsCollection
          .where('items.itemId', arrayContains: itemId)
          .orderBy('movementDate', descending: true);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => InventoryMovementModel.fromJson(
              doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      _loggingService.error('Failed to get movements for item', e, stackTrace);
      return [];
    }
  }

  @override
  Future<List<InventoryMovementModel>> getInboundMovementsForItem(
      String itemId) async {
    try {
      final movements = await getMovementsForItem(itemId);

      return movements
          .where((movement) => movement.items
              .any((item) => item.itemId == itemId && item.quantity > 0))
          .toList();
    } catch (e, stackTrace) {
      _loggingService.error(
          'Failed to get inbound movements for item', e, stackTrace);
      return [];
    }
  }

  @override
  Future<List<InventoryMovementModel>> getMovementsForWarehouse(
      String warehouseId) async {
    try {
      final query = _movementsCollection
          .where('warehouseId', isEqualTo: warehouseId)
          .orderBy('movementDate', descending: true);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => InventoryMovementModel.fromJson(
              doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      _loggingService.error(
          'Failed to get movements for warehouse', e, stackTrace);
      return [];
    }
  }

  @override
  Future<void> updateMovement(InventoryMovementModel movement) async {
    try {
      await _movementsCollection
          .doc(movement.id)
          .update(movement.toFirestore());
    } catch (e, stackTrace) {
      _loggingService.error('Failed to update movement', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteMovement(String movementId) async {
    try {
      final costLayerQuery = await _costLayersCollection
          .where('movementId', isEqualTo: movementId)
          .get();

      if (costLayerQuery.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in costLayerQuery.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      await _movementsCollection.doc(movementId).delete();
    } catch (e, stackTrace) {
      _loggingService.error('Failed to delete movement', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<InventoryItem?> getInventoryItem(String itemId) async {
    return getItem(itemId);
  }

  @override
  Future<void> updateInventoryItem(InventoryItem item) async {
    return updateItem(item);
  }

  @override
  Future<List<InventoryItem>> getInventoryItems(String warehouseId) async {
    try {
      final query =
          _inventoryCollection.where('warehouseId', isEqualTo: warehouseId);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => InventoryItemModel.fromFirestore(doc).toDomain())
          .toList();
    } catch (e, stackTrace) {
      _loggingService.error(
          'Failed to get inventory items for warehouse', e, stackTrace);
      return [];
    }
  }

  @override
  Future<double> getCurrentStockQuantity(
      String itemId, String warehouseId) async {
    try {
      final item = await getItem(itemId);
      if (item == null) return 0.0;

      if (item.location != warehouseId) {
        final movements = await _movementsCollection
            .where('warehouseId', isEqualTo: warehouseId)
            .where('items.itemId', arrayContains: itemId)
            .get();

        double quantity = 0.0;
        for (final doc in movements.docs) {
          final movement = InventoryMovementModel.fromJson(
              doc.data() as Map<String, dynamic>);
          for (final item in movement.items.where((i) => i.itemId == itemId)) {
            quantity += item.quantity;
          }
        }
        return quantity;
      }

      return item.quantity;
    } catch (e, stackTrace) {
      _loggingService.error(
          'Failed to get current stock quantity', e, stackTrace);
      return 0.0;
    }
  }

  @override
  Future<List<CostLayer>> getAvailableCostLayers(
      String itemId, String warehouseId, CostingMethod costingMethod) async {
    try {
      final query = _costLayersCollection
          .where('itemId', isEqualTo: itemId)
          .where('remainingQuantity', isGreaterThan: 0);

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CostLayer(
          id: doc.id,
          itemId: data['itemId'] as String,
          warehouseId: data['warehouseId'] as String,
          batchLotNumber: data['batchLotNumber'] as String,
          initialQuantity: (data['initialQuantity'] as num).toDouble(),
          remainingQuantity: (data['remainingQuantity'] as num).toDouble(),
          costAtTransaction: (data['costAtTransaction'] as num).toDouble(),
          movementId: data['movementId'] as String?,
          movementDate: (data['movementDate'] as Timestamp).toDate(),
          expirationDate: data['expirationDate'] != null
              ? (data['expirationDate'] as Timestamp).toDate()
              : null,
          productionDate: data['productionDate'] != null
              ? (data['productionDate'] as Timestamp).toDate()
              : null,
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
        );
      }).toList();
    } catch (e, stackTrace) {
      _loggingService.error(
          'Failed to get available cost layers', e, stackTrace);
      return [];
    }
  }

  @override
  Future<double?> getItemWeightedAverageCost(
      String itemId, String warehouseId) {
    throw UnimplementedError('getItemWeightedAverageCost is not implemented');
  }

  @override
  Future<double> getItemCurrentQuantity(String itemId, String warehouseId) {
    throw UnimplementedError('getItemCurrentQuantity is not implemented');
  }

  @override
  Future<void> updateCostLayers(
      InventoryMovementModel movement, CostingMethod costingMethod) {
    throw UnimplementedError('updateCostLayers is not implemented');
  }

  @override
  Future<CostMethodSetting> getCostingMethodSetting(String? warehouseId) {
    throw UnimplementedError('getCostingMethodSetting is not implemented');
  }

  @override
  Future<void> updateCostingMethodSetting(CostMethodSetting setting) {
    throw UnimplementedError('updateCostingMethodSetting is not implemented');
  }

  @override
  Future<Map<String, InventoryValuation>> getInventoryValuation(
      {required String warehouseId,
      required CostingMethod costingMethod,
      List<String>? itemIds,
      String? categoryId}) {
    throw UnimplementedError('getInventoryValuation is not implemented');
  }

  @override
  Future<List<PickingSuggestion>> getPickingSuggestions(
      {required String itemId,
      required String warehouseId,
      required double quantity,
      required PickingStrategy strategy}) {
    throw UnimplementedError('getPickingSuggestions is not implemented');
  }

  @override
  Future<Warehouse?> getWarehouse(String id) {
    throw UnimplementedError('getWarehouse is not implemented');
  }

  @override
  Future<List<Warehouse>> getWarehouses() {
    throw UnimplementedError('getWarehouses is not implemented');
  }

  @override
  Future<CompanySettings?> getCompanySettings() {
    throw UnimplementedError('getCompanySettings is not implemented');
  }

  @override
  Future<void> saveCompanySettings(CompanySettings settings) {
    throw UnimplementedError('saveCompanySettings is not implemented');
  }

  @override
  Future<InventoryMovementModel> saveMovement(InventoryMovementModel movement) {
    throw UnimplementedError('saveMovement is not implemented');
  }

  @override
  Future<void> updateInventoryQuantity(
      String itemId, String warehouseId, double quantityChange) {
    throw UnimplementedError('updateInventoryQuantity is not implemented');
  }

  @override
  Future<void> saveCostLayer(CostLayer layer) {
    throw UnimplementedError('saveCostLayer is not implemented');
  }

  @override
  Future<void> deleteCostLayer(String id) {
    throw UnimplementedError('deleteCostLayer is not implemented');
  }

  @override
  Future<void> saveCostLayerConsumption(CostLayerConsumption consumption) {
    throw UnimplementedError('saveCostLayerConsumption is not implemented');
  }

  @override
  Future<List<CostLayerConsumption>> getCostLayerConsumptions(String itemId) {
    throw UnimplementedError('getCostLayerConsumptions is not implemented');
  }

  @override
  Future<List<ItemCostHistoryEntry>> getItemCostHistory(
      String itemId, DateTime startDate, DateTime endDate) {
    throw UnimplementedError('getItemCostHistory is not implemented');
  }
}
