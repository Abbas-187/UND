// Placeholder for CRM widget
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/crm_reminder.dart';
import '../models/customer.dart';
import '../models/interaction_log.dart';
import '../providers/crm_provider.dart';

/// A card widget for displaying customer information
class CustomerCard extends ConsumerWidget {

  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
  });
  final Customer customer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.primaryColor,
                    child: Text(
                      customer.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          customer.email,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          customer.phone,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (customer.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  children: customer.tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      backgroundColor: theme.colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                'Created: ${DateFormat.yMMMMd().format(customer.createdAt)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A widget for displaying a list of customers
class CustomerList extends ConsumerWidget {

  const CustomerList({
    super.key,
    required this.customers,
    required this.onCustomerTap,
  });
  final List<Customer> customers;
  final Function(Customer) onCustomerTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (customers.isEmpty) {
      return Center(
        child: Text(
          'No customers found',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return CustomerCard(
          customer: customer,
          onTap: () => onCustomerTap(customer),
        );
      },
    );
  }
}

/// A widget for displaying customer interaction history
class InteractionHistoryList extends ConsumerWidget {

  const InteractionHistoryList({
    super.key,
    required this.customerId,
  });
  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interactionsAsync = ref.watch(interactionProvider);
    final interactionNotifier = ref.read(interactionProvider.notifier);

    // Load interactions if customerId changes
    if (interactionNotifier.currentCustomerId != customerId) {
      interactionNotifier.loadInteractionsForCustomer(customerId);
    }

    return interactionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error loading interactions: $error'),
      ),
      data: (interactions) {
        if (interactions.isEmpty) {
          return Center(
            child: Text(
              'No interactions recorded',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        // Sort interactions by date (newest first)
        final sortedInteractions = List<InteractionLog>.from(interactions)
          ..sort((a, b) => b.date.compareTo(a.date));

        return ListView.separated(
          itemCount: sortedInteractions.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final interaction = sortedInteractions[index];
            return ListTile(
              leading: CircleAvatar(
                child: _getInteractionTypeIcon(interaction.type),
              ),
              title: Text(interaction.type),
              subtitle: Text(interaction.notes),
              trailing: Text(
                DateFormat.yMMMd().format(interaction.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          },
        );
      },
    );
  }

  Widget _getInteractionTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'call':
        return const Icon(Icons.phone);
      case 'email':
        return const Icon(Icons.email);
      case 'meeting':
        return const Icon(Icons.people);
      case 'order':
        return const Icon(Icons.shopping_cart);
      default:
        return const Icon(Icons.chat);
    }
  }
}

/// A widget for displaying customer reminders
class ReminderList extends ConsumerWidget {

  const ReminderList({
    super.key,
    required this.customerId,
  });
  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(reminderProvider);
    final reminderNotifier = ref.read(reminderProvider.notifier);

    // Load reminders if customerId changes
    if (reminderNotifier.currentCustomerId != customerId) {
      reminderNotifier.loadRemindersForCustomer(customerId);
    }

    return remindersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error loading reminders: $error'),
      ),
      data: (reminders) {
        if (reminders.isEmpty) {
          return Center(
            child: Text(
              'No reminders set',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        // Sort reminders by date (oldest first for upcoming reminders)
        final sortedReminders = List<CrmReminder>.from(reminders)
          ..sort((a, b) => a.remindAt.compareTo(b.remindAt));

        return ListView.builder(
          itemCount: sortedReminders.length,
          itemBuilder: (context, index) {
            final reminder = sortedReminders[index];
            return ListTile(
              leading: Icon(
                Icons.notifications,
                color: reminder.isCompleted ? Colors.grey : Colors.orange,
              ),
              title: Text(
                reminder.message,
                style: TextStyle(
                  decoration:
                      reminder.isCompleted ? TextDecoration.lineThrough : null,
                  color: reminder.isCompleted ? Colors.grey : null,
                ),
              ),
              subtitle: Text(
                'Due: ${DateFormat.yMMMd().add_jm().format(reminder.remindAt)}',
              ),
              trailing: reminder.isCompleted
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () {
                        reminderNotifier.markReminderCompleted(reminder.id);
                      },
                    ),
            );
          },
        );
      },
    );
  }
}

/// A form widget for adding new customer interactions
class AddInteractionForm extends ConsumerStatefulWidget {

  const AddInteractionForm({
    super.key,
    required this.customerId,
  });
  final String customerId;

  @override
  ConsumerState<AddInteractionForm> createState() => _AddInteractionFormState();
}

class _AddInteractionFormState extends ConsumerState<AddInteractionForm> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  final _notesController = TextEditingController();

  final List<String> _interactionTypes = [
    'Call',
    'Email',
    'Meeting',
    'Order',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _type = _interactionTypes.first;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Add Interaction',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(
              labelText: 'Interaction Type',
              border: OutlineInputBorder(),
            ),
            items: _interactionTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _type = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some notes';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('Save Interaction'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final interaction = InteractionLog(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}', // Will be replaced by API
        customerId: widget.customerId,
        type: _type,
        date: DateTime.now(),
        notes: _notesController.text,
      );

      final interactionNotifier = ref.read(interactionProvider.notifier);
      interactionNotifier.logInteraction(interaction).then((_) {
        Navigator.of(context).pop();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log interaction: $error')),
        );
      });
    }
  }
}

