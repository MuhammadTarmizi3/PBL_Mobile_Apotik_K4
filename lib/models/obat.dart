// Model data obat — mapping ke tabel obat + relasi jenis_obat (key UPPERCASE)
class ObatModel {
  final int idObat; // PK
  final String namaObat; // nama obat
  final int? idJenisObat; // FK ke jenis_obat
  final String? namaJenisObat; // resolved dari eager load relasi
  final int stok; // jumlah stok tersedia
  final String satuan; // satuan obat (tablet, kapsul, dll)
  final DateTime tanggalKadaluwarsa; // tanggal expired
  final double hargaBeli; // harga beli dari supplier
  final double hargaJual; // harga jual ke pasien

  // Constructor
  const ObatModel({
    required this.idObat,
    required this.namaObat,
    this.idJenisObat,
    this.namaJenisObat,
    required this.stok,
    required this.satuan,
    required this.tanggalKadaluwarsa,
    required this.hargaBeli,
    required this.hargaJual,
  });

  // True jika obat akan expired dalam 90 hari
  bool get isExpiringSoon {
    final diff = tanggalKadaluwarsa.difference(DateTime.now()).inDays;
    return diff <= 90 && diff >= 0;
  }

  // True jika obat sudah expired
  bool get isExpired => tanggalKadaluwarsa.isBefore(DateTime.now());

  // Format display tanggal expired (bulan/tahun)
  String get expDisplay {
    final m = tanggalKadaluwarsa.month.toString().padLeft(2, '0');
    return 'EXP: $m/${tanggalKadaluwarsa.year}';
  }

  // Buat salinan dengan field tertentu diganti
  ObatModel copyWith({
    int? idObat,
    String? namaObat,
    int? idJenisObat,
    String? namaJenisObat,
    int? stok,
    String? satuan,
    DateTime? tanggalKadaluwarsa,
    double? hargaBeli,
    double? hargaJual,
  }) {
    return ObatModel(
      idObat: idObat ?? this.idObat,
      namaObat: namaObat ?? this.namaObat,
      idJenisObat: idJenisObat ?? this.idJenisObat,
      namaJenisObat: namaJenisObat ?? this.namaJenisObat,
      stok: stok ?? this.stok,
      satuan: satuan ?? this.satuan,
      tanggalKadaluwarsa: tanggalKadaluwarsa ?? this.tanggalKadaluwarsa,
      hargaBeli: hargaBeli ?? this.hargaBeli,
      hargaJual: hargaJual ?? this.hargaJual,
    );
  }

  // Parse dari JSON API (key UPPERCASE, support nested jenis_obat)
  factory ObatModel.fromJson(Map<String, dynamic> json) {
    // Resolve nama jenis obat dari nested eager load
    String? resolvedJenisObat;
    if (json['jenis_obat'] != null && json['jenis_obat'] is Map) {
      resolvedJenisObat = json['jenis_obat']['JENIS_OBAT'] as String?;
    }

    return ObatModel(
      idObat: _parseInt(json['ID_OBAT']),
      namaObat: json['NAMA_OBAT'] as String,
      idJenisObat: _parseIntOpt(json['ID_JENIS_OBAT']),
      namaJenisObat: resolvedJenisObat,
      stok: _parseInt(json['STOK']),
      satuan: (json['SATUAN'] as String?) ?? '-',
      tanggalKadaluwarsa: _parseDate(json['TANGGAL_KADALUWARSA'] ?? json['EXPIRED_DATE']),
      hargaBeli: _parseDouble(json['HARGA_BELI']),
      hargaJual: _parseDouble(json['HARGA_JUAL']),
    );
  }

  // Parse dynamic ke double (API bisa return String atau number)
  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  // Parse dynamic ke int
  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  // Parse dynamic ke int nullable
  static int? _parseIntOpt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  // Parse dynamic ke DateTime
  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is String && v.isNotEmpty) {
      return DateTime.tryParse(v) ?? DateTime.now();
    }
    return DateTime.now();
  }

  // Konversi ke JSON (key UPPERCASE)
  Map<String, dynamic> toJson() {
    return {
      'ID_OBAT': idObat,
      'ID_JENIS_OBAT': idJenisObat,
      'NAMA_OBAT': namaObat,
      'STOK': stok,
      'EXPIRED_DATE': tanggalKadaluwarsa.toIso8601String().split('T').first,
      'HARGA_BELI': hargaBeli,
      'HARGA_JUAL': hargaJual,
    };
  }

  // JSON untuk POST/PUT tanpa PK
  Map<String, dynamic> toJsonForCreate() {
    return {
      'ID_JENIS_OBAT': idJenisObat,
      'NAMA_OBAT': namaObat,
      'STOK': stok,
      'EXPIRED_DATE': tanggalKadaluwarsa.toIso8601String().split('T').first,
      'HARGA_BELI': hargaBeli,
      'HARGA_JUAL': hargaJual,
    };
  }

  // Data dummy obat saat API belum tersedia
  static List<ObatModel> get dummyData => [
        ObatModel(
          idObat: 1,
          namaObat: 'Paracetamol 500mg',
          idJenisObat: 3,
          namaJenisObat: 'Analgesik',
          stok: 120,
          satuan: 'tablet',
          tanggalKadaluwarsa: DateTime(2027, 1, 20),
          hargaBeli: 1500,
          hargaJual: 2500,
        ),
        ObatModel(
          idObat: 2,
          namaObat: 'Cefadroxil 500mg',
          idJenisObat: 1,
          namaJenisObat: 'Antibiotik',
          stok: 80,
          satuan: 'kapsul',
          tanggalKadaluwarsa: DateTime(2027, 5, 1),
          hargaBeli: 3500,
          hargaJual: 5500,
        ),
        ObatModel(
          idObat: 3,
          namaObat: 'Mylanta Cair 50ml',
          idJenisObat: 2,
          namaJenisObat: 'Antasida',
          stok: 45,
          satuan: 'botol',
          tanggalKadaluwarsa: DateTime(2026, 7, 7),
          hargaBeli: 12000,
          hargaJual: 18000,
        ),
        ObatModel(
          idObat: 4,
          namaObat: 'Bodrex Migra',
          idJenisObat: 3,
          namaJenisObat: 'Analgesik',
          stok: 65,
          satuan: 'tablet',
          tanggalKadaluwarsa: DateTime(2026, 12, 15),
          hargaBeli: 2000,
          hargaJual: 3500,
        ),
        ObatModel(
          idObat: 5,
          namaObat: 'Sangobion',
          idJenisObat: 5,
          namaJenisObat: 'Suplemen',
          stok: 60,
          satuan: 'tablet',
          tanggalKadaluwarsa: DateTime(2027, 3, 10),
          hargaBeli: 4500,
          hargaJual: 7000,
        ),
      ];
}
