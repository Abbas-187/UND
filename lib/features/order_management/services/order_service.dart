// OrderService for handling order-related business logic and API integration
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/utils/network_info.dart';
import '../../../shared/constants/api_endpoints.dart';
import '../../../providers/network_providers.dart';
import '../models/order.dart';
import '../models/user_role.dart';
import '../integrations/inventory_integration.dart';
import '../integrations/customer_profile_integration.dart';
import '../providers/order_provider.dart';
import '../../procurement/services/procurement_service.dart';
import '../../production/services/production_service.dart';
import '../models/order_discussion.dart';
import '../services/order_discussion_service.dart';
import '../services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// OrderService handles all order-related operations
/// Including fetching, creating, and updating orders
class OrderService {
  final OrderInventoryIntegrationService? _inventoryIntegration;
  final CustomerProfileIntegrationService? _customerProfileService;
  final ProcurementService? _procurementService;
  final ProductionService? _productionService;
  final NotificationService? _notificationService;
  final OrderDiscussionService? _discussionService;
  final http.Client _httpClient;
  final DefaultCacheManager _cacheManager;
  final NetworkInfo _networkInfo;

  OrderService({
    OrderInventoryIntegrationService? inventoryIntegration,
    CustomerProfileIntegrationService? customerProfileService,
    ProcurementService? procurementService,
    ProductionService? productionService,
    NotificationService? notificationService,
    OrderDiscussionService? discussionService,
    http.Client? httpClient,
    DefaultCacheManager? cacheManager,
    NetworkInfo? networkInfo,
  })  : _inventoryIntegration = inventoryIntegration,
        _customerProfileService = customerProfileService,
        _procurementService = procurementService,
        _productionService = productionService,
        _notificationService = notificationService,
        _discussionService = discussionService,
        _httpClient = httpClient ?? http.Client(),
        _cacheManager = cacheManager ?? DefaultCacheManager(),
        _networkInfo = networkInfo ?? NetworkInfo();

  /// Fetches orders based on filter criteria
  Future<List<Order>> fetchOrders({
    String? userId,
    String? location,
    RoleType? role,
  }) async {
    try {
      // Create a unique cache key based on the filter parameters
      final String cacheKey =
          'orders_${userId ?? ''}_${location ?? ''}_${role?.toString() ?? ''}';

      // Check for connectivity first
      final bool isConnected = await _networkInfo.isConnected;

      // Try to get data from cache first if we're offline or for immediate UI display
      if (!isConnected || true) {
        // Always check cache first for performance
        try {
          final cacheFile = await _cacheManager.getFileFromCache(cacheKey);
          if (cacheFile != null) {
            final String cacheData = await cacheFile.file.readAsString();
            final List<dynamic> decodedData = json.decode(cacheData);
            final orders =
                decodedData.map((data) => Order.fromJson(data)).toList();

            // If we're offline, return cached data
            if (!isConnected) {
              return orders;
            }

            // If we're online, we'll still return cached data first, then update it
            // This is sometimes called the "stale-while-revalidate" pattern
            _fetchAndCacheFreshOrders(cacheKey, userId, location, role);
            return orders;
          }
        } catch (e) {
          // Cache error, continue to API call
          print('Cache error: $e');
        }
      }

      // If no cached data or we need fresh data, fetch from API
      if (isConnected) {
        return await _fetchAndCacheFreshOrders(
            cacheKey, userId, location, role);
      } else {
        // If we're offline and have no cache, throw a network exception
        throw NetworkException(
            'No internet connection and no cached data available');
      }
    } catch (e) {
      if (e is NetworkException) {
        rethrow; // We've already formatted this exception
      } else if (e is http.ClientException) {
        throw NetworkException('Network error: ${e.message}');
      } else if (e is FormatException) {
        throw DataParsingException('Error parsing order data');
      } else {
        throw ServiceException('Failed to fetch orders: ${e.toString()}');
      }
    }
  }

