// Halaman profil petugas — info user dan logout
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../providers/provider_auth.dart';
import 'widgets/profile_info_row.dart';

// Tab profil petugas — info akun dan session
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _email;
  String? _role;
  int? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final storage = const FlutterSecureStorage();
    setState(() => _isLoading = true);
    try {
      _email = await storage.read(key: 'auth_email');
      _role = await storage.read(key: 'auth_role');
      final userIdStr = await storage.read(key: 'auth_user_id');
      _userId = userIdStr != null ? int.tryParse(userIdStr) : null;
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading profile data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMint,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        shape: const Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildInfoSection(),
                    const SizedBox(height: 32),
                    _buildLogoutButton(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    const displayName = "apt. Marie Curie, S.Farm.";
    final roleDisplay = _getRoleDisplay(_role ?? 'apoteker');
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surface, width: 3),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: ClipOval(
            child: Image.asset(
              AppAssets.fotoProfileApoteker01,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                final initial = (_email ?? 'A')[0].toUpperCase();
                return Container(
                  color: AppColors.primary,
                  child: Center(
                    child: Text(initial, style: const TextStyle(fontFamily: 'Poppins', fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(displayName, style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text(roleDisplay, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.primaryLight)),
      ],
    );
  }

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
      case 'admin_perawat':
        return 'Admin Perawat';
      case 'dokter':
        return 'Dokter';
      case 'perawat':
        return 'Perawat';
      default:
        return role;
    }
  }

  Widget _buildInfoSection() {
    final email = _email ?? '-';
    const phone = "08514804556";
    final employeeId = _userId != null
        ? 'APT-APOTEKER-${_userId.toString().padLeft(3, '0')}'
        : 'APT-APOTEKER-000';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informasi Pribadi', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                ProfileInfoRow(icon: Icons.email_outlined, label: 'EMAIL', value: email, divider: true),
                ProfileInfoRow(icon: Icons.phone_outlined, label: 'NOMOR TELEPON', value: phone, divider: true),
                ProfileInfoRow(icon: Icons.badge_outlined, label: 'ID PEGAWAI', value: employeeId, divider: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () async {
            await context.read<AuthProvider>().logout();
            if (!context.mounted) return;
            context.go('/login');
          },
          icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
          label: const Text(
            'Keluar',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}
