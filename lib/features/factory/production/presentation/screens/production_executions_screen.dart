import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/routes/app_router.dart';
import '../../../production/domain/models/production_execution_model.dart';
import '../widgets/production_execution_card.dart';

// Mock data for development purposes
List<ProductionExecutionModel> _mockExecutions = [
  ProductionExecutionModel(
    id: '001',
    batchNumber: 'B2023-0123',
    productionOrderId: 'PO-2023-001',
    scheduledDate: DateTime.now(),
    productId: 'P001',
    productName: 'Whole Milk (1L)',
    targetQuantity: 1500,
    unitOfMeasure: 'Liters',
    status: ProductionExecutionStatus.inProgress,
    startTime: DateTime.now().subtract(const Duration(hours: 2)),
    endTime: null,
    productionLineId: 'PL-001',
    productionLineName: 'Milk Processing Line 1',
    assignedPersonnel: const [],
    materials: const [],
    expectedYield: 1450,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    createdBy: 'admin',
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    updatedBy: 'operator',
  ),
  ProductionExecutionModel(
    id: '002',
    batchNumber: 'B2023-0124',
    productionOrderId: 'PO-2023-002',
    scheduledDate: DateTime.now().add(const Duration(days: 1)),
    productId: 'P002',
    productName: 'Low-Fat Milk (1L)',
    targetQuantity: 1200,
    unitOfMeasure: 'Liters',
    status: ProductionExecutionStatus.planned,
    startTime: null,
    endTime: null,
    productionLineId: 'PL-001',
    productionLineName: 'Milk Processing Line 1',
    assignedPersonnel: const [],
    materials: const [],
    expectedYield: 1150,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    createdBy: 'admin',
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedBy: 'admin',
  ),
  ProductionExecutionModel(
    id: '003',
    batchNumber: 'B2023-0122',
    productionOrderId: 'PO-2023-003',
    scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
    productId: 'P003',
    productName: 'Strawberry Yogurt (500g)',
    targetQuantity: 800,
    unitOfMeasure: 'Units',
    status: ProductionExecutionStatus.completed,
    startTime: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
    endTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    productionLineId: 'PL-002',
    productionLineName: 'Yogurt Production Line',
    assignedPersonnel: const [],
    materials: const [],
    expectedYield: 790,
    actualYield: 785,
    qualityRating: QualityRating.good,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    createdBy: 'admin',
    updatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    updatedBy: 'operator',
  ),
  ProductionExecutionModel(
    id: '004',
    batchNumber: 'B2023-0125',
    productionOrderId: 'PO-2023-004',
    scheduledDate: DateTime.now().add(const Duration(days: 2)),
    productId: 'P004',
    productName: 'Cheese Curd (250g)',
    targetQuantity: 500,
    unitOfMeasure: 'Units',
    status: ProductionExecutionStatus.planned,
    startTime: null,
    endTime: null,
    productionLineId: 'PL-003',
    productionLineName: 'Cheese Production Line',
    assignedPersonnel: const [],
    materials: const [],
    expectedYield: 480,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    createdBy: 'admin',
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedBy: 'admin',
  ),
  ProductionExecutionModel(
    id: '005',
    batchNumber: 'B2023-0126',
    productionOrderId: 'PO-2023-005',
    scheduledDate: DateTime.now().subtract(const Duration(days: 3)),
    productId: 'P005',
    productName: 'Butter (200g)',
    targetQuantity: 1000,
    unitOfMeasure: 'Units',
    status: ProductionExecutionStatus.completed,
    startTime: DateTime.now().subtract(const Duration(days: 3, hours: 10)),
    endTime: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
    productionLineId: 'PL-004',
    productionLineName: 'Butter Production Line',
    assignedPersonnel: const [],
    materials: const [],
    expectedYield: 980,
    actualYield: 975,
    qualityRating: QualityRating.excellent,
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
    createdBy: 'admin',
    updatedAt: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
    updatedBy: 'operator',
  ),
];

// Temporary provider until Riverpod code generation is run
final tempProductionExecutionsProvider =
    StreamProvider.autoDispose<List<ProductionExecutionModel>>((ref) {
  // This is a placeholder and should be replaced with the actual generated provider
  return Stream.value(_mockExecutions);
});

/// Screen that displays a list of production executions
class ProductionExecutionsScreen extends ConsumerStatefulWidget {
  const ProductionExecutionsScreen({super.key});

  /// Route name for navigation
  static const routeName = '/production-executions';

  @override
  ConsumerState<ProductionExecutionsScreen> createState() =>
      _ProductionExecutionsScreenState();
}

