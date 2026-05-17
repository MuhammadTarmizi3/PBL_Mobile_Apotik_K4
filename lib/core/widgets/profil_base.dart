// Widget profil base reusable untuk admin dan petugas
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants/app_colors.dart';

// Base profile page — reusable untuk admin & petugas (hindari duplikasi)
class BaseProfilePage extends StatelessWidget {
  final String name;
  final String role;
  final String email;
  final String phone;
  final String employeeId;
  final String avatarUrl;
  final VoidCallback? onEditPressed;
  final List<ProfileMenuItem> menuItems;

  const BaseProfilePage({
    super.key,
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.employeeId,
    required this.avatarUrl,
    this.onEditPressed,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildEmployeeInfo(),
            const SizedBox(height: 24),
            ...menuItems.map((item) => _buildMenuItem(item)),
            const SizedBox(height: 24),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.backgroundLight,
          backgroundImage: CachedNetworkImageProvider(avatarUrl),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          role,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
        if (onEditPressed != null) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onEditPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text(
              'Edit Profil',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmployeeInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Karyawan',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('ID Karyawan', employeeId),
          const SizedBox(height: 12),
          _buildInfoRow('Email', email),
          const SizedBox(height: 12),
          _buildInfoRow('Telepon', phone),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(ProfileMenuItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            item.icon,
            color: item.color,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.onSurfaceMuted,
        ),
        onTap: item.onPressed,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text(
              'Apakah Anda yakin ingin logout?',
              style: TextStyle(
                fontFamily: 'Poppins',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement logout logic
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: AppColors.error, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      icon: const Icon(Icons.logout_rounded),
      label: const Text(
        'Logout',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Data item menu di halaman profil
class ProfileMenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const ProfileMenuItem({
    required this.title,
    required this.icon,
    required this.color,
    this.onPressed,
  });
}
