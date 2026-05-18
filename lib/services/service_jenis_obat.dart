// Service untuk CRUD jenis obat via API
import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_error_handler.dart';
import '../core/network/dio_client.dart';
import '../models/jenis_obat.dart';

// Service jenis obat — kategori/tipe obat
class JenisObatService {
  final DioClient _dioClient = DioClient.apotik;

  // Ambil semua jenis obat
  Future<List<JenisObatModel>> getAllJenisObat() async {
    try {
      final response = await _dioClient.get(ApiConstants.jenisObat);

      if (response.statusCode == 200) {
        final data = ApiErrorHandler.parseListData(response.data, 'getAllJenisObat');
        return data.map((json) => JenisObatModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Gagal memuat jenis obat: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Ambil jenis obat berdasarkan id
  Future<JenisObatModel> getJenisObatById(int id) async {
    try {
      final response = await _dioClient.get('${ApiConstants.jenisObat}/$id');

      if (response.statusCode == 200) {
        return JenisObatModel.fromJson(
          ApiErrorHandler.requireData(response.data, 'getJenisObatById') as Map<String, dynamic>,
        );
      } else {
        throw Exception('Gagal memuat jenis obat: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Tambah jenis obat baru
  Future<JenisObatModel> createJenisObat(JenisObatModel jenisObat) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.jenisObat,
        data: jenisObat.toJsonForCreate(),
      );

      if (response.statusCode == 201) {
        return JenisObatModel.fromJson(
          ApiErrorHandler.requireData(response.data, 'createJenisObat') as Map<String, dynamic>,
        );
      } else {
        throw Exception('Gagal menambahkan jenis obat: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Update data jenis obat
  Future<JenisObatModel> updateJenisObat(int id, JenisObatModel jenisObat) async {
    try {
      final response = await _dioClient.put(
        '${ApiConstants.jenisObat}/$id',
        data: jenisObat.toJsonForCreate(),
      );

      if (response.statusCode == 200) {
        return JenisObatModel.fromJson(
          ApiErrorHandler.requireData(response.data, 'updateJenisObat') as Map<String, dynamic>,
        );
      } else {
        throw Exception('Gagal mengupdate jenis obat: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Hapus jenis obat berdasarkan id
  Future<void> deleteJenisObat(int id) async {
    try {
      final response = await _dioClient.delete('${ApiConstants.jenisObat}/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Gagal menghapus jenis obat: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }
}
