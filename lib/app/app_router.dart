// Konfigurasi routing app menggunakan go_router dengan auth guard
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../providers/provider_auth.dart';
import '../pages/pembuka.dart';
import '../pages/login/login.dart';
import '../pages/petugas/petugas_utama.dart';
import '../pages/admin/admin_utama.dart';
import '../pages/petugas/dashboard_petugas.dart';
import '../pages/petugas/semua_antrian.dart';
import '../pages/petugas/daftar_eresep.dart';
import '../pages/admin/dashboard_admin.dart';
import '../pages/admin/daftar_obat.dart';
import '../pages/admin/profil_admin.dart';
import '../pages/petugas/profil_petugas.dart';

// Buat GoRouter dengan refreshListenable dari AuthProvider
// Setiap kali auth state berubah, redirect guard dijalankan ulang
GoRouter createAppRouter(AuthProvider authProvider) => GoRouter(
  // refreshListenable: GoRouter re-run redirect guard saat auth berubah
  refreshListenable: authProvider,

  // Redirect guard — cegah akses route tanpa login / role yang salah
  redirect: (context, state) {
    final isLoggedIn = authProvider.isAuthenticated;
    final location = state.matchedLocation;

    // Splash screen — biarkan tampil dulu sebelum redirect
    if (location == '/') {
      return null;
    }

    // Belum login dan bukan di /login — paksa redirect ke login
    if (!isLoggedIn && location != '/login') {
      return '/login';
    }

    // Sudah login tapi coba akses /login — redirect ke home sesuai role
    if (isLoggedIn && location == '/login') {
      // Cek admin dulu karena admin_apotik punya akses admin juga
      if (authProvider.isAdmin) return '/admin';
      if (authProvider.isPetugas) return '/petugas';
    }

    // Lindungi route petugas dari role yang bukan petugas/admin
    if (isLoggedIn && location.startsWith('/petugas') && !authProvider.isPetugas && !authProvider.isAdmin) {
      return '/login';
    }
    // Lindungi route admin — hanya admin yang boleh akses
    if (isLoggedIn && location.startsWith('/admin') && !authProvider.isAdmin) {
      return '/petugas';
    }

    return null;
  },

  // Daftar route aplikasi
  routes: [
    GoRoute(
      path: '/',
      name: 'opening',
      builder: (context, state) => const OpeningPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/petugas',
      name: 'petugas',
      builder: (context, state) => const MainPetugasPage(),
      routes: [
        GoRoute(
          path: 'dashboard',
          name: 'petugas_dashboard',
          builder: (context, state) => const DashboardPetugasPage(),
        ),
        GoRoute(
          path: 'antrian',
          name: 'petugas_antrian',
          builder: (context, state) => const LihatSemuaAntrianPage(),
        ),
        GoRoute(
          path: 'eresep',
          name: 'petugas_eresep',
          builder: (context, state) => const EResepPage(),
        ),
        GoRoute(
          path: 'profile',
          name: 'petugas_profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => const MainAdminPage(),
      routes: [
        GoRoute(
          path: 'dashboard',
          name: 'admin_dashboard',
          builder: (context, state) => const DashboardAdminPage(),
        ),
        GoRoute(
          path: 'obat',
          name: 'admin_obat',
          builder: (context, state) => const ObatAdminPage(),
        ),
        GoRoute(
          path: 'profile',
          name: 'admin_profile',
          builder: (context, state) => const ProfileAdminPage(),
        ),
      ],
    ),
  ],
);

// Extension navigasi — shortcut ke home page sesuai role user
extension Navigation on BuildContext {
  void goToRoleHome(String role) {
    if (role == 'admin') {
      go('/admin');
    } else if (role == 'petugas') {
      go('/petugas');
    }
  }
}
