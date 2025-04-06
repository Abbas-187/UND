import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../production/domain/models/production_execution_model.dart';
import '../widgets/production_execution_card.dart';

// Temporary provider until Riverpod code generation is run
final tempProductionExecutionsProvider =
    StreamProvider.autoDispose<List<ProductionExecutionModel>>((ref) {
  // This is a placeholder and should be replaced with the actual generated provider
  return Stream.value([]);
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
              // Navigator.of(context).pushNamed('/create-production-execution');
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
          // In a real app, this would navigate to a form
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
        // Navigator.of(context).pushNamed(
        //   '/production-execution-details',
        //   arguments: execution.id,
        // );
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
