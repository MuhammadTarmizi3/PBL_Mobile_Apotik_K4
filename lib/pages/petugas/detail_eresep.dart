// Halaman detail e-Resep — input jumlah obat, validasi stok, dan simpan
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/resep.dart';
import '../../models/obat_apotek.dart';
import '../../core/widgets/badges/badge_kategori.dart';
import '../../core/widgets/layouts/custom_app_bar.dart';
import 'widgets/resep_terpilih_card.dart';
import 'widgets/obat_card.dart';
import 'widgets/eresep_bottom_actions.dart';
import 'widgets/eresep_success_overlay.dart';
import '../../services/service_obat.dart';

// Widget detail e-Resep — proses pengambilan obat dari resep
class DetailEResepPage extends StatefulWidget {
  final Resep resep;
  const DetailEResepPage({super.key, required this.resep});

  @override
  State<DetailEResepPage> createState() => _DetailEResepPageState();
}

class _DetailEResepPageState extends State<DetailEResepPage> {
  bool _berhasil = false;
  bool _isSaving = false;
  bool _siapTutupPopup = false;

  final ObatService _obatService = ObatService();

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Controller & FocusNode per obat, dikelola parent agar bisa dibaca saat Simpan.
  final Map<int, TextEditingController> _jumlahControllers = {};
  final Map<int, FocusNode> _jumlahFocusNodes = {};

  TextEditingController _controllerFor(ObatApotek obat) {
    return _jumlahControllers.putIfAbsent(
      obat.idObat,
      () => TextEditingController(text: obat.jumlahDiambil.toString()),
    );
  }

  FocusNode _focusNodeFor(ObatApotek obat) {
    return _jumlahFocusNodes.putIfAbsent(obat.idObat, () => FocusNode());
  }

  @override
  void initState() {
    super.initState();
    // Pre-create controllers untuk semua obat.
    for (final obat in _daftarObat) {
      _controllerFor(obat);
      _focusNodeFor(obat);
    }
  }

  final List<ObatApotek> _daftarObat = [
    ObatApotek(idObat: 1, namaObat: 'Cefadroxil 500mg', namaJenisObat: 'Antibiotik', tanggalKadaluwarsa: DateTime(2027, 5, 1), stok: 80),
    ObatApotek(idObat: 2, namaObat: 'Mylanta Cair 50ml', namaJenisObat: 'Antasida', tanggalKadaluwarsa: DateTime(2026, 7, 7), stok: 45),
    ObatApotek(idObat: 3, namaObat: 'Bodrex Migra', namaJenisObat: 'Analgesik', tanggalKadaluwarsa: DateTime(2026, 12, 15), stok: 65),
    ObatApotek(idObat: 4, namaObat: 'Diapet', namaJenisObat: 'Antidiare', tanggalKadaluwarsa: DateTime(2026, 5, 25), stok: 80),
    ObatApotek(idObat: 5, namaObat: 'Enervon-C', namaJenisObat: 'Suplemen', tanggalKadaluwarsa: DateTime(2027, 5, 25), stok: 150),
    ObatApotek(idObat: 6, namaObat: 'Rohto Cool 7ml', namaJenisObat: 'Tetes Mata', tanggalKadaluwarsa: DateTime(2026, 6, 18), stok: 70),
    ObatApotek(idObat: 7, namaObat: 'Siladex Antitussive', namaJenisObat: 'Batuk', tanggalKadaluwarsa: DateTime(2026, 9, 1), stok: 50),
    ObatApotek(idObat: 8, namaObat: 'Sangobion', namaJenisObat: 'Suplemen', tanggalKadaluwarsa: DateTime(2027, 5, 1), stok: 50),
  ];

