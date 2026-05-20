// Halaman profil admin — info user, employee ID, dan logout
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../providers/provider_auth.dart';
import '../../core/widgets/layouts/custom_app_bar.dart';

// Halaman profil admin dengan info user dan tombol logout
class ProfileAdminPage extends StatefulWidget {
  const ProfileAdminPage({super.key});

  @override
  State<ProfileAdminPage> createState() => _ProfileAdminPageState();
}

class _ProfileAdminPageState extends State<ProfileAdminPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _email;
  String? _role;
  int? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Load data user dari secure storage
  Future<void> _loadProfileData() async {
    try {
      _email = await _storage.read(key: 'auth_email');
      _role = await _storage.read(key: 'auth_role');
      final userIdStr = await _storage.read(key: 'auth_user_id');
      _userId = userIdStr != null ? int.tryParse(userIdStr) : null;
    } catch (e) {
      // Jika gagal baca storage, biarkan null
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // Konversi role API ke label jabatan yang user-friendly
  String _getRoleDisplay(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
      case 'superadmin':
      case 'admin_apotik':
        return 'Administrator';
      case 'apoteker':
        return 'Apoteker';
      case 'petugas':
        return 'Petugas Apotek';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Profile',
        centerTitle: true,
        showBackButton: false,
        backgroundColor: AppColors.backgroundMint,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                child: Column(children: [
                  const SizedBox(height: 24),
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildInfoSection(),
                  const SizedBox(height: 32),
                  _buildLogoutButton(context),
                  const SizedBox(height: 24),
                ]),
              ),
      ),
    );
  }

  // Header profil dengan foto admin, nama dummy, dan jabatan
  Widget _buildProfileHeader() {
    // Data dummy hardcode (sama seperti petugas)
    const displayName = 'dr. Rina Wulandari, M.Kes.';
    final roleDisplay = _getRoleDisplay(_role ?? 'admin_apotik');

    return Column(
      children: [
        const SizedBox(height: 16),
        // Foto profil dari asset lokal
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surface, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              AppAssets.fotoProfileAdmin,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback ke initial jika gambar gagal load
                final initial = (_email ?? 'A')[0].toUpperCase();
                return Container(
                  color: AppColors.primary,
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          displayName,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          roleDisplay,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryLight,
          ),
        ),
      ],
    );
  }

  // Kotak informasi pribadi dengan email dari API, telepon dummy, dan ID admin
  Widget _buildInfoSection() {
    // Email dari SharedPreferences (API Kelompok 1)
    final email = _email ?? '-';

    // Data dummy hardcode
    const phone = '081378294501';

    // ID Admin: generate dari userId
    final employeeId = _userId != null
        ? 'APT-ADM-${_userId.toString().padLeft(3, '0')}'
        : 'APT-ADM-000';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Informasi Pribadi', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(children: [
            _infoRow(icon: Icons.email_outlined,   label: 'EMAIL',         value: email,  divider: true),
            _infoRow(icon: Icons.phone_outlined,   label: 'NOMOR TELEPON', value: phone,    divider: true),
            _infoRow(icon: Icons.badge_outlined,   label: 'ID ADMIN',      value: employeeId,          divider: false),
          ]),
        ),
      ]),
    );
  }

  Widget _infoRow({required IconData icon, required String label, required String value, required bool divider}) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.grey, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
          ])),
        ]),
      ),
      if (divider) const Divider(height: 1, thickness: 1, indent: 72, color: AppColors.border),
    ]);
  }

  Widget _buildLogoutButton(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton.icon(
        onPressed: () async {
          await context.read<AuthProvider>().logout();
          if (!context.mounted) return;
          context.go('/login');
        },
        icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
        label: const Text('Keluar', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
    ),
  );
}
