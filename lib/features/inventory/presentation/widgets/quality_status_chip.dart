import 'package:flutter/material.dart';

class QualityStatusChip extends StatelessWidget {
  const QualityStatusChip({super.key, this.status});
  final String? status;

  Color _getColor(String? status) {
    switch (status) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.lightGreen;
      case 'acceptable':
        return Colors.blue;
      case 'warning':
        return Colors.orange;
      case 'critical':
        return Colors.redAccent;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status ?? 'Unknown'),
      backgroundColor: _getColor(status),
      labelStyle: const TextStyle(color: Colors.white),
    );
  }
}
