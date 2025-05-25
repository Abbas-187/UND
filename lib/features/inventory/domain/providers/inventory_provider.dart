import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/inventory_item_model.dart';
import '../../data/models/inventory_transaction_model.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';
import 'inventory_filter.dart';

// Repository provider
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  // Use the real Firebase-based repository
  return InventoryRepositoryImpl();
});

// Inventory items provider
final inventoryProvider = StateNotifierProvider<InventoryStateNotifier,
    AsyncValue<List<InventoryItemModel>>>((ref) {
  return InventoryStateNotifier();
});

// State notifier for inventory management
class InventoryStateNotifier
    extends StateNotifier<AsyncValue<List<InventoryItemModel>>> {
  InventoryStateNotifier() : super(const AsyncValue.loading()) {
    loadInventory();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> loadInventory() async {
    try {
      state = const AsyncValue.loading();
      // Get all inventory items across all warehouses
      final snapshot = await _firestore.collection('inventory_items').get();
      final items = snapshot.docs
          .map((doc) => InventoryItemModel.fromFirestore(doc))
          .toList();
      state = AsyncValue.data(items);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Gets available stock for a material
  Future<double> getAvailableStock(String materialId) async {
    try {
      // Query for the specific materialId across all locations
      final snapshot = await _firestore
          .collection('inventory_items')
          .where('materialId', isEqualTo: materialId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      // Sum quantities across all locations
      double totalQuantity = 0.0;
      for (var doc in snapshot.docs) {
        final item = InventoryItemModel.fromFirestore(doc);
        totalQuantity += item.quantity;
      }
      return totalQuantity;
    } catch (e) {
      return 0.0;
    }
  }

  /// Reserves stock for a specific item
  Future<void> reserveStock({
    required String itemId,
    required double quantity,
    required String reason,
    required String referenceId,
  }) async {
    try {
      // Step 1: Get the current item
      final docRef = _firestore.collection('inventory_items').doc(itemId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) {
          throw Exception('Item not found');
        }

        final item = InventoryItemModel.fromFirestore(doc);

        // Step 2: Check if enough stock exists
        if (item.quantity < quantity) {
          throw Exception('Insufficient stock available');
        }

        // Calculate new quantities
        final availableQuantity = item.quantity - quantity;

        // Step 3: Update available quantity
        transaction.update(docRef, {
          'quantity': availableQuantity,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Step 4: Create reservation record
        final reservationRef =
            _firestore.collection('inventory_reservations').doc();
        transaction.set(reservationRef, {
          'itemId': itemId,
          'quantity': quantity,
          'reason': reason,
          'referenceId': referenceId,
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
          'expiresAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(hours: 24)),
          ),
        });

        // Step 5: Record transaction
        final transactionRef =
            _firestore.collection('inventory_transactions').doc();
        final inventoryTransaction = InventoryTransactionModel(
          materialId: item.id ?? '',
          materialName: item.name,
          warehouseId: item.location
              .split('/')
              .first, // Assuming location format is "warehouseId/locationId"
          transactionType: TransactionType.other,
          quantity: -quantity, // Negative because it's a reservation
          uom: item.unit,
          referenceNumber: referenceId,
          referenceType: 'reservation',
          reason: reason,
          transactionDate: DateTime.now(),
        );

        transaction.set(transactionRef, inventoryTransaction.toFirestore());
      });

      // Refresh inventory data
      await loadInventory();
    } catch (e) {
      rethrow;
    }
  }

  /// Gets optimal picking locations
  Future<List<Map<String, dynamic>>> getOptimalPickingLocations({
    required String itemId,
    required double quantity,
    bool useFEFO = true, // First Expiry, First Out
  }) async {
    try {
      // Step 1: Get all storage locations for this item
      final snapshot = await _firestore
          .collection('storage_locations')
          .where('itemId', isEqualTo: itemId)
          .where('quantity', isGreaterThan: 0)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('No stock locations found for this item');
      }

      // Step 2: Convert to list of locations with quantities
      final locations = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'locationId': doc.id,
          'warehouseId': data['warehouseId'] as String,
          'zoneName': data['zoneName'] as String? ?? 'Unknown',
          'binName': data['binName'] as String? ?? 'Unknown',
          'quantity': (data['quantity'] as num).toDouble(),
          'expiryDate': data['expiryDate'] != null
              ? (data['expiryDate'] as Timestamp).toDate()
              : null,
          'batchNumber': data['batchNumber'] as String?,
        };
      }).toList();

      // Step 3: Sort locations according to strategy
      if (useFEFO) {
        // FEFO: Sort by expiry date (nulls last)
        locations.sort((a, b) {
          final DateTime? dateA = a['expiryDate'] as DateTime?;
          final DateTime? dateB = b['expiryDate'] as DateTime?;

          // Handle nulls
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1; // A is null, B is not, so B comes first
          if (dateB == null) return -1; // B is null, A is not, so A comes first

          return dateA.compareTo(dateB); // A and B are not null, compare dates
        });
      } else {
        // FIFO: Sort by created date (or another appropriate field)
        // For this example, we'll just use locationId as a simple approximation
        locations.sort((a, b) =>
            (a['locationId'] as String).compareTo(b['locationId'] as String));
      }

      // Step 4: Determine optimal picking plan
      double remainingToPick = quantity;
      final pickingPlan = <Map<String, dynamic>>[];

      for (var location in locations) {
        if (remainingToPick <= 0) break;

        final availableAtLocation = location['quantity'] as double;
        final pickFromLocation = availableAtLocation >= remainingToPick
            ? remainingToPick
            : availableAtLocation;

        pickingPlan.add({
          ...location,
          'pickQuantity': pickFromLocation,
        });

        remainingToPick -= pickFromLocation;
      }

      if (remainingToPick > 0) {
        throw Exception('Insufficient stock available across all locations');
      }

      return pickingPlan;
    } catch (e) {
      return []; // Return empty array on error
    }
  }

  /// Decreases stock for a specific item
  Future<void> decreaseStock({
    required String itemId,
    required double quantity,
    required String reason,
    String? referenceId,
    String? locationId,
    String? batchNumber,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be positive');
    }

    try {
      // Step 1: Determine which locations to pick from
      final locations = locationId != null
          ? [
              {'locationId': locationId, 'quantity': quantity}
            ]
          : await getOptimalPickingLocations(
              itemId: itemId,
              quantity: quantity,
            );

      if (locations.isEmpty) {
        throw Exception('No suitable locations found for stock decrease');
      }

      // Step 2: Update stock in each location
      await _firestore.runTransaction((transaction) async {
        // Get the item first to get details
        final itemDocRef = _firestore.collection('inventory_items').doc(itemId);
        final itemDoc = await transaction.get(itemDocRef);

        if (!itemDoc.exists) {
          throw Exception('Item not found');
        }

        final item = InventoryItemModel.fromFirestore(itemDoc);

        // Update the main inventory item
        transaction.update(itemDocRef, {
          'quantity': FieldValue.increment(-quantity),
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Create transaction record
        final transactionRef =
            _firestore.collection('inventory_transactions').doc();
        final inventoryTransaction = InventoryTransactionModel(
          materialId: item.id ?? '',
          materialName: item.name,
          warehouseId: item.location.split('/').first,
          transactionType: TransactionType.issue,
          quantity: -quantity, // Negative for decrease
          uom: item.unit,
          batchNumber: batchNumber,
          sourceLocationId: locationId,
          referenceNumber: referenceId,
          reason: reason,
          transactionDate: DateTime.now(),
        );

        transaction.set(transactionRef, inventoryTransaction.toFirestore());

        // Update each storage location
        for (final location in locations) {
          final locationDocRef = _firestore
              .collection('storage_locations')
              .doc(location['locationId'] as String);

          final pickQuantity = location['pickQuantity'] as double? ?? quantity;

          // Update the location quantity
          transaction.update(locationDocRef, {
            'quantity': FieldValue.increment(-pickQuantity),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });

      // Refresh inventory data
      await loadInventory();
    } catch (e) {
      rethrow;
    }
  }

  /// Increases stock for a specific item
  Future<void> increaseStock({
    required String itemId,
    required double quantity,
    String? batchNumber,
    DateTime? productionDate,
    DateTime? expiryDate,
    String? locationId,
    required String reason,
    String? referenceId,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be positive');
    }

    try {
      await _firestore.runTransaction((transaction) async {
        // Get the item first to get details
        final itemDocRef = _firestore.collection('inventory_items').doc(itemId);
        final itemDoc = await transaction.get(itemDocRef);

        if (!itemDoc.exists) {
          throw Exception('Item not found');
        }

        final item = InventoryItemModel.fromFirestore(itemDoc);

        // Determine location ID if not provided
        final String finalLocationId = locationId ?? item.location;

        // Update the main inventory item
        transaction.update(itemDocRef, {
          'quantity': FieldValue.increment(quantity),
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Create transaction record
        final transactionRef =
            _firestore.collection('inventory_transactions').doc();
        final inventoryTransaction = InventoryTransactionModel(
          materialId: item.id ?? '',
          materialName: item.name,
          warehouseId: item.location.split('/').first,
          transactionType: TransactionType.receipt,
          quantity: quantity, // Positive for increase
          uom: item.unit,
          batchNumber: batchNumber,
          destinationLocationId: finalLocationId,
          referenceNumber: referenceId,
          reason: reason,
          transactionDate: DateTime.now(),
        );

        transaction.set(transactionRef, inventoryTransaction.toFirestore());

        // Update or create the storage location record
        final locationDocRef =
            _firestore.collection('storage_locations').doc(finalLocationId);

        final locationDoc = await transaction.get(locationDocRef);

        if (locationDoc.exists) {
          // Update existing location
          transaction.update(locationDocRef, {
            'quantity': FieldValue.increment(quantity),
            'lastUpdated': FieldValue.serverTimestamp(),
            // Only update these if provided and the location exists
            if (batchNumber != null) 'batchNumber': batchNumber,
            if (expiryDate != null)
              'expiryDate': Timestamp.fromDate(expiryDate),
          });
        } else {
          // Create new location record
          transaction.set(locationDocRef, {
            'itemId': itemId,
            'warehouseId': item.location.split('/').first,
            'quantity': quantity,
            'unit': item.unit,
            'batchNumber': batchNumber,
            'productionDate': productionDate != null
                ? Timestamp.fromDate(productionDate)
                : null,
            'expiryDate':
                expiryDate != null ? Timestamp.fromDate(expiryDate) : null,
            'createdAt': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });

      // Refresh inventory data
      await loadInventory();
    } catch (e) {
      rethrow;
    }
  }

  /// Adds items to damaged inventory
  Future<void> addToDamagedInventory({
    required String itemId,
    required double quantity,
    required String reason,
    String? referenceId,
    String? notes,
    String? batchNumber,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Get the item first to get details
        final itemDocRef = _firestore.collection('inventory_items').doc(itemId);
        final itemDoc = await transaction.get(itemDocRef);

        if (!itemDoc.exists) {
          throw Exception('Item not found');
        }

        final item = InventoryItemModel.fromFirestore(itemDoc);

        // Check if enough stock exists
        if (item.quantity < quantity) {
          throw Exception('Insufficient stock available');
        }

        // Update main inventory (decrease normal stock)
        transaction.update(itemDocRef, {
          'quantity': FieldValue.increment(-quantity),
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Create or update damaged inventory record
        final damagedInventoryRef = _firestore
            .collection('damaged_inventory')
            .doc(); // Generate new ID for each record

        transaction.set(damagedInventoryRef, {
          'itemId': itemId,
          'materialName': item.name,
          'quantity': quantity,
          'unit': item.unit,
          'reason': reason,
          'referenceId': referenceId,
          'notes': notes,
          'batchNumber': batchNumber,
          'reportedAt': FieldValue.serverTimestamp(),
          'status': 'pending_inspection', // Initial status
        });

        // Record transaction
        final transactionRef =
            _firestore.collection('inventory_transactions').doc();
        final inventoryTransaction = InventoryTransactionModel(
          materialId: item.id ?? '',
          materialName: item.name,
          warehouseId: item.location.split('/').first,
          transactionType: TransactionType.other,
          quantity: -quantity, // Negative for removal from normal stock
          uom: item.unit,
          batchNumber: batchNumber,
          referenceNumber: referenceId,
          referenceType: 'damaged_inventory',
          reason: reason,
          notes: notes,
          transactionDate: DateTime.now(),
        );

        transaction.set(transactionRef, inventoryTransaction.toFirestore());
      });

      // Refresh inventory data
      await loadInventory();
    } catch (e) {
      rethrow;
    }
  }

  /// Adds items to quality hold
  Future<void> addToQualityHold({
    required String itemId,
    required double quantity,
    required String reason,
    String? referenceId,
    String? batchNumber,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Get the item first to get details
        final itemDocRef = _firestore.collection('inventory_items').doc(itemId);
        final itemDoc = await transaction.get(itemDocRef);

        if (!itemDoc.exists) {
          throw Exception('Item not found');
        }

        final item = InventoryItemModel.fromFirestore(itemDoc);

        // Check if enough stock exists
        if (item.quantity < quantity) {
          throw Exception('Insufficient stock available');
        }

        // Update main inventory (decrease normal stock)
        transaction.update(itemDocRef, {
          'quantity': FieldValue.increment(-quantity),
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Create quality hold record
        final qualityHoldRef = _firestore
            .collection('quality_holds')
            .doc(); // Generate new ID for each hold

        transaction.set(qualityHoldRef, {
          'itemId': itemId,
          'materialName': item.name,
          'quantity': quantity,
          'unit': item.unit,
          'reason': reason,
          'referenceId': referenceId,
          'batchNumber': batchNumber,
          'heldAt': FieldValue.serverTimestamp(),
          'status': 'on_hold', // Initial status
          'expectedResolutionDate': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 7)),
          ),
        });

        // Record transaction
        final transactionRef =
            _firestore.collection('inventory_transactions').doc();
        final inventoryTransaction = InventoryTransactionModel(
          materialId: item.id ?? '',
          materialName: item.name,
          warehouseId: item.location.split('/').first,
          transactionType: TransactionType.other,
          quantity: -quantity, // Negative for removal from normal stock
          uom: item.unit,
          batchNumber: batchNumber,
          referenceNumber: referenceId,
          referenceType: 'quality_hold',
          reason: reason,
          transactionDate: DateTime.now(),
        );

        transaction.set(transactionRef, inventoryTransaction.toFirestore());
      });

      // Refresh inventory data
      await loadInventory();
    } catch (e) {
      rethrow;
    }
  }
}

/// Provider for inventory items by warehouse
final inventoryByWarehouseProvider =
    FutureProvider.family<List<InventoryItem>, String>(
        (ref, warehouseId) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  final items = await repository.getItems();
  return items.where((item) => item.location.startsWith(warehouseId)).toList();
});

/// Provider for a single inventory item
final inventoryItemProvider =
    FutureProvider.family<InventoryItem?, String>((ref, itemId) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  return await repository.getItem(itemId);
});

// Filter provider
final inventoryFilterProvider =
    StateProvider<InventoryFilter>((ref) => const InventoryFilter());

// Filtered inventory items provider
final filteredInventoryItemsProvider =
    Provider<AsyncValue<List<InventoryItemModel>>>((ref) {
  final items = ref.watch(inventoryProvider);
  final filter = ref.watch(inventoryFilterProvider);

  return items.when(
    data: (items) {
      return AsyncValue.data(items.where((item) {
        // Apply search filter
        if (filter.searchQuery.isNotEmpty) {
          final query = filter.searchQuery.toLowerCase();
          if (!item.name.toLowerCase().contains(query) &&
              !item.category.toLowerCase().contains(query) &&
              !(item.batchNumber?.toLowerCase().contains(query) ?? false)) {
            return false;
          }
        }

        // Apply category filter
        if (filter.selectedCategory != null &&
            item.category != filter.selectedCategory) {
          return false;
        }

        // Apply location filter
        if (filter.selectedLocation != null &&
            item.location != filter.selectedLocation) {
          return false;
        }

        // Apply stock status filters
        if (filter.showLowStock && !item.isLowStock) {
          return false;
        }

        if (filter.showNeedsReorder && !item.needsReorder) {
          return false;
        }

        if (filter.showExpiringSoon && item.expiryDate != null) {
          final daysUntilExpiry =
              item.expiryDate!.difference(DateTime.now()).inDays;
          if (daysUntilExpiry > 30) {
            return false;
          }
        }

        return true;
      }).toList());
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
