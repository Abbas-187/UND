import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'unified_data_manager.dart';

/// Query parameters for optimized data fetching
class QueryParams {
  const QueryParams({
    this.limit = 50,
    this.offset = 0,
    this.orderBy,
    this.orderDirection = 'asc',
    this.filters = const {},
    this.searchTerm,
    this.startAfter,
    this.endBefore,
  });

  final int limit;
  final int offset;
  final String? orderBy;
  final String orderDirection;
  final Map<String, dynamic> filters;
  final String? searchTerm;
  final DocumentSnapshot? startAfter;
  final DocumentSnapshot? endBefore;

  QueryParams copyWith({
    int? limit,
    int? offset,
    String? orderBy,
    String? orderDirection,
    Map<String, dynamic>? filters,
    String? searchTerm,
    DocumentSnapshot? startAfter,
    DocumentSnapshot? endBefore,
  }) {
    return QueryParams(
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      orderBy: orderBy ?? this.orderBy,
      orderDirection: orderDirection ?? this.orderDirection,
      filters: filters ?? this.filters,
      searchTerm: searchTerm ?? this.searchTerm,
      startAfter: startAfter ?? this.startAfter,
      endBefore: endBefore ?? this.endBefore,
    );
  }
}

/// Paginated result wrapper
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.hasMore,
    required this.totalCount,
    this.lastDocument,
    this.firstDocument,
  });

  final List<T> items;
  final bool hasMore;
  final int totalCount;
  final DocumentSnapshot? lastDocument;
  final DocumentSnapshot? firstDocument;
}

/// Base optimized repository interface
abstract class OptimizedRepository<T> {
  /// Get single item by ID with caching
  Future<T?> findById(String id, {bool useCache = true});

  /// Get multiple items with pagination and caching
  Future<PaginatedResult<T>> findMany(QueryParams params,
      {bool useCache = true});

  /// Watch items with real-time updates (optimized)
  Stream<List<T>> watchMany(QueryParams params);

  /// Watch single item with real-time updates
  Stream<T?> watchById(String id);

  /// Create new item
  Future<T> create(T item);

  /// Update existing item
  Future<T> update(String id, T item);

  /// Delete item
  Future<void> delete(String id);

  /// Batch operations
  Future<List<T>> createBatch(List<T> items);
  Future<List<T>> updateBatch(Map<String, T> items);
  Future<void> deleteBatch(List<String> ids);

  /// Search functionality
  Future<List<T>> search(String query, {QueryParams? params});

  /// Count items matching criteria
  Future<int> count({Map<String, dynamic>? filters});

  /// Sync with remote (for offline support)
  Future<void> sync();

  /// Clear local cache
  Future<void> clearCache();
}

