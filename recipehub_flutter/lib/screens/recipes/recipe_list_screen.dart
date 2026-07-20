// screens/recipes/recipe_list_screen.dart
/**
 * File: screens/recipes/recipe_list_screen.dart
 * Fungsi: Menampilkan daftar semua resep user dengan fitur search & filter
 * 
 * TASK 5 Improvements:
 * ✅ Add Recipe navigation bekerja sempurna
 * ✅ Refresh otomatis setelah Add/Edit/Delete
 * ✅ Better error handling
 * ✅ SnackBar untuk feedback
 * ✅ Loading states
 */

import 'package:flutter/material.dart';
import '../../services/recipe_service.dart';
import '../../services/category_service.dart';
import '../../models/recipe.dart';
import '../../models/category.dart';
import '../../utils/local_storage.dart';
import '../../utils/constants.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({Key? key}) : super(key: key);

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  // ============================================================
  // STATE VARIABLES
  // ============================================================
  int? _userId;
  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];
  List<Category> _categories = [];

  bool _isLoading = true;
  bool _isLoadingCategories = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  final _searchController = TextEditingController();
  int? _selectedCategoryId;
  int _currentNavIndex = 1; // Recipes is index 1

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================
  /**
   * Method: _loadData()
   * Fungsi: Load user_id dan ambil data recipes & categories
   */
  Future<void> _loadData() async {
    try {
      final localStorage = LocalStorage();
      final userId = await localStorage.getUserId();

      if (userId == null) {
        _logout();
        return;
      }

      setState(() {
        _userId = userId;
      });

      // Load both recipes and categories in parallel
      await Future.wait([
        _loadRecipes(),
        _loadCategories(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // LOAD RECIPES
  // ============================================================
  /**
   * Method: _loadRecipes()
   * Fungsi: Ambil daftar resep dari backend
   */
  Future<void> _loadRecipes() async {
    try {
      if (_userId == null) return;

      final response = await RecipeService.getRecipes(userId: _userId!);

      if (response['success'] == true) {
        setState(() {
          _allRecipes = response['recipes'] ?? [];
            for (var r in _allRecipes) {
              debugPrint("LIST IMAGE : ${r.image}");
            }
          _errorMessage = null;
        });

        // Terapkan search & filter setelah load
        _applySearchAndFilter();
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Gagal load resep';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  // ============================================================
  // LOAD CATEGORIES
  // ============================================================
  /**
   * Method: _loadCategories()
   * Fungsi: Ambil daftar kategori untuk dropdown filter
   */
  Future<void> _loadCategories() async {
    try {
      if (_userId == null) return;

      final response = await CategoryService.getCategories(userId: _userId!);

      if (response['success'] == true) {
        setState(() {
          _categories = response['categories'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  // ============================================================
  // APPLY SEARCH & FILTER
  // ============================================================
  /**
   * Method: _applySearchAndFilter()
   * Fungsi: Terapkan search dan filter ke resep
   */
  void _applySearchAndFilter() {
    final query = _searchController.text;
    final categoryId = _selectedCategoryId;

    setState(() {
      _filteredRecipes = RecipeService.searchAndFilter(
        recipes: _allRecipes,
        query: query,
        categoryId: categoryId,
      );
    });
  }

  // ============================================================
  // HANDLE SEARCH INPUT
  // ============================================================
  /**
   * Method: _onSearchChanged()
   * Fungsi: Dipanggil saat user mengetik di search box
   */
  void _onSearchChanged(String value) {
    _applySearchAndFilter();
  }

  // ============================================================
  // HANDLE CATEGORY FILTER
  // ============================================================
  /**
   * Method: _onCategoryChanged()
   * Fungsi: Dipanggil saat user mengubah kategori filter
   */
  void _onCategoryChanged(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _applySearchAndFilter();
  }

  // ============================================================
  // CLEAR SEARCH
  // ============================================================
  /**
   * Method: _clearSearch()
   * Fungsi: Hapus text di search box
   */
  void _clearSearch() {
    _searchController.clear();
    _applySearchAndFilter();
  }

  // ============================================================
  // CLEAR ALL FILTERS
  // ============================================================
  /**
   * Method: _clearAllFilters()
   * Fungsi: Reset search dan kategori filter
   */
  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategoryId = null;
    });
    _applySearchAndFilter();
  }

  // ============================================================
  // ADD RECIPE NAVIGATION
  // ============================================================
  /**
   * Method: _handleAddRecipe()
   * Fungsi: Navigate ke add recipe form
   */
  Future<void> _handleAddRecipe() async {
    try {
      final result = await Navigator.pushNamed(context, '/recipes/add');

      // Jika recipe berhasil ditambahkan, reload list
      if (result == true && mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
        await _loadRecipes();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resep berhasil ditambahkan!'),
            backgroundColor: Color(AppColors.successColor),
            duration: AppConstants.snackBarDuration,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error navigasi: ${e.toString()}'),
            backgroundColor: Color(AppColors.errorColor),
            duration: AppConstants.snackBarDuration,
          ),
        );
      }
    }
  }

  // ============================================================
  // HANDLE NAVIGATION
  // ============================================================
  /**
   * Method: _handleNavigation()
   * Fungsi: Handle bottom navigation bar tap
   */
  void _handleNavigation(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    switch (index) {
      case 0:
        // Home (Dashboard)
        Navigator.of(context).pushReplacementNamed('/dashboard');
        break;
      case 1:
        // Recipes (stay in recipes)
        break;
      case 2:
        // Categories
        Navigator.of(context).pushReplacementNamed('/categories');
        break;
      case 3:
        // Logout
        _logout();
        break;
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================
  /**
   * Method: _logout()
   * Fungsi: Logout user
   */
  Future<void> _logout() async {
    final localStorage = LocalStorage();
    await localStorage.logout();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.backgroundColor),
      appBar: AppBar(
        backgroundColor: Color(AppColors.primaryColor),
        title: Text(
          'Daftar Resep',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _isRefreshing = true;
                    });
                    await _loadRecipes();
                  },
                  color: Color(AppColors.primaryColor),
                  child: Column(
                    children: [
                      // ============================================================
                      // SEARCH BAR
                      // ============================================================
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Cari resep atau bahan...',
                            prefixIcon: Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: _clearSearch,
                                  )
                                : null,
                          ),
                        ),
                      ),

                      // ============================================================
                      // CATEGORY FILTER DROPDOWN
                      // ============================================================
                      if (_categories.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color(AppColors.borderColor),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButton<int?>(
                                    isExpanded: true,
                                    value: _selectedCategoryId,
                                    underline: SizedBox(),
                                    hint: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 12),
                                      child: Text('Filter Kategori'),
                                    ),
                                    items: [
                                      DropdownMenuItem<int?>(
                                        value: null,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Text('Semua Kategori'),
                                        ),
                                      ),
                                      ..._categories.map((category) {
                                        return DropdownMenuItem<int?>(
                                          value: category.id,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12),
                                            child: Text(category.name),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: _onCategoryChanged,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              // Clear filters button
                              if (_searchController.text.isNotEmpty ||
                                  _selectedCategoryId != null)
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color(AppColors.errorColor),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: Color(AppColors.errorColor),
                                    ),
                                    onPressed: _clearAllFilters,
                                    tooltip: 'Hapus Filter',
                                  ),
                                ),
                            ],
                          ),
                        ),

                      SizedBox(height: 16),

                      // ============================================================
                      // FILTER STATUS INDICATOR
                      // ============================================================
                      if (_searchController.text.isNotEmpty ||
                          _selectedCategoryId != null)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Color(AppColors.primaryColor)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.filter_list,
                                  size: 18,
                                  color: Color(AppColors.primaryColor),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Menampilkan ${_filteredRecipes.length} dari ${_allRecipes.length} resep',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Color(AppColors.primaryColor),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(height: 12),

                      // ============================================================
                      // RECIPE LIST
                      // ============================================================
                      Expanded(
                        child: _filteredRecipes.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredRecipes.length,
                                itemBuilder: (context, index) {
                                  final recipe = _filteredRecipes[index];
                                  return GestureDetector(
                                    onTap: () async {
                                      try {
                                        final result = await Navigator.pushNamed(
                                          context,
                                          '/recipes/detail',
                                          arguments: recipe.id,
                                        );

                                        // Reload jika recipe dihapus dari detail screen
                                        if (result == true && mounted) {
                                          setState(() {
                                            _isLoading = true;
                                            _errorMessage = null;
                                          });
                                          await _loadRecipes();
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Error membuka detail: ${e.toString()}'),
                                              backgroundColor:
                                                  Color(AppColors.errorColor),
                                              duration: AppConstants
                                                  .snackBarDuration,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: _RecipeCard(recipe: recipe),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(AppColors.primaryColor),
        onPressed: _handleAddRecipe,
        tooltip: 'Tambah Resep',
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavigation,
        backgroundColor: Colors.white,
        selectedItemColor: Color(AppColors.primaryColor),
        unselectedItemColor: Color(AppColors.textSecondary),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
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

  // ============================================================
  // LOADING STATE
  // ============================================================
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(AppColors.primaryColor),
            ),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Memuat resep...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Color(AppColors.textSecondary),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================
  Widget _buildEmptyState() {
    final hasActiveFilters =
        _searchController.text.isNotEmpty || _selectedCategoryId != null;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasActiveFilters
                  ? Icons.search_off_rounded
                  : Icons.restaurant_outlined,
              size: 80,
              color: Color(AppColors.borderColor),
            ),
            SizedBox(height: 16),
            Text(
              hasActiveFilters
                  ? 'Tidak ada hasil pencarian'
                  : 'Belum ada resep',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Color(AppColors.textPrimary),
                  ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                hasActiveFilters
                    ? 'Coba ubah kata kunci atau kategori filter'
                    : 'Mulai buat resep Anda sekarang!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Color(AppColors.textSecondary),
                    ),
              ),
            ),
            if (hasActiveFilters)
              Padding(
                padding: EdgeInsets.only(top: 24),
                child: ElevatedButton.icon(
                  onPressed: _clearAllFilters,
                  icon: Icon(Icons.refresh),
                  label: Text('Reset Filter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppColors.primaryColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================
  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
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
                _errorMessage ?? 'Terjadi kesalahan',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Color(AppColors.errorColor),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadData();
              },
              icon: Icon(Icons.refresh),
              label: Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppColors.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// RECIPE CARD WIDGET
// ============================================================
class _RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const _RecipeCard({required this.recipe});

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
            width: 80,
            height: 80,
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
                  maxLines: 2,
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