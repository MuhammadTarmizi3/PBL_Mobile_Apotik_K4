// Provider state management untuk autentikasi user
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/service_auth.dart';
import '../models/user.dart';
import '../core/constants/storage_keys.dart';
import '../core/constants/role_constants.dart';

// Provider autentikasi — login, logout, session management via secure storage
class AuthProvider with ChangeNotifier {
  static const String _storageKeyEmail = StorageKeys.authEmail;
  static const String _storageKeyRole = StorageKeys.authRole;
  static const String _storageKeyToken = StorageKeys.authToken;
  static const String _storageKeyUserId = StorageKeys.authUserId;
  static const String _storageKeyExpiredAt = StorageKeys.authExpiredAt;

  // Akun demo sudah tidak dipakai, login sekarang via API

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();

  String? _email;
  String? _role; // role user dari backend (admin, apoteker, perawat, dll)
  String? _token;
  int? _userId;
  String? _expiredAt;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters — akses state auth dari luar
  String? get email => _email;
  String? get role => _role;
  String? get token => _token;
  int? get userId => _userId;
  String? get expiredAt => _expiredAt;
  UserModel? get userProfile => _userProfile;
  bool get isAuthenticated => _role != null && _token != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => RoleConstants.isAdmin(_role);
  bool get isApoteker => _role == RoleConstants.apoteker || _role == RoleConstants.adminApotik;
  bool get isPetugas => RoleConstants.isPetugas(_role);

  // Muat session dari secure storage saat app dibuka
  Future<void> init() async {
    _email = await _storage.read(key: _storageKeyEmail);
    _role = await _storage.read(key: _storageKeyRole);
    _token = await _storage.read(key: _storageKeyToken);
    final userIdStr = await _storage.read(key: _storageKeyUserId);
    _userId = userIdStr != null ? int.tryParse(userIdStr) : null;
    _expiredAt = await _storage.read(key: _storageKeyExpiredAt);
    notifyListeners();
  }

  // Login via API Kelompok 1
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Panggil API login
      final data = await _authService.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      // Extract data user dari response
      _token = data['token'] as String;
      
      final user = data['user'] as Map<String, dynamic>;
      _email = user['email'] as String;
      _userId = user['id'] as int;
      
      // Extract expired_at dari token_info jika ada
      if (user.containsKey('token_info') && user['token_info'] is Map) {
        final tokenInfo = user['token_info'] as Map<String, dynamic>;
        _expiredAt = tokenInfo['expired_at'] as String?;
      }
      
      // Mapping role dari array roles yang dikirim backend
      final roles = user['roles'] as List<dynamic>;
      
      // Role ditentukan 100% dari backend, tidak ada hardcode di client
      
      if (roles.contains('superadmin')) {
        _role = 'superadmin';
      } else if (roles.contains('admin')) {
        _role = 'admin';
      } else if (roles.contains('admin_apotik')) {
        _role = 'admin_apotik';
      } else if (roles.contains('apoteker')) {
        _role = 'apoteker';
      } else if (roles.contains('admin_perawat')) {
        _role = 'admin_perawat';
      } else if (roles.contains('dokter')) {
        _role = 'dokter';
      } else if (roles.contains('perawat')) {
        _role = 'perawat';
      } else if (roles.contains('pasien')) {
        _role = 'pasien';
      } else if (roles.isNotEmpty) {
        _role = roles.first as String; // fallback ke role pertama
      } else {
        _role = 'pasien'; // default jika roles kosong
      }

      debugPrint('Role dipilih: $_role | isAdmin: $isAdmin | isPetugas: $isPetugas');

      // Simpan session ke secure storage
      await _saveAuthData(_email!, _role!, _token!, _userId!, _expiredAt);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout — panggil API lalu hapus session local
  Future<void> logout() async {
    try {
      if (_token != null) {
        await _authService.logout();
      }
    } catch (e) {
      debugPrint('Logout API error (ignored): $e');
    } finally {
      _email = null;
      _role = null;
      _token = null;
      _userId = null;
      _expiredAt = null;
      _userProfile = null;
      
      await _storage.delete(key: _storageKeyEmail);
      await _storage.delete(key: _storageKeyRole);
      await _storage.delete(key: _storageKeyToken);
      await _storage.delete(key: _storageKeyUserId);
      await _storage.delete(key: _storageKeyExpiredAt);
      
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Fetch profil user dari API /auth/me
  Future<void> fetchUserProfile() async {
    if (_token == null) {
      debugPrint('Cannot fetch profile: No token available');
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _authService.getCurrentUser();
      _userProfile = UserModel.fromJson(data);
      
      // Update email & userId dari profile jika berbeda
      if (_userProfile != null) {
        _email = _userProfile!.email;
        _userId = _userProfile!.id;
      }

      debugPrint('[OK] User profile fetched: ${_userProfile?.displayName}');
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      debugPrint('âŒ Failed to fetch user profile: $_errorMessage');
      notifyListeners();
    }
  }

  // Simpan data autentikasi ke secure storage
  Future<void> _saveAuthData(String email, String role, String token, int userId, String? expiredAt) async {
    await _storage.write(key: _storageKeyEmail, value: email);
    await _storage.write(key: _storageKeyRole, value: role);
    await _storage.write(key: _storageKeyToken, value: token);
    await _storage.write(key: _storageKeyUserId, value: userId.toString());
    if (expiredAt != null) {
      await _storage.write(key: _storageKeyExpiredAt, value: expiredAt);
    }
  }

  // Reset error message
  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }
}
