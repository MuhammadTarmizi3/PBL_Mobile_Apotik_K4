// Widget reusable untuk state kosong, loading, dan error
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

// Widget generalis untuk tampilkan state kosong (icon + pesan)
class EmptyState extends StatelessWidget {
  final IconData icon; // icon yang ditampilkan di tengah
  final String message; // pesan utama
  final String? subMessage; // pesan tambahan opsional
  final Widget? action; // tombol aksi opsional

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.subMessage,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.onSurfaceMuted.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
            if (subMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                subMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// Widget loading — tampilkan spinner + pesan
class LoadingState extends StatelessWidget {
  final String message;

  const LoadingState({
    super.key,
    this.message = 'Memuat data...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget error state — tampilkan pesan + tombol retry opsional
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
