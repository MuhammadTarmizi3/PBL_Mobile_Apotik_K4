// Widget tombol reusable dengan berbagai tipe (primary, outline, danger, dll)
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

// Widget tombol reusable — support loading state, icon, dan berbagai style
class AppButton extends StatelessWidget {
  final String text; // label tombol
  final VoidCallback? onPressed; // callback saat ditekan
  final ButtonType type; // tipe style tombol
  final bool isLoading; // flag loading (tampilkan spinner)
  final bool fullWidth; // lebar penuh atau auto
  final double? height; // tinggi custom (default 56)
  final IconData? icon; // icon opsional di kiri text
  final Color? backgroundColor; // warna custom background
  final Color? textColor; // warna custom text

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.height,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  static const double _defaultHeight = 56; // tinggi default tombol

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? _getBackgroundColor();
    final fgColor = textColor ?? _getForegroundColor();

    return SizedBox(
      height: height ?? _defaultHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Ambil warna background berdasarkan tipe tombol
  Color _getBackgroundColor() {
    switch (type) {
      case ButtonType.primary:
        return AppColors.primary;
      case ButtonType.secondary:
        return AppColors.surface;
      case ButtonType.outline:
        return Colors.transparent;
      case ButtonType.danger:
        return AppColors.error;
      case ButtonType.success:
        return AppColors.teal;
      case ButtonType.custom:
        return backgroundColor ?? AppColors.primary;
    }
  }

  // Ambil warna foreground/text berdasarkan tipe tombol
  Color _getForegroundColor() {
    switch (type) {
      case ButtonType.primary:
        return Colors.white;
      case ButtonType.secondary:
        return AppColors.onSurface;
      case ButtonType.outline:
        return AppColors.primary;
      case ButtonType.danger:
        return Colors.white;
      case ButtonType.success:
        return Colors.white;
      case ButtonType.custom:
        return textColor ?? Colors.white;
    }
  }
}

// Tipe-tipe tombol yang tersedia
enum ButtonType {
  primary,
  secondary,
  outline,
  danger,
  success,
  custom,
}
