import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../features/milk_reception/domain/models/notification_model.dart';
import '../../../../services/reception_notification_service.dart';
import '../../../../utils/service_locator.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<NotificationModel>> _notificationsFuture;
  late ReceptionNotificationService _notificationService;
  String? _userId;

  // Filters
  bool _showOnlyUnread = false;
  NotificationCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _notificationService =
        ServiceLocator.instance.get<ReceptionNotificationService>();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    _loadNotifications();
  }

  void _loadNotifications() {
    if (_userId != null) {
      _notificationsFuture =
          _notificationService.getNotificationsForUser(_userId!);
    } else {
      // Default to empty list if no user is logged in
      _notificationsFuture = Future.value([]);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Notifications'),
            Tab(text: 'Settings'),
          ],
        ),
        actions: [
          // Filter actions
          IconButton(
            icon: Icon(
              _showOnlyUnread ? Icons.visibility_off : Icons.visibility,
              color: _showOnlyUnread ? Colors.blue : null,
            ),
            tooltip: 'Show unread only',
            onPressed: () {
              setState(() {
                _showOnlyUnread = !_showOnlyUnread;
                _loadNotifications();
              });
            },
          ),
          // More actions can be added here
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {
                _loadNotifications();
              });
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsList(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return Column(
      children: [
        // Category filter chips
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 8.0,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedCategory == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = null;
                  });
                },
              ),
              ...NotificationCategory.values.map((category) => FilterChip(
                    label: Text(_getCategoryDisplayName(category)),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                    },
                  )),
            ],
          ),
        ),

        // Notifications list
        Expanded(
          child: FutureBuilder<List<NotificationModel>>(
            future: _notificationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading notifications: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No notifications'),
                );
              }

              // Apply filters
              var filteredNotifications = snapshot.data!;

              if (_showOnlyUnread) {
                filteredNotifications = filteredNotifications
                    .where((notification) => !notification.isRead)
                    .toList();
              }

              if (_selectedCategory != null) {
                filteredNotifications = filteredNotifications
                    .where((notification) =>
                        notification.category == _selectedCategory)
                    .toList();
              }

              if (filteredNotifications.isEmpty) {
                return const Center(
                  child: Text('No notifications match your filters'),
                );
              }

              return ListView.builder(
                itemCount: filteredNotifications.length,
                itemBuilder: (context, index) {
                  final notification = filteredNotifications[index];
                  return _buildNotificationCard(notification);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    // Use different colors based on priority
    Color priorityColor;
    switch (notification.priority) {
      case NotificationPriority.low:
        priorityColor = Colors.green;
        break;
      case NotificationPriority.medium:
        priorityColor = Colors.orange;
        break;
      case NotificationPriority.high:
        priorityColor = Colors.red;
        break;
      case NotificationPriority.critical:
        priorityColor = Colors.purple;
        break;
    }

    // Format the creation date
    final formattedDate =
        DateFormat('MMM dd, yyyy HH:mm').format(notification.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: Container(
          width: 12,
          height: double.infinity,
          color: priorityColor,
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              'Category: ${_getCategoryDisplayName(notification.category)} • $formattedDate',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: notification.isAcknowledged
            ? const Icon(Icons.check_circle, color: Colors.green)
            : IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => _acknowledgeNotification(notification),
              ),
        onTap: () {
          if (!notification.isRead) {
            _markAsRead(notification);
          }

          // Show detail dialog
          _showNotificationDetailDialog(notification);
        },
      ),
    );
  }

  void _markAsRead(NotificationModel notification) {
    _notificationService.markNotificationAsRead(notification.id).then((_) {
      // Refresh notifications list
      setState(() {
        _loadNotifications();
      });
    });
  }

  void _acknowledgeNotification(NotificationModel notification) {
    if (_userId != null) {
      _notificationService
          .acknowledgeNotification(notification.id, _userId!)
          .then((_) {
        // Refresh notifications list
        setState(() {
          _loadNotifications();
        });
      });
    }
  }

  void _showNotificationDetailDialog(NotificationModel notification) {
    // Show different dialogs based on notification type
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notification.message),
              const Divider(),
              Text(
                  'Category: ${_getCategoryDisplayName(notification.category)}'),
              Text(
                  'Priority: ${_getPriorityDisplayName(notification.priority)}'),
              Text(
                  'Created: ${DateFormat('yyyy-MM-dd HH:mm').format(notification.createdAt)}'),
              if (notification.acknowledgedAt != null)
                Text(
                    'Acknowledged: ${DateFormat('yyyy-MM-dd HH:mm').format(notification.acknowledgedAt!)}'),

              // Show specific information based on notification type
              const SizedBox(height: 16),
              if (notification is QualityAlertNotification) ...[
                const Text('Quality Alert Details:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Parameter: ${notification.parameterName}'),
                Text('Value: ${notification.parameterValue}'),
                Text('Threshold: ${notification.thresholdValue}'),
                if (notification.recommendedAction != null)
                  Text('Recommended Action: ${notification.recommendedAction}'),
              ] else if (notification is ReceptionRejectionNotification) ...[
                const Text('Rejection Details:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Reason: ${notification.rejectionReason}'),
                Text('Quantity: ${notification.quantityRejected} liters'),
                if (notification.recommendedAction != null)
                  Text('Recommended Action: ${notification.recommendedAction}'),
              ] else if (notification is ReceptionCompletionNotification) ...[
                const Text('Reception Details:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Quantity: ${notification.quantityAccepted} liters'),
                Text('Quality Grade: ${notification.qualityGrade}'),
              ] else if (notification is PendingTestNotification) ...[
                const Text('Test Details:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Sample Code: ${notification.sampleCode}'),
                Text(
                    'Tests Required: ${notification.testsRequired.join(", ")}'),
                Text(
                    'Due By: ${DateFormat('yyyy-MM-dd HH:mm').format(notification.dueBy)}'),
              ] else if (notification is SupplierPerformanceAlert) ...[
                const Text('Performance Details:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Trend: ${notification.trendType}'),
                Text('Change: ${notification.percentageChange}%'),
                if (notification.recommendedAction != null)
                  Text('Recommended Action: ${notification.recommendedAction}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (!notification.isAcknowledged)
            TextButton(
              onPressed: () {
                _acknowledgeNotification(notification);
                Navigator.of(context).pop();
              },
              child: const Text('Acknowledge'),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userId != null
          ? _notificationService.getUserNotificationSettings(_userId!)
          : Future.value({}),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading settings: ${snapshot.error}'),
          );
        }

        final settings = snapshot.data ?? {};

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              'Notification Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Delivery methods
            const Text(
              'Delivery Methods',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SwitchListTile(
              title: const Text('In-App Notifications'),
              value: settings['inAppEnabled'] ?? true,
              onChanged: _userId != null
                  ? (value) {
                      final updatedSettings =
                          Map<String, dynamic>.from(settings);
                      updatedSettings['inAppEnabled'] = value;
                      _notificationService.updateUserNotificationSettings(
                          _userId!, updatedSettings);
                      setState(() {});
                    }
                  : null,
            ),
            SwitchListTile(
              title: const Text('Push Notifications'),
              value: settings['pushEnabled'] ?? true,
              onChanged: _userId != null
                  ? (value) {
                      final updatedSettings =
                          Map<String, dynamic>.from(settings);
                      updatedSettings['pushEnabled'] = value;
                      _notificationService.updateUserNotificationSettings(
                          _userId!, updatedSettings);
                      setState(() {});
                    }
                  : null,
            ),
            SwitchListTile(
              title: const Text('Email Notifications'),
              value: settings['emailEnabled'] ?? true,
              onChanged: _userId != null
                  ? (value) {
                      final updatedSettings =
                          Map<String, dynamic>.from(settings);
                      updatedSettings['emailEnabled'] = value;
                      _notificationService.updateUserNotificationSettings(
                          _userId!, updatedSettings);
                      setState(() {});
                    }
                  : null,
            ),
            SwitchListTile(
              title: const Text('SMS Notifications'),
              value: settings['smsEnabled'] ?? true,
              onChanged: _userId != null
                  ? (value) {
                      final updatedSettings =
                          Map<String, dynamic>.from(settings);
                      updatedSettings['smsEnabled'] = value;
                      _notificationService.updateUserNotificationSettings(
                          _userId!, updatedSettings);
                      setState(() {});
                    }
                  : null,
            ),

            const Divider(),

            // Priority settings
            const Text(
              'Priority Levels',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SwitchListTile(
              title: const Text('Low Priority'),
              value: settings['lowPriorityEnabled'] ?? true,
              onChanged: _userId != null
                  ? (value) {
                      final updatedSettings =
                          Map<String, dynamic>.from(settings);
                      updatedSettings['lowPriorityEnabled'] = value;
                      _notificationService.updateUserNotificationSettings(
                          _userId!, updatedSettings);
                      setState(() {});
                    }
                  : null,
            ),
            SwitchListTile(
              title: const Text('Medium Priority'),
              value: settings['mediumPriorityEnabled'] ?? true,
              onChanged: _userId != null
                  ? (value) {
                      final updatedSettings =
                          Map<String, dynamic>.from(settings);
                      updatedSettings['mediumPriorityEnabled'] = value;
                      _notificationService.updateUserNotificationSettings(
                          _userId!, updatedSettings);
                      setState(() {});
                    }
                  : null,
            ),
            SwitchListTile(
              title: const Text('High Priority'),
              value: settings['highPriorityEnabled'] ?? true,
              onChanged: _userId != null
                  ? (value) {
                      final updatedSettings =
                          Map<String, dynamic>.from(settings);
                      updatedSettings['highPriorityEnabled'] = value;
                      _notificationService.updateUserNotificationSettings(
                          _userId!, updatedSettings);
                      setState(() {});
                    }
                  : null,
            ),
            SwitchListTile(
              title: const Text('Critical Priority'),
              value: settings['criticalPriorityEnabled'] ?? true,
              onChanged: _userId != null
                  ? (value) {
                      final updatedSettings =
                          Map<String, dynamic>.from(settings);
                      updatedSettings['criticalPriorityEnabled'] = value;
                      _notificationService.updateUserNotificationSettings(
                          _userId!, updatedSettings);
                      setState(() {});
                    }
                  : null,
            ),

            const Divider(),

            // Categories
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            ...NotificationCategory.values.map((category) {
              final categoryKey = category.toString().split('.').last;
              final categorySettings =
                  (settings['categorySettings'] as Map<String, dynamic>?) ?? {};
              return SwitchListTile(
                title: Text(_getCategoryDisplayName(category)),
                value: categorySettings[categoryKey] ?? true,
                onChanged: _userId != null
                    ? (value) {
                        final updatedSettings =
                            Map<String, dynamic>.from(settings);
                        if (updatedSettings['categorySettings'] == null) {
                          updatedSettings['categorySettings'] = {};
                        }
                        final categorySettingsCopy = Map<String, dynamic>.from(
                            updatedSettings['categorySettings']
                                as Map<String, dynamic>);
                        categorySettingsCopy[categoryKey] = value;
                        updatedSettings['categorySettings'] =
                            categorySettingsCopy;
                        _notificationService.updateUserNotificationSettings(
                            _userId!, updatedSettings);
                        setState(() {});
                      }
                    : null,
              );
            }),
          ],
        );
      },
    );
  }

  String _getCategoryDisplayName(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.qualityAlert:
        return 'Quality Alert';
      case NotificationCategory.rejectionNotice:
        return 'Rejection Notice';
      case NotificationCategory.receptionCompletion:
        return 'Reception Completion';
      case NotificationCategory.pendingTest:
        return 'Pending Test';
      case NotificationCategory.supplierPerformance:
        return 'Supplier Performance';
      case NotificationCategory.system:
        return 'System';
      default:
        return category.toString().split('.').last;
    }
  }

  String _getPriorityDisplayName(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.medium:
        return 'Medium';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.critical:
        return 'Critical';
      default:
        return priority.toString().split('.').last;
    }
  }
}
