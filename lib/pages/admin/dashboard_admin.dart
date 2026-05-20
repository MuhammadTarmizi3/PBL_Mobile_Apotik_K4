// Dashboard admin — calling antrian, auto-refresh, status ringkasan
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/cards/card_antrian.dart';
import '../../core/widgets/state_antrian_kosong.dart';
import '../../models/antrian_rs.dart';
import '../../services/service_antrian_rs.dart';
import '../../core/widgets/snackbar.dart';
import 'widgets/admin_calling_card.dart';
import 'widgets/admin_dashboard_error_state.dart';

// Halaman dashboard admin — panggil antrian & pantau status
class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  final AntrianRsService _antrianRsService = AntrianRsService();
  List<AntrianRs> _antrianRsList = [];
  List<AntrianRs> _allAntrianToday = [];
  AntrianRs? _antrianAktifApotik;
  final List<AntrianRs> _antrianSelesai = [];
  bool _isRefreshing = false;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _autoRefreshTimer;
  static const Duration _autoRefreshInterval = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _fetchAntrianData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    super.dispose();
  }

  void _startAutoRefresh() {
    _stopAutoRefresh();
    _autoRefreshTimer = Timer.periodic(_autoRefreshInterval, (timer) {
      if (mounted && !_isRefreshing) {
        _fetchAntrianData(silent: true);
      }
    });
  }

  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  Future<void> _fetchAntrianData({bool silent = false}) async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
      if (!silent) _errorMessage = null;
    });
    try {
      final todayString = '2026-06-04';
      final allAntrian = await _antrianRsService.getAllAntrianRs(tanggal: todayString);
      final antrianLunas = allAntrian.where((a) => a.isSelesaiBayar).toList();
      if (mounted) {
        final previousActiveId = _antrianAktifApotik?.id;
        setState(() {
          _antrianRsList = antrianLunas;
          _allAntrianToday = allAntrian;
          _isRefreshing = false;
          _isLoading = false;
          _errorMessage = null;
        });
        if (antrianLunas.isNotEmpty) {
          if (previousActiveId != null) {
            final stillExists = antrianLunas.any((a) => a.id == previousActiveId);
            if (stillExists) {
              _antrianAktifApotik = antrianLunas.firstWhere((a) => a.id == previousActiveId);
              if (!silent) debugPrint('âœ… Antrian aktif dipertahankan: ${_antrianAktifApotik!.nomorAntrian}');
            } else {
              _setAntrianAktif(antrianLunas.first);
              if (!silent) showAppSnackBar(context, 'Antrian berikutnya: ${antrianLunas.first.nomorAntrian}');
            }
          } else if (_antrianAktifApotik == null) {
            _setAntrianAktif(antrianLunas.first);
            if (!silent) debugPrint('âœ… Antrian pertama otomatis aktif: ${antrianLunas.first.nomorAntrian}');
          }
        } else {
          _antrianAktifApotik = null;
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
          if (_antrianRsList.isEmpty) {
            _errorMessage = e.toString().replaceAll('Exception: ', '');
          }
          _isRefreshing = false;
          _isLoading = false;
        });
        if (!silent) debugPrint('âŒ Error fetching data: $e');
      }
    }
  }

  void _setAntrianAktif(AntrianRs antrian) {
    setState(() => _antrianAktifApotik = antrian);
    debugPrint('âœ… Antrian ${antrian.nomorAntrian} set sebagai aktif');
  }

  int get _jumlahBelumDipanggil {
    if (_antrianAktifApotik == null) return _antrianRsList.length;
    return _antrianRsList.length - 1;
  }

  List<AntrianRs> get _antrianMenunggu {
    if (_antrianAktifApotik == null) return _antrianRsList;
    return _antrianRsList.where((a) => a.id != _antrianAktifApotik!.id).toList();
  }

  int get _jumlahSelesai {
    final dariApi = _allAntrianToday.where((a) => a.status?.toLowerCase() == 'obat_diserahkan').length;
    return dariApi + _antrianSelesai.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_errorMessage != null && _antrianRsList.isEmpty) {
      return AdminDashboardErrorState(
        errorMessage: _errorMessage!,
        onRetry: _fetchAntrianData,
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAntrianData,
      color: AppColors.primary,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTodayCard(),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(child: _buildStatusCard('BELUM DI PANGGIL', '$_jumlahBelumDipanggil', AppColors.warning, Icons.hourglass_bottom_rounded)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatusCard('SELESAI', '$_jumlahSelesai', AppColors.teal, Icons.check_circle_outline_rounded)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AdminCallingCard(antrian: _antrianAktifApotik),
              const SizedBox(height: 16),
              _buildNextSection(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      const Text('ANTRIAN HARI INI', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.lightCyan, letterSpacing: 1.1)),
      const SizedBox(height: 4),
      RichText(text: TextSpan(children: [
        TextSpan(text: '${_antrianRsList.length}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 40, fontWeight: FontWeight.w700, color: Colors.white)),
        const TextSpan(text: '\u2003\u2003Pasien Lunas', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: AppColors.lightCyan)),
      ])),
    ]),
  );

  Widget _buildStatusCard(String title, String count, Color color, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border, width: 1),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), offset: const Offset(0, 4), blurRadius: 8)],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Expanded(child: Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.slateGrey), overflow: TextOverflow.ellipsis)),
      ]),
      const SizedBox(height: 8),
      Text(count, style: const TextStyle(fontFamily: 'Poppins', fontSize: 26, fontWeight: FontWeight.w400, color: AppColors.textDark)),
    ]),
  );

  Widget _buildNextSection() {
    final antrianMenunggu = _antrianMenunggu;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Antrean Berikutnya', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textDark)),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: const Text('Lihat Semua', style: TextStyle(fontFamily: 'Poppins', color: AppColors.teal, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (antrianMenunggu.isEmpty)
          EmptyQueueState(isRefreshing: _isRefreshing, onRefresh: _fetchAntrianData)
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
            _dialogRow('Pasien', antrian.namaPasien ?? '-'),
            _dialogRow('ID Pasien', antrian.idPasien?.toString() ?? '-'),
            _dialogRow('Unit', antrian.namaUnit ?? '-'),
            _dialogRow('Status', antrian.status ?? '-'),
            _dialogRow('Waktu', antrian.formattedCreatedAt),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }

  Widget _dialogRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 80, child: Text('$label:', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12))),
      Expanded(child: Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12))),
    ]),
  );
}
