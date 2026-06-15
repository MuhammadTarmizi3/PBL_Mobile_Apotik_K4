// Section informasi profil — email, telepon, ID pegawai dalam kotak
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'profile_info_row.dart';

class ProfileInfoSection extends StatelessWidget {
  final String title;
  final String email;
  final String phone;
  final String employeeId;
  final String employeeIdLabel;

  const ProfileInfoSection({
    super.key,
    this.title = 'Informasi Pribadi',
    required this.email,
    required this.phone,
    required this.employeeId,
    this.employeeIdLabel = 'ID PEGAWAI',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                ProfileInfoRow(icon: Icons.email_outlined, label: 'EMAIL', value: email, divider: true),
                ProfileInfoRow(icon: Icons.phone_outlined, label: 'NOMOR TELEPON', value: phone, divider: true),
                ProfileInfoRow(icon: Icons.badge_outlined, label: employeeIdLabel, value: employeeId, divider: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
