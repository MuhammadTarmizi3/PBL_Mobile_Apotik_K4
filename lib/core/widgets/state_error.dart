// Widget state error dengan pesan + tombol coba lagi untuk dashboard
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

// Widget error state — tampilkan pesan error + tombol retry
class DashboardErrorState extends StatelessWidget {
  const DashboardErrorState({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  final String errorMessage; // pesan error yang akan ditampilkan
  final VoidCallback onRetry; // callback saat tombol coba lagi ditekan

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Poppins', color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
