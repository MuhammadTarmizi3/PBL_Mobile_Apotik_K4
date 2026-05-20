// Provider state management untuk data antrian pengambilan obat
import 'package:flutter/material.dart';

import '../models/antrian.dart';
import '../services/service_antrian.dart';

// Provider antrian — kelola daftar antrian, status, dan aksi panggil/selesai
class AntrianProvider extends ChangeNotifier {
  final AntrianService _antrianService = AntrianService();

  List<Antrian> _daftarAntrian = []; // cache data antrian dari API
  Antrian? _selectedAntrian; // antrian yang sedang dipilih
  bool _isLoading = false;
  String? _errorMessage;

  List<Antrian> get daftarAntrian => List.unmodifiable(_daftarAntrian);
  Antrian? get selectedAntrian => _selectedAntrian;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Antrian yang sedang diproses (status DIPROSES)
  Antrian? get antrianAktif {
    final matches = _daftarAntrian.where(
      (antrian) => antrian.status == AntrianStatus.diproses,
    );
    return matches.isEmpty ? null : matches.first;
  }

  // Daftar antrian dengan status MENUNGGU
  List<Antrian> get antrianMenunggu => List.unmodifiable(
        _daftarAntrian.where((a) => a.status == AntrianStatus.menunggu).toList(),
      );

  // Daftar antrian dengan status SELESAI
  List<Antrian> get antrianSelesai => List.unmodifiable(
        _daftarAntrian.where((a) => a.status == AntrianStatus.selesai).toList(),
      );

  // Daftar antrian yang belum selesai (MENUNGGU + DIPROSES)
  List<Antrian> get antrianBelumSelesai {
    final menunggu = _daftarAntrian.where((a) => a.status == AntrianStatus.menunggu).toList();
    final diproses = _daftarAntrian.where((a) => a.status == AntrianStatus.diproses).toList();
    return List.unmodifiable([...diproses, ...menunggu]);
  }

  // Total antrian aktif (MENUNGGU + DIPROSES)
  int get totalAntrianAktif {
    final menungguCount = _daftarAntrian.where((a) => a.status == AntrianStatus.menunggu).length;
    final diprosesCount = _daftarAntrian.where((a) => a.status == AntrianStatus.diproses).length;
    return menungguCount + diprosesCount;
  }

  // Fetch antrian dari API dan update state
  Future<void> fetchAntrian() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _daftarAntrian = await _antrianService.getAllAntrian();
      _errorMessage = null;
    } catch (e) {
      _daftarAntrian = [];
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Pilih antrian tertentu untuk ditampilkan detail
  void selectAntrian(Antrian antrian) {
    _selectedAntrian = antrian;
    notifyListeners();
  }

  // Panggil ulang antrian yang sedang diproses (tetap DIPROSES)
  Future<Antrian?> panggilUlang() async {
    final current = antrianAktif;
    if (current == null) return null;

    try {
      await _antrianService.updateStatusAntrian(current.idAntrian, 'DIPROSES');
      await fetchAntrian();
      return antrianAktif;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  // Selesaikan antrian aktif lalu panggil berikutnya
  Future<void> selesaiDanLanjut() async {
    final current = antrianAktif;
    if (current == null) return;

    try {
      // Set antrian aktif ke SELESAI
      await _antrianService.updateStatusAntrian(current.idAntrian, 'SELESAI');
      await fetchAntrian();

      // Panggil antrian berikutnya (set ke DIPROSES)
      await _panggilAntrianBerikutnya();
      await fetchAntrian();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  // Selesaikan antrian tertentu
  Future<void> selesaikanAntrian(Antrian antrian) async {
    try {
      await _antrianService.updateStatusAntrian(antrian.idAntrian, 'SELESAI');
      await fetchAntrian();

      // Auto panggil berikutnya kalau tidak ada antrian aktif
      if (antrianAktif == null) {
        await _panggilAntrianBerikutnya();
        await fetchAntrian();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  // Buat antrian baru dari id resep
  Future<Antrian> createAntrian(int idResep) async {
    try {
      final antrian = await _antrianService.createAntrian(idResep: idResep);
      await fetchAntrian();
      return antrian;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  // Hapus antrian berdasarkan id
  Future<void> deleteAntrian(int id) async {
    try {
      await _antrianService.deleteAntrian(id);
      await fetchAntrian();
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

  // Muat data dummy untuk testing tanpa API call
  void loadDummyData() {
    _daftarAntrian = List.from(Antrian.dummyData);
    notifyListeners();
  }

  // Panggil antrian berikutnya yang statusnya MENUNGGU
  Future<void> _panggilAntrianBerikutnya() async {
    final menunggu = _daftarAntrian.where((a) => a.status == AntrianStatus.menunggu).toList();

    if (menunggu.isNotEmpty) {
      await _antrianService.updateStatusAntrian(menunggu.first.idAntrian, 'DIPROSES');
    }
  }
}
