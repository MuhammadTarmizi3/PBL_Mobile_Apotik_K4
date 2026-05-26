// Card item antrian berikutnya di dashboard petugas
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/antrian_rs.dart';

// Card antrian dalam list queue — tap untuk lihat detail
class AntrianQueueCard extends StatelessWidget {
  const AntrianQueueCard({
    super.key,
    required this.antrian,
    required this.onTap,
    this.isDilewati = false,
  });

  final AntrianRs antrian;
  final VoidCallback onTap;
  final bool isDilewati;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Nomor antrian
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      antrian.nomorAntrian ?? '?',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info pasien
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        antrian.namaPasien ?? 'Pasien #${antrian.idPasien}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (antrian.namaUnit != null)
                        Row(
                          children: [
                            const Icon(Icons.local_hospital, size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                antrian.namaUnit!,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (isDilewati ? AppColors.neutral : AppColors.warning).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: (isDilewati ? AppColors.neutral : AppColors.warning).withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              isDilewati ? 'Dilewati' : 'Menunggu',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDilewati ? AppColors.neutral : AppColors.warning,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            antrian.formattedCreatedAt,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
