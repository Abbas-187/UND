import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/bill_of_materials.dart';
import '../../domain/entities/bom_item.dart';

/// Enumeration for sync operation types
enum SyncOperationType {
  create,
  update,
  delete,
}

/// Enumeration for sync status
enum SyncStatus {
  pending,
  syncing,
  completed,
  failed,
  conflict,
}

/// Represents a pending sync operation
class SyncOperation {

  const SyncOperation({
    required this.id,
    required this.type,
    required this.entityType,
    required this.entityId,
    required this.data,
    required this.timestamp,
    this.status = SyncStatus.pending,
    this.errorMessage,
    this.retryCount = 0,
  });

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String,
      type: SyncOperationType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: SyncStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SyncStatus.pending,
      ),
      errorMessage: json['errorMessage'] as String?,
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }
  final String id;
  final SyncOperationType type;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final SyncStatus status;
  final String? errorMessage;
  final int retryCount;

  SyncOperation copyWith({
    String? id,
    SyncOperationType? type,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    SyncStatus? status,
    String? errorMessage,
    int? retryCount,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'entityType': entityType,
      'entityId': entityId,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'errorMessage': errorMessage,
      'retryCount': retryCount,
    };
  }
}

/// Offline sync service for BOM data
class OfflineSyncService {
  static const String _syncQueueKey = 'bom_sync_queue';
  static const String _lastSyncKey = 'bom_last_sync';
  static const String _offlineDataKey = 'bom_offline_data';
  static const int _maxRetries = 3;
  static const Duration _syncInterval = Duration(minutes: 5);

  final List<SyncOperation> _syncQueue = [];
  final Map<String, dynamic> _offlineData = {};
  Timer? _syncTimer;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  // Stream controllers for sync events
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  final _syncProgressController = StreamController<double>.broadcast();
  final _conflictController = StreamController<SyncOperation>.broadcast();

  // Getters for streams
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  Stream<double> get syncProgressStream => _syncProgressController.stream;
  Stream<SyncOperation> get conflictStream => _conflictController.stream;

  // Getters for sync state
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingOperationsCount =>
      _syncQueue.where((op) => op.status == SyncStatus.pending).length;
  List<SyncOperation> get failedOperations =>
      _syncQueue.where((op) => op.status == SyncStatus.failed).toList();

  /// Initialize the offline sync service
  Future<void> initialize() async {
    await _loadSyncQueue();
    await _loadOfflineData();
    await _loadLastSyncTime();
    _startPeriodicSync();
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
    _syncProgressController.close();
    _conflictController.close();
  }

  /// Add a BOM operation to sync queue
  Future<void> queueBomOperation({
    required SyncOperationType type,
    required BillOfMaterials bom,
  }) async {
    final operation = SyncOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      entityType: 'BillOfMaterials',
      entityId: bom.id,
      data: bom.toJson(),
      timestamp: DateTime.now(),
    );

    _syncQueue.add(operation);
    await _saveSyncQueue();

    // Store offline data
    _offlineData['bom_${bom.id}'] = bom.toJson();
    await _saveOfflineData();

