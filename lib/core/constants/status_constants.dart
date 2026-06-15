// Konstanta status — sentralisasi string status antrian, resep, dan obat
class StatusConstants {
  StatusConstants._();

  // ===== STATUS ANTRIAN RS (API Kelompok 1) =====
  static const String lunas = 'lunas';
  static const String obatDiserahkan = 'obat_diserahkan';

  // ===== STATUS ANTRIAN APOTEK (internal) =====
  static const String menunggu = 'MENUNGGU';
  static const String diproses = 'DIPROSES';
  static const String selesai = 'SELESAI';

  // ===== LABEL DISPLAY =====
  static const String menungguLabel = 'Menunggu';
  static const String diprosesLabel = 'Diproses';
  static const String selesaiLabel = 'Selesai';
  static const String belumDipanggilLabel = 'BELUM DI PANGGIL';
  static const String selesaiDisplayLabel = 'SELESAI';

  // Cek apakah status antrian RS sudah lunas (sudah bayar)
  static bool isLunas(String? status) {
    return status?.toLowerCase() == lunas;
  }

  // Cek apakah status antrian RS sudah diserahkan obatnya
  static bool isObatDiserahkan(String? status) {
    return status?.toLowerCase() == obatDiserahkan;
  }
}
