// Dashboard admin — calling antrian, auto-refresh, status ringkasan
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/date_constants.dart';
import '../../core/mixins/dashboard_fetch_mixin.dart';
import '../../core/widgets/dialog_row.dart';
import '../../core/widgets/snackbar.dart';
import '../../models/antrian_rs.dart';
import '../../core/widgets/cards/card_antrian.dart';
import '../../core/widgets/cards/card_antrian_hari_ini.dart';
import '../../core/widgets/cards/card_ringkasan_status.dart';
import '../../core/widgets/state_antrian_kosong.dart';
import 'widgets/admin_calling_card.dart';
import 'widgets/admin_dashboard_error_state.dart';

// Halaman dashboard admin — panggil antrian & pantau status
class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> with DashboardFetchMixin<DashboardAdminPage> {

  @override
  void initState() {
    super.initState();
    fetchData();
    startAutoRefresh();
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }

  @override
  Future<void> fetchData({bool silent = false}) async {
    if (isRefreshing) return;
    setState(() {
      isRefreshing = true;
      if (!silent) errorMessage = null;
    });
    try {
      final todayString = DateConstants.todayString;
      final allAntrian = await antrianRsService.getAllAntrianRs(tanggal: todayString);
      final antrianLunas = allAntrian.where((a) => a.isSelesaiBayar).toList();
      if (mounted) {
        final previousActiveId = antrianAktifApotik?.id;
        setState(() {
          antrianRsList = antrianLunas;
          allAntrianToday = allAntrian;
          isRefreshing = false;
          isLoading = false;
          errorMessage = null;
        });
        if (antrianLunas.isNotEmpty) {
          if (previousActiveId != null) {
            final stillExists = antrianLunas.any((a) => a.id == previousActiveId);
            if (stillExists) {
              antrianAktifApotik = antrianLunas.firstWhere((a) => a.id == previousActiveId);
              if (!silent) debugPrint('✅ Antrian aktif dipertahankan: ${antrianAktifApotik!.nomorAntrian}');
            } else {
              _setAntrianAktif(antrianLunas.first);
              if (!silent) showAppSnackBar(context, 'Antrian berikutnya: ${antrianLunas.first.nomorAntrian}');
            }
          } else if (antrianAktifApotik == null) {
            _setAntrianAktif(antrianLunas.first);
            if (!silent) debugPrint('âœ… Antrian pertama otomatis aktif: ${antrianLunas.first.nomorAntrian}');
          }
        } else {
          antrianAktifApotik = null;
        }
        if (silent) {
          debugPrint('ðŸ”„ Silent refresh: ${antrianLunas.length} antrian lunas');
        } else {
          debugPrint('ðŸ“¥ Data loaded: ${antrianLunas.length} antrian lunas, ${allAntrian.length} total');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (antrianRsList.isEmpty) {
            errorMessage = e.toString().replaceAll('Exception: ', '');
          }
          isRefreshing = false;
          isLoading = false;
        });
        if (!silent) debugPrint('âŒ Error fetching data: $e');
      }
    }
  }

  void _setAntrianAktif(AntrianRs antrian) {
    setState(() => antrianAktifApotik = antrian);
    debugPrint('✅ Antrian ${antrian.nomorAntrian} set sebagai aktif');
  }

  List<AntrianRs> get _antrianMenunggu {
    if (antrianAktifApotik == null) return antrianRsList;
    return antrianRsList.where((a) => a.id != antrianAktifApotik!.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (errorMessage != null && antrianRsList.isEmpty) {
      return AdminDashboardErrorState(
        errorMessage: errorMessage!,
        onRetry: fetchData,
      );
    }

    return RefreshIndicator(
      onRefresh: fetchData,
      color: AppColors.primary,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TodayQueueCard(totalAntrian: antrianRsList.length),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(child: StatusSummaryCard(title: 'BELUM DI PANGGIL', count: '$jumlahBelumDipanggil', color: AppColors.warning, icon: Icons.hourglass_bottom_rounded)),
                    const SizedBox(width: 12),
                    Expanded(child: StatusSummaryCard(title: 'SELESAI', count: '$jumlahSelesai', color: AppColors.teal, icon: Icons.check_circle_outline_rounded)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AdminCallingCard(antrian: antrianAktifApotik),
              const SizedBox(height: 16),
              _buildNextSection(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextSection() {
    final antrianMenunggu = _antrianMenunggu;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text('Antrean Berikutnya', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textDark)),
          ],
        ),
        const SizedBox(height: 4),
        if (antrianMenunggu.isEmpty)
          EmptyQueueState(isRefreshing: isRefreshing, onRefresh: fetchData)
        else
          ...antrianMenunggu.take(3).map((antrian) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AntrianCard(
              nomorAntrian: antrian.nomorAntrian ?? '-',
              namaPasien: antrian.namaPasien ?? 'Pasien #${antrian.idPasien}',
              idResep: '-',
              statusLabel: 'Menunggu',
              onTap: () => _showAntrianDetail(antrian),
            ),
          )),
      ],
    );
  }

  void _showAntrianDetail(AntrianRs antrian) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Antrian ${antrian.nomorAntrian}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DialogInfoRow(label: 'Pasien', value: antrian.namaPasien ?? '-'),
            DialogInfoRow(label: 'ID Pasien', value: antrian.idPasien?.toString() ?? '-'),
            DialogInfoRow(label: 'Unit', value: antrian.namaUnit ?? '-'),
            DialogInfoRow(label: 'Status', value: antrian.status ?? '-'),
            DialogInfoRow(label: 'Waktu', value: antrian.formattedCreatedAt),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }
}
