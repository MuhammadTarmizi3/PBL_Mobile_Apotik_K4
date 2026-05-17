// Card ringkasan status (belum dipanggil, selesai, dll)
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

// Card kecil ringkasan status antrian
class StatusSummaryCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  final IconData icon;

  const StatusSummaryCard({
    super.key,
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slateGrey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.w400,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
