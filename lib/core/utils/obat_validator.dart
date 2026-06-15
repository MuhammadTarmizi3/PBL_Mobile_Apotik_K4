// Validator form obat — sentralisasi aturan validasi tambah & edit obat
class ObatValidator {
  ObatValidator._();

  // Validasi nama obat (tidak boleh kosong)
  static String? validateNama(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nama obat tidak boleh kosong';
    return null;
  }

  // Validasi jenis obat (harus dipilih)
  static String? validateJenis(bool isSelected) {
    if (!isSelected) return 'Jenis obat tidak boleh kosong';
    return null;
  }

  // Validasi stok (harus angka >= 0)
  static String? validateStok(String? value) {
    if (value == null || value.trim().isEmpty) return 'Stok harus diisi dengan angka';
    final stok = int.tryParse(value.trim());
    if (stok == null) return 'Stok harus diisi dengan angka';
    if (stok < 0) return 'Stok tidak boleh kurang dari 0';
    return null;
  }

  // Validasi tanggal kadaluwarsa (harus diisi)
  static String? validateTanggalKadaluwarsa(DateTime? date) {
    if (date == null) return 'Tanggal kadaluwarsa harus diisi';
    return null;
  }

  // Validasi harga beli (harus angka > 0)
  static String? validateHargaBeli(String? value) {
    if (value == null || value.trim().isEmpty) return 'Harga beli harus diisi dengan angka';
    final harga = int.tryParse(value.trim());
    if (harga == null) return 'Harga beli harus diisi dengan angka';
    if (harga < 1) return 'Harga beli harus lebih dari 0';
    return null;
  }

  // Validasi harga jual (harus angka > 0, tidak boleh < harga beli)
  static String? validateHargaJual(String? value, {String? hargaBeliValue}) {
    if (value == null || value.trim().isEmpty) return 'Harga jual harus diisi dengan angka';
    final hargaJual = int.tryParse(value.trim());
    if (hargaJual == null) return 'Harga jual harus diisi dengan angka';
    if (hargaJual < 1) return 'Harga jual harus lebih dari 0';
    if (hargaBeliValue != null) {
      final hargaBeli = int.tryParse(hargaBeliValue.trim());
      if (hargaBeli != null && hargaJual < hargaBeli) {
        return 'Harga jual tidak boleh lebih kecil dari harga beli';
      }
    }
    return null;
  }

  // Validasi ID obat (khusus tambah obat — harus angka)
  static String? validateIdObat(String? value) {
    if (value == null || value.trim().isEmpty) return 'ID Obat tidak boleh kosong';
    if (int.tryParse(value.trim()) == null) return 'ID Obat harus berupa angka';
    return null;
  }

  // Validasi berurutan lengkap untuk tambah obat — return error pertama atau null
  static String? validateTambahObat({
    required String? idObat,
    required String? namaObat,
    required bool jenisSelected,
    required String? stok,
    required DateTime? tanggalKadaluwarsa,
    required String? hargaBeli,
    required String? hargaJual,
  }) {
    return validateIdObat(idObat) ??
        validateNama(namaObat) ??
        validateJenis(jenisSelected) ??
        validateStok(stok) ??
        validateTanggalKadaluwarsa(tanggalKadaluwarsa) ??
        validateHargaBeli(hargaBeli) ??
        validateHargaJual(hargaJual, hargaBeliValue: hargaBeli);
  }

  // Validasi berurutan lengkap untuk edit obat — return error pertama atau null
  static String? validateEditObat({
    required String? namaObat,
    required bool jenisSelected,
    required String? stok,
    required String? hargaBeli,
    required String? hargaJual,
  }) {
    return validateNama(namaObat) ??
        validateJenis(jenisSelected) ??
        validateStok(stok) ??
        validateHargaBeli(hargaBeli) ??
        validateHargaJual(hargaJual, hargaBeliValue: hargaBeli);
  }
}
