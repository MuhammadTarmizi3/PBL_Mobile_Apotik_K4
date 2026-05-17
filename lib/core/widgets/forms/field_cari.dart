// TextField search reusable dengan clear button
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

// Search field dengan icon dan tombol clear
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;
  final VoidCallback? onClear;

  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Cari...',
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: AppColors.textDark,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: AppColors.textMuted,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.primary,
          size: 22,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                onPressed: () {
                  controller.clear();
                  if (onClear != null) {
                    onClear!();
                  } else {
                    onChanged('');
                  }
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
