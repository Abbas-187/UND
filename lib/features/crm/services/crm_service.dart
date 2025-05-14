import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../../../core/errors/exceptions.dart';
import '../../../shared/config/api_config.dart';
import '../models/crm_reminder.dart';
import '../models/crm_report.dart';
import '../models/customer.dart';
import '../models/interaction_log.dart';

/// Service for handling customer relationship management operations
class CrmService {

  CrmService({
    http.Client? httpClient,
    ApiConfig? apiConfig,
  })  : _httpClient = httpClient ?? http.Client(),
        _apiConfig = apiConfig ?? ApiConfig();
  static final Logger _logger = Logger('CrmService');

  final http.Client _httpClient;
  final ApiConfig _apiConfig;

  /// Fetches all customers
  Future<List<Customer>> getCustomers() async {
    _logger.info('Fetching all customers');
    final endpoint = '${_apiConfig.crmApiUrl}/customers';

    try {
      final response = await _httpClient.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final customers = data.map((json) => Customer.fromJson(json)).toList();
        _logger.fine('Successfully fetched ${customers.length} customers');
        return customers;
      } else {
        throw ApiException(
          'Failed to fetch customers. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.severe('Error fetching customers: $e');
      if (e is ApiException) rethrow;
      throw ServiceException('Failed to fetch customers: ${e.toString()}');
    }
  }

  /// Fetches a customer by ID
  Future<Customer> getCustomer(String customerId) async {
    _logger.info('Fetching customer with ID: $customerId');
    final endpoint = '${_apiConfig.crmApiUrl}/customers/$customerId';

    try {
      final response = await _httpClient.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final customer = Customer.fromJson(data);
        _logger.fine('Successfully fetched customer: ${customer.name}');
        return customer;
      } else if (response.statusCode == 404) {
        throw NotFoundException('Customer not found with ID: $customerId');
      } else {
        throw ApiException(
          'Failed to fetch customer. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.severe('Error fetching customer: $e');
      if (e is ApiException || e is NotFoundException) rethrow;
      throw ServiceException('Failed to fetch customer: ${e.toString()}');
    }
  }

  /// Creates a new customer
  Future<Customer> createCustomer(Customer customer) async {
    _logger.info('Creating new customer: ${customer.name}');
    final endpoint = '${_apiConfig.crmApiUrl}/customers';

    try {
      final response = await _httpClient.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(customer.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final createdCustomer = Customer.fromJson(data);
        _logger.fine('Successfully created customer: ${createdCustomer.name}');
        return createdCustomer;
      } else if (response.statusCode == 400) {
        throw ValidationException('Invalid customer data: ${response.body}');
      } else {
        throw ApiException(
          'Failed to create customer. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.severe('Error creating customer: $e');
      if (e is ApiException || e is ValidationException) rethrow;
      throw ServiceException('Failed to create customer: ${e.toString()}');
    }
  }

  /// Updates an existing customer
  Future<Customer> updateCustomer(Customer customer) async {
    _logger.info('Updating customer: ${customer.id}');
    final endpoint = '${_apiConfig.crmApiUrl}/customers/${customer.id}';

    try {
      final response = await _httpClient.put(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(customer.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final updatedCustomer = Customer.fromJson(data);
        _logger.fine('Successfully updated customer: ${updatedCustomer.name}');
        return updatedCustomer;
      } else if (response.statusCode == 404) {
        throw NotFoundException('Customer not found with ID: ${customer.id}');
      } else if (response.statusCode == 400) {
        throw ValidationException('Invalid customer data: ${response.body}');
      } else {
        throw ApiException(
          'Failed to update customer. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.severe('Error updating customer: $e');
      if (e is ApiException ||
          e is ValidationException ||
          e is NotFoundException) {
        rethrow;
      }
      throw ServiceException('Failed to update customer: ${e.toString()}');
    }
  }

  /// Deletes a customer
  Future<void> deleteCustomer(String customerId) async {
    _logger.info('Deleting customer with ID: $customerId');
    final endpoint = '${_apiConfig.crmApiUrl}/customers/$customerId';

    try {
      final response = await _httpClient.delete(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        _logger.fine('Successfully deleted customer: $customerId');
        return;
      } else if (response.statusCode == 404) {
        throw NotFoundException('Customer not found with ID: $customerId');
      } else {
        throw ApiException(
          'Failed to delete customer. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.severe('Error deleting customer: $e');
      if (e is ApiException || e is NotFoundException) rethrow;
      throw ServiceException('Failed to delete customer: ${e.toString()}');
    }
  }

  /// Logs an interaction with a customer
  Future<InteractionLog> logInteraction(InteractionLog interaction) async {
    _logger.info('Logging interaction for customer: ${interaction.customerId}');
    final endpoint = '${_apiConfig.crmApiUrl}/interactions';

    try {
      final response = await _httpClient.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(interaction.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final createdInteraction = InteractionLog.fromJson(data);
        _logger
            .fine('Successfully logged interaction: ${createdInteraction.id}');
        return createdInteraction;
      } else if (response.statusCode == 400) {
        throw ValidationException('Invalid interaction data: ${response.body}');
      } else {
        throw ApiException(
          'Failed to log interaction. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.severe('Error logging interaction: $e');
      if (e is ApiException || e is ValidationException) rethrow;
      throw ServiceException('Failed to log interaction: ${e.toString()}');
    }
  }

  /// Gets all interactions for a customer
  Future<List<InteractionLog>> getCustomerInteractions(
      String customerId) async {
    _logger.info('Fetching interactions for customer: $customerId');
    final endpoint =
        '${_apiConfig.crmApiUrl}/customers/$customerId/interactions';

    try {
      final response = await _httpClient.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final interactions =
            data.map((json) => InteractionLog.fromJson(json)).toList();
        _logger.fine(
            'Successfully fetched ${interactions.length} interactions for customer: $customerId');
        return interactions;
      } else if (response.statusCode == 404) {
        throw NotFoundException('Customer not found with ID: $customerId');
      } else {
        throw ApiException(
          'Failed to fetch customer interactions. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.severe('Error fetching customer interactions: $e');
      if (e is ApiException || e is NotFoundException) rethrow;
      throw ServiceException(
          'Failed to fetch customer interactions: ${e.toString()}');
    }
  }

  /// Generates a CRM report with various metrics
  Future<CrmReport> generateReport() async {
    _logger.info('Generating CRM report');
    final endpoint = '${_apiConfig.crmApiUrl}/reports/summary';

    try {
      final response = await _httpClient.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final report = CrmReport.fromJson(data);
        _logger.fine('Successfully generated CRM report');
        return report;
      } else {
        throw ApiException(
          'Failed to generate report. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.severe('Error generating CRM report: $e');
      if (e is ApiException) rethrow;
      throw ServiceException('Failed to generate CRM report: ${e.toString()}');
    }
  }

  /// Sets a reminder for a customer
  Future<CrmReminder> setReminder(CrmReminder reminder) async {
    _logger.info('Setting reminder for customer: ${reminder.customerId}');
    final endpoint = '${_apiConfig.crmApiUrl}/reminders';

    try {
      final response = await _httpClient.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(reminder.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final createdReminder = CrmReminder.fromJson(data);
        _logger.fine('Successfully set reminder: ${createdReminder.id}');
        return createdReminder;
      } else if (response.statusCode == 400) {
        throw ValidationException('Invalid reminder data: ${response.body}');
      } else {
        throw ApiException(
          'Failed to set reminder. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.severe('Error setting reminder: $e');
      if (e is ApiException || e is ValidationException) rethrow;
      throw ServiceException('Failed to set reminder: ${e.toString()}');
    }
  }

  /// Gets all reminders for a customer
  Future<List<CrmReminder>> getCustomerReminders(String customerId) async {
    _logger.info('Fetching reminders for customer: $customerId');
    final endpoint = '${_apiConfig.crmApiUrl}/customers/$customerId/reminders';

    try {
      final response = await _httpClient.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer ${_apiConfig.crmApiKey}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final reminders =
            data.map((json) => CrmReminder.fromJson(json)).toList();
        _logger.fine(
            'Successfully fetched ${reminders.length} reminders for customer: $customerId');
        return reminders;
      } else if (response.statusCode == 404) {
        throw NotFoundException('Customer not found with ID: $customerId');
      } else {
        throw ApiException(
          'Failed to fetch customer reminders. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.severe('Error fetching customer reminders: $e');
      if (e is ApiException || e is NotFoundException) rethrow;
      throw ServiceException(
          'Failed to fetch customer reminders: ${e.toString()}');
    }
  }

  /// Dispose method to clean up resources
  void dispose() {
    _httpClient.close();
  }
}

// Provider for the CrmService
final crmServiceProvider = Provider<CrmService>((ref) {
  return CrmService();
});
