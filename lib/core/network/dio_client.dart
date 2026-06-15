// Dio HTTP client — dua instance (simrs & apotik) dengan interceptor token
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';

// Dio client dengan interceptor auto-attach token dan auto-refresh
class DioClient {
  static final DioClient simrs = DioClient._internal(ApiConstants.simrsBaseUrl);
  static final DioClient apotik = DioClient._internal(ApiConstants.apotikBaseUrl);

  // Default ke SIMRS (auth, antrian RS)
  factory DioClient() => simrs;

  late final Dio dio;
  final String baseUrl;
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  DioClient._internal(this.baseUrl) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: StorageKeys.authToken);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            debugPrint('[AUTH] Token expired/invalid — clearing auth data.');
            // Hapus semua data auth agar user dipaksa login ulang
            await _storage.delete(key: StorageKeys.authToken);
            await _storage.delete(key: StorageKeys.authRole);
            await _storage.delete(key: StorageKeys.authEmail);
            await _storage.delete(key: StorageKeys.authUserId);
            await _storage.delete(key: StorageKeys.authExpiredAt);
          }
          return handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint('[DIO $baseUrl] $obj'),
        ),
      );
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) {
    return dio.patch(path, data: data);
  }

  Future<Response> delete(String path) {
    return dio.delete(path);
  }
}
