import 'package:flutter/material.dart';

/// Widget for displaying errors in a user-friendly way
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.icon = Icons.error_outline,
    this.iconColor,
    this.onRetry,
  });

  /// Error message to display
  final String message;

  /// Icon to show with the error
  final IconData icon;

  /// Color for the error icon
  final Color? iconColor;

  /// Optional callback to retry the operation
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = iconColor ?? theme.colorScheme.error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: errorColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
