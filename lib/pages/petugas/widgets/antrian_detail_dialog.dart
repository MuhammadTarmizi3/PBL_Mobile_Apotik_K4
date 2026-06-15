// Dialog detail info antrian dengan opsi panggil sekarang
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/dialog_row.dart';
import '../../../models/antrian_rs.dart';

// Dialog popup detail antrian RS
class AntrianDetailDialog extends StatelessWidget {
  const AntrianDetailDialog({
    super.key,
    required this.antrian,
    required this.isCurrentlyActive,
    required this.onPanggilSekarang,
  });

  final AntrianRs antrian;
  final bool isCurrentlyActive;
  final Future<void> Function(AntrianRs) onPanggilSekarang;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Antrian ${antrian.nomorAntrian}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DialogInfoRow(label: 'Pasien', value: antrian.namaPasien ?? '-'),
          DialogInfoRow(label: 'ID Pasien', value: antrian.idPasien?.toString() ?? '-'),
          DialogInfoRow(label: 'Unit', value: antrian.namaUnit ?? '-'),
          DialogInfoRow(label: 'Status', value: antrian.status ?? '-'),
          DialogInfoRow(label: 'Waktu', value: antrian.formattedCreatedAt),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
        if (!isCurrentlyActive)
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await onPanggilSekarang(antrian);
            },
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('Panggil Sekarang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }
}
