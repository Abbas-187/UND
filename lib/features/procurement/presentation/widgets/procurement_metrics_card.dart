import 'package:flutter/material.dart';

class ProcurementMetricsCard extends StatelessWidget {
  const ProcurementMetricsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.tooltip,
    this.onTap,
    this.isLoading = false,
    this.errorMessage,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final String? tooltip;
  final VoidCallback? onTap;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget content;
    if (isLoading) {
      content = const Center(child: CircularProgressIndicator(strokeWidth: 2));
    } else if (errorMessage != null && errorMessage!.isNotEmpty) {
      content = Center(
        child: Text(
          errorMessage!,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      content = Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1 * 255),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    if (tooltip != null)
                      Tooltip(
                        message: tooltip!,
                        child: const Icon(Icons.info_outline, size: 16),
                      ),
                  ],
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    value.isNotEmpty ? value : '-',
                    key: ValueKey(value),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Semantics(
      label: title,
      value: value,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
