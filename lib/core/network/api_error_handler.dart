// Handler error Dio terpusat — satu sumber untuk semua service layer
import 'package:dio/dio.dart';

// Handler error Dio dengan pesan user-friendly
class ApiErrorHandler {
  ApiErrorHandler._();

  // Konversi DioException ke Exception dengan pesan yang mudah dipahami user
  static Exception handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Koneksi timeout. Cek koneksi internet Anda.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? 'Terjadi kesalahan server';
        return Exception('Error $statusCode: $message');
      case DioExceptionType.cancel:
        return Exception('Request dibatalkan');
      case DioExceptionType.connectionError:
        return Exception('Tidak dapat terhubung ke server. Cek koneksi internet atau backend Anda.');
      default:
        return Exception('Error jaringan: ${e.message}');
    }
  }

  // Cek apakah statusCode termasuk sukses (200/201/204)
  static bool isSuccessStatus(int? statusCode) {
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }

  // Extract field 'data' dari response body, lempar exception jika tidak ada
  static T extractData<T>(dynamic responseBody, String context) {
    if (responseBody is! Map<String, dynamic>) {
      throw Exception('$context: Format response tidak sesuai (expected Map)');
    }
    final data = responseBody['data'];
    if (data == null) {
      throw Exception('$context: Field "data" kosong dalam response');
    }
    if (data is T) return data;
    throw Exception('$context: Field "data" bukan tipe yang diharapkan ($T)');
  }

  // Extract 'data' dari response API, throw error jika null
  static dynamic requireData(dynamic responseBody, String context) {
    if (responseBody is Map<String, dynamic>) {
      final data = responseBody['data'];
      if (data != null) return data;
      throw Exception('$context: Field "data" kosong dalam response');
    }
    throw Exception('$context: Format response tidak sesuai');
  }

  // Parse response array — support format direct array & wrapped {"data": [...]}
  static List<dynamic> parseListData(dynamic responseBody, String context) {
    // Format 1: Direct array [...] (API Apotik)
    if (responseBody is List) return responseBody;

    // Format 2: Wrapped {"data": [...]} (API SIMRS)
    if (responseBody is Map<String, dynamic>) {
      final data = responseBody['data'];
      if (data is List) return data;
      // Single object → wrap in list
      if (data is Map<String, dynamic>) return [data];
      if (data == null) {
        throw Exception('$context: Field "data" kosong dalam response');
      }
    }

    throw Exception('$context: Format response bukan array');
  }
}
