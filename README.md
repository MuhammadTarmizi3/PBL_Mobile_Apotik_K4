# Aplikasi Apotik Kelompok 4

Aplikasi manajemen apotik berbasis Flutter untuk proyek PBL (Project-Based Learning).

## Deskripsi

Aplikasi ini dirancang untuk mengelola operasional apotik, termasuk manajemen stok obat, penjualan, dan administrasi. Aplikasi ini menggunakan Flutter sebagai framework utama dengan state management Provider.

## Fitur Utama

- **Autentikasi Pengguna**: Login dengan JWT token dan secure storage
- **Manajemen Stok Obat**: CRUD operasi untuk data obat
- **Manajemen Penjualan**: Transaksi dan riwayat penjualan
- **Dashboard Admin**: Statistik dan laporan visual dengan grafik
- **Navigasi**: Routing dengan Go Router

## Teknologi yang Digunakan

- **Flutter SDK**: ^3.10.8
- **State Management**: Provider ^6.1.5
- **HTTP Client**: Dio ^5.9.2
- **Routing**: Go Router ^17.2.3
- **Secure Storage**: Flutter Secure Storage ^10.3.1
- **Caching**: Cached Network Image ^3.4.1
- **UI Components**: Flutter SVG ^2.0.10

## Prasyarat

- Flutter SDK versi 3.10.8 atau lebih baru
- Dart SDK (included dengan Flutter)
- Android Studio / VS Code dengan Flutter extension
- Emulator Android atau perangkat fisik untuk testing

## Instalasi

1. Clone repository ini:
```bash
git clone <repository-url>
cd pbl_apotik_kelompok_4
```

2. Install dependencies:
```bash
flutter pub get
```

3. Jalankan aplikasi:
```bash
flutter run
```

## Struktur Folder

```
lib/
├── core/
│   └── constants/        # Konstanta (colors, assets)
├── pages/
│   └── admin/           # Halaman admin
└── main.dart            # Entry point aplikasi
```

## Konfigurasi

Aplikasi menggunakan:
- Font custom: Poppins (Regular, Medium, SemiBold, Bold, Light)
- Assets gambar di folder `asset/image/`

## Tim Pengembang

Kelompok 4 - PBL Pemrograman Perangkat Bergerak

## Lisensi

Project ini dibuat untuk keperluan akademik - PBL Semester 4
