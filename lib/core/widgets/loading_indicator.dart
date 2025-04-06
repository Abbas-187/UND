import 'package:flutter/material.dart';

/// A simple loading indicator widget
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.color,
    this.size = 40.0,
    this.strokeWidth = 4.0,
  });

  /// The color of the indicator. Defaults to theme's primary color
  final Color? color;

  /// The size of the indicator
  final double size;

  /// The stroke width of the indicator
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? Theme.of(context).primaryColor,
          ),
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}
