import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/bill_of_materials.dart';
import 'cache_strategies.dart';

/// Comprehensive caching manager for BOM data
class BomCacheManager {
  factory BomCacheManager() => _instance;
  BomCacheManager._internal();
  static final BomCacheManager _instance = BomCacheManager._internal();

  final Map<String, CachedData> _cache = {};
  final Map<String, Timer> _expirationTimers = {};
  final Logger _logger = Logger();
  final StreamController<CacheEvent> _cacheEventController =
      StreamController<CacheEvent>.broadcast();

  /// Stream of cache events for monitoring
  Stream<CacheEvent> get cacheEvents => _cacheEventController.stream;

  /// Default TTL for different data types
  static const Duration _bomDataTtl = Duration(minutes: 15);
  static const Duration _costCalculationTtl = Duration(minutes: 10);
  static const Duration _supplierDataTtl = Duration(minutes: 30);
  static const Duration _inventoryDataTtl = Duration(minutes: 5);

  /// Get cached data
  Future<T?> get<T>(String key) async {
    final cached = _cache[key];

    if (cached == null) {
      _logCacheEvent(CacheEventType.miss, key);
      return null;
    }

    if (cached.isExpired) {
      await invalidate(key);
      _logCacheEvent(CacheEventType.expired, key);
      return null;
    }

    _logCacheEvent(CacheEventType.hit, key);
    cached.updateLastAccessed();
    return cached.data as T;
  }

  /// Set cached data with optional TTL
  Future<void> set<T>(
    String key,
    T data, {
    Duration? ttl,
    CacheStrategy strategy = CacheStrategy.timeToLive,
  }) async {
    final effectiveTtl = ttl ?? _getDefaultTtl(key);

    // Cancel existing expiration timer
    _expirationTimers[key]?.cancel();

    // Create cached data entry
    final cachedData = CachedData(
      data: data,
      expiresAt: DateTime.now().add(effectiveTtl),
      strategy: strategy,
      size: _calculateDataSize(data),
    );

    _cache[key] = cachedData;

    // Set expiration timer
    _expirationTimers[key] = Timer(effectiveTtl, () {
      invalidate(key);
    });

    _logCacheEvent(CacheEventType.set, key, dataSize: cachedData.size);

    // Check cache size limits
    await _enforceMemoryLimits();
  }

  /// Invalidate specific cache entry
  Future<void> invalidate(String key) async {
    _cache.remove(key);
    _expirationTimers[key]?.cancel();
    _expirationTimers.remove(key);

    _logCacheEvent(CacheEventType.invalidated, key);
  }

  /// Invalidate cache entries matching pattern
  Future<void> invalidatePattern(String pattern) async {
    final regex = RegExp(pattern);
    final keysToRemove =
        _cache.keys.where((key) => regex.hasMatch(key)).toList();

    for (final key in keysToRemove) {
      await invalidate(key);
    }

    _logCacheEvent(CacheEventType.patternInvalidated, pattern);
  }

  /// Clear all cache
  Future<void> clearAll() async {
    final count = _cache.length;

    _cache.clear();
    for (final timer in _expirationTimers.values) {
      timer.cancel();
    }
    _expirationTimers.clear();

    _logCacheEvent(CacheEventType.cleared, 'all', count: count);
  }

  /// Get cache statistics
  CacheStatistics getStatistics() {
    final now = DateTime.now();
    var totalSize = 0;
    var expiredCount = 0;
    var activeCount = 0;

    for (final entry in _cache.values) {
      totalSize += entry.size;
      if (entry.isExpired) {
        expiredCount++;
      } else {
        activeCount++;
      }
    }

    return CacheStatistics(
      totalEntries: _cache.length,
      activeEntries: activeCount,
      expiredEntries: expiredCount,
      totalSizeBytes: totalSize,
      hitRate: _calculateHitRate(),
      averageAccessTime: _calculateAverageAccessTime(),
    );
  }

  /// BOM-specific caching methods

  /// Cache BOM data
  Future<void> cacheBom(BillOfMaterials bom) async {
    await set('bom:${bom.id}', bom, ttl: _bomDataTtl);

    // Cache BOM items separately for faster access
    for (final item in bom.items) {
      await set('bom_item:${item.id}', item, ttl: _bomDataTtl);
    }
  }

  /// Get cached BOM
  Future<BillOfMaterials?> getCachedBom(String bomId) async {
    return await get<BillOfMaterials>('bom:$bomId');
  }

  /// Cache BOM cost calculation
  Future<void> cacheBomCost(
      String bomId, double totalCost, Map<String, double> itemCosts) async {
    final costData = {
      'total_cost': totalCost,
      'item_costs': itemCosts,
      'calculated_at': DateTime.now().toIso8601String(),
    };

    await set('bom_cost:$bomId', costData, ttl: _costCalculationTtl);
  }

  /// Get cached BOM cost
  Future<Map<String, dynamic>?> getCachedBomCost(String bomId) async {
    return await get<Map<String, dynamic>>('bom_cost:$bomId');
  }

  /// Cache supplier information
  Future<void> cacheSupplierData(
      String supplierId, Map<String, dynamic> data) async {
    await set('supplier:$supplierId', data, ttl: _supplierDataTtl);
  }

  /// Cache inventory availability
  Future<void> cacheInventoryAvailability(
      String itemId, double availableQuantity) async {
    final inventoryData = {
      'available_quantity': availableQuantity,
      'checked_at': DateTime.now().toIso8601String(),
    };

    await set('inventory:$itemId', inventoryData, ttl: _inventoryDataTtl);
  }

