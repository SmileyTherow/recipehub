// services/recipe_service.dart
// services/recipe_service.dart
/**
 * File: services/recipe_service.dart
 * Fungsi: Service untuk handle Recipe API calls dengan multipart image upload
 */

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import '../models/recipe.dart';

class RecipeService {
  // ============================================================
  // GET ALL RECIPES
  // ============================================================
  /**
   * Method: getRecipes()
   * Fungsi: Ambil semua resep user
   * Parameter: userId (int)
   * Return: List<Recipe>
   */
  static Future<Map<String, dynamic>> getRecipes({
    required int userId,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.recipes}?user_id=$userId');

      final response = await http
          .get(
            url,
            headers: ApiConfig.headers,
          )
          .timeout(ApiConfig.requestTimeout);

      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        final List<dynamic> recipeList = responseData['data'] ?? [];
        final recipes =
            recipeList.map((json) => Recipe.fromJson(json)).toList();

        return {
          'success': true,
          'message': responseData['message'] ?? 'Data loaded',
          'recipes': recipes,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal load resep',
          'recipes': <Recipe>[],
        };
      }
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'message': 'Permintaan timeout',
        'recipes': <Recipe>[],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
        'recipes': <Recipe>[],
      };
    }
  }

  // ============================================================
  // GET RECIPE DETAIL
  // ============================================================
  /**
   * Method: getRecipeDetail()
   * Fungsi: Ambil detail satu resep
   * Parameter: recipeId, userId
   * Return: Recipe object
   */
  static Future<Map<String, dynamic>> getRecipeDetail({
    required int recipeId,
    required int userId,
  }) async {
    try {
      final url = Uri.parse(
          '${ApiConfig.recipeDetail(recipeId)}?user_id=$userId');

      final response = await http
          .get(
            url,
            headers: ApiConfig.headers,
          )
          .timeout(ApiConfig.requestTimeout);

      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true && responseData['data'] != null) {
        final recipe = Recipe.fromJson(responseData['data']);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Data loaded',
          'recipe': recipe,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal load detail resep',
        };
      }
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

  // ============================================================
  // ADD RECIPE WITH IMAGE (MULTIPART)
  // ============================================================
  /**
   * Method: addRecipe()
   * Fungsi: Tambah resep baru dengan multipart image upload
   * Parameter: userId, categoryId, name, ingredients, steps, cookingTime, servings, imageFile
   * Return: success status & recipe_id
   *
   * Note: imageFile sekarang bertipe XFile?:
   * - Web: upload via MultipartFile.fromBytes
   * - Mobile: upload via MultipartFile.fromPath
   */
  static Future<Map<String, dynamic>> addRecipe({
    required int userId,
    required int categoryId,
    required String name,
    required String ingredients,
    required String steps,
    required int cookingTime,
    required int servings,
    String? description,
    XFile? imageFile,
  }) async {
    try {
      // Buat multipart request untuk file upload
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.recipes),
      );

      // Add form fields
      request.fields['user_id'] = userId.toString();
      request.fields['category_id'] = categoryId.toString();
      request.fields['name'] = name;
      request.fields['ingredients'] = ingredients;
      request.fields['steps'] = steps;
      request.fields['cooking_time'] = cookingTime.toString();
      request.fields['servings'] = servings.toString();

      // Add description jika ada
      if (description != null) {
        request.fields['description'] = description;
      }

      // Add image file jika ada
      if (imageFile != null) {
        if (kIsWeb) {
          // Web: read bytes and use fromBytes with filename
          final bytes = await imageFile.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              bytes,
              filename: imageFile.name,
            ),
          );
        } else {
          // Mobile: use fromPath
          request.files.add(
            await http.MultipartFile.fromPath('image', imageFile.path),
          );
        }
      }

      // Send request
      var streamedResponse = await request.send().timeout(
            ApiConfig.uploadTimeout,
          );

      var response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      return {
        'success': responseData['success'] ?? false,
        'message': responseData['message'] ?? 'Gagal tambah resep',
        'recipe_id': responseData['data']?['id'],
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

  // ============================================================
  // EDIT RECIPE WITH IMAGE (MULTIPART)
  // ============================================================
  /**
   * Method: editRecipe()
   * Fungsi: Edit resep dengan multipart image upload
   * Parameter: recipeId, userId, dan field-field yang diupdate
   * Return: success status
   *
   * Note: imageFile sekarang bertipe XFile?:
   * - Web: upload via MultipartFile.fromBytes
   * - Mobile: upload via MultipartFile.fromPath
   */
  static Future<Map<String, dynamic>> editRecipe({
    required int recipeId,
    required int userId,
    String? name,
    int? categoryId,
    String? ingredients,
    String? steps,
    int? cookingTime,
    int? servings,
    String? description,
    XFile? imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.recipeDetail(recipeId)}?_method=PUT'),
      );

      // Add required fields
      request.fields['user_id'] = userId.toString();

      // Add optional fields yang dikirim
      if (name != null) request.fields['name'] = name;
      if (categoryId != null) {
        request.fields['category_id'] = categoryId.toString();
      }
      if (ingredients != null) request.fields['ingredients'] = ingredients;
      if (steps != null) request.fields['steps'] = steps;
      if (cookingTime != null) {
        request.fields['cooking_time'] = cookingTime.toString();
      }
      if (servings != null) request.fields['servings'] = servings.toString();

      // Add description jika ada
      if (description != null) {
        request.fields['description'] = description;
      }

      // Add image file jika ada
      if (imageFile != null) {
        if (kIsWeb) {
          final bytes = await imageFile.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              bytes,
              filename: imageFile.name,
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath('image', imageFile.path),
          );
        }
      }

      var streamedResponse = await request.send().timeout(
            ApiConfig.uploadTimeout,
          );

      var response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      return {
        'success': responseData['success'] ?? false,
        'message': responseData['message'] ?? 'Gagal update resep',
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

  // ============================================================
  // DELETE RECIPE
  // ============================================================
  /**
   * Method: deleteRecipe()
   * Fungsi: Hapus resep
   * Parameter: recipeId, userId
   * Return: success status
   */
  static Future<Map<String, dynamic>> deleteRecipe({
    required int recipeId,
    required int userId,
  }) async {
    try {
      final body = {
        'user_id': userId.toString(),
      };

      final response = await http
          .delete(
            Uri.parse(ApiConfig.recipeDetail(recipeId)),
            headers: ApiConfig.headers,
            body: body,
          )
          .timeout(ApiConfig.requestTimeout);

      final responseData = jsonDecode(response.body);

      return {
        'success': responseData['success'] ?? false,
        'message': responseData['message'] ?? 'Gagal hapus resep',
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

  // ============================================================
  // SEARCH & FILTER RECIPES (LOCAL - di client side)
  // ============================================================
  /**
   * Method: searchRecipes()
   * Fungsi: Search resep berdasarkan nama (client side)
   * Parameter: recipes (list), query (string)
   * Return: List<Recipe> yang match dengan query
   */
  static List<Recipe> searchRecipes({
    required List<Recipe> recipes,
    required String query,
  }) {
    if (query.isEmpty) {
      return recipes;
    }

    final lowerQuery = query.toLowerCase();
    return recipes.where((recipe) {
      return recipe.name.toLowerCase().contains(lowerQuery) ||
          recipe.ingredients.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // ============================================================
  // FILTER BY CATEGORY (LOCAL - di client side)
  // ============================================================
  /**
   * Method: filterByCategory()
   * Fungsi: Filter resep berdasarkan kategori (client side)
   * Parameter: recipes (list), categoryId (int)
   * Return: List<Recipe> yang sesuai kategori
   */
  static List<Recipe> filterByCategory({
    required List<Recipe> recipes,
    required int? categoryId,
  }) {
    if (categoryId == null) {
      return recipes;
    }

    return recipes.where((recipe) {
      return recipe.categoryId == categoryId;
    }).toList();
  }

  // ============================================================
  // COMBINED SEARCH & FILTER
  // ============================================================
  /**
   * Method: searchAndFilter()
   * Fungsi: Search dan filter resep sekaligus (client side)
   * Parameter: recipes (list), query (string), categoryId (int?)
   * Return: List<Recipe> yang sudah di-search dan di-filter
   */
  static List<Recipe> searchAndFilter({
    required List<Recipe> recipes,
    required String query,
    required int? categoryId,
  }) {
    var result = recipes;

    // Terapkan search filter
    result = searchRecipes(recipes: result, query: query);

    // Terapkan category filter
    result = filterByCategory(recipes: result, categoryId: categoryId);

    return result;
  }
}