// Halaman profil admin — info user, employee ID, dan logout
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/role_constants.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/widgets/profile_avatar_header.dart';
import '../../core/widgets/profile_info_section.dart';
import '../../core/widgets/logout_button.dart';
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
      _email = await _storage.read(key: StorageKeys.authEmail);
      _role = await _storage.read(key: StorageKeys.authRole);
      final userIdStr = await _storage.read(key: StorageKeys.authUserId);
      _userId = userIdStr != null ? int.tryParse(userIdStr) : null;
    } catch (e) {
      // Jika gagal baca storage, biarkan null
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // Konversi role API ke label jabatan — delegate ke RoleConstants terpusat

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
                  ProfileAvatarHeader(
                    displayName: 'dr. Rina Wulandari, M.Kes.',
                    roleDisplay: RoleConstants.getDisplayLabel(_role ?? RoleConstants.adminApotik),
                    photoAsset: AppAssets.fotoProfileAdmin,
                    emailFallback: _email,
                  ),
                  const SizedBox(height: 24),
                  ProfileInfoSection(
                    email: _email ?? '-',
                    phone: '081378294501',
                    employeeId: _userId != null ? 'APT-ADM-${_userId.toString().padLeft(3, '0')}' : 'APT-ADM-000',
                    employeeIdLabel: 'ID ADMIN',
                  ),
                  const SizedBox(height: 32),
                  const LogoutButton(),
                  const SizedBox(height: 24),
                ]),
              ),
      ),
    );
  }
}
