// filepath: c:\FlutterProjects\und\lib\features\ai\presentation\widgets\workflow_automation_widgets.dart

import 'package:flutter/material.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../data/services/workflow_automation_service.dart';

/// Widget for displaying workflow automation dashboard
class WorkflowAutomationDashboard extends StatefulWidget {
  final WorkflowAutomationService automationService;

  const WorkflowAutomationDashboard({
    super.key,
    required this.automationService,
  });

  @override
  State<WorkflowAutomationDashboard> createState() =>
      _WorkflowAutomationDashboardState();
}

class _WorkflowAutomationDashboardState
    extends State<WorkflowAutomationDashboard> with TickerProviderStateMixin {
  late TabController _tabController;
  List<WorkflowExecution> _activeWorkflows = [];
  List<WorkflowDefinition> _workflowDefinitions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _listenToWorkflowUpdates();
  }

  void _loadData() {
    setState(() {
      _activeWorkflows = widget.automationService.getActiveWorkflows();
      _workflowDefinitions =
          widget.automationService.getAllWorkflowDefinitions();
    });
  }

  void _listenToWorkflowUpdates() {
    widget.automationService.workflowStream.listen((execution) {
      setState(() {
        _activeWorkflows = widget.automationService.getActiveWorkflows();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active', icon: Icon(Icons.play_circle)),
            Tab(text: 'Templates', icon: Icon(Icons.template_outlined)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildActiveWorkflowsTab(),
              _buildWorkflowTemplatesTab(),
              _buildAnalyticsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active Workflows', icon: Icon(Icons.play_circle)),
            Tab(
                text: 'Workflow Templates',
                icon: Icon(Icons.template_outlined)),
            Tab(text: 'Analytics & Insights', icon: Icon(Icons.analytics)),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildActiveWorkflowsTab(),
              _buildWorkflowTemplatesTab(),
              _buildAnalyticsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar navigation
        Container(
          width: 250,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(right: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            children: [
              _buildSidebarItem('Active Workflows', Icons.play_circle, 0),
              _buildSidebarItem(
                  'Workflow Templates', Icons.template_outlined, 1),
              _buildSidebarItem('Analytics & Insights', Icons.analytics, 2),
            ],
          ),
        ),
        // Main content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildActiveWorkflowsTab(),
              _buildWorkflowTemplatesTab(),
              _buildAnalyticsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarItem(String title, IconData icon, int index) {
    final isSelected = _tabController.index == index;
    return InkWell(
      onTap: () => _tabController.animateTo(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : null,
          border: Border(
            left: BorderSide(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey[800],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveWorkflowsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Workflows',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _showStartWorkflowDialog,
                icon: const Icon(Icons.add),
                label: const Text('Start Workflow'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _activeWorkflows.isEmpty
                ? _buildEmptyState(
                    'No active workflows', 'Start a workflow to see it here')
                : ListView.builder(
                    itemCount: _activeWorkflows.length,
                    itemBuilder: (context, index) {
                      return WorkflowExecutionCard(
                        execution: _activeWorkflows[index],
                        onCancel: (executionId) {
                          widget.automationService.cancelWorkflow(executionId);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowTemplatesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workflow Templates',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    MediaQuery.of(context).size.width > 1200 ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: _workflowDefinitions.length,
              itemBuilder: (context, index) {
                return WorkflowTemplateCard(
                  definition: _workflowDefinitions[index],
                  onStart: (workflowId) {
                    _startWorkflow(workflowId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workflow Analytics',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: WorkflowAnalyticsWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _showStartWorkflowDialog() {
    showDialog(
      context: context,
      builder: (context) => StartWorkflowDialog(
        workflowDefinitions: _workflowDefinitions,
        onStart: (workflowId, parameters) {
          _startWorkflow(workflowId, parameters);
        },
      ),
    );
  }

  void _startWorkflow(String workflowId, [Map<String, dynamic>? parameters]) {
    widget.automationService.startWorkflow(workflowId, parameters ?? {});
  }
}

/// Card widget for displaying workflow execution status
class WorkflowExecutionCard extends StatelessWidget {
  final WorkflowExecution execution;
  final Function(String) onCancel;

  const WorkflowExecutionCard({
    super.key,
    required this.execution,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    execution.workflowId.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _buildStatusChip(execution.status),
                if (execution.status == WorkflowStatus.running)
                  IconButton(
                    onPressed: () => onCancel(execution.id),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    tooltip: 'Cancel Workflow',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Execution ID: ${execution.id}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            _buildProgressIndicator(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${execution.currentStep} of ${execution.totalSteps}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  _formatDuration(execution.duration),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            if (execution.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Error: ${execution.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(WorkflowStatus status) {
    Color color;
    String label;

    switch (status) {
      case WorkflowStatus.running:
        color = Colors.blue;
        label = 'Running';
        break;
      case WorkflowStatus.completed:
        color = Colors.green;
        label = 'Completed';
        break;
      case WorkflowStatus.failed:
        color = Colors.red;
        label = 'Failed';
        break;
      case WorkflowStatus.cancelled:
        color = Colors.orange;
        label = 'Cancelled';
        break;
      case WorkflowStatus.pending:
        color = Colors.grey;
        label = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return LinearProgressIndicator(
      value: execution.progress,
      backgroundColor: Colors.grey[300],
      valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
    );
  }

  Color _getProgressColor() {
    switch (execution.status) {
      case WorkflowStatus.completed:
        return Colors.green;
      case WorkflowStatus.failed:
        return Colors.red;
      case WorkflowStatus.cancelled:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '';

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

/// Card widget for workflow template
class WorkflowTemplateCard extends StatelessWidget {
  final WorkflowDefinition definition;
  final Function(String) onStart;

  const WorkflowTemplateCard({
    super.key,
    required this.definition,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getCategoryIcon(definition.category), color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    definition.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              definition.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  definition.category,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.list, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${definition.steps.length} steps',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => onStart(definition.id),
                child: const Text('Start Workflow'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'inventory management':
        return Icons.inventory;
      case 'quality management':
        return Icons.verified;
      case 'procurement':
        return Icons.shopping_cart;
      default:
        return Icons.work;
    }
  }
}

/// Dialog for starting a new workflow
class StartWorkflowDialog extends StatefulWidget {
  final List<WorkflowDefinition> workflowDefinitions;
  final Function(String, Map<String, dynamic>) onStart;

  const StartWorkflowDialog({
    super.key,
    required this.workflowDefinitions,
    required this.onStart,
  });

  @override
  State<StartWorkflowDialog> createState() => _StartWorkflowDialogState();
}

class _StartWorkflowDialogState extends State<StartWorkflowDialog> {
  WorkflowDefinition? _selectedWorkflow;
  final Map<String, TextEditingController> _parameterControllers = {};

  @override
  void dispose() {
    for (final controller in _parameterControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start New Workflow'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Workflow:'),
            const SizedBox(height: 8),
            DropdownButton<WorkflowDefinition>(
              value: _selectedWorkflow,
              isExpanded: true,
              hint: const Text('Choose a workflow template'),
              items: widget.workflowDefinitions.map((workflow) {
                return DropdownMenuItem(
                  value: workflow,
                  child: Text(workflow.name),
                );
              }).toList(),
              onChanged: (workflow) {
                setState(() {
                  _selectedWorkflow = workflow;
                });
              },
            ),
            if (_selectedWorkflow != null) ...[
              const SizedBox(height: 16),
              Text(
                _selectedWorkflow!.description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              const Text('Parameters (optional):'),
              const SizedBox(height: 8),
              _buildParameterFields(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedWorkflow != null ? _startWorkflow : null,
          child: const Text('Start'),
        ),
      ],
    );
  }

  Widget _buildParameterFields() {
    // For now, show common parameters based on workflow category
    if (_selectedWorkflow!.category == 'Inventory Management') {
      return Column(
        children: [
          _buildParameterField('location', 'Location (optional)'),
          _buildParameterField('category', 'Category (optional)'),
        ],
      );
    } else if (_selectedWorkflow!.category == 'Quality Management') {
      return Column(
        children: [
          _buildParameterField('product_line', 'Product Line (optional)'),
          _buildParameterField('time_period', 'Time Period (optional)'),
        ],
      );
    } else {
      return const Text(
        'No additional parameters required',
        style: TextStyle(fontSize: 12),
      );
    }
  }

  Widget _buildParameterField(String key, String label) {
    _parameterControllers[key] ??= TextEditingController();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: _parameterControllers[key],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  void _startWorkflow() {
    final parameters = <String, dynamic>{};
    for (final entry in _parameterControllers.entries) {
      if (entry.value.text.isNotEmpty) {
        parameters[entry.key] = entry.value.text;
      }
    }

    widget.onStart(_selectedWorkflow!.id, parameters);
    Navigator.of(context).pop();
  }
}

/// Widget for workflow analytics
class WorkflowAnalyticsWidget extends StatelessWidget {
  const WorkflowAnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildAnalyticsCard(
          'Total Workflows',
          '247',
          Icons.work,
          Colors.blue,
          '+12% this month',
        ),
        _buildAnalyticsCard(
          'Success Rate',
          '94.2%',
          Icons.check_circle,
          Colors.green,
          '+2.1% this month',
        ),
        _buildAnalyticsCard(
          'Avg. Execution Time',
          '4.7 min',
          Icons.timer,
          Colors.orange,
          '-0.8 min this month',
        ),
        _buildAnalyticsCard(
          'Active Workflows',
          '12',
          Icons.play_circle,
          Colors.purple,
          'Currently running',
        ),
        _buildAnalyticsCard(
          'Cost Savings',
          '\$47,250',
          Icons.savings,
          Colors.teal,
          '+18% this month',
        ),
        _buildAnalyticsCard(
          'Error Rate',
          '2.1%',
          Icons.error,
          Colors.red,
          '-0.5% this month',
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
      String title, String value, IconData icon, Color color, String trend) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  trend,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