class _ProductionExecutionsScreenState
    extends ConsumerState<ProductionExecutionsScreen>
    with SingleTickerProviderStateMixin {
  // Filter states
  late TabController _tabController;
  ProductionExecutionStatus? _statusFilter;
  String _searchQuery = '';
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  String? _productIdFilter;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize tab controller for different status views
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Handle tab changes to update status filter
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0: // All
            _statusFilter = null;
            break;
          case 1: // Active
            _statusFilter = ProductionExecutionStatus.inProgress;
            break;
          case 2: // Planned
            _statusFilter = ProductionExecutionStatus.planned;
            break;
          case 3: // Completed
            _statusFilter = ProductionExecutionStatus.completed;
            break;
        }
      });
    }
  }

  // Reset all filters
  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _startDateFilter = null;
      _endDateFilter = null;
      _productIdFilter = null;
      // Don't reset status as it's controlled by tabs
    });
  }

  // Show filter dialog
  Future<void> _showFilterDialog() async {
    final DateTime? startDate = await showDatePicker(
      context: context,
      initialDate: _startDateFilter ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Select Start Date',
    );

    if (startDate != null) {
      setState(() {
        _startDateFilter = startDate;
      });

      if (mounted) {
        final DateTime? endDate = await showDatePicker(
          context: context,
          initialDate:
              _endDateFilter ?? DateTime.now().add(const Duration(days: 7)),
          firstDate: startDate,
          lastDate: DateTime(2030),
          helpText: 'Select End Date',
        );

        if (endDate != null) {
          setState(() {
            _endDateFilter = endDate;
          });
        }
      }
    }
  }

  // Filter executions locally until Riverpod providers are working
  List<ProductionExecutionModel> _filterExecutions(
      List<ProductionExecutionModel> executions) {
    return executions.where((execution) {
      // Apply status filter
      if (_statusFilter != null && execution.status != _statusFilter) {
        return false;
      }

      // Apply date filters
      if (_startDateFilter != null &&
          execution.scheduledDate.isBefore(_startDateFilter!)) {
        return false;
      }

      if (_endDateFilter != null &&
          execution.scheduledDate.isAfter(_endDateFilter!)) {
        return false;
      }

      // Apply product filter
      if (_productIdFilter != null && execution.productId != _productIdFilter) {
        return false;
      }

      // Apply search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return execution.productName.toLowerCase().contains(query) ||
            execution.batchNumber.toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Watch executions
    final executionsAsync = ref.watch(tempProductionExecutionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Executions'),
        actions: [
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter by date',
          ),
          // Reset filters button
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _resetFilters,
            tooltip: 'Reset filters',
          ),
          // Create new button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to create execution screen
              Navigator.of(context)
                  .pushNamed(AppRoutes.createProductionExecution);
            },
            tooltip: 'Create new production execution',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Planned'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by product or batch number',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Active filters display
          if (_startDateFilter != null || _endDateFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('Date Filter:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_startDateFilter != null ? DateFormat('yyyy-MM-dd').format(_startDateFilter!) : 'Any'} to ${_endDateFilter != null ? DateFormat('yyyy-MM-dd').format(_endDateFilter!) : 'Any'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: () {
                      setState(() {
                        _startDateFilter = null;
                        _endDateFilter = null;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Main content
          Expanded(
            child: executionsAsync.when(
              data: (executions) {
                final filteredExecutions = _filterExecutions(executions);

                if (filteredExecutions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No production executions found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _statusFilter != null
                              ? 'No ${_statusFilter.toString().split('.').last} executions'
                              : 'Try adjusting your filters',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return _buildExecutionsList(filteredExecutions);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading production executions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(tempProductionExecutionsProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create new execution screen
          Navigator.of(context).pushNamed(AppRoutes.createProductionExecution);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExecutionsList(List<ProductionExecutionModel> executions) {
    // Sort executions by date (most recent first)
    executions.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

    // Group by different statuses for better organization
    final active = executions
        .where((e) =>
            e.status == ProductionExecutionStatus.inProgress ||
            e.status == ProductionExecutionStatus.paused)
        .toList();

    final scheduled = executions
        .where((e) => e.status == ProductionExecutionStatus.planned)
        .toList();

    final completed = executions
        .where((e) => e.status == ProductionExecutionStatus.completed)
        .toList();

    final other = executions
        .where((e) =>
            e.status == ProductionExecutionStatus.cancelled ||
            e.status == ProductionExecutionStatus.failed)
        .toList();

    // For the "All" tab, show a grouped view with headers
    if (_statusFilter == null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (active.isNotEmpty) ...[
            _buildSectionHeader('Active Executions (${active.length})'),
            ...active.map(_buildExecutionCard),
          ],
          if (scheduled.isNotEmpty) ...[
            _buildSectionHeader('Scheduled Executions (${scheduled.length})'),
            ...scheduled.map(_buildExecutionCard),
          ],
          if (completed.isNotEmpty) ...[
            _buildSectionHeader('Completed Executions (${completed.length})'),
            ...completed.map(_buildExecutionCard),
          ],
          if (other.isNotEmpty) ...[
            _buildSectionHeader('Other Executions (${other.length})'),
            ...other.map(_buildExecutionCard),
          ],
        ],
      );
    }

    // For filtered tabs, show a simple list
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: executions.length,
      itemBuilder: (context, index) {
        return _buildExecutionCard(executions[index]);
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildExecutionCard(ProductionExecutionModel execution) {
    return ProductionExecutionCard(
      execution: execution,
      onTap: () {
        // Navigate to detail screen
        Navigator.of(context).pushNamed(
          AppRoutes.productionExecutionDetail,
          arguments: {'executionId': execution.id},
        );
      },
      // Pass callbacks for actions
      onStart: (id) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Started execution $id')),
        );
        // When Riverpod is set up, this would call: controller.startExecution(id);
      },
      onPause: (id) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paused execution $id')),
        );
        // When Riverpod is set up, this would call: controller.pauseExecution(id);
      },
      onResume: (id) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resumed execution $id')),
        );
        // When Riverpod is set up, this would call: controller.resumeExecution(id);
      },
      onComplete: (id) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Completed execution $id')),
        );
        // When Riverpod is set up, this would call:
        // controller.completeExecution(
        //   id,
        //   actualYield: execution.targetQuantity * 0.95,
        //   qualityRating: QualityRating.good,
        // );
      },
    );
  }
}