  /// Cache BOM search results
  Future<void> cacheBomSearchResults(
      String searchKey, List<BillOfMaterials> results) async {
    await set('search:$searchKey', results, ttl: Duration(minutes: 5));
  }

  /// Get cached search results
  Future<List<BillOfMaterials>?> getCachedSearchResults(
      String searchKey) async {
    return await get<List<BillOfMaterials>>('search:$searchKey');
  }

  /// Smart invalidation based on data relationships

  /// Invalidate BOM-related cache when BOM is updated
  Future<void> invalidateBomCache(String bomId) async {
    await invalidatePattern('bom:$bomId');
    await invalidatePattern('bom_cost:$bomId');
    await invalidatePattern('bom_item:.*'); // Invalidate all BOM items
    await invalidatePattern('search:.*'); // Invalidate search results
  }

  /// Invalidate inventory-related cache when inventory changes
  Future<void> invalidateInventoryCache(String itemId) async {
    await invalidatePattern('inventory:$itemId');
    await invalidatePattern(
        'bom_cost:.*'); // Cost calculations depend on inventory
  }

  /// Invalidate supplier-related cache when supplier data changes
  Future<void> invalidateSupplierCache(String supplierId) async {
    await invalidatePattern('supplier:$supplierId');
    await invalidatePattern(
        'bom_cost:.*'); // Cost calculations depend on supplier data
  }

  /// Private helper methods

  Duration _getDefaultTtl(String key) {
    if (key.startsWith('bom:')) return _bomDataTtl;
    if (key.startsWith('bom_cost:')) return _costCalculationTtl;
    if (key.startsWith('supplier:')) return _supplierDataTtl;
    if (key.startsWith('inventory:')) return _inventoryDataTtl;
    return Duration(minutes: 10); // Default TTL
  }

  int _calculateDataSize(dynamic data) {
    try {
      final jsonString = jsonEncode(data);
      return jsonString.length * 2; // Approximate size in bytes (UTF-16)
    } catch (e) {
      return 1024; // Default size estimate
    }
  }

  Future<void> _enforceMemoryLimits() async {
    const maxCacheSize = 50 * 1024 * 1024; // 50MB limit
    const maxEntries = 10000;

    final stats = getStatistics();

    if (stats.totalSizeBytes > maxCacheSize ||
        stats.totalEntries > maxEntries) {
      await _evictLeastRecentlyUsed();
    }
  }

  Future<void> _evictLeastRecentlyUsed() async {
    final entries = _cache.entries.toList();

    // Sort by last accessed time (oldest first)
    entries
        .sort((a, b) => a.value.lastAccessed.compareTo(b.value.lastAccessed));

    // Remove oldest 25% of entries
    final entriesToRemove = (entries.length * 0.25).ceil();

    for (int i = 0; i < entriesToRemove && i < entries.length; i++) {
      await invalidate(entries[i].key);
    }

    _logger.i('Evicted $entriesToRemove cache entries due to memory limits');
  }

  double _calculateHitRate() {
    // This would be calculated from actual hit/miss statistics
    // For now, return a mock value
    return 0.85;
  }

  double _calculateAverageAccessTime() {
    // This would be calculated from actual access time measurements
    // For now, return a mock value
    return 2.5; // milliseconds
  }

  void _logCacheEvent(
    CacheEventType type,
    String key, {
    int? dataSize,
    int? count,
  }) {
    final event = CacheEvent(
      type: type,
      key: key,
      timestamp: DateTime.now(),
      dataSize: dataSize,
      count: count,
    );

    _cacheEventController.add(event);

    // Log to console for debugging
    _logger.d('CACHE_EVENT: ${type.name} - $key');
  }
}

/// Cached data wrapper
class CachedData {

  CachedData({
    required this.data,
    required this.expiresAt,
    required this.strategy,
    required this.size,
  }) : lastAccessed = DateTime.now();
  final dynamic data;
  final DateTime expiresAt;
  final CacheStrategy strategy;
  final int size;
  DateTime lastAccessed;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  void updateLastAccessed() {
    lastAccessed = DateTime.now();
  }
}

/// Cache event for monitoring
class CacheEvent {

  CacheEvent({
    required this.type,
    required this.key,
    required this.timestamp,
    this.dataSize,
    this.count,
  });
  final CacheEventType type;
  final String key;
  final DateTime timestamp;
  final int? dataSize;
  final int? count;
}

/// Cache event types
enum CacheEventType {
  hit,
  miss,
  set,
  invalidated,
  patternInvalidated,
  cleared,
  expired,
  evicted,
}

/// Cache statistics
class CacheStatistics {

  CacheStatistics({
    required this.totalEntries,
    required this.activeEntries,
    required this.expiredEntries,
    required this.totalSizeBytes,
    required this.hitRate,
    required this.averageAccessTime,
  });
  final int totalEntries;
  final int activeEntries;
  final int expiredEntries;
  final int totalSizeBytes;
  final double hitRate;
  final double averageAccessTime;

  String get formattedSize {
    if (totalSizeBytes < 1024) return '${totalSizeBytes}B';
    if (totalSizeBytes < 1024 * 1024) {
      return '${(totalSizeBytes / 1024).toStringAsFixed(1)}KB';
    }
    return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// Provider for BOM cache manager
final bomCacheManagerProvider = Provider<BomCacheManager>((ref) {
  return BomCacheManager();
});
