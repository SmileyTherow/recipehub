// config/api_config.dart
class ApiConfig {
  // BASE URL
  static const String baseUrl = 'http://192.168.100.9/recipehub-backend/index.php';

  // AUTH ENDPOINTS
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';

  // ASHBOARD ENDPOINTS
  static const String dashboard = '$baseUrl/dashboard';

  // RECIPE ENDPOINTS
  static const String recipes = '$baseUrl/recipes';
  
  static String recipeDetail(int recipeId) => '$baseUrl/recipes/$recipeId';

  // CATEGORY ENDPOINTS
  static const String categories = '$baseUrl/categories';
  
  static String categoryDetail(int categoryId) => '$baseUrl/categories/$categoryId';

  // UPLOAD ENDPOINTS
  static const String uploadDir =
    'http://192.168.100.9/recipehub-backend/uploads/recipes';
  static String recipeImageUrl(String filename) => '$uploadDir/$filename';

  // HTTP HEADERS
  static const Map<String, String> headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  // Headers untuk multipart/form-data (file upload)
  static const Map<String, String> multipartHeaders = {
    'Accept': 'application/json',
  };

  // TIMEOUT CONFIGURATION
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // Timeout untuk file upload (dalam detik)
  static const Duration uploadTimeout = Duration(seconds: 60);
}
