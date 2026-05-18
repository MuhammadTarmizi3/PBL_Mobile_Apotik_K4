// Service untuk ambil data antrian dari API SIMRS (Kelompok 1)
import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_error_handler.dart';
import '../core/network/dio_client.dart';
import '../models/antrian_rs.dart';

// Service antrian RS — data pasien yang sudah bayar dan masuk ke apotik
class AntrianRsService {
  final DioClient _dioClient = DioClient.simrs;

  // Parse response antrian yang bisa berupa Map per unit atau List biasa
  List<AntrianRs> _parseAntrianResponse(dynamic responseData) {
    List<AntrianRs> allAntrian = [];

    // Response dikelompokkan per unit (object dengan key unit_id)
    if (responseData is Map) {
      for (final unitData in responseData.values) {
        if (unitData is List) {
          for (final json in unitData) {
            if (json is Map<String, dynamic>) {
              allAntrian.add(AntrianRs.fromJson(json));
            }
          }
        }
      }
    }
    // Fallback: response langsung array (format lama)
    else if (responseData is List) {
      allAntrian = responseData
          .map((json) => AntrianRs.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return allAntrian;
  }

  // Ambil semua antrian RS hari ini, optional filter tanggal
  Future<List<AntrianRs>> getAllAntrianRs({String? tanggal}) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.antrianRs,
        queryParameters: tanggal != null ? {'tanggal': tanggal} : null,
      );

      if (response.statusCode == 200) {
        final responseData = ApiErrorHandler.requireData(response.data, 'getAllAntrianRs');
        return _parseAntrianResponse(responseData);
      } else {
        throw Exception('Gagal memuat antrian RS: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Ambil antrian yang sudah lunas (siap diproses apotik)
  Future<List<AntrianRs>> getAntrianSelesaiBayar({String? tanggal}) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.antrianRs,
        queryParameters: tanggal != null ? {'tanggal': tanggal} : null,
      );

      if (response.statusCode == 200) {
        final responseData = ApiErrorHandler.requireData(response.data, 'getAntrianSelesaiBayar');
        final allAntrian = _parseAntrianResponse(responseData);

        // Filter hanya yang statusnya "lunas" (sudah bayar)
        return allAntrian.where((antrian) {
          final status = antrian.status?.toLowerCase() ?? '';
          return status == 'lunas';
        }).toList();
      } else {
        throw Exception('Gagal memuat antrian RS: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Ambil antrian RS berdasarkan status
  Future<List<AntrianRs>> getAntrianByStatus(String status) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.antrianRs,
        queryParameters: {'status': status},
      );

      if (response.statusCode == 200) {
        final data = ApiErrorHandler.requireData(response.data, 'getAntrianByStatus');

        if (data is List) {
          return data.map((json) => AntrianRs.fromJson(json as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic>) {
          return [AntrianRs.fromJson(data)];
        } else {
          return [];
        }
      } else {
        throw Exception('Gagal memuat antrian RS: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Ambil antrian RS berdasarkan id
  Future<AntrianRs> getAntrianById(int id) async {
    try {
      final response = await _dioClient.get('${ApiConstants.antrianRs}/$id');

      if (response.statusCode == 200) {
        return AntrianRs.fromJson(
          ApiErrorHandler.requireData(response.data, 'getAntrianById') as Map<String, dynamic>,
        );
      } else {
        throw Exception('Gagal memuat antrian RS: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Ambil antrian milik pasien yang sedang login
  Future<AntrianRs?> getAntrianSaya() async {
    try {
      final response = await _dioClient.get('${ApiConstants.antrianRs}/saya');

      if (response.statusCode == 200) {
        return AntrianRs.fromJson(
          ApiErrorHandler.requireData(response.data, 'getAntrianSaya') as Map<String, dynamic>,
        );
      } else {
        return null;
      }
    } on DioException catch (e) {
      // 404 = tidak ada antrian, return null
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Update status antrian RS (misal: obat_diserahkan)
  Future<AntrianRs> updateStatusAntrian(int id, String status) async {
    try {
      final response = await _dioClient.put(
        '${ApiConstants.antrianRs}/$id/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return AntrianRs.fromJson(
          ApiErrorHandler.requireData(response.data, 'updateStatusAntrian') as Map<String, dynamic>,
        );
      } else {
        throw Exception('Gagal mengubah status antrian: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }
}
