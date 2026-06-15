// Halaman utama admin — tab navigasi dashboard, obat, profil
import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/widgets/logo_app_bar.dart';
import 'dashboard_admin.dart';
import 'daftar_obat.dart';
import 'profil_admin.dart';

// Widget utama admin dengan bottom tab navigasi
class MainAdminPage extends StatefulWidget {
  const MainAdminPage({super.key});

  @override
  State<MainAdminPage> createState() => _MainAdminPageState();
}

class _MainAdminPageState extends State<MainAdminPage> {
  int _selectedIndex = 0;
  final GlobalKey<ObatAdminPageState> _obatKey = GlobalKey<ObatAdminPageState>();

  @override
  Widget build(BuildContext context) {
    // Scaffold sebagai kerangka dasar halaman
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _selectedIndex == 2 ? null : const LogoAppBar(profileAsset: AppAssets.fotoProfileAdmin),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const DashboardAdminPage(),
          ObatAdminPage(key: _obatKey),
          const ProfileAdminPage(),
        ],
      ),
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavItemData(icon: Icons.grid_view_rounded, label: 'Dashboard'),
          BottomNavItemData(icon: Icons.medication_rounded, label: 'Obat'),
          BottomNavItemData(icon: Icons.person_outline_rounded, label: 'Profile'),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => _obatKey.currentState?.navigasiTambahObat(),
              backgroundColor: AppColors.tealBright,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            )
          : null,
    );
  }


}
