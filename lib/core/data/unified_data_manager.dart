import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart';

/// Domain events for event-driven architecture
abstract class DomainEvent {
  const DomainEvent({
    required this.id,
    required this.timestamp,
    required this.eventType,
    required this.aggregateId,
  });

  final String id;
  final DateTime timestamp;
  final String eventType;
  final String aggregateId;

  Map<String, dynamic> toJson();
}

class InventoryUpdatedEvent extends DomainEvent {
  const InventoryUpdatedEvent({
    required super.id,
    required super.timestamp,
    required super.aggregateId,
    required this.itemId,
    required this.newQuantity,
    required this.oldQuantity,
    required this.reason,
  }) : super(eventType: 'inventory_updated');

  final String itemId;
  final double newQuantity;
  final double oldQuantity;
  final String reason;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'eventType': eventType,
        'aggregateId': aggregateId,
        'itemId': itemId,
        'newQuantity': newQuantity,
        'oldQuantity': oldQuantity,
        'reason': reason,
      };
}

class ProductionExecutionEvent extends DomainEvent {
  const ProductionExecutionEvent({
    required super.id,
    required super.timestamp,
    required super.aggregateId,
    required this.executionId,
    required this.status,
    required this.materialConsumption,
  }) : super(eventType: 'production_execution_updated');

  final String executionId;
  final String status;
  final Map<String, double> materialConsumption;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'eventType': eventType,
        'aggregateId': aggregateId,
        'executionId': executionId,
        'status': status,
        'materialConsumption': materialConsumption,
      };
}

/// Performance monitoring
class PerformanceMonitor {
  static final Logger _logger = Logger();
  static final Map<String, Stopwatch> _operations = {};

  static void startOperation(String operationId) {
    _operations[operationId] = Stopwatch()..start();
  }

  static void endOperation(String operationId,
      {Map<String, dynamic>? metadata}) {
    final stopwatch = _operations.remove(operationId);
    if (stopwatch != null) {
      final duration = stopwatch.elapsedMilliseconds;
      _logger.i('Operation $operationId completed in ${duration}ms');

      // Track slow operations
      if (duration > 1000) {
        _logger.w('Slow operation detected: $operationId took ${duration}ms');
      }
    }
  }

  static Future<T> trackAsync<T>(
    String operation,
    Future<T> Function() fn, {
    Map<String, dynamic>? metadata,
  }) async {
    startOperation(operation);
    try {
      final result = await fn();
      endOperation(operation, metadata: metadata);
      return result;
    } catch (e) {
      endOperation(operation, metadata: {...?metadata, 'error': e.toString()});
      rethrow;
    }
  }
}

/// Cache entry with TTL
class CacheEntry<T> {
  const CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });

  final T data;
  final DateTime timestamp;
  final Duration ttl;

  bool get isExpired => DateTime.now().difference(timestamp) > ttl;
}

/// Smart caching layer
class SmartCache {
  static final Map<String, CacheEntry> _cache = {};
  static final Logger _logger = Logger();

  static T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.data as T?;
  }

  static void set<T>(
    String key,
    T data, {
    Duration ttl = const Duration(minutes: 5),
  }) {
    _cache[key] = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl,
    );
  }

  static void invalidate(String key) {
    _cache.remove(key);
  }

  static void invalidatePattern(String pattern) {
    final regex = RegExp(pattern);
    _cache.removeWhere((key, _) => regex.hasMatch(key));
  }

  static void clear() {
    _cache.clear();
  }

  static int get size => _cache.length;
}

/// Background calculation service
class BackgroundCalculationService {
  static SendPort? _sendPort;
  static Isolate? _isolate;
  static final Completer<void> _isolateReady = Completer<void>();

  static Future<void> initialize() async {
    if (_isolate != null) return;

    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_isolateEntryPoint, receivePort.sendPort);

    receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        _isolateReady.complete();
      }
    });

    await _isolateReady.future;
  }

  static void _isolateEntryPoint(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) async {
      if (message is Map<String, dynamic>) {
        final operation = message['operation'] as String;
        final data = message['data'];
        final responsePort = message['responsePort'] as SendPort;

        try {
          dynamic result;
          switch (operation) {
            case 'calculateBomCost':
              result = await _calculateBomCostInIsolate(data);
              break;
            case 'calculateInventoryMetrics':
              result = await _calculateInventoryMetricsInIsolate(data);
              break;
            case 'processProductionData':
              result = await _processProductionDataInIsolate(data);
              break;
          }
          responsePort.send({'success': true, 'result': result});
        } catch (e) {
          responsePort.send({'success': false, 'error': e.toString()});
        }
      }
    });
  }

  static Future<double> calculateBomCostAsync(
    List<Map<String, dynamic>> items,
    double batchSize,
  ) async {
    await _isolateReady.future;
    if (_sendPort == null) throw StateError('Isolate not ready');

    final receivePort = ReceivePort();
    _sendPort!.send({
      'operation': 'calculateBomCost',
      'data': {'items': items, 'batchSize': batchSize},
      'responsePort': receivePort.sendPort,
    });

    final response = await receivePort.first as Map<String, dynamic>;
    if (response['success'] == true) {
      return response['result'] as double;
    } else {
      throw Exception(response['error']);
    }
  }

  static Future<Map<String, dynamic>> calculateInventoryMetricsAsync(
    List<Map<String, dynamic>> inventoryData,
  ) async {
    await _isolateReady.future;
    if (_sendPort == null) throw StateError('Isolate not ready');

    final receivePort = ReceivePort();
    _sendPort!.send({
      'operation': 'calculateInventoryMetrics',
      'data': inventoryData,
      'responsePort': receivePort.sendPort,
    });

    final response = await receivePort.first as Map<String, dynamic>;
    if (response['success'] == true) {
      return response['result'] as Map<String, dynamic>;
    } else {
      throw Exception(response['error']);
    }
  }

  static Future<double> _calculateBomCostInIsolate(
      Map<String, dynamic> data) async {
    final items = data['items'] as List<Map<String, dynamic>>;
    final batchSize = data['batchSize'] as double;

    double totalCost = 0.0;
    for (final item in items) {
      if (item['isActive'] == true) {
        final quantity = (item['quantity'] as num).toDouble();
        final unitCost = (item['unitCost'] as num?)?.toDouble() ?? 0.0;
        totalCost += quantity * unitCost * batchSize;
      }
    }
    return totalCost;
  }

  static Future<Map<String, dynamic>> _calculateInventoryMetricsInIsolate(
    List<Map<String, dynamic>> inventoryData,
  ) async {
    double totalValue = 0.0;
    int lowStockItems = 0;
    int expiredItems = 0;
    final now = DateTime.now();

    for (final item in inventoryData) {
      final quantity = (item['quantity'] as num).toDouble();
      final cost = (item['cost'] as num?)?.toDouble() ?? 0.0;
      final minimumQuantity = (item['minimumQuantity'] as num).toDouble();
      final expiryDateStr = item['expiryDate'] as String?;

      totalValue += quantity * cost;

      if (quantity <= minimumQuantity) {
        lowStockItems++;
      }

      if (expiryDateStr != null) {
        final expiryDate = DateTime.parse(expiryDateStr);
        if (expiryDate.isBefore(now)) {
          expiredItems++;
        }
      }
    }

    return {
      'totalValue': totalValue,
      'lowStockItems': lowStockItems,
      'expiredItems': expiredItems,
      'totalItems': inventoryData.length,
    };
  }

  static Future<Map<String, dynamic>> _processProductionDataInIsolate(
    Map<String, dynamic> data,
  ) async {
    // Complex production calculations
    return {'processed': true, 'timestamp': DateTime.now().toIso8601String()};
  }

  static Future<void> dispose() async {
    _isolate?.kill();
    _isolate = null;
    _sendPort = null;
  }
}

/// Unified data manager coordinating all data operations
class UnifiedDataManager {
  static UnifiedDataManager? _instance;
  static UnifiedDataManager get instance =>
      _instance ??= UnifiedDataManager._();

  UnifiedDataManager._();

  final Logger _logger = Logger();
  final StreamController<DomainEvent> _eventStream =
      StreamController.broadcast();
  final Map<String, StreamSubscription> _subscriptions = {};
  bool _isInitialized = false;

  Stream<DomainEvent> get eventStream => _eventStream.stream;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await PerformanceMonitor.trackAsync('unified_data_manager_init', () async {
      await BackgroundCalculationService.initialize();
      await _setupConnectivityListener();
      await _setupEventHandlers();
      _isInitialized = true;
      _logger.i('UnifiedDataManager initialized successfully');
    });
  }

  Future<void> _setupConnectivityListener() async {
    final connectivity = Connectivity();
    _subscriptions['connectivity'] = connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        final result =
            results.isNotEmpty ? results.first : ConnectivityResult.none;
        if (result != ConnectivityResult.none) {
          await _syncPendingChanges();
        }
      },
    );
  }

  Future<void> _setupEventHandlers() async {
    _eventStream.stream.listen((event) async {
      await _handleDomainEvent(event);
    });
  }

  Future<void> _handleDomainEvent(DomainEvent event) async {
    switch (event.eventType) {
      case 'inventory_updated':
        await _handleInventoryUpdate(event as InventoryUpdatedEvent);
        break;
      case 'production_execution_updated':
        await _handleProductionUpdate(event as ProductionExecutionEvent);
        break;
    }
  }

  Future<void> _handleInventoryUpdate(InventoryUpdatedEvent event) async {
    // Invalidate related caches
    SmartCache.invalidatePattern('inventory_.*');
    SmartCache.invalidatePattern('bom_.*_${event.itemId}');

    // Trigger dependent calculations
    if (event.newQuantity <= 0) {
      await _triggerReorderPointCalculation(event.itemId);
    }
  }

  Future<void> _handleProductionUpdate(ProductionExecutionEvent event) async {
    // Update inventory based on material consumption
    for (final entry in event.materialConsumption.entries) {
      final materialId = entry.key;
      final consumedQuantity = entry.value;

      // This would trigger inventory updates
      await _updateInventoryFromProduction(materialId, consumedQuantity);
    }
  }

  Future<void> _triggerReorderPointCalculation(String itemId) async {
    // Background calculation for reorder points
    _logger.i('Triggering reorder point calculation for item: $itemId');
  }

  Future<void> _updateInventoryFromProduction(
      String materialId, double quantity) async {
    // Update inventory quantities based on production consumption
    _logger.i('Updating inventory $materialId by -$quantity from production');
  }

  Future<void> _syncPendingChanges() async {
    await PerformanceMonitor.trackAsync('sync_pending_changes', () async {
      _logger.i('Syncing pending changes...');
      // Implement sync logic
    });
  }

  void publishEvent(DomainEvent event) {
    _eventStream.add(event);
  }

  Future<void> dispose() async {
    for (final subscription in _subscriptions.values) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    await _eventStream.close();
    await BackgroundCalculationService.dispose();
    _isInitialized = false;
  }
}
