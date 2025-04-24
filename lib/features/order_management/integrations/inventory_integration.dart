import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import '../models/order.dart';
import '../../../features/inventory/domain/repositories/inventory_repository.dart';
import '../../../features/inventory/domain/entities/inventory_item.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/errors/exceptions.dart';
import '../../../shared/constants/api_endpoints.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Service for integrating the order management module with the inventory system
class OrderInventoryIntegrationService {
  final InventoryRepository _inventoryRepository;
  final DefaultCacheManager? _cacheManager;

  OrderInventoryIntegrationService({
    required InventoryRepository inventoryRepository,
    DefaultCacheManager? cacheManager,
  })  : _inventoryRepository = inventoryRepository,
        _cacheManager = cacheManager ?? DefaultCacheManager();

  /// Check if all items in the order are available in inventory
  /// Returns a map with item names and availability status
  Future<Map<String, bool>> checkInventoryAvailability(Order order) async {
    try {
      Map<String, bool> availabilityMap = {};
      final cacheKey = 'inventory_items_${DateTime.now().day}';

      // Try to get inventory from cache first
      List<InventoryItem> inventoryItems;
      try {
        final cacheFile = await _cacheManager?.getFileFromCache(cacheKey);
        if (cacheFile != null) {
          // Use cached inventory data if it exists
          final cachedData = await cacheFile.file.readAsString();
          final List<dynamic> jsonList = jsonDecode(cachedData);
          inventoryItems =
              jsonList.map((json) => InventoryItem.fromJson(json)).toList();
        } else {
          // Fetch from repository and cache
          inventoryItems = await _inventoryRepository.getItems();
          // Cache the result for 30 minutes
          final jsonList = inventoryItems.map((item) => item.toJson()).toList();
          final jsonString = jsonEncode(jsonList);
          await _cacheManager?.putFile(
            cacheKey,
            Uint8List.fromList(jsonString.codeUnits),
            maxAge: const Duration(minutes: 30),
          );
        }
      } catch (e) {
        // If cache fails, get directly from repository
        inventoryItems = await _inventoryRepository.getItems();
      }

      // Check each order item against inventory
      for (var orderItem in order.items) {
        // Find matching inventory item by name (in a real system, you'd use product IDs)
        bool itemAvailable = false;

        for (var inventoryItem in inventoryItems) {
          if (inventoryItem.name.toLowerCase() ==
              orderItem.name.toLowerCase()) {
            // Check if enough quantity is available
            itemAvailable = inventoryItem.quantity >= orderItem.quantity;
            break;
          }
        }

        availabilityMap[orderItem.name] = itemAvailable;
      }

      return availabilityMap;
    } catch (e) {
      throw Exception(
          'Failed to check inventory availability: ${e.toString()}');
    }
  }

  /// Reserve inventory items for an order
  /// Returns true if all items were successfully reserved
  Future<bool> reserveInventory(Order order) async {
    try {
      for (var orderItem in order.items) {
        // Find matching inventory item (in a real system, you'd use product IDs)
        List<InventoryItem> matchingItems =
            await _inventoryRepository.searchItems(orderItem.name);

        if (matchingItems.isEmpty) {
          return false; // Item not found in inventory
        }

        InventoryItem inventoryItem = matchingItems.first;

        // Check if enough quantity is available
        if (inventoryItem.quantity < orderItem.quantity) {
          return false; // Not enough quantity
        }

        // Adjust inventory (reduce quantity)
        await _inventoryRepository.adjustQuantity(
          inventoryItem.id,
          -orderItem.quantity.toDouble(), // Convert to double
          'Reserved for Order: ${order.id}',
        );
      }

      return true;
    } catch (e) {
      print('Error reserving inventory: $e');
      return false;
    }
  }

  /// Release reserved inventory items (for cancelled orders)
  Future<bool> releaseInventory(Order order) async {
    try {
      for (var orderItem in order.items) {
        // Find matching inventory item
        List<InventoryItem> matchingItems =
            await _inventoryRepository.searchItems(orderItem.name);

        if (matchingItems.isNotEmpty) {
          InventoryItem inventoryItem = matchingItems.first;

          // Adjust inventory (increase quantity)
          await _inventoryRepository.adjustQuantity(
            inventoryItem.id,
            orderItem.quantity.toDouble(), // Convert to double
            'Released from cancelled Order: ${order.id}',
          );
        }
      }

      return true;
    } catch (e) {
      print('Error releasing inventory: $e');
      return false;
    }
  }

