// Provider state management untuk data obat apotek
import 'package:flutter/material.dart';

import '../core/constants/api_constants.dart';
import '../models/obat.dart';
import '../services/service_obat.dart';

// Provider obat — CRUD, filter kategori, dan search obat
class ObatProvider with ChangeNotifier {
  final ObatService _obatService = ObatService();

  List<ObatModel> _obatList = []; // cache data obat dari API
  List<ObatModel> _filteredObatList = []; // hasil filter/search
  String _selectedKategori = 'Semua'; // kategori yang sedang aktif
  String _searchQuery = ''; // query pencarian obat
  bool _isLoading = false;
  String? _errorMessage;

  List<ObatModel> get obatList => List.unmodifiable(_obatList);
  List<ObatModel> get filteredObatList => List.unmodifiable(_filteredObatList);
  String get selectedKategori => _selectedKategori;
  String get searchQuery => _searchQuery;

  // Daftar kategori unik dari data obat (dinamis, termasuk 'Semua')
  List<String> get kategoriList {
    final Set<String> unique = {};
    for (final o in _obatList) {
      if (o.namaJenisObat != null && o.namaJenisObat!.isNotEmpty) {
        unique.add(o.namaJenisObat!);
      }
    }
    return ['Semua', ...unique];
  }
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUsingLocalData => !ApiConstants.apotikApiEnabled;
  String get localDataNotice =>
      'API modul apotik belum tersedia â€” menampilkan data contoh.';

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
    _loadLocalData();
  }

  // Load dummy data dari model
  void _loadLocalData() {
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

  // Tambah obat baru (API atau local fallback)
  Future<void> addObat(ObatModel obat) async {
    if (!ApiConstants.apotikApiEnabled) {
      final newId = _obatList.isEmpty
          ? 1
          : _obatList.map((o) => o.idObat).reduce((a, b) => a > b ? a : b) + 1;
      _obatList.insert(0, obat.copyWith(idObat: newId));
      _filterObat();
      notifyListeners();
      return;
    }

    try {
      final newObat = await _obatService.createObat(obat);
      _obatList.insert(0, newObat);
      _filterObat();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  // Update data obat
  Future<void> updateObat(ObatModel obat) async {
    if (!ApiConstants.apotikApiEnabled) {
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
    if (!ApiConstants.apotikApiEnabled) {
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
      final kMatch = _selectedKategori == 'Semua' || o.namaJenisObat == _selectedKategori;
      final sMatch = o.namaObat.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (o.namaJenisObat?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return kMatch && sMatch;
    }).toList();
  }
}
