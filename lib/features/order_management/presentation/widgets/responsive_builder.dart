import 'package:flutter/material.dart';

/// A widget that renders different layouts based on screen size.
/// Use this widget to create responsive layouts for mobile, tablet, and desktop.
class ResponsiveBuilder extends StatelessWidget {

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
    this.mobileBreakpoint,
    this.tabletBreakpoint,
  });
  /// Widget to display on mobile devices (< 600dp width)
  final Widget mobile;

  /// Widget to display on tablet devices (>= 600dp and < 1200dp width)
  final Widget tablet;

  /// Widget to display on desktop devices (>= 1200dp width)
  final Widget desktop;

  /// Optional width breakpoints to override the defaults
  final double? mobileBreakpoint;
  final double? tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final width = constraints.maxWidth;
        final mobileWidth = mobileBreakpoint ?? 600;
        final tabletWidth = tabletBreakpoint ?? 1200;
        if (width < mobileWidth) return mobile;
        if (width < tabletWidth) return tablet;
        return desktop;
      },
    );
  }
}
