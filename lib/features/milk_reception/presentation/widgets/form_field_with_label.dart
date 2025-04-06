import 'package:flutter/material.dart';

/// A form field with a label and consistent styling
class FormFieldWithLabel extends StatelessWidget {
  const FormFieldWithLabel({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.validator,
    this.prefixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  /// Text editing controller
  final TextEditingController controller;

  /// Field label
  final String label;

  /// Hint text
  final String? hintText;

  /// Validator function
  final String? Function(String?)? validator;

  /// Prefix icon
  final IconData? prefixIcon;

  /// Keyboard type
  final TextInputType? keyboardType;

  /// Maximum number of lines
  final int maxLines;

  /// Whether the field is read-only
  final bool readOnly;

  /// Callback when the field is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
        ),
      ],
    );
  }
}
