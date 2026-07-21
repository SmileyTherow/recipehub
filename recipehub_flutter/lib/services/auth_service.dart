// services/auth_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../config/api_config.dart';
import '../models/user.dart';

class AuthService {
  // REGISTER - Daftar user baru
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Siapkan body request
      final body = {
        'name': name,
        'email': email,
        'password': password,
      };

      // 2. Kirim POST request ke backend
      final response = await http
          .post(
            Uri.parse(ApiConfig.register),
            headers: ApiConfig.headers,
            body: body,
          )
          .timeout(ApiConfig.requestTimeout);

      // 3. Parse response
      final responseData = jsonDecode(response.body);

      // 4. Return response
      return {
        'success': responseData['success'] ?? false,
        'message': responseData['message'] ?? 'Terjadi kesalahan',
        'data': responseData['data'],
      };
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'message': 'Permintaan timeout. Silakan coba lagi.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // LOGIN - Autentikasi user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Siapkan body request
      final body = {
        'email': email,
        'password': password,
      };

      // 2. Kirim POST request ke backend
      final response = await http
          .post(
            Uri.parse(ApiConfig.login),
            headers: ApiConfig.headers,
            body: body,
          )
          .timeout(ApiConfig.requestTimeout);

      // 3. Parse response
      final responseData = jsonDecode(response.body);

      // 4. Jika login berhasil, convert data user ke User object
      if (responseData['success'] == true && responseData['data'] != null) {
        final user = User.fromJson(responseData['data']);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Login berhasil',
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login gagal',
        };
      }
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'message': 'Permintaan timeout. Silakan coba lagi.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }
}
