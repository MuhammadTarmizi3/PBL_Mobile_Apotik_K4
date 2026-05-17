// Card besar total antrian hari ini
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

// Card ringkasan total antrian hari ini
class TodayQueueCard extends StatelessWidget {
  final int totalAntrian;
  final String label;
  final Color backgroundColor;

  const TodayQueueCard({
    super.key,
    required this.totalAntrian,
    this.label = 'ANTRIAN HARI INI',
    this.backgroundColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.lightCyan,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Semantics(
            label: 'Total antrian: $totalAntrian pasien',
            excludeSemantics: true,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$totalAntrian',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: AppColors.surface,
                    ),
                  ),
                  const TextSpan(
                    text: '\u2003\u2003Pasien Lunas',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: AppColors.lightCyan,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
