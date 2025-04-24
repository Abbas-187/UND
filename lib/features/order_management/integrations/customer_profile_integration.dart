import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../services/order_service.dart';
import '../../../shared/config/api_config.dart';

/// Service for integrating with customer profile systems and CRM
/// Used to enhance orders with customer information
class CustomerProfileIntegrationService {
  final OrderService _orderService;
  final http.Client _httpClient;
  final ApiConfig _apiConfig;

  CustomerProfileIntegrationService({
    required OrderService orderService,
    http.Client? httpClient,
    ApiConfig? apiConfig,
  })  : _orderService = orderService,
        _httpClient = httpClient ?? http.Client(),
        _apiConfig = apiConfig ?? ApiConfig();

  /// Fetches customer profile data from the CRM system
  Future<Map<String, dynamic>?> getCustomerProfile(String customerId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${_apiConfig.crmApiUrl}/customers/$customerId'),
        headers: {
          'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to fetch customer profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching customer profile: $e');
      return null;
    }
  }

  /// Enriches an order with customer profile data from the CRM
  Future<Order> enrichOrderWithCustomerData(Order order) async {
    final customerProfile = await getCustomerProfile(order.customer);

    if (customerProfile == null) {
      return order;
    }

    // Extract relevant customer data from profile
    final preferences = customerProfile['preferences'] as Map<String, dynamic>?;
    final allergies = customerProfile['allergies'] as List<dynamic>?;
    final tier = customerProfile['tier'] as String?;
    final notes = customerProfile['notes'] as String?;

    // Create an updated order with customer information
    return order.copyWith(
      customerPreferences: preferences,
      customerAllergies: allergies?.cast<String>(),
      customerTier: tier,
      customerNotes: notes,
    );
  }

  /// Alias for enrichOrderWithCustomerData to maintain backward compatibility with tests
  Future<Order> enhanceOrderWithCustomerContext(Order order) async {
    return enrichOrderWithCustomerData(order);
  }

  /// Updates customer preferences in the CRM based on an order
  Future<bool> updateCustomerPreferences(
      String customerId, Map<String, dynamic> preferences) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('${_apiConfig.crmApiUrl}/customers/$customerId/preferences'),
        headers: {
          'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(preferences),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating customer preferences: $e');
      return false;
    }
  }

  /// Syncs order history for a customer to the CRM
  Future<bool> syncOrderHistoryToCrm(
      String customerId, List<Order> orders) async {
    try {
      // Format orders for CRM
      final orderData = orders
          .map((order) => {
                'id': order.id,
                'date': order.createdAt.toIso8601String(),
                'status': order.status.name,
                'items': order.items
                    .map((item) => {
                          'name': item.name,
                          'quantity': item.quantity,
                        })
                    .toList(),
                'total': order.totalAmount,
              })
          .toList();

      final response = await _httpClient.post(
        Uri.parse(
            '${_apiConfig.crmApiUrl}/customers/$customerId/order-history'),
        headers: {
          'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'orders': orderData}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error syncing order history: $e');
      return false;
    }
  }

  /// Gets a list of recent orders for a customer
  Future<List<Order>> getCustomerOrderHistory(String customerId) async {
    try {
      // First fetch from local database
      final orders = await _orderService.fetchOrders(
        userId: customerId,
      );

      // Then enrich with any additional CRM data if needed
      List<Order> enrichedOrders = [];
      for (var order in orders) {
        final enriched = await enrichOrderWithCustomerData(order);
        enrichedOrders.add(enriched);
      }

      return enrichedOrders;
    } catch (e) {
      print('Error fetching customer order history: $e');
      return [];
    }
  }

  /// Dispose method to clean up resources
  void dispose() {
    _httpClient.close();
  }
}
