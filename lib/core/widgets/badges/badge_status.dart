// Badge status reusable dengan warna dan teks dinamis
import 'package:flutter/material.dart';

// Badge status — label, warna, dan font bisa dikustom
class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsets padding;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w500,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          color: textColor,
          fontWeight: fontWeight,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
