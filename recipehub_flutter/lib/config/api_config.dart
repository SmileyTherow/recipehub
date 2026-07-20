// config/api_config.dart
/**
 * File: config/api_config.dart
 * Fungsi: Konfigurasi API endpoint dan base URL
 *
 * Penjelasan:
 * - Semua endpoint API backend didefinisikan di sini
 * - Base URL dapat diubah untuk development/production
 * - Digunakan oleh service classes untuk membuat request
 */

class ApiConfig {
  // ============================================================
  // BASE URL
  // ============================================================
  // Ganti dengan IP/domain server Anda untuk production
  static const String baseUrl = 'http://192.168.100.9/recipehub-backend/index.php';

  // ============================================================
  // AUTH ENDPOINTS
  // ============================================================
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';

  // ============================================================
  // DASHBOARD ENDPOINTS
  // ============================================================
  static const String dashboard = '$baseUrl/dashboard';

  // ============================================================
  // RECIPE ENDPOINTS
  // ============================================================
  static const String recipes = '$baseUrl/recipes';
  
  // Untuk GET detail resep: recipes/{id}
  // Untuk PUT edit resep: recipes/{id}
  // Untuk DELETE resep: recipes/{id}
  static String recipeDetail(int recipeId) => '$baseUrl/recipes/$recipeId';

  // ============================================================
  // CATEGORY ENDPOINTS
  // ============================================================
  static const String categories = '$baseUrl/categories';
  
  // Untuk PUT edit kategori: categories/{id}
  // Untuk DELETE kategori: categories/{id}
  static String categoryDetail(int categoryId) => '$baseUrl/categories/$categoryId';

  // ============================================================
  // UPLOAD ENDPOINTS
  // ============================================================
  // Foto resep disimpan di: uploads/recipes/{filename}
  static const String uploadDir =
    'http://192.168.100.9/recipehub-backend/uploads/recipes';
  static String recipeImageUrl(String filename) => '$uploadDir/$filename';

  // ============================================================
  // HTTP HEADERS
  // ============================================================
  // Headers default untuk semua request
  static const Map<String, String> headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  // Headers untuk multipart/form-data (file upload)
  static const Map<String, String> multipartHeaders = {
    'Accept': 'application/json',
  };

  // ============================================================
  // TIMEOUT CONFIGURATION
  // ============================================================
  // Timeout untuk API request (dalam detik)
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // Timeout untuk file upload (dalam detik)
  static const Duration uploadTimeout = Duration(seconds: 60);
}
