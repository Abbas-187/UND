import 'package:flutter/material.dart';

/// A widget that builds different layouts based on screen size.
///
/// This widget provides an easy way to implement responsive design by
/// taking different builder functions for mobile, tablet, and desktop layouts.
class ResponseBuilder extends StatelessWidget {

  const ResponseBuilder({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });
  /// Builder function for mobile screens (typically < 600px wide)
  final WidgetBuilder mobile;

  /// Builder function for tablet screens (typically 600-1200px wide)
  final WidgetBuilder tablet;

  /// Builder function for desktop screens (typically > 1200px wide)
  final WidgetBuilder desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return desktop(context);
        } else if (constraints.maxWidth > 600) {
          return tablet(context);
        } else {
          return mobile(context);
        }
      },
    );
  }
}
