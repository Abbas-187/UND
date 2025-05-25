import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/bill_of_materials.dart';
import '../../domain/entities/bom_item.dart';
import '../cache/bom_cache_manager.dart';

/// Real-time synchronization manager for BOM data
class RealTimeSyncManager {
  static final RealTimeSyncManager _instance = RealTimeSyncManager._internal();
  factory RealTimeSyncManager() => _instance;
  RealTimeSyncManager._internal();

  final Logger _logger = Logger();
  final StreamController<SyncEvent> _syncController =
      StreamController.broadcast();
  final Queue<SyncOperation> _syncQueue = Queue();
  final Map<String, DateTime> _lastSyncTimes = {};
  final BomCacheManager _cacheManager = BomCacheManager();

  bool _isOnline = true;
  bool _isSyncing = false;
  Timer? _syncTimer;
  Timer? _heartbeatTimer;

  /// Stream of sync events
  Stream<SyncEvent> get syncStream => _syncController.stream;

  /// Current sync status
  SyncStatus get status => SyncStatus(
        isOnline: _isOnline,
        isSyncing: _isSyncing,
        queuedOperations: _syncQueue.length,
        lastSyncTime: _getLastSyncTime(),
      );

  /// Initialize sync manager
  void initialize() {
    _startPeriodicSync();
    _startHeartbeat();
    _logger.i('Real-time sync manager initialized');
  }

  /// Dispose sync manager
  void dispose() {
    _syncTimer?.cancel();
    _heartbeatTimer?.cancel();
    _syncController.close();
    _logger.i('Real-time sync manager disposed');
  }