  /// Check if any items need procurement and return those items
  Future<List<OrderItem>> getItemsNeedingProcurement(Order order) async {
    List<OrderItem> itemsNeedingProcurement = [];

    // Get all inventory items
    List<InventoryItem> inventoryItems = await _inventoryRepository.getItems();

    for (var orderItem in order.items) {
      bool needsProcurement = true;

      for (var inventoryItem in inventoryItems) {
        if (inventoryItem.name.toLowerCase() == orderItem.name.toLowerCase()) {
          // If inventory has enough quantity, no procurement needed
          if (inventoryItem.quantity >= orderItem.quantity) {
            needsProcurement = false;
          }
          break;
        }
      }

      if (needsProcurement) {
        itemsNeedingProcurement.add(orderItem);
      }
    }

    return itemsNeedingProcurement;
  }

  /// Consume inventory when order moves to production
  Future<bool> consumeInventoryForProduction(Order order) async {
    try {
      // Similar to reserveInventory but with different reason text
      for (var orderItem in order.items) {
        List<InventoryItem> matchingItems =
            await _inventoryRepository.searchItems(orderItem.name);

        if (matchingItems.isNotEmpty) {
          InventoryItem inventoryItem = matchingItems.first;

          await _inventoryRepository.adjustQuantity(
            inventoryItem.id,
            -orderItem.quantity.toDouble(), // Convert to double
            'Consumed for Order: ${order.id} in Production',
          );
        } else {
          return false; // Item not found in inventory
        }
      }

      return true;
    } catch (e) {
      print('Error consuming inventory: $e');
      return false;
    }
  }

  /// Set up real-time inventory monitoring for specific items
  /// Returns a stream of inventory updates for the items in the order
  Stream<Map<String, double>> monitorInventoryLevels(List<String> itemNames) {
    try {
      // Use getItems() and poll periodically as a workaround since getInventoryStream() is not available
      StreamController<Map<String, double>> controller =
          StreamController<Map<String, double>>();

      Timer.periodic(const Duration(minutes: 5), (timer) async {
        try {
          final inventoryItems = await _inventoryRepository.getItems();
          Map<String, double> itemLevels = {};

          for (var name in itemNames) {
            // Find the item in the inventory
            var matchingItems = inventoryItems
                .where((item) => item.name.toLowerCase() == name.toLowerCase())
                .toList();

            if (matchingItems.isNotEmpty) {
              itemLevels[name] = matchingItems.first.quantity;
            } else {
              itemLevels[name] = 0.0;
            }
          }

          controller.add(itemLevels);
        } catch (e) {
          controller.addError(e);
        }
      });

      // Initial data
      _inventoryRepository.getItems().then((inventoryItems) {
        Map<String, double> itemLevels = {};
        for (var name in itemNames) {
          var matchingItems = inventoryItems
              .where((item) => item.name.toLowerCase() == name.toLowerCase())
              .toList();

          if (matchingItems.isNotEmpty) {
            itemLevels[name] = matchingItems.first.quantity;
          } else {
            itemLevels[name] = 0.0;
          }
        }
        controller.add(itemLevels);
      }).catchError((e) {
        controller.addError(e);
      });

      return controller.stream;
    } catch (e) {
      throw Exception('Failed to monitor inventory levels: ${e.toString()}');
    }
  }

  /// Check if inventory levels are below reorder thresholds
  /// Returns a list of items that need reordering
  Future<List<InventoryItem>> getItemsBelowThreshold() async {
    try {
      final allItems = await _inventoryRepository.getItems();
      return allItems
          .where((item) => item.quantity <= item.reorderPoint)
          .toList();
    } catch (e) {
      throw Exception('Failed to check inventory thresholds: ${e.toString()}');
    }
  }
}

// Provider for the OrderInventoryIntegrationService
final orderInventoryIntegrationProvider =
    Provider<OrderInventoryIntegrationService>((ref) {
  // Use dependency injection to get the repository
  // Change this to match your actual repository provider name
  final inventoryRepository = ref.watch(inventoryRepositoryImplProvider);
  return OrderInventoryIntegrationService(
      inventoryRepository: inventoryRepository);
});