    // Trigger immediate sync if online
    if (await _isOnline()) {
      _performSync();
    }
  }

  /// Add a BOM item operation to sync queue
  Future<void> queueBomItemOperation({
    required SyncOperationType type,
    required BomItem item,
  }) async {
    final operation = SyncOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      entityType: 'BomItem',
      entityId: item.id,
      data: item.toJson(),
      timestamp: DateTime.now(),
    );

    _syncQueue.add(operation);
    await _saveSyncQueue();

    // Store offline data
    _offlineData['item_${item.id}'] = item.toJson();
    await _saveOfflineData();

    // Trigger immediate sync if online
    if (await _isOnline()) {
      _performSync();
    }
  }

  /// Get offline BOM data
  BillOfMaterials? getOfflineBom(String bomId) {
    final data = _offlineData['bom_$bomId'];
    if (data != null) {
      return BillOfMaterials.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  /// Get offline BOM item data
  BomItem? getOfflineBomItem(String itemId) {
    final data = _offlineData['item_$itemId'];
    if (data != null) {
      return BomItem.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  /// Get all offline BOMs
  List<BillOfMaterials> getAllOfflineBoms() {
    final boms = <BillOfMaterials>[];
    for (final entry in _offlineData.entries) {
      if (entry.key.startsWith('bom_')) {
        try {
          final bom =
              BillOfMaterials.fromJson(Map<String, dynamic>.from(entry.value));
          boms.add(bom);
        } catch (e) {
          debugPrint('Error parsing offline BOM: $e');
        }
      }
    }
    return boms;
  }

  /// Force sync all pending operations
  Future<void> forcSync() async {
    if (_isSyncing) return;
    await _performSync();
  }

  /// Retry failed operations
  Future<void> retryFailedOperations() async {
    final failedOps =
        _syncQueue.where((op) => op.status == SyncStatus.failed).toList();
    for (final op in failedOps) {
      if (op.retryCount < _maxRetries) {
        final updatedOp = op.copyWith(
          status: SyncStatus.pending,
          retryCount: op.retryCount + 1,
        );
        final index = _syncQueue.indexOf(op);
        _syncQueue[index] = updatedOp;
      }
    }
    await _saveSyncQueue();
    await _performSync();
  }

  /// Clear all sync data (use with caution)
  Future<void> clearSyncData() async {
    _syncQueue.clear();
    _offlineData.clear();
    _lastSyncTime = null;
    await _saveSyncQueue();
    await _saveOfflineData();
    await _saveLastSyncTime();
  }

  /// Resolve sync conflict
  Future<void> resolveConflict({
    required SyncOperation operation,
    required bool useLocalData,
  }) async {
    if (useLocalData) {
      // Keep local data, mark operation as completed
      final index = _syncQueue.indexOf(operation);
      if (index != -1) {
        _syncQueue[index] = operation.copyWith(status: SyncStatus.completed);
        await _saveSyncQueue();
      }
    } else {
      // Use server data, remove local changes
      _offlineData.remove(
          '${operation.entityType.toLowerCase()}_${operation.entityId}');
      _syncQueue.remove(operation);
      await _saveSyncQueue();
      await _saveOfflineData();
    }
  }

  // Private methods

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      if (!_isSyncing) {
        _performSync();
      }
    });
  }

  Future<void> _performSync() async {
    if (_isSyncing || !await _isOnline()) return;

    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);

    try {
      final pendingOps =
          _syncQueue.where((op) => op.status == SyncStatus.pending).toList();
      if (pendingOps.isEmpty) {
        _syncStatusController.add(SyncStatus.completed);
        return;
      }

      for (int i = 0; i < pendingOps.length; i++) {
        final operation = pendingOps[i];
        _syncProgressController.add((i + 1) / pendingOps.length);

        try {
          await _syncOperation(operation);
        } catch (e) {
          debugPrint('Sync operation failed: $e');
          final index = _syncQueue.indexOf(operation);
          if (index != -1) {
            _syncQueue[index] = operation.copyWith(
              status: SyncStatus.failed,
              errorMessage: e.toString(),
            );
          }
        }
      }

      _lastSyncTime = DateTime.now();
      await _saveLastSyncTime();
      await _saveSyncQueue();

      _syncStatusController.add(SyncStatus.completed);
    } catch (e) {
      debugPrint('Sync failed: $e');
      _syncStatusController.add(SyncStatus.failed);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncOperation(SyncOperation operation) async {
    // Simulate API call - in real implementation, this would call actual API
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate conflict detection
    if (operation.retryCount > 0 && DateTime.now().millisecond % 10 == 0) {
      final index = _syncQueue.indexOf(operation);
      if (index != -1) {
        _syncQueue[index] = operation.copyWith(status: SyncStatus.conflict);
        _conflictController.add(operation);
      }
      return;
    }

    // Mark as completed
    final index = _syncQueue.indexOf(operation);
    if (index != -1) {
      _syncQueue[index] = operation.copyWith(status: SyncStatus.completed);
    }
  }

  Future<bool> _isOnline() async {
    // In real implementation, check network connectivity
    // For now, simulate online status
    return true;
  }

  Future<void> _loadSyncQueue() async {
    // In real implementation, load from local storage (SharedPreferences, SQLite, etc.)
    // For now, use empty queue
    _syncQueue.clear();
  }

  Future<void> _saveSyncQueue() async {
    // In real implementation, save to local storage
    // For now, just log
    debugPrint('Saving sync queue with ${_syncQueue.length} operations');
  }

  Future<void> _loadOfflineData() async {
    // In real implementation, load from local storage
    // For now, use empty data
    _offlineData.clear();
  }

  Future<void> _saveOfflineData() async {
    // In real implementation, save to local storage
    // For now, just log
    debugPrint('Saving offline data with ${_offlineData.length} entries');
  }

  Future<void> _loadLastSyncTime() async {
    // In real implementation, load from local storage
    // For now, set to null
    _lastSyncTime = null;
  }

  Future<void> _saveLastSyncTime() async {
    // In real implementation, save to local storage
    // For now, just log
    debugPrint('Saving last sync time: $_lastSyncTime');
  }
}
