// Header profil dengan foto, nama, dan jabatan
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/app_colors.dart';

// Header profil — avatar, nama, dan role user
class ProfileHeader extends StatelessWidget {
  final String displayName;
  final String roleDisplay;
  final String avatarUrl;
  final double avatarRadius;

  const ProfileHeader({
    super.key,
    required this.displayName,
    required this.roleDisplay,
    required this.avatarUrl,
    this.avatarRadius = 96,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: avatarRadius,
          height: avatarRadius,
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
            image: DecorationImage(
              image: CachedNetworkImageProvider(avatarUrl),
              fit: BoxFit.cover,
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
