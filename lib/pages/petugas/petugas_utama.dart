// Halaman utama petugas — tab navigasi dashboard, e-Resep, profil
import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/widgets/logo_app_bar.dart';
import 'dashboard_petugas.dart';
import 'daftar_eresep.dart';
import 'profil_petugas.dart';

// Shell utama petugas — kelola AppBar, BottomNav, dan IndexedStack antar tab
class MainPetugasPage extends StatefulWidget {
  const MainPetugasPage({super.key});

  @override
  State<MainPetugasPage> createState() => _MainPetugasPageState();
}

class _MainPetugasPageState extends State<MainPetugasPage> {
  int _selectedIndex = 0; // tab aktif: 0=Dashboard, 1=E-Resep, 2=Profile

  @override
  void initState() {
    super.initState();
    // TODO: Uncomment ketika endpoint /antrian-pengambilan-obat sudah tersedia
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<AntrianProvider>().fetchAntrian();
    // });
  }

  // Daftar halaman per tab (const agar hemat memori)
  static const List<Widget> _pages = [
    DashboardPetugasPage(),
    EResepPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _selectedIndex == 2 ? null : const LogoAppBar(profileAsset: AppAssets.fotoProfileApoteker01),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavItemData(icon: Icons.grid_view_rounded, label: 'Dashboard'),
          BottomNavItemData(icon: Icons.receipt_long_rounded, label: 'E-Resep'),
          BottomNavItemData(icon: Icons.person_outline_rounded, label: 'Profile'),
        ],
      ),
    );
  }

}
