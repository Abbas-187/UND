import 'package:flutter/foundation.dart';

import '../models/customer.dart';
import '../models/interaction_log.dart';

class CrmWorkflowAutomationService with ChangeNotifier {

  CrmWorkflowAutomationService({
    required this.customers,
    required this.interactions,
  });
  final List<Customer> customers;
  final List<InteractionLog> interactions;

  /// Find customers needing follow-up (e.g., no interaction in X days)
  List<Customer> customersNeedingFollowUp({int days = 7}) {
    final now = DateTime.now();
    return customers.where((customer) {
      final logs = interactions.where((log) => log.customerId == customer.id);
      if (logs.isEmpty) return true;
      final lastInteraction =
          logs.map((l) => l.date).reduce((a, b) => a.isAfter(b) ? a : b);
      return now.difference(lastInteraction).inDays >= days;
    }).toList();
  }

  /// Schedule a follow-up reminder for a customer
  void scheduleFollowUpReminder(
      Customer customer, DateTime remindAt, String message) {
    // Integrate with CrmReminderProvider or notification system
    // Example: CrmReminderProvider().addReminder(...)
    // This is a placeholder for actual implementation
    debugPrint(
        'Scheduled follow-up for ${customer.name} at $remindAt: $message');
  }

  /// Lead nurturing: find new customers with no interactions
  List<Customer> newLeadsNeedingNurture({int days = 14}) {
    final now = DateTime.now();
    return customers.where((customer) {
      final isNew = now.difference(customer.createdAt).inDays <= days;
      final hasInteraction =
          interactions.any((log) => log.customerId == customer.id);
      return isNew && !hasInteraction;
    }).toList();
  }
}
