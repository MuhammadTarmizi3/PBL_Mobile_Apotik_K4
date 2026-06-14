// Halaman edit obat — form update data obat + validasi & submit ke API
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/jenis_obat.dart';
import '../../models/obat.dart';
import '../../providers/provider_obat.dart';
import '../../services/service_jenis_obat.dart';
import 'widgets/obat_success_overlay.dart';
import 'widgets/obat_form_card.dart';

// Halaman edit obat dengan form dan validasi
class EditObatAdminPage extends StatefulWidget {
  final ObatModel obat;
  const EditObatAdminPage({super.key, required this.obat});

  @override
  State<EditObatAdminPage> createState() => _EditObatAdminPageState();
}

class _EditObatAdminPageState extends State<EditObatAdminPage> {
  late final TextEditingController _namaCtrl;
  late final TextEditingController _stokCtrl;
  late final TextEditingController _hargaBeliCtrl;
  late final TextEditingController _hargaJualCtrl;
  late DateTime _selectedDate;
  bool _loading = false;
  bool _berhasil = false;
  bool _siapTutupPopup = false;
  ObatModel? _updatedObat;

  // Jenis-obat dropdown state
  final _jenisObatService = JenisObatService();
  List<JenisObatModel> _jenisObatList = [];
  JenisObatModel? _selectedJenis;
  bool _loadingJenis = false;

  @override
  void initState() {
    super.initState();
    final o = widget.obat;
    _namaCtrl      = TextEditingController(text: o.namaObat);
    _stokCtrl      = TextEditingController(text: o.stok.toString());
    _hargaBeliCtrl = TextEditingController(text: o.hargaBeli.toInt().toString());
    _hargaJualCtrl = TextEditingController(text: o.hargaJual.toInt().toString());
    _selectedDate  = o.tanggalKadaluwarsa;
    _fetchJenisObat();
  }

  // Fetch jenis-obat list and pre-select the current value
  Future<void> _fetchJenisObat() async {
    setState(() => _loadingJenis = true);
    try {
      final list = await _jenisObatService.getAllJenisObat();
      if (!mounted) return;
      final preSelected = list.where((j) => j.idJenisObat == widget.obat.idJenisObat).firstOrNull;
      setState(() {
        _jenisObatList = list;
        _selectedJenis = preSelected;
        _loadingJenis = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingJenis = false);
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose(); _stokCtrl.dispose();
    _hargaBeliCtrl.dispose(); _hargaJualCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final p = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 10),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (p != null) setState(() => _selectedDate = p);
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  // ── SnackBar helper ──────────────────────────────────────────────────────────
  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
      backgroundColor: AppColors.danger,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 3),
    ));
  }

  // ── Tahap 1: Validasi berurutan ─────────────────────────────────────────────
  bool _validasi() {
    if (_namaCtrl.text.trim().isEmpty) {
      _snack('Nama obat tidak boleh kosong');
      return false;
    }
    if (_selectedJenis == null) {
      _snack('Jenis obat tidak boleh kosong');
      return false;
    }
    if (_stokCtrl.text.trim().isEmpty) {
      _snack('Stok harus diisi dengan angka');
      return false;
    }
    final stok = int.tryParse(_stokCtrl.text.trim());
    if (stok == null) {
      _snack('Stok harus diisi dengan angka');
      return false;
    }
    if (stok < 0) {
      _snack('Stok tidak boleh kurang dari 0');
      return false;
    }
    if (_hargaBeliCtrl.text.trim().isEmpty) {
      _snack('Harga beli harus diisi dengan angka');
      return false;
    }
    final hargaBeli = int.tryParse(_hargaBeliCtrl.text.trim());
    if (hargaBeli == null) {
      _snack('Harga beli harus diisi dengan angka');
      return false;
    }
    if (hargaBeli < 1) {
      _snack('Harga beli harus lebih dari 0');
      return false;
    }
    if (_hargaJualCtrl.text.trim().isEmpty) {
      _snack('Harga jual harus diisi dengan angka');
      return false;
    }
    final hargaJual = int.tryParse(_hargaJualCtrl.text.trim());
    if (hargaJual == null) {
      _snack('Harga jual harus diisi dengan angka');
      return false;
    }
    if (hargaJual < 1) {
      _snack('Harga jual harus lebih dari 0');
      return false;
    }
    if (hargaJual < hargaBeli) {
      _snack('Harga jual tidak boleh lebih kecil dari harga beli');
      return false;
    }
    return true;
  }

  // ── Tahap 2: Konfirmasi simpan ──────────────────────────────────────────────
  Future<bool> _konfirmasiSimpan() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi', style: TextStyle(fontFamily: 'Poppins')),
        content: const Text(
          'Apakah Anda yakin ingin menyimpan data obat ini?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simpan', style: TextStyle(fontFamily: 'Poppins', color: AppColors.primary)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ── Tahap 3: Eksekusi API ───────────────────────────────────────────────────
  void _simpan() async {
    if (!_validasi()) return;
    final yakin = await _konfirmasiSimpan();
    if (!yakin || !mounted) return;

    setState(() => _loading = true);
    try {
      _updatedObat = ObatModel(
        idObat: widget.obat.idObat,
        namaObat: _namaCtrl.text.trim(),
        idJenisObat: _selectedJenis!.idJenisObat,
        namaJenisObat: _selectedJenis!.jenisObat,
        stok: int.tryParse(_stokCtrl.text.trim()) ?? 0,
        satuan: widget.obat.satuan,
        tanggalKadaluwarsa: _selectedDate,
        hargaBeli: double.tryParse(_hargaBeliCtrl.text.trim()) ?? 0.0,
        hargaJual: double.tryParse(_hargaJualCtrl.text.trim()) ?? 0.0,
      );

      final provider = context.read<ObatProvider>();
      await provider.updateObat(_updatedObat!);
      if (!mounted) return;

      setState(() {
        _loading = false;
        _berhasil = true;
        _siapTutupPopup = false;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() => _siapTutupPopup = true);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showDialogGagal();
    }
  }

  // ── Dialog gagal API ────────────────────────────────────────────────────────
  void _showDialogGagal() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Gagal', style: TextStyle(fontFamily: 'Poppins')),
        content: const Text(
          'Gagal menyimpan data obat. Silakan coba lagi.',
          style: TextStyle(fontFamily: 'Poppins'),
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

  // ── Konfirmasi batal / keluar ───────────────────────────────────────────────
  Future<void> _konfirmasiBatal() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi', style: TextStyle(fontFamily: 'Poppins')),
        content: const Text(
          'Perubahan belum disimpan. Yakin ingin keluar?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tetap di Sini', style: TextStyle(fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(fontFamily: 'Poppins', color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (result == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _konfirmasiBatal();
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
                onPressed: _berhasil ? null : _konfirmasiBatal,
              ),
              title: const Text('Edit Data Obat', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              shape: const Border(bottom: BorderSide(color: AppColors.border)),
            ),
            bottomNavigationBar: _berhasil ? null : _buildBottomActions(),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  ObatFormCard(children: [
                    _field(label: 'NAMA OBAT', ctrl: _namaCtrl, hint: 'Masukkan Nama Obat'),
                    const SizedBox(height: 16),
                    _jenisDropdown(),
                    const SizedBox(height: 16),
                    _field(label: 'STOK', ctrl: _stokCtrl, hint: 'Masukkan Stok', type: TextInputType.number, fmt: [FilteringTextInputFormatter.digitsOnly]),
                    const SizedBox(height: 16),
                    _dateField(),
                  ]),
                  const SizedBox(height: 12),
                  ObatFormCard(children: [
                    _currField(label: 'HARGA BELI', ctrl: _hargaBeliCtrl, hint: 'Masukkan Harga Beli'),
                    const SizedBox(height: 16),
                    _currField(label: 'HARGA JUAL', ctrl: _hargaJualCtrl, hint: 'Masukkan Harga Jual'),
                  ]),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
          ),
          if (_berhasil) ObatSuccessOverlay(
            message: 'DATA OBAT\nBERHASIL\nDIPERBARUI',
            siapTutup: _siapTutupPopup,
            onDismissResult: _updatedObat,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _btn(label: 'Simpan', icon: Icons.save_rounded, color: AppColors.primary, onTap: _loading ? null : _simpan, loading: _loading),
        const SizedBox(height: 12),
        _btn(label: 'Batal', color: AppColors.danger, onTap: _konfirmasiBatal),
      ]),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  // Dropdown jenis obat — fetched from /api/jenis-obat, pre-selected by idJenisObat
  Widget _jenisDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _lbl('JENIS'),
      const SizedBox(height: 8),
      _loadingJenis
          ? Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            )
          : DropdownButtonFormField<JenisObatModel>(
              value: _selectedJenis,
              isExpanded: true,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textDark),
              decoration: _deco('Pilih Jenis Obat'),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
              items: _jenisObatList.map((j) => DropdownMenuItem(
                value: j,
                child: Text(j.jenisObat, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textDark)),
              )).toList(),
              onChanged: (val) => setState(() => _selectedJenis = val),
            ),
    ]);
  }

  Widget _field({required String label, required TextEditingController ctrl, required String hint, TextInputType type = TextInputType.text, List<TextInputFormatter>? fmt}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _lbl(label),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl,
        keyboardType: type,
        inputFormatters: fmt,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textDark),
        decoration: _deco(hint),
      ),
    ]);
  }

  Widget _currField({required String label, required TextEditingController ctrl, required String hint}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _lbl(label),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textDark),
        decoration: _deco(hint).copyWith(
          prefixText: 'Rp  ',
          prefixStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textMuted),
        ),
      ),
    ]);
  }

  Widget _dateField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _lbl('TANGGAL KADALUWARSA'),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _pickDate,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.borderLight)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(_fmt(_selectedDate), style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textDark)),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
          ]),
        ),
      ),
    ]);
  }

  Widget _btn({required String label, IconData? icon, required Color color, VoidCallback? onTap, bool loading = false}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: color, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (loading) ...[
            const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            const SizedBox(width: 10),
          ] else if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
          ],
          Text(loading ? 'Menyimpan...' : label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        ]),
      ),
    );
  }

  Widget _lbl(String t) => Text(t, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5));

  InputDecoration _deco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.lightGrey),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.danger)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.danger, width: 1.5)),
  );
}
