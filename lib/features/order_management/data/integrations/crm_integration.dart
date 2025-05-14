import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../shared/constants/api_endpoints.dart';
import '../../domain/entities/order_discussion_entity.dart';
import '../../domain/entities/order_entity.dart';

/// Service to integrate order management with CRM for discussions and customer data
class CrmIntegrationService {

  CrmIntegrationService({http.Client? client})
      : _client = client ?? http.Client();
  final http.Client _client;

  Future<Map<String, dynamic>> getCustomerProfile(String customerId) async {
    final uri = Uri.parse('${ApiEndpoints.customers}/$customerId');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch customer profile: \\$response.statusCode');
  }

  Future<String> createInteractionFromDiscussion(
      OrderDiscussionEntity discussion, OrderEntity order) async {
    final uri = Uri.parse(
        '${ApiEndpoints.customers}/${order.customerName}/interactions');
    final payload = {
      'orderId': order.id,
      'discussionId': discussion.id,
      'messages': discussion.messages
          .map((m) => {
                'senderId': m.senderId,
                'content': m.content,
                'timestamp': m.timestamp.toIso8601String(),
              })
          .toList(),
    };
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data['id'] as String;
    }
    throw Exception('Failed to create CRM interaction: \\$response.statusCode');
  }
}

/// Riverpod provider for CrmIntegrationService
final crmIntegrationServiceProvider =
    Provider<CrmIntegrationService>((ref) => CrmIntegrationService());
