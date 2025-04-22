import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getStatusColor()),
      ),
      child: Text(
        _formatStatus(status),
        style: TextStyle(
          color: _getStatusColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatStatus(String statusString) {
    // Convert camelCase to Title Case
    final result = statusString.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );

    return result.trim().capitalize();
  }

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'inprogress':
        return Colors.blue;
      case 'delivered':
        return Colors.indigo;
      case 'completed':
        return Colors.teal;
      case 'canceled':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }
}

// Extension to capitalize first letter of a string
extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
