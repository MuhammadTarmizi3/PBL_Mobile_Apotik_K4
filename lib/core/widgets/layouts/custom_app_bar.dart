// AppBar reusable dengan border bawah dan back button
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

// Custom app bar — title, back button, dan actions
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color titleColor;
  final double elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor = AppColors.surface,
    this.titleColor = AppColors.textDark,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      automaticallyImplyLeading: showBackButton,
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      actions: actions,
      shape: const Border(
        bottom: BorderSide(color: AppColors.border, width: 1),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
