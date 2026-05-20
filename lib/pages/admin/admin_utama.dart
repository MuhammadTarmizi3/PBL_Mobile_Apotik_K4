// Halaman utama admin — tab navigasi dashboard, obat, profil
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
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
      appBar: _selectedIndex == 2 ? null : _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const DashboardAdminPage(),
          ObatAdminPage(key: _obatKey),
          const ProfileAdminPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
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

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: AppColors.surface, elevation: 0, scrolledUnderElevation: 0,
    automaticallyImplyLeading: false, titleSpacing: 20, toolbarHeight: 64,
    shape: const Border(bottom: BorderSide(color: AppColors.border, width: 1)),
    title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      SvgPicture.asset(AppAssets.logoUtamaLandscape, height: 50, fit: BoxFit.contain),
      CircleAvatar(radius: 18, backgroundImage: AssetImage(AppAssets.fotoProfileAdmin)),
    ]),
  );

  Widget _buildBottomNav() {
    return Container(
      height: 78,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: AppColors.surface,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
        ),
        items: [
          BottomNavigationBarItem(
            icon: _navIcon(Icons.grid_view_rounded, 0),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: _navIcon(Icons.medication_rounded, 1),
            label: 'Obat',
          ),
          BottomNavigationBarItem(
            icon: _navIcon(Icons.person_outline_rounded, 2),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Icon navigasi dengan animasi scale + background saat aktif
  Widget _navIcon(IconData icon, int index) {
    final bool active = _selectedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 220),
        scale: active ? 1.1 : 1.0,
        child: Icon(
          icon,
          size: 22,
          color: active ? AppColors.primary : AppColors.textMuted,
        ),
      ),
    );
  }
}
