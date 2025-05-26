// Placeholder for CRM main screen
import 'package:flutter/material.dart';

import '../models/crm_report.dart';
import '../models/customer.dart';
import 'crm_analytics_dashboard_screen.dart';
import 'crm_onboarding_screen.dart';
import 'crm_reminders_screen.dart';
import 'crm_report_screen.dart';
import 'customer_bulk_actions_screen.dart';
import 'customer_import_export_screen.dart';
import 'customer_search_screen.dart';
import 'customer_tagging_screen.dart';

class CrmMainScreen extends StatelessWidget {
  const CrmMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRM Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CrmNavCard(
            title: 'Analytics Dashboard',
            icon: Icons.analytics,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CrmAnalyticsDashboardScreen(
                    totalCustomers: 100,
                    newCustomersThisMonth: 10,
                    totalInteractions: 200,
                    interactionsThisMonth: 20,
                    totalOrders: 50,
                    ordersThisMonth: 5,
                  ),
                ),
              );
            },
          ),
          _CrmNavCard(
            title: 'Customer Search',
            icon: Icons.search,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CustomerSearchScreen(
                    customers: [CustomerDummy.dummy()],
                  ),
                ),
              );
            },
          ),
          _CrmNavCard(
            title: 'Bulk Actions',
            icon: Icons.group,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CustomerBulkActionsScreen(
                    customers: [CustomerDummy.dummy()],
                    onBulkAction: (selected, action) {},
                  ),
                ),
              );
            },
          ),
          _CrmNavCard(
            title: 'Import/Export Customers',
            icon: Icons.import_export,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CustomerImportExportScreen(
                    customers: [CustomerDummy.dummy()],
                    onImport: (imported) {},
                  ),
                ),
              );
            },
          ),
          _CrmNavCard(
            title: 'Reminders',
            icon: Icons.alarm,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CrmRemindersScreen(
                    reminders: const [],
                    onComplete: (id) {},
                  ),
                ),
              );
            },
          ),
          _CrmNavCard(
            title: 'Reports',
            icon: Icons.summarize,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CrmReportScreen(
                    report: CrmReportDummy.dummy(),
                  ),
                ),
              );
            },
          ),
          _CrmNavCard(
            title: 'Onboarding',
            icon: Icons.info,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CrmOnboardingScreen(),
                ),
              );
            },
          ),
          _CrmNavCard(
            title: 'Customer Tagging',
            icon: Icons.label,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CustomerTaggingScreen(
                    customer: CustomerDummy.dummy(),
                    availableTags: const ['VIP', 'Prospect', 'Inactive'],
                    onTagsUpdated: (tags) {},
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CrmNavCard extends StatelessWidget {
  const _CrmNavCard(
      {required this.title, required this.icon, required this.onTap});
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
