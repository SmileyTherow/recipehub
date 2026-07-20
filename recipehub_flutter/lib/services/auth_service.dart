// services/auth_service.dart
/**
 * File: services/auth_service.dart
 * Fungsi: Service untuk handle authentication API calls
 * 
 * Alur:
 * 1. Flutter kirim email & password ke AuthService
 * 2. AuthService buat HTTP request ke backend
 * 3. Backend verify, kirim response (success atau error)
 * 4. AuthService parse response & return ke Flutter
 * 5. Flutter handle response (simpan session atau tampilkan error)
 */

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../config/api_config.dart';
import '../models/user.dart';

class AuthService {
  // ============================================================
  // REGISTER - Daftar user baru
  // ============================================================
  /**
   * Method: register()
   * Fungsi: Register user baru ke backend
   * Parameter:
   *   - name: Nama user
   *   - email: Email user
   *   - password: Password user
   * Return: Map dengan keys: success (bool), message (string), data (jika ada)
   * 
   * Contoh return:
   * {
   *   "success": true,
   *   "message": "Registrasi berhasil. Silakan login"
   * }
   */
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

  // ============================================================
  // LOGIN - Autentikasi user
  // ============================================================
  /**
   * Method: login()
   * Fungsi: Login user dengan email & password
   * Parameter:
   *   - email: Email user
   *   - password: Password user
   * Return: Map dengan keys: success (bool), message (string), user (User object)
   * 
   * Contoh return jika sukses:
   * {
   *   "success": true,
   *   "message": "Login berhasil",
   *   "user": User(id: 1, name: "Sarah", email: "sarah@email.com")
   * }
   */
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