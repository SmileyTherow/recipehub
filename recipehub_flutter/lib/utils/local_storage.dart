// utils/local_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  // SINGLETON PATTERN

  static final LocalStorage _instance = LocalStorage._internal();

  factory LocalStorage() {
    return _instance;
  }

  LocalStorage._internal();

  // STORAGE KEYS

  // Keys untuk session/user data
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';
  static const String isLoggedInKey = 'is_logged_in';
  static const String recentRecipesKey = 'recent_recipes';

  // SAVE USER DATA (saat login berhasil)
  Future<bool> saveUserData({
    required int userId,
    required String userName,
    required String userEmail,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Simpan semua data user
      await prefs.setInt(userIdKey, userId);
      await prefs.setString(userNameKey, userName);
      await prefs.setString(userEmailKey, userEmail);
      await prefs.setBool(isLoggedInKey, true);

      return true;
    } catch (e) {
      print('Error saving user data: $e');
      return false;
    }
  }

  // GET USER DATA
  Future<int?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(userIdKey);
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(userNameKey);
    } catch (e) {
      print('Error getting user name: $e');
      return null;
    }
  }

  Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(userEmailKey);
    } catch (e) {
      print('Error getting user email: $e');
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(isLoggedInKey) ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // GET ALL USER DATA (dalam satu method)
  Future<Map<String, dynamic>> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'user_id': prefs.getInt(userIdKey),
        'user_name': prefs.getString(userNameKey),
        'user_email': prefs.getString(userEmailKey),
      };
    } catch (e) {
      print('Error getting user data: $e');
      return {};
    }
  }

  // SAVE RECENT RECIPE

  Future<void> saveRecentRecipe(int recipeId) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> recent = prefs.getStringList(recentRecipesKey) ?? [];

    // hapus jika sudah ada
    recent.remove(recipeId.toString());

    // masukkan ke paling depan
    recent.insert(0, recipeId.toString());

    // maksimal 5 data
    if (recent.length > 5) {
      recent = recent.sublist(0, 5);
    }

    await prefs.setStringList(recentRecipesKey, recent);
  }

  // GET RECENT RECIPES

  Future<List<int>> getRecentRecipes() async {
    final prefs = await SharedPreferences.getInstance();

    final recent = prefs.getStringList(recentRecipesKey) ?? [];

    return recent.map(int.parse).toList();
  }

  // CLEAR RECENT RECIPES

  Future<void> clearRecentRecipes() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(recentRecipesKey);
  }

  // LOGOUT (hapus semua user data)
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Hapus semua user-related keys
      await prefs.remove(userIdKey);
      await prefs.remove(userNameKey);
      await prefs.remove(userEmailKey);
      await prefs.remove(isLoggedInKey);

      return true;
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }

  // CLEAR ALL DATA (optional)
  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return true;
    } catch (e) {
      print('Error clearing all data: $e');
      return false;
    }
  }
}
