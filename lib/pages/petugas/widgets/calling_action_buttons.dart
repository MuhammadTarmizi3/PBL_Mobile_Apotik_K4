// Tombol aksi calling card — panggil ulang, skip, selesai & lanjut
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

// Tombol aksi pada calling card antrian
class CallingActionButtons extends StatelessWidget {
  const CallingActionButtons({
    super.key,
    required this.onPanggilUlang,
    required this.onSkip,
    required this.onSelesaiDanLanjut,
  });

  final VoidCallback onPanggilUlang;
  final VoidCallback onSkip;
  final VoidCallback onSelesaiDanLanjut;

  static const Color _darkTeal = AppColors.primary;
  static const Color _dangerRed = AppColors.danger;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 74,
                child: OutlinedButton(
                  onPressed: onPanggilUlang,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.teal, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Semantics(
                    label: 'Panggil ulang antrian',
                    excludeSemantics: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.refresh_rounded,
                          color: AppColors.teal,
                          size: 26,
                        ),
                        SizedBox(width: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Panggil',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.teal,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '  Ulang',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.teal,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 74,
                child: ElevatedButton(
                  onPressed: onSkip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dangerRed,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: onSelesaiDanLanjut,
            style: ElevatedButton.styleFrom(
              backgroundColor: _darkTeal,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.done_all_rounded, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text(
                  'Selesai & Lanjut',
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
      ],
    );
  }
}
