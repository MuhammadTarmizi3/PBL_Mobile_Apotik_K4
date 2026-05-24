// Card resep terpilih di halaman detail e-Resep
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/resep.dart';

// Card ringkasan resep yang dipilih di halaman sebelumnya
class ResepTerpilihCard extends StatelessWidget {
  const ResepTerpilihCard({super.key, required this.resep});

  final Resep resep;

  @override
  Widget build(BuildContext context) {
    final String nomor = resep.idResep.toString();
    final List<String> items =
        resep.items.map((e) => '${e.namaObat}  x${e.jumlah}').toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.tealDark, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.tealDark,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              nomor,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: AppColors.surface,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resep',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.tealDark,
                  ),
                ),
                const SizedBox(height: 4),
                ...items.map(
                  (item) => Text(
                    item,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.tealDark,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