  /// Helper method to fetch fresh data from API and update cache
  Future<List<Order>> _fetchAndCacheFreshOrders(
      String cacheKey, String? userId, String? location, RoleType? role) async {
    // Build query parameters
    final Map<String, String> queryParams = {};
    if (userId != null) queryParams['userId'] = userId;
    if (location != null) queryParams['location'] = location;
    if (role != null) queryParams['role'] = role.toString();

    // Construct the URL with query parameters
    final Uri uri = Uri.parse('${ApiEndpoints.orders}')
        .replace(queryParameters: queryParams);

    // Make the API call with timeout and headers
    final response = await _httpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _getAuthToken()}',
      },
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw RequestTimeoutException('Request timed out');
      },
    );

    // Check response status code
    if (response.statusCode == 200) {
      final List<dynamic> decodedData = json.decode(response.body);
      final orders = decodedData.map((data) => Order.fromJson(data)).toList();

      // Store the fresh data in cache
      await _cacheManager.putFile(
        cacheKey,
        utf8.encode(response.body),
        fileExtension: 'json',
        maxAge: const Duration(hours: 1), // Cache for 1 hour
      );

      return orders;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Unauthorized access to orders');
    } else if (response.statusCode == 403) {
      throw ForbiddenException('Forbidden access to orders');
    } else if (response.statusCode == 404) {
      throw NotFoundException('Orders not found');
    } else {
      throw ApiException(
          'Failed to fetch orders: Status ${response.statusCode}');
    }
  }

  /// Helper method to get the authentication token
  Future<String> _getAuthToken() async {
    // In a real app, this would retrieve the token from secure storage
    // For now, we'll return a placeholder
    return 'mock_auth_token';
  }

  /// Creates a new order with inventory check and procurement if necessary
  Future<Order> createOrder(Order order) async {
    try {
      // Step 1: Enrich order with customer data if integration available
      Order enrichedOrder = order;
      if (_customerProfileService != null) {
        enrichedOrder =
            await _customerProfileService.enrichOrderWithCustomerData(order);
      }

      // Step 2: Check inventory availability if integration available
      if (_inventoryIntegration != null) {
        final inventoryAvailability = await _inventoryIntegration
            .checkInventoryAvailability(enrichedOrder);
        final allItemsAvailable = !inventoryAvailability.containsValue(false);

        if (allItemsAvailable) {
          // All items are available, reserve them and set status to ReadyForProduction
          await _inventoryIntegration.reserveInventory(enrichedOrder);
          enrichedOrder = enrichedOrder.copyWith(
            status: OrderStatus.readyForProduction,
            procurementStatus: ProcurementStatus.notRequired,
          );
        } else {
          // Some items need procurement
          final itemsNeedingProcurement = await _inventoryIntegration
              .getItemsNeedingProcurement(enrichedOrder);

          if (itemsNeedingProcurement.isNotEmpty &&
              _procurementService != null) {
            // Create procurement request
            await _procurementService.createProcurementRequest(enrichedOrder.id,
                itemsNeedingProcurement, enrichedOrder.location);

            // Update order status
            enrichedOrder = enrichedOrder.copyWith(
              status: OrderStatus.awaitingProcurement,
              procurementStatus: ProcurementStatus.pending,
            );

            // Notify procurement department
            if (_notificationService != null) {
              await _notificationService.notifyProcurement(enrichedOrder.id,
                  itemsNeedingProcurement, enrichedOrder.location);
            }

            // Create discussion room for this order
            if (_discussionService != null) {
              await _discussionService.createDiscussionRoom(
                  orderId: enrichedOrder.id,
                  initialMessage:
                      "Procurement needed for order ${enrichedOrder.id}",
                  participants: ['procurementDept', enrichedOrder.createdBy]);
            }
          }
        }
      }

      // Save the updated order via API call
      final savedOrder = enrichedOrder.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Check network connectivity
      final bool isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw NetworkException('No internet connection available');
      }

      // Make API call to save the order
      final Uri uri = Uri.parse('${ApiEndpoints.orders}');

      final response = await _httpClient
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode(savedOrder.toJson()),
      )
          .timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw RequestTimeoutException(
              'Request timed out while creating order');
        },
      );

      // Handle response
      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Order createdOrder = Order.fromJson(responseData);

        // Cache the newly created order
        final String cacheKey = 'order_detail_${createdOrder.id}';
        await _cacheManager.putFile(
          cacheKey,
          utf8.encode(response.body),
          fileExtension: 'json',
          maxAge: const Duration(days: 1),
        );

        return createdOrder;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized to create orders');
      } else if (response.statusCode == 403) {
        throw ForbiddenException('Forbidden to create orders');
      } else if (response.statusCode == 400) {
        throw ValidationException('Invalid order data: ${response.body}');
      } else {
        throw ApiException(
            'Failed to create order: Status ${response.statusCode}');
      }
    } catch (e) {
      if (e is NetworkException ||
          e is UnauthorizedException ||
          e is ForbiddenException ||
          e is ValidationException ||
          e is ApiException ||
          e is TimeoutException) {
        rethrow; // We've already formatted these exceptions
      } else if (e is http.ClientException) {
        throw NetworkException(
            'Network error while creating order: ${e.message}');
      } else if (e is FormatException) {
        throw DataParsingException('Error parsing order creation response');
      } else {
        throw ServiceException('Failed to create order: ${e.toString()}');
      }
    }
  }

  /// Updates an existing order
  Future<Order> updateOrder(Order order) async {
    try {
      // Check network connectivity
      final bool isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw NetworkException('No internet connection available');
      }

      // Handle status transition logic
      Order updatedOrder = order.copyWith(
        updatedAt: DateTime.now(),
      );

      // If transitioning to production, consume inventory
      if (order.status == OrderStatus.inProduction &&
          _inventoryIntegration != null) {
        await _inventoryIntegration.consumeInventoryForProduction(order);

        // Notify production department
        if (_productionService != null) {
          await _productionService.startProduction(order.id);
        }

        // Lock the discussion room if it exists
        if (_discussionService != null) {
          await _discussionService.lockDiscussionRoom(order.id);
        }
      }

      // If order is complete, update production status
      if (order.status == OrderStatus.completed) {
        updatedOrder =
            updatedOrder.copyWith(productionStatus: ProductionStatus.completed);
      }

      // Make API call to update the order
      final Uri uri = Uri.parse('${ApiEndpoints.orders}/${order.id}');

      final response = await _httpClient
          .put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode(updatedOrder.toJson()),
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw RequestTimeoutException(
              'Request timed out while updating order');
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Order serverUpdatedOrder = Order.fromJson(responseData);

        // Update the cache with the new order data
        final String cacheKey = 'order_detail_${serverUpdatedOrder.id}';
        await _cacheManager.putFile(
          cacheKey,
          utf8.encode(response.body),
          fileExtension: 'json',
          maxAge: const Duration(days: 1),
        );

        // Also invalidate any order list caches since the order has changed
        await _invalidateOrderListCaches();

        return serverUpdatedOrder;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized to update order');
      } else if (response.statusCode == 403) {
        throw ForbiddenException('Forbidden to update order');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Order not found');
      } else if (response.statusCode == 400) {
        throw ValidationException('Invalid order update: ${response.body}');
      } else if (response.statusCode == 409) {
        throw ConflictException('Order has been modified by another user');
      } else {
        throw ApiException(
            'Failed to update order: Status ${response.statusCode}');
      }
    } catch (e) {
      if (e is NetworkException ||
          e is UnauthorizedException ||
          e is ForbiddenException ||
          e is NotFoundException ||
          e is ValidationException ||
          e is ConflictException ||
          e is ApiException ||
          e is TimeoutException) {
        rethrow; // We've already formatted these exceptions
      } else if (e is http.ClientException) {
        throw NetworkException(
            'Network error while updating order: ${e.message}');
      } else if (e is FormatException) {
        throw DataParsingException('Error parsing order update response');
      } else {
        throw ServiceException('Failed to update order: ${e.toString()}');
      }
    }
  }

  /// Helper method to invalidate order list caches
  Future<void> _invalidateOrderListCaches() async {
    try {
      // Since DefaultCacheManager doesn't have a direct way to get all keys,
      // we'll use pattern-based cache key invalidation for specific patterns
      final orderListPatterns = [
        'orders_', // General order list cache
        'customer_recent_orders_', // Customer recent orders cache
      ];

      // For each pattern, try to remove any cached files with matching keys
      for (final pattern in orderListPatterns) {
        try {
          // This is a more targeted approach without needing to list all keys
          await _cacheManager.emptyCache();

          // For specific keys we know about, try to remove them directly
          // In a real implementation, you might want to track cache keys in a separate store
          // so you can directly invalidate them
        } catch (e) {
          print('Error removing cache for pattern $pattern: $e');
        }
      }
    } catch (e) {
      // Log cache error but continue - this is non-critical
      print('Cache invalidation error: $e');
    }
  }

  /// Cancels an order and releases inventory if needed
  Future<Order> cancelOrder(
      String orderId, String reason, String cancelledBy) async {
    try {
      // Check network connectivity
      final bool isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw NetworkException('No internet connection available');
      }

      // First, get the current order from the API or cache
      final Order order = await _getOrderById(orderId);

      // Release inventory if the order had reserved items
      if (order.status == OrderStatus.readyForProduction &&
          _inventoryIntegration != null) {
        await _inventoryIntegration.releaseInventory(order);
      }

      // Cancel any procurement requests if needed
      if (order.status == OrderStatus.awaitingProcurement &&
          _procurementService != null) {
        await _procurementService.cancelProcurementRequest(orderId, reason);
      }

      // Record cancellation details
      final cancelledOrder = order.copyWith(
        status: OrderStatus.cancelled,
        cancellationReason: reason,
        cancellationBy: cancelledBy,
        cancellationAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create a final message in the discussion room
      if (_discussionService != null) {
        await _discussionService.addSystemMessage(
            orderId: orderId, message: "Order cancelled. Reason: $reason");

        // Lock the discussion room
        await _discussionService.lockDiscussionRoom(orderId);
      }

      // Make API call to cancel the order
      final Uri uri = Uri.parse('${ApiEndpoints.orders}/$orderId/cancel');

      final response = await _httpClient
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode({
          'reason': reason,
          'cancelledBy': cancelledBy,
          'cancellationAt': DateTime.now().toIso8601String(),
        }),
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw RequestTimeoutException(
              'Request timed out while cancelling order');
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Order serverCancelledOrder = Order.fromJson(responseData);

        // Update the cache with the cancelled order
        final String cacheKey = 'order_detail_${serverCancelledOrder.id}';
        await _cacheManager.putFile(
          cacheKey,
          utf8.encode(response.body),
          fileExtension: 'json',
          maxAge: const Duration(days: 1),
        );

        // Also invalidate any order list caches
        await _invalidateOrderListCaches();

        return serverCancelledOrder;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized to cancel order');
      } else if (response.statusCode == 403) {
        throw ForbiddenException('Forbidden to cancel order');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Order not found');
      } else if (response.statusCode == 409) {
        throw ConflictException(
            'Order cannot be cancelled in its current state');
      } else {
        throw ApiException(
            'Failed to cancel order: Status ${response.statusCode}');
      }
    } catch (e) {
      if (e is NetworkException ||
          e is UnauthorizedException ||
          e is ForbiddenException ||
          e is NotFoundException ||
          e is ConflictException ||
          e is ApiException ||
          e is TimeoutException) {
        rethrow; // We've already formatted these exceptions
      } else if (e is http.ClientException) {
        throw NetworkException(
            'Network error while cancelling order: ${e.message}');
      } else if (e is FormatException) {
        throw DataParsingException('Error parsing order cancellation response');
      } else {
        throw ServiceException('Failed to cancel order: ${e.toString()}');
      }
    }
  }

  /// Helper method to get an order by ID (from API or cache)
  Future<Order> _getOrderById(String orderId) async {
    try {
      final String cacheKey = 'order_detail_$orderId';

      // Check for connectivity first
      final bool isConnected = await _networkInfo.isConnected;

      // Try to get data from cache first
      if (!isConnected || true) {
        // Always check cache first for performance
        try {
          final cacheFile = await _cacheManager.getFileFromCache(cacheKey);
          if (cacheFile != null) {
            final String cacheData = await cacheFile.file.readAsString();
            final Map<String, dynamic> decodedData = json.decode(cacheData);
            final Order order = Order.fromJson(decodedData);

            // If we're offline, return cached data
            if (!isConnected) {
              return order;
            }
          }
        } catch (e) {
          // Cache error, continue to API call
          print('Cache error: $e');
        }
      }

      // If no cached data or we need fresh data, fetch from API
      if (isConnected) {
        final Uri uri = Uri.parse('${ApiEndpoints.orders}/$orderId');

        final response = await _httpClient.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${await _getAuthToken()}',
          },
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw RequestTimeoutException('Request timed out');
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          final Order order = Order.fromJson(responseData);

          // Cache the order data
          await _cacheManager.putFile(
            cacheKey,
            utf8.encode(response.body),
            fileExtension: 'json',
            maxAge: const Duration(hours: 2),
          );

          return order;
        } else if (response.statusCode == 401) {
          throw UnauthorizedException('Unauthorized access to order');
        } else if (response.statusCode == 403) {
          throw ForbiddenException('Forbidden access to order');
        } else if (response.statusCode == 404) {
          throw NotFoundException('Order not found');
        } else {
          throw ApiException(
              'Failed to fetch order: Status ${response.statusCode}');
        }
      } else {
        throw NetworkException(
            'No internet connection and no cached data available');
      }
    } catch (e) {
      if (e is NetworkException ||
          e is UnauthorizedException ||
          e is ForbiddenException ||
          e is NotFoundException ||
          e is ApiException ||
          e is TimeoutException) {
        rethrow;
      } else if (e is http.ClientException) {
        throw NetworkException('Network error: ${e.message}');
      } else if (e is FormatException) {
        throw DataParsingException('Error parsing order data');
      } else {
        throw ServiceException('Failed to fetch order: ${e.toString()}');
      }
    }
  }

  /// Gets detailed customer profile information
  Future<Map<String, dynamic>> getCustomerProfile(String customerId) async {
    try {
      final String cacheKey = 'customer_profile_$customerId';

      // Check for connectivity first
      final bool isConnected = await _networkInfo.isConnected;

      // Try to get data from cache first
      if (!isConnected || true) {
        // Always check cache first for performance
        try {
          final cacheFile = await _cacheManager.getFileFromCache(cacheKey);
          if (cacheFile != null) {
            final String cacheData = await cacheFile.file.readAsString();
            final Map<String, dynamic> customerData = json.decode(cacheData);

            // If we're offline, return cached data
            if (!isConnected) {
              return customerData;
            }

            // If cache is recent (less than 30 minutes old), return it immediately
            final DateTime cacheTime =
                cacheFile.validTill.subtract(const Duration(hours: 2));
            if (DateTime.now().difference(cacheTime) <
                const Duration(minutes: 30)) {
              return customerData;
            }

            // Continue to API call to refresh cache but don't block the UI
            _fetchAndCacheCustomerProfile(customerId, cacheKey);
            return customerData;
          }
        } catch (e) {
          // Cache error, continue to API call
          print('Cache error when fetching customer profile: $e');
        }
      }

      // If no cached data or we need fresh data, fetch from API
      if (isConnected) {
        return await _fetchAndCacheCustomerProfile(customerId, cacheKey);
      } else {
        throw NetworkException(
            'No internet connection and no cached data available');
      }
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      } else if (e is http.ClientException) {
        throw NetworkException(
            'Network error while fetching customer profile: ${e.message}');
      } else if (e is FormatException) {
        throw DataParsingException('Error parsing customer profile data');
      } else {
        throw ServiceException(
            'Failed to fetch customer profile: ${e.toString()}');
      }
    }
  }

  /// Helper method to fetch and cache customer profile data
  Future<Map<String, dynamic>> _fetchAndCacheCustomerProfile(
      String customerId, String cacheKey) async {
    final Uri uri = Uri.parse('${ApiEndpoints.customers}/$customerId');

    final response = await _httpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _getAuthToken()}',
      },
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw RequestTimeoutException(
            'Request timed out while fetching customer profile');
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> customerData = json.decode(response.body);

      // Cache the customer data
      await _cacheManager.putFile(
        cacheKey,
        utf8.encode(response.body),
        fileExtension: 'json',
        maxAge: const Duration(hours: 2),
      );

      return customerData;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Unauthorized access to customer profile');
    } else if (response.statusCode == 403) {
      throw ForbiddenException('Forbidden access to customer profile');
    } else if (response.statusCode == 404) {
      throw NotFoundException('Customer profile not found');
    } else {
      throw ApiException(
          'Failed to fetch customer profile: Status ${response.statusCode}');
    }
  }

  /// Gets customer information to enhance order with
  Future<Map<String, dynamic>> getCustomerOrderPreferences(
      String customerId) async {
    try {
      final String cacheKey = 'customer_preferences_$customerId';

      // Check for connectivity first
      final bool isConnected = await _networkInfo.isConnected;

      // Try to get data from cache first
      if (!isConnected || true) {
        // Always check cache first for performance
        try {
          final cacheFile = await _cacheManager.getFileFromCache(cacheKey);
          if (cacheFile != null) {
            final String cacheData = await cacheFile.file.readAsString();
            final Map<String, dynamic> preferencesData = json.decode(cacheData);

            // If we're offline, return cached data
            if (!isConnected) {
              return preferencesData;
            }

            // If cache is recent (less than 1 hour old), return it immediately
            final DateTime cacheTime =
                cacheFile.validTill.subtract(const Duration(hours: 12));
            if (DateTime.now().difference(cacheTime) <
                const Duration(hours: 1)) {
              return preferencesData;
            }

            // Continue to API call to refresh cache but don't block the UI
            _fetchAndCacheCustomerPreferences(customerId, cacheKey);
            return preferencesData;
          }
        } catch (e) {
          // Cache error, continue to API call
          print('Cache error when fetching customer preferences: $e');
        }
      }

      // If no cached data or we need fresh data, fetch from API
      if (isConnected) {
        return await _fetchAndCacheCustomerPreferences(customerId, cacheKey);
      } else {
        throw NetworkException(
            'No internet connection and no cached data available');
      }
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      } else if (e is http.ClientException) {
        throw NetworkException(
            'Network error while fetching customer preferences: ${e.message}');
      } else if (e is FormatException) {
        throw DataParsingException('Error parsing customer preferences data');
      } else {
        throw ServiceException(
            'Failed to fetch customer preferences: ${e.toString()}');
      }
    }
  }

  /// Helper method to fetch and cache customer preferences data
  Future<Map<String, dynamic>> _fetchAndCacheCustomerPreferences(
      String customerId, String cacheKey) async {
    final Uri uri =
        Uri.parse('${ApiEndpoints.customers}/$customerId/preferences');

    final response = await _httpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _getAuthToken()}',
      },
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw RequestTimeoutException(
            'Request timed out while fetching customer preferences');
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> preferencesData = json.decode(response.body);

      // Cache the preferences data
      await _cacheManager.putFile(
        cacheKey,
        utf8.encode(response.body),
        fileExtension: 'json',
        maxAge: const Duration(
            hours: 12), // Customer preferences don't change often
      );

      return preferencesData;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException(
          'Unauthorized access to customer preferences');
    } else if (response.statusCode == 403) {
      throw ForbiddenException('Forbidden access to customer preferences');
    } else if (response.statusCode == 404) {
      throw NotFoundException('Customer preferences not found');
    } else {
      throw ApiException(
          'Failed to fetch customer preferences: Status ${response.statusCode}');
    }
  }

  /// Handle procurement completion for an order
  Future<Order> handleProcurementComplete(String orderId) async {
    try {
      // Check network connectivity
      final bool isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw NetworkException('No internet connection available');
      }

      // First, get the current order from API or cache
      final Order order = await _getOrderById(orderId);

      // Validate the current order status
      if (order.status != OrderStatus.awaitingProcurement ||
          order.procurementStatus != ProcurementStatus.pending) {
        throw ValidationException('Order is not awaiting procurement');
      }

      // Update order status
      final updatedOrder = order.copyWith(
        status: OrderStatus.readyForProduction,
        procurementStatus: ProcurementStatus.fulfilled,
        updatedAt: DateTime.now(),
      );

      // Make API call to complete procurement
      final Uri uri =
          Uri.parse('${ApiEndpoints.orders}/$orderId/procurement-complete');

      final response = await _httpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw RequestTimeoutException(
              'Request timed out while completing procurement');
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Order serverUpdatedOrder = Order.fromJson(responseData);

        // Update the cache with the new order data
        final String cacheKey = 'order_detail_${serverUpdatedOrder.id}';
        await _cacheManager.putFile(
          cacheKey,
          utf8.encode(response.body),
          fileExtension: 'json',
          maxAge: const Duration(days: 1),
        );

        // Invalidate order list caches
        await _invalidateOrderListCaches();

        // Notify production team
        if (_notificationService != null) {
          await _notificationService.notifyProduction(orderId,
              "Order is ready for production after procurement completion.");
        }

        // Add a message to the discussion room
        if (_discussionService != null) {
          await _discussionService.addSystemMessage(
              orderId: orderId,
              message: "Procurement completed. Order is ready for production.");
        }

        return serverUpdatedOrder;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized to complete procurement');
      } else if (response.statusCode == 403) {
        throw ForbiddenException('Forbidden to complete procurement');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Order not found');
      } else if (response.statusCode == 409) {
        throw ConflictException(
            'Order is not in a valid state for procurement completion');
      } else {
        throw ApiException(
            'Failed to complete procurement: Status ${response.statusCode}');
      }
    } catch (e) {
      if (e is NetworkException ||
          e is UnauthorizedException ||
          e is ForbiddenException ||
          e is NotFoundException ||
          e is ValidationException ||
          e is ConflictException ||
          e is ApiException ||
          e is TimeoutException) {
        rethrow; // We've already formatted these exceptions
      } else if (e is http.ClientException) {
        throw NetworkException(
            'Network error while completing procurement: ${e.message}');
      } else if (e is FormatException) {
        throw DataParsingException(
            'Error parsing procurement completion response');
      } else {
        throw ServiceException(
            'Failed to complete procurement: ${e.toString()}');
      }
    }
  }

  /// Gets recent orders for a specific customer
  Future<List<Map<String, dynamic>>> getCustomerRecentOrders(String customerId,
      {int limit = 5}) async {
    try {
      final String cacheKey = 'customer_recent_orders_${customerId}_$limit';

      // Check for connectivity first
      final bool isConnected = await _networkInfo.isConnected;

      // Try to get data from cache first
      if (!isConnected || true) {
        // Always check cache first for performance
        try {
          final cacheFile = await _cacheManager.getFileFromCache(cacheKey);
          if (cacheFile != null) {
            final String cacheData = await cacheFile.file.readAsString();
            final List<dynamic> ordersData = json.decode(cacheData);

            // If we're offline, return cached data
            if (!isConnected) {
              return List<Map<String, dynamic>>.from(ordersData);
            }

            // If cache is recent (less than 15 minutes old), return it immediately
            final DateTime cacheTime =
                cacheFile.validTill.subtract(const Duration(minutes: 30));
            if (DateTime.now().difference(cacheTime) <
                const Duration(minutes: 15)) {
              return List<Map<String, dynamic>>.from(ordersData);
            }

            // Continue to API call to refresh cache but don't block the UI
            _fetchAndCacheCustomerRecentOrders(customerId, limit, cacheKey);
            return List<Map<String, dynamic>>.from(ordersData);
          }
        } catch (e) {
          // Cache error, continue to API call
          print('Cache error when fetching recent orders: $e');
        }
      }

      // If no cached data or we need fresh data, fetch from API
      if (isConnected) {
        return await _fetchAndCacheCustomerRecentOrders(
            customerId, limit, cacheKey);
      } else {
        throw NetworkException(
            'No internet connection and no cached data available');
      }
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      } else if (e is http.ClientException) {
        throw NetworkException(
            'Network error while fetching recent orders: ${e.message}');
      } else if (e is FormatException) {
        throw DataParsingException('Error parsing recent orders data');
      } else {
        throw ServiceException(
            'Failed to fetch recent orders: ${e.toString()}');
      }
    }
  }

  /// Helper method to fetch and cache customer recent orders
  Future<List<Map<String, dynamic>>> _fetchAndCacheCustomerRecentOrders(
      String customerId, int limit, String cacheKey) async {
    final Map<String, String> queryParams = {'limit': limit.toString()};
    final Uri uri = Uri.parse('${ApiEndpoints.customers}/$customerId/orders')
        .replace(queryParameters: queryParams);

    final response = await _httpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _getAuthToken()}',
      },
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw RequestTimeoutException(
            'Request timed out while fetching recent orders');
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> ordersData = json.decode(response.body);

      // Cache the recent orders data
      await _cacheManager.putFile(
        cacheKey,
        utf8.encode(response.body),
        fileExtension: 'json',
        maxAge:
            const Duration(minutes: 30), // Recent orders may change frequently
      );

      return List<Map<String, dynamic>>.from(ordersData);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Unauthorized access to customer orders');
    } else if (response.statusCode == 403) {
      throw ForbiddenException('Forbidden access to customer orders');
    } else if (response.statusCode == 404) {
      throw NotFoundException('Customer not found');
    } else {
      throw ApiException(
          'Failed to fetch recent orders: Status ${response.statusCode}');
    }
  }

  /// Gets product recommendations for a specific customer
  Future<List<Map<String, dynamic>>> getProductRecommendations(
      String customerId) async {
    try {
      final String cacheKey = 'product_recommendations_$customerId';

      // Check for connectivity first
      final bool isConnected = await _networkInfo.isConnected;

      // Try to get data from cache first
      if (!isConnected || true) {
        // Always check cache first for performance
        try {
          final cacheFile = await _cacheManager.getFileFromCache(cacheKey);
          if (cacheFile != null) {
            final String cacheData = await cacheFile.file.readAsString();
            final List<dynamic> recommendationsData = json.decode(cacheData);

            // If we're offline, return cached data
            if (!isConnected) {
              return List<Map<String, dynamic>>.from(recommendationsData);
            }

            // If cache is less than 3 hours old, return it immediately
            // Product recommendations should update a few times per day
            final DateTime cacheTime =
                cacheFile.validTill.subtract(const Duration(hours: 6));
            if (DateTime.now().difference(cacheTime) <
                const Duration(hours: 3)) {
              return List<Map<String, dynamic>>.from(recommendationsData);
            }

            // Continue to API call to refresh cache but don't block the UI
            _fetchAndCacheProductRecommendations(customerId, cacheKey);
            return List<Map<String, dynamic>>.from(recommendationsData);
          }
        } catch (e) {
          // Cache error, continue to API call
          print('Cache error when fetching product recommendations: $e');
        }
      }

      // If no cached data or we need fresh data, fetch from API
      if (isConnected) {
        return await _fetchAndCacheProductRecommendations(customerId, cacheKey);
      } else {
        throw NetworkException(
            'No internet connection and no cached data available');
      }
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      } else if (e is http.ClientException) {
        throw NetworkException(
            'Network error while fetching product recommendations: ${e.message}');
      } else if (e is FormatException) {
        throw DataParsingException(
            'Error parsing product recommendations data');
      } else {
        throw ServiceException(
            'Failed to fetch product recommendations: ${e.toString()}');
      }
    }
  }

  /// Helper method to fetch and cache product recommendations
  Future<List<Map<String, dynamic>>> _fetchAndCacheProductRecommendations(
      String customerId, String cacheKey) async {
    final Uri uri =
        Uri.parse('${ApiEndpoints.customers}/$customerId/recommendations');

    final response = await _httpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _getAuthToken()}',
      },
    ).timeout(
      const Duration(
          seconds: 15), // Allow more time for AI recommendation engine
      onTimeout: () {
        throw RequestTimeoutException(
            'Request timed out while fetching product recommendations');
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> recommendationsData = json.decode(response.body);

      // Cache the recommendations data
      await _cacheManager.putFile(
        cacheKey,
        utf8.encode(response.body),
        fileExtension: 'json',
        maxAge: const Duration(hours: 6), // Cache for 6 hours
      );

      return List<Map<String, dynamic>>.from(recommendationsData);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException(
          'Unauthorized access to product recommendations');
    } else if (response.statusCode == 403) {
      throw ForbiddenException('Forbidden access to product recommendations');
    } else if (response.statusCode == 404) {
      throw NotFoundException('Product recommendations not found for customer');
    } else {
      throw ApiException(
          'Failed to fetch product recommendations: Status ${response.statusCode}');
    }
  }
}

// Updated provider for OrderService with all integrations connected
final orderServiceWithIntegrationsProvider = Provider<OrderService>((ref) {
  final inventoryIntegration = ref.watch(orderInventoryIntegrationProvider);
  final customerProfileService = ref.watch(customerProfileServiceProvider);
  final procurementService = ref.watch(procurementServiceProvider);
  final productionService = ref.watch(productionServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final discussionService = ref.watch(orderDiscussionServiceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  final httpClient = ref.watch(httpClientProvider);
  final cacheManager = ref.watch(cacheManagerProvider);

  return OrderService(
    inventoryIntegration: inventoryIntegration,
    customerProfileService: customerProfileService,
    procurementService: procurementService,
    productionService: productionService,
    notificationService: notificationService,
    discussionService: discussionService,
    httpClient: httpClient,
    cacheManager: cacheManager,
    networkInfo: networkInfo,
  );
});
