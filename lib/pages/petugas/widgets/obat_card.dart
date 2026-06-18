// Card obat individual dengan kontrol +/- kuantitas dan input manual
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/obat_apotek.dart';

// Card obat dengan counter +/- dan input manual (controller dari parent)
class ObatCard extends StatelessWidget {
  const ObatCard({
    super.key,
    required this.obat,
    required this.resepMax,
    required this.onIncrement,
    required this.onDecrement,
    required this.controller,
    required this.focusNode,
    required this.onCommit,
  });

  final ObatApotek obat;
  final int? resepMax;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final TextEditingController controller;
  final FocusNode focusNode;

  // Dipanggil saat user selesai mengetik (focus lost / submit)
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    final int jumlahDiambil = obat.jumlahDiambil;
    final int stok = obat.stok;
    final bool belumDiambil = obat.belumDiambil;
    final bool atMax = resepMax != null && jumlahDiambil >= resepMax!;
    final bool expired = obat.isExpired;
    final bool notInResep = resepMax == null;
    final bool plusDisabled = atMax || expired || notInResep;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: expired ? AppColors.pureRed.withValues(alpha: 0.04) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: expired ? Border.all(color: AppColors.pureRed.withValues(alpha: 0.4), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  obat.idObat.toString(),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tealMedium,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 60.0),
                child: Text(
                  'Stok: $stok',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            obat.namaObat,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          Text(
            obat.namaJenisObat ?? '',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 12, color: expired ? AppColors.pureRed : AppColors.textMuted),
              const SizedBox(width: 5),
              Text(
                obat.tanggalKadaluwarsa != null
                    ? 'Exp: ${obat.tanggalKadaluwarsa!.month.toString().padLeft(2, '0')}/${obat.tanggalKadaluwarsa!.year}'
                    : 'Exp: -',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: expired ? FontWeight.w600 : FontWeight.w400,
                  color: expired ? AppColors.pureRed : AppColors.textMuted,
                ),
              ),
              if (expired) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.pureRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'KADALUARSA',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.pureRed,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Tombol minus
              GestureDetector(
                onTap: onDecrement,
                child: Icon(
                  Icons.remove_circle_outline_rounded,
                  size: 28,
                  color: belumDiambil
                      ? AppColors.danger.withValues(alpha: 0.4)
                      : AppColors.red,
                ),
              ),
              const SizedBox(width: 8),
              // Input field manual
              SizedBox(
                width: 60,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: atMax ? AppColors.pureRed : AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.teal,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onSubmitted: (_) => onCommit(),
                ),
              ),
              const SizedBox(width: 8),
              // Tombol plus — disabled saat sudah max, kadaluarsa, atau tidak dalam resep
              GestureDetector(
                onTap: plusDisabled ? null : onIncrement,
                child: Icon(
                  Icons.add_circle_outline_rounded,
                  size: 28,
                  color: plusDisabled
                      ? AppColors.neutral
                      : AppColors.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
