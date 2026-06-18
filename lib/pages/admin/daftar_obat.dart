// Halaman daftar obat admin — search, filter, CRUD navigation
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/obat.dart';
import '../../providers/provider_obat.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helper_icon_obat.dart';
import '../../core/utils/formatter.dart';
import '../../core/widgets/search_bar.dart';
import '../../core/widgets/local_data_notice.dart';
import 'tambah_obat.dart';
import 'edit_obat.dart';

// Halaman daftar obat dengan search dan filter kategori
class ObatAdminPage extends StatefulWidget {
  const ObatAdminPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  ObatAdminPageState createState() => ObatAdminPageState();
}

class ObatAdminPageState extends State<ObatAdminPage> with WidgetsBindingObserver {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  // Auto-refresh saat app kembali ke foreground (resume)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<ObatProvider>().fetchObat();
    }
  }

  // Public â€“ dipanggil FAB dari MainAdminPage
  Future<void> navigasiTambahObat() async {
    final result = await Navigator.push<ObatModel>(
      context,
      MaterialPageRoute(builder: (_) => const TambahObatAdminPage()),
    );
    if (result != null && mounted) {
      context.read<ObatProvider>().addObat(result);
    }
    // Auto-refresh setelah kembali dari halaman tambah (pastikan data sinkron)
    if (mounted) context.read<ObatProvider>().fetchObat();
  }
  
  Future<void> _bukaEdit(ObatModel obat) async {
    final result = await Navigator.push<ObatModel>(
      context,
      MaterialPageRoute(builder: (_) => EditObatAdminPage(obat: obat)),
    );
    if (result != null && mounted) {
      context.read<ObatProvider>().updateObat(result);
    }
    // Auto-refresh setelah kembali dari halaman edit (pastikan data sinkron)
    if (mounted) context.read<ObatProvider>().fetchObat();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ObatProvider>();
    final list = provider.filteredObatList;

    return SafeArea(
      child: Column(
        children: [
          if (provider.isUsingLocalData)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: LocalDataNotice(message: provider.localDataNotice),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: AppSearchBar(
              controller: _searchController,
              onChanged: (v) => provider.setSearchQuery(v),
              hintText: 'Cari Nama Obat',
            ),
          ),

          // Filter chips
          const SizedBox(height: 16),
          SizedBox(
            height: 38,
            child: (() {
              final kategori = provider.kategoriList;
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: kategori.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final k = kategori[i];
                  final active = provider.selectedKategori == k;
                  return GestureDetector(
                    onTap: () => provider.setSelectedKategori(k),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: active ? AppColors.primary : AppColors.border, width: 1.2),
                      ),
                      child: Text(k, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : AppColors.onSurfaceVariant)),
                    ),
                  );
                },
              );
            })(),
          ),

          // List
          const SizedBox(height: 8),
          Expanded(
            child: list.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.medication_outlined, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('Obat tidak ditemukan', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey[400], fontSize: 14)),
                  ]))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border, indent: 72),
                    itemBuilder: (_, i) => _ObatTile(obat: list[i], onTap: () => _bukaEdit(list[i])),
                  ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Tile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _ObatTile extends StatelessWidget {
  final ObatModel obat;
  final VoidCallback onTap;
  const _ObatTile({required this.obat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final expColor = (obat.isExpired || obat.isExpiringSoon) ? Colors.red : AppColors.onSurfaceMuted;
    final jenisName = context.read<ObatProvider>().getJenisName(obat.idJenisObat);
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(10)),
              child: Icon(ObatIconHelper.getIcon(jenisName), color: AppColors.teal, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(obat.namaObat, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                const SizedBox(height: 3),
                Row(children: [
                  Text('Jenis: $jenisName', style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.onSurfaceMuted)),
                  const SizedBox(width: 12),
                  Text('Stok: ${obat.stok}${obat.satuan == '-' || obat.satuan.isEmpty ? '' : ' ${obat.satuan}'}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.onSurfaceMuted)),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.onSurfaceMuted),
                      children: [
                        const TextSpan(text: 'Rp ', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.teal, fontWeight: FontWeight.w600)),
                        TextSpan(text: Formatters.toRupiah(obat.hargaJual.toInt()), style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.teal, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(obat.expDisplay, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: expColor,
                      fontWeight: (obat.isExpired || obat.isExpiringSoon) ? FontWeight.w600 : FontWeight.normal)),
                ]),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
