import 'package:flutter/material.dart';
import '../../../production/domain/models/production_execution_model.dart';

/// Widget to display action buttons based on the current production execution status
class ProductionActionButton extends StatelessWidget {
  const ProductionActionButton({
    super.key,
    required this.status,
    required this.onActionPressed,
    this.onSecondaryActionPressed,
    this.actionLabel,
    this.secondaryActionLabel,
    this.actionIcon,
    this.secondaryActionIcon,
  });

  /// Current status of the production execution
  final ProductionExecutionStatus status;

  /// Function to call when the primary action is pressed
  final VoidCallback onActionPressed;

  /// Function to call when the secondary action is pressed
  final VoidCallback? onSecondaryActionPressed;

  /// Optional label override for the primary button
  final String? actionLabel;

  /// Optional label override for the secondary button
  final String? secondaryActionLabel;

  /// Optional icon override for the primary button
  final IconData? actionIcon;

  /// Optional icon override for the secondary button
  final IconData? secondaryActionIcon;

  @override
  Widget build(BuildContext context) {
    // Define button properties based on current status
    String primaryLabel = actionLabel ?? _getPrimaryActionLabel();
    String? secondaryLabel = secondaryActionLabel ?? _getSecondaryActionLabel();
    IconData primaryIcon = actionIcon ?? _getPrimaryActionIcon();
    IconData? secondaryIcon = secondaryActionIcon ?? _getSecondaryActionIcon();
    Color primaryColor = _getPrimaryActionColor();
    Color? secondaryColor = _getSecondaryActionColor();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(primaryIcon),
            label: Text(primaryLabel),
            onPressed: onActionPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        if (secondaryLabel != null && onSecondaryActionPressed != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(secondaryIcon),
                label: Text(secondaryLabel),
                onPressed: onSecondaryActionPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: secondaryColor,
                  side: BorderSide(color: secondaryColor ?? Colors.grey),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Returns the appropriate label for the primary action button based on status
  String _getPrimaryActionLabel() {
    switch (status) {
      case ProductionExecutionStatus.planned:
        return 'Start Production';
      case ProductionExecutionStatus.inProgress:
        return 'Complete Production';
      case ProductionExecutionStatus.paused:
        return 'Resume Production';
      case ProductionExecutionStatus.completed:
        return 'View Production Report';
      case ProductionExecutionStatus.failed:
        return 'Review Issues';
      case ProductionExecutionStatus.cancelled:
        return 'Review Details';
    }
  }

  /// Returns the appropriate label for the secondary action button based on status
  String? _getSecondaryActionLabel() {
    switch (status) {
      case ProductionExecutionStatus.planned:
        return 'Reschedule';
      case ProductionExecutionStatus.inProgress:
        return 'Pause Production';
      case ProductionExecutionStatus.paused:
        return 'Cancel Production';
      case ProductionExecutionStatus.completed:
        return 'Start New Batch';
      case ProductionExecutionStatus.failed:
        return 'Try Again';
      case ProductionExecutionStatus.cancelled:
        return null;
    }
  }

  /// Returns the appropriate icon for the primary action button based on status
  IconData _getPrimaryActionIcon() {
    switch (status) {
      case ProductionExecutionStatus.planned:
        return Icons.play_arrow;
      case ProductionExecutionStatus.inProgress:
        return Icons.check;
      case ProductionExecutionStatus.paused:
        return Icons.play_arrow;
      case ProductionExecutionStatus.completed:
        return Icons.summarize;
      case ProductionExecutionStatus.failed:
        return Icons.error_outline;
      case ProductionExecutionStatus.cancelled:
        return Icons.info_outline;
    }
  }

  /// Returns the appropriate icon for the secondary action button based on status
  IconData? _getSecondaryActionIcon() {
    switch (status) {
      case ProductionExecutionStatus.planned:
        return Icons.calendar_month;
      case ProductionExecutionStatus.inProgress:
        return Icons.pause;
      case ProductionExecutionStatus.paused:
        return Icons.cancel;
      case ProductionExecutionStatus.completed:
        return Icons.add;
      case ProductionExecutionStatus.failed:
        return Icons.refresh;
      case ProductionExecutionStatus.cancelled:
        return null;
    }
  }

  /// Returns the appropriate color for the primary action button based on status
  Color _getPrimaryActionColor() {
    switch (status) {
      case ProductionExecutionStatus.planned:
        return Colors.green;
      case ProductionExecutionStatus.inProgress:
        return Colors.blue;
      case ProductionExecutionStatus.paused:
        return Colors.green;
      case ProductionExecutionStatus.completed:
        return Colors.indigo;
      case ProductionExecutionStatus.failed:
        return Colors.red.shade700;
      case ProductionExecutionStatus.cancelled:
        return Colors.grey.shade700;
    }
  }

  /// Returns the appropriate color for the secondary action button based on status
  Color? _getSecondaryActionColor() {
    switch (status) {
      case ProductionExecutionStatus.planned:
        return Colors.orange;
      case ProductionExecutionStatus.inProgress:
        return Colors.amber.shade700;
      case ProductionExecutionStatus.paused:
        return Colors.red;
      case ProductionExecutionStatus.completed:
        return Colors.green;
      case ProductionExecutionStatus.failed:
        return Colors.blue;
      case ProductionExecutionStatus.cancelled:
        return Colors.grey.shade700;
    }
  }
}
