import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/connectivity_service.dart';
import 'local_database_service.dart';
import 'firestore_service.dart';

/// Provider for the sync service
final syncServiceProvider = Provider<SyncService>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  final localDatabaseService = ref.watch(localDatabaseServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  return SyncService(
    connectivityService,
    localDatabaseService,
    firestoreService,
  );
});

/// Service for synchronizing data between local database and Firestore
class SyncService {
  final ConnectivityService _connectivityService;
  final LocalDatabaseService _localDatabaseService;
  final FirestoreService _firestoreService;

  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  Timer? _syncTimer;
  bool _isSyncing = false;

  /// Constructor
  SyncService(
    this._connectivityService,
    this._localDatabaseService,
    this._firestoreService,
  ) {
    // Listen for connectivity changes
    _connectivitySubscription =
        _connectivityService.statusStream.listen((status) {
      if (status == ConnectivityStatus.connected) {
        // When connection is restored, sync immediately
        syncData();
      }
    });

    // Start periodic sync (every 5 minutes)
    _startPeriodicSync();
  }

  /// Start periodic synchronization
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      syncData();
    });
  }

  /// Manually trigger data synchronization
  Future<bool> syncData() async {
    if (_isSyncing) return false;

    _isSyncing = true;
    bool success = false;

    try {
      // Process sync queue (items that need to be pushed to server)
      success = await _processSyncQueue();

      // Get latest data from server
      if (success) {
        await _pullDataFromServer();
      }

      // Update last sync time if successful
      if (success) {
        await _localDatabaseService.saveLastSyncTime(DateTime.now());
      }
    } catch (e) {
      success = false;
    } finally {
      _isSyncing = false;
    }

    return success;
  }

  /// Process items in the sync queue
  Future<bool> _processSyncQueue() async {
    final syncQueue = _localDatabaseService.getSyncQueue();
    if (syncQueue.isEmpty) return true;

    for (final item in syncQueue) {
      try {
        final operation = item['operation'] as String;
        final collection = item['collection'] as String;
        final id = item['id'] as String;
        final data = item['data'] as Map<String, dynamic>?;
        final key = item['key'];

        bool success = false;

        // Execute the operation on Firestore
        switch (operation) {
          case 'create':
          case 'update':
            if (data != null) {
              await _firestoreService.setDocument(collection, id, data);
              success = true;
            }
            break;
          case 'delete':
            await _firestoreService.deleteDocument(collection, id);
            success = true;
            break;
        }

        // Remove item from sync queue if operation was successful
        if (success) {
          await _localDatabaseService.removeFromSyncQueue(key);
        } else {
          // If we failed, abort and try again later
          return false;
        }
      } catch (e) {
        // If any operation fails, abort and try again later
        return false;
      }
    }

    return true;
  }

  /// Pull latest data from server
  Future<void> _pullDataFromServer() async {
    final lastSyncTime = _localDatabaseService.getLastSyncTime();

    // Collections to sync
    final collections = [
      'inventory',
      'suppliers',
      'sales',
      'forecasting',
    ];

    for (final collection in collections) {
      try {
        // Get documents that were updated after the last sync
        final documents = await _firestoreService.getDocumentsModifiedSince(
          collection,
          lastSyncTime,
        );

        // Update local database
        for (final doc in documents) {
          await _localDatabaseService.saveData(
            collection,
            doc['id'] as String,
            doc,
          );
        }
      } catch (e) {
        // Continue with next collection if one fails
        continue;
      }
    }
  }

  /// Schedule an item for synchronization when online
  Future<void> scheduleSync(String operation, String collection, String id,
      Map<String, dynamic>? data) async {
    // Save to local database immediately
    if (operation == 'create' || operation == 'update') {
      if (data != null) {
        await _localDatabaseService.saveData(collection, id, data);
      }
    } else if (operation == 'delete') {
      await _localDatabaseService.deleteData(collection, id);
    }

    // Add to sync queue
    await _localDatabaseService.addToSyncQueue(operation, collection, id, data);

    // Try to sync immediately if online
    final isConnected = await _isConnected();
    if (isConnected) {
      syncData();
    }
  }

  /// Check if the device is currently connected
  Future<bool> _isConnected() async {
    bool isConnected = false;

    await _connectivityService.statusStream.first.then((status) {
      isConnected = status == ConnectivityStatus.connected;
    }).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        isConnected = false;
        return null;
      },
    );

    return isConnected;
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }
}
