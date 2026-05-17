// Badge kategori obat dengan background warna primary
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

// Badge label kategori obat
class KategoriBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const KategoriBadge({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
