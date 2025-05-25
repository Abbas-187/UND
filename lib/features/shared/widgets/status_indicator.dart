import 'package:flutter/material.dart';

/// A reusable status indicator widget for showing active/inactive states
class StatusIndicator extends StatelessWidget {
  const StatusIndicator({
    super.key,
    required this.isActive,
    this.size = 12.0,
    this.activeColor,
    this.inactiveColor,
  });

  final bool isActive;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive
        ? (activeColor ?? Colors.green)
        : (inactiveColor ?? Colors.grey);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
