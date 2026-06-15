// Dashboard petugas — calling antrian, queue list, auto-refresh
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/antrian_rs.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/date_constants.dart';
import '../../core/constants/status_constants.dart';
import '../../core/mixins/dashboard_fetch_mixin.dart';
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

class _DashboardPetugasPageState extends State<DashboardPetugasPage> with DashboardFetchMixin<DashboardPetugasPage> {
  final Set<int> _skippedAntrianIds = {};

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
      final allAntrian = await antrianRsService.getAllAntrianRs(
        tanggal: todayString,
      );
      final antrianLunas = allAntrian.where((a) => a.isSelesaiBayar).toList();
      if (mounted) {
        final previousActiveId = antrianAktifApotik?.id;
        // Reorder: non-skipped first, skipped at bottom (fix Q4)
        final nonSkipped = antrianLunas.where((a) => !_skippedAntrianIds.contains(a.id)).toList();
        final skipped = antrianLunas.where((a) => _skippedAntrianIds.contains(a.id)).toList();
        final reordered = [...nonSkipped, ...skipped];
        setState(() {
          antrianRsList = reordered;
          allAntrianToday = allAntrian;
          isRefreshing = false;
          isLoading = false;
          errorMessage = null;
        });
        // Smart logic untuk set antrian aktif
        if (antrianLunas.isNotEmpty) {
          if (previousActiveId != null) {
            final stillExists = antrianLunas.any((a) => a.id == previousActiveId);
            if (stillExists) {
              // Pertahankan antrian aktif yang sama
              antrianAktifApotik = antrianLunas.firstWhere((a) => a.id == previousActiveId);
              if (!silent) {
                debugPrint('âœ… [Petugas] Antrian aktif dipertahankan: ${antrianAktifApotik!.nomorAntrian}');
              }
            } else {
              // Antrian aktif sebelumnya sudah selesai, set yang baru
              _updateStatusToSedangDilayani(antrianLunas.first.id!);
              if (!silent) {
                showAppSnackBar(context, 'Antrian berikutnya: ${antrianLunas.first.nomorAntrian}');
              }
            }
          } else if (antrianAktifApotik == null) {
            // Belum ada antrian aktif, set yang pertama
            _updateStatusToSedangDilayani(antrianLunas.first.id!);
            if (!silent) {
              debugPrint('âœ… [Petugas] Antrian pertama otomatis aktif: ${antrianLunas.first.nomorAntrian}');
            }
          }
        } else {
          // Tidak ada antrian, reset antrian aktif
          antrianAktifApotik = null;
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
          if (antrianRsList.isEmpty) {
            antrianRsList = [];
            allAntrianToday = [];
            errorMessage = e.toString().replaceAll('Exception: ', '');
          }
          isRefreshing = false;
          isLoading = false;
        });
        
        if (!silent) {
          debugPrint('âŒ [Petugas] Error fetching data: $e');
        }
      }
    }
  }
  
  void _updateStatusToSedangDilayani(int idAntrian) {
    setState(() {
      final index = antrianRsList.indexWhere((a) => a.id == idAntrian);
      if (index != -1) {
        antrianAktifApotik = antrianRsList[index];
      }
    });
    debugPrint('âœ… Antrian ID $idAntrian set sebagai aktif (local only)');
  }

  List<AntrianRs> get _antrianMenunggu {
    if (antrianAktifApotik == null) {
      return antrianRsList.where((a) => !_skippedAntrianIds.contains(a.id)).toList();
    }
    return antrianRsList.where((a) => a.id != antrianAktifApotik!.id && !_skippedAntrianIds.contains(a.id)).toList();
  }

  // Antrian yang di-skip — ditampilkan terpisah di bawah
  List<AntrianRs> get _antrianDilewati {
    return antrianRsList.where((a) => _skippedAntrianIds.contains(a.id)).toList();
  }

  Future<void> _panggilUlang(BuildContext context) async {
    if (antrianAktifApotik == null) {
      showAppSnackBar(context, 'Tidak ada antrian yang sedang dipanggil');
      return;
    }

    if (!context.mounted) return;
    showAppSnackBar(
      context,
      'Memanggil ${antrianAktifApotik!.namaPasien} (${antrianAktifApotik!.nomorAntrian})',
    );
  }

  Future<void> _skipAntrian(BuildContext context) async {
    if (antrianAktifApotik == null) return;

    // Skip LOCAL ONLY - tidak update API karena status "skip" tidak valid
    setState(() {
      // Tandai antrian aktif sebagai di-skip
      final current = antrianAktifApotik!;
      _skippedAntrianIds.add(current.id!);
      
      // Pindahkan antrian di-skip ke urutan terakhir
      antrianRsList.removeWhere((a) => a.id == current.id);
      antrianRsList.add(current);
      
      // Set antrian berikutnya (non-skipped) sebagai aktif
      final nonSkipped = antrianRsList.where((a) => !_skippedAntrianIds.contains(a.id)).toList();
      if (nonSkipped.isNotEmpty) {
        antrianAktifApotik = nonSkipped.first;
      } else if (antrianRsList.isNotEmpty) {
        // Semua di-skip, ambil yang pertama
        antrianAktifApotik = antrianRsList.first;
      } else {
        antrianAktifApotik = null;
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
    if (antrianAktifApotik == null) return;

    try {
      // Update status ke "obat_diserahkan" di API
      final updatedAntrian = await antrianRsService.updateStatusAntrian(antrianAktifApotik!.id!, StatusConstants.obatDiserahkan);
      
      // Pindahkan ke list selesai
      setState(() {
        antrianSelesai.add(updatedAntrian);
        
        // Hapus antrian aktif dari list
        antrianRsList.removeWhere((a) => a.id == updatedAntrian.id);
        
        // Update di allAntrianToday juga
        final indexAll = allAntrianToday.indexWhere((a) => a.id == updatedAntrian.id);
        if (indexAll != -1) {
          allAntrianToday[indexAll] = updatedAntrian;
        }
        
        // Set antrian berikutnya sebagai aktif (LOCAL ONLY)
        if (antrianRsList.isNotEmpty) {
          antrianAktifApotik = antrianRsList.first;
        } else {
          antrianAktifApotik = null;
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
      antrianAktifApotik = antrian;
      // Pindahkan antrian ini ke posisi pertama
      antrianRsList.removeWhere((a) => a.id == antrian.id);
      antrianRsList.insert(0, antrian);
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
        isCurrentlyActive: antrianAktifApotik?.id == antrian.id,
        onPanggilSekarang: _panggilAntrianSekarang,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final upcomingAntrian = _antrianMenunggu;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (errorMessage != null && antrianRsList.isEmpty) {
      return DashboardErrorState(
        errorMessage: errorMessage!,
        onRetry: fetchData,
      );
    }

    return RefreshIndicator(
      onRefresh: fetchData,
      color: AppColors.primary,
      child: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                TodayQueueCard(totalAntrian: antrianRsList.length),
                const SizedBox(height: 16),
                // Card Belum Di Panggil dan Selesai
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: StatusSummaryCard(
                          title: 'BELUM DI PANGGIL',
                          count: '$jumlahBelumDipanggil',
                          color: AppColors.warning,
                          icon: Icons.hourglass_bottom_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatusSummaryCard(
                          title: 'SELESAI',
                          count: '$jumlahSelesai',
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
                  isRefreshing: isRefreshing,
                  onRefresh: fetchData,
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
    final current = antrianAktifApotik;

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
