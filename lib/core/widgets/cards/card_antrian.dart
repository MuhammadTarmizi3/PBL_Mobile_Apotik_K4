// Card reusable untuk item antrian
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../badges/badge_antrian.dart';

// Card item antrian — nomor, nama, status, dan tap action
class AntrianCard extends StatelessWidget {
  final String nomorAntrian;
  final String namaPasien;
  final String idResep;
  final String statusLabel;
  final VoidCallback? onTap;
  final bool showChevron;
  final Color? backgroundColor;
  final Color? borderColor;

  const AntrianCard({
    super.key,
    required this.nomorAntrian,
    required this.namaPasien,
    required this.idResep,
    required this.statusLabel,
    this.onTap,
    this.showChevron = true,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? AppColors.border),
      ),
      child: Row(
        children: [
          AntrianBadge(nomorAntrian: nomorAntrian),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaPasien,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'R-$idResep â€¢ $statusLabel',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (showChevron)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(32),
                onTap: onTap,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.lightestGrey,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
