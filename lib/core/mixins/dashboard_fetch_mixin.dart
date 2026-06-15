// Mixin dashboard — state, timer auto-refresh, dan getter antrian bersama
import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/status_constants.dart';
import '../../models/antrian_rs.dart';
import '../../services/service_antrian_rs.dart';

/// Mixin yang menyediakan state & lifecycle bersama untuk dashboard admin & petugas.
///
/// Subclass harus mengimplementasikan [fetchData] sendiri karena logic
/// ordering / active-selection berbeda antara admin dan petugas.
mixin DashboardFetchMixin<W extends StatefulWidget> on State<W> {
  final AntrianRsService antrianRsService = AntrianRsService();
  List<AntrianRs> antrianRsList = [];
  List<AntrianRs> allAntrianToday = [];
  AntrianRs? antrianAktifApotik;
  final List<AntrianRs> antrianSelesai = [];
  bool isRefreshing = false;
  bool isLoading = true;
  String? errorMessage;
  Timer? autoRefreshTimer;
  static const Duration autoRefreshInterval = Duration(seconds: 10);

  void startAutoRefresh() {
    stopAutoRefresh();
    autoRefreshTimer = Timer.periodic(autoRefreshInterval, (timer) {
      if (mounted && !isRefreshing) {
        fetchData(silent: true);
      }
    });
  }

  void stopAutoRefresh() {
    autoRefreshTimer?.cancel();
    autoRefreshTimer = null;
  }

  /// Override di subclass — logic ordering & active-selection berbeda.
  Future<void> fetchData({bool silent = false});

  int get jumlahBelumDipanggil {
    if (antrianAktifApotik == null) return antrianRsList.length;
    return antrianRsList.length - 1;
  }

  int get jumlahSelesai {
    final dariApi = allAntrianToday
        .where((a) => a.status?.toLowerCase() == StatusConstants.obatDiserahkan)
        .length;
    return dariApi + antrianSelesai.length;
  }
}
