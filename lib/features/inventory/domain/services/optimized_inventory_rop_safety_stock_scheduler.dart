import 'dart:async';
import 'dart:isolate';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../core/data/unified_data_manager.dart';
import '../../../../core/data/optimized_repository.dart';
import '../entities/inventory_item.dart';
import '../usecases/apply_dynamic_reorder_point_usecase.dart';

/// Optimized ROP scheduler with background processing and incremental updates
class OptimizedInventoryRopSafetyStockScheduler {
  OptimizedInventoryRopSafetyStockScheduler({
    required this.ref,
    required this.inventoryRepository,
    required this.applyDynamicRopUseCase,
    this.batchSize = 50,
    this.processingInterval = const Duration(minutes: 5),
    this.fullRecalculationInterval = const Duration(hours: 1),
  });

  final ProviderContainer ref;
  final dynamic inventoryRepository; // Will be properly typed
  final dynamic applyDynamicRopUseCase; // Will be properly typed
  final int batchSize;
  final Duration processingInterval;
  final Duration fullRecalculationInterval;

  final Logger _logger = Logger();
  Timer? _incrementalTimer;
  Timer? _fullRecalculationTimer;
  StreamSubscription? _eventSubscription;
  bool _isProcessing = false;
  bool _isDisposed = false;

  // Track items that need recalculation
  final Set<String> _pendingRecalculations = {};
  DateTime? _lastFullRecalculation;

  /// Start the optimized scheduler
  void start() {
    if (_isDisposed) return;

    _logger.i('Starting optimized ROP scheduler');

    // Listen to inventory events for incremental updates
    _setupEventListener();

    // Start incremental processing timer
    _startIncrementalProcessing();

    // Start full recalculation timer
    _startFullRecalculationTimer();

    // Perform initial calculation in background
    _scheduleInitialCalculation();
  }

  /// Setup event listener for incremental updates
  void _setupEventListener() {
    _eventSubscription = UnifiedDataManager.instance.eventStream
        .where((event) => event.eventType == 'inventory_updated')
        .listen((event) async {
      if (event is InventoryUpdatedEvent) {
        await _handleInventoryUpdate(event);
      }
    });
  }

  /// Handle inventory update events
  Future<void> _handleInventoryUpdate(InventoryUpdatedEvent event) async {
    if (_isDisposed) return;

    _logger.d('Handling inventory update for item: ${event.itemId}');

    // Add to pending recalculations
    _pendingRecalculations.add(event.itemId);

    // If quantity dropped significantly, prioritize this item
    if (event.newQuantity < event.oldQuantity * 0.5) {
      await _processHighPriorityItem(event.itemId);
    }
  }

  /// Process high priority items immediately
  Future<void> _processHighPriorityItem(String itemId) async {
    if (_isDisposed) return;

    await PerformanceMonitor.trackAsync(
      'rop_process_high_priority',
      () async {
        try {
          final item = await inventoryRepository.findById(itemId);
          if (item != null) {
            await _calculateRopForItem(item);
            _pendingRecalculations.remove(itemId);
          }
        } catch (e) {
          _logger.e('Error processing high priority item $itemId: $e');
        }
      },
    );
  }

  /// Start incremental processing timer
  void _startIncrementalProcessing() {
    _incrementalTimer = Timer.periodic(processingInterval, (_) {
      if (!_isProcessing && _pendingRecalculations.isNotEmpty) {
        _processIncrementalUpdates();
      }
    });
  }

  /// Start full recalculation timer
  void _startFullRecalculationTimer() {
    _fullRecalculationTimer = Timer.periodic(fullRecalculationInterval, (_) {
      _scheduleFullRecalculation();
    });
  }

  /// Process incremental updates in batches
  Future<void> _processIncrementalUpdates() async {
    if (_isDisposed || _isProcessing) return;

    _isProcessing = true;

    await PerformanceMonitor.trackAsync(
      'rop_incremental_processing',
      () async {
        try {
          final itemsToProcess =
              _pendingRecalculations.take(batchSize).toList();
          _logger.i('Processing ${itemsToProcess.length} items incrementally');

          // Process in background isolate
          await _processItemsBatch(itemsToProcess);

          // Remove processed items
          for (final itemId in itemsToProcess) {
            _pendingRecalculations.remove(itemId);
          }
        } catch (e) {
          _logger.e('Error in incremental processing: $e');
        } finally {
          _isProcessing = false;
        }
      },
    );
  }