/// Firebase-based optimized repository implementation
abstract class FirebaseOptimizedRepository<T>
    implements OptimizedRepository<T> {
  FirebaseOptimizedRepository({
    required this.firestore,
    required this.collectionName,
    required this.logger,
  });

  final FirebaseFirestore firestore;
  final String collectionName;
  final Logger logger;

  /// Convert Firestore document to entity
  T fromFirestore(DocumentSnapshot doc);

  /// Convert entity to Firestore data
  Map<String, dynamic> toFirestore(T item);

  /// Get entity ID
  String getId(T item);

  /// Generate cache key
  String _getCacheKey(String operation, [String? id, QueryParams? params]) {
    final parts = [collectionName, operation];
    if (id != null) parts.add(id);
    if (params != null) {
      parts.add('limit_${params.limit}');
      parts.add('offset_${params.offset}');
      if (params.orderBy != null) parts.add('order_${params.orderBy}');
      if (params.filters.isNotEmpty) {
        parts.add('filters_${params.filters.hashCode}');
      }
    }
    return parts.join('_');
  }

  @override
  Future<T?> findById(String id, {bool useCache = true}) async {
    return await PerformanceMonitor.trackAsync(
      'repository_find_by_id_$collectionName',
      () async {
        if (useCache) {
          final cached = SmartCache.get<T>(_getCacheKey('find_by_id', id));
          if (cached != null) {
            logger.d('Cache hit for $collectionName:$id');
            return cached;
          }
        }

        final doc = await firestore.collection(collectionName).doc(id).get();
        if (!doc.exists) return null;

        final item = fromFirestore(doc);
        if (useCache) {
          SmartCache.set(_getCacheKey('find_by_id', id), item);
        }

        return item;
      },
    );
  }

  @override
  Future<PaginatedResult<T>> findMany(
    QueryParams params, {
    bool useCache = true,
  }) async {
    return await PerformanceMonitor.trackAsync(
      'repository_find_many_$collectionName',
      () async {
        final cacheKey = _getCacheKey('find_many', null, params);

        if (useCache) {
          final cached = SmartCache.get<PaginatedResult<T>>(cacheKey);
          if (cached != null) {
            logger.d('Cache hit for $collectionName query');
            return cached;
          }
        }

        Query query = firestore.collection(collectionName);

        // Apply filters
        for (final entry in params.filters.entries) {
          query = query.where(entry.key, isEqualTo: entry.value);
        }

        // Apply ordering
        if (params.orderBy != null) {
          query = query.orderBy(
            params.orderBy!,
            descending: params.orderDirection == 'desc',
          );
        }

        // Apply pagination
        if (params.startAfter != null) {
          query = query.startAfterDocument(params.startAfter!);
        }

        query = query.limit(params.limit);

        final snapshot = await query.get();
        final items = snapshot.docs.map((doc) => fromFirestore(doc)).toList();

        // Get total count (expensive operation, consider caching)
        final totalCount = await _getTotalCount(params.filters);

        final result = PaginatedResult<T>(
          items: items,
          hasMore: items.length == params.limit,
          totalCount: totalCount,
          lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
          firstDocument: snapshot.docs.isNotEmpty ? snapshot.docs.first : null,
        );

        if (useCache) {
          SmartCache.set(cacheKey, result, ttl: const Duration(minutes: 2));
        }

        return result;
      },
    );
  }

  @override
  Stream<List<T>> watchMany(QueryParams params) {
    Query query = firestore.collection(collectionName);

    // Apply filters
    for (final entry in params.filters.entries) {
      query = query.where(entry.key, isEqualTo: entry.value);
    }

    // Apply ordering
    if (params.orderBy != null) {
      query = query.orderBy(
        params.orderBy!,
        descending: params.orderDirection == 'desc',
      );
    }

    // Apply limit
    query = query.limit(params.limit);

    return query.snapshots().map((snapshot) {
      final items = snapshot.docs.map((doc) => fromFirestore(doc)).toList();

      // Update cache with fresh data
      final cacheKey = _getCacheKey('find_many', null, params);
      SmartCache.set(
          cacheKey,
          PaginatedResult<T>(
            items: items,
            hasMore: items.length == params.limit,
            totalCount: items.length, // Approximate
          ));

      return items;
    });
  }

  @override
  Stream<T?> watchById(String id) {
    return firestore.collection(collectionName).doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;

      final item = fromFirestore(doc);

      // Update cache
      SmartCache.set(_getCacheKey('find_by_id', id), item);

      return item;
    });
  }

  @override
  Future<T> create(T item) async {
    return await PerformanceMonitor.trackAsync(
      'repository_create_$collectionName',
      () async {
        final data = toFirestore(item);
        final docRef = await firestore.collection(collectionName).add(data);

        // Invalidate related caches
        SmartCache.invalidatePattern('${collectionName}_find_many.*');

        // Get the created item with ID
        final doc = await docRef.get();
        return fromFirestore(doc);
      },
    );
  }

  @override
  Future<T> update(String id, T item) async {
    return await PerformanceMonitor.trackAsync(
      'repository_update_$collectionName',
      () async {
        final data = toFirestore(item);
        await firestore.collection(collectionName).doc(id).update(data);

        // Invalidate caches
        SmartCache.invalidate(_getCacheKey('find_by_id', id));
        SmartCache.invalidatePattern('${collectionName}_find_many.*');

        return item;
      },
    );
  }

  @override
  Future<void> delete(String id) async {
    await PerformanceMonitor.trackAsync(
      'repository_delete_$collectionName',
      () async {
        await firestore.collection(collectionName).doc(id).delete();

        // Invalidate caches
        SmartCache.invalidate(_getCacheKey('find_by_id', id));
        SmartCache.invalidatePattern('${collectionName}_find_many.*');
      },
    );
  }

  @override
  Future<List<T>> createBatch(List<T> items) async {
    return await PerformanceMonitor.trackAsync(
      'repository_create_batch_$collectionName',
      () async {
        final batch = firestore.batch();
        final refs = <DocumentReference>[];

        for (final item in items) {
          final ref = firestore.collection(collectionName).doc();
          batch.set(ref, toFirestore(item));
          refs.add(ref);
        }

        await batch.commit();

        // Invalidate caches
        SmartCache.invalidatePattern('${collectionName}_find_many.*');

        // Return created items (simplified - in real implementation,
        // you'd fetch the actual documents with IDs)
        return items;
      },
    );
  }

  @override
  Future<List<T>> updateBatch(Map<String, T> items) async {
    return await PerformanceMonitor.trackAsync(
      'repository_update_batch_$collectionName',
      () async {
        final batch = firestore.batch();

        for (final entry in items.entries) {
          final ref = firestore.collection(collectionName).doc(entry.key);
          batch.update(ref, toFirestore(entry.value));
        }

        await batch.commit();

        // Invalidate caches
        for (final id in items.keys) {
          SmartCache.invalidate(_getCacheKey('find_by_id', id));
        }
        SmartCache.invalidatePattern('${collectionName}_find_many.*');

        return items.values.toList();
      },
    );
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    await PerformanceMonitor.trackAsync(
      'repository_delete_batch_$collectionName',
      () async {
        final batch = firestore.batch();

        for (final id in ids) {
          final ref = firestore.collection(collectionName).doc(id);
          batch.delete(ref);
        }

        await batch.commit();

        // Invalidate caches
        for (final id in ids) {
          SmartCache.invalidate(_getCacheKey('find_by_id', id));
        }
        SmartCache.invalidatePattern('${collectionName}_find_many.*');
      },
    );
  }

  @override
  Future<List<T>> search(String query, {QueryParams? params}) async {
    // Basic text search implementation
    // For advanced search, consider using Algolia or similar
    final searchParams = params ?? const QueryParams();
    final result = await findMany(searchParams.copyWith(
      filters: {
        ...searchParams.filters,
        // Add text search logic here
      },
    ));

    return result.items.where((item) {
      // Implement client-side filtering for now
      // In production, use proper search service
      return true; // Placeholder
    }).toList();
  }

  @override
  Future<int> count({Map<String, dynamic>? filters}) async {
    return await _getTotalCount(filters ?? {});
  }

  Future<int> _getTotalCount(Map<String, dynamic> filters) async {
    // This is expensive - consider using aggregation queries in production
    Query query = firestore.collection(collectionName);

    for (final entry in filters.entries) {
      query = query.where(entry.key, isEqualTo: entry.value);
    }

    final snapshot = await query.get();
    return snapshot.docs.length;
  }

  @override
  Future<void> sync() async {
    // Implement offline sync logic
    logger.i('Syncing $collectionName...');
  }

  @override
  Future<void> clearCache() async {
    SmartCache.invalidatePattern('${collectionName}_.*');
  }
}
