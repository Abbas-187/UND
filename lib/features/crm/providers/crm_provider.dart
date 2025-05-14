import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crm_reminder.dart';
import '../models/crm_report.dart';
import '../models/customer.dart';
import '../models/interaction_log.dart';
import '../services/crm_service.dart';

/// Provider for managing customers
class CustomerNotifier extends StateNotifier<AsyncValue<List<Customer>>> {

  CustomerNotifier(this._crmService) : super(const AsyncValue.loading()) {
    loadCustomers();
  }
  final CrmService _crmService;

  /// Loads all customers
  Future<void> loadCustomers() async {
    try {
      state = const AsyncValue.loading();
      final customers = await _crmService.getCustomers();
      state = AsyncValue.data(customers);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Gets a customer by ID
  Future<Customer?> getCustomerById(String customerId) async {
    try {
      // First check if the customer is already in the state
      Customer? customer;
      state.whenData((customers) {
        customer = customers.firstWhere(
          (c) => c.id == customerId,
          orElse: () => null as Customer, // This will be null if not found
        );
      });

      // If found in state, return it
      if (customer != null) return customer;

      // If not in state, fetch it directly
      return await _crmService.getCustomer(customerId);
    } catch (e) {
      debugPrint('Error getting customer by ID: $e');
      return null;
    }
  }

  /// Creates a new customer
  Future<Customer> createCustomer(Customer customer) async {
    try {
      final createdCustomer = await _crmService.createCustomer(customer);

      // Update the state with the new customer
      state.whenData((customers) {
        state = AsyncValue.data([...customers, createdCustomer]);
      });

      return createdCustomer;
    } catch (e) {
      rethrow;
    }
  }

  /// Updates an existing customer
  Future<Customer> updateCustomer(Customer customer) async {
    try {
      final updatedCustomer = await _crmService.updateCustomer(customer);

      // Update the state with the updated customer
      state.whenData((customers) {
        final index = customers.indexWhere((c) => c.id == updatedCustomer.id);
        if (index >= 0) {
          final updatedCustomers = [...customers];
          updatedCustomers[index] = updatedCustomer;
          state = AsyncValue.data(updatedCustomers);
        }
      });

      return updatedCustomer;
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes a customer
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _crmService.deleteCustomer(customerId);

      // Update the state by removing the deleted customer
      state.whenData((customers) {
        final updatedCustomers =
            customers.where((c) => c.id != customerId).toList();
        state = AsyncValue.data(updatedCustomers);
      });
    } catch (e) {
      rethrow;
    }
  }
}

/// Provider for managing customer interactions
class InteractionNotifier
    extends StateNotifier<AsyncValue<List<InteractionLog>>> {

  InteractionNotifier(this._crmService) : super(const AsyncValue.loading());
  final CrmService _crmService;
  String? _currentCustomerId;

  /// Loads interactions for a specific customer
  Future<void> loadInteractionsForCustomer(String customerId) async {
    try {
      state = const AsyncValue.loading();
      _currentCustomerId = customerId;

      final interactions =
          await _crmService.getCustomerInteractions(customerId);
      state = AsyncValue.data(interactions);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Logs a new interaction
  Future<InteractionLog> logInteraction(InteractionLog interaction) async {
    try {
      final createdInteraction = await _crmService.logInteraction(interaction);

      // Update the state with the new interaction
      state.whenData((interactions) {
        state = AsyncValue.data([...interactions, createdInteraction]);
      });

      return createdInteraction;
    } catch (e) {
      rethrow;
    }
  }

  /// Gets the current customer ID being viewed
  String? get currentCustomerId => _currentCustomerId;
}

/// Provider for managing CRM reminders
class ReminderNotifier extends StateNotifier<AsyncValue<List<CrmReminder>>> {

  ReminderNotifier(this._crmService) : super(const AsyncValue.loading());
  final CrmService _crmService;
  String? _currentCustomerId;

  /// Loads reminders for a specific customer
  Future<void> loadRemindersForCustomer(String customerId) async {
    try {
      state = const AsyncValue.loading();
      _currentCustomerId = customerId;

      final reminders = await _crmService.getCustomerReminders(customerId);
      state = AsyncValue.data(reminders);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Creates a new reminder
  Future<CrmReminder> setReminder(CrmReminder reminder) async {
    try {
      final createdReminder = await _crmService.setReminder(reminder);

      // Update the state with the new reminder
      state.whenData((reminders) {
        state = AsyncValue.data([...reminders, createdReminder]);
      });

      return createdReminder;
    } catch (e) {
      rethrow;
    }
  }

  /// Marks a reminder as completed
  Future<void> markReminderCompleted(String reminderId) async {
    state.whenData((reminders) {
      final index = reminders.indexWhere((r) => r.id == reminderId);
      if (index >= 0) {
        final updatedReminder = reminders[index].copyWith(isCompleted: true);
        final updatedReminders = [...reminders];
        updatedReminders[index] = updatedReminder;
        state = AsyncValue.data(updatedReminders);

        // In a real implementation, you would call the API to update the reminder
        // _crmService.updateReminder(updatedReminder);
      }
    });
  }

  /// Gets the current customer ID being viewed
  String? get currentCustomerId => _currentCustomerId;
}

/// Provider for the CRM report
class ReportNotifier extends StateNotifier<AsyncValue<CrmReport?>> {

  ReportNotifier(this._crmService) : super(const AsyncValue.loading());
  final CrmService _crmService;

  /// Generates a CRM report
  Future<void> generateReport() async {
    try {
      state = const AsyncValue.loading();
      final report = await _crmService.generateReport();
      state = AsyncValue.data(report);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Provider for the CustomerNotifier
final customerProvider =
    StateNotifierProvider<CustomerNotifier, AsyncValue<List<Customer>>>((ref) {
  final crmService = ref.watch(crmServiceProvider);
  return CustomerNotifier(crmService);
});

// Provider for the InteractionNotifier
final interactionProvider = StateNotifierProvider<InteractionNotifier,
    AsyncValue<List<InteractionLog>>>((ref) {
  final crmService = ref.watch(crmServiceProvider);
  return InteractionNotifier(crmService);
});

// Provider for the ReminderNotifier
final reminderProvider =
    StateNotifierProvider<ReminderNotifier, AsyncValue<List<CrmReminder>>>(
        (ref) {
  final crmService = ref.watch(crmServiceProvider);
  return ReminderNotifier(crmService);
});

// Provider for the ReportNotifier
final reportProvider =
    StateNotifierProvider<ReportNotifier, AsyncValue<CrmReport?>>((ref) {
  final crmService = ref.watch(crmServiceProvider);
  return ReportNotifier(crmService);
});
