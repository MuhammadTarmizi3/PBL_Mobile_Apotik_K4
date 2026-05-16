// Model data jenis/kategori obat — mapping ke tabel jenis_obat (key UPPERCASE)
class JenisObatModel {
  final int idJenisObat; // PK
  final String jenisObat; // nama jenis obat

  const JenisObatModel({
    required this.idJenisObat,
    required this.jenisObat,
  });

  // Parse dari JSON API (key UPPERCASE)
  factory JenisObatModel.fromJson(Map<String, dynamic> json) {
    return JenisObatModel(
      idJenisObat: json['ID_JENIS_OBAT'] as int,
      jenisObat: json['JENIS_OBAT'] as String,
    );
  }

  // Konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'ID_JENIS_OBAT': idJenisObat,
      'JENIS_OBAT': jenisObat,
    };
  }

  // JSON untuk POST/PUT tanpa PK
  Map<String, dynamic> toJsonForCreate() {
    return {
      'JENIS_OBAT': jenisObat,
    };
  }

  // Data dummy jenis obat
  static List<JenisObatModel> dummyData = [
    const JenisObatModel(idJenisObat: 1, jenisObat: 'Antibiotik'),
    const JenisObatModel(idJenisObat: 2, jenisObat: 'Antasida'),
    const JenisObatModel(idJenisObat: 3, jenisObat: 'Analgesik'),
    const JenisObatModel(idJenisObat: 4, jenisObat: 'Antidiare'),
    const JenisObatModel(idJenisObat: 5, jenisObat: 'Suplemen'),
    const JenisObatModel(idJenisObat: 6, jenisObat: 'Vitamin'),
    const JenisObatModel(idJenisObat: 7, jenisObat: 'Obat Mata'),
    const JenisObatModel(idJenisObat: 8, jenisObat: 'Antitusif'),
    const JenisObatModel(idJenisObat: 9, jenisObat: 'Antipiretik'),
  ];
}
