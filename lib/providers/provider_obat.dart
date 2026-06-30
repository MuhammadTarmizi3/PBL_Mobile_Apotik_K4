// Provider state management untuk data obat apotek
import 'package:flutter/material.dart';

import '../core/constants/api_constants.dart';
import '../models/obat.dart';
import '../models/jenis_obat.dart';
import '../services/service_obat.dart';
import '../services/service_jenis_obat.dart';

// Provider obat — CRUD, filter kategori, dan search obat
class ObatProvider with ChangeNotifier {
  final ObatService _obatService = ObatService();
  final JenisObatService _jenisObatService = JenisObatService();

  List<ObatModel> _obatList = []; // cache data obat dari API
  List<ObatModel> _filteredObatList = []; // hasil filter/search
  List<JenisObatModel> _jenisList = []; // cache data jenis obat
  String _selectedKategori = 'Semua'; // kategori yang sedang aktif
  String _searchQuery = ''; // query pencarian obat
  bool _isLoading = false;
  String? _errorMessage;
  bool _isTestMode = false; // true = gunakan data lokal, bypass API

  List<ObatModel> get obatList => List.unmodifiable(_obatList);
  List<ObatModel> get filteredObatList => List.unmodifiable(_filteredObatList);
  String get selectedKategori => _selectedKategori;
  String get searchQuery => _searchQuery;

  // Daftar kategori unik dari data obat (dinamis, termasuk 'Semua')
  List<String> get kategoriList {
    final Set<String> unique = {};
    for (final o in _obatList) {
      final name = getJenisName(o.idJenisObat);
      if (name != '-') {
        unique.add(name);
      }
    }
    return ['Semua', ...unique];
  }
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUsingLocalData => !ApiConstants.apotikApiEnabled;
  String get localDataNotice =>
      'API modul apotik belum tersedia — menampilkan data contoh.';

  // Constructor utama — fetch API atau load dummy sesuai flag
  ObatProvider() {
    if (ApiConstants.apotikApiEnabled) {
      fetchObat();
    } else {
      _loadLocalData();
    }
  }

  // Constructor khusus test — load dummy data tanpa API
  ObatProvider.forTest() {
    _isTestMode = true;
    _loadLocalData();
  }

  // Helper untuk mendapatkan nama jenis obat berdasarkan id
  String getJenisName(int? idJenisObat) {
    if (idJenisObat == null) return '-';
    final match = _jenisList.where((j) => j.idJenisObat == idJenisObat).firstOrNull;
    return match?.jenisObat ?? '-';
  }

  // Load dummy data dari model
  void _loadLocalData() {
    _jenisList = List.from(JenisObatModel.dummyData);
    _obatList = List.from(ObatModel.dummyData);
    _filterObat();
    _errorMessage = null;
    notifyListeners();
  }

  // Fetch obat dari API (atau fallback ke dummy)
  Future<void> fetchObat() async {
    if (!ApiConstants.apotikApiEnabled) {
      _loadLocalData();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _jenisList = await _jenisObatService.getAllJenisObat();
      _obatList = await _obatService.getAllObat();
      _filterObat();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update query pencarian dan trigger filter
  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterObat();
    notifyListeners();
  }

  // Update filter kategori dan trigger filter
  void setSelectedKategori(String kategori) {
    _selectedKategori = kategori;
    _filterObat();
    notifyListeners();
  }

  // Tambah obat baru ke list lokal (API call sudah dilakukan di halaman tambah_obat)
  // fetchObat() yang dipanggil setelahnya akan sinkronisasi data dari API
  void addObat(ObatModel obat) {
    if (_isTestMode || !ApiConstants.apotikApiEnabled) {
      final newId = _obatList.isEmpty
          ? 1
          : _obatList.map((o) => o.idObat).reduce((a, b) => a > b ? a : b) + 1;
      _obatList.insert(0, obat.copyWith(idObat: newId));
    } else {
      // Insert langsung — obat sudah di-create di API oleh halaman tambah
      _obatList.insert(0, obat);
    }
    _filterObat();
    notifyListeners();
  }

  // Update data obat
  Future<void> updateObat(ObatModel obat) async {
    if (_isTestMode || !ApiConstants.apotikApiEnabled) {
      final index = _obatList.indexWhere((o) => o.idObat == obat.idObat);
      if (index != -1) {
        _obatList[index] = obat;
        _filterObat();
        notifyListeners();
      }
      return;
    }

    try {
      final updatedObat = await _obatService.updateObat(obat.idObat, obat);
      final index = _obatList.indexWhere((o) => o.idObat == obat.idObat);
      if (index != -1) {
        _obatList[index] = updatedObat;
        _filterObat();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  // Hapus obat berdasarkan id
  Future<void> deleteObat(int idObat) async {
    if (_isTestMode || !ApiConstants.apotikApiEnabled) {
      _obatList.removeWhere((o) => o.idObat == idObat);
      _filterObat();
      notifyListeners();
      return;
    }

    try {
      await _obatService.deleteObat(idObat);
      _obatList.removeWhere((o) => o.idObat == idObat);
      _filterObat();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  // Ambil obat dari cache berdasarkan id
  ObatModel? getObatById(int idObat) {
    final matches = _obatList.where((o) => o.idObat == idObat);
    return matches.isEmpty ? null : matches.first;
  }

  // Update stok beberapa obat sekaligus setelah resep diproses
  // Menerima map {idObat: stokBaru} dan meng-update cache + API
  // Throws exception dengan daftar obat yang gagal jika ada error
  Future<void> updateStokSetelahResep(Map<int, int> stokUpdates) async {
    if (stokUpdates.isEmpty) return;

    if (_isTestMode || !ApiConstants.apotikApiEnabled) {
      // Mode lokal: update langsung di cache
      for (final entry in stokUpdates.entries) {
        final idx = _obatList.indexWhere((o) => o.idObat == entry.key);
        if (idx != -1) {
          _obatList[idx] = _obatList[idx].copyWith(stok: entry.value);
        }
      }
      _filterObat();
      notifyListeners();
      return;
    }

    // Mode API: update masing-masing obat
    final List<String> gagal = [];
    for (final entry in stokUpdates.entries) {
      try {
        final updated = await _obatService.updateStokObat(entry.key, entry.value);
        final idx = _obatList.indexWhere((o) => o.idObat == entry.key);
        if (idx != -1) {
          _obatList[idx] = updated;
        }
      } catch (_) {
        final namaObat = getObatById(entry.key)?.namaObat ?? 'Obat #${entry.key}';
        gagal.add(namaObat);
      }
    }
    _filterObat();
    notifyListeners();

    if (gagal.isNotEmpty) {
      throw Exception('Gagal update stok: ${gagal.join(', ')}');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Muat data dummy untuk testing
  void loadDummyData() {
    _loadLocalData();
  }

  // Filter obat berdasarkan kategori dan search query
  void _filterObat() {
    _filteredObatList = _obatList.where((o) {
      final namaJenis = getJenisName(o.idJenisObat);
      final kMatch = _selectedKategori == 'Semua' || namaJenis == _selectedKategori;
      final sMatch = o.namaObat.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          namaJenis.toLowerCase().contains(_searchQuery.toLowerCase());
      return kMatch && sMatch;
    }).toList();
  }
}
