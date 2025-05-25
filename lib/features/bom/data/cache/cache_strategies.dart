/// Cache strategies and related enums for BOM caching system
library cache_strategies;

/// Different caching strategies available
enum CacheStrategy {
  /// Time-to-live based caching
  timeToLive,

  /// Least recently used eviction
  leastRecentlyUsed,

  /// Write-through caching
  writeThrough,

  /// Write-behind caching
  writeBehind,

  /// Read-through caching
  readThrough,

  /// Cache-aside pattern
  cacheAside,
}

/// Cache invalidation strategies
enum InvalidationStrategy {
  /// Manual invalidation
  manual,

  /// Time-based expiration
  timeBased,

  /// Event-driven invalidation
  eventDriven,

  /// Pattern-based invalidation
  patternBased,
}

/// Cache priority levels
enum CachePriority {
  /// Low priority - first to be evicted
  low,

  /// Normal priority
  normal,

  /// High priority - last to be evicted
  high,

  /// Critical priority - never evicted automatically
  critical,
}

/// Cache configuration for different data types
class CacheConfig {
  final Duration ttl;
  final CacheStrategy strategy;
  final InvalidationStrategy invalidationStrategy;
  final CachePriority priority;
  final int maxSize;
  final bool enableCompression;

  const CacheConfig({
    required this.ttl,
    this.strategy = CacheStrategy.timeToLive,
    this.invalidationStrategy = InvalidationStrategy.timeBased,
    this.priority = CachePriority.normal,
    this.maxSize = 1000,
    this.enableCompression = false,
  });

  /// Default configuration for BOM data
  static const bomData = CacheConfig(
    ttl: Duration(minutes: 15),
    strategy: CacheStrategy.timeToLive,
    priority: CachePriority.high,
    maxSize: 500,
  );

  /// Default configuration for cost calculations
  static const costCalculations = CacheConfig(
    ttl: Duration(minutes: 10),
    strategy: CacheStrategy.timeToLive,
    priority: CachePriority.normal,
    maxSize: 1000,
  );

  /// Default configuration for supplier data
  static const supplierData = CacheConfig(
    ttl: Duration(minutes: 30),
    strategy: CacheStrategy.timeToLive,
    priority: CachePriority.normal,
    maxSize: 200,
  );

  /// Default configuration for inventory data
  static const inventoryData = CacheConfig(
    ttl: Duration(minutes: 5),
    strategy: CacheStrategy.timeToLive,
    priority: CachePriority.high,
    maxSize: 2000,
  );

  /// Default configuration for search results
  static const searchResults = CacheConfig(
    ttl: Duration(minutes: 5),
    strategy: CacheStrategy.leastRecentlyUsed,
    priority: CachePriority.low,
    maxSize: 100,
  );
}
