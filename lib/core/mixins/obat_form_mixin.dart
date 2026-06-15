// Mixin form obat — helper field, dekorasi, tombol, dropdown, date picker
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../utils/formatter.dart';
import '../../models/jenis_obat.dart';

/// Mixin yang menyediakan helper form identik untuk tambah_obat & edit_obat.
///
/// Kelas yang menggunakan mixin ini harus menyediakan:
/// - [selectedDate] / setter untuk tanggal kadaluwarsa
/// - [selectedJenis] / setter untuk jenis obat terpilih
/// - [jenisObatList] — daftar jenis obat untuk dropdown
/// - [loadingJenis] — flag loading dropdown
mixin ObatFormMixin<W extends StatefulWidget> on State<W> {
  // ── Abstract: disediakan oleh subclass ──────────────────────────────────
  DateTime? get selectedDate;
  set selectedDate(DateTime? value);
  JenisObatModel? get selectedJenis;
  set selectedJenis(JenisObatModel? value);
  List<JenisObatModel> get jenisObatList;
  bool get loadingJenis;

  // ── Date picker ─────────────────────────────────────────────────────────
  Future<void> pickDate() async {
    final now = DateTime.now();
    final p = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(now.year + 1, now.month),
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
    if (p != null) setState(() => selectedDate = p);
  }

  String fmtDate(DateTime d) => Formatters.toDateString(d);

  // ── Dropdown jenis obat ─────────────────────────────────────────────────
  Widget jenisDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      formLabel('JENIS'),
      const SizedBox(height: 8),
      loadingJenis
          ? Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            )
          : DropdownButtonFormField<JenisObatModel>(
              initialValue: selectedJenis,
              isExpanded: true,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textDark),
              decoration: formDecoration('Pilih Jenis Obat'),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
              items: jenisObatList.map((j) => DropdownMenuItem(
                value: j,
                child: Text(j.jenisObat, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textDark)),
              )).toList(),
              onChanged: (val) => setState(() => selectedJenis = val),
            ),
    ]);
  }

  // ── Text field ──────────────────────────────────────────────────────────
  Widget formField({
    required String label,
    required TextEditingController ctrl,
    required String hint,
    TextInputType type = TextInputType.text,
    List<TextInputFormatter>? fmt,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      formLabel(label),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl,
        keyboardType: type,
        inputFormatters: fmt,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textDark),
        decoration: formDecoration(hint),
      ),
    ]);
  }

  // ── Currency field (Rp prefix) ──────────────────────────────────────────
  Widget currencyField({
    required String label,
    required TextEditingController ctrl,
    required String hint,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      formLabel(label),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textDark),
        decoration: formDecoration(hint).copyWith(
          prefixText: 'Rp  ',
          prefixStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textMuted),
        ),
      ),
    ]);
  }

  // ── Date field ──────────────────────────────────────────────────────────
  Widget dateField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      formLabel('TANGGAL KADALUWARSA'),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: pickDate,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              selectedDate != null ? fmtDate(selectedDate!) : 'Pilih Tanggal',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: selectedDate != null ? AppColors.textDark : AppColors.lightGrey,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
          ]),
        ),
      ),
    ]);
  }

  // ── Action button dengan loading state ──────────────────────────────────
  Widget formButton({
    required String label,
    IconData? icon,
    required Color color,
    VoidCallback? onTap,
    bool loading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (loading) ...[
            const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            const SizedBox(width: 10),
          ] else if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            loading ? 'Menyimpan...' : label,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ]),
      ),
    );
  }

  // ── Label teks kecil ────────────────────────────────────────────────────
  Widget formLabel(String t) => Text(
    t,
    style: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppColors.textMuted,
      letterSpacing: 0.5,
    ),
  );

  // ── InputDecoration konsisten ───────────────────────────────────────────
  InputDecoration formDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.lightGrey),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.borderLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.danger),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
    ),
  );
}
