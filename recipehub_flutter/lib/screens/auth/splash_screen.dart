// screens/auth/splash_screen.dart
/**
 * File: screens/auth/splash_screen.dart
 * Fungsi: Splash Screen - menampilkan saat app pertama kali dibuka
 * 
 * Alur:
 * 1. App terbuka, tampilkan Splash Screen selama 3 detik
 * 2. Selama itu, cek apakah user sudah login (check local storage)
 * 3. Jika sudah login → navigasi ke Dashboard
 * 4. Jika belum login → navigasi ke Login Screen
 */

import 'package:flutter/material.dart';
import '../../utils/local_storage.dart';
import '../../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // ============================================================
  // CEK LOGIN STATUS
  // ============================================================
  /**
   * Method: _checkLoginStatus()
   * Fungsi: 
   * 1. Wait 3 detik (splash duration)
   * 2. Cek apakah user sudah login (check local storage)
   * 3. Navigate ke Dashboard atau Login berdasarkan status login
   */
  Future<void> _checkLoginStatus() async {
    // Wait 3 detik
    await Future.delayed(
      Duration(seconds: AppConstants.splashDuration),
    );

    // Cek login status dari local storage
    final localStorage = LocalStorage();
    final isLoggedIn = await localStorage.isLoggedIn();

    // Navigate berdasarkan status login
    if (mounted) {
      if (isLoggedIn) {
        // User sudah login → ke Dashboard
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        // User belum login → ke Login
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.backgroundColor),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ============================================================
            // APP LOGO/ICON
            // ============================================================
            // Bisa menggunakan Image.asset atau Icon
            Icon(
              Icons.restaurant_menu_rounded,
              size: 80,
              color: Color(AppColors.primaryColor),
            ),

            SizedBox(height: 20),

            // ============================================================
            // APP NAME
            // ============================================================
            Text(
              AppConstants.appName,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Color(AppColors.primaryColor),
                    fontWeight: FontWeight.bold,
                  ),
            ),

            SizedBox(height: 30),

            // ============================================================
            // LOADING INDICATOR
            // ============================================================
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(AppColors.primaryColor),
                ),
                strokeWidth: 3,
              ),
            ),

            SizedBox(height: 20),

            // ============================================================
            // LOADING TEXT
            // ============================================================
            Text(
              'Memuat...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Color(AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}