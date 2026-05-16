// Model data resep dan item resep — mapping ke tabel e_resep & detail_resep (key UPPERCASE)

// Model item resep (satu obat dalam resep) — mapping ke tabel detail_resep
class ResepItem {
  final int idDetail; // PK
  final int? idResep; // FK ke e_resep
  final int? idObat; // FK ke obat
  final String namaObat; // resolved dari eager load relasi obat
  final String dosis; // dosis obat
  final String aturanPakai; // aturan pakai
  final int jumlah; // jumlah obat

  const ResepItem({
    required this.idDetail,
    this.idResep,
    this.idObat,
    required this.namaObat,
    required this.dosis,
    required this.aturanPakai,
    required this.jumlah,
  });

  // Parse dari JSON API (key UPPERCASE, support nested obat)
  factory ResepItem.fromJson(Map<String, dynamic> json) {
    // Resolve nama obat dari nested eager load
    String resolvedNamaObat = '-';
    if (json['obat'] != null && json['obat'] is Map) {
      resolvedNamaObat = json['obat']['NAMA_OBAT'] as String? ?? '-';
    }

    return ResepItem(
      idDetail: json['ID_DETAIL'] as int,
      idResep: json['ID_RESEP'] as int?,
      idObat: json['ID_OBAT'] as int?,
      namaObat: resolvedNamaObat,
      dosis: (json['DOSIS'] as String?) ?? '-',
      aturanPakai: (json['ATURAN_PAKAI'] as String?) ?? '-',
      jumlah: _parseInt(json['JUMLAH']),
    );
  }

  // Parse dynamic ke int (default 1 jika null)
  static int _parseInt(dynamic v) {
    if (v == null) return 1;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 1;
    return 1;
  }

  // Konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'ID_DETAIL': idDetail,
      'ID_RESEP': idResep,
      'ID_OBAT': idObat,
      'DOSIS': dosis,
      'ATURAN_PAKAI': aturanPakai,
      'JUMLAH': jumlah,
    };
  }

  // JSON untuk POST/PUT tanpa PK
  Map<String, dynamic> toJsonForCreate() {
    return {
      'ID_OBAT': idObat,
      'ID_RESEP': idResep,
      'DOSIS': dosis,
      'ATURAN_PAKAI': aturanPakai,
      'JUMLAH': jumlah,
    };
  }
}

// Model data resep (kumpulan item) — mapping ke tabel e_resep
class Resep {
  final int idResep; // PK
  final int? idAntrian; // FK ke antrian
  final int? idRm; // FK ke rekam medis
  final int? idDokter; // FK ke dokter
  final int? idPasien; // FK ke pasien
  final String namaPasien; // resolved dari join/eager load
  final String namaDokter; // resolved dari join/eager load
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<ResepItem> items; // daftar obat dalam resep
  final String statusResep; // AKTIF atau SELESAI
  final String? catatanTambahan; // catatan dari dokter
  final String? foto; // URL foto resep

  const Resep({
    required this.idResep,
    this.idAntrian,
    this.idRm,
    this.idDokter,
    this.idPasien,
    required this.namaPasien,
    required this.namaDokter,
    required this.createdAt,
    this.updatedAt,
    required this.items,
    required this.statusResep,
    this.catatanTambahan,
    this.foto,
  });

