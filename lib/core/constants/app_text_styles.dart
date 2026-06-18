// Style teks aplikasi — heading, body, caption untuk konsistensi typography
import 'package:flutter/material.dart';

import 'app_colors.dart';

// Class style teks dengan font Poppins heading, body, caption
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceMuted,
  );

  static const TextStyle caption1 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  static const TextStyle caption2 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceMuted,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.teal,
  );

  static const TextStyle error = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
  );

  static const TextStyle hint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceHint,
  );
}
