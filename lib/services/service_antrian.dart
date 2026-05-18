// Service untuk CRUD antrian pengambilan obat via API
import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_error_handler.dart';
import '../core/network/dio_client.dart';
import '../models/antrian.dart';

// Service antrian pengambilan obat apotek
class AntrianService {
  final DioClient _dioClient = DioClient.apotik;

  // Ambil semua antrian dari API
  Future<List<Antrian>> getAllAntrian() async {
    try {
      final response = await _dioClient.get(ApiConstants.antrianPengambilanObat);

      if (response.statusCode == 200) {
        final data = ApiErrorHandler.parseListData(response.data, 'getAllAntrian');
        return data.map((json) => Antrian.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Gagal memuat antrian: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Ambil antrian berdasarkan id
  Future<Antrian> getAntrianById(int id) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.antrianPengambilanObat}/$id',
      );

      if (response.statusCode == 200) {
        return Antrian.fromJson(
          ApiErrorHandler.requireData(response.data, 'getAntrianById') as Map<String, dynamic>,
        );
      } else {
        throw Exception('Gagal memuat antrian: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Buat antrian baru dari id resep
  Future<Antrian> createAntrian({required int idResep}) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.antrianPengambilanObat,
        data: {'ID_RESEP': idResep},
      );

      if (response.statusCode == 201) {
        return Antrian.fromJson(
          ApiErrorHandler.requireData(response.data, 'createAntrian') as Map<String, dynamic>,
        );
      } else {
        throw Exception('Gagal menambahkan antrian: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Update status antrian (MENUNGGU/DIPROSES/SELESAI)
  Future<Antrian> updateStatusAntrian(int id, String status) async {
    try {
      final response = await _dioClient.put(
        '${ApiConstants.antrianPengambilanObat}/$id',
        data: {'STATUS': status},
      );

      if (response.statusCode == 200) {
        return Antrian.fromJson(
          ApiErrorHandler.requireData(response.data, 'updateStatusAntrian') as Map<String, dynamic>,
        );
      } else {
        throw Exception('Gagal mengupdate status antrian: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }

  // Hapus antrian berdasarkan id
  Future<void> deleteAntrian(int id) async {
    try {
      final response = await _dioClient.delete(
        '${ApiConstants.antrianPengambilanObat}/$id',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Gagal menghapus antrian: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioException(e);
    } catch (e) {
      throw Exception('Error tidak terduga: $e');
    }
  }
}
