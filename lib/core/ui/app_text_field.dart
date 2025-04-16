import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable text input component with consistent styling across the app
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final bool autoFocus;
  final bool showCursor;
  final String? errorText;
  final String? helperText;
  final int? maxLength;
  final bool showCounter;
  final TextCapitalization textCapitalization;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;

  const AppTextField({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.borderRadius = 8.0,
    this.contentPadding,
    this.autoFocus = false,
    this.showCursor = true,
    this.errorText,
    this.helperText,
    this.maxLength,
    this.showCounter = true,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      readOnly: readOnly,
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      inputFormatters: inputFormatters,
      autofocus: autoFocus,
      showCursor: showCursor,
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        helperText: helperText,
        counterText: showCounter ? null : '',
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefixIconConstraints: prefixIconConstraints,
        suffixIconConstraints: suffixIconConstraints,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: theme.dividerColor,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: theme.dividerColor,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: theme.primaryColor,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: theme.disabledColor.withOpacity(0.3),
            width: 1.0,
          ),
        ),
        filled: !enabled,
        fillColor: !enabled ? theme.disabledColor.withOpacity(0.05) : null,
      ),
    );
  }
}
