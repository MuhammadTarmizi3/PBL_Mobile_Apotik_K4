// Bug Fix Unit Tests
// These tests VERIFY that both bug fixes work correctly.
//
// Bug 1 Fix: edit_obat.dart sekarang menggunakan ObatProvider.updateObat()
//   → cache ter-update dan semua listener mendapat stok terbaru
//
// Bug 2 Fix: detail_eresep.dart sekarang menggunakan ObatProvider.updateStokSetelahResep()
//   → stok di-update via provider (cache sync) bukan langsung via ObatService

import 'package:flutter_test/flutter_test.dart';
import 'package:pbl_apotik_kelompok_4/models/obat.dart';
import 'package:pbl_apotik_kelompok_4/models/resep.dart';
import 'package:pbl_apotik_kelompok_4/providers/provider_eresep.dart';
import 'package:pbl_apotik_kelompok_4/providers/provider_obat.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ──────────────────────────────────────────────────────────────────────────
  // Task 3.4 — Verifikasi Fix Bug 1: Cache Synchronization via ObatProvider
  // ──────────────────────────────────────────────────────────────────────────
  group('Task 3.4 — Bug 1 Fix: ObatProvider.updateObat() syncs cache', () {
    test('updateObat() memperbarui entry di cache _obatList', () async {
      final provider = ObatProvider.forTest();

      // Pastikan dummy data sudah dimuat
      expect(provider.obatList.isNotEmpty, isTrue,
          reason: 'Dummy data harus ada');

      // Ambil obat pertama dan catat stok awal
      final obatAwal = provider.obatList.first;
      final stokAwal = obatAwal.stok;
      final stokBaru = stokAwal + 99;

      // Simulasi: admin edit stok via ObatProvider (fix Bug 1)
      final obatDiperbarui = obatAwal.copyWith(stok: stokBaru);
      await provider.updateObat(obatDiperbarui);

      // Verifikasi: cache ter-update dengan stok baru
      final obatSetelahUpdate =
          provider.obatList.firstWhere((o) => o.idObat == obatAwal.idObat);
      expect(obatSetelahUpdate.stok, equals(stokBaru),
          reason:
              'FIX VERIFIED: Cache harus ter-update setelah updateObat() dipanggil');
      print(
          '✓ Bug 1 Fix: ${obatAwal.namaObat} stok berhasil diperbarui dari $stokAwal → $stokBaru di cache');
    });

    test('updateObat() memanggil notifyListeners sehingga listener mendapat update', () async {
      final provider = ObatProvider.forTest();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      final obatAwal = provider.obatList.first;
      final obatDiperbarui = obatAwal.copyWith(stok: obatAwal.stok - 10);
      await provider.updateObat(obatDiperbarui);

      expect(notifyCount, greaterThan(0),
          reason: 'FIX VERIFIED: notifyListeners harus dipanggil setelah update');
      print('✓ Bug 1 Fix: notifyListeners dipanggil $notifyCount kali setelah updateObat()');
    });

    test('updateObat() juga memperbarui filteredObatList', () async {
      final provider = ObatProvider.forTest();

      final obatAwal = provider.obatList.last;
      final stokBaru = 999;

      await provider.updateObat(obatAwal.copyWith(stok: stokBaru));

      // filteredObatList harus mencerminkan data terbaru
      final filtered = provider.filteredObatList
          .where((o) => o.idObat == obatAwal.idObat)
          .toList();
      if (filtered.isNotEmpty) {
        expect(filtered.first.stok, equals(stokBaru),
            reason: 'filteredObatList harus ter-update setelah updateObat()');
        print('✓ Bug 1 Fix: filteredObatList juga ter-update → stok = $stokBaru');
      }
    });

    test('Single ObatProvider instance berfungsi sebagai sumber kebenaran tunggal', () async {
      // Simulasi skenario: admin dan petugas berbagi satu instance ObatProvider
      // (sudah disetup sebagai ChangeNotifierProvider di app root)
      final sharedProvider = ObatProvider.forTest();

      int listenerCallCount = 0;
      // Simulasi 2 widget listen ke provider yang sama
      sharedProvider.addListener(() => listenerCallCount++);
      sharedProvider.addListener(() => listenerCallCount++);

      final obatAwal = sharedProvider.obatList.first;
      await sharedProvider.updateObat(obatAwal.copyWith(stok: 777));

      // Kedua listener mendapat notifikasi dari 1 instance yang sama
      expect(listenerCallCount, greaterThanOrEqualTo(2),
          reason:
              'FIX VERIFIED: Semua listener pada single instance harus mendapat notifikasi');
      expect(
          sharedProvider.obatList
              .firstWhere((o) => o.idObat == obatAwal.idObat)
              .stok,
          equals(777),
          reason: 'Cache di single instance harus ter-update');
      print(
          '✓ Bug 1 Fix: $listenerCallCount listener notified dari single ObatProvider instance');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Task 4.4 — Verifikasi Fix Bug 2: Stock Update via ObatProvider
  // ──────────────────────────────────────────────────────────────────────────
  group('Task 4.4 — Bug 2 Fix: updateStokSetelahResep() syncs cache', () {
    test('updateStokSetelahResep() memperbarui stok obat di cache', () async {
      final obatProvider = ObatProvider.forTest();

      // Ambil dua obat dari dummyData
      final obat1 = obatProvider.obatList[0];
      final obat2 = obatProvider.obatList[1];

      final stokBaru1 = obat1.stok - 5;
      final stokBaru2 = obat2.stok - 3;

      print('Sebelum update:');
      print('  ${obat1.namaObat}: stok = ${obat1.stok}');
      print('  ${obat2.namaObat}: stok = ${obat2.stok}');

      // Simulasi: petugas selesaikan resep → update stok via provider
      await obatProvider.updateStokSetelahResep({
        obat1.idObat: stokBaru1,
        obat2.idObat: stokBaru2,
      });

      print('Setelah update:');
      final obat1Setelah =
          obatProvider.obatList.firstWhere((o) => o.idObat == obat1.idObat);
      final obat2Setelah =
          obatProvider.obatList.firstWhere((o) => o.idObat == obat2.idObat);
      print('  ${obat1Setelah.namaObat}: stok = ${obat1Setelah.stok}');
      print('  ${obat2Setelah.namaObat}: stok = ${obat2Setelah.stok}');

      expect(obat1Setelah.stok, equals(stokBaru1),
          reason:
              'FIX VERIFIED: Stok ${obat1.namaObat} harus ter-update di cache');
      expect(obat2Setelah.stok, equals(stokBaru2),
          reason:
              'FIX VERIFIED: Stok ${obat2.namaObat} harus ter-update di cache');
      print('✓ Bug 2 Fix: Kedua obat berhasil diupdate di cache ObatProvider');
    });

    test('updateStokSetelahResep() memanggil notifyListeners', () async {
      final provider = ObatProvider.forTest();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      final obat = provider.obatList.first;
      await provider.updateStokSetelahResep({obat.idObat: obat.stok - 1});

      expect(notifyCount, greaterThan(0),
          reason: 'notifyListeners harus dipanggil setelah updateStokSetelahResep()');
      print('✓ Bug 2 Fix: notifyListeners dipanggil $notifyCount kali');
    });

    test('updateStokSetelahResep() dengan map kosong tidak crash', () async {
      final provider = ObatProvider.forTest();
      // Tidak boleh throw exception saat map kosong
      await expectLater(
        provider.updateStokSetelahResep({}),
        completes,
        reason: 'Map kosong harus ditangani tanpa error',
      );
      print('✓ Bug 2 Fix: updateStokSetelahResep({}) tidak crash');
    });

    test('updateStokSetelahResep() tidak mempengaruhi obat yang tidak di-update', () async {
      final provider = ObatProvider.forTest();

      final semuaObat = provider.obatList.toList();
      // Hanya update obat pertama
      final obat0 = semuaObat[0];
      final stokAwalObat1 = semuaObat.length > 1 ? semuaObat[1].stok : null;

      await provider.updateStokSetelahResep({obat0.idObat: 1});

      // Obat kedua tidak boleh berubah
      if (stokAwalObat1 != null) {
        final obat1Setelah = provider.obatList[1];
        expect(obat1Setelah.stok, equals(stokAwalObat1),
            reason: 'Obat yang tidak diupdate tidak boleh berubah stoknya');
        print(
            '✓ Bug 2 Fix: Obat yang tidak diupdate tetap memiliki stok = $stokAwalObat1');
      }
    });

    test('getObatById() mengembalikan obat dari cache berdasarkan id', () {
      final provider = ObatProvider.forTest();

      final obatPertama = provider.obatList.first;
      final ditemukan = provider.getObatById(obatPertama.idObat);

      expect(ditemukan, isNotNull,
          reason: 'getObatById harus menemukan obat yang ada di cache');
      expect(ditemukan!.idObat, equals(obatPertama.idObat));
      expect(ditemukan.namaObat, equals(obatPertama.namaObat));
      print('✓ getObatById(${obatPertama.idObat}) → ${ditemukan.namaObat}');
    });

    test('getObatById() mengembalikan null untuk id yang tidak ada', () {
      final provider = ObatProvider.forTest();

      final tidakAda = provider.getObatById(99999);
      expect(tidakAda, isNull,
          reason: 'getObatById harus null untuk id yang tidak ada');
      print('✓ getObatById(99999) → null (benar)');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Regression Tests — Pastikan existing behavior tidak rusak
  // ──────────────────────────────────────────────────────────────────────────
  group('Regression — Existing ObatProvider behavior tidak rusak', () {
    test('addObat() tetap berfungsi setelah penambahan method baru', () async {
      final provider = ObatProvider.forTest();
      final jumlahAwal = provider.obatList.length;

      final obatBaru = ObatModel(
        idObat: 9999,
        namaObat: 'Obat Test Regression',
        stok: 10,
        satuan: 'tablet',
        tanggalKadaluwarsa: DateTime(2028, 1, 1),
        hargaBeli: 1000,
        hargaJual: 2000,
      );
      await provider.addObat(obatBaru);

      expect(provider.obatList.length, equals(jumlahAwal + 1));
      print('✓ Regression: addObat() masih berfungsi');
    });

    test('deleteObat() tetap berfungsi setelah penambahan method baru', () async {
      final provider = ObatProvider.forTest();
      final obatPertama = provider.obatList.first;
      final jumlahAwal = provider.obatList.length;

      await provider.deleteObat(obatPertama.idObat);

      expect(provider.obatList.length, equals(jumlahAwal - 1));
      expect(
          provider.obatList.any((o) => o.idObat == obatPertama.idObat), isFalse);
      print('✓ Regression: deleteObat() masih berfungsi');
    });

    test('EResepProvider.addResep() masih berfungsi untuk data valid', () {
      final eresepProvider = EResepProvider.forTest();
      final jumlahAwal = eresepProvider.resepList.length;

      final resepBaru = Resep(
        idResep: 500,
        idAntrian: 200,
        idPasien: 99,
        namaPasien: 'Test Regression',
        namaDokter: 'dr. Test',
        createdAt: DateTime.now(),
        items: const [
          ResepItem(
            idDetail: 1,
            idResep: 500,
            idObat: 1,
            namaObat: 'Paracetamol 500mg',
            dosis: '500mg',
            aturanPakai: '3x1',
            jumlah: 5,
          ),
        ],
        statusResep: 'AKTIF',
      );

      eresepProvider.addResep(resepBaru);
      expect(eresepProvider.resepList.length, equals(jumlahAwal + 1));
      print('✓ Regression: EResepProvider.addResep() masih berfungsi');
    });
  });
}
