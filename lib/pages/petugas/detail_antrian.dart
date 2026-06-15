// Halaman detail antrian — info pasien, status, dan aksi panggil/selesai
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/snackbar.dart';
import '../../core/widgets/badges/badge_status.dart';
import '../../core/widgets/badges/badge_antrian.dart';
import '../../core/widgets/layouts/custom_app_bar.dart';
import '../../core/widgets/overlay_berhasil.dart';
import '../../models/antrian.dart';
import '../../providers/provider_antrian.dart';

// Widget detail antrian — tampilkan info pasien & kontrol status
class DetailAntrianPage extends StatefulWidget {
  final Antrian antrian; // Data antrian yang diterima dari halaman sebelumnya

  const DetailAntrianPage({
    super.key,
    required this.antrian,
  });

  @override
  State<DetailAntrianPage> createState() => _DetailAntrianPageState();
}

class _DetailAntrianPageState extends State<DetailAntrianPage> {
  bool _berhasil = false;
  bool _siapTutupPopup = false;
  bool _loading = false;

  Antrian get antrian => widget.antrian;

  void _selesaikan() async {
    if (_loading) return;
    setState(() => _loading = true);

    final provider = context.read<AntrianProvider>();
    try {
      await provider.selesaikanAntrian(antrian);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _berhasil = true;
        _siapTutupPopup = false;
      });
      // Tunggu sebentar agar tap dari tombol Selesaikan tidak langsung menutup popup
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() => _siapTutupPopup = true);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showAppSnackBar(
        context,
        provider.errorMessage ?? e.toString(),
        backgroundColor: AppColors.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // â”€â”€ LAPISAN BAWAH: Scaffold utama â”€â”€
        Scaffold(
      backgroundColor: AppColors.backgroundMint,
      appBar: const CustomAppBar(
        title: 'Detail Antrian',
        centerTitle: false,
        backgroundColor: Colors.white,
      ),

      // â”€â”€ TOMBOL BAWAH (SELESAIKAN) â€” sticky di bawah layar â”€â”€
      bottomNavigationBar: _berhasil
          ? null
          : Container(
        padding: EdgeInsets.fromLTRB(
          20, 16, 20, 16 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.backgroundMint,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _loading ? null : _selesaikan,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.save, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Selesaikan',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),

      // â”€â”€ KONTEN UTAMA â”€â”€
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // â”€â”€ KARTU HEADER PASIEN â”€â”€
            // Menampilkan nomor antrian, nama pasien, dan ID resep
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  AntrianBadge(
                    nomorAntrian: antrian.nomorAntrian,
                    radius: 28,
                    fontSize: 16,
                  ),
                  const SizedBox(width: 16),
                  // Nama dan ID Resep
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          antrian.namaPasien,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'R-${antrian.idResep}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // â”€â”€ LABEL STATUS â”€â”€
            const Text(
              'Status',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            // Badge status dengan warna dinamis berdasarkan status antrian
            StatusBadge(
              label: antrian.status.label,
              backgroundColor: antrian.status.badgeColor,
            ),

            const SizedBox(height: 24),

            // â”€â”€ DETAIL RESEP â”€â”€
            const Text(
              'Detail',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ID Resep: R-${antrian.idResep}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Kartu daftar obat (Mock Data sementara)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  // Daftar obat (Data statis sementara)
                  Text(
                    '1x Sangobion',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.tealMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1x Cefadroxil 500mg',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.tealMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),

        // â”€â”€ LAPISAN ATAS: Overlay sukses â”€â”€
        if (_berhasil)
          SuccessOverlay(
            message: 'ANTRIAN ${antrian.namaPasien}\nSELESAI DILAYANI',
            siapTutup: _siapTutupPopup,
          ),
      ],
    );
  }
}
