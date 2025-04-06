import 'package:flutter/material.dart';

/// A widget that displays a loading indicator over its child when [isLoading] is true.
/// Used to provide a consistent loading experience across the app.
class LoadingOverlay extends StatelessWidget {

  /// Creates a [LoadingOverlay] widget.
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.color,
    this.opacity = 0.5,
  });
  /// Whether to show the loading indicator
  final bool isLoading;

  /// The widget to display under the loading indicator
  final Widget child;

  /// Optional custom color for the loading indicator
  final Color? color;

  /// Optional custom opacity for the loading overlay background
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        child,

        // Conditional loading overlay
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(opacity),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    color ?? Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
