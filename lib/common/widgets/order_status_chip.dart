import 'package:flutter/material.dart';
import '../../features/sales/data/models/order_model.dart'; // Import OrderStatus enum

class OrderStatusChip extends StatelessWidget {

  const OrderStatusChip({super.key, required this.status});
  final OrderStatus status;

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return Colors.grey;
      case OrderStatus.pendingApproval:
        return Colors.orange.shade300;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.shipped:
      case OrderStatus.partiallyShipped:
        return Colors.teal;
      case OrderStatus.delivered:
        return Colors.cyan;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.onHold:
        return Colors.yellow.shade700;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(OrderStatus status) {
    // Convert enum name to title case (e.g., pendingApproval -> Pending Approval)
    final words = status.name
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .split(' ');
    return words
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        _getStatusText(status),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: _getStatusColor(status),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      labelPadding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
