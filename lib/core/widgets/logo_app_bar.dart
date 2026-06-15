// AppBar utama dengan logo kiri dan foto profil kanan — shared untuk admin & petugas
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_assets.dart';
import '../constants/app_colors.dart';

class LogoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String profileAsset;

  const LogoAppBar({super.key, required this.profileAsset});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      toolbarHeight: 64,
      shape: const Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(AppAssets.logoUtamaLandscape, height: 50, fit: BoxFit.contain),
          CircleAvatar(radius: 18, backgroundImage: AssetImage(profileAsset)),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