  /// Process a batch of items in background
  Future<void> _processItemsBatch(List<String> itemIds) async {
    if (_isDisposed) return;

    // Fetch items in batch
    final items = <InventoryItem>[];
    for (final itemId in itemIds) {
      try {
        final item = await inventoryRepository.findById(itemId);
        if (item != null) {
          items.add(item);
        }
      } catch (e) {
        _logger.w('Failed to fetch item $itemId: $e');
      }
    }

    if (items.isEmpty) return;

    // Calculate ROP for each item
    for (final item in items) {
      if (_isDisposed) break;

      try {
        await _calculateRopForItem(item);

        // Yield control periodically
        if (items.indexOf(item) % 10 == 0) {
          await Future.delayed(Duration.zero);
        }
      } catch (e) {
        _logger.w('Failed to calculate ROP for item ${item.id}: $e');
      }
    }
  }

  /// Calculate ROP for a single item
  Future<void> _calculateRopForItem(InventoryItem item) async {
    if (_isDisposed) return;

    try {
      // Use the existing use case but with optimizations
      await applyDynamicRopUseCase.execute(item.id);

      // Cache the calculation timestamp
      SmartCache.set(
        'rop_calculated_${item.id}',
        DateTime.now(),
        ttl: const Duration(hours: 2),
      );
    } catch (e) {
      _logger.w('ROP calculation failed for item ${item.id}: $e');
    }
  }

