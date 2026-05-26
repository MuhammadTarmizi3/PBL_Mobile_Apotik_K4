// Dialog detail info antrian dengan opsi panggil sekarang
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
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
          _buildDialogRow('Pasien', antrian.namaPasien ?? '-'),
          _buildDialogRow('ID Pasien', antrian.idPasien?.toString() ?? '-'),
          _buildDialogRow('Unit', antrian.namaUnit ?? '-'),
          _buildDialogRow('Status', antrian.status ?? '-'),
          _buildDialogRow('Waktu', antrian.formattedCreatedAt),
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

  Widget _buildDialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
