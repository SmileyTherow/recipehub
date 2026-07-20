// services/dashboard_service.dart
/**
 * File: services/dashboard_service.dart
 * Fungsi: Service untuk handle Dashboard API calls
 */

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../config/api_config.dart';
import '../models/recipe.dart';

class DashboardService {
  // ============================================================
  // GET DASHBOARD DATA
  // ============================================================
  /**
   * Method: getDashboard()
   * Fungsi: Ambil data dashboard (total resep, total kategori, resep terbaru)
   * Parameter: userId
   * Return: Map dengan dashboard data
   */
  static Future<Map<String, dynamic>> getDashboard({
    required int userId,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.dashboard}?user_id=$userId');

      final response = await http
          .get(
            url,
            headers: ApiConfig.headers,
          )
          .timeout(ApiConfig.requestTimeout);

      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true && responseData['data'] != null) {
        final data = responseData['data'];

        // Parse latest recipes dari response
        final List<dynamic> recipeList = data['latest_recipes'] ?? [];
        final latestRecipes =
            recipeList.map((json) => Recipe.fromJson(json)).toList();

        return {
          'success': true,
          'message': responseData['message'] ?? 'Data loaded',
          'total_recipes': data['total_recipes'] ?? 0,
          'total_categories': data['total_categories'] ?? 0,
          'latest_recipes': latestRecipes,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal load dashboard',
          'total_recipes': 0,
          'total_categories': 0,
          'latest_recipes': <Recipe>[],
        };
      }
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'message': 'Permintaan timeout',
        'total_recipes': 0,
        'total_categories': 0,
        'latest_recipes': <Recipe>[],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
        'total_recipes': 0,
        'total_categories': 0,
        'latest_recipes': <Recipe>[],
      };
    }
  }
}