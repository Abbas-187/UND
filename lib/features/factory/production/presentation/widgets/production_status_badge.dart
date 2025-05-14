import 'package:flutter/material.dart';
import '../../../production/domain/models/production_execution_model.dart';

/// A widget that displays the status of a production execution as a colored badge
class ProductionStatusBadge extends StatelessWidget {
  const ProductionStatusBadge({
    super.key,
    required this.status,
    this.mini = false,
  });

  /// The status to display
  final ProductionExecutionStatus status;

  /// Whether to use a smaller size for compact layouts
  final bool mini;

  /// Get the appropriate color for the status
  Color _getStatusColor() {
    switch (status) {
      case ProductionExecutionStatus.planned:
        return Colors.blue.shade300;
      case ProductionExecutionStatus.inProgress:
        return Colors.green;
      case ProductionExecutionStatus.completed:
        return Colors.indigo;
      case ProductionExecutionStatus.paused:
        return Colors.amber;
      case ProductionExecutionStatus.cancelled:
        return Colors.red;
      case ProductionExecutionStatus.failed:
        return Colors.deepOrange;
    }
  }

  /// Get a user-friendly text for the status
  String _getStatusText() {
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

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final text = _getStatusText();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: mini ? 6.0 : 8.0,
        vertical: mini ? 2.0 : 4.0,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: mini ? 10 : 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
