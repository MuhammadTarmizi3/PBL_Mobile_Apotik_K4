// Konstanta API — base URL, endpoint, dan feature flag untuk semua modul
class ApiConstants {
  ApiConstants._();

  // Feature flag — false = pakai data dummy, true = endpoint sudah live
  static const bool apotikApiEnabled = true;

  // Base URL untuk semua API request
  static String get baseUrl => _resolveBaseUrl();

  // Alias untuk modul SIMRS (auth + antrian RS)
  static String get simrsBaseUrl => baseUrl;
  static String get apotikBaseUrl => apotikServerUrl;

  // Server SIMRS Kelompok 1 (VPS Poliban) — auth & antrian RS
  static const String simrsServerUrl = 'https://daftar4b06.vps-poliban.my.id/api';

  // Server API Apotik Kelompok 4 (VPS Poliban)
  static const String apotikServerUrl = 'https://farmasi4b06.vps-poliban.my.id/api';

  static String _resolveBaseUrl() {
    const environment = Environment.development;

    switch (environment) {
      case Environment.development:
      case Environment.production:
        return simrsServerUrl;
    }
  }

  static const String auth = '/auth';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String authMe = '/auth/me';
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh';

  // Antrian RS dari API Kelompok 1
  static const String antrianRs = '/antrian';

  static const String obat = '/obat';
  static const String jenisObat = '/jenis-obat';
  static const String eResep = '/e-resep';
  static const String detailResep = '/detail-resep';
  static const String antrianPengambilanObat = '/antrian-pengambilan-obat';
  static const String detailPengambilanAntrian = '/detail-pengambilan-antrian';

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  static const int sendTimeout = 15000;
}

enum Environment {
  development,
  production,
}
