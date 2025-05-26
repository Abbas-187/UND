import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/logging/logging_service.dart';
import '../../../../core/data/optimized_repository.dart';
import '../../../../core/data/unified_data_manager.dart';
import '../../domain/entities/cost_layer.dart';
import '../../domain/entities/cost_method_setting.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../models/inventory_item_model.dart';
import '../models/inventory_movement_model.dart';

/// Optimized implementation of the [InventoryRepository] interface using Firebase Firestore
class InventoryRepositoryImpl extends FirebaseOptimizedRepository<InventoryItem>
    implements InventoryRepository {
  InventoryRepositoryImpl({
    LoggingService? loggingService,
    FirebaseFirestore? firestore,
    Logger? logger,
  })  : _loggingService = loggingService ??
            LoggingService(Logger(printer: PrettyPrinter()), AppConfig()),
        super(
          firestore: firestore ?? FirebaseFirestore.instance,
          logger: logger ?? Logger(),
          collectionName: 'inventoryItems',
        );

  final LoggingService _loggingService;

  // Override optimized repository methods
  @override
  InventoryItem fromFirestore(DocumentSnapshot doc) {
    return InventoryItemModel.fromFirestore(
      doc as DocumentSnapshot<Map<String, dynamic>>,
    ).toDomain();
  }

  @override
  Map<String, dynamic> toFirestore(InventoryItem item) {
    final model = InventoryItemModel.fromDomain(item);
    final json = model.toJson();
    json.remove('id'); // Remove ID as it's handled by Firestore
    return json;
  }

  @override
  String getId(InventoryItem item) => item.id;

  // Legacy collection references for backward compatibility
  CollectionReference<Map<String, dynamic>> get _inventoryCollection =>
      firestore.collection('inventoryItems');

  CollectionReference get _movementsCollection =>
      firestore.collection('inventory_movements');

  CollectionReference get _costLayersCollection =>
      firestore.collection('inventory_cost_layers');

  // Implement InventoryRepository interface methods using optimized base
  @override
  Future<List<InventoryItem>> getItems() async {
    return await PerformanceMonitor.trackAsync(
      'inventory_get_items',
      () async {
        final result = await findMany(const QueryParams(limit: 1000));
        return result.items;
      },
    );
  }

  @override
  Future<InventoryItem?> getItem(String id) async {
    return await PerformanceMonitor.trackAsync(
      'inventory_get_item',
      () async {
        return await findById(id);
      },
    );
  }

  @override
  Future<InventoryItem> addItem(InventoryItem item) async {
    return await PerformanceMonitor.trackAsync(
      'inventory_add_item',
      () async {
        final savedItem = await create(item);

        // Emit domain event
        UnifiedDataManager.instance.publishEvent(InventoryUpdatedEvent(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          aggregateId: savedItem.id,
          itemId: savedItem.id,
          oldQuantity: 0,
          newQuantity: savedItem.quantity,
          reason: 'Item created',
        ));

        return savedItem;
      },
    );
  }

  @override
  Future<void> updateItem(InventoryItem item) async {
    await PerformanceMonitor.trackAsync(
      'inventory_update_item',
      () async {
        // Get old quantity for event
        final oldItem = await findById(item.id);
        final oldQuantity = oldItem?.quantity ?? 0;

        await update(item.id, item);

        // Emit domain event
        UnifiedDataManager.instance.publishEvent(InventoryUpdatedEvent(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          aggregateId: item.id,
          itemId: item.id,
          oldQuantity: oldQuantity,
          newQuantity: item.quantity,
          reason: 'Item updated',
        ));
      },
    );
  }

  @override
  Future<void> deleteItem(String id) async {
    await PerformanceMonitor.trackAsync(
      'inventory_delete_item',
      () async {
        await delete(id);

        // Emit domain event
        UnifiedDataManager.instance.publishEvent(InventoryUpdatedEvent(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          aggregateId: id,
          itemId: id,
          oldQuantity: 0,
          newQuantity: 0,
          reason: 'Item deleted',
        ));
      },
    );
  }

  @override
  Stream<List<InventoryItem>> watchAllItems() {
    return watchMany(const QueryParams(limit: 1000));
  }

  @override
  Stream<InventoryItem> watchItem(String id) {
    return watchById(id).map((item) => item!);
  }

  // Optimized methods using the base class
  @override
  Future<List<InventoryItem>> getLowStockItems() async {
    return await PerformanceMonitor.trackAsync(
      'inventory_get_low_stock',
      () async {
        const cacheKey = 'inventory_low_stock_items';

        final cached = SmartCache.get<List<InventoryItem>>(cacheKey);
        if (cached != null) {
          logger.d('Cache hit for low stock items');
          return cached;
        }

        final result = await findMany(const QueryParams(limit: 1000));
        final lowStockItems = result.items
            .where((item) => item.quantity <= item.lowStockThreshold)
            .toList();

        SmartCache.set(cacheKey, lowStockItems,
            ttl: const Duration(minutes: 5));
        return lowStockItems;
      },
    );
  }

  @override
  Future<List<InventoryItem>> getItemsNeedingReorder() async {
    return await PerformanceMonitor.trackAsync(
      'inventory_get_reorder_items',
      () async {
        const cacheKey = 'inventory_reorder_items';

        final cached = SmartCache.get<List<InventoryItem>>(cacheKey);
        if (cached != null) {
          return cached;
        }

        final result = await findMany(const QueryParams(limit: 1000));
        final reorderItems = result.items
            .where((item) => item.quantity <= item.reorderPoint)
            .toList();

        SmartCache.set(cacheKey, reorderItems, ttl: const Duration(minutes: 5));
        return reorderItems;
      },
    );
  }

  @override
  Future<List<InventoryItem>> searchItems(String query) async {
    return await PerformanceMonitor.trackAsync(
      'inventory_search_items',
      () async {
        final result = await findMany(QueryParams(
          searchTerm: query,
          limit: 100,
        ));
        return result.items;
      },
    );
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
    return await PerformanceMonitor.trackAsync(
      'inventory_filter_items',
      () async {
        final filters = <String, dynamic>{};

        if (category != null && category.isNotEmpty) {
          filters['category'] = category;
        }
        if (subCategory != null && subCategory.isNotEmpty) {
          filters['subCategory'] = subCategory;
        }
        if (location != null && location.isNotEmpty) {
          filters['location'] = location;
        }
        if (supplier != null && supplier.isNotEmpty) {
          filters['supplier'] = supplier;
        }

        final result = await findMany(QueryParams(
          filters: filters,
          limit: 1000,
        ));

        var items = result.items;

        // Client-side filters for complex conditions
        if (lowStock == true) {
          items = items
              .where((item) => item.quantity <= item.lowStockThreshold)
              .toList();
        }
        if (needsReorder == true) {
          items = items
              .where((item) => item.quantity <= item.reorderPoint)
              .toList();
        }
        if (expired == true) {
          final now = DateTime.now();
          items = items
              .where((item) =>
                  item.expiryDate != null && item.expiryDate!.isBefore(now))
              .toList();
        }

        return items;
      },
    );
  }

  @override
  Future<void> batchUpdateItems(List<InventoryItem> items) async {
    await PerformanceMonitor.trackAsync(
      'inventory_batch_update',
      () async {
        final itemMap = <String, InventoryItem>{};
        for (final item in items) {
          itemMap[item.id] = item;
        }

        await updateBatch(itemMap);

        // Emit events for all updated items
        for (final item in items) {
          UnifiedDataManager.instance.publishEvent(InventoryUpdatedEvent(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            timestamp: DateTime.now(),
            aggregateId: item.id,
            itemId: item.id,
            oldQuantity: 0, // We don't have old quantity in batch update
            newQuantity: item.quantity,
            reason: 'Batch update',
          ));
        }
      },
    );
  }

  @override
  Future<InventoryItem> adjustQuantity(String id, double adjustment,
      String reason, String initiatingEmployeeId) async {
    return await PerformanceMonitor.trackAsync(
      'inventory_adjust_quantity',
      () async {
        final item = await findById(id);
        if (item == null) {
          throw Exception('Item not found: $id');
        }

        final oldQuantity = item.quantity;
        final newQuantity = oldQuantity + adjustment;

        final updatedItem = item.copyWith(
          quantity: newQuantity,
          lastUpdated: DateTime.now(),
        );

        await update(id, updatedItem);

        // Emit domain event
        UnifiedDataManager.instance.publishEvent(InventoryUpdatedEvent(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          aggregateId: id,
          itemId: id,
          oldQuantity: oldQuantity,
          newQuantity: newQuantity,
          reason: reason,
        ));

        return updatedItem;
      },
    );
  }

  // Legacy methods - keeping for backward compatibility
  @override
  Future<List<InventoryItem>> getItemsBelowReorderLevel() async {
    return getItemsNeedingReorder();
  }

  @override
  Future<List<InventoryItem>> getItemsAtCriticalLevel() async {
    return getLowStockItems();
  }

  @override
  Future<List<InventoryItem>> getExpiringItems(DateTime before) async {
    return await PerformanceMonitor.trackAsync(
      'inventory_get_expiring_items',
      () async {
        final result = await findMany(const QueryParams(limit: 1000));
        return result.items
            .where((item) =>
                item.expiryDate != null && item.expiryDate!.isBefore(before))
            .toList();
      },
    );
  }

  @override
  Future<List<dynamic>> getItemMovementHistory(String id) async {
    try {
      final adjustments = await firestore
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
  Future<List<InventoryItem>> getTopMovingItems(int limit) async {
    return await PerformanceMonitor.trackAsync(
      'inventory_get_top_moving',
      () async {
        final result = await findMany(QueryParams(
          limit: limit,
          orderBy: 'quantity',
          orderDirection: 'desc',
        ));
        return result.items;
      },
    );
  }

  @override
  Future<List<InventoryItem>> getSlowMovingItems(int limit) async {
    return await PerformanceMonitor.trackAsync(
      'inventory_get_slow_moving',
      () async {
        final result = await findMany(QueryParams(
          limit: limit,
          orderBy: 'quantity',
          orderDirection: 'asc',
        ));
        return result.items;
      },
    );
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
  Future<int> countBomsUsingItem(String itemId) async {
    try {
      final querySnapshot = await firestore
          .collection('boms')
          .where('ingredients', arrayContains: itemId)
          .get();
      return querySnapshot.docs.length;
    } catch (e, stackTrace) {
      _loggingService.error('Failed to count BOMs using item', e, stackTrace);
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
            warehouseId: movement.warehouseId,
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
        final batch = firestore.batch();
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
      final costLayers = snapshot.docs.map((doc) {
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

      // Fetch inventory item for quality status
      final itemDoc = await _inventoryCollection.doc(itemId).get();
      if (!itemDoc.exists) return [];
      final item = InventoryItemModel.fromFirestore(itemDoc).toDomain();
      final attrs = item.additionalAttributes ?? {};
      final batchStatuses =
          attrs['batchQualityStatus'] as Map<String, dynamic>?;
      final itemStatus = attrs['qualityStatus'];

      // Filter cost layers by quality status == 'AVAILABLE'
      final filtered = costLayers.where((layer) {
        if (batchStatuses != null) {
          final status = batchStatuses[layer.batchLotNumber];
          return status == 'AVAILABLE';
        }
        return itemStatus == 'AVAILABLE';
      }).toList();

      // Sort by movementDate (FIFO by default)
      filtered.sort((a, b) => a.movementDate.compareTo(b.movementDate));
      return filtered;
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

  @override
  Future<bool> allocateInventoryForBom(String bomId, double quantity) async {
    // Implement logic to allocate inventory for a BOM
    // This is a placeholder implementation
    throw UnimplementedError('allocateInventoryForBom is not implemented yet.');
  }

  @override
  Future<void> batchDeleteItems(List<String> ids) async {
    await PerformanceMonitor.trackAsync(
      'inventory_batch_delete',
      () async {
        await deleteBatch(ids);

        // Emit events for all deleted items
        for (final id in ids) {
          UnifiedDataManager.instance.publishEvent(InventoryUpdatedEvent(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            timestamp: DateTime.now(),
            aggregateId: id,
            itemId: id,
            oldQuantity: 0,
            newQuantity: 0,
            reason: 'Batch delete',
          ));
        }
      },
    );
  }

  @override
  Stream<List<InventoryItem>> watchLowStockItems() {
    return watchMany(const QueryParams(limit: 1000)).map((items) => items
        .where((item) => item.quantity <= item.lowStockThreshold)
        .toList());
  }

  @override
  Future<Map<String, double>> getInventoryValueByCategory() async {
    return await PerformanceMonitor.trackAsync(
      'inventory_get_value_by_category',
      () async {
        const cacheKey = 'inventory_value_by_category';

        final cached = SmartCache.get<Map<String, double>>(cacheKey);
        if (cached != null) {
          return cached;
        }

        final result = await findMany(const QueryParams(limit: 1000));
        final valueByCategory = <String, double>{};

        for (final item in result.items) {
          final value = (item.cost ?? 0) * item.quantity;
          valueByCategory[item.category] =
              (valueByCategory[item.category] ?? 0) + value;
        }

        SmartCache.set(cacheKey, valueByCategory,
            ttl: const Duration(minutes: 10));
        return valueByCategory;
      },
    );
  }
}
