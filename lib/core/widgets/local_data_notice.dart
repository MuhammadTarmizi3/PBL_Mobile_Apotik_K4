// Banner notifikasi data lokal — warning saat menggunakan data offline
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class LocalDataNotice extends StatelessWidget {
  final String message;

  const LocalDataNotice({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
