import 'package:flutter/material.dart';

/// A button component with consistent styling across the app
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? color;
  final IconData? icon;
  final double? width;
  final double height;
  final EdgeInsets padding;
  final double borderRadius;
  final TextStyle? textStyle;

  const AppButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.color,
    this.icon,
    this.width,
    this.height = 48.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.borderRadius = 8.0,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.primaryColor;
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: buttonColor,
            side: BorderSide(color: buttonColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding,
            minimumSize: Size(width ?? 0, height),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding,
            minimumSize: Size(width ?? 0, height),
          );

    final buttonTextStyle = textStyle ??
        (isOutlined
            ? theme.textTheme.labelLarge?.copyWith(color: buttonColor)
            : theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
              ));

    Widget buttonChild = isLoading
        ? const SizedBox(
            width: 24.0,
            height: 24.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18.0),
                const SizedBox(width: 8.0),
              ],
              Text(label, style: buttonTextStyle),
            ],
          );

    return isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          );
  }
}
