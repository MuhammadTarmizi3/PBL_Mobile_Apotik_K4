// Halaman profil petugas — info user dan logout
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
      _email = await storage.read(key: StorageKeys.authEmail);
      _role = await storage.read(key: StorageKeys.authRole);
      final userIdStr = await storage.read(key: StorageKeys.authUserId);
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
      appBar: const CustomAppBar(
        title: 'Profile',
        centerTitle: true,
        showBackButton: false,
        backgroundColor: AppColors.backgroundMint,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    ProfileAvatarHeader(
                      displayName: 'apt. Marie Curie, S.Farm.',
                      roleDisplay: RoleConstants.getDisplayLabel(_role ?? RoleConstants.apoteker),
                      photoAsset: AppAssets.fotoProfileApoteker01,
                      emailFallback: _email,
                    ),
                    const SizedBox(height: 24),
                    ProfileInfoSection(
                      email: _email ?? '-',
                      phone: '08514804556',
                      employeeId: _userId != null ? 'APT-APOTEKER-${_userId.toString().padLeft(3, '0')}' : 'APT-APOTEKER-000',
                    ),
                    const SizedBox(height: 32),
                    const LogoutButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
