import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/production_execution_model.dart';
import '../providers/production_execution_providers.dart';
import 'production_execution_detail_screen.dart';

/// Parameters for filtering production executions
class FilteredExecutionsParams {
  const FilteredExecutionsParams({
    this.startDate,
    this.endDate,
    this.status,
    this.searchQuery,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final ProductionExecutionStatus? status;
  final String? searchQuery;
}

/// Provider for filtered production executions
final filteredProductionExecutionsProvider = Provider.family<
    AsyncValue<List<ProductionExecutionModel>>,
    FilteredExecutionsParams>((ref, params) {
  final executionsAsync = ref.watch(productionExecutionsProvider(
    startDate: params.startDate,
    endDate: params.endDate,
    status: params.status,
    searchQuery: params.searchQuery,
  ));

  return executionsAsync;
});

/// Screen that displays a list of production executions with filtering options
class ProductionExecutionListScreen extends ConsumerStatefulWidget {
  const ProductionExecutionListScreen({super.key});

  @override
  ConsumerState<ProductionExecutionListScreen> createState() =>
      _ProductionExecutionListScreenState();
}

class _ProductionExecutionListScreenState
    extends ConsumerState<ProductionExecutionListScreen> {
  // Filter state
  DateTime? _startDate;
  DateTime? _endDate;
  ProductionExecutionStatus? _selectedStatus;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    // Initialize with default date range (last 30 days)
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    // Watch the filtered executions provider
    final executionsAsync = ref.watch(filteredProductionExecutionsProvider(
      FilteredExecutionsParams(
        startDate: _startDate,
        endDate: _endDate,
        status: _selectedStatus,
        searchQuery: _searchQuery,
      ),
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Executions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(filteredProductionExecutionsProvider(
              FilteredExecutionsParams(
                startDate: _startDate,
                endDate: _endDate,
                status: _selectedStatus,
                searchQuery: _searchQuery,
              ),
            )),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by product or batch',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: _searchQuery != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = null;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.isEmpty ? null : value;
                });
              },
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                if (_startDate != null && _endDate != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(
                          '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}'),
                      onSelected: (_) => _showFilterDialog(),
                      selected: true,
                    ),
                  ),

                if (_selectedStatus != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(_getStatusLabel(_selectedStatus!)),
                      onSelected: (_) {
                        setState(() {
                          _selectedStatus = null;
                        });
                      },
                      selected: true,
                      backgroundColor:
                          _getStatusColor(_selectedStatus!).withOpacity(0.1),
                      selectedColor:
                          _getStatusColor(_selectedStatus!).withOpacity(0.2),
                    ),
                  ),

                // Clear all filters button
                if (_selectedStatus != null || _searchQuery != null)
                  TextButton.icon(
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Filters'),
                    onPressed: () {
                      setState(() {
                        _selectedStatus = null;
                        _searchQuery = null;
                      });
                    },
                  ),
              ],
            ),
          ),

          // List of executions
          Expanded(
            child: executionsAsync.when(
              data: (executions) => executions.isEmpty
                  ? const Center(child: Text('No production executions found'))
                  : ListView.builder(
                      itemCount: executions.length,
                      itemBuilder: (context, index) =>
                          _buildExecutionCard(executions[index]),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text(
                  'Error loading executions: ${error.toString()}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create execution screen
          // Implementation depends on your routing system
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Filter Executions'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date range selection
                const Text('Date Range'),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _startDate = date;
                            });
                          }
                        },
                        child: Text(_startDate != null
                            ? _formatDate(_startDate!)
                            : 'Start Date'),
                      ),
                    ),
                    const Text(' - '),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate:
                                DateTime.now().add(const Duration(days: 30)),
                          );
                          if (date != null) {
                            setState(() {
                              _endDate = date;
                            });
                          }
                        },
                        child: Text(_endDate != null
                            ? _formatDate(_endDate!)
                            : 'End Date'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16.0),

                // Status selection
                const Text('Status'),
                Wrap(
                  spacing: 8.0,
                  children: ProductionExecutionStatus.values.map((status) {
                    return FilterChip(
                      label: Text(_getStatusLabel(status)),
                      selected: _selectedStatus == status,
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = selected ? status : null;
                        });
                      },
                      backgroundColor: _getStatusColor(status).withOpacity(0.1),
                      selectedColor: _getStatusColor(status).withOpacity(0.2),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // The state is already updated within the StatefulBuilder
                  // Refresh the widget to apply filters
                  this.setState(() {});
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExecutionCard(ProductionExecutionModel execution) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        title: Text(
          execution.productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Batch: ${execution.batchNumber}'),
            Text('Scheduled: ${_formatDate(execution.scheduledDate)}'),
            Text(
                'Quantity: ${execution.targetQuantity} ${execution.unitOfMeasure}'),
          ],
        ),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(execution.status),
          child: Icon(
            _getStatusIcon(execution.status),
            color: Colors.white,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _getStatusLabel(execution.status),
              style: TextStyle(
                color: _getStatusColor(execution.status),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (execution.startTime != null) ...[
              const SizedBox(height: 4.0),
              Text(
                'Started: ${_formatDate(execution.startTime!)}',
                style: const TextStyle(fontSize: 12.0),
              ),
            ],
          ],
        ),
        onTap: () {
          // Navigate to execution detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductionExecutionDetailScreen(
                executionId: execution.id,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusLabel(ProductionExecutionStatus status) {
    switch (status) {
      case ProductionExecutionStatus.planned:
        return 'Planned';
      case ProductionExecutionStatus.inProgress:
        return 'In Progress';
      case ProductionExecutionStatus.completed:
        return 'Completed';
      case ProductionExecutionStatus.paused:
        return 'Paused';
      case ProductionExecutionStatus.cancelled:
        return 'Cancelled';
      case ProductionExecutionStatus.failed:
        return 'Failed';
    }
  }

  Color _getStatusColor(ProductionExecutionStatus status) {
    switch (status) {
      case ProductionExecutionStatus.planned:
        return Colors.blue;
      case ProductionExecutionStatus.inProgress:
        return Colors.amber;
      case ProductionExecutionStatus.completed:
        return Colors.green;
      case ProductionExecutionStatus.paused:
        return Colors.orange;
      case ProductionExecutionStatus.cancelled:
        return Colors.grey;
      case ProductionExecutionStatus.failed:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ProductionExecutionStatus status) {
    switch (status) {
      case ProductionExecutionStatus.planned:
        return Icons.event;
      case ProductionExecutionStatus.inProgress:
        return Icons.play_arrow;
      case ProductionExecutionStatus.completed:
        return Icons.check_circle;
      case ProductionExecutionStatus.paused:
        return Icons.pause;
      case ProductionExecutionStatus.cancelled:
        return Icons.cancel;
      case ProductionExecutionStatus.failed:
        return Icons.error;
    }
  }
}
