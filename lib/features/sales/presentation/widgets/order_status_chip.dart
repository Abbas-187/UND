import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';

class OrderStatusChip extends StatelessWidget {

  const OrderStatusChip({
    super.key,
    required this.status,
    this.miniSize = false,
  });
  final OrderStatus status;
  final bool miniSize;

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
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _getStatusText(status);
    final backgroundColor = _getStatusColor(status);

    return Chip(
      label: Text(
        statusText,
        style: TextStyle(
          color: Colors.white,
          fontSize: miniSize ? 10 : 12,
        ),
      ),
      backgroundColor: backgroundColor,
      padding: EdgeInsets.symmetric(
        horizontal: miniSize ? 4 : 8,
        vertical: miniSize ? 0 : 2,
      ),
      labelPadding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
