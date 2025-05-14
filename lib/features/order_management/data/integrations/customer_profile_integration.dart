import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../shared/constants/api_endpoints.dart';
import '../../domain/entities/order_entity.dart';

/// Service for integrating with customer profile systems to enrich orders
class CustomerProfileIntegrationService {

  CustomerProfileIntegrationService({http.Client? client})
      : _client = client ?? http.Client();
  final http.Client _client;

  /// Fetches customer profile data from CRM
  Future<Map<String, dynamic>?> getCustomerProfile(String customerId) async {
    final uri = Uri.parse('${ApiEndpoints.customers}/$customerId');
    final response = await _client.get(uri, headers: {
      'Content-Type': 'application/json',
    });
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  /// Enriches an order entity with customer-specific data
  Future<OrderEntity> enrichOrderWithCustomerData(OrderEntity order) async {
    final profile = await getCustomerProfile(order.customerName);
    if (profile == null) return order;
    // TODO: map profile fields to OrderEntity if needed
    return order;
  }
}

/// Riverpod provider for CustomerProfileIntegrationService
final customerProfileIntegrationServiceProvider =
    Provider<CustomerProfileIntegrationService>(
        (ref) => CustomerProfileIntegrationService());
