import 'package:flutter/material.dart';

/// A custom app bar with a back button and title.
/// Simplifies creating consistent app bars across the application.
class AppBarWithBack extends StatelessWidget implements PreferredSizeWidget {

  /// Creates an [AppBarWithBack] widget.
  const AppBarWithBack({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });
  /// The title displayed in the app bar.
  final String title;

  /// Optional actions to display on the right side.
  final List<Widget>? actions;

  /// Optional bottom widget for tabs.
  final PreferredSizeWidget? bottom;

  /// Optional leading widget to override the back button.
  final Widget? leading;

  /// Whether the leading widget is automatically added.
  final bool automaticallyImplyLeading;

  /// Optional background color.
  final Color? backgroundColor;

  /// Optional foreground color for icons and text.
  final Color? foregroundColor;

  /// Optional elevation of the app bar.
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      bottom: bottom,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
