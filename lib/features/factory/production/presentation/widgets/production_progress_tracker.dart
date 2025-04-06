import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../production/domain/models/production_execution_model.dart';

/// Widget to display production progress metrics in visual format
class ProductionProgressTracker extends StatelessWidget {

  const ProductionProgressTracker({
    super.key,
    required this.targetQuantity,
    required this.actualQuantity,
    required this.unitOfMeasure,
    required this.expectedYield,
    this.actualYield,
    required this.scheduledDate,
    this.startTime,
    this.endTime,
    required this.status,
  });
  /// The target quantity to be produced
  final double targetQuantity;

  /// The actual quantity produced so far
  final double actualQuantity;

  /// Unit of measure
  final String unitOfMeasure;

  /// Expected production yield
  final double expectedYield;

  /// Actual production yield
  final double? actualYield;

  /// Scheduled start time
  final DateTime scheduledDate;

  /// Actual start time (if production has started)
  final DateTime? startTime;

  /// Actual end time (if production has completed)
  final DateTime? endTime;

  /// Current production status
  final ProductionExecutionStatus status;

  @override
  Widget build(BuildContext context) {
    // Calculate percentage completion
    final double completionPercentage = actualQuantity / targetQuantity;
    final bool isCompleted = status == ProductionExecutionStatus.completed;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Production Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Quantity progress
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quantity Progress',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      LinearPercentIndicator(
                        lineHeight: 18.0,
                        percent: completionPercentage.clamp(0.0, 1.0),
                        center: Text(
                          '${(completionPercentage * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        barRadius: const Radius.circular(8),
                        progressColor: _getProgressColor(completionPercentage),
                        backgroundColor: Colors.grey.shade200,
                        animation: true,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${actualQuantity.toStringAsFixed(1)} of ${targetQuantity.toStringAsFixed(1)} $unitOfMeasure',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Yield Efficiency',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularPercentIndicator(
                            radius: 35.0,
                            lineWidth: 8.0,
                            percent: actualYield != null && expectedYield > 0
                                ? (actualYield! / expectedYield).clamp(0.0, 1.0)
                                : 0.0,
                            center: Text(
                              actualYield != null && expectedYield > 0
                                  ? '${((actualYield! / expectedYield) * 100).toStringAsFixed(0)}%'
                                  : 'N/A',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            progressColor: actualYield != null
                                ? _getYieldColor(actualYield! / expectedYield)
                                : Colors.grey,
                            backgroundColor: Colors.grey.shade200,
                            animation: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Time progress
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTimeInfo(
                    'Start',
                    startTime ?? scheduledDate,
                    startTime != null,
                    isScheduled: startTime == null,
                  ),
                ),
                Expanded(
                  child: _buildTimeInfo(
                    'End',
                    endTime ?? _calculateExpectedEndTime(),
                    endTime != null,
                    isScheduled: endTime == null,
                  ),
                ),
                Expanded(
                  child: _buildDurationInfo(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, DateTime time, bool isActual,
      {bool isScheduled = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          _formatDateTime(time),
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActual ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        Text(
          isScheduled ? 'Scheduled' : 'Actual',
          style: TextStyle(
            fontSize: 12,
            color: isActual ? Colors.green.shade700 : Colors.grey.shade600,
            fontStyle: isScheduled ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildDurationInfo() {
    Duration actualDuration = Duration.zero;
    String durationLabel = 'Estimated Duration';

    if (startTime != null && endTime != null) {
      actualDuration = endTime!.difference(startTime!);
      durationLabel = 'Actual Duration';
    } else if (startTime != null) {
      actualDuration = DateTime.now().difference(startTime!);
      durationLabel = 'Current Duration';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          durationLabel,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          _formatDuration(actualDuration),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Format datetime for display
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Format duration for display
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return '$hours hrs $minutes min';
  }

  // Calculate expected end time based on scheduled date and estimated duration
  DateTime _calculateExpectedEndTime() {
    // Placeholder calculation - in a real app this would use production rate data
    return scheduledDate.add(const Duration(hours: 8));
  }

  // Get appropriate color based on progress percentage
  Color _getProgressColor(double percentage) {
    if (percentage >= 1.0) return Colors.green.shade700;
    if (percentage >= 0.75) return Colors.green;
    if (percentage >= 0.5) return Colors.amber;
    return Colors.orange;
  }

  // Get appropriate color for yield efficiency
  Color _getYieldColor(double efficiency) {
    if (efficiency >= 0.95) return Colors.green.shade700;
    if (efficiency >= 0.85) return Colors.green;
    if (efficiency >= 0.75) return Colors.amber;
    return Colors.orange;
  }
}
