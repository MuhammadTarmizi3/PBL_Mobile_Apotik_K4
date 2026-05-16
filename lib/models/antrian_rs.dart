// Model data antrian RS dari API SIMRS (Kelompok 1) — pasien yang sudah lunas masuk ke apotik
class AntrianRs {
  final int? id; // PK antrian
  final String? nomorAntrian; // kode/nomor antrian
  final int? idPasien; // FK ke pasien
  final String? namaPasien; // resolved dari nested pendaftaran.pasien
  final int? unitId; // FK ke unit
  final String? namaUnit; // resolved dari nested unit
  final String? status; // status antrian (lunas, menunggu, dll)
  final String? createdAt;
  final String? updatedAt;

  AntrianRs({
    this.id,
    this.nomorAntrian,
    this.idPasien,
    this.namaPasien,
    this.unitId,
    this.namaUnit,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  // Parse dari JSON API SIMRS (snake_case, support nested object)
  factory AntrianRs.fromJson(Map<String, dynamic> json) {
    // Ambil nama pasien dari nested pendaftaran.pasien
    String? namaPasien;
    int? idPasien;
    
    // Coba ambil dari pendaftaran.pasien
    if (json['pendaftaran'] != null && json['pendaftaran'] is Map) {
      final pendaftaran = json['pendaftaran'] as Map<String, dynamic>;
      
      if (pendaftaran['pasien'] != null && pendaftaran['pasien'] is Map) {
        final pasien = pendaftaran['pasien'] as Map<String, dynamic>;
        namaPasien = pasien['nama_lengkap'] as String?;
        idPasien = pasien['id'] as int?;
      }
    }
    
    // Fallback: ambil dari field langsung
    namaPasien ??= json['nama_pasien'] as String?;
    idPasien ??= json['id_pasien'] as int?;
    
    // Ambil nama unit dari nested object
    String? namaUnit;
    if (json['unit'] != null && json['unit'] is Map) {
      final unit = json['unit'] as Map<String, dynamic>;
      namaUnit = unit['nama_unit'] as String?;
    }
    
    // Fallback: ambil dari field langsung
    namaUnit ??= json['nama_unit'] as String?;
    
    // Nomor antrian bisa dari kode_antrian atau nomor_antrian
    String? nomorAntrian = json['kode_antrian'] as String? ?? 
                          json['nomor_antrian']?.toString();
    
    return AntrianRs(
      id: json['id'] as int?,
      nomorAntrian: nomorAntrian,
      idPasien: idPasien,
      namaPasien: namaPasien,
      unitId: json['unit_id'] as int?,
      namaUnit: namaUnit,
      status: json['status'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  // Konversi ke JSON untuk POST/PUT
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomor_antrian': nomorAntrian,
      'id_pasien': idPasien,
      'nama_pasien': namaPasien,
      'unit_id': unitId,
      'nama_unit': namaUnit,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Cek apakah antrian sudah lunas (sudah bayar)
  bool get isSelesaiBayar {
    if (status == null) return false;
    return status!.toLowerCase() == 'lunas';
  }

  // Format tanggal created_at untuk tampil di UI
  String get formattedCreatedAt {
    if (createdAt == null) return '-';
    try {
      final dateTime = DateTime.parse(createdAt!);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return createdAt ?? '-';
    }
  }

  // Buat salinan dengan field tertentu diganti
  AntrianRs copyWith({
    int? id,
    String? nomorAntrian,
    int? idPasien,
    String? namaPasien,
    int? unitId,
    String? namaUnit,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return AntrianRs(
      id: id ?? this.id,
      nomorAntrian: nomorAntrian ?? this.nomorAntrian,
      idPasien: idPasien ?? this.idPasien,
      namaPasien: namaPasien ?? this.namaPasien,
      unitId: unitId ?? this.unitId,
      namaUnit: namaUnit ?? this.namaUnit,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AntrianRs(id: $id, nomorAntrian: $nomorAntrian, namaPasien: $namaPasien, status: $status)';
  }
}
