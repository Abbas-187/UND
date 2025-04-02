# Offline Support System

This module implements a comprehensive offline support system for the UND Inventory Application, allowing users to continue working even when internet connectivity is lost.

## Features

### Local Database Storage
- Persistent local storage using Hive
- Structured data storage for all application entities
- Fast read/write operations
- Low memory footprint

### Connectivity Management
- Real-time connectivity status monitoring
- Automatic detection of network state changes
- Event-based connectivity notifications
- Support for various connection types (WiFi, Mobile, Ethernet)

### Data Synchronization
- Bidirectional sync between local and remote databases
- Conflict resolution strategies
- Background synchronization with retry mechanisms
- Synchronization queue for offline operations
- Timestamp-based selective synchronization

### Offline Editing
- Full CRUD operations while offline
- Local operation queueing
- Automatic synchronization when connectivity is restored
- UI indicators for offline status and pending changes

## Architecture

### Core Components

1. **Services**:
   - `LocalDatabaseService`: Manages the local Hive database
   - `ConnectivityService`: Monitors network connectivity state
   - `SyncService`: Orchestrates data synchronization processes
   - `FirestoreService`: Handles remote database operations

2. **Models**:
   - Various entity models with JSON serialization/deserialization
   - Sync queue entries for pending operations

3. **Providers**:
   - `localDatabaseServiceProvider`: Provides access to local database
   - `connectivityServiceProvider`: Provides access to connectivity state
   - `connectivityStatusProvider`: Stream of connectivity changes
   - `syncServiceProvider`: Provides access to sync functionality

## Usage

### Working with Offline Data

```dart
// Saving data with offline support
Future<void> saveInventoryItem(InventoryItem item) async {
  try {
    final syncService = ref.read(syncServiceProvider);
    await syncService.scheduleSync(
      'update',
      'inventory',
      item.id,
      item.toJson(),
    );
  } catch (e) {
    // Handle error
  }
}

// Reading data with offline fallback
Future<InventoryItem?> getInventoryItem(String id) async {
  try {
    final localDb = ref.read(localDatabaseServiceProvider);
    final data = localDb.getData('inventory', id);
    
    if (data != null) {
      return InventoryItem.fromJson(data);
    }
    
    // If online, try to get from remote
    final connectivityStatus = ref.read(connectivityStatusProvider).value;
    if (connectivityStatus == ConnectivityStatus.connected) {
      final firestoreService = ref.read(firestoreServiceProvider);
      final remoteData = await firestoreService.getDocument('inventory', id);
      
      if (remoteData != null) {
        // Save to local for future offline access
        await localDb.saveData('inventory', id, remoteData);
        return InventoryItem.fromJson(remoteData);
      }
    }
    
    return null;
  } catch (e) {
    // Handle error
    return null;
  }
}
```

### Triggering Manual Synchronization

```dart
// Manually trigger synchronization
Future<void> syncData() async {
  final syncService = ref.read(syncServiceProvider);
  final success = await syncService.syncData();
  
  if (!success) {
    // Handle sync failure
  }
}
```

### Monitoring Connectivity Status

```dart
// Watching connectivity changes in UI
Widget build(BuildContext context, WidgetRef ref) {
  final connectivityStatus = ref.watch(connectivityStatusProvider);
  
  return connectivityStatus.when(
    data: (status) {
      final isOnline = status == ConnectivityStatus.connected;
      
      return Scaffold(
        appBar: AppBar(
          title: const Text('Inventory'),
          actions: [
            Icon(
              isOnline ? Icons.wifi : Icons.wifi_off,
              color: isOnline ? Colors.green : Colors.red,
            ),
          ],
        ),
        // ...
      );
    },
    loading: () => const LoadingScreen(),
    error: (_, __) => const ErrorScreen(),
  );
}
```

## Implementation Notes

1. All data operations check connectivity and use appropriate data source.
2. A background sync process attempts to synchronize data periodically.
3. Users are notified of offline status and pending sync operations.
4. The system prioritizes data availability and user experience over immediate consistency.
5. Data is securely stored locally with appropriate encryption methods. 