// Header section "Antrian Berikutnya" dengan tombol lihat semua
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

// Header section antrian berikutnya + tombol lihat semua
class NextQueueHeader extends StatelessWidget {
  const NextQueueHeader({
    super.key,
    required this.onLihatSemua,
  });

  final VoidCallback onLihatSemua;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Antrean Berikutnya',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textDark,
          ),
        ),
        TextButton(
          onPressed: onLihatSemua,
          child: const Text(
            'Lihat Semua',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.teal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
