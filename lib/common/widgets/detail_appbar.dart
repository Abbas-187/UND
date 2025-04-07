import 'package:flutter/material.dart';

/// A reusable AppBar for detail screens with a persistent back button
class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a DetailAppBar with a persistent back button
  const DetailAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onBackPressed,
    this.automaticallyImplyLeading = true,
  });

  /// The title displayed in the app bar
  final String title;

  /// Optional actions to display on the right side of the app bar
  final List<Widget>? actions;

  /// Optional callback for when the back button is pressed
  final VoidCallback? onBackPressed;

  /// Whether to automatically add a back button
  final bool automaticallyImplyLeading;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: automaticallyImplyLeading
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ??
                  () {
                    Navigator.of(context).pop();
                  },
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
