// Widget text field reusable dengan berbagai fitur
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

// Text field reusable — label, hint, validasi, dan styling
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool filled;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.filled = true,
    this.fillColor,
    this.contentPadding,
    this.decoration,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurface,
          ),
          decoration: decoration ??
              InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.onSurfaceHint,
                ),
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                filled: filled,
                fillColor: fillColor ?? AppColors.surface,
                contentPadding: contentPadding ??
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                ),
              ),
        ),
        if (validator != null && maxLength != null)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${controller.text.length}/$maxLength',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.onSurfaceMuted,
              ),
            ),
          ),
      ],
    );
  }
}

// Text field dengan label floating + validasi
class AppTextFieldWithLabel extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixIconPressed;

  const AppTextFieldWithLabel({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hintText: hintText,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      onSuffixIconPressed: onSuffixIconPressed,
    );
  }
}
