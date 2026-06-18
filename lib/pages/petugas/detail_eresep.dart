// Halaman detail e-Resep — input jumlah obat, validasi stok, dan simpan
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/resep.dart';
import '../../models/obat_apotek.dart';
import '../../core/widgets/badges/badge_kategori.dart';
import '../../core/widgets/layouts/custom_app_bar.dart';
import '../../core/widgets/snackbar.dart';
import '../../core/widgets/overlay_berhasil.dart';
import '../../core/widgets/search_bar.dart';
import 'widgets/resep_terpilih_card.dart';
import 'widgets/obat_card.dart';
import 'widgets/eresep_bottom_actions.dart';
import '../../providers/provider_obat.dart';

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

  late List<ObatApotek> _daftarObat;

  @override
  void initState() {
    super.initState();
    // Populate _daftarObat dari provider agar stok dan nama selalu fresh
    final obatProvider = context.read<ObatProvider>();
    _daftarObat = obatProvider.obatList.map((o) => ObatApotek(
      idObat: o.idObat,
      namaObat: o.namaObat,
      namaJenisObat: obatProvider.getJenisName(o.idJenisObat),
      tanggalKadaluwarsa: o.tanggalKadaluwarsa,
      stok: o.stok,
      jumlahDiambil: 0,
    )).toList();

    // Pre-create controllers untuk semua obat.
    for (final obat in _daftarObat) {
      _controllerFor(obat);
      _focusNodeFor(obat);
    }
  }

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
    // Blok obat kadaluarsa sejak awal interaksi
    if (obat.isExpired) {
      showAppSnackBar(context, 'Obat kadaluarsa tidak dapat diambil', backgroundColor: AppColors.pureRed);
      return;
    }
    final int? resepJumlah = _getResepJumlah(obat);
    if (resepJumlah == null) {
      showAppSnackBar(context, 'Obat ini tidak ada dalam resep dokter', backgroundColor: AppColors.pureRed);
      return;
    }
    if (obat.jumlahDiambil >= obat.stok) {
      showAppSnackBar(context, 'Stok tidak cukup (tersedia: ${obat.stok})', backgroundColor: AppColors.pureRed);
      return;
    }
    if (obat.jumlahDiambil >= resepJumlah) {
      showAppSnackBar(context, 'Jumlah melebihi resep dokter (maks. $resepJumlah)', backgroundColor: AppColors.pureRed);
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

    // Obat kadaluarsa tidak boleh diambil — reset ke 0
    if (obat.isExpired && nilai > 0) {
      if (showSnackBar) {
        showAppSnackBar(context, '${obat.namaObat} sudah kadaluarsa, tidak dapat diambil', backgroundColor: AppColors.pureRed);
      }
      nilai = 0;
    } else if (resepJumlah != null && nilai > resepJumlah) {
      if (showSnackBar) {
        showAppSnackBar(context, 'Melebihi jumlah yang diminta dalam eResep', backgroundColor: AppColors.pureRed);
      }
      nilai = resepJumlah;
    } else if (nilai > stok) {
      if (showSnackBar) {
        showAppSnackBar(context, 'Melebihi stok yang tersedia (stok: $stok)', backgroundColor: AppColors.pureRed);
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

  // Tahap 3: cek apakah ada obat kadaluarsa yang diambil
  List<ObatApotek> _validasiKadaluarsa() {
    return _daftarObat.where((o) => o.jumlahDiambil > 0 && o.isExpired).toList();
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
                '\u2022 ${item['nama']} \u2014 diminta: ${item['diminta']}, stok tersedia: ${item['stok']}',
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

  // Dialog obat kadaluarsa — tampilkan daftar obat yang sudah expired
  void _showDialogObatKadaluarsa(List<ObatApotek> obatExpired) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Obat Kadaluarsa',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Obat berikut sudah kadaluarsa dan tidak dapat disimpan:',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...obatExpired.map((o) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '\u2022 ${o.namaObat} (Exp: ${o.tanggalKadaluwarsa!.month}/${o.tanggalKadaluwarsa!.year})',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.pureRed),
              ),
            )),
            const SizedBox(height: 12),
            const Text(
              'Silakan hapus obat kadaluarsa dari pengambilan atau ganti dengan obat yang masih layak.',
              style: TextStyle(fontFamily: 'Poppins', fontStyle: FontStyle.italic, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontFamily: 'Poppins')),
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

    // Bangun map {idObat: stokBaru} dari semua obat yang diambil
    final Map<int, int> stokUpdates = {};
    final List<Map<String, dynamic>> hasilLokal = [];

    for (final obat in _daftarObat) {
      if (obat.jumlahDiambil <= 0) continue;
      final stokBaru = obat.stok - obat.jumlahDiambil;
      stokUpdates[obat.idObat] = stokBaru;
      hasilLokal.add({'nama': obat.namaObat, 'idObat': obat.idObat, 'stokBaru': stokBaru});
    }

    if (stokUpdates.isEmpty) {
      setState(() => _isSaving = false);
      return;
    }

    try {
      // Gunakan ObatProvider untuk update stok — cache ter-update otomatis
      final obatProvider = context.read<ObatProvider>();
      await obatProvider.updateStokSetelahResep(stokUpdates);

      // Update stok lokal agar UI langsung mencerminkan perubahan
      for (final obat in _daftarObat) {
        if (stokUpdates.containsKey(obat.idObat)) {
          obat.stok = stokUpdates[obat.idObat]!;
        }
      }

      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _berhasil = true;
        _siapTutupPopup = false;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() => _siapTutupPopup = true);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showDialogGagalSimpan(e.toString());
    }
  }

  void _showDialogGagalSimpan(String pesanError) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Gagal Menyimpan Resep',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pesanError.replaceAll('Exception: ', ''),
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Text(
              'Stok yang sudah berubah tidak dapat dikembalikan secara otomatis.',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontFamily: 'Poppins')),
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
      showAppSnackBar(context, 'Jumlah obat belum sesuai eResep. Periksa kembali.', backgroundColor: AppColors.pureRed);
      return;
    }

    // Tahap 2: validasi stok
    final kurangStok = _validasiStok();
    if (kurangStok.isNotEmpty) {
      _showDialogStokTidakCukup(kurangStok);
      return;
    }

    // Tahap 3: validasi obat kadaluarsa
    final obatExpired = _validasiKadaluarsa();
    if (obatExpired.isNotEmpty) {
      _showDialogObatKadaluarsa(obatExpired);
      return;
    }

    // Tahap 4: konfirmasi simpan
    final konfirmasi = await _showDialogKonfirmasi();
    if (konfirmasi != true) return;

    // Tahap 5: eksekusi simpan
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
          appBar: const CustomAppBar(title: 'E-Resep', centerTitle: true, showBackButton: false),
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
                AppSearchBar(controller: _searchController, onChanged: (v) => setState(() => _searchQuery = v), hintText: 'Cari Nama Obat'),
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
        if (_berhasil) SuccessOverlay(
          message: 'RESEP BERHASIL\nDI PROSES',
          siapTutup: _siapTutupPopup,
        ),
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
