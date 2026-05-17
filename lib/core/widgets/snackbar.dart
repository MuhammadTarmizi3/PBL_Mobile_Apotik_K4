// Utilitas snackbar — helper untuk tampilkan notifikasi konsisten di seluruh app
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

// Tampilkan snackbar standar dengan pesan singkat
void showAppSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
  Duration duration = const Duration(seconds: 2),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontFamily: 'Poppins'),
      ),
      backgroundColor: backgroundColor ?? AppColors.teal,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: duration,
    ),
  );
}

// Tampilkan snackbar dengan icon di sebelah kiri pesan
void showAppSnackBarWithIcon(
  BuildContext context,
  String message,
  IconData icon, {
  Color? backgroundColor,
  Duration duration = const Duration(seconds: 2),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontFamily: 'Poppins', color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor ?? AppColors.teal,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: duration,
    ),
  );
}

// Snackbar khusus error (background merah)
void showAppErrorSnackBar(BuildContext context, String message) {
  showAppSnackBar(context, message, backgroundColor: AppColors.error);
}

// Snackbar khusus sukses (icon centang hijau)
void showAppSuccessSnackBar(BuildContext context, String message) {
  showAppSnackBarWithIcon(context, message, Icons.check_circle_rounded, backgroundColor: AppColors.teal);
}

// Snackbar khusus warning (icon peringatan kuning)
void showAppWarningSnackBar(BuildContext context, String message) {
  showAppSnackBarWithIcon(context, message, Icons.warning_rounded, backgroundColor: AppColors.warning);
}
