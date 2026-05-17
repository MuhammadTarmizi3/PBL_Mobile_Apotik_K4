// Card calling — tampilkan antrian yang sedang dipanggil
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

// Card antrian yang sedang dipanggil (bisa kosong atau dengan action)
class CallingCard extends StatelessWidget {
  final String nomorAntrian;
  final String namaPasien;
  final String? idResep;
  final List<Widget>? actionButtons;
  final bool isEmpty;

  const CallingCard({
    super.key,
    required this.nomorAntrian,
    required this.namaPasien,
    this.idResep,
    this.actionButtons,
    this.isEmpty = false,
  });

  // Constructor alternatif untuk state kosong (tanpa data antrian)
  const CallingCard.empty({
    super.key,
  })  : nomorAntrian = '',
        namaPasien = '',
        idResep = null,
        actionButtons = null,
        isEmpty = true;

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 48,
              color: AppColors.textMuted.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tidak ada antrian aktif',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Semua pasien hari ini telah dilayani',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SEDANG DIPANGGIL',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.teal,
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(
                width: 10,
                height: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.mintDark,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            nomorAntrian,
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
                  namaPasien,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ID Resep: ${idResep ?? "-"}',
                      style: const TextStyle(
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
          if (actionButtons != null) ...[
            const SizedBox(height: 24),
            ...actionButtons!,
          ],
        ],
      ),
    );
  }
}
