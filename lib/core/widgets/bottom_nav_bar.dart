// Bottom navigasi animasi — shared untuk admin & petugas shell
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AnimatedBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItemData> items;

  const AnimatedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
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
          items: items.asMap().entries.map((entry) {
            return BottomNavigationBarItem(
              icon: _NavIcon(icon: entry.value.icon, isActive: currentIndex == entry.key),
              label: entry.value.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Icon navigasi dengan animasi scale + background saat aktif
class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;

  const _NavIcon({required this.icon, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 220),
        scale: isActive ? 1.1 : 1.0,
        child: Icon(
          icon,
          size: 22,
          color: isActive ? AppColors.primary : AppColors.textMuted,
        ),
      ),
    );
  }
}

// Data item untuk bottom navigation bar
class BottomNavItemData {
  final IconData icon;
  final String label;

  const BottomNavItemData({required this.icon, required this.label});
}
