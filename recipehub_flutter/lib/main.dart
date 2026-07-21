// main.dart
import 'package:flutter/material.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/recipes/recipe_list_screen.dart';
import 'screens/recipes/recipe_detail_screen.dart';
import 'screens/recipes/recipe_form_screen.dart';
import 'screens/categories/category_list_screen.dart';
import 'screens/categories/category_form_screen.dart';
import 'utils/constants.dart';
import 'models/recipe.dart';
import 'models/category.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // THEME CONFIGURATION

      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Color(AppColors.primaryColor),
        scaffoldBackgroundColor: Color(AppColors.backgroundColor),

        // AppBar Theme
        appBarTheme: AppBarTheme(
          backgroundColor: Color(AppColors.primaryColor),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),

        // Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(AppColors.primaryColor),
            foregroundColor: Colors.white,
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),

        // Outlined Button Theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Color(AppColors.primaryColor),
            side: BorderSide(color: Color(AppColors.primaryColor)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),

        // Text Button Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(AppColors.primaryColor),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          ),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Color(AppColors.borderColor),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Color(AppColors.borderColor),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Color(AppColors.primaryColor),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Color(AppColors.errorColor),
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Color(AppColors.errorColor),
              width: 2,
            ),
          ),
          labelStyle: TextStyle(
            color: Color(AppColors.textSecondary),
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Color(AppColors.textSecondary),
          ),
          errorStyle: TextStyle(
            color: Color(AppColors.errorColor),
            fontSize: 12,
          ),
        ),

        // Text Theme
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.textPrimary),
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.textPrimary),
          ),
          displaySmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.textPrimary),
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.textPrimary),
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.textPrimary),
          ),
          bodyLarge: TextStyle(
            fontSize: 15,
            color: Color(AppColors.textPrimary),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(AppColors.textPrimary),
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: Color(AppColors.textSecondary),
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            color: Color(AppColors.textSecondary),
          ),
        ),

        // FloatingActionButton Theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(AppColors.primaryColor),
          foregroundColor: Colors.white,
          elevation: 4,
          highlightElevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // SnackBar Theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Color(AppColors.textPrimary),
          contentTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          behavior: SnackBarBehavior.floating,
        ),

        // Dialog Theme
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.textPrimary),
          ),
          contentTextStyle: TextStyle(
            fontSize: 14,
            color: Color(AppColors.textPrimary),
          ),
        ),

        // Bottom Navigation Bar Theme
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(AppColors.primaryColor),
          unselectedItemColor: Color(AppColors.textSecondary),
          elevation: 8,
        ),
      ),

      // NAVIGATION ROUTES

      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/recipes': (context) => const RecipeListScreen(),
        '/recipes/add': (context) => const RecipeFormScreen(),
        '/categories': (context) => const CategoryListScreen(),
        '/categories/add': (context) => const CategoryFormScreen(),
      },

      // DYNAMIC ROUTE GENERATION

      onGenerateRoute: (settings) {
        try {
          // Recipe Detail Route
          if (settings.name == '/recipes/detail') {
            final recipeId = settings.arguments as int?;
            if (recipeId == null) {
              return MaterialPageRoute(
                builder: (context) => ErrorScreen(
                  error: 'ID Resep tidak ditemukan',
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipeId: recipeId),
              settings: settings,
            );
          }

          // Recipe Edit Route
          if (settings.name == '/recipes/edit') {
            final recipe = settings.arguments as Recipe?;
            if (recipe == null) {
              return MaterialPageRoute(
                builder: (context) => ErrorScreen(
                  error: 'Data Resep tidak ditemukan',
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => RecipeFormScreen(recipe: recipe),
              settings: settings,
            );
          }

          // Category Edit Route
          if (settings.name == '/categories/edit') {
            final category = settings.arguments as Category?;
            if (category == null) {
              return MaterialPageRoute(
                builder: (context) => ErrorScreen(
                  error: 'Data Kategori tidak ditemukan',
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => CategoryFormScreen(category: category),
              settings: settings,
            );
          }

          // Unknown route
          return MaterialPageRoute(
            builder: (context) => ErrorScreen(
              error: 'Route tidak ditemukan: ${settings.name}',
            ),
          );
        } catch (e) {
          return MaterialPageRoute(
            builder: (context) => ErrorScreen(
              error: 'Error saat membuka halaman: ${e.toString()}',
            ),
          );
        }
      },
    );
  }
}

// ERROR SCREEN WIDGET

class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({
    Key? key,
    required this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Error'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Color(AppColors.errorColor),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Color(AppColors.errorColor),
                    ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
