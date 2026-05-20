// Halaman utama petugas — tab navigasi dashboard, e-Resep, profil
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
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
      appBar: _selectedIndex == 2 ? null : _buildAppBar(),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // AppBar dengan logo kiri dan foto profil kanan
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface, // Warna background atas (putih)
      elevation: 0, // Menghilangkan garis bayangan
      scrolledUnderElevation: 0, // Mencegah warna berubah saat di-scroll
      automaticallyImplyLeading: false, // Menghapus tombol panah back bawaan
      titleSpacing: 20, // Memberi jarak tepi untuk judul
      toolbarHeight: 64, // Tinggi AppBar disesuaikan (agak tinggi)
      
      // Membuat garis bawah yang tipis untuk batas AppBar
      shape: const Border(
        bottom: BorderSide(color: AppColors.border, width: 1),
      ),
      
      // Isi konten AppBar (kiri: Logo, kanan: Foto Profil)
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Agar logo dan profil saling berjauhan (rata ujung kiri dan kanan)
        children: [
          // SvgPicture untuk menampilkan logo format .svg
          SvgPicture.asset(
            AppAssets.logoUtamaLandscape,
            height: 50,
            fit: BoxFit.contain,
          ),
          
          // CircleAvatar untuk membuat gambar profil jadi bulat sempurna
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(AppAssets.fotoProfileApoteker01),
          ),
        ],
      ),
    );
  }

  // Bottom nav dengan 3 menu: Dashboard, E-Resep, Profile
  Widget _buildBottomNav() {
    return Container(
      height: 78, // Tinggi container navigasi bawah
      // Dekorasi untuk membuat border atas
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      // Widget BottomNavigationBar untuk menampilkan menu navigasi
      child: BottomNavigationBar(
        currentIndex: _selectedIndex, // Index tab yang sedang aktif
        // Fungsi yang dipanggil saat user tap salah satu menu
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Mengubah tab aktif
          });
        },
        backgroundColor: AppColors.surface, // Warna background navigasi
        elevation: 0, // Menghilangkan bayangan
        type: BottomNavigationBarType.fixed, // Tipe fixed agar semua item terlihat
        selectedItemColor: AppColors.primary, // Warna item yang dipilih
        unselectedItemColor: AppColors.textMuted, // Warna item yang tidak dipilih
        // Style untuk label item yang dipilih
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        // Style untuk label item yang tidak dipilih
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
        ),
        // Daftar item menu navigasi
        items: [
          BottomNavigationBarItem(
            icon: _navIcon(Icons.grid_view_rounded, 0), // Icon Dashboard
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: _navIcon(Icons.receipt_long_rounded, 1), // Icon E-Resep
            label: 'E-Resep',
          ),
          BottomNavigationBarItem(
            icon: _navIcon(Icons.person_outline_rounded, 2), // Icon Profile
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Icon navbar dengan animasi background saat aktif
  Widget _navIcon(IconData icon, int index) {
    final bool active = _selectedIndex == index; // Cek apakah icon ini sedang aktif

    // AnimatedContainer untuk membuat animasi perubahan background
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220), // Durasi animasi
      curve: Curves.easeInOut, // Kurva animasi yang smooth
      padding: const EdgeInsets.all(8), // Padding dalam icon
      // Dekorasi background yang berubah saat aktif
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.12) // Background biru transparan saat aktif
            : Colors.transparent, // Transparan saat tidak aktif
        borderRadius: BorderRadius.circular(12), // Sudut melengkung
      ),
      // AnimatedScale untuk membuat efek zoom saat icon aktif
      child: AnimatedScale(
        duration: const Duration(milliseconds: 220), // Durasi animasi
        scale: active ? 1.1 : 1.0, // Scale 1.1x saat aktif, 1.0x saat tidak
        child: Icon(
          icon,
          size: 22, // Ukuran icon
          color: active ? AppColors.primary : AppColors.textMuted, // Warna berubah sesuai status
        ),
      ),
    );
  }
}
