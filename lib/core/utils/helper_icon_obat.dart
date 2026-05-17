// Helper mapping jenis obat ke icon — pisahkan UI concern dari data model
import 'package:flutter/material.dart';

// Helper untuk dapat icon berdasarkan jenis obat
class ObatIconHelper {
  // Return icon yang sesuai dengan jenis obat
  static IconData getIcon(String jenisObat) {
    switch (jenisObat.toLowerCase()) {
      case 'antibiotik':
        return Icons.vaccines_rounded;
      case 'antasida':
        return Icons.local_drink_rounded;
      case 'analgesik':
        return Icons.medication_rounded;
      case 'antidiare':
        return Icons.medication_liquid_rounded;
      case 'suplemen':
      case 'vitamin':
        return Icons.local_pharmacy_rounded;
      case 'obat mata':
        return Icons.visibility_rounded;
      case 'antitusif':
        return Icons.air_rounded;
      case 'antipiretik':
        return Icons.thermostat_rounded;
      default:
        return Icons.medication_rounded;
    }
  }
}
