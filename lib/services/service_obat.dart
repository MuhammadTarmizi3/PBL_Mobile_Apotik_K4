// Service untuk CRUD obat via API (dengan relasi jenis_obat)
import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_error_handler.dart';
import '../core/network/dio_client.dart';
import '../models/obat.dart';

// Service obat — CRUD data obat apotek
class ObatService {
  final DioClient _dioClient = DioClient.apotik;

  // Ambil semua obat dari API
  Future<List<ObatModel>> getAllObat() async {
    try {
      final response = await _dioClient.get(ApiConstants.obat);

      if (response.statusCode == 200) {
        final data = ApiErrorHandler.parseListData(response.data, 'getAllObat');
        return data.map((json) => ObatModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Gagal memuat obat: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Ambil obat berdasarkan id
  Future<ObatModel> getObatById(int id) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.obat}/$id',
      );

      if (response.statusCode == 200) {
        return ObatModel.fromJson(
          ApiErrorHandler.requireData(response.data, 'getObatById') as Map<String, dynamic>,
        );
      } else {
        throw Exception('Gagal memuat obat: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Ambil obat berdasarkan id jenis obat
  Future<List<ObatModel>> getObatByJenisObat(int idJenisObat) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.obat,
        queryParameters: {
          'id_jenis_obat': idJenisObat,
        },
      );

      if (response.statusCode == 200) {
        final data = ApiErrorHandler.parseListData(response.data, 'getObatByJenisObat');
        return data.map((json) => ObatModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Gagal memuat obat: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Tambah obat baru
  Future<ObatModel> createObat(ObatModel obat) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.obat,
        data: obat.toJson(),
      );

      if (response.statusCode == 201) {
        return ObatModel.fromJson(
          ApiErrorHandler.requireData(response.data, 'createObat') as Map<String, dynamic>,
        );
      } else {
        throw Exception('Gagal menambahkan obat: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Update data obat
  Future<ObatModel> updateObat(int id, ObatModel obat) async {
    try {
      final response = await _dioClient.put(
        '${ApiConstants.obat}/$id',
        data: obat.toJsonForCreate(),
      );

      if (response.statusCode == 200) {
        return ObatModel.fromJson(
          ApiErrorHandler.requireData(response.data, 'updateObat') as Map<String, dynamic>,
        );
      } else {
        throw Exception('Gagal mengupdate obat: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Hapus obat berdasarkan id
  Future<void> deleteObat(int id) async {
    try {
      final response = await _dioClient.delete('${ApiConstants.obat}/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Gagal menghapus obat: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Update stok obat saja berdasarkan id
  Future<ObatModel> updateStokObat(int id, int stokBaru) async {
    try {
      final response = await _dioClient.put(
        '${ApiConstants.obat}/$id',
        data: {'STOK': stokBaru},
      );

      if (response.statusCode == 200) {
        return ObatModel.fromJson(
          ApiErrorHandler.requireData(response.data, 'updateStokObat') as Map<String, dynamic>,
        );
      } else {
        throw Exception('Gagal mengupdate stok obat: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Cari obat berdasarkan nama (search query)
  Future<List<ObatModel>> searchObat(String query) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.obat,
        queryParameters: {
          'search': query,
        },
      );

      if (response.statusCode == 200) {
        final data = ApiErrorHandler.parseListData(response.data, 'searchObat');
        return data.map((json) => ObatModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Gagal mencari obat: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }
}
