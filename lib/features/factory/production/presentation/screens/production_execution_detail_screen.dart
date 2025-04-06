import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../production/domain/models/production_execution_model.dart';
import '../widgets/material_consumption_table.dart';
import '../widgets/production_action_button.dart';
import '../widgets/production_progress_tracker.dart';
import '../widgets/production_status_badge.dart';

// Temporary provider until Riverpod code generation is run
final tempProductionExecutionDetailProvider =
    StreamProvider.family<ProductionExecutionModel, String>((ref, id) {
  // This is a placeholder and should be replaced with the actual generated provider
  return Stream.value(
    ProductionExecutionModel(
      id: id,
      batchNumber: 'BATCH-001',
      productionOrderId: 'PO-001',
      scheduledDate: DateTime.now(),
      productId: 'PROD-001',
      productName: 'Dairy Product A',
      targetQuantity: 1000.0,
      unitOfMeasure: 'kg',
      status: ProductionExecutionStatus.inProgress,
      startTime: DateTime.now().subtract(const Duration(hours: 2)),
      endTime: null,
      productionLineId: 'LINE-001',
      productionLineName: 'Processing Line 1',
      assignedPersonnel: [
        AssignedPersonnel(
          personnelId: 'P001',
          personnelName: 'John Doe',
          role: 'Line Operator',
          assignedStartTime: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        AssignedPersonnel(
          personnelId: 'P002',
          personnelName: 'Jane Smith',
          role: 'Quality Inspector',
          assignedStartTime: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
      materials: [
        MaterialUsage(
          materialId: 'MAT-001',
          materialName: 'Raw Milk',
          plannedQuantity: 800.0,
          actualQuantity: 815.0,
          unitOfMeasure: 'L',
          batchNumber: 'RM-001',
        ),
        MaterialUsage(
          materialId: 'MAT-002',
          materialName: 'Starter Culture',
          plannedQuantity: 2.0,
          actualQuantity: 2.0,
          unitOfMeasure: 'kg',
          batchNumber: 'SC-001',
        ),
        MaterialUsage(
          materialId: 'MAT-003',
          materialName: 'Sugar',
          plannedQuantity: 50.0,
          actualQuantity: 48.5,
          unitOfMeasure: 'kg',
          batchNumber: 'SUG-001',
        ),
      ],
      expectedYield: 950.0,
      actualYield: 625.0,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      createdBy: 'admin',
      updatedAt: DateTime.now(),
      updatedBy: 'admin',
      notes: 'Production proceeding according to plan',
    ),
  );
});

/// Detailed screen for a specific production execution
class ProductionExecutionDetailScreen extends ConsumerStatefulWidget {

  const ProductionExecutionDetailScreen({
    super.key,
    required this.executionId,
  });
  /// Route name for navigation
  static const routeName = '/production-execution-detail';

  /// ID of the production execution to display
  final String executionId;

  @override
  ConsumerState<ProductionExecutionDetailScreen> createState() =>
      _ProductionExecutionDetailScreenState();
}

class _ProductionExecutionDetailScreenState
    extends ConsumerState<ProductionExecutionDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _notesController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the execution details
    final executionAsync =
        ref.watch(tempProductionExecutionDetailProvider(widget.executionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Execution Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh data
              ref.invalidate(
                  tempProductionExecutionDetailProvider(widget.executionId));
            },
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle menu selection
              switch (value) {
                case 'export_pdf':
                  // Export to PDF logic
                  break;
                case 'share':
                  // Share logic
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf),
                    SizedBox(width: 8),
                    Text('Export to PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: executionAsync.when(
        data: (execution) {
          // Set notes text
          if (_notesController.text.isEmpty && execution.notes != null) {
            _notesController.text = execution.notes!;
          }

          return Column(
            children: [
              // Header with basic details
              _buildHeader(execution),

              // Tab bar
              ColoredBox(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Quality'),
                    Tab(text: 'Timeline'),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Overview tab
                    _buildOverviewTab(execution),

                    // Quality tab
                    _buildQualityTab(execution),

                    // Timeline tab
                    _buildTimelineTab(execution),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: executionAsync.when(
        data: (execution) => Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ProductionActionButton(
            status: execution.status,
            onActionPressed: () {
              // Primary action handler
              _handlePrimaryAction(execution);
            },
            onSecondaryActionPressed: () {
              // Secondary action handler
              _handleSecondaryAction(execution);
            },
          ),
        ),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildHeader(ProductionExecutionModel execution) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product details row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      execution.productName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Batch: ${execution.batchNumber}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              ProductionStatusBadge(status: execution.status),
            ],
          ),

          const SizedBox(height: 12),

          // Info chips row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                Icons.calendar_today,
                DateFormat('dd MMM yyyy').format(execution.scheduledDate),
              ),
              _buildInfoChip(
                Icons.category,
                '${execution.targetQuantity} ${execution.unitOfMeasure}',
              ),
              _buildInfoChip(
                Icons.engineering,
                execution.productionLineName,
              ),
              if (execution.assignedPersonnel.isNotEmpty)
                _buildInfoChip(
                  Icons.people,
                  '${execution.assignedPersonnel.length} Personnel',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ProductionExecutionModel execution) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      children: [
        // Progress tracker
        ProductionProgressTracker(
          targetQuantity: execution.targetQuantity,
          actualQuantity: execution.actualYield ?? 0.0,
          unitOfMeasure: execution.unitOfMeasure,
          expectedYield: execution.expectedYield,
          actualYield: execution.actualYield,
          scheduledDate: execution.scheduledDate,
          startTime: execution.startTime,
          endTime: execution.endTime,
          status: execution.status,
        ),

        // Materials section
        MaterialConsumptionTable(
          materials: execution.materials,
          allowEditing:
              execution.status == ProductionExecutionStatus.inProgress,
          onMaterialUpdated: (materialId, newQuantity) {
            // Update material quantity logic
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Updated material $materialId to $newQuantity')),
            );
          },
        ),

        // Notes section
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Production Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Add notes about the production...',
                    border: OutlineInputBorder(),
                  ),
                  enabled: execution.status !=
                          ProductionExecutionStatus.completed &&
                      execution.status != ProductionExecutionStatus.cancelled,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: execution.status !=
                                ProductionExecutionStatus.completed &&
                            execution.status !=
                                ProductionExecutionStatus.cancelled
                        ? () {
                            // Save notes logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Notes saved')),
                            );
                          }
                        : null,
                    child: const Text('Save Notes'),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Personnel section
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assigned Personnel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...execution.assignedPersonnel.map((personnel) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(Icons.person, color: Colors.blue),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  personnel.personnelName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  personnel.role,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Since ${DateFormat('HH:mm').format(personnel.assignedStartTime)}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )),
                if (execution.status == ProductionExecutionStatus.inProgress)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text('Assign Personnel'),
                      onPressed: () {
                        // Assign personnel logic
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQualityTab(ProductionExecutionModel execution) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Quality status
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quality Assessment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                execution.qualityRating != null
                    ? _buildQualityRating(execution.qualityRating!)
                    : const Center(
                        child: Text(
                          'No quality assessment yet',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
                // Quality notes
                if (execution.qualityNotes != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quality Notes:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(execution.qualityNotes!),
                      ],
                    ),
                  ),
                // Quality check button
                if (execution.status == ProductionExecutionStatus.inProgress)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Record Quality Check'),
                        onPressed: () {
                          // Record quality check logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Quality parameters section - placeholder for detailed quality metrics
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quality Parameters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // This would be replaced with actual quality parameters
                _buildQualityParameter('pH Value', '6.8', '6.6-7.0'),
                _buildQualityParameter('Fat Content', '3.5%', '3.2-3.7%'),
                _buildQualityParameter('Protein', '4.2%', '4.0-4.5%'),
                _buildQualityParameter('Temperature', '6.2°C', '4.0-8.0°C'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQualityParameter(
      String name, String value, String acceptableRange) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Range: $acceptableRange',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityRating(QualityRating rating) {
    Color ratingColor;
    String ratingText;
    IconData ratingIcon;

    switch (rating) {
      case QualityRating.excellent:
        ratingColor = Colors.green.shade800;
        ratingText = 'Excellent';
        ratingIcon = Icons.star;
        break;
      case QualityRating.good:
        ratingColor = Colors.green;
        ratingText = 'Good';
        ratingIcon = Icons.thumb_up;
        break;
      case QualityRating.acceptable:
        ratingColor = Colors.blue;
        ratingText = 'Acceptable';
        ratingIcon = Icons.check_circle;
        break;
      case QualityRating.belowStandard:
        ratingColor = Colors.orange;
        ratingText = 'Below Standard';
        ratingIcon = Icons.warning;
        break;
      case QualityRating.poor:
        ratingColor = Colors.red;
        ratingText = 'Poor';
        ratingIcon = Icons.error_outline;
        break;
      case QualityRating.rejected:
        ratingColor = Colors.red.shade900;
        ratingText = 'Rejected';
        ratingIcon = Icons.cancel;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ratingColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ratingColor),
      ),
      child: Column(
        children: [
          Icon(ratingIcon, color: ratingColor, size: 48),
          const SizedBox(height: 8),
          Text(
            ratingText,
            style: TextStyle(
              color: ratingColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTab(ProductionExecutionModel execution) {
    // Create a list of timeline events
    final List<Map<String, dynamic>> timelineEvents = [
      {
        'time': execution.createdAt,
        'title': 'Production Planned',
        'description': 'Production execution created and scheduled',
        'icon': Icons.event,
        'color': Colors.blue,
      },
    ];

    if (execution.startTime != null) {
      timelineEvents.add({
        'time': execution.startTime!,
        'title': 'Production Started',
        'description': 'Production execution was started',
        'icon': Icons.play_arrow,
        'color': Colors.green,
      });
    }

    // Add sample events - in a real app these would come from the database
    timelineEvents.add({
      'time': DateTime.now().subtract(const Duration(hours: 1)),
      'title': 'Materials Added',
      'description': 'All raw materials have been added to the production line',
      'icon': Icons.add_circle,
      'color': Colors.amber,
    });

    if (execution.endTime != null) {
      timelineEvents.add({
        'time': execution.endTime!,
        'title': 'Production Completed',
        'description': 'Production execution successfully completed',
        'icon': Icons.check_circle,
        'color': Colors.indigo,
      });
    }

    // Sort events by time, newest first
    timelineEvents.sort(
        (a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Production Timeline',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...timelineEvents.asMap().entries.map((entry) {
                  final index = entry.key;
                  final event = entry.value;
                  final isLast = index == timelineEvents.length - 1;

                  return _buildTimelineEvent(
                    time: event['time'] as DateTime,
                    title: event['title'] as String,
                    description: event['description'] as String,
                    icon: event['icon'] as IconData,
                    color: event['color'] as Color,
                    isLast: isLast,
                  );
                }),

                // Add event button
                if (execution.status == ProductionExecutionStatus.inProgress)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 24.0),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Event'),
                      onPressed: () {
                        // Add event logic
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineEvent({
    required DateTime time,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: color,
              child: Icon(icon, size: 14, color: Colors.white),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(time),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handlePrimaryAction(ProductionExecutionModel execution) {
    String message = '';

    switch (execution.status) {
      case ProductionExecutionStatus.planned:
        message = 'Starting production...';
        break;
      case ProductionExecutionStatus.inProgress:
        message = 'Completing production...';
        break;
      case ProductionExecutionStatus.paused:
        message = 'Resuming production...';
        break;
      case ProductionExecutionStatus.completed:
        message = 'Opening production report...';
        break;
      case ProductionExecutionStatus.failed:
        message = 'Reviewing production issues...';
        break;
      case ProductionExecutionStatus.cancelled:
        message = 'Viewing production details...';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleSecondaryAction(ProductionExecutionModel execution) {
    String message = '';

    switch (execution.status) {
      case ProductionExecutionStatus.planned:
        message = 'Rescheduling production...';
        break;
      case ProductionExecutionStatus.inProgress:
        message = 'Pausing production...';
        break;
      case ProductionExecutionStatus.paused:
        message = 'Cancelling production...';
        break;
      case ProductionExecutionStatus.completed:
        message = 'Starting new batch...';
        break;
      case ProductionExecutionStatus.failed:
        message = 'Retrying production...';
        break;
      default:
        message = 'Action not available';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
