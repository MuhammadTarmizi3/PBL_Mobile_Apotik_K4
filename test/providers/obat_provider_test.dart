// Unit test untuk ObatProvider — menguji filter, search, dan CRUD lokal.
// Catatan: method async (addObat, updateObat, deleteObat) membutuhkan
// mock ObatService karena apotikApiEnabled = true, jadi tidak diuji di sini.
import 'package:flutter_test/flutter_test.dart';
import 'package:pbl_apotik_kelompok_4/providers/provider_obat.dart';
import 'package:pbl_apotik_kelompok_4/models/obat.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ObatProvider', () {
    late ObatProvider provider;

    setUp(() {
      provider = ObatProvider.forTest();
    });

    test('filteredObatList terisi penuh saat pertama dibuat', () {
      expect(provider.filteredObatList, isNotEmpty);
      expect(provider.filteredObatList.length, provider.obatList.length);
    });

    test('setSearchQuery memfilter berdasarkan nama', () {
      provider.setSearchQuery('paracetamol');
      expect(provider.filteredObatList, isNotEmpty);
      expect(
        provider.filteredObatList.every(
          (o) => o.namaObat.toLowerCase().contains('paracetamol'),
        ),
        isTrue,
      );
    });

    test('setSearchQuery kosong mengembalikan semua', () {
      provider.setSearchQuery('paracetamol');
      provider.setSearchQuery('');
      expect(provider.filteredObatList.length, provider.obatList.length);
    });

    test('setSelectedKategori memfilter berdasarkan jenis', () {
      provider.setSelectedKategori('Antibiotik');
      expect(
        provider.filteredObatList.every((o) => o.namaJenisObat == 'Antibiotik'),
        isTrue,
      );
    });

    test('setSelectedKategori Semua mengembalikan semua', () {
      provider.setSelectedKategori('Antibiotik');
      provider.setSelectedKategori('Semua');
      expect(provider.filteredObatList.length, provider.obatList.length);
    });

    test('kategoriList berisi Semua + kategori unik', () {
      expect(provider.kategoriList.first, 'Semua');
      expect(provider.kategoriList.contains('Antibiotik'), isTrue);
      expect(provider.kategoriList.contains('Analgesik'), isTrue);
    });

    test('obatList mengembalikan list unmodifiable', () {
      expect(
        () => provider.obatList.add(
          ObatModel(
            idObat: 999,
            namaObat: 'Test',
            stok: 1,
            satuan: 'Pcs',
            tanggalKadaluwarsa: DateTime(2027, 1),
            hargaBeli: 1000,
            hargaJual: 2000,
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
