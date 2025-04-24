import 'package:flutter/material.dart';

/// A widget that renders different layouts based on screen size.
/// Use this widget to create responsive layouts for mobile, tablet, and desktop.
class ResponsiveBuilder extends StatelessWidget {
  /// Widget to display on mobile devices (< 600dp width)
  final Widget mobile;

  /// Widget to display on tablet devices (>= 600dp and < 1200dp width)
  final Widget tablet;

  /// Widget to display on desktop devices (>= 1200dp width)
  final Widget desktop;

  /// Optional width breakpoints to override the defaults
  final double? mobileBreakpoint;
  final double? tabletBreakpoint;

  const ResponsiveBuilder({
    Key? key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
    this.mobileBreakpoint,
    this.tabletBreakpoint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Use default or custom breakpoints
        final mobileWidth = mobileBreakpoint ?? 600;
        final tabletWidth = tabletBreakpoint ?? 1200;

        // Return the appropriate layout based on screen width
        if (width < mobileWidth) {
          return mobile;
        } else if (width < tabletWidth) {
          return tablet;
        } else {
          return desktop;
        }
      },
    );
  }
}
