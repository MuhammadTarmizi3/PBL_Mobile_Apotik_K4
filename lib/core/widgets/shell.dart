// Shell page untuk halaman utama admin & petugas (hindari duplikasi)
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

// Widget shell berisi Scaffold + bottom nav untuk halaman utama
class MainShellPage extends StatefulWidget {
  final String title; // judul halaman
  final List<BottomNavItem> tabs;
  final int initialIndex;
  final Widget Function(int) builder; // callback builder untuk tab content
  final VoidCallback? onTabChanged; // dipanggil saat tab berganti

  const MainShellPage({
    super.key,
    required this.title,
    required this.tabs,
    this.initialIndex = 0,
    required this.builder,
    this.onTabChanged,
  });

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late int _currentIndex; // index tab yang aktif

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: widget.tabs.map((tab) => widget.builder(_currentIndex)).toList(),
      ),
      appBar: _buildAppBar(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Bangun AppBar dengan judul dari widget
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          widget.onTabChanged?.call();
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceMuted,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: widget.tabs.map((tab) {
          return BottomNavigationBarItem(
            icon: Icon(tab.icon, size: 24),
            activeIcon: Icon(tab.activeIcon, size: 24),
            label: tab.label,
          );
        }).toList(),
      ),
    );
  }
}

// Data item untuk bottom navigation bar
class BottomNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const BottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
