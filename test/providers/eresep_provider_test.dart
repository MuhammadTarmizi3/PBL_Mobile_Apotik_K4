// Unit test untuk EResepProvider — menguji getter, lookup, dan filter.
// Catatan: method async (updateStatus, addResep, deleteResep) membutuhkan
// mock ResepService karena apotikApiEnabled = true, jadi tidak diuji di sini.
import 'package:flutter_test/flutter_test.dart';
import 'package:pbl_apotik_kelompok_4/providers/provider_eresep.dart';
import 'package:pbl_apotik_kelompok_4/models/resep.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EResepProvider', () {
    late EResepProvider provider;

    setUp(() {
      provider = EResepProvider.forTest();
    });

    test('resepList terisi data awal', () {
      expect(provider.resepList, isNotEmpty);
    });

    test('resepAktif hanya berisi status aktif', () {
      expect(
        provider.resepAktif.every((r) => r.statusResep.toUpperCase() == 'AKTIF'),
        isTrue,
      );
    });

    test('resepSelesai hanya berisi status selesai', () {
      expect(
        provider.resepSelesai.every((r) => r.statusResep.toUpperCase() == 'SELESAI'),
        isTrue,
      );
    });

    test('getResepById mengembalikan resep yang cocok', () {
      final resep = provider.getResepById(1);
      expect(resep, isNotNull);
      expect(resep!.idResep, 1);
    });

    test('getResepById mengembalikan null jika tidak ada', () {
      expect(provider.getResepById(999), isNull);
    });

    test('resepList mengembalikan list unmodifiable', () {
      expect(
        () => provider.resepList.add(
          Resep(
            idResep: 999,
            namaPasien: 'Test',
            namaDokter: 'Dr. Test',
            createdAt: DateTime(2026, 1),
            items: const [],
            statusResep: 'aktif',
          ),
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('clearError menghapus errorMessage', () {
      provider.clearError();
      expect(provider.errorMessage, isNull);
    });
  });
}
