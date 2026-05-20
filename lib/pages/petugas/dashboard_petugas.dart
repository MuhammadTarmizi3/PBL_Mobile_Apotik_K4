// Dashboard petugas — calling antrian, queue list, auto-refresh
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/antrian_rs.dart';
import '../../services/service_antrian_rs.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/snackbar.dart';
import '../../core/widgets/state_error.dart';
import '../../core/widgets/cards/card_antrian_hari_ini.dart';
import '../../core/widgets/cards/card_ringkasan_status.dart';
import '../../core/widgets/cards/card_panggil.dart';
import 'widgets/antrian_queue_card.dart';
import 'widgets/calling_action_buttons.dart';
import '../../core/widgets/state_antrian_kosong.dart';
import 'widgets/antrian_detail_dialog.dart';
import 'widgets/next_queue_header.dart';

// Halaman dashboard petugas — panggil antrian & kelola queue
class DashboardPetugasPage extends StatefulWidget {
  const DashboardPetugasPage({super.key});

  @override
  State<DashboardPetugasPage> createState() => _DashboardPetugasPageState();
}

class _DashboardPetugasPageState extends State<DashboardPetugasPage> {
  final AntrianRsService _antrianRsService = AntrianRsService();
  List<AntrianRs> _antrianRsList = [];
  List<AntrianRs> _allAntrianToday = [];
  AntrianRs? _antrianAktifApotik;
  final List<AntrianRs> _antrianSelesai = [];
  final Set<int> _skippedAntrianIds = {};
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
      final allAntrian = await _antrianRsService.getAllAntrianRs(
        tanggal: todayString,
      );
      final antrianLunas = allAntrian.where((a) => a.isSelesaiBayar).toList();
      if (mounted) {
        final previousActiveId = _antrianAktifApotik?.id;
        // Reorder: non-skipped first, skipped at bottom (fix Q4)
        final nonSkipped = antrianLunas.where((a) => !_skippedAntrianIds.contains(a.id)).toList();
        final skipped = antrianLunas.where((a) => _skippedAntrianIds.contains(a.id)).toList();
        final reordered = [...nonSkipped, ...skipped];
        setState(() {
          _antrianRsList = reordered;
          _allAntrianToday = allAntrian;
          _isRefreshing = false;
          _isLoading = false;
          _errorMessage = null;
        });
        // Smart logic untuk set antrian aktif
        if (antrianLunas.isNotEmpty) {
          if (previousActiveId != null) {
            final stillExists = antrianLunas.any((a) => a.id == previousActiveId);
            if (stillExists) {
              // Pertahankan antrian aktif yang sama
              _antrianAktifApotik = antrianLunas.firstWhere((a) => a.id == previousActiveId);
              if (!silent) {
                debugPrint('âœ… [Petugas] Antrian aktif dipertahankan: ${_antrianAktifApotik!.nomorAntrian}');
              }
            } else {
              // Antrian aktif sebelumnya sudah selesai, set yang baru
              _updateStatusToSedangDilayani(antrianLunas.first.id!);
              if (!silent) {
                showAppSnackBar(context, 'Antrian berikutnya: ${antrianLunas.first.nomorAntrian}');
              }
            }
          } else if (_antrianAktifApotik == null) {
            // Belum ada antrian aktif, set yang pertama
            _updateStatusToSedangDilayani(antrianLunas.first.id!);
            if (!silent) {
              debugPrint('âœ… [Petugas] Antrian pertama otomatis aktif: ${antrianLunas.first.nomorAntrian}');
            }
          }
        } else {
          // Tidak ada antrian, reset antrian aktif
          _antrianAktifApotik = null;
        }
        
        // Log untuk debugging
        if (silent) {
          debugPrint('ðŸ”„ [Petugas] Silent refresh: ${antrianLunas.length} antrian lunas');
        } else {
          debugPrint('ðŸ“¥ [Petugas] Data loaded: ${antrianLunas.length} antrian lunas, ${allAntrian.length} total');
        }
      }
    } catch (e) {
      // Silent error - data kosong akan ditampilkan
      if (mounted) {
        setState(() {
          if (_antrianRsList.isEmpty) {
            _antrianRsList = [];
            _allAntrianToday = [];
            _errorMessage = e.toString().replaceAll('Exception: ', '');
          }
          _isRefreshing = false;
          _isLoading = false;
        });
        
        if (!silent) {
          debugPrint('âŒ [Petugas] Error fetching data: $e');
        }
      }
    }
  }
  
  void _updateStatusToSedangDilayani(int idAntrian) {
    setState(() {
      final index = _antrianRsList.indexWhere((a) => a.id == idAntrian);
      if (index != -1) {
        _antrianAktifApotik = _antrianRsList[index];
      }
    });
    debugPrint('âœ… Antrian ID $idAntrian set sebagai aktif (local only)');
  }

  int get _jumlahBelumDipanggil {
    if (_antrianAktifApotik == null) {
      return _antrianRsList.length;
    }
    return _antrianRsList.length - 1;
  }

  List<AntrianRs> get _antrianMenunggu {
    if (_antrianAktifApotik == null) {
      return _antrianRsList.where((a) => !_skippedAntrianIds.contains(a.id)).toList();
    }
    return _antrianRsList.where((a) => a.id != _antrianAktifApotik!.id && !_skippedAntrianIds.contains(a.id)).toList();
  }

  // Antrian yang di-skip — ditampilkan terpisah di bawah
  List<AntrianRs> get _antrianDilewati {
    return _antrianRsList.where((a) => _skippedAntrianIds.contains(a.id)).toList();
  }

  int get _jumlahSelesai {
    final dariApi = _allAntrianToday.where((a) => a.status?.toLowerCase() == 'obat_diserahkan').length;
    return dariApi + _antrianSelesai.length;
  }

  Future<void> _panggilUlang(BuildContext context) async {
    if (_antrianAktifApotik == null) {
      showAppSnackBar(context, 'Tidak ada antrian yang sedang dipanggil');
      return;
    }

    if (!context.mounted) return;
    showAppSnackBar(
      context,
      'Memanggil ${_antrianAktifApotik!.namaPasien} (${_antrianAktifApotik!.nomorAntrian})',
    );
  }

  Future<void> _skipAntrian(BuildContext context) async {
    if (_antrianAktifApotik == null) return;

    // Skip LOCAL ONLY - tidak update API karena status "skip" tidak valid
    setState(() {
      // Tandai antrian aktif sebagai di-skip
      final current = _antrianAktifApotik!;
      _skippedAntrianIds.add(current.id!);
      
      // Pindahkan antrian di-skip ke urutan terakhir
      _antrianRsList.removeWhere((a) => a.id == current.id);
      _antrianRsList.add(current);
      
      // Set antrian berikutnya (non-skipped) sebagai aktif
      final nonSkipped = _antrianRsList.where((a) => !_skippedAntrianIds.contains(a.id)).toList();
      if (nonSkipped.isNotEmpty) {
        _antrianAktifApotik = nonSkipped.first;
      } else if (_antrianRsList.isNotEmpty) {
        // Semua di-skip, ambil yang pertama
        _antrianAktifApotik = _antrianRsList.first;
      } else {
        _antrianAktifApotik = null;
      }
    });

    if (!context.mounted) return;
    showAppSnackBar(
      context,
      'Antrian di-skip dan dipindahkan ke urutan bawah',
      backgroundColor: AppColors.warning,
    );
  }

  Future<void> _selesaiDanLanjut(BuildContext context) async {
    if (_antrianAktifApotik == null) return;

    try {
      // Update status ke "obat_diserahkan" di API
      final updatedAntrian = await _antrianRsService.updateStatusAntrian(_antrianAktifApotik!.id!, 'obat_diserahkan');
      
      // Pindahkan ke list selesai
      setState(() {
        _antrianSelesai.add(updatedAntrian);
        
        // Hapus antrian aktif dari list
        _antrianRsList.removeWhere((a) => a.id == updatedAntrian.id);
        
        // Update di allAntrianToday juga
        final indexAll = _allAntrianToday.indexWhere((a) => a.id == updatedAntrian.id);
        if (indexAll != -1) {
          _allAntrianToday[indexAll] = updatedAntrian;
        }
        
        // Set antrian berikutnya sebagai aktif (LOCAL ONLY)
        if (_antrianRsList.isNotEmpty) {
          _antrianAktifApotik = _antrianRsList.first;
        } else {
          _antrianAktifApotik = null;
        }
      });

      if (!context.mounted) return;
      showAppSnackBar(
        context, 
        'Obat diserahkan. Antrian berikutnya dipanggil.',
      );
    } catch (e) {
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        'Gagal menyelesaikan antrian: ${e.toString().replaceAll('Exception: ', '')}',
        backgroundColor: AppColors.error,
      );
    }
  }

  void _lihatSemua(BuildContext context) {
    context.push('/petugas/antrian');
  }
  
  Future<void> _panggilAntrianSekarang(AntrianRs antrian) async {
    // Set antrian ini sebagai aktif (LOCAL ONLY - tidak update API)
    // Jika antrian sebelumnya di-skip, unskip
    _skippedAntrianIds.remove(antrian.id);
    setState(() {
      _antrianAktifApotik = antrian;
      // Pindahkan antrian ini ke posisi pertama
      _antrianRsList.removeWhere((a) => a.id == antrian.id);
      _antrianRsList.insert(0, antrian);
    });
    
    if (!mounted) return;
    showAppSnackBar(
      context,
      '${antrian.namaPasien} (${antrian.nomorAntrian}) sedang dipanggil',
    );
  }

  void _handleAntrianRsTap(AntrianRs antrian) {
    showDialog(
      context: context,
      builder: (context) => AntrianDetailDialog(
        antrian: antrian,
        isCurrentlyActive: _antrianAktifApotik?.id == antrian.id,
        onPanggilSekarang: _panggilAntrianSekarang,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final upcomingAntrian = _antrianMenunggu;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_errorMessage != null && _antrianRsList.isEmpty) {
      return DashboardErrorState(
        errorMessage: _errorMessage!,
        onRetry: _fetchAntrianData,
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAntrianData,
      color: AppColors.primary,
      child: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                TodayQueueCard(totalAntrian: _antrianRsList.length),
                const SizedBox(height: 16),
                // Card Belum Di Panggil dan Selesai
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: StatusSummaryCard(
                          title: 'BELUM DI PANGGIL',
                          count: '$_jumlahBelumDipanggil',
                          color: AppColors.warning,
                          icon: Icons.hourglass_bottom_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatusSummaryCard(
                          title: 'SELESAI',
                          count: '$_jumlahSelesai',
                          color: AppColors.teal,
                          icon: Icons.check_circle_outline_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildCallingCard(context),
                const SizedBox(height: 20),
                NextQueueHeader(onLihatSemua: () => _lihatSemua(context)),
              ]),
            ),
          ),
          if (upcomingAntrian.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              sliver: SliverToBoxAdapter(
                child: EmptyQueueState(
                  isRefreshing: _isRefreshing,
                  onRefresh: _fetchAntrianData,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              sliver: SliverList.separated(
                itemCount: upcomingAntrian.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final antrian = upcomingAntrian[index];
                  return AntrianQueueCard(
                    antrian: antrian,
                    isDilewati: false,
                    onTap: () => _handleAntrianRsTap(antrian),
                  );
                },
              ),
            ),
          // Daftar antrian yang di-skip (ditampilkan terpisah)
          if (_antrianDilewati.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'DILEWATI (${_antrianDilewati.length})',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              sliver: SliverList.separated(
                itemCount: _antrianDilewati.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final antrian = _antrianDilewati[index];
                  return AntrianQueueCard(
                    antrian: antrian,
                    isDilewati: true,
                    onTap: () => _handleAntrianRsTap(antrian),
                  );
                },
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }

  Widget _buildCallingCard(BuildContext context) {
    final current = _antrianAktifApotik;

    if (current == null) {
      return const CallingCard.empty();
    }

    return CallingCard(
      nomorAntrian: current.nomorAntrian ?? '-',
      namaPasien: current.namaPasien ?? 'Pasien',
      idResep: '-', // ID Resep belum ada di tahap ini
      actionButtons: [
        CallingActionButtons(
          onPanggilUlang: () => _panggilUlang(context),
          onSkip: () => _skipAntrian(context),
          onSelesaiDanLanjut: () => _selesaiDanLanjut(context),
        ),
      ],
    );
  }
}
