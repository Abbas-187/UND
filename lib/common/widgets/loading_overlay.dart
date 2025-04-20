import 'package:flutter/material.dart';

/// A widget that shows a loading overlay when isLoading is true.
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color? backgroundColor;
  final Color? progressColor;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.backgroundColor,
    this.progressColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressColor ?? Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
