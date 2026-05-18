// Service untuk autentikasi user via API SIMRS (Kelompok 1)
import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_error_handler.dart';
import '../core/network/dio_client.dart';

// Service autentikasi — login, logout, refresh token, get current user
class AuthService {
  final DioClient _dioClient = DioClient.simrs;

  // Login user dengan email & password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
          'remember_me': rememberMe,
        },
      );

      if (response.statusCode == 200) {
        final data = ApiErrorHandler.requireData(response.data, 'login') as Map<String, dynamic>;

        // Pastikan token dan user ada di response
        if (data['token'] == null || data['user'] == null) {
          throw Exception('Response tidak lengkap dari server');
        }

        return data;
      } else {
        throw Exception('Login gagal: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Refresh token yang sudah expired
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final response = await _dioClient.post(ApiConstants.refreshToken);

      if (response.statusCode == 200) {
        return ApiErrorHandler.requireData(response.data, 'refreshToken') as Map<String, dynamic>;
      } else {
        throw Exception('Refresh token gagal: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Ambil data user yang sedang login
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dioClient.get(ApiConstants.authMe);

      if (response.statusCode == 200) {
        // Response bisa wrapped {data: ...} atau langsung object user
        if (response.data is Map && response.data['data'] != null) {
          return response.data['data'] as Map<String, dynamic>;
        } else {
          return response.data as Map<String, dynamic>;
        }
      } else {
        throw Exception('Gagal mendapat user: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Logout user (hapus token di local, endpoint optional)
  Future<void> logout() async {
    try {
      // Endpoint logout mungkin tidak ada di backend, abaikan error
      final response = await _dioClient.post(ApiConstants.logout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Logout gagal: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // 404 = endpoint tidak ada, logout tetap sukses di local
      if (e.response?.statusCode == 404) {
        return; // Logout tetap berhasil di local
      }
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }
}