  /// Schedule initial calculation
  void _scheduleInitialCalculation() {
    if (_isDisposed) return;

    // Run initial calculation in background
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isDisposed) {
        _performInitialCalculation();
      }
    });
  }

  /// Perform initial calculation for all items
  Future<void> _performInitialCalculation() async {
    if (_isDisposed) return;

    await PerformanceMonitor.trackAsync(
      'rop_initial_calculation',
      () async {
        _logger.i('Starting initial ROP calculation');

        try {
          // Get all inventory items in batches
          int offset = 0;
          bool hasMore = true;

          while (hasMore && !_isDisposed) {
            final result = await inventoryRepository.findMany(
              QueryParams(
                limit: batchSize,
                offset: offset,
                orderBy: 'lastUpdated',
              ),
            );

            if (result.items.isEmpty) {
              hasMore = false;
              break;
            }

            // Process batch
            await _processItemsBatch(
              result.items.map((item) => item.id).toList(),
            );

            offset += batchSize;
            hasMore = result.hasMore;

            // Yield control between batches
            await Future.delayed(const Duration(milliseconds: 100));
          }

          _lastFullRecalculation = DateTime.now();
          _logger.i('Initial ROP calculation completed');
        } catch (e) {
          _logger.e('Error in initial calculation: $e');
        }
      },
    );
  }

  /// Schedule full recalculation
  void _scheduleFullRecalculation() {
    if (_isDisposed || _isProcessing) return;

    // Check if we really need a full recalculation
    if (_lastFullRecalculation != null) {
      final timeSinceLastFull =
          DateTime.now().difference(_lastFullRecalculation!);
      if (timeSinceLastFull < fullRecalculationInterval) {
        return; // Skip if too recent
      }
    }

    _logger.i('Scheduling full ROP recalculation');

    // Run in background
    Future.delayed(Duration.zero, () {
      if (!_isDisposed) {
        _performFullRecalculation();
      }
    });
  }

  /// Perform full recalculation
  Future<void> _performFullRecalculation() async {
    if (_isDisposed || _isProcessing) return;

    _isProcessing = true;

    await PerformanceMonitor.trackAsync(
      'rop_full_recalculation',
      () async {
        _logger.i('Starting full ROP recalculation');

        try {
          // Clear pending items since we're doing a full recalc
          _pendingRecalculations.clear();

          // Get count of items to process
          final totalItems = await inventoryRepository.count();
          _logger.i('Full recalculation for $totalItems items');

          int processed = 0;
          int offset = 0;
          bool hasMore = true;

          while (hasMore && !_isDisposed) {
            final result = await inventoryRepository.findMany(
              QueryParams(
                limit: batchSize,
                offset: offset,
                orderBy: 'lastUpdated',
              ),
            );

            if (result.items.isEmpty) {
              hasMore = false;
              break;
            }

            // Process batch in background
            await _processItemsBatch(
              result.items.map((item) => item.id).toList(),
            );

            processed += result.items.length as int;
            offset += batchSize;
            hasMore = result.hasMore;

            // Log progress
            if (processed % (batchSize * 5) == 0) {
              _logger.i('Full recalculation progress: $processed/$totalItems');
            }

            // Yield control between batches
            await Future.delayed(const Duration(milliseconds: 200));
          }

          _lastFullRecalculation = DateTime.now();
          _logger.i('Full ROP recalculation completed: $processed items');
        } catch (e) {
          _logger.e('Error in full recalculation: $e');
        } finally {
          _isProcessing = false;
        }
      },
    );
  }

  /// Get scheduler status
  Map<String, dynamic> getStatus() {
    return {
      'isProcessing': _isProcessing,
      'pendingRecalculations': _pendingRecalculations.length,
      'lastFullRecalculation': _lastFullRecalculation?.toIso8601String(),
      'isDisposed': _isDisposed,
    };
  }

  /// Force recalculation for specific items
  Future<void> forceRecalculation(List<String> itemIds) async {
    if (_isDisposed) return;

    _logger.i('Forcing recalculation for ${itemIds.length} items');
    _pendingRecalculations.addAll(itemIds);

    // Process immediately if not busy
    if (!_isProcessing) {
      await _processIncrementalUpdates();
    }
  }

  /// Pause the scheduler
  void pause() {
    _logger.i('Pausing ROP scheduler');
    _incrementalTimer?.cancel();
    _fullRecalculationTimer?.cancel();
  }

  /// Resume the scheduler
  void resume() {
    if (_isDisposed) return;

    _logger.i('Resuming ROP scheduler');
    _startIncrementalProcessing();
    _startFullRecalculationTimer();
  }

  /// Dispose the scheduler
  void dispose() {
    if (_isDisposed) return;

    _logger.i('Disposing optimized ROP scheduler');
    _isDisposed = true;

    _incrementalTimer?.cancel();
    _fullRecalculationTimer?.cancel();
    _eventSubscription?.cancel();

    _pendingRecalculations.clear();
  }
}

/// Provider for the optimized scheduler
final optimizedRopSchedulerProvider =
    Provider<OptimizedInventoryRopSafetyStockScheduler>((ref) {
  // Note: These providers need to be properly imported/defined when available
  // final inventoryRepo = ref.watch(inventoryRepositoryProvider);
  // final applyDynamicRop = ref.watch(applyDynamicReorderPointUseCaseProvider);

  final scheduler = OptimizedInventoryRopSafetyStockScheduler(
    ref: ref.container,
    inventoryRepository: null, // Will be properly injected
    applyDynamicRopUseCase: null, // Will be properly injected
  );

  // Auto-dispose when provider is disposed
  ref.onDispose(() {
    scheduler.dispose();
  });

  return scheduler;
});

/// Widget provider for the scheduler
class OptimizedRopSchedulerProvider extends ConsumerStatefulWidget {
  const OptimizedRopSchedulerProvider({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<OptimizedRopSchedulerProvider> createState() =>
      _OptimizedRopSchedulerProviderState();
}

class _OptimizedRopSchedulerProviderState
    extends ConsumerState<OptimizedRopSchedulerProvider> {
  OptimizedInventoryRopSafetyStockScheduler? _scheduler;

  @override
  void initState() {
    super.initState();

    // Initialize scheduler after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduler = ref.read(optimizedRopSchedulerProvider);
      _scheduler!.start();
    });
  }

  @override
  void dispose() {
    _scheduler?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
