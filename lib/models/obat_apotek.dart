// Model obat di rak apotek untuk UI penyerahan e-Resep (type-safe, bukan raw Map)
class ObatApotek {
  final int idObat; // PK obat
  final String namaObat; // nama obat
  final String? namaJenisObat; // resolved dari jenis_obat
  final DateTime tanggalKadaluwarsa; // tanggal expired
  int stok; // mutable agar bisa update setelah simpan
  int jumlahDiambil; // mutable untuk UI counter (+/-)

  ObatApotek({
    required this.idObat,
    required this.namaObat,
    this.namaJenisObat,
    required this.tanggalKadaluwarsa,
    required this.stok,
    this.jumlahDiambil = 0,
  });

  // True jika belum diambil sama sekali
  bool get belumDiambil => jumlahDiambil == 0;

  // True jika masih bisa ditambah (belum mentok stok)
  bool get bisaDitambah => jumlahDiambil < stok;

  // Parse dari JSON API (key UPPERCASE, untuk UI state penyerahan resep)
  factory ObatApotek.fromJson(Map<String, dynamic> json) {
    // Resolve nama jenis obat dari nested eager load
    String? resolvedJenisObat;
    if (json['jenis_obat'] != null && json['jenis_obat'] is Map) {
      resolvedJenisObat = json['jenis_obat']['JENIS_OBAT'] as String?;
    }

    return ObatApotek(
      idObat: json['ID_OBAT'] as int,
      namaObat: json['NAMA_OBAT'] as String,
      namaJenisObat: resolvedJenisObat,
      tanggalKadaluwarsa: json['EXPIRED_DATE'] != null
          ? DateTime.parse(json['EXPIRED_DATE'] as String)
          : DateTime.now(),
      stok: (json['STOK'] as num?)?.toInt() ?? 0,
      jumlahDiambil: (json['jumlahDiambil'] as int?) ?? 0, // UI state, bukan dari DB
    );
  }

  // Konversi ke JSON (key UPPERCASE)
  Map<String, dynamic> toJson() {
    return {
      'ID_OBAT': idObat,
      'NAMA_OBAT': namaObat,
      'NAMA_JENIS_OBAT': namaJenisObat,
      'EXPIRED_DATE': tanggalKadaluwarsa.toIso8601String().split('T').first,
      'STOK': stok,
      'jumlahDiambil': jumlahDiambil, // UI state
    };
  }
}
