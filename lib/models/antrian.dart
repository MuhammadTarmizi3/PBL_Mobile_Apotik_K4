// Model data antrian pengambilan obat dari API apotek
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

// Enum status antrian: menunggu, diproses, selesai
enum AntrianStatus {
  menunggu,
  diproses,
  selesai,
}

// Extension untuk label, warna, dan ikon status antrian
extension AntrianStatusX on AntrianStatus {
  String get label {
    switch (this) {
      case AntrianStatus.menunggu:
        return 'Menunggu';
      case AntrianStatus.diproses:
        return 'Diproses';
      case AntrianStatus.selesai:
        return 'Selesai';
    }
  }

  String get listLabel {
    switch (this) {
      case AntrianStatus.menunggu:
        return 'Menunggu';
      case AntrianStatus.diproses:
        return 'Sedang Diproses';
      case AntrianStatus.selesai:
        return 'Selesai';
    }
  }

  Color get color {
    switch (this) {
      case AntrianStatus.menunggu:
        return AppColors.warning;
      case AntrianStatus.diproses:
        return AppColors.teal;
      case AntrianStatus.selesai:
        return AppColors.primaryLight;
    }
  }

  Color get badgeColor {
    return color;
  }

  IconData get icon {
    switch (this) {
      case AntrianStatus.menunggu:
        return Icons.hourglass_bottom_rounded;
      case AntrianStatus.diproses:
        return Icons.notifications_active_rounded;
      case AntrianStatus.selesai:
        return Icons.check_circle_rounded;
    }
  }
}

// Model data antrian — mapping ke tabel antrian_pengambilan_obat
class Antrian {
  final int idAntrian; // PK
  final String nomorAntrian; // nomor urut antrian
  final String namaPasien; // resolved dari join tabel pasien
  final int? idResep; // FK ke e_resep
  final AntrianStatus status;

  const Antrian({
    required this.idAntrian,
    required this.nomorAntrian,
    required this.namaPasien,
    required this.idResep,
    required this.status,
  });

  // Buat salinan dengan field tertentu diganti
  Antrian copyWith({
    int? idAntrian,
    String? nomorAntrian,
    String? namaPasien,
    int? idResep,
    AntrianStatus? status,
  }) {
    return Antrian(
      idAntrian: idAntrian ?? this.idAntrian,
      nomorAntrian: nomorAntrian ?? this.nomorAntrian,
      namaPasien: namaPasien ?? this.namaPasien,
      idResep: idResep ?? this.idResep,
      status: status ?? this.status,
    );
  }

  // Parse dari JSON API (dukung format SIMRS & Apotik)
  factory Antrian.fromJson(Map<String, dynamic> json) {
    final idAntrian = _readInt(json, ['ID_ANTRIAN', 'id_antrian', 'id']) ?? 0;
    final nomorAntrian = _readString(json, ['NOMOR_ANTRIAN', 'nomor_antrian', 'nomor']) ?? '-';
    final idResep = _readInt(json, ['ID_RESEP', 'id_resep', 'id_pendaftaran', 'pendaftaran_id']);
    final namaPasien = _resolveNamaPasien(json, idAntrian);
    final status = _parseStatus(_readString(json, ['STATUS', 'status']));

    return Antrian(
      idAntrian: idAntrian,
      nomorAntrian: nomorAntrian,
      namaPasien: namaPasien,
      idResep: idResep,
      status: status,
    );
  }

