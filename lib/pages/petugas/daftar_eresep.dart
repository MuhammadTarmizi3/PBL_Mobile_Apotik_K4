// Halaman daftar e-Resep — list resep aktif dan selesai untuk petugas
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/provider_eresep.dart';
import '../../providers/provider_obat.dart';
import '../../models/resep.dart';
import 'detail_eresep.dart';

// Tab e-Resep — list resep dengan navigasi ke detail
class EResepPage extends StatefulWidget {
  const EResepPage({super.key});

  @override
  State<EResepPage> createState() => _EResepPageState();
}

class _EResepPageState extends State<EResepPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ObatProvider>().fetchObat(); // re-fetch tiap buka screen
    });
  }

  // Aturan Wajib: Fungsi untuk menggambar tampilan halaman
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EResepProvider>();

    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        
        itemCount: provider.resepList.length + (provider.isUsingLocalData ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (provider.isUsingLocalData && index == 0) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.localDataNotice,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
            );
          }
          final resepIndex = provider.isUsingLocalData ? index - 1 : index;
          return _buildResepCard(context, provider.resepList[resepIndex]);
        },
      ),
    );
  }

  // â”€â”€ Fungsi untuk menggambar desain 1 Kotak Kartu Resep â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildResepCard(BuildContext context, Resep resep) {
    // Container sebagai pembungkus utama (Kartu putih)
    return Container(
      clipBehavior: Clip.antiAlias, // Aturan wajib agar garis kiri ikut melengkung sesuai sudut kartu
      decoration: BoxDecoration(
        color: AppColors.surface, // Background kartu putih
        borderRadius: BorderRadius.circular(12), // Ujung kartu melengkung
        // Memberi bayangan tipis
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08), // Sedikit digelapkan agar lebih terlihat
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Container tambahan untuk membuat garis aksen di sisi kiri
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppColors.navy,
              width: 6,
            ),
          ),
        ),
        // Padding di dalam kartu agar teksnya tidak mentok ke dinding batas kartu
        child: Padding(
          padding: const EdgeInsets.all(16),
          // Column karena di dalam kartu disusun secara vertikal (Isi resep -> lalu Tombol di bawahnya)
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
          children: [
            // Row digunakan untuk membagi layar kiri (Kotak Nomor) dan kanan (Daftar Obat)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Posisi sejajar di atas
              children: [
                // â”€â”€ Kotak Badge nomor antrian (Warna Biru)
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.navy, // Background kotak biru
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center, // Teks otomatis di tengah kotak
                  // Teks "001" dsb
                  child: Text(
                    '${resep.idResep}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700, // Sangat tebal (bold)
                      color: AppColors.surface,
                    ),
                  ),
                ),
                
                const SizedBox(width: 12), // Jarak antara kotak nomor dan tulisan obat
                
                // Expanded: Aturan Wajib agar teks sebelahnya tidak melebar merusak layar (overflow)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul "Resep"
                      const Text(
                        'Resep',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Looping (perulangan) otomatis untuk setiap obat yang ada di list 'items'
                      // Tanda ... (Spread Operator) digunakan untuk memecah daftar Widget menjadi satuan di dalam Column
                      ...resep.items.map(
                        (item) => Text(
                          item.namaObat, // Mencetak nama obat
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: AppColors.tealDark,
                            height: 1.6, // Memberi spasi jarak antar baris tulisan obat
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 14), // Jarak antara daftar obat dan tombol
            
            // â”€â”€ Tombol "Pilih" di bagian bawah kartu
            // SizedBox agar lebar tombol penuh memenuhi kartu
            SizedBox(
              width: double.infinity,
              height: 44, // Tinggi tombol
              child: ElevatedButton(
                // onPressed: Apa yang terjadi jika ditekan?
                onPressed: () {
                  // Navigator.push: Perintah untuk membuka/tumpuk halaman baru (Maju)
                  // Membuka DetailEResepPage dan mengirimkan data `resep` ke halaman tersebut
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailEResepPage(resep: resep),
                    ),
                  );
                },
                // style: Warna dan bentuk tombol
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy, // Warna biru
                  elevation: 0, // Hilangkan bayangan bawaan
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Pilih',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ), // Penutup Container tambahan (garis aksen)
    );
  }
}
