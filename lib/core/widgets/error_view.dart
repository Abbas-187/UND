import 'package:flutter/material.dart';

/// A widget that displays an error with a retry button
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconSize = 48.0,
    this.iconColor,
    this.retryButtonText = 'Retry',
  });

  /// The error message to display
  final String error;

  /// Optional callback function to retry the operation
  final VoidCallback? onRetry;

  /// The icon to display
  final IconData icon;

  /// The size of the icon
  final double iconSize;

  /// The color of the icon. Defaults to theme's error color
  final Color? iconColor;

  /// The text for the retry button
  final String retryButtonText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? theme.colorScheme.error,
            ),
            const SizedBox(height: 16.0),
            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24.0),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryButtonText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
