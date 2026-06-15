// Header profil dengan avatar foto lokal, nama, dan jabatan
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ProfileAvatarHeader extends StatelessWidget {
  final String displayName;
  final String roleDisplay;
  final String photoAsset;
  final String? emailFallback;

  const ProfileAvatarHeader({
    super.key,
    required this.displayName,
    required this.roleDisplay,
    required this.photoAsset,
    this.emailFallback,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surface, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              photoAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                final initial = (emailFallback ?? 'A')[0].toUpperCase();
                return Container(
                  color: AppColors.primary,
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          displayName,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          roleDisplay,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryLight,
          ),
        ),
      ],
    );
  }
}
