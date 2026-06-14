// Provider state management untuk data e-Resep
import 'package:flutter/material.dart';

import '../core/constants/api_constants.dart';
import '../models/resep.dart';
import '../services/service_resep.dart';

// Provider e-Resep — CRUD resep dan update status resep
class EResepProvider with ChangeNotifier {
  final ResepService _resepService = ResepService();

  List<Resep> _resepList = []; // cache data resep dari API
  bool _isLoading = false;
  String? _errorMessage;
  bool _isTestMode = false; // true = gunakan data lokal, bypass API

  List<Resep> get resepList => List.unmodifiable(_resepList);
  List<Resep> get resepAktif => List.unmodifiable(
        _resepList.where((r) => r.statusResep.toUpperCase() == 'AKTIF').toList(),
      );
  List<Resep> get resepSelesai => List.unmodifiable(
        _resepList.where((r) => r.statusResep.toUpperCase() == 'SELESAI').toList(),
      );
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUsingLocalData => !ApiConstants.apotikApiEnabled;
  String get localDataNotice =>
      'API modul apotik belum tersedia â€” menampilkan data contoh.';

  // Constructor utama — fetch API atau load dummy sesuai flag
  EResepProvider() {
    if (ApiConstants.apotikApiEnabled) {
      fetchResep();
    } else {
      _loadLocalData();
    }
  }

  // Constructor khusus test — load dummy data tanpa API
  EResepProvider.forTest() {
    _isTestMode = true;
    _loadLocalData();
  }

  // Load dummy data dari model
  void _loadLocalData() {
    _resepList = List.from(Resep.dummyData);
    _errorMessage = null;
    notifyListeners();
  }

  // Fetch resep dari API (atau fallback ke dummy jika API off)
  Future<void> fetchResep() async {
    if (!ApiConstants.apotikApiEnabled) {
      _loadLocalData();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _resepList = await _resepService.getAllResep();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch resep berdasarkan status
  Future<void> fetchResepByStatus(String status) async {
    if (!ApiConstants.apotikApiEnabled) {
      _resepList = Resep.dummyData
          .where((r) => r.statusResep.toUpperCase() == status.toUpperCase())
          .toList();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _resepList = await _resepService.getResepByStatus(status);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Ambil resep berdasarkan id resep
  Resep? getResepById(int idResep) {
    final matches = _resepList.where((r) => r.idResep == idResep);
    return matches.isEmpty ? null : matches.first;
  }

  // Ambil resep berdasarkan id antrian
  Future<Resep?> getResepByIdAntrian(int idAntrian) async {
    if (!ApiConstants.apotikApiEnabled) {
      final matches = _resepList.where((r) => r.idAntrian == idAntrian);
      return matches.isEmpty ? null : matches.first;
    }

    try {
      return await _resepService.getResepByIdAntrian(idAntrian);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  // Update status resep (API atau local fallback)
  Future<void> updateStatus(int idResep, String statusResep) async {
    if (_isTestMode || !ApiConstants.apotikApiEnabled) {
      final index = _resepList.indexWhere((r) => r.idResep == idResep);
      if (index != -1) {
        _resepList[index] = _resepList[index].copyWith(statusResep: statusResep);
        notifyListeners();
      }
      return;
    }

    try {
      final updatedResep = await _resepService.updateStatusResep(idResep, statusResep);
      final index = _resepList.indexWhere((r) => r.idResep == idResep);
      if (index != -1) {
        _resepList[index] = updatedResep;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  // Tambah resep baru
  Future<void> addResep(Resep resep) async {
    if (_isTestMode || !ApiConstants.apotikApiEnabled) {
      final newId = _resepList.isEmpty
          ? 1
          : _resepList.map((r) => r.idResep).reduce((a, b) => a > b ? a : b) + 1;
      _resepList.insert(0, resep.copyWith(idResep: newId));
      notifyListeners();
      return;
    }

    try {
      final newResep = await _resepService.createResep(resep);
      _resepList.insert(0, newResep);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  // Hapus resep berdasarkan id
  Future<void> deleteResep(int idResep) async {
    if (_isTestMode || !ApiConstants.apotikApiEnabled) {
      _resepList.removeWhere((r) => r.idResep == idResep);
      notifyListeners();
      return;
    }

    try {
      await _resepService.deleteResep(idResep);
      _resepList.removeWhere((r) => r.idResep == idResep);
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
}
