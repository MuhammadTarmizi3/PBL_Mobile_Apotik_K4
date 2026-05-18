// Service untuk CRUD e-Resep via API (dengan eager load detail_resep & obat)
import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_error_handler.dart';
import '../core/network/dio_client.dart';
import '../models/resep.dart';

// Service e-Resep — CRUD data resep dan update status
class ResepService {
  final DioClient _dioClient = DioClient.apotik;

  // Ambil semua resep dengan detail_resep dan obat
  Future<List<Resep>> getAllResep() async {
    try {
      final response = await _dioClient.get(
        ApiConstants.eResep,
        queryParameters: {'with': 'detail_resep.obat'},
      );

      if (response.statusCode == 200) {
        final data = ApiErrorHandler.parseListData(response.data, 'getAllResep');
        return data.map((json) => Resep.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Gagal memuat resep: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Ambil resep berdasarkan id dengan detail
  Future<Resep> getResepById(int id) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.eResep}/$id',
        queryParameters: {'with': 'detail_resep.obat'},
      );

      if (response.statusCode == 200) {
        return Resep.fromJson(
          ApiErrorHandler.requireData(response.data, 'getResepById') as Map<String, dynamic>,
        );
      } else {
        throw Exception('Gagal memuat resep: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Ambil resep berdasarkan status (dengan detail)
  Future<List<Resep>> getResepByStatus(String status) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.eResep,
        queryParameters: {
          'status': status,
          'with': 'detail_resep.obat',
        },
      );

      if (response.statusCode == 200) {
        final data = ApiErrorHandler.parseListData(response.data, 'getResepByStatus');
        return data.map((json) => Resep.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Gagal memuat resep: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Ambil resep berdasarkan id antrian, return null jika tidak ada
  Future<Resep?> getResepByIdAntrian(int idAntrian) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.eResep,
        queryParameters: {
          'id_antrian': idAntrian,
          'with': 'detail_resep.obat',
        },
      );

      if (response.statusCode == 200) {
        final data = ApiErrorHandler.parseListData(response.data, 'getResepByIdAntrian');
        if (data.isEmpty) return null;
        return Resep.fromJson(data.first as Map<String, dynamic>);
      } else {
        throw Exception('Gagal memuat resep: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Tambah resep baru
  Future<Resep> createResep(Resep resep) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.eResep,
        data: resep.toJsonForCreate(),
      );

      if (response.statusCode == 201) {
        return Resep.fromJson(
          ApiErrorHandler.requireData(response.data, 'createResep') as Map<String, dynamic>,
        );
      } else {
        throw Exception('Gagal menambahkan resep: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Update data resep (status atau catatan)
  Future<Resep> updateResep(int id, Resep resep) async {
    try {
      final response = await _dioClient.put(
        '${ApiConstants.eResep}/$id',
        data: resep.toJsonForCreate(),
      );

      if (response.statusCode == 200) {
        return Resep.fromJson(
          ApiErrorHandler.requireData(response.data, 'updateResep') as Map<String, dynamic>,
        );
      } else {
        throw Exception('Gagal mengupdate resep: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Update status resep saja (PATCH)
  Future<Resep> updateStatusResep(int id, String status) async {
    try {
      final response = await _dioClient.patch(
        '${ApiConstants.eResep}/$id/status',
        data: {'STATUS_RESEP': status},
      );

      if (response.statusCode == 200) {
        return Resep.fromJson(
          ApiErrorHandler.requireData(response.data, 'updateStatusResep') as Map<String, dynamic>,
        );
      } else {
        throw Exception('Gagal mengupdate status resep: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Hapus resep berdasarkan id
  Future<void> deleteResep(int id) async {
    try {
      final response = await _dioClient.delete('${ApiConstants.eResep}/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Gagal menghapus resep: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }
}
