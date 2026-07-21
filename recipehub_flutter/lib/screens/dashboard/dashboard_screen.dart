// screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../services/dashboard_service.dart';
import '../../services/recipe_service.dart';
import '../../utils/local_storage.dart';
import '../../utils/constants.dart';
import '../../models/recipe.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // STATE VARIABLES
  int? _userId;
  String? _userName;
  bool _isLoading = true;
  int _totalRecipes = 0;
  int _totalCategories = 0;
  List<Recipe> _latestRecipes = [];
  int _currentNavIndex = 0; // Untuk bottom navigation

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // LOAD DASHBOARD DATA
  Future<void> _loadDashboardData() async {
    try {
      final localStorage = LocalStorage();

      // Ambil user data dari local storage
      final userId = await localStorage.getUserId();
      final userName = await localStorage.getUserName();

      if (userId == null) {
        // User tidak valid, logout
        _logout();
        return;
      }

      setState(() {
        _userId = userId;
        _userName = userName;
      });

      // Load dashboard data dari API
      final response = await DashboardService.getDashboard(userId: userId);

      if (response['success'] == true) {
        setState(() {
          _totalRecipes = response['total_recipes'] ?? 0;
          _totalCategories = response['total_categories'] ?? 0;
          _latestRecipes = response['latest_recipes'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Gagal load dashboard'),
            backgroundColor: Color(AppColors.errorColor),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Color(AppColors.errorColor),
        ),
      );
    }
  }

  // HANDLE LOGOUT
  Future<void> _logout() async {
    final localStorage = LocalStorage();
    await localStorage.logout();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  // LOGOUT CONFIRMATION
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text(
          "Apakah Anda yakin ingin keluar dari aplikasi?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  // HANDLE NAVIGATION
  void _handleNavigation(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    switch (index) {
      case 0:
        // Home (stay in dashboard)
        break;
      case 1:
        // Recipes
        Navigator.of(context).pushNamed('/recipes');
        break;
      case 2:
        // Categories
        Navigator.of(context).pushNamed('/categories');
        break;
      case 3:
      _showLogoutDialog();
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.backgroundColor),
      appBar: AppBar(
        backgroundColor: Color(AppColors.primaryColor),
        title: Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(AppColors.primaryColor),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GREETING
                    Text(
                      'Halo, $_userName! 👋',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.textPrimary),
                          ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Selamat datang di RecipeHub',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Color(AppColors.textSecondary),
                          ),
                    ),

                    SizedBox(height: 24),

                    // STATISTICS CARDS
                    Row(
                      children: [
                        // Total Recipes Card
                        Expanded(
                          child: _StatisticCard(
                            title: 'Total Resep',
                            value: _totalRecipes.toString(),
                            icon: Icons.restaurant_menu_rounded,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(width: 16),
                        // Total Categories Card
                        Expanded(
                          child: _StatisticCard(
                            title: 'Total Kategori',
                            value: _totalCategories.toString(),
                            icon: Icons.category_rounded,
                            color: AppColors.secondaryColor,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32),

                    // LATEST RECIPES SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Resep Terbaru',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Color(AppColors.textPrimary),
                              ),
                        ),
                        if (_latestRecipes.length > 5)
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed('/recipes');
                            },
                            child: Text(
                              AppConstants.btnViewAll,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Color(AppColors.primaryColor),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Latest Recipes List
                    if (_latestRecipes.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.restaurant_outlined,
                                size: 60,
                                color: Color(AppColors.borderColor),
                              ),
                              SizedBox(height: 12),
                              Text(
                                AppConstants.emptyRecipes,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Color(AppColors.textSecondary),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _latestRecipes.length > 5
                            ? 5
                            : _latestRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _latestRecipes[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                '/recipes/detail',
                                arguments: recipe.id,
                              );

                              if (result == true) {
                                _loadDashboardData();
                              }
                            },
                            child: _RecipeListItem(recipe: recipe),
                          );
                        },
                      ),

                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavigation,
        backgroundColor: Colors.white,
        selectedItemColor: Color(AppColors.primaryColor),
        unselectedItemColor: Color(AppColors.textSecondary),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: AppConstants.navHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu_rounded),
            label: AppConstants.navRecipes,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category_rounded),
            label: AppConstants.navCategories,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout_rounded),
            label: 'Logout',
          ),
        ],
      ),
    );
  }
}

// STATISTIC CARD WIDGET
class _StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final int color;

  const _StatisticCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(color).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Color(color),
            size: 32,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Color(color),
                ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Color(AppColors.textSecondary),
                ),
          ),
        ],
      ),
    );
  }
}

// RECIPE LIST ITEM WIDGET
class _RecipeListItem extends StatelessWidget {
  final Recipe recipe;

  const _RecipeListItem({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(AppColors.cardColor),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Recipe Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(AppColors.backgroundColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: recipe.image != null && recipe.image!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      recipe.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.restaurant_menu_rounded,
                          color: Color(AppColors.primaryColor),
                        );
                      },
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;

                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.restaurant_menu_rounded,
                    color: Color(AppColors.primaryColor),
                  ),
          ),
          SizedBox(width: 12),
          // Recipe Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 4),
                Text(
                  '${recipe.cookingTime} menit • ${recipe.servings} porsi',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Color(AppColors.textSecondary),
                      ),
                ),
              ],
            ),
          ),
          // Arrow Icon
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}