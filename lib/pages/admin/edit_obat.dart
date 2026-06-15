// Halaman edit obat — form update data obat + validasi & submit ke API
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/mixins/obat_form_mixin.dart';
import '../../core/utils/obat_validator.dart';
import '../../core/widgets/dialog_konfirmasi.dart';
import '../../core/widgets/overlay_berhasil.dart';
import '../../core/widgets/snackbar.dart';
import '../../models/jenis_obat.dart';
import '../../models/obat.dart';
import '../../providers/provider_obat.dart';
import '../../services/service_jenis_obat.dart';
import 'widgets/obat_form_card.dart';

// Halaman edit obat dengan form dan validasi
class EditObatAdminPage extends StatefulWidget {
  final ObatModel obat;
  const EditObatAdminPage({super.key, required this.obat});

  @override
  State<EditObatAdminPage> createState() => _EditObatAdminPageState();
}

class _EditObatAdminPageState extends State<EditObatAdminPage> with ObatFormMixin<EditObatAdminPage> {
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

  // ── ObatFormMixin abstract impl ──────────────────────────────────────────
  @override DateTime? get selectedDate => _selectedDate;
  @override set selectedDate(DateTime? value) { if (value != null) _selectedDate = value; }
  @override JenisObatModel? get selectedJenis => _selectedJenis;
  @override set selectedJenis(JenisObatModel? value) => _selectedJenis = value;
  @override List<JenisObatModel> get jenisObatList => _jenisObatList;
  @override bool get loadingJenis => _loadingJenis;

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

  // ── Tahap 1: Validasi berurutan — delegate ke ObatValidator terpusat ──────
  bool _validasi() {
    final error = ObatValidator.validateEditObat(
      namaObat: _namaCtrl.text,
      jenisSelected: _selectedJenis != null,
      stok: _stokCtrl.text,
      hargaBeli: _hargaBeliCtrl.text,
      hargaJual: _hargaJualCtrl.text,
    );
    if (error != null) {
      showAppSnackBar(context, error, backgroundColor: AppColors.danger);
      return false;
    }
    return true;
  }

  // ── Tahap 2: Konfirmasi simpan — delegate ke ConfirmDialog terpusat ─────────
  Future<bool> _konfirmasiSimpan() async {
    return ConfirmDialog.show(context, ConfirmDialog.simpan(context));
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

  // ── Dialog gagal API — delegate ke ErrorDialog terpusat ────────────────
  void _showDialogGagal() {
    ErrorDialog.show(context, ErrorDialog.gagalSimpan());
  }

  // ── Konfirmasi batal / keluar — delegate ke ConfirmDialog terpusat ───
  Future<void> _konfirmasiBatal() async {
    final yakin = await ConfirmDialog.show(context, ConfirmDialog.keluar());
    if (yakin && mounted) Navigator.pop(context);
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
                    formField(label: 'NAMA OBAT', ctrl: _namaCtrl, hint: 'Masukkan Nama Obat'),
                    const SizedBox(height: 16),
                    jenisDropdown(),
                    const SizedBox(height: 16),
                    formField(label: 'STOK', ctrl: _stokCtrl, hint: 'Masukkan Stok', type: TextInputType.number, fmt: [FilteringTextInputFormatter.digitsOnly]),
                    const SizedBox(height: 16),
                    dateField(),
                  ]),
                  const SizedBox(height: 12),
                  ObatFormCard(children: [
                    currencyField(label: 'HARGA BELI', ctrl: _hargaBeliCtrl, hint: 'Masukkan Harga Beli'),
                    const SizedBox(height: 16),
                    currencyField(label: 'HARGA JUAL', ctrl: _hargaJualCtrl, hint: 'Masukkan Harga Jual'),
                  ]),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
          ),
          if (_berhasil) SuccessOverlay(
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
        formButton(label: 'Simpan', icon: Icons.save_rounded, color: AppColors.primary, onTap: _loading ? null : _simpan, loading: _loading),
        const SizedBox(height: 12),
        formButton(label: 'Batal', color: AppColors.danger, onTap: _konfirmasiBatal),
      ]),
    );
  }

}
