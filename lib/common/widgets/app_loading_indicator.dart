import 'package:flutter/material.dart';

/// Loading indicator for various parts of the app
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.size = 40.0,
    this.color,
    this.strokeWidth = 4.0,
    this.message,
  });

  /// Size of the indicator
  final double size;

  /// Color of the indicator (defaults to primary color)
  final Color? color;

  /// Width of the circular stroke
  final double strokeWidth;

  /// Optional loading message to display
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              valueColor:
                  color != null ? AlwaysStoppedAnimation<Color>(color!) : null,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
