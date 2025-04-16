import 'package:flutter/material.dart';

/// A consistent card component that can be used across the app
class AppCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final double elevation;
  final Color? shadowColor;
  final BorderSide? border;
  final VoidCallback? onTap;
  final bool withRipple;
  final Clip clipBehavior;

  const AppCard({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.symmetric(vertical: 8.0),
    this.borderRadius = 12.0,
    this.elevation = 1.0,
    this.shadowColor,
    this.border,
    this.onTap,
    this.withRipple = true,
    this.clipBehavior = Clip.antiAlias,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.cardColor;

    final Widget cardContent = Padding(
      padding: padding,
      child: child,
    );

    // If no tap action is specified, return a simple card
    if (onTap == null) {
      return Card(
        elevation: elevation,
        shadowColor: shadowColor,
        color: bgColor,
        margin: margin,
        clipBehavior: clipBehavior,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: border ?? BorderSide.none,
        ),
        child: cardContent,
      );
    }

    // If tap action is specified, wrap the card with InkWell or GestureDetector
    if (withRipple) {
      return Card(
        elevation: elevation,
        shadowColor: shadowColor,
        color: bgColor,
        margin: margin,
        clipBehavior: clipBehavior,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: border ?? BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          splashColor: theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(borderRadius),
          child: cardContent,
        ),
      );
    } else {
      return GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: elevation,
          shadowColor: shadowColor,
          color: bgColor,
          margin: margin,
          clipBehavior: clipBehavior,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: border ?? BorderSide.none,
          ),
          child: cardContent,
        ),
      );
    }
  }
}
