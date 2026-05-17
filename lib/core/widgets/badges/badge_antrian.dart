// Badge nomor antrian dengan CircleAvatar
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

// Badge lingkaran untuk nomor antrian
class AntrianBadge extends StatelessWidget {
  final String nomorAntrian;
  final Color backgroundColor;
  final Color textColor;
  final double radius;
  final double fontSize;

  const AntrianBadge({
    super.key,
    required this.nomorAntrian,
    this.backgroundColor = AppColors.mint,
    this.textColor = AppColors.teal,
    this.radius = 24,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Nomor antrian $nomorAntrian',
      child: CircleAvatar(
        backgroundColor: backgroundColor,
        radius: radius,
        child: Text(
          nomorAntrian,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