  // â”€â”€ Search Logic (matchStart) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Map<String, List<ObatApotek>> get _groupedDaftarObat {
    final Map<String, List<ObatApotek>> grouped = {};
    for (final obat in _daftarObat) {
      grouped.putIfAbsent(obat.namaJenisObat ?? '', () => []).add(obat);
    }
    return grouped;
  }

  Map<String, dynamic>? _matchStart(String term, Map<String, dynamic> data) {
    if (term.trim().isEmpty) return data;
    if (data['children'] == null) return null;
    final List<ObatApotek> filteredChildren = [];
    for (final ObatApotek child in data['children'] as List<ObatApotek>) {
      if (child.namaObat.toUpperCase().indexOf(term.toUpperCase()) == 0) {
        filteredChildren.add(child);
      }
    }
    if (filteredChildren.isNotEmpty) {
      final Map<String, dynamic> modifiedData = Map<String, dynamic>.from(data);
      modifiedData['children'] = filteredChildren;
      return modifiedData;
    }
    return null;
  }

  Map<String, List<ObatApotek>> get _filteredGrouped {
    final Map<String, List<ObatApotek>> result = {};
    for (final entry in _groupedDaftarObat.entries) {
      final Map<String, dynamic> data = {
        'text': entry.key,
        'children': entry.value,
      };
      final Map<String, dynamic>? matched = _matchStart(_searchQuery, data);
      if (matched != null) {
        result[matched['text'] as String] = matched['children'] as List<ObatApotek>;
      }
    }
    return result;
  }

  List<ObatApotek> get _filteredDaftarObat {
    return _filteredGrouped.values.expand((list) => list).toList();
  }

  // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  int? _getResepJumlah(ObatApotek obat) {
    for (final item in widget.resep.items) {
      if (item.idObat != null && item.idObat == obat.idObat) {
        return item.jumlah;
      }
    }
    for (final item in widget.resep.items) {
      final keyword = item.namaObat
          .replaceFirst(RegExp(r'^\d+x\s*'), '')
          .toLowerCase()
          .trim();
      if (keyword.isNotEmpty && obat.namaObat.toLowerCase().contains(keyword)) {
        return item.jumlah;
      }
    }
    return null;
  }

  void _increment(ObatApotek obat) {
    final int? resepJumlah = _getResepJumlah(obat);
    if (resepJumlah == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Obat ini tidak ada dalam resep dokter'),
          backgroundColor: AppColors.pureRed,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    if (obat.jumlahDiambil >= obat.stok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok tidak cukup (tersedia: ${obat.stok})'),
          backgroundColor: AppColors.pureRed,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    if (obat.jumlahDiambil >= resepJumlah) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jumlah melebihi resep dokter (maks. $resepJumlah)'),
          backgroundColor: AppColors.pureRed,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() => obat.jumlahDiambil++);
    _controllerFor(obat).text = obat.jumlahDiambil.toString();
  }

  void _decrement(ObatApotek obat) {
    if (obat.jumlahDiambil > 0) {
      setState(() => obat.jumlahDiambil--);
      _controllerFor(obat).text = obat.jumlahDiambil.toString();
    }
  }

  // Commit nilai dari controller ke obat.jumlahDiambil dengan validasi
  void _commitObat(ObatApotek obat, {bool showSnackBar = true}) {
    final controller = _controllerFor(obat);
    final raw = controller.text.trim();
    int nilai = int.tryParse(raw) ?? 0;
    final int? resepJumlah = _getResepJumlah(obat);
    final int stok = obat.stok;

    if (nilai < 0) nilai = 0;

    if (resepJumlah != null && nilai > resepJumlah) {
      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Melebihi jumlah yang diminta dalam eResep'),
            backgroundColor: AppColors.pureRed,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      nilai = resepJumlah;
    } else if (nilai > stok) {
      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Melebihi stok yang tersedia (stok: $stok)'),
            backgroundColor: AppColors.pureRed,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      nilai = stok;
    }

    setState(() => obat.jumlahDiambil = nilai);
    controller.text = nilai.toString();
  }

  // Commit semua controller ke obat sebelum validasi simpan
  void _commitAllControllers() {
    for (final obat in _daftarObat) {
      _commitObat(obat, showSnackBar: false);
    }
  }

  // â”€â”€ Validasi & Simpan â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  // Tahap 1: cek apakah jumlahDiambil setiap obat == jumlah di eResep
  bool _validasiJumlahEResep() {
    for (final item in widget.resep.items) {
      final ObatApotek? matched = _cariObatUntukResep(item);
      if (matched == null || matched.jumlahDiambil != item.jumlah) {
        return false;
      }
    }
    // Cek tidak ada obat ekstra yang diambil tapi tidak ada di resep
    for (final obat in _daftarObat) {
      if (obat.jumlahDiambil > 0) {
        final adaDiResep = widget.resep.items.any((item) {
          final matched = _cariObatUntukResep(item);
          return matched != null && matched.idObat == obat.idObat;
        });
        if (!adaDiResep) return false;
      }
    }
    return true;
  }

  // Cari obat di _daftarObat yang cocok dengan item resep
  ObatApotek? _cariObatUntukResep(ResepItem item) {
    if (item.idObat != null) {
      final byId = _daftarObat.where((o) => o.idObat == item.idObat).toList();
      if (byId.isNotEmpty) return byId.first;
    }
    final keyword = item.namaObat
        .replaceFirst(RegExp(r'^\d+x\s*'), '')
        .toLowerCase()
        .trim();
    if (keyword.isEmpty) return null;
    final matches = _daftarObat
        .where((o) => o.namaObat.toLowerCase().contains(keyword))
        .toList();
    return matches.isEmpty ? null : matches.first;
  }

  // Tahap 2: cek stok tersedia untuk setiap obat yang diambil
  List<Map<String, dynamic>> _validasiStok() {
    final kurang = <Map<String, dynamic>>[];
    for (final obat in _daftarObat) {
      if (obat.jumlahDiambil > 0 && obat.jumlahDiambil > obat.stok) {
        kurang.add({
          'nama': obat.namaObat,
          'diminta': obat.jumlahDiambil,
          'stok': obat.stok,
        });
      }
    }
    return kurang;
  }

  void _showDialogStokTidakCukup(List<Map<String, dynamic>> kurangStok) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Stok Obat Tidak Mencukupi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...kurangStok.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'â€¢ ${item['nama']} â€” diminta: ${item['diminta']}, stok tersedia: ${item['stok']}',
              ),
            )),
            const SizedBox(height: 12),
            const Text(
              'Mohon sampaikan kepada pasien bahwa obat tersebut perlu dibeli di apotek lain.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDialogKonfirmasi() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text(
          'Semua obat sudah sesuai. Apakah Anda yakin ingin menyimpan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _eksekusiSimpan() async {
    setState(() => _isSaving = true);

    // Snapshot stok asli sebelum diubah
    final stokAsli = <int, int>{
      for (final o in _daftarObat) o.idObat: o.stok,
    };

    final hasil = <Map<String, dynamic>>[];
    bool semuaBerhasil = true;

    for (final obat in _daftarObat) {
      if (obat.jumlahDiambil <= 0) continue;
      final stokBaru = obat.stok - obat.jumlahDiambil;
      try {
        await _obatService.updateStokObat(obat.idObat, stokBaru);
        obat.stok = stokBaru; // update lokal
        hasil.add({'nama': obat.namaObat, 'berhasil': true});
      } catch (e) {
        semuaBerhasil = false;
        hasil.add({
          'nama': obat.namaObat,
          'berhasil': false,
          'stokAsli': stokAsli[obat.idObat] ?? obat.stok,
        });
      }
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (semuaBerhasil) {
      setState(() {
        _berhasil = true;
        _siapTutupPopup = false;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() => _siapTutupPopup = true);
      });
    } else {
      _showDialogGagalSimpan(hasil);
    }
  }

  void _showDialogGagalSimpan(List<Map<String, dynamic>> hasil) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sebagian Obat Gagal Diperbarui'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...hasil.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item['berhasil'] == true
                    ? '\u2705 ${item['nama']} \u2014 berhasil'
                    : '\u274C ${item['nama']} \u2014 gagal, coba lagi',
              ),
            )),
            const SizedBox(height: 12),
            const Text(
              'Stok yang sudah berubah tidak dapat dikembalikan secara otomatis.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onSimpan() async {
    // Commit semua input field â†’ obat.jumlahDiambil sebelum validasi.
    _commitAllControllers();

    // Tahap 1: validasi jumlah input vs eResep
    if (!_validasiJumlahEResep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah obat belum sesuai eResep. Periksa kembali.'),
          backgroundColor: AppColors.pureRed,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Tahap 2: validasi stok
    final kurangStok = _validasiStok();
    if (kurangStok.isNotEmpty) {
      _showDialogStokTidakCukup(kurangStok);
      return;
    }

    // Tahap 3: konfirmasi simpan
    final konfirmasi = await _showDialogKonfirmasi();
    if (konfirmasi != true) return;

    // Tahap 4: eksekusi simpan
    await _eksekusiSimpan();
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (final c in _jumlahControllers.values) {
      c.dispose();
    }
    for (final fn in _jumlahFocusNodes.values) {
      fn.dispose();
    }
    super.dispose();
  }

  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.surface,
          appBar: const CustomAppBar(title: 'E-Resep', centerTitle: true),
          bottomNavigationBar: (_berhasil || _isSaving)
              ? null
              : EresepBottomActions(
                  onSimpan: _onSimpan,
                  onBatal: () => Navigator.pop(context),
                ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('RESEP TERPILIH'),
                const SizedBox(height: 8),
                ResepTerpilihCard(resep: widget.resep),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 16),
                _sectionLabel('DAFTAR OBAT (LIST OBAT)'),
                const SizedBox(height: 8),
                if (_filteredDaftarObat.isEmpty)
                  _buildEmptySearch()
                else
                  ..._filteredGrouped.entries.expand(
                    (group) => [
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 8),
                        child: KategoriBadge(label: group.key),
                      ),
                      ...group.value.map(
                        (obat) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ObatCard(
                            obat: obat,
                            resepMax: _getResepJumlah(obat),
                            onIncrement: () => _increment(obat),
                            onDecrement: () => _decrement(obat),
                            controller: _controllerFor(obat),
                            focusNode: _focusNodeFor(obat),
                            onCommit: () => _commitObat(obat),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          ),
        ),
        if (_berhasil) EresepSuccessOverlay(siapTutup: _siapTutupPopup),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Cari Nama Obat',
        hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.onSurfaceMuted),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceMuted),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceMuted, size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5)),
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 8),
            Text(
              'Obat "$_searchQuery" tidak ditemukan',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
