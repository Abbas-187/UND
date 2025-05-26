import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ai_request.dart';
import '../../domain/entities/ai_response.dart';
import '../../domain/entities/ai_capability.dart';

part 'advanced_cache_service.g.dart';

/// Cache entry with metadata
@HiveType(typeId: 1)
class CacheEntry {
  @HiveField(0)
  final String key;

  @HiveField(1)
  final AIResponse response;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime expiresAt;

  @HiveField(4)
  final int accessCount;

  @HiveField(5)
  final DateTime lastAccessedAt;

  @HiveField(6)
  final double confidence;

  @HiveField(7)
  final Map<String, dynamic> metadata;

  @HiveField(8)
  final int priority;

  @HiveField(9)
  final bool isPersistent;

  const CacheEntry({
    required this.key,
    required this.response,
    required this.createdAt,
    required this.expiresAt,
    required this.accessCount,
    required this.lastAccessedAt,
    required this.confidence,
    required this.metadata,
    required this.priority,
    required this.isPersistent,
  });

  CacheEntry copyWith({
    String? key,
    AIResponse? response,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? accessCount,
    DateTime? lastAccessedAt,
    double? confidence,
    Map<String, dynamic>? metadata,
    int? priority,
    bool? isPersistent,
  }) {
    return CacheEntry(
      key: key ?? this.key,
      response: response ?? this.response,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      accessCount: accessCount ?? this.accessCount,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
      priority: priority ?? this.priority,
      isPersistent: isPersistent ?? this.isPersistent,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isExpired && confidence > 0.5;

  Duration get age => DateTime.now().difference(createdAt);
  Duration get timeSinceLastAccess => DateTime.now().difference(lastAccessedAt);
}

/// Cache statistics
class CacheStatistics {
  final int totalEntries;
  final int validEntries;
  final int expiredEntries;
  final double hitRate;
  final double missRate;
  final int totalHits;
  final int totalMisses;
  final int totalRequests;
  final double averageResponseTime;
  final Map<String, int> capabilityHits;
  final Map<String, int> providerHits;
  final DateTime lastCleanup;
  final int memoryUsageBytes;
  final int diskUsageBytes;

  const CacheStatistics({
    required this.totalEntries,
    required this.validEntries,
    required this.expiredEntries,
    required this.hitRate,
    required this.missRate,
    required this.totalHits,
    required this.totalMisses,
    required this.totalRequests,
    required this.averageResponseTime,
    required this.capabilityHits,
    required this.providerHits,
    required this.lastCleanup,
    required this.memoryUsageBytes,
    required this.diskUsageBytes,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalEntries': totalEntries,
      'validEntries': validEntries,
      'expiredEntries': expiredEntries,
      'hitRate': hitRate,
      'missRate': missRate,
      'totalHits': totalHits,
      'totalMisses': totalMisses,
      'totalRequests': totalRequests,
      'averageResponseTime': averageResponseTime,
      'capabilityHits': capabilityHits,
      'providerHits': providerHits,
      'lastCleanup': lastCleanup.toIso8601String(),
      'memoryUsageBytes': memoryUsageBytes,
      'diskUsageBytes': diskUsageBytes,
    };
  }
}

/// Cache eviction strategies
enum EvictionStrategy {
  lru, // Least Recently Used
  lfu, // Least Frequently Used
  fifo, // First In, First Out
  random, // Random eviction
  ttl, // Time To Live based
  priority, // Priority based
  hybrid, // Combination strategy
}

/// Cache configuration
class CacheConfiguration {
  final int maxMemoryEntries;
  final int maxDiskEntries;
  final Duration defaultTTL;
  final Map<AICapability, Duration> capabilityTTLs;
  final EvictionStrategy evictionStrategy;
  final bool enablePersistence;
  final bool enableCompression;
  final bool enableEncryption;
  final double cleanupThreshold;
  final Duration cleanupInterval;
  final int maxConcurrentWrites;
  final bool enablePrefetching;
  final double confidenceThreshold;

  const CacheConfiguration({
    this.maxMemoryEntries = 1000,
    this.maxDiskEntries = 10000,
    this.defaultTTL = const Duration(hours: 1),
    this.capabilityTTLs = const {},
    this.evictionStrategy = EvictionStrategy.hybrid,
    this.enablePersistence = true,
    this.enableCompression = true,
    this.enableEncryption = false,
    this.cleanupThreshold = 0.8,
    this.cleanupInterval = const Duration(minutes: 30),
    this.maxConcurrentWrites = 5,
    this.enablePrefetching = true,
    this.confidenceThreshold = 0.7,
  });

  Duration getTTLForCapability(AICapability capability) {
    return capabilityTTLs[capability] ?? defaultTTL;
  }
}

/// Advanced AI cache service with multi-level caching and intelligent eviction
class AdvancedCacheService {
  final CacheConfiguration _config;

  // Multi-level cache storage
  final LinkedHashMap<String, CacheEntry> _memoryCache =
      LinkedHashMap<String, CacheEntry>();
  Box<CacheEntry>? _diskCache;

  // Cache statistics
  int _totalHits = 0;
  int _totalMisses = 0;
  final Map<String, int> _capabilityHits = {};
  final Map<String, int> _providerHits = {};
  final List<double> _responseTimes = [];
  DateTime _lastCleanup = DateTime.now();

  // Background operations
  Timer? _cleanupTimer;
  Timer? _statisticsTimer;
  final Queue<Future<void> Function()> _writeQueue =
      Queue<Future<void> Function()>();
  int _activeWrites = 0;

  // Prefetching
  final Map<String, DateTime> _prefetchCandidates = {};
  Timer? _prefetchTimer;

  AdvancedCacheService({
    CacheConfiguration? config,
  }) : _config = config ?? const CacheConfiguration() {
    _initializeCache();
    _startBackgroundTasks();
  }

  /// Initialize cache system
  Future<void> _initializeCache() async {
    try {
      if (_config.enablePersistence) {
        await Hive.initFlutter();

        // Register adapters if not already registered
        if (!Hive.isAdapterRegistered(1)) {
          Hive.registerAdapter(CacheEntryAdapter());
        }
        if (!Hive.isAdapterRegistered(2)) {
          Hive.registerAdapter(AIResponseAdapter());
        }

        _diskCache = await Hive.openBox<CacheEntry>('ai_cache');
        await _loadFromDisk();
      }

      debugPrint(
          'Advanced cache service initialized with ${_memoryCache.length} entries');
    } catch (error) {
      debugPrint('Cache initialization error: $error');
    }
  }

  /// Load cache entries from disk to memory
  Future<void> _loadFromDisk() async {
    if (_diskCache == null) return;

    try {
      final entries =
          _diskCache!.values.where((entry) => entry.isValid).toList();
      entries.sort((a, b) => b.lastAccessedAt.compareTo(a.lastAccessedAt));

      // Load most recently accessed entries into memory
      final memoryLimit = (_config.maxMemoryEntries * 0.8).toInt();
      for (int i = 0; i < entries.length && i < memoryLimit; i++) {
        _memoryCache[entries[i].key] = entries[i];
      }

      debugPrint('Loaded ${_memoryCache.length} cache entries from disk');
    } catch (error) {
      debugPrint('Error loading cache from disk: $error');
    }
  }

  /// Start background maintenance tasks
  void _startBackgroundTasks() {
    // Cleanup timer
    _cleanupTimer = Timer.periodic(_config.cleanupInterval, (timer) {
      _performCleanup();
    });

    // Statistics timer
    _statisticsTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _updateStatistics();
    });

    // Prefetch timer
    if (_config.enablePrefetching) {
      _prefetchTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
        _performPrefetching();
      });
    }
  }

  /// Get cached response for request
  Future<AIResponse?> get(AIRequest request) async {
    final startTime = DateTime.now();

    try {
      final key = _generateCacheKey(request);
      CacheEntry? entry;

      // Check memory cache first
      entry = _memoryCache[key];
      if (entry != null && entry.isValid) {
        _recordCacheHit(entry, 'memory');
        _updateAccessMetrics(entry);
        return entry.response;
      }

      // Check disk cache if enabled
      if (_config.enablePersistence && _diskCache != null) {
        entry = _diskCache!.get(key);
        if (entry != null && entry.isValid) {
          _recordCacheHit(entry, 'disk');
          _updateAccessMetrics(entry);

          // Promote to memory cache
          await _promoteToMemory(entry);
          return entry.response;
        }
      }

      // Check for similar requests (fuzzy matching)
      final similarEntry = await _findSimilarEntry(request);
      if (similarEntry != null) {
        _recordCacheHit(similarEntry, 'similar');
        _updateAccessMetrics(similarEntry);
        return similarEntry.response;
      }

      _recordCacheMiss(request);
      return null;
    } finally {
      final responseTime =
          DateTime.now().difference(startTime).inMicroseconds / 1000.0;
      _responseTimes.add(responseTime);
      if (_responseTimes.length > 1000) {
        _responseTimes.removeAt(0);
      }
    }
  }

  /// Store response in cache
  Future<void> store(AIRequest request, AIResponse response) async {
    if (response.confidence < _config.confidenceThreshold) {
      debugPrint(
          'Skipping cache storage due to low confidence: ${response.confidence}');
      return;
    }

    final key = _generateCacheKey(request);
    final ttl = _config.getTTLForCapability(request.capability);
    final expiresAt = DateTime.now().add(ttl);

    final entry = CacheEntry(
      key: key,
      response: response,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      accessCount: 1,
      lastAccessedAt: DateTime.now(),
      confidence: response.confidence,
      metadata: {
        'capability': request.capability.name,
        'provider': response.metadata['provider'] ?? 'unknown',
        'user_id': request.userId ?? 'anonymous',
        'request_hash': _hashRequest(request),
      },
      priority: _calculatePriority(request, response),
      isPersistent: _shouldPersist(request, response),
    );

    // Store in memory
    await _storeInMemory(entry);

    // Queue disk storage if enabled
    if (_config.enablePersistence && entry.isPersistent) {
      _queueDiskWrite(() => _storeToDisk(entry));
    }

    // Update prefetch candidates
    if (_config.enablePrefetching) {
      _updatePrefetchCandidates(request);
    }
  }

  /// Store entry in memory cache
  Future<void> _storeInMemory(CacheEntry entry) async {
    _memoryCache[entry.key] = entry;

    // Check if memory cache needs cleanup
    if (_memoryCache.length > _config.maxMemoryEntries) {
      await _evictMemoryEntries();
    }
  }

  /// Store entry to disk cache
  Future<void> _storeToDisk(CacheEntry entry) async {
    if (_diskCache == null) return;

    try {
      await _diskCache!.put(entry.key, entry);

      // Check if disk cache needs cleanup
      if (_diskCache!.length > _config.maxDiskEntries) {
        await _evictDiskEntries();
      }
    } catch (error) {
      debugPrint('Error storing to disk cache: $error');
    }
  }

  /// Queue disk write operation
  void _queueDiskWrite(Future<void> Function() writeOperation) {
    _writeQueue.add(writeOperation);
    _processDiskWriteQueue();
  }

  /// Process queued disk write operations
  Future<void> _processDiskWriteQueue() async {
    if (_activeWrites >= _config.maxConcurrentWrites || _writeQueue.isEmpty) {
      return;
    }

    _activeWrites++;

    try {
      final operation = _writeQueue.removeFirst();
      await operation();
    } catch (error) {
      debugPrint('Disk write operation failed: $error');
    } finally {
      _activeWrites--;

      // Process next operation if queue is not empty
      if (_writeQueue.isNotEmpty) {
        unawaited(_processDiskWriteQueue());
      }
    }
  }

  /// Promote disk entry to memory cache
  Future<void> _promoteToMemory(CacheEntry entry) async {
    if (_memoryCache.length < _config.maxMemoryEntries) {
      _memoryCache[entry.key] = entry;
    } else {
      // Replace least valuable memory entry
      final leastValuable = _findLeastValuableMemoryEntry();
      if (leastValuable != null &&
          _calculateValue(entry) > _calculateValue(leastValuable)) {
        _memoryCache.remove(leastValuable.key);
        _memoryCache[entry.key] = entry;
      }
    }
  }

  /// Find similar cache entry using fuzzy matching
  Future<CacheEntry?> _findSimilarEntry(AIRequest request) async {
    const similarityThreshold = 0.8;

    // Check memory cache for similar requests
    for (final entry in _memoryCache.values) {
      if (entry.metadata['capability'] == request.capability.name) {
        final similarity = _calculateSimilarity(request, entry);
        if (similarity >= similarityThreshold) {
          return entry;
        }
      }
    }

    return null;
  }

  /// Calculate similarity between requests
  double _calculateSimilarity(AIRequest request, CacheEntry entry) {
    // Simple similarity calculation based on prompt similarity
    final requestWords = request.prompt.toLowerCase().split(' ');
    final cachedPrompt = entry.metadata['request_hash']?.toString() ?? '';

    // For simplicity, using Jaccard similarity
    final requestSet = requestWords.toSet();
    final cachedSet = cachedPrompt.split('_').toSet();

    final intersection = requestSet.intersection(cachedSet);
    final union = requestSet.union(cachedSet);

    return union.isEmpty ? 0.0 : intersection.length / union.length;
  }

  /// Evict entries from memory cache
  Future<void> _evictMemoryEntries() async {
    final targetSize = (_config.maxMemoryEntries * 0.8).toInt();
    final toEvict = _memoryCache.length - targetSize;

    if (toEvict <= 0) return;

    final entries = _memoryCache.values.toList();
    final candidates = _selectEvictionCandidates(entries, toEvict);

    for (final candidate in candidates) {
      _memoryCache.remove(candidate.key);

      // Move to disk if persistent and not already there
      if (candidate.isPersistent && _diskCache != null) {
        _queueDiskWrite(() => _storeToDisk(candidate));
      }
    }

    debugPrint('Evicted $toEvict entries from memory cache');
  }

  /// Evict entries from disk cache
  Future<void> _evictDiskEntries() async {
    if (_diskCache == null) return;

    final targetSize = (_config.maxDiskEntries * 0.8).toInt();
    final toEvict = _diskCache!.length - targetSize;

    if (toEvict <= 0) return;

    final entries = _diskCache!.values.toList();
    final candidates = _selectEvictionCandidates(entries, toEvict);

    for (final candidate in candidates) {
      await _diskCache!.delete(candidate.key);
    }

    debugPrint('Evicted $toEvict entries from disk cache');
  }

  /// Select eviction candidates based on strategy
  List<CacheEntry> _selectEvictionCandidates(
      List<CacheEntry> entries, int count) {
    switch (_config.evictionStrategy) {
      case EvictionStrategy.lru:
        entries.sort((a, b) => a.lastAccessedAt.compareTo(b.lastAccessedAt));
        break;
      case EvictionStrategy.lfu:
        entries.sort((a, b) => a.accessCount.compareTo(b.accessCount));
        break;
      case EvictionStrategy.fifo:
        entries.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case EvictionStrategy.ttl:
        entries.sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
        break;
      case EvictionStrategy.priority:
        entries.sort((a, b) => a.priority.compareTo(b.priority));
        break;
      case EvictionStrategy.random:
        entries.shuffle();
        break;
      case EvictionStrategy.hybrid:
        // Combine multiple factors
        entries
            .sort((a, b) => _calculateValue(a).compareTo(_calculateValue(b)));
        break;
    }

    return entries.take(count).toList();
  }

  /// Calculate entry value for hybrid eviction strategy
  double _calculateValue(CacheEntry entry) {
    final age = entry.age.inMinutes;
    final accessFrequency = entry.accessCount / max(1, age);
    final recency = DateTime.now().difference(entry.lastAccessedAt).inMinutes;
    final confidenceFactor = entry.confidence;
    final priorityFactor = entry.priority / 10.0;

    // Higher value means more valuable (less likely to be evicted)
    return (accessFrequency * 0.3) +
        (confidenceFactor * 0.3) +
        (priorityFactor * 0.2) +
        (1.0 / max(1, recency) * 0.2);
  }

  /// Find least valuable memory entry
  CacheEntry? _findLeastValuableMemoryEntry() {
    if (_memoryCache.isEmpty) return null;

    return _memoryCache.values
        .reduce((a, b) => _calculateValue(a) < _calculateValue(b) ? a : b);
  }

  /// Perform periodic cleanup
  Future<void> _performCleanup() async {
    final startTime = DateTime.now();
    int removedCount = 0;

    try {
      // Remove expired entries from memory
      final memoryKeysToRemove = <String>[];
      for (final entry in _memoryCache.values) {
        if (entry.isExpired) {
          memoryKeysToRemove.add(entry.key);
        }
      }

      for (final key in memoryKeysToRemove) {
        _memoryCache.remove(key);
        removedCount++;
      }

      // Remove expired entries from disk
      if (_diskCache != null) {
        final diskKeysToRemove = <String>[];
        for (final entry in _diskCache!.values) {
          if (entry.isExpired) {
            diskKeysToRemove.add(entry.key);
          }
        }

        for (final key in diskKeysToRemove) {
          await _diskCache!.delete(key);
          removedCount++;
        }
      }

      _lastCleanup = DateTime.now();

      if (removedCount > 0) {
        debugPrint(
            'Cache cleanup removed $removedCount expired entries in ${DateTime.now().difference(startTime).inMilliseconds}ms');
      }
    } catch (error) {
      debugPrint('Cache cleanup error: $error');
    }
  }

  /// Perform prefetching for frequently accessed patterns
  Future<void> _performPrefetching() async {
    // Analyze access patterns and prefetch likely needed responses
    final candidates = _prefetchCandidates.entries
        .where((entry) => DateTime.now().difference(entry.value).inMinutes < 60)
        .take(5)
        .map((entry) => entry.key)
        .toList();

    debugPrint('Prefetch candidates: ${candidates.length}');

    // In a real implementation, this would trigger background AI requests
    // for predicted user needs based on usage patterns
  }

  /// Update prefetch candidates based on request patterns
  void _updatePrefetchCandidates(AIRequest request) {
    final pattern =
        '${request.capability.name}_${request.userId ?? 'anonymous'}';
    _prefetchCandidates[pattern] = DateTime.now();

    // Keep only recent candidates
    if (_prefetchCandidates.length > 100) {
      final oldEntries = _prefetchCandidates.entries
          .where((entry) => DateTime.now().difference(entry.value).inHours > 24)
          .map((entry) => entry.key)
          .toList();

      for (final key in oldEntries) {
        _prefetchCandidates.remove(key);
      }
    }
  }

  /// Generate cache key for request
  String _generateCacheKey(AIRequest request) {
    final keyData = {
      'prompt': request.prompt,
      'capability': request.capability.name,
      'user_id': request.userId ?? 'anonymous',
      'context': request.context?.toString() ?? '',
    };

    final keyString = json.encode(keyData);
    final bytes = utf8.encode(keyString);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  /// Hash request for similarity comparison
  String _hashRequest(AIRequest request) {
    final words = request.prompt.toLowerCase().split(' ');
    final significantWords = words.where((word) => word.length > 3).take(10);
    return significantWords.join('_');
  }

  /// Calculate priority for cache entry
  int _calculatePriority(AIRequest request, AIResponse response) {
    int priority = 5; // Base priority

    // Higher confidence gets higher priority
    priority += (response.confidence * 3).round();

    // Critical capabilities get higher priority
    if (request.capability == AICapability.codeGeneration ||
        request.capability == AICapability.dataAnalysis) {
      priority += 2;
    }

    // Faster responses get slightly higher priority
    if (response.processingTime.inSeconds < 5) {
      priority += 1;
    }

    return priority.clamp(1, 10);
  }

  /// Determine if entry should be persisted to disk
  bool _shouldPersist(AIRequest request, AIResponse response) {
    return _config.enablePersistence &&
        response.confidence >= _config.confidenceThreshold &&
        response.processingTime.inSeconds >= 2; // Persist slower requests
  }

  /// Record cache hit metrics
  void _recordCacheHit(CacheEntry entry, String source) {
    _totalHits++;

    final capability = entry.metadata['capability']?.toString() ?? 'unknown';
    final provider = entry.metadata['provider']?.toString() ?? 'unknown';

    _capabilityHits[capability] = (_capabilityHits[capability] ?? 0) + 1;
    _providerHits[provider] = (_providerHits[provider] ?? 0) + 1;

    debugPrint('Cache hit ($source): $capability from $provider');
  }

  /// Record cache miss metrics
  void _recordCacheMiss(AIRequest request) {
    _totalMisses++;
    debugPrint('Cache miss: ${request.capability.name}');
  }

  /// Update access metrics for cache entry
  void _updateAccessMetrics(CacheEntry entry) {
    final updatedEntry = entry.copyWith(
      accessCount: entry.accessCount + 1,
      lastAccessedAt: DateTime.now(),
    );

    _memoryCache[entry.key] = updatedEntry;

    // Queue disk update if persistent
    if (entry.isPersistent && _diskCache != null) {
      _queueDiskWrite(() => _storeToDisk(updatedEntry));
    }
  }

  /// Update statistics
  void _updateStatistics() {
    // This would typically send statistics to monitoring systems
    final stats = getStatistics();
    debugPrint(
        'Cache statistics: ${stats.hitRate.toStringAsFixed(2)}% hit rate, ${stats.totalEntries} entries');
  }

  /// Invalidate specific cache entry
  Future<void> invalidate(AIRequest request) async {
    final key = _generateCacheKey(request);

    _memoryCache.remove(key);

    if (_diskCache != null) {
      await _diskCache!.delete(key);
    }

    debugPrint('Invalidated cache entry: $key');
  }

  /// Invalidate cache entries by pattern
  Future<void> invalidateByPattern(String pattern) async {
    final keysToRemove = <String>[];

    // Find matching keys in memory
    for (final key in _memoryCache.keys) {
      if (key.contains(pattern)) {
        keysToRemove.add(key);
      }
    }

    // Remove from memory
    for (final key in keysToRemove) {
      _memoryCache.remove(key);
    }

    // Remove from disk
    if (_diskCache != null) {
      final diskKeysToRemove = <String>[];
      for (final key in _diskCache!.keys) {
        if (key.contains(pattern)) {
          diskKeysToRemove.add(key);
        }
      }

      for (final key in diskKeysToRemove) {
        await _diskCache!.delete(key);
      }
    }

    debugPrint(
        'Invalidated ${keysToRemove.length} cache entries matching pattern: $pattern');
  }

  /// Clear all cache entries
  Future<void> clear() async {
    _memoryCache.clear();

    if (_diskCache != null) {
      await _diskCache!.clear();
    }

    // Reset statistics
    _totalHits = 0;
    _totalMisses = 0;
    _capabilityHits.clear();
    _providerHits.clear();
    _responseTimes.clear();

    debugPrint('Cache cleared');
  }

  /// Get current cache statistics
  CacheStatistics getStatistics() {
    final totalRequests = _totalHits + _totalMisses;
    final hitRate = totalRequests > 0 ? _totalHits / totalRequests : 0.0;
    final missRate = totalRequests > 0 ? _totalMisses / totalRequests : 0.0;
    final avgResponseTime = _responseTimes.isNotEmpty
        ? _responseTimes.reduce((a, b) => a + b) / _responseTimes.length
        : 0.0;

    final memoryUsage = _calculateMemoryUsage();
    final diskUsage = _calculateDiskUsage();

    return CacheStatistics(
      totalEntries: _memoryCache.length + (_diskCache?.length ?? 0),
      validEntries: _memoryCache.values.where((e) => e.isValid).length +
          (_diskCache?.values.where((e) => e.isValid).length ?? 0),
      expiredEntries: _memoryCache.values.where((e) => e.isExpired).length +
          (_diskCache?.values.where((e) => e.isExpired).length ?? 0),
      hitRate: hitRate,
      missRate: missRate,
      totalHits: _totalHits,
      totalMisses: _totalMisses,
      totalRequests: totalRequests,
      averageResponseTime: avgResponseTime,
      capabilityHits: Map.from(_capabilityHits),
      providerHits: Map.from(_providerHits),
      lastCleanup: _lastCleanup,
      memoryUsageBytes: memoryUsage,
      diskUsageBytes: diskUsage,
    );
  }

  /// Calculate memory usage in bytes (estimate)
  int _calculateMemoryUsage() {
    int totalBytes = 0;

    for (final entry in _memoryCache.values) {
      // Rough estimate of entry size
      totalBytes += entry.response.content.length * 2; // UTF-16 encoding
      totalBytes += 200; // Metadata overhead
    }

    return totalBytes;
  }

  /// Calculate disk usage in bytes (estimate)
  int _calculateDiskUsage() {
    if (_diskCache == null) return 0;

    int totalBytes = 0;

    for (final entry in _diskCache!.values) {
      // Rough estimate of entry size
      totalBytes += entry.response.content.length * 2; // UTF-16 encoding
      totalBytes += 200; // Metadata overhead
    }

    return totalBytes;
  }

  /// Warm up cache with predefined entries
  Future<void> warmUp(List<AIRequest> requests) async {
    debugPrint('Warming up cache with ${requests.length} requests');

    // This would typically pre-populate cache with common requests
    // For now, just mark them as prefetch candidates
    for (final request in requests) {
      _updatePrefetchCandidates(request);
    }
  }

  /// Export cache statistics to JSON
  Map<String, dynamic> exportStatistics() {
    return getStatistics().toJson();
  }

  /// Dispose cache service
  Future<void> dispose() async {
    _cleanupTimer?.cancel();
    _statisticsTimer?.cancel();
    _prefetchTimer?.cancel();

    // Process remaining write queue
    while (
        _writeQueue.isNotEmpty && _activeWrites < _config.maxConcurrentWrites) {
      await _processDiskWriteQueue();
    }

    // Close disk cache
    await _diskCache?.close();

    _memoryCache.clear();

    debugPrint('Advanced cache service disposed');
  }
}