/// A form widget for setting reminders
class AddReminderForm extends ConsumerStatefulWidget {

  const AddReminderForm({
    super.key,
    required this.customerId,
  });
  final String customerId;

  @override
  ConsumerState<AddReminderForm> createState() => _AddReminderFormState();
}

class _AddReminderFormState extends ConsumerState<AddReminderForm> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  DateTime _remindAt = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Set Reminder',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Reminder Message',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a reminder message';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Remind At'),
            subtitle: Text(DateFormat.yMMMd().add_jm().format(_remindAt)),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _selectDateTime,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('Save Reminder'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _remindAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_remindAt),
      );

      if (pickedTime != null) {
        setState(() {
          _remindAt = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final reminder = CrmReminder(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}', // Will be replaced by API
        customerId: widget.customerId,
        message: _messageController.text,
        remindAt: _remindAt,
      );

      final reminderNotifier = ref.read(reminderProvider.notifier);
      reminderNotifier.setReminder(reminder).then((_) {
        Navigator.of(context).pop();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set reminder: $error')),
        );
      });
    }
  }
}

/// A tab view for the customer profile page
class CustomerProfileTabs extends StatelessWidget {

  const CustomerProfileTabs({
    super.key,
    required this.customer,
  });
  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.info), text: 'Details'),
              Tab(icon: Icon(Icons.history), text: 'Interactions'),
              Tab(icon: Icon(Icons.notifications), text: 'Reminders'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Details tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Email', customer.email),
                      _buildDetailRow('Phone', customer.phone),
                      _buildDetailRow('Address', customer.address),
                      _buildDetailRow('Created',
                          DateFormat.yMMMMd().format(customer.createdAt)),
                      if (customer.updatedAt != null)
                        _buildDetailRow('Last Updated',
                            DateFormat.yMMMMd().format(customer.updatedAt!)),
                      const SizedBox(height: 16),
                      Text(
                        'Tags',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: customer.tags.map((tag) {
                          return Chip(label: Text(tag));
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Interactions tab
                Stack(
                  children: [
                    InteractionHistoryList(customerId: customer.id),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton(
                        onPressed: () {
                          _showAddInteractionDialog(context, customer.id);
                        },
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),

                // Reminders tab
                Stack(
                  children: [
                    ReminderList(customerId: customer.id),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton(
                        onPressed: () {
                          _showAddReminderDialog(context, customer.id);
                        },
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddInteractionDialog(BuildContext context, String customerId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AddInteractionForm(customerId: customerId),
        ),
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context, String customerId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AddReminderForm(customerId: customerId),
        ),
      ),
    );
  }
}
