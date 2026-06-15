// Helper terpusat untuk format tanggal antrian
class DateConstants {
  // Default: real-time (tanggal hari ini)
  // Untuk testing tanggal tertentu, uncomment baris di bawah dan isi tanggal yang diinginkan:
  // static const String? testDate = '2026-06-04';
  static const String? testDate = null;

  static String get todayString {
    if (testDate != null) return testDate!;
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
