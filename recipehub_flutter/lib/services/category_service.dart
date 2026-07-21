// services/category_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../config/api_config.dart';
import '../models/category.dart';

class CategoryService {
  // GET ALL CATEGORIES
  static Future<Map<String, dynamic>> getCategories({
    required int userId,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.categories}?user_id=$userId');

      final response = await http
          .get(
            url,
            headers: ApiConfig.headers,
          )
          .timeout(ApiConfig.requestTimeout);

      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        final List<dynamic> categoryList = responseData['data'] ?? [];
        final categories =
            categoryList.map((json) => Category.fromJson(json)).toList();

        return {
          'success': true,
          'message': responseData['message'] ?? 'Data loaded',
          'categories': categories,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal load kategori',
          'categories': <Category>[],
        };
      }
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'message': 'Permintaan timeout',
        'categories': <Category>[],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
        'categories': <Category>[],
      };
    }
  }

  // ADD CATEGORY
  static Future<Map<String, dynamic>> addCategory({
    required int userId,
    required String name,
  }) async {
    try {
      final body = {
        'user_id': userId.toString(),
        'name': name,
      };

      final response = await http
          .post(
            Uri.parse(ApiConfig.categories),
            headers: ApiConfig.headers,
            body: body,
          )
          .timeout(ApiConfig.requestTimeout);

      final responseData = jsonDecode(response.body);

      return {
        'success': responseData['success'] ?? false,
        'message': responseData['message'] ?? 'Gagal tambah kategori',
        'category_id': responseData['data']?['id'],
      };
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'message': 'Permintaan timeout',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // EDIT CATEGORY
  static Future<Map<String, dynamic>> editCategory({
    required int categoryId,
    required int userId,
    required String name,
  }) async {
    try {
      final body = {
        'user_id': userId.toString(),
        'name': name,
      };

      final response = await http
          .put(
            Uri.parse(ApiConfig.categoryDetail(categoryId)),
            headers: ApiConfig.headers,
            body: body,
          )
          .timeout(ApiConfig.requestTimeout);

      final responseData = jsonDecode(response.body);

      return {
        'success': responseData['success'] ?? false,
        'message': responseData['message'] ?? 'Gagal update kategori',
      };
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'message': 'Permintaan timeout',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // DELETE CATEGORY
  static Future<Map<String, dynamic>> deleteCategory({
    required int categoryId,
    required int userId,
  }) async {
    try {
      final body = {
        'user_id': userId.toString(),
      };

      final response = await http
          .delete(
            Uri.parse(ApiConfig.categoryDetail(categoryId)),
            headers: ApiConfig.headers,
            body: body,
          )
          .timeout(ApiConfig.requestTimeout);

      final responseData = jsonDecode(response.body);

      return {
        'success': responseData['success'] ?? false,
        'message': responseData['message'] ?? 'Gagal hapus kategori',
      };
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'message': 'Permintaan timeout',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }
}
