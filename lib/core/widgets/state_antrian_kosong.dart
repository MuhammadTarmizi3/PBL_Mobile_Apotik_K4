// Widget state kosong saat tidak ada antrian berikutnya + tombol refresh
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

// Widget state kosong saat tidak ada antrian berikutnya + tombol refresh
class EmptyQueueState extends StatelessWidget {
  const EmptyQueueState({
    super.key,
    required this.isRefreshing,
    required this.onRefresh,
  });

  final bool isRefreshing; // flag loading saat refresh
  final VoidCallback onRefresh; // callback saat tombol refresh ditekan

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            size: 40,
            color: AppColors.textMuted.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 8),
          const Text(
            'Belum ada antrean berikutnya',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: isRefreshing ? null : onRefresh,
            icon: isRefreshing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh, size: 16),
            label: Text(isRefreshing ? 'Memuat...' : 'Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
