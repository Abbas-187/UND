import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../../../../core/data/optimized_repository.dart';
import '../../../../core/data/unified_data_manager.dart';
import '../../domain/entities/inventory_item.dart';

class OptimizedInventoryRepository
    extends FirebaseOptimizedRepository<InventoryItem> {
  OptimizedInventoryRepository({
    required super.firestore,
    required super.logger,
  }) : super(collectionName: 'inventory');

  @override
  InventoryItem fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryItem.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  @override
  Map<String, dynamic> toFirestore(InventoryItem item) {
    final json = item.toJson();
    json.remove('id'); // Remove ID as it's handled by Firestore
    return json;
  }

  @override
  String getId(InventoryItem item) => item.id;

  /// Get low stock items with caching
  Future<List<InventoryItem>> getLowStockItems({bool useCache = true}) async {
    return await PerformanceMonitor.trackAsync(
      'inventory_get_low_stock',
      () async {
        const cacheKey = 'inventory_low_stock_items';

        if (useCache) {
          final cached = SmartCache.get<List<InventoryItem>>(cacheKey);
          if (cached != null) {
            logger.d('Cache hit for low stock items');
            return cached;
          }
        }

        final result = await findMany(const QueryParams(
          filters: {},
          limit: 1000, // Get all items for low stock check
        ));

        final lowStockItems =
            result.items.where((item) => item.isLowStock).toList();

        if (useCache) {
          SmartCache.set(cacheKey, lowStockItems,
              ttl: const Duration(minutes: 1));
        }

        return lowStockItems;
      },
    );
  }

  /// Get expired items with caching
  Future<List<InventoryItem>> getExpiredItems({bool useCache = true}) async {
    return await PerformanceMonitor.trackAsync(
      'inventory_get_expired',
      () async {
        const cacheKey = 'inventory_expired_items';

        if (useCache) {
          final cached = SmartCache.get<List<InventoryItem>>(cacheKey);
          if (cached != null) {
            logger.d('Cache hit for expired items');
            return cached;
          }
        }

        final result = await findMany(const QueryParams(
          filters: {},
          limit: 1000,
        ));

        final expiredItems =
            result.items.where((item) => item.isExpired).toList();

        if (useCache) {
          SmartCache.set(cacheKey, expiredItems,
              ttl: const Duration(minutes: 5));
        }

        return expiredItems;
      },
    );
  }

  /// Get items by category with optimized caching
  Future<List<InventoryItem>> getItemsByCategory(
    String category, {
    bool useCache = true,
    int limit = 50,
  }) async {
    return await PerformanceMonitor.trackAsync(
      'inventory_get_by_category',
      () async {
        final result = await findMany(
          QueryParams(
            filters: {'category': category},
            limit: limit,
            orderBy: 'name',
          ),
          useCache: useCache,
        );

        return result.items;
      },
    );
  }

  /// Update inventory quantity with event publishing
  Future<InventoryItem> updateQuantity(
    String itemId,
    double newQuantity, {
    required String reason,
  }) async {
    return await PerformanceMonitor.trackAsync(
      'inventory_update_quantity',
      () async {
        final currentItem = await findById(itemId);
        if (currentItem == null) {
          throw Exception('Inventory item not found: $itemId');
        }

        final oldQuantity = currentItem.quantity;
        final updatedItem = currentItem.copyWith(
          quantity: newQuantity,
          lastUpdated: DateTime.now(),
        );

        final result = await update(itemId, updatedItem);

        // Publish domain event
        UnifiedDataManager.instance.publishEvent(
          InventoryUpdatedEvent(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            timestamp: DateTime.now(),
            aggregateId: itemId,
            itemId: itemId,
            newQuantity: newQuantity,
            oldQuantity: oldQuantity,
            reason: reason,
          ),
        );

        // Invalidate related caches
        SmartCache.invalidate('inventory_low_stock_items');
        SmartCache.invalidate('inventory_expired_items');

        return result;
      },
    );
  }

  /// Batch update quantities for production consumption
  Future<void> updateQuantitiesFromProduction(
    Map<String, double> materialConsumption,
  ) async {
    await PerformanceMonitor.trackAsync(
      'inventory_batch_update_production',
      () async {
        final updates = <String, InventoryItem>{};

        for (final entry in materialConsumption.entries) {
          final materialId = entry.key;
          final consumedQuantity = entry.value;

          final currentItem = await findById(materialId);
          if (currentItem != null) {
            final newQuantity = currentItem.quantity - consumedQuantity;
            updates[materialId] = currentItem.copyWith(
              quantity: newQuantity,
              lastUpdated: DateTime.now(),
            );
          }
        }

        if (updates.isNotEmpty) {
          await updateBatch(updates);

          // Publish events for each update
          for (final entry in updates.entries) {
            final itemId = entry.key;
            final updatedItem = entry.value;
            final consumedQuantity = materialConsumption[itemId]!;

            UnifiedDataManager.instance.publishEvent(
              InventoryUpdatedEvent(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                timestamp: DateTime.now(),
                aggregateId: itemId,
                itemId: itemId,
                newQuantity: updatedItem.quantity,
                oldQuantity: updatedItem.quantity + consumedQuantity,
                reason: 'Production consumption',
              ),
            );
          }
        }

        // Invalidate caches
        SmartCache.invalidate('inventory_low_stock_items');
        SmartCache.invalidate('inventory_expired_items');
      },
    );
  }

  /// Get inventory metrics with background calculation
  Future<Map<String, dynamic>> getInventoryMetrics(
      {bool useCache = true}) async {
    return await PerformanceMonitor.trackAsync(
      'inventory_get_metrics',
      () async {
        const cacheKey = 'inventory_metrics';

        if (useCache) {
          final cached = SmartCache.get<Map<String, dynamic>>(cacheKey);
          if (cached != null) {
            logger.d('Cache hit for inventory metrics');
            return cached;
          }
        }

        // Get all inventory data
        final result = await findMany(const QueryParams(limit: 10000));

        // Convert to format suitable for background processing
        final inventoryData =
            result.items.map((item) => item.toJson()).toList();

        // Calculate metrics in background isolate
        final metrics =
            await BackgroundCalculationService.calculateInventoryMetricsAsync(
          inventoryData,
        );

        if (useCache) {
          SmartCache.set(cacheKey, metrics, ttl: const Duration(minutes: 10));
        }

        return metrics;
      },
    );
  }

  /// Search inventory items with optimized text search
  @override
  Future<List<InventoryItem>> search(String query,
      {QueryParams? params}) async {
    return await PerformanceMonitor.trackAsync(
      'inventory_search',
      () async {
        final searchParams = params ?? const QueryParams();

        // For now, implement client-side search
        // In production, consider using Algolia or Elasticsearch
        final result = await findMany(searchParams);

        final searchTermLower = query.toLowerCase();
        return result.items.where((item) {
          return item.name.toLowerCase().contains(searchTermLower) ||
              item.category.toLowerCase().contains(searchTermLower) ||
              item.sapCode.toLowerCase().contains(searchTermLower) ||
              (item.supplier?.toLowerCase().contains(searchTermLower) ?? false);
        }).toList();
      },
    );
  }

  /// Watch low stock items with real-time updates
  Stream<List<InventoryItem>> watchLowStockItems() {
    return watchMany(const QueryParams(limit: 1000))
        .map((items) => items.where((item) => item.isLowStock).toList());
  }

  /// Watch items expiring soon
  Stream<List<InventoryItem>> watchExpiringItems({int daysAhead = 7}) {
    final cutoffDate = DateTime.now().add(Duration(days: daysAhead));

    return watchMany(const QueryParams(limit: 1000))
        .map((items) => items.where((item) {
              return item.expiryDate != null &&
                  item.expiryDate!.isBefore(cutoffDate) &&
                  !item.isExpired;
            }).toList());
  }

  /// Get items requiring reorder
  Future<List<InventoryItem>> getItemsRequiringReorder(
      {bool useCache = true}) async {
    return await PerformanceMonitor.trackAsync(
      'inventory_get_reorder_items',
      () async {
        const cacheKey = 'inventory_reorder_items';

        if (useCache) {
          final cached = SmartCache.get<List<InventoryItem>>(cacheKey);
          if (cached != null) {
            logger.d('Cache hit for reorder items');
            return cached;
          }
        }

        final result = await findMany(const QueryParams(limit: 1000));
        final reorderItems =
            result.items.where((item) => item.needsReorder).toList();

        if (useCache) {
          SmartCache.set(cacheKey, reorderItems,
              ttl: const Duration(minutes: 5));
        }

        return reorderItems;
      },
    );
  }

  /// Bulk import inventory items with optimized batch processing
  Future<List<InventoryItem>> bulkImport(List<InventoryItem> items) async {
    return await PerformanceMonitor.trackAsync(
      'inventory_bulk_import',
      () async {
        // Process in chunks to avoid Firestore limits
        const chunkSize = 500;
        final results = <InventoryItem>[];

        for (int i = 0; i < items.length; i += chunkSize) {
          final chunk = items.skip(i).take(chunkSize).toList();
          final chunkResults = await createBatch(chunk);
          results.addAll(chunkResults);
        }

        // Invalidate all caches after bulk import
        await clearCache();

        return results;
      },
    );
  }
}
