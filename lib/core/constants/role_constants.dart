// Konstanta role — string role, display label, dan helper pengecekan role
class RoleConstants {
  RoleConstants._();

  // ===== STRING ROLE (dari backend API) =====
  static const String admin = 'admin';
  static const String superadmin = 'superadmin';
  static const String adminApotik = 'admin_apotik';
  static const String apoteker = 'apoteker';
  static const String petugas = 'petugas';
  static const String adminPerawat = 'admin_perawat';
  static const String dokter = 'dokter';
  static const String perawat = 'perawat';
  static const String pasien = 'pasien';

  // ===== DISPLAY LABEL =====
  static const String administratorLabel = 'Administrator';
  static const String apotekerLabel = 'Apoteker';
  static const String petugasApotekLabel = 'Petugas Apotek';
  static const String adminPerawatLabel = 'Admin Perawat';
  static const String dokterLabel = 'Dokter';
  static const String perawatLabel = 'Perawat';

  // Konversi role API ke label jabatan yang user-friendly
  static String getDisplayLabel(String? role) {
    switch (role?.toLowerCase() ?? '') {
      case admin:
      case superadmin:
      case adminApotik:
        return administratorLabel;
      case apoteker:
        return apotekerLabel;
      case petugas:
        return petugasApotekLabel;
      case adminPerawat:
        return adminPerawatLabel;
      case dokter:
        return dokterLabel;
      case perawat:
        return perawatLabel;
      default:
        return role ?? '';
    }
  }

  // Cek apakah role termasuk admin (punya akses admin panel)
  static bool isAdmin(String? role) {
    return role == admin || role == superadmin || role == adminApotik;
  }

  // Cek apakah role termasuk petugas (punya akses halaman petugas)
  static bool isPetugas(String? role) {
    return role == petugas ||
        role == adminPerawat ||
        role == apoteker ||
        role == adminApotik ||
        role == perawat ||
        role == dokter;
  }
}
