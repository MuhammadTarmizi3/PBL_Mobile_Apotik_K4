// Unit test untuk AntrianProvider — menguji logika antrian tanpa UI/backend.
// Catatan: method async (selesaiDanLanjut, panggilUlang, dll) membutuhkan
// mock AntrianService, jadi di sini hanya getter & method sync yang diuji.
import 'package:flutter_test/flutter_test.dart';
import 'package:pbl_apotik_kelompok_4/providers/provider_antrian.dart';
import 'package:pbl_apotik_kelompok_4/models/antrian.dart';

void main() {
  group('AntrianProvider', () {
    late AntrianProvider provider;

    setUp(() {
      provider = AntrianProvider();
      // Load dummy data langsung (tanpa API call)
      provider.loadDummyData();
    });

    test('antrianAktif mengembalikan antrian berstatus diproses', () {
      expect(provider.antrianAktif, isNotNull);
      expect(provider.antrianAktif!.status, AntrianStatus.diproses);
    });

    test('antrianMenunggu berisi antrian berstatus menunggu', () {
      expect(provider.antrianMenunggu, isNotEmpty);
      expect(
        provider.antrianMenunggu.every((a) => a.status == AntrianStatus.menunggu),
        isTrue,
      );
    });

    test('antrianSelesai berisi antrian berstatus selesai', () {
      expect(provider.antrianSelesai, isNotEmpty);
      expect(
        provider.antrianSelesai.every((a) => a.status == AntrianStatus.selesai),
        isTrue,
      );
    });

    test('antrianBelumSelesai menggabungkan menunggu dan diproses', () {
      expect(
        provider.antrianBelumSelesai.every(
          (a) => a.status == AntrianStatus.menunggu || a.status == AntrianStatus.diproses,
        ),
        isTrue,
      );
      expect(
        provider.antrianBelumSelesai.length,
        provider.antrianMenunggu.length +
            provider.daftarAntrian.where((a) => a.status == AntrianStatus.diproses).length,
      );
    });

    test('totalAntrianAktif sama dengan menunggu + diproses', () {
      final menungguCount = provider.antrianMenunggu.length;
      final diprosesCount =
          provider.daftarAntrian.where((a) => a.status == AntrianStatus.diproses).length;
      expect(provider.totalAntrianAktif, menungguCount + diprosesCount);
    });

    test('selectAntrian menyimpan antrian terpilih', () {
      final target = provider.antrianMenunggu.first;
      provider.selectAntrian(target);
      expect(provider.selectedAntrian, target);
    });

    test('selectAntrian bisa diganti', () {
      final pertama = provider.antrianMenunggu.first;
      final kedua = provider.antrianMenunggu.last;
      provider.selectAntrian(pertama);
      expect(provider.selectedAntrian, pertama);
      provider.selectAntrian(kedua);
      expect(provider.selectedAntrian, kedua);
    });

    test('daftarAntrian mengembalikan list unmodifiable', () {
      expect(provider.daftarAntrian, isNotEmpty);
      expect(() => provider.daftarAntrian.add(
        const Antrian(
          idAntrian: 999,
          nomorAntrian: 'X',
          namaPasien: 'Test',
          idResep: 1,
          status: AntrianStatus.menunggu,
        ),
      ), throwsA(isA<UnsupportedError>()));
    });
  });
}
