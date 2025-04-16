import 'package:flutter/material.dart';

/// A reusable error state widget for consistent error handling across the app
class AppErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String retryText;

  const AppErrorWidget({
    Key? key,
    this.title = 'Error',
    required this.message,
    this.icon = Icons.error_outline,
    this.onRetry,
    this.retryText = 'Retry',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 56.0,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24.0),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A reusable empty state widget for consistent empty state handling
class AppEmptyWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String actionText;

  const AppEmptyWidget({
    Key? key,
    this.title = 'No Data',
    required this.message,
    this.icon = Icons.hourglass_empty,
    this.onAction,
    this.actionText = 'Add New',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 56.0,
              color: theme.disabledColor,
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: 24.0),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A reusable loading widget for consistent loading states across the app
class AppLoadingWidget extends StatelessWidget {
  final String message;
  final bool showText;
  final double size;
  final double strokeWidth;
  final Color? color;

  const AppLoadingWidget({
    Key? key,
    this.message = 'Loading...',
    this.showText = true,
    this.size = 40.0,
    this.strokeWidth = 4.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loadingColor = color ?? theme.primaryColor;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
            ),
          ),
          if (showText) ...[
            const SizedBox(height: 16.0),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
