import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../forecasting/data/models/production_plan_model.dart';
import '../../../../forecasting/domain/providers/production_planning_provider.dart';
import '../providers/production_integration_providers.dart';

/// Detail screen for a production plan
class ProductionPlanDetailScreen extends ConsumerStatefulWidget {

  const ProductionPlanDetailScreen({
    super.key,
    required this.planId,
  });
  /// Route name for navigation
  static const routeName = '/production-plan-detail';

  /// ID of the production plan to display
  final String planId;

  @override
  ConsumerState<ProductionPlanDetailScreen> createState() =>
      _ProductionPlanDetailScreenState();
}

class _ProductionPlanDetailScreenState
    extends ConsumerState<ProductionPlanDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _notesController = TextEditingController();
  bool _isConverting = false;
  String? _selectedProductionLineId;
  String? _selectedProductionLineName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fetch the plan details
    final planAsync = ref.watch(_productionPlanProvider(widget.planId));
    final canConvertAsync =
        ref.watch(canConvertPlanToExecutionProvider(widget.planId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Plan Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(_productionPlanProvider(widget.planId));
            },
          ),
        ],
      ),
      body: planAsync.when(
        data: (plan) {
          // Set notes text if available
          if (_notesController.text.isEmpty && plan.description.isNotEmpty) {
            _notesController.text = plan.description;
          }

          return Column(
            children: [
              // Header with basic details
              _buildHeader(plan),

              // Tab bar
              ColoredBox(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Products'),
                    Tab(text: 'Resources'),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Overview tab
                    _buildOverviewTab(plan),

                    // Products tab
                    _buildProductsTab(plan),

                    // Resources tab
                    _buildResourcesTab(plan),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: _buildFloatingActionButton(canConvertAsync),
    );
  }

  Widget _buildFloatingActionButton(AsyncValue<bool> canConvertAsync) {
    return canConvertAsync.when(
      data: (canConvert) {
        if (!canConvert) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: () => _showCreateExecutionDialog(),
          label: const Text('Create Execution'),
          icon: const Icon(Icons.play_arrow),
          backgroundColor: Theme.of(context).primaryColor,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<void> _showCreateExecutionDialog() async {
    // Get production lines from repository (simplified for now)
    final productionLines = [
      {'id': 'line1', 'name': 'Production Line 1'},
      {'id': 'line2', 'name': 'Production Line 2'},
      {'id': 'line3', 'name': 'Production Line 3'},
    ];

    _selectedProductionLineId = productionLines.first['id'];
    _selectedProductionLineName = productionLines.first['name'];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Production Execution'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create an execution record from this production plan. '
                    'The plan will be marked as in execution once the record is created.',
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Production Line:'),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedProductionLineId,
                    items: productionLines.map((line) {
                      return DropdownMenuItem<String>(
                        value: line['id'],
                        child: Text(line['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProductionLineId = value;
                        _selectedProductionLineName = productionLines
                            .firstWhere((line) => line['id'] == value)['name'];
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCEL'),
                ),
                _isConverting
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _convertPlanToExecution();
                        },
                        child: const Text('CREATE'),
                      ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _convertPlanToExecution() async {
    if (_selectedProductionLineId == null ||
        _selectedProductionLineName == null) {
      return;
    }

    setState(() {
      _isConverting = true;
    });

    try {
      final controller =
          ref.read(productionIntegrationControllerProvider.notifier);

      final result = await controller.convertPlanToExecution(
        planId: widget.planId,
        productionLineId: _selectedProductionLineId!,
        productionLineName: _selectedProductionLineName!,
      );

      if (result.isSuccess && result.data != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Production execution created successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to the execution detail screen
          Navigator.pushReplacementNamed(
            context,
            '/production-execution-detail',
            arguments: result.data!.id,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to create execution: ${result.failure?.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConverting = false;
        });
      }
    }
  }

  Widget _buildHeader(ProductionPlanModel plan) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan name and status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created: ${dateFormat.format(plan.createdDate)}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(plan.status),
            ],
          ),

          const SizedBox(height: 12),

          // Production period
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 8),
              Text(
                '${dateFormat.format(plan.startDate)} - ${dateFormat.format(plan.endDate)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Product count
          Row(
            children: [
              const Icon(Icons.inventory_2, size: 16),
              const SizedBox(width: 8),
              Text(
                '${plan.productionItems.length} Products',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    String label;

    switch (status.toLowerCase()) {
      case 'draft':
        backgroundColor = Colors.grey;
        label = 'DRAFT';
        break;
      case 'approved':
        backgroundColor = Colors.green;
        label = 'APPROVED';
        break;
      case 'rejected':
        backgroundColor = Colors.red;
        label = 'REJECTED';
        break;
      case 'inExecution':
        backgroundColor = Colors.blue;
        label = 'IN EXECUTION';
        break;
      default:
        backgroundColor = Colors.grey;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildOverviewTab(ProductionPlanModel plan) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(plan.description),
                ],
              ),
            ),
          ),

          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Approval Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildApprovalInfo(plan),
                ],
              ),
            ),
          ),

          // Additional sections can be added here
        ],
      ),
    );
  }

  Widget _buildApprovalInfo(ProductionPlanModel plan) {
    if (plan.status == 'approved' && plan.approvedDate != null) {
      final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Approved on: ${dateFormat.format(plan.approvedDate!)}'),
          if (plan.approvedBy != null) Text('Approved by: ${plan.approvedBy!}'),
        ],
      );
    } else if (plan.status == 'inExecution') {
      return const Text(
        'This plan has been converted to a production execution.',
        style: TextStyle(color: Colors.blue),
      );
    } else if (plan.status == 'rejected') {
      return const Text(
        'This plan has been rejected.',
        style: TextStyle(color: Colors.red),
      );
    } else {
      return const Text('This plan is pending approval.');
    }
  }

  Widget _buildProductsTab(ProductionPlanModel plan) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: plan.productionItems.length,
      itemBuilder: (context, index) {
        final item = plan.productionItems[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Quantity: ${item.quantity} ${item.unitOfMeasure}'),
                    Text('Status: ${item.status}'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Scheduled: ${DateFormat('MMM dd, yyyy').format(item.scheduledDate)}',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResourcesTab(ProductionPlanModel plan) {
    if (plan.resourceAllocation == null || plan.resourceAllocation!.isEmpty) {
      return const Center(
        child: Text('No resource allocations available for this plan.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: plan.resourceAllocation!.length,
      itemBuilder: (context, index) {
        final resource = plan.resourceAllocation![index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Type: ${resource.type}'),
                Text(
                    'Quantity: ${resource.dailyCapacity ?? "N/A"} ${resource.capacityUnit ?? ""}'),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Provider for fetching a specific production plan
final _productionPlanProvider =
    FutureProvider.family<ProductionPlanModel, String>((ref, id) async {
  final repository = ref.watch(productionPlanRepositoryProvider);
  return repository.getProductionPlanById(id);
});
