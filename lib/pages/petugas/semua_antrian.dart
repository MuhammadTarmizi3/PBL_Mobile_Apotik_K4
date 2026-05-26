// Halaman lihat semua antrian hari ini (pull-to-refresh)
import 'package:flutter/material.dart';

import '../../models/antrian_rs.dart';
import '../../services/service_antrian_rs.dart';
import '../../core/constants/app_colors.dart';

// Halaman semua antrian dengan pull-to-refresh
class LihatSemuaAntrianPage extends StatefulWidget {
  const LihatSemuaAntrianPage({super.key});

  @override
  State<LihatSemuaAntrianPage> createState() => _LihatSemuaAntrianPageState();
}

class _LihatSemuaAntrianPageState extends State<LihatSemuaAntrianPage> {
  final AntrianRsService _antrianService = AntrianRsService();
  List<AntrianRs> _allAntrian = [];
  bool _isLoading = true;
  bool _isRefreshing = false; // State untuk loading refresh button

  @override
  void initState() {
    super.initState();
    _fetchAllAntrian();
  }

  Future<void> _fetchAllAntrian() async {
    if (!_isRefreshing) {
      setState(() => _isRefreshing = true);
    }
    
    setState(() => _isLoading = true);
    
    try {
      // TODO: Kembalikan ke DateTime.now() setelah selesai testing
      final todayString = '2026-06-04';
      final antrian = await _antrianService.getAllAntrianRs(
        tanggal: todayString,
      );
      
      if (mounted) {
        setState(() {
          _allAntrian = antrian;
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _allAntrian = [];
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }
  
  // Helper: Filter antrian berdasarkan status
  // TIDAK tampilkan yang sedang dilayani dan yang di-skip - hanya tracking local
  
  List<AntrianRs> get _menunggu => 
      _allAntrian.where((a) => a.status?.toLowerCase() == 'lunas').toList();
  
  List<AntrianRs> get _selesai => 
      _allAntrian.where((a) => a.status?.toLowerCase() == 'obat_diserahkan').toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Semua Antrian',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textDark),
                    ),
                  )
                : const Icon(Icons.refresh, color: AppColors.textDark),
            onPressed: _isRefreshing ? null : _fetchAllAntrian,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _allAntrian.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchAllAntrian,
                  color: AppColors.primary,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Menunggu
                      if (_menunggu.isNotEmpty) ...[
                        _buildSectionHeader('Menunggu', _menunggu.length, AppColors.warning),
                        const SizedBox(height: 12),
                        ..._menunggu.map((a) => _buildAntrianCard(a, 'menunggu')),
                        const SizedBox(height: 20),
                      ],
                      
                      // Selesai
                      if (_selesai.isNotEmpty) ...[
                        _buildSectionHeader('Selesai', _selesai.length, AppColors.teal),
                        const SizedBox(height: 12),
                        ..._selesai.map((a) => _buildAntrianCard(a, 'selesai')),
                      ],
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.borderLight,
          ),
          const SizedBox(height: 12),
          const Text(
            'Tidak ada antrian',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _isRefreshing ? null : _fetchAllAntrian,
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh, size: 18),
            label: Text(_isRefreshing ? 'Memuat...' : 'Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAntrianCard(AntrianRs antrian, String statusType) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    
    switch (statusType) {
      case 'menunggu':
        statusColor = AppColors.warning;
        statusLabel = 'Menunggu';
        statusIcon = Icons.hourglass_bottom_rounded;
        break;
      case 'selesai':
        statusColor = AppColors.teal;
        statusLabel = 'Selesai';
        statusIcon = Icons.check_circle_rounded;
        break;
      default:
        statusColor = AppColors.textMuted;
        statusLabel = antrian.status ?? '-';
        statusIcon = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Nomor antrian
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              antrian.nomorAntrian ?? '?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info pasien
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  antrian.namaPasien ?? 'Pasien #${antrian.idPasien}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                if (antrian.namaUnit != null)
                  Text(
                    antrian.namaUnit!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
