import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../shared/config/api_config.dart';
import '../models/crm_reminder.dart';
import '../models/customer.dart';
import '../models/interaction_log.dart';

/// Repository interface for CRM data access
abstract class CrmRepository {
  /// Gets all customers
  Future<List<Customer>> getCustomers();

  /// Gets a customer by ID
  Future<Customer> getCustomer(String id);

  /// Creates a new customer
  Future<Customer> createCustomer(Customer customer);

  /// Updates an existing customer
  Future<Customer> updateCustomer(Customer customer);

  /// Deletes a customer
  Future<void> deleteCustomer(String id);

  /// Gets interactions for a customer
  Future<List<InteractionLog>> getCustomerInteractions(String customerId);

  /// Logs a new interaction
  Future<InteractionLog> logInteraction(InteractionLog interaction);

  /// Gets reminders for a customer
  Future<List<CrmReminder>> getCustomerReminders(String customerId);

  /// Creates a new reminder
  Future<CrmReminder> createReminder(CrmReminder reminder);

  /// Updates a reminder
  Future<CrmReminder> updateReminder(CrmReminder reminder);

  /// Deletes a reminder
  Future<void> deleteReminder(String id);

  /// Gets customers by tag
  Future<List<Customer>> getCustomersByTag(String tag);

  /// Searches for customers
  Future<List<Customer>> searchCustomers(String query);
}

/// Implementation of the CrmRepository interface
class CrmRepositoryImpl implements CrmRepository {

  CrmRepositoryImpl({
    http.Client? httpClient,
    ApiConfig? apiConfig,
  })  : _httpClient = httpClient ?? http.Client(),
        _apiConfig = apiConfig ?? ApiConfig();
  final http.Client _httpClient;
  final ApiConfig _apiConfig;

  @override
  Future<List<Customer>> getCustomers() async {
    final response = await _httpClient.get(
      Uri.parse('${_apiConfig.crmApiUrl}/customers'),
      headers: {
        'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Customer.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load customers: ${response.statusCode}');
    }
  }

  @override
  Future<Customer> getCustomer(String id) async {
    final response = await _httpClient.get(
      Uri.parse('${_apiConfig.crmApiUrl}/customers/$id'),
      headers: {
        'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Customer.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Customer not found: $id');
    } else {
      throw Exception('Failed to load customer: ${response.statusCode}');
    }
  }

  @override
  Future<Customer> createCustomer(Customer customer) async {
    final response = await _httpClient.post(
      Uri.parse('${_apiConfig.crmApiUrl}/customers'),
      headers: {
        'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(customer.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Customer.fromJson(data);
    } else {
      throw Exception('Failed to create customer: ${response.statusCode}');
    }
  }

  @override
  Future<Customer> updateCustomer(Customer customer) async {
    final response = await _httpClient.put(
      Uri.parse('${_apiConfig.crmApiUrl}/customers/${customer.id}'),
      headers: {
        'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(customer.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Customer.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Customer not found: ${customer.id}');
    } else {
      throw Exception('Failed to update customer: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    final response = await _httpClient.delete(
      Uri.parse('${_apiConfig.crmApiUrl}/customers/$id'),
      headers: {
        'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete customer: ${response.statusCode}');
    }
  }

  @override
  Future<List<InteractionLog>> getCustomerInteractions(
      String customerId) async {
    final response = await _httpClient.get(
      Uri.parse('${_apiConfig.crmApiUrl}/customers/$customerId/interactions'),
      headers: {
        'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => InteractionLog.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      throw Exception('Customer not found: $customerId');
    } else {
      throw Exception('Failed to load interactions: ${response.statusCode}');
    }
  }

  @override
  Future<InteractionLog> logInteraction(InteractionLog interaction) async {
    final response = await _httpClient.post(
      Uri.parse('${_apiConfig.crmApiUrl}/interactions'),
      headers: {
        'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(interaction.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return InteractionLog.fromJson(data);
    } else {
      throw Exception('Failed to log interaction: ${response.statusCode}');
    }
  }

  @override
  Future<List<CrmReminder>> getCustomerReminders(String customerId) async {
    final response = await _httpClient.get(
      Uri.parse('${_apiConfig.crmApiUrl}/customers/$customerId/reminders'),
      headers: {
        'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CrmReminder.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      throw Exception('Customer not found: $customerId');
    } else {
      throw Exception('Failed to load reminders: ${response.statusCode}');
    }
  }

  @override
  Future<CrmReminder> createReminder(CrmReminder reminder) async {
    final response = await _httpClient.post(
      Uri.parse('${_apiConfig.crmApiUrl}/reminders'),
      headers: {
        'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(reminder.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return CrmReminder.fromJson(data);
    } else {
      throw Exception('Failed to create reminder: ${response.statusCode}');
    }
  }

  @override
  Future<CrmReminder> updateReminder(CrmReminder reminder) async {
    final response = await _httpClient.put(
      Uri.parse('${_apiConfig.crmApiUrl}/reminders/${reminder.id}'),
      headers: {
        'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(reminder.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return CrmReminder.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Reminder not found: ${reminder.id}');
    } else {
      throw Exception('Failed to update reminder: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteReminder(String id) async {
    final response = await _httpClient.delete(
      Uri.parse('${_apiConfig.crmApiUrl}/reminders/$id'),
      headers: {
        'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete reminder: ${response.statusCode}');
    }
  }

  @override
  Future<List<Customer>> getCustomersByTag(String tag) async {
    final response = await _httpClient.get(
      Uri.parse('${_apiConfig.crmApiUrl}/customers?tag=$tag'),
      headers: {
        'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Customer.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load customers by tag: ${response.statusCode}');
    }
  }

  @override
  Future<List<Customer>> searchCustomers(String query) async {
    final response = await _httpClient.get(
      Uri.parse('${_apiConfig.crmApiUrl}/customers/search?q=$query'),
      headers: {
        'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Customer.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search customers: ${response.statusCode}');
    }
  }

  /// Dispose method to clean up resources
  void dispose() {
    _httpClient.close();
  }
}

// Provider for the CrmRepository
final crmRepositoryProvider = Provider<CrmRepository>((ref) {
  return CrmRepositoryImpl();
});
