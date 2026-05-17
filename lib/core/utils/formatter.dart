// Helper formatting — Rupiah, tanggal, dan utilitas string
class Formatters {
  // Format angka ke format Rupiah (Rp xxx.xxx)
  static String toRupiah(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  // Format tanggal ke MM/YYYY
  static String toMonthYear(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Format tanggal ke DD/MM/YYYY
  static String toDateString(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Nama hari singkat dalam Bahasa Indonesia (Sen, Sel, dst)
  static String toDayName(int weekday) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[weekday - 1];
  }

  // Nama bulan singkat dalam Bahasa Indonesia (Jan, Feb, dst)
  static String toMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }
}
