import 'package:flutter/material.dart';

/// A widget that displays a loading indicator over its child when [isLoading] is true.
class LoadingOverlay extends StatelessWidget {
  /// Whether to show the loading indicator
  final bool isLoading;

  /// The widget to display under the loading indicator
  final Widget child;

  /// Optional color for the loading indicator background
  final Color? color;

  /// Optional opacity for the loading indicator background
  final double opacity;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.color,
    this.opacity = 0.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: Container(
                color: (color ?? Colors.black).withOpacity(opacity),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
