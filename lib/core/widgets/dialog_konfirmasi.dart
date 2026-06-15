// Dialog konfirmasi dan error — reusable untuk seluruh form dan aksi
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

// Dialog konfirmasi umum (Simpan/Batal, Keluar/Tetap, dsb.)
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Color confirmColor;

  const ConfirmDialog({
    super.key,
    this.title = 'Konfirmasi',
    required this.message,
    this.confirmLabel = 'Simpan',
    this.cancelLabel = 'Batal',
    this.confirmColor = AppColors.primary,
  });

  // Factory: konfirmasi simpan data
  factory ConfirmDialog.simpan(BuildContext context, {String message = 'Apakah Anda yakin ingin menyimpan data obat ini?'}) {
    return ConfirmDialog(
      message: message,
      confirmLabel: 'Simpan',
      cancelLabel: 'Batal',
      confirmColor: AppColors.primary,
    );
  }

  // Factory: konfirmasi keluar tanpa simpan
  factory ConfirmDialog.keluar() {
    return ConfirmDialog(
      title: 'Konfirmasi',
      message: 'Perubahan belum disimpan. Yakin ingin keluar?',
      confirmLabel: 'Keluar',
      cancelLabel: 'Tetap di Sini',
      confirmColor: AppColors.danger,
    );
  }

  // Show helper — panggil dialog dan return bool
  static Future<bool> show(BuildContext context, ConfirmDialog dialog) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => dialog,
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: const TextStyle(fontFamily: 'Poppins')),
      content: Text(message, style: const TextStyle(fontFamily: 'Poppins')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel, style: const TextStyle(fontFamily: 'Poppins')),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel, style: TextStyle(fontFamily: 'Poppins', color: confirmColor)),
        ),
      ],
    );
  }
}

// Dialog error umum — tampilkan pesan error + tombol OK
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;

  const ErrorDialog({
    super.key,
    this.title = 'Gagal',
    required this.message,
    this.buttonLabel = 'OK',
  });

  // Factory: gagal simpan data
  factory ErrorDialog.gagalSimpan({String message = 'Gagal menyimpan data obat. Silakan coba lagi.'}) {
    return ErrorDialog(title: 'Gagal', message: message);
  }

  // Show helper
  static Future<void> show(BuildContext context, ErrorDialog dialog) async {
    await showDialog<void>(
      context: context,
      builder: (_) => dialog,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: const TextStyle(fontFamily: 'Poppins')),
      content: Text(message, style: const TextStyle(fontFamily: 'Poppins')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(buttonLabel, style: const TextStyle(fontFamily: 'Poppins')),
        ),
      ],
    );
  }
}
