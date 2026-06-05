// Calling card khusus admin (read-only, tanpa action buttons)
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/cards/card_panggil.dart';
import '../../../models/antrian_rs.dart';

// Calling card antrian admin — tampil info pasien yang sedang dipanggil
class AdminCallingCard extends StatelessWidget {
  const AdminCallingCard({super.key, required this.antrian});

  final AntrianRs? antrian;

  @override
  Widget build(BuildContext context) {
    if (antrian == null) {
      return const CallingCard.empty();
    }

    final current = antrian!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SEDANG DIPANGGIL',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.teal,
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.mintDark,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            current.nomorAntrian ?? '-',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(left: 14),
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.teal, width: 4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  current.namaPasien ?? 'Pasien #${current.idPasien}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.textMuted),
                    SizedBox(width: 6),
                    Text(
                      'ID Resep: -',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
