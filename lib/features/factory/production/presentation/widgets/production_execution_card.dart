import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../production/domain/models/production_execution_model.dart';
import 'production_status_badge.dart';

/// A card widget that displays key information about a production execution
class ProductionExecutionCard extends ConsumerWidget {

  const ProductionExecutionCard({
    super.key,
    required this.execution,
    this.onTap,
    this.onStart,
    this.onPause,
    this.onResume,
    this.onComplete,
    this.showDetails = false,
  });
  /// The production execution model to display
  final ProductionExecutionModel execution;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Callback for starting a production execution
  final void Function(String id)? onStart;

  /// Callback for pausing a production execution
  final void Function(String id)? onPause;

  /// Callback for resuming a production execution
  final void Function(String id)? onResume;

  /// Callback for completing a production execution
  final void Function(String id)? onComplete;

  /// Whether to show detailed information
  final bool showDetails;

  /// Calculate the progress percentage of the execution
  double _calculateProgress() {
    // If completed or cancelled, use the actual yield vs target
    if (execution.status == ProductionExecutionStatus.completed) {
      if (execution.actualYield != null && execution.targetQuantity > 0) {
        return (execution.actualYield! / execution.targetQuantity)
            .clamp(0.0, 1.0);
      }
      return 1.0; // Assume 100% if completed but no data
    }

    // If cancelled or failed, use whatever progress was made
    if (execution.status == ProductionExecutionStatus.cancelled ||
        execution.status == ProductionExecutionStatus.failed) {
      if (execution.actualYield != null && execution.targetQuantity > 0) {
        return (execution.actualYield! / execution.targetQuantity)
            .clamp(0.0, 1.0);
      }
      return 0.0; // Assume 0% if cancelled/failed but no data
    }

    // If planned, no progress yet
    if (execution.status == ProductionExecutionStatus.planned) {
      return 0.0;
    }

    // For in-progress or paused, use a time-based estimate if we don't have actual yield
    if (execution.actualYield != null && execution.targetQuantity > 0) {
      return (execution.actualYield! / execution.targetQuantity)
          .clamp(0.0, 1.0);
    } else if (execution.startTime != null) {
      // Rough estimate based on time elapsed vs expected duration
      final now = DateTime.now();
      final start = execution.startTime!;
      final scheduledEnd = start
          .add(const Duration(hours: 8)); // Assuming 8-hour production runs
      final totalDuration = scheduledEnd.difference(start).inMinutes;
      final elapsed = now.difference(start).inMinutes;

      if (totalDuration > 0) {
        return (elapsed / totalDuration).clamp(0.0, 1.0);
      }
    }

    // Default fallback
    return 0.3; // Arbitrary progress indicator for in-progress items
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final progress = _calculateProgress();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with product name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      execution.productName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ProductionStatusBadge(status: execution.status),
                ],
              ),

              const SizedBox(height: 8),

              // Batch number and production line
              Row(
                children: [
                  Icon(Icons.tag, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Batch: ${execution.batchNumber}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Icon(Icons.precision_manufacturing,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      execution.productionLineName,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Date information
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Scheduled: ${dateFormat.format(execution.scheduledDate)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),

              // Show start/end times if available
              if (execution.startTime != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.play_circle_outline,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Started: ${timeFormat.format(execution.startTime!)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (execution.endTime != null) ...[
                      const Spacer(),
                      Icon(Icons.stop_circle_outlined,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Ended: ${timeFormat.format(execution.endTime!)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Progress indicator
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  execution.status == ProductionExecutionStatus.completed
                      ? Colors.indigo
                      : execution.status == ProductionExecutionStatus.inProgress
                          ? Colors.green
                          : execution.status == ProductionExecutionStatus.paused
                              ? Colors.amber
                              : Colors.grey,
                ),
              ),

              const SizedBox(height: 4),

              // Target quantity and progress text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Target: ${execution.targetQuantity} ${execution.unitOfMeasure}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    execution.actualYield != null
                        ? 'Progress: ${execution.actualYield?.toStringAsFixed(1)} ${execution.unitOfMeasure}'
                        : 'Progress: ${(progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),

              // Show action buttons only for active executions
              if ((execution.status == ProductionExecutionStatus.inProgress &&
                      onPause != null) ||
                  (execution.status == ProductionExecutionStatus.paused &&
                      onResume != null) ||
                  onComplete != null) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Toggle pause/resume button
                    if ((execution.status ==
                                ProductionExecutionStatus.inProgress &&
                            onPause != null) ||
                        (execution.status == ProductionExecutionStatus.paused &&
                            onResume != null)) ...[
                      _ActionButton(
                        icon:
                            execution.status == ProductionExecutionStatus.paused
                                ? Icons.play_arrow
                                : Icons.pause,
                        label:
                            execution.status == ProductionExecutionStatus.paused
                                ? 'Resume'
                                : 'Pause',
                        onTap: () {
                          if (execution.status ==
                              ProductionExecutionStatus.paused) {
                            if (onResume != null) onResume!(execution.id);
                          } else {
                            if (onPause != null) onPause!(execution.id);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Complete button
                    if (onComplete != null)
                      _ActionButton(
                        icon: Icons.check_circle,
                        label: 'Complete',
                        color: Colors.green,
                        onTap: () {
                          onComplete!(execution.id);
                        },
                      ),
                  ],
                ),
              ],

              // Show start button for planned executions
              if (execution.status == ProductionExecutionStatus.planned &&
                  onStart != null) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ActionButton(
                      icon: Icons.play_arrow,
                      label: 'Start',
                      color: Colors.green,
                      onTap: () {
                        onStart!(execution.id);
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper widget for action buttons
class _ActionButton extends StatelessWidget {

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: color ?? Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color ?? Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
