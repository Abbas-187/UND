import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool isPassword;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.isPassword = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onFieldSubmitted,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      onFieldSubmitted: onFieldSubmitted,
      focusNode: focusNode,
      textInputAction: textInputAction,
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