/// Hive adapter for CacheEntry
class CacheEntryAdapter extends TypeAdapter<CacheEntry> {
  @override
  final int typeId = 1;

  @override
  CacheEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheEntry(
      key: fields[0] as String,
      response: fields[1] as AIResponse,
      createdAt: fields[2] as DateTime,
      expiresAt: fields[3] as DateTime,
      accessCount: fields[4] as int,
      lastAccessedAt: fields[5] as DateTime,
      confidence: fields[6] as double,
      metadata: Map<String, dynamic>.from(fields[7] as Map),
      priority: fields[8] as int,
      isPersistent: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CacheEntry obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.response)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.expiresAt)
      ..writeByte(4)
      ..write(obj.accessCount)
      ..writeByte(5)
      ..write(obj.lastAccessedAt)
      ..writeByte(6)
      ..write(obj.confidence)
      ..writeByte(7)
      ..write(obj.metadata)
      ..writeByte(8)
      ..write(obj.priority)
      ..writeByte(9)
      ..write(obj.isPersistent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Hive adapter for AIResponse
class AIResponseAdapter extends TypeAdapter<AIResponse> {
  @override
  final int typeId = 2;

  @override
  AIResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AIResponse(
      content: fields[0] as String,
      confidence: fields[1] as double,
      processingTime: fields[2] as Duration,
      metadata: Map<String, dynamic>.from(fields[3] as Map),
    );
  }

  @override
  void write(BinaryWriter writer, AIResponse obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.content)
      ..writeByte(1)
      ..write(obj.confidence)
      ..writeByte(2)
      ..write(obj.processingTime)
      ..writeByte(3)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Provider for advanced cache service
@riverpod
AdvancedCacheService advancedCacheService(AdvancedCacheServiceRef ref) {
  final cacheService = AdvancedCacheService();

  ref.onDispose(() => cacheService.dispose());

  return cacheService;
}
