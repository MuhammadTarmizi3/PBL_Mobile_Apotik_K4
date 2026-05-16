// Model data user dari API /auth/me untuk profile page
class UserModel {
  final int id; // PK user
  final String email;
  final List<String> roles; // daftar role dari backend
  final String? namaLengkap;
  final String? noTelepon;
  final String? fotoProfile;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.roles,
    this.namaLengkap,
    this.noTelepon,
    this.fotoProfile,
    this.createdAt,
    this.updatedAt,
  });

  // Parse dari JSON response API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
      namaLengkap: json['nama_lengkap'] as String? ?? json['name'] as String?,
      noTelepon: json['no_telepon'] as String? ?? json['phone'] as String?,
      fotoProfile: json['foto_profile'] as String? ?? json['avatar'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  // Konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'roles': roles,
      'nama_lengkap': namaLengkap,
      'no_telepon': noTelepon,
      'foto_profile': fotoProfile,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Nama untuk ditampilkan (fallback ke email jika nama kosong)
  String get displayName => namaLengkap ?? email.split('@').first;

  // Role utama (yang pertama dalam list)
  String get primaryRole => roles.isNotEmpty ? roles.first : 'user';

  // Role yang lebih human-readable untuk UI
  String get roleDisplay {
    switch (primaryRole) {
      case 'admin':
      case 'superadmin':
      case 'admin_apotik':
        return 'Administrator';
      case 'apoteker':
        return 'Apoteker';
      case 'petugas':
        return 'Petugas Apotek';
      case 'admin_perawat':
        return 'Admin Perawat';
      case 'dokter':
        return 'Dokter';
      case 'perawat':
        return 'Perawat';
      case 'pasien':
        return 'Pasien';
      default:
        return primaryRole;
    }
  }

  // ID pegawai format APT-XXX-nnn untuk ditampilkan
  String get employeeId {
    String prefix;
    switch (primaryRole) {
      case 'admin':
      case 'superadmin':
      case 'admin_apotik':
        prefix = 'APT-ADM';
        break;
      case 'apoteker':
        prefix = 'APT-APT';
        break;
      case 'petugas':
        prefix = 'APT-PTG';
        break;
      default:
        prefix = 'APT-USR';
    }
    // Format ID dengan leading zeros (contoh: APT-ADM-001)
    return '$prefix-${id.toString().padLeft(3, '0')}';
  }

  // URL foto profile dengan fallback ke pravatar
  String get avatarUrl {
    if (fotoProfile != null && fotoProfile!.isNotEmpty) {
      return fotoProfile!;
    }
    // Fallback ke pravatar dengan seed dari user ID
    return 'https://i.pravatar.cc/150?img=$id';
  }

  // Buat salinan dengan field tertentu diganti
  UserModel copyWith({
    int? id,
    String? email,
    List<String>? roles,
    String? namaLengkap,
    String? noTelepon,
    String? fotoProfile,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      noTelepon: noTelepon ?? this.noTelepon,
      fotoProfile: fotoProfile ?? this.fotoProfile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, roles: $roles, nama: $namaLengkap)';
  }
}
