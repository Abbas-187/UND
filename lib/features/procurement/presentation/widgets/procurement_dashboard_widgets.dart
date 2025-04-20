import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/purchase_order_model.dart';
import '../../data/models/supplier_model.dart';
import '../../data/models/supplier_quality_log_model.dart';
import 'supplier_performance_chart.dart';

/// Widget for displaying upcoming deliveries on the dashboard
class UpcomingDeliveriesWidget extends ConsumerWidget {
  const UpcomingDeliveriesWidget({super.key, this.limit = 5});

  final int limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingDeliveries = ref.watch(upcomingDeliveriesProvider(limit));

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Deliveries',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full deliveries screen
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            upcomingDeliveries.when(
              data: (deliveries) {
                if (deliveries.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No upcoming deliveries'),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: deliveries.length,
                  itemBuilder: (context, index) {
                    final delivery = deliveries[index];
                    final daysRemaining = delivery.expectedDeliveryDate != null
                        ? delivery.expectedDeliveryDate!
                            .difference(DateTime.now())
                            .inDays
                        : 0;

                    return ListTile(
                      title: Text(
                        'PO ${delivery.orderNumber ?? delivery.poNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${delivery.supplierName} • ${DateFormat('MMM dd, yyyy').format(delivery.expectedDeliveryDate ?? DateTime.now())}',
                      ),
                      trailing: Chip(
                        label: Text(
                          '$daysRemaining days',
                          style: TextStyle(
                            color: daysRemaining <= 2
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        backgroundColor: daysRemaining <= 2
                            ? Colors.red
                            : daysRemaining <= 5
                                ? Colors.amber
                                : Colors.green[100],
                      ),
                      onTap: () {
                        // Navigate to order details
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Error: ${error.toString()}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying pending approvals on the dashboard
class PendingApprovalsWidget extends ConsumerWidget {
  const PendingApprovalsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingApprovals = ref.watch(pendingApprovalsProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pending Approvals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to approvals screen
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            pendingApprovals.when(
              data: (approvals) {
                if (approvals.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No pending approvals'),
                    ),
                  );
                }

                return Column(
                  children: [
                    _buildApprovalSummary(approvals),
                    const Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: approvals.length > 3 ? 3 : approvals.length,
                      itemBuilder: (context, index) {
                        final approval = approvals[index];
                        return ListTile(
                          title: Text(
                            'PO ${approval.orderNumber ?? approval.poNumber}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Created ${DateFormat('MMM dd').format(approval.createdAt ?? DateTime.now())} • ${NumberFormat.currency(symbol: '\$').format(approval.totalAmount)}',
                          ),
                          trailing: OutlinedButton(
                            onPressed: () {
                              // Open approval dialog
                            },
                            child: const Text('Review'),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Error: ${error.toString()}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalSummary(List<PurchaseOrderModel> approvals) {
    final totalAmount = approvals.fold<double>(
        0, (sum, approval) => sum + approval.totalAmount);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            approvals.length.toString(),
            'Orders',
            Colors.blue,
          ),
          _buildSummaryItem(
            NumberFormat.currency(symbol: '\$').format(totalAmount),
            'Total Value',
            Colors.green,
          ),
          _buildSummaryItem(
            '${approvals.where((a) => a.createdAt != null && a.createdAt!.difference(DateTime.now()).inDays.abs() <= 2).length}',
            'Urgent',
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Widget for displaying supplier performance metrics
class SupplierPerformanceWidget extends StatefulWidget {
  const SupplierPerformanceWidget({super.key, this.limit = 5});
  final int limit;

  @override
  State<SupplierPerformanceWidget> createState() =>
      _SupplierPerformanceWidgetState();
}

class _SupplierPerformanceWidgetState extends State<SupplierPerformanceWidget> {
  bool _showData = true;
  Color _barColor = Colors.indigo;
  String _title = 'Supplier Performance (Mock)';
  final TextEditingController _titleController =
      TextEditingController(text: 'Supplier Performance (Mock)');

  List<SupplierPerformance> get _mockData => [
        SupplierPerformance(name: 'DairyBest', score: 4.7),
        SupplierPerformance(name: 'MilkPro', score: 4.2),
        SupplierPerformance(name: 'AgroFarm', score: 3.8),
        SupplierPerformance(name: 'FreshFields', score: 4.5),
        SupplierPerformance(name: 'GreenPastures', score: 3.9),
      ];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Chart Title',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (val) => setState(() => _title = val),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<Color>(
                  value: _barColor,
                  items: [
                    DropdownMenuItem(
                      value: Colors.indigo,
                      child: Container(
                          width: 24, height: 24, color: Colors.indigo),
                    ),
                    DropdownMenuItem(
                      value: Colors.blue,
                      child:
                          Container(width: 24, height: 24, color: Colors.blue),
                    ),
                    DropdownMenuItem(
                      value: Colors.green,
                      child:
                          Container(width: 24, height: 24, color: Colors.green),
                    ),
                    DropdownMenuItem(
                      value: Colors.orange,
                      child: Container(
                          width: 24, height: 24, color: Colors.orange),
                    ),
                  ],
                  onChanged: (color) => setState(() => _barColor = color!),
                  underline: Container(),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => setState(() => _showData = !_showData),
                  child: Text(_showData ? 'Show Empty' : 'Show Data'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SupplierPerformanceChart(
              data: _showData ? _mockData : [],
              title: _title,
              barColor: _barColor,
              backgroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying recent quality issues
class RecentQualityIssuesWidget extends ConsumerWidget {
  const RecentQualityIssuesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentQualityIssues = ref.watch(recentQualityIssuesProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Quality Issues',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to quality issues screen
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            recentQualityIssues.when(
              data: (issues) {
                if (issues.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No recent quality issues'),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: issues.length,
                  itemBuilder: (context, index) {
                    final issue = issues[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(top: 4, right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: issue.inspectionResult ==
                                      InspectionResult.fail
                                  ? Colors.red
                                  : Colors.amber,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  issue.supplierName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Inspection: ${DateFormat('MMM dd, yyyy').format(issue.inspectionDate)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Issues: ${_getQualityIssueDescription(issue)}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                if (issue.correctiveActions != null &&
                                    issue.correctiveActions!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      'Action: ${issue.correctiveActions}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Error: ${error.toString()}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getQualityIssueDescription(SupplierQualityLog issue) {
    final issues = <String>[];

    if (issue.fatContent != null && issue.fatContent! < 3.5) {
      issues.add('Low fat content (${issue.fatContent}%)');
    }

    if (issue.proteinContent != null && issue.proteinContent! < 3.0) {
      issues.add('Low protein content (${issue.proteinContent}%)');
    }

    if (issue.bacterialCount != null && issue.bacterialCount! > 100000) {
      issues.add('High bacterial count (${issue.bacterialCount})');
    }

    return issues.isEmpty ? 'Quality standards not met' : issues.join(', ');
  }
}

// Providers for the dashboard widgets
final purchaseOrderProvider =
    StateNotifierProvider<PurchaseOrderNotifier, List<PurchaseOrderModel>>(
        (ref) => PurchaseOrderNotifier());

final supplierProvider =
    StateNotifierProvider<SupplierNotifier, List<Supplier>>(
        (ref) => SupplierNotifier());

final supplierQualityProvider =
    StateNotifierProvider<SupplierQualityNotifier, List<SupplierQualityLog>>(
        (ref) => SupplierQualityNotifier());

// Mock notifiers for the providers
class PurchaseOrderNotifier extends StateNotifier<List<PurchaseOrderModel>> {
  PurchaseOrderNotifier() : super([]);

  Future<List<PurchaseOrderModel>> getUpcomingDeliveries(
      {int limit = 5}) async {
    // Implementation would fetch from repository
    return [];
  }

  Future<List<PurchaseOrderModel>> getPendingApprovals() async {
    // Implementation would fetch from repository
    return [];
  }
}

class SupplierNotifier extends StateNotifier<List<Supplier>> {
  SupplierNotifier() : super([]);

  Future<List<Supplier>> getTopSuppliers({int limit = 5}) async {
    // Implementation would fetch from repository
    return [];
  }
}

class SupplierQualityNotifier extends StateNotifier<List<SupplierQualityLog>> {
  SupplierQualityNotifier() : super([]);

  Future<List<SupplierQualityLog>> getRecentQualityIssues({
    int daysBack = 30,
    int limit = 5,
    bool onlyFailures = true,
  }) async {
    // Implementation would fetch from repository
    return [];
  }
}

final upcomingDeliveriesProvider =
    FutureProvider.family<List<PurchaseOrderModel>, int>((ref, limit) async {
  final purchaseOrderState = ref.read(purchaseOrderProvider.notifier);
  return purchaseOrderState.getUpcomingDeliveries(limit: limit);
});

final pendingApprovalsProvider =
    FutureProvider<List<PurchaseOrderModel>>((ref) async {
  final purchaseOrderState = ref.read(purchaseOrderProvider.notifier);
  return purchaseOrderState.getPendingApprovals();
});

final topSuppliersProvider =
    FutureProvider.family<List<Supplier>, int>((ref, limit) async {
  final supplierState = ref.read(supplierProvider.notifier);
  return supplierState.getTopSuppliers(limit: limit);
});

final recentQualityIssuesProvider =
    FutureProvider<List<SupplierQualityLog>>((ref) async {
  final qualityState = ref.read(supplierQualityProvider.notifier);
  return qualityState.getRecentQualityIssues(
    daysBack: 30,
    limit: 5,
    onlyFailures: true,
  );
});