  /// Sync BOM changes
  Future<void> syncBomChanges(String bomId, {bool force = false}) async {
    try {
      _logger.d('Syncing BOM changes for: $bomId');

      if (!_isOnline && !force) {
        _queueSyncOperation(SyncOperation(
          type: SyncOperationType.bomUpdate,
          entityId: bomId,
          timestamp: DateTime.now(),
        ));
        return;
      }

      _isSyncing = true;
      _emitSyncEvent(SyncEventType.syncStarted, bomId);

      // 1. Check for conflicts
      final conflicts = await _checkForConflicts(bomId);

      if (conflicts.isNotEmpty) {
        await _resolveConflicts(bomId, conflicts);
      }

      // 2. Fetch latest data from server
      final latestBom = await _fetchLatestBomFromServer(bomId);

      // 3. Merge changes intelligently
      final mergedBom = await _mergeChanges(bomId, latestBom);

      // 4. Update local cache
      await _cacheManager.cacheBom(mergedBom);

      // 5. Notify subscribers
      _emitSyncEvent(SyncEventType.syncCompleted, bomId, data: mergedBom);

      _lastSyncTimes[bomId] = DateTime.now();
    } catch (e) {
      _logger.e('Failed to sync BOM changes for $bomId: $e');
      _emitSyncEvent(SyncEventType.syncFailed, bomId, error: e.toString());

      // Queue for retry if offline
      if (!_isOnline) {
        _queueSyncOperation(SyncOperation(
          type: SyncOperationType.bomUpdate,
          entityId: bomId,
          timestamp: DateTime.now(),
          retryCount: 1,
        ));
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Handle offline changes when coming back online
  Future<void> handleOfflineChanges() async {
    if (_syncQueue.isEmpty) return;

    _logger.i('Processing ${_syncQueue.length} queued sync operations');

    final operations = List<SyncOperation>.from(_syncQueue);
    _syncQueue.clear();

    for (final operation in operations) {
      try {
        await _processSyncOperation(operation);
      } catch (e) {
        _logger.e('Failed to process sync operation: $e');

        // Re-queue with increased retry count
        if (operation.retryCount < 3) {
          _queueSyncOperation(operation.copyWith(
            retryCount: operation.retryCount + 1,
          ));
        }
      }
    }
  }

  /// Batch sync for multiple BOMs
  Future<void> batchSyncBoms(List<String> bomIds) async {
    _logger.i('Starting batch sync for ${bomIds.length} BOMs');

    final batchSize = 5; // Process 5 BOMs at a time

    for (int i = 0; i < bomIds.length; i += batchSize) {
      final batch = bomIds.skip(i).take(batchSize).toList();

      await Future.wait(
        batch.map((bomId) => syncBomChanges(bomId)),
      );

      // Small delay between batches to prevent overwhelming the server
      await Future.delayed(Duration(milliseconds: 100));
    }

    _logger.i('Batch sync completed');
  }

  /// Selective sync based on user context
  Future<void> selectiveSync({
    List<String>? bomIds,
    DateTime? since,
    List<String>? userIds,
  }) async {
    final criteria = SyncCriteria(
      bomIds: bomIds,
      since: since,
      userIds: userIds,
    );

    final bomsToSync = await _getBomIdsForSync(criteria);

    if (bomsToSync.isNotEmpty) {
      await batchSyncBoms(bomsToSync);
    }
  }

  /// Set online/offline status
  void setOnlineStatus(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      _emitSyncEvent(
        isOnline
            ? SyncEventType.onlineStatusChanged
            : SyncEventType.offlineStatusChanged,
        'system',
      );

      if (isOnline) {
        // Process queued operations when coming back online
        handleOfflineChanges();
      }
    }
  }

  /// Private helper methods

  Future<List<SyncConflict>> _checkForConflicts(String bomId) async {
    // This would check for conflicts between local and server versions
    // For now, return empty list (no conflicts)
    return [];
  }

  Future<void> _resolveConflicts(
      String bomId, List<SyncConflict> conflicts) async {
    for (final conflict in conflicts) {
      switch (conflict.resolutionStrategy) {
        case ConflictResolutionStrategy.serverWins:
          // Use server version
          break;
        case ConflictResolutionStrategy.clientWins:
          // Use client version
          break;
        case ConflictResolutionStrategy.merge:
          // Merge both versions
          await _mergeConflictedData(conflict);
          break;
        case ConflictResolutionStrategy.manual:
          // Require manual resolution
          _emitSyncEvent(SyncEventType.conflictDetected, bomId, data: conflict);
          break;
      }
    }
  }

  Future<BillOfMaterials> _fetchLatestBomFromServer(String bomId) async {
    // This would fetch from actual server
    // For now, return cached version or create mock
    final cached = await _cacheManager.getCachedBom(bomId);
    if (cached != null) {
      return cached;
    }

    // Mock BOM for demonstration
    return BillOfMaterials(
      id: bomId,
      bomCode: 'BOM-${DateTime.now().millisecondsSinceEpoch}',
      bomName: 'Sample BOM',
      productId: 'product-1',
      productCode: 'PROD-001',
      productName: 'Sample Product',
      version: '1.0',
      status: BomStatus.active,
      bomType: BomType.production,
      baseQuantity: 1.0,
      baseUnit: 'pcs',
      items: [],
      totalCost: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: 'system',
      updatedBy: 'system',
    );
  }

  Future<BillOfMaterials> _mergeChanges(
      String bomId, BillOfMaterials serverBom) async {
    final localBom = await _cacheManager.getCachedBom(bomId);

    if (localBom == null) {
      return serverBom;
    }

    // Simple merge strategy - use latest timestamp
    if (serverBom.updatedAt.isAfter(localBom.updatedAt)) {
      return serverBom;
    } else {
      return localBom;
    }
  }

  Future<void> _mergeConflictedData(SyncConflict conflict) async {
    // Implement intelligent merging logic
    _logger.i('Merging conflicted data for ${conflict.entityId}');
  }

  void _queueSyncOperation(SyncOperation operation) {
    _syncQueue.add(operation);
    _emitSyncEvent(SyncEventType.operationQueued, operation.entityId);
  }

  Future<void> _processSyncOperation(SyncOperation operation) async {
    switch (operation.type) {
      case SyncOperationType.bomUpdate:
        await syncBomChanges(operation.entityId, force: true);
        break;
      case SyncOperationType.bomCreate:
        await _syncNewBom(operation.entityId);
        break;
      case SyncOperationType.bomDelete:
        await _syncBomDeletion(operation.entityId);
        break;
      case SyncOperationType.bomItemUpdate:
        await _syncBomItemUpdate(operation.entityId);
        break;
      case SyncOperationType.bomItemCreate:
        await _syncBomItemCreate(operation.entityId);
        break;
      case SyncOperationType.bomItemDelete:
        await _syncBomItemDelete(operation.entityId);
        break;
    }
  }

  Future<void> _syncNewBom(String bomId) async {
    // Sync newly created BOM
    await syncBomChanges(bomId);
  }

  Future<void> _syncBomDeletion(String bomId) async {
    // Handle BOM deletion sync
    await _cacheManager.invalidateBomCache(bomId);
  }

  Future<void> _syncBomItemUpdate(String bomItemId) async {
    // Handle BOM item update sync
    _logger.d('Syncing BOM item update: $bomItemId');
  }

  Future<void> _syncBomItemCreate(String bomItemId) async {
    // Handle BOM item creation sync
    _logger.d('Syncing BOM item creation: $bomItemId');
  }

  Future<void> _syncBomItemDelete(String bomItemId) async {
    // Handle BOM item deletion sync
    _logger.d('Syncing BOM item deletion: $bomItemId');
  }

  Future<List<String>> _getBomIdsForSync(SyncCriteria criteria) async {
    // This would query the database based on criteria
    // For now, return mock data
    return ['bom-1', 'bom-2', 'bom-3'];
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(Duration(minutes: 5), (_) {
      if (_isOnline && !_isSyncing) {
        _performPeriodicSync();
      }
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(Duration(seconds: 30), (_) {
      _checkConnectionStatus();
    });
  }

  Future<void> _performPeriodicSync() async {
    // Sync recently modified BOMs
    final recentBomIds = await _getRecentlyModifiedBomIds();
    if (recentBomIds.isNotEmpty) {
      await batchSyncBoms(recentBomIds);
    }
  }

  Future<void> _checkConnectionStatus() async {
    // This would check actual network connectivity
    // For now, assume we're always online
    setOnlineStatus(true);
  }

  Future<List<String>> _getRecentlyModifiedBomIds() async {
    // This would query for recently modified BOMs
    // For now, return empty list
    return [];
  }

  DateTime? _getLastSyncTime() {
    if (_lastSyncTimes.isEmpty) return null;
    return _lastSyncTimes.values.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  void _emitSyncEvent(SyncEventType type, String entityId,
      {dynamic data, String? error}) {
    final event = SyncEvent(
      type: type,
      entityId: entityId,
      timestamp: DateTime.now(),
      data: data,
      error: error,
    );

    _syncController.add(event);
    _logger.d('Sync event: ${type.name} for $entityId');
  }
}

/// Sync event
class SyncEvent {
  final SyncEventType type;
  final String entityId;
  final DateTime timestamp;
  final dynamic data;
  final String? error;

  SyncEvent({
    required this.type,
    required this.entityId,
    required this.timestamp,
    this.data,
    this.error,
  });
}

/// Sync event types
enum SyncEventType {
  syncStarted,
  syncCompleted,
  syncFailed,
  conflictDetected,
  operationQueued,
  onlineStatusChanged,
  offlineStatusChanged,
}

/// Sync operation
class SyncOperation {
  final SyncOperationType type;
  final String entityId;
  final DateTime timestamp;
  final int retryCount;
  final Map<String, dynamic>? metadata;

  SyncOperation({
    required this.type,
    required this.entityId,
    required this.timestamp,
    this.retryCount = 0,
    this.metadata,
  });

  SyncOperation copyWith({
    SyncOperationType? type,
    String? entityId,
    DateTime? timestamp,
    int? retryCount,
    Map<String, dynamic>? metadata,
  }) {
    return SyncOperation(
      type: type ?? this.type,
      entityId: entityId ?? this.entityId,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Sync operation types
enum SyncOperationType {
  bomUpdate,
  bomCreate,
  bomDelete,
  bomItemUpdate,
  bomItemCreate,
  bomItemDelete,
}

/// Sync status
class SyncStatus {
  final bool isOnline;
  final bool isSyncing;
  final int queuedOperations;
  final DateTime? lastSyncTime;

  SyncStatus({
    required this.isOnline,
    required this.isSyncing,
    required this.queuedOperations,
    this.lastSyncTime,
  });
}

/// Sync criteria for selective sync
class SyncCriteria {
  final List<String>? bomIds;
  final DateTime? since;
  final List<String>? userIds;

  SyncCriteria({
    this.bomIds,
    this.since,
    this.userIds,
  });
}

/// Sync conflict
class SyncConflict {
  final String entityId;
  final String field;
  final dynamic localValue;
  final dynamic serverValue;
  final ConflictResolutionStrategy resolutionStrategy;

  SyncConflict({
    required this.entityId,
    required this.field,
    required this.localValue,
    required this.serverValue,
    required this.resolutionStrategy,
  });
}

/// Conflict resolution strategies
enum ConflictResolutionStrategy {
  serverWins,
  clientWins,
  merge,
  manual,
}

/// Provider for real-time sync manager
final realTimeSyncManagerProvider = Provider<RealTimeSyncManager>((ref) {
  return RealTimeSyncManager();
});