  // Baca int dari berbagai kemungkinan key
  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
    }
    return null;
  }

  // Baca string dari berbagai kemungkinan key
  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  // Resolve nama pasien dari nested object atau field langsung
  static String _resolveNamaPasien(Map<String, dynamic> json, int idAntrian) {
    final direct = _readString(json, ['NAMA_PASIEN', 'nama_pasien', 'nama_lengkap']);
    if (direct != null) return direct;

    final pasien = json['pasien'];
    if (pasien is Map<String, dynamic>) {
      final nama = _readString(pasien, ['nama_lengkap', 'NAMA_LENGKAP', 'nama']);
      if (nama != null) return nama;
    }

    final pendaftaran = json['pendaftaran'];
    if (pendaftaran is Map<String, dynamic>) {
      final nama = _readString(pendaftaran, ['nama_lengkap', 'NAMA_LENGKAP', 'nama']);
      if (nama != null) return nama;
    }

    return 'Pasien #$idAntrian';
  }

  // Parse string status ke enum AntrianStatus
  static AntrianStatus _parseStatus(String? statusString) {
    final normalized = statusString?.toUpperCase().trim() ?? '';

    switch (normalized) {
      case 'DIPROSES':
        return AntrianStatus.diproses;
      case 'SELESAI':
        return AntrianStatus.selesai;
      case 'MENUNGGU':
      default:
        return AntrianStatus.menunggu;
    }
  }

  // Status string UPPERCASE untuk dikirim ke API
  String get statusForApi {
    switch (status) {
      case AntrianStatus.menunggu:
        return 'MENUNGGU';
      case AntrianStatus.diproses:
        return 'DIPROSES';
      case AntrianStatus.selesai:
        return 'SELESAI';
    }
  }

  // Konversi ke JSON (key UPPERCASE)
  Map<String, dynamic> toJson() {
    // Konversi enum ke UPPERCASE string untuk API
    String statusString = status.name.toUpperCase();
    
    return {
      'ID_ANTRIAN': idAntrian,
      'NOMOR_ANTRIAN': nomorAntrian,
      'NAMA_PASIEN': namaPasien,
      'ID_RESEP': idResep,
      'STATUS': statusString,
    };
  }

  // JSON untuk POST/PUT tanpa PK (auto-increment)
  Map<String, dynamic> toJsonForCreate() {
    String statusString = status.name.toUpperCase();
    
    return {
      'NOMOR_ANTRIAN': nomorAntrian,
      'ID_RESEP': idResep,
      'STATUS': statusString,
    };
  }

  // Data dummy untuk testing tanpa API
  static List<Antrian> dummyData = [
    Antrian(
      idAntrian: 4,
      nomorAntrian: 'A04',
      namaPasien: 'Budi Santoso',
      idResep: 1,
      status: AntrianStatus.diproses,
    ),
    Antrian(
      idAntrian: 5,
      nomorAntrian: 'A05',
      namaPasien: 'Siti Aminah',
      idResep: 2,
      status: AntrianStatus.menunggu,
    ),
    Antrian(
      idAntrian: 6,
      nomorAntrian: 'A06',
      namaPasien: 'Ahmad Rizki',
      idResep: 3,
      status: AntrianStatus.menunggu,
    ),
    Antrian(
      idAntrian: 7,
      nomorAntrian: 'A07',
      namaPasien: 'Dewi Lestari',
      idResep: 4,
      status: AntrianStatus.menunggu,
    ),
    Antrian(
      idAntrian: 8,
      nomorAntrian: 'A08',
      namaPasien: 'Eko Prasetyo',
      idResep: 5,
      status: AntrianStatus.menunggu,
    ),
    Antrian(
      idAntrian: 1,
      nomorAntrian: 'A01',
      namaPasien: 'Rina Wijaya',
      idResep: 6,
      status: AntrianStatus.selesai,
    ),
    Antrian(
      idAntrian: 2,
      nomorAntrian: 'A02',
      namaPasien: 'Joko Susilo',
      idResep: 7,
      status: AntrianStatus.selesai,
    ),
    Antrian(
      idAntrian: 3,
      nomorAntrian: 'A03',
      namaPasien: 'Fatimah Zahra',
      idResep: 8,
      status: AntrianStatus.diproses,
    ),
  ];
}

// Extension AntrianListX dipindahkan ke AntrianProvider
// untuk separation of concerns (business logic tidak di model)