  // Parse dari JSON API (key UPPERCASE, support eager load detail_resep)
  factory Resep.fromJson(Map<String, dynamic> json) {
    // Parse detail_resep items dari eager load
    List<ResepItem> parsedItems = [];
    if (json['detail_resep'] != null && json['detail_resep'] is List) {
      parsedItems = (json['detail_resep'] as List)
          .map((item) => ResepItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return Resep(
      idResep: json['ID_RESEP'] as int,
      idAntrian: json['ID_ANTRIAN'] as int?,
      idRm: json['ID_RM'] as int?,
      idDokter: json['ID_DOKTER'] as int?,
      idPasien: json['ID_PASIEN'] as int?,
      // nama pasien & dokter pakai placeholder sampai backend tambah relasi
      namaPasien: (json['NAMA_PASIEN'] as String?) ?? 'Pasien #${json['ID_PASIEN'] ?? '-'}',
      namaDokter: (json['NAMA_DOKTER'] as String?) ?? 'Dokter #${json['ID_DOKTER'] ?? '-'}',
      createdAt: json['CREATED_AT'] != null
          ? DateTime.parse(json['CREATED_AT'] as String)
          : DateTime.now(),
      updatedAt: json['UPDATED_AT'] != null
          ? DateTime.parse(json['UPDATED_AT'] as String)
          : null,
      items: parsedItems,
      statusResep: (json['STATUS_RESEP'] as String?) ?? 'AKTIF',
      catatanTambahan: json['CATATAN_TAMBAHAN'] as String?,
      foto: json['FOTO'] as String?,
    );
  }

  // Konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'ID_RESEP': idResep,
      'ID_ANTRIAN': idAntrian,
      'ID_RM': idRm,
      'ID_DOKTER': idDokter,
      'ID_PASIEN': idPasien,
      'CREATED_AT': createdAt.toIso8601String(),
      'UPDATED_AT': updatedAt?.toIso8601String(),
      'STATUS_RESEP': statusResep,
      'CATATAN_TAMBAHAN': catatanTambahan,
      'FOTO': foto,
    };
  }

  // JSON untuk POST/PUT tanpa PK dan timestamps
  Map<String, dynamic> toJsonForCreate() {
    return {
      'ID_ANTRIAN': idAntrian,
      'ID_RM': idRm,
      'ID_DOKTER': idDokter,
      'ID_PASIEN': idPasien,
      'STATUS_RESEP': statusResep,
      'CATATAN_TAMBAHAN': catatanTambahan,
      'FOTO': foto,
    };
  }

  // Buat salinan dengan field tertentu diganti
  Resep copyWith({
    int? idResep,
    int? idAntrian,
    int? idRm,
    int? idDokter,
    int? idPasien,
    String? namaPasien,
    String? namaDokter,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ResepItem>? items,
    String? statusResep,
    String? catatanTambahan,
    String? foto,
  }) {
    return Resep(
      idResep: idResep ?? this.idResep,
      idAntrian: idAntrian ?? this.idAntrian,
      idRm: idRm ?? this.idRm,
      idDokter: idDokter ?? this.idDokter,
      idPasien: idPasien ?? this.idPasien,
      namaPasien: namaPasien ?? this.namaPasien,
      namaDokter: namaDokter ?? this.namaDokter,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      statusResep: statusResep ?? this.statusResep,
      catatanTambahan: catatanTambahan ?? this.catatanTambahan,
      foto: foto ?? this.foto,
    );
  }

  // Data dummy resep saat API belum tersedia
  static List<Resep> get dummyData => [
        Resep(
          idResep: 1,
          idAntrian: 4,
          idPasien: 10,
          namaPasien: 'Budi Santoso',
          namaDokter: 'dr. Ahmad Wijaya',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          items: const [
            ResepItem(
              idDetail: 1,
              idResep: 1,
              idObat: 4,
              namaObat: 'Diapet',
              dosis: '500mg',
              aturanPakai: '3x1 sehari sesudah makan',
              jumlah: 10,
            ),
            ResepItem(
              idDetail: 2,
              idResep: 1,
              idObat: 3,
              namaObat: 'Bodrex Migra',
              dosis: '1 tablet',
              aturanPakai: 'Jika demam',
              jumlah: 5,
            ),
          ],
          statusResep: 'AKTIF',
        ),
        Resep(
          idResep: 2,
          idAntrian: 5,
          idPasien: 11,
          namaPasien: 'Siti Aminah',
          namaDokter: 'dr. Rina Kartika',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          items: const [
            ResepItem(
              idDetail: 3,
              idResep: 2,
              idObat: 2,
              namaObat: 'Cefadroxil 500mg',
              dosis: '500mg',
              aturanPakai: '2x1 sehari',
              jumlah: 14,
            ),
          ],
          statusResep: 'AKTIF',
        ),
        Resep(
          idResep: 3,
          idAntrian: 1,
          idPasien: 12,
          namaPasien: 'Rina Wijaya',
          namaDokter: 'dr. Ahmad Wijaya',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          items: const [
            ResepItem(
              idDetail: 4,
              idResep: 3,
              idObat: 8,
              namaObat: 'Sangobion',
              dosis: '1 tablet',
              aturanPakai: '1x1 sehari',
              jumlah: 1,
            ),
          ],
          statusResep: 'SELESAI',
        ),
      ];
}
