// screens/recipes/recipe_detail_screen.dart
import 'package:flutter/material.dart';
import '../../services/recipe_service.dart';
import '../../services/category_service.dart';
import '../../models/recipe.dart';
import '../../models/category.dart';
import '../../utils/local_storage.dart';
import '../../utils/constants.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  const RecipeDetailScreen({
    Key? key,
    required this.recipeId,
  }) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  // STATE VARIABLES
  int? _userId;
  Recipe? _recipe;
  Category? _category;
  bool _isLoading = true;
  bool _isLoadingCategory = true;
  bool _isDeleting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // LOAD DATA
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

      await _loadRecipeDetail();
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // LOAD RECIPE DETAIL
  Future<void> _loadRecipeDetail() async {
    try {
      if (_userId == null) return;

      final response = await RecipeService.getRecipeDetail(
        recipeId: widget.recipeId,
        userId: _userId!,
      );

      if (response['success'] == true && response['recipe'] != null) {
        final recipe = response['recipe'];
        setState(() {
          _recipe = recipe;
          _errorMessage = null;
        });
        await LocalStorage().saveRecentRecipe(recipe.id);
        print("=================================");
        print("IMAGE DARI MODEL : ${recipe.image}");
        print("=================================");

        // Load category untuk mendapatkan nama kategori
        await _loadCategory(recipe.categoryId);
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Resep tidak ditemukan';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // LOAD CATEGORY
  Future<void> _loadCategory(int categoryId) async {
    try {
      if (_userId == null) return;

      final response = await CategoryService.getCategories(userId: _userId!);

      if (response['success'] == true && response['categories'] != null) {
        final categories = response['categories'] as List;

        Category? category;

        try {
          category = categories.firstWhere(
            (cat) => cat.id == categoryId,
          );
        } catch (_) {
          category = null;
        }

        if (category != null) {
          setState(() {
            _category = category;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading category: $e');
    } finally {
      setState(() {
        _isLoadingCategory = false;
      });
    }
  }

  // HANDLE EDIT
  Future<void> _handleEdit() async {
    if (_recipe == null) return;

    try {
      final result = await Navigator.pushNamed(
        context,
        '/recipes/edit',
        arguments: _recipe,
      );

      // Reload data setelah edit jika user mengganti data
      if (result == true && mounted) {
        setState(() {
          _isLoading = true;
          _isLoadingCategory = true;
          _errorMessage = null;
          _recipe = null;
          _category = null;
        });
        await _loadData();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resep berhasil diperbarui!'),
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

  // HANDLE DELETE
  void _handleDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Resep',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda yakin ingin menghapus resep ini?'),
            SizedBox(height: 8),
            Text(
              _recipe?.name ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Color(AppColors.primaryColor),
                  ),
            ),
            SizedBox(height: 12),
            Text(
              'Tindakan ini tidak dapat dibatalkan.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Color(AppColors.errorColor),
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: Color(AppColors.textSecondary)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRecipe();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppColors.errorColor),
            ),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // DELETE RECIPE
  Future<void> _deleteRecipe() async {
    try {
      if (_userId == null || _recipe == null) return;

      setState(() {
        _isDeleting = true;
      });

      final response = await RecipeService.deleteRecipe(
        recipeId: _recipe!.id,
        userId: _userId!,
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppConstants.successRecipeDeleted),
              backgroundColor: Color(AppColors.successColor),
              duration: AppConstants.snackBarDuration,
            ),
          );
          // Pop back ke recipe list dengan return true untuk refresh
          Future.delayed(Duration(milliseconds: 300), () {
            if (mounted) {
              Navigator.pop(context, true);
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isDeleting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Gagal hapus resep'),
              backgroundColor: Color(AppColors.errorColor),
              duration: AppConstants.snackBarDuration,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Color(AppColors.errorColor),
            duration: AppConstants.snackBarDuration,
          ),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Color(AppColors.backgroundColor),
        appBar: AppBar(
          backgroundColor: Color(AppColors.primaryColor),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Kembali',
          ),
          title: Text(
            'Detail Resep',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            if (!_isLoading && _recipe != null && !_isDeleting)
              IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: _handleEdit,
                tooltip: 'Edit Resep',
              ),
          ],
        ),
        body: _isLoading
            ? _buildLoadingState()
            : _errorMessage != null
                ? _buildErrorState()
                : _recipe == null
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadRecipeDetail,
                        color: Color(AppColors.primaryColor),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // RECIPE IMAGE
                              Container(
                                width: double.infinity,
                                height: 250,
                                decoration: BoxDecoration(
                                  color: Color(AppColors.backgroundColor),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _recipe!.image != null &&
                                        _recipe!.image!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          _recipe!.image!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            print("ERROR IMAGE : $error");
                                            print("URL : ${_recipe!.image}");
                                            return Container(
                                              color: Color(
                                                  AppColors.backgroundColor),
                                              child: Icon(
                                                Icons.restaurant_menu_rounded,
                                                size: 100,
                                                color: Color(
                                                    AppColors.primaryColor),
                                              ),
                                            );
                                          },
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Color(AppColors.primaryColor),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Container(
                                        color: Color(AppColors.backgroundColor),
                                        child: Center(
                                          child: Icon(
                                            Icons.restaurant_menu_rounded,
                                            size: 100,
                                            color:
                                                Color(AppColors.primaryColor),
                                          ),
                                        ),
                                      ),
                              ),

                              SizedBox(height: 20),

                              // RECIPE NAME

                              Text(
                                _recipe!.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Color(AppColors.textPrimary),
                                    ),
                              ),

                              SizedBox(height: 8),

                              // CATEGORY NAME

                              if (_category != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(AppColors.primaryColor)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _category!.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Color(AppColors.primaryColor),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                )
                              else if (!_isLoadingCategory)
                                Text(
                                  'Kategori: -',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Color(AppColors.textSecondary),
                                      ),
                                ),

                              SizedBox(height: 20),

                              // COOKING INFO (Time & Servings)

                              Row(
                                children: [
                                  // Cooking Time
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(AppColors.primaryColor)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color:
                                                Color(AppColors.primaryColor),
                                            size: 28,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            '${_recipe!.cookingTime}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  color: Color(
                                                      AppColors.textPrimary),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'menit',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Color(
                                                      AppColors.textSecondary),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  // Servings
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(AppColors.secondaryColor)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.restaurant_menu_rounded,
                                            color:
                                                Color(AppColors.secondaryColor),
                                            size: 28,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            '${_recipe!.servings}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  color: Color(
                                                      AppColors.textPrimary),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'porsi',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Color(
                                                      AppColors.textSecondary),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 32),

                              // DESCRIPTION SECTION
                              if (_recipe!.description != null &&
                                  _recipe!.description!.trim().isNotEmpty) ...[
                                Text(
                                  'Deskripsi',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Color(AppColors.textPrimary),
                                      ),
                                ),
                                SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Color(AppColors.borderColor),
                                    ),
                                  ),
                                  child: Text(
                                    _recipe!.description!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Color(AppColors.textPrimary),
                                          height: 1.8,
                                        ),
                                  ),
                                ),
                                SizedBox(height: 32),
                              ],

                              // INGREDIENTS SECTION
                              Text(
                                'Bahan-Bahan',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Color(AppColors.textPrimary),
                                    ),
                              ),

                              SizedBox(height: 12),

                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Color(AppColors.borderColor),
                                  ),
                                ),
                                child: Text(
                                  _recipe!.ingredients,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Color(AppColors.textPrimary),
                                        height: 1.8,
                                      ),
                                ),
                              ),

                              SizedBox(height: 32),

                              // STEPS SECTION
                              Text(
                                'Langkah-Langkah',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Color(AppColors.textPrimary),
                                    ),
                              ),

                              SizedBox(height: 12),

                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Color(AppColors.borderColor),
                                  ),
                                ),
                                child: Text(
                                  _recipe!.steps,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Color(AppColors.textPrimary),
                                        height: 1.8,
                                      ),
                                ),
                              ),

                              SizedBox(height: 40),

                              // INFO TIMESTAMPS
                              if (_recipe!.createdAt != null ||
                                  _recipe!.updatedAt != null)
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Color(AppColors.backgroundColor),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (_recipe!.createdAt != null)
                                        Text(
                                          'Dibuat: ${_recipe!.createdAt}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Color(
                                                    AppColors.textSecondary),
                                              ),
                                        ),
                                      if (_recipe!.updatedAt != null)
                                        SizedBox(height: 4),
                                      if (_recipe!.updatedAt != null)
                                        Text(
                                          'Diperbarui: ${_recipe!.updatedAt}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Color(
                                                    AppColors.textSecondary),
                                              ),
                                        ),
                                    ],
                                  ),
                                ),

                              SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
        floatingActionButton: _recipe != null && !_isLoading
            ? FloatingActionButton(
                backgroundColor: Color(AppColors.errorColor),
                onPressed: _isDeleting ? null : _handleDelete,
                tooltip: 'Hapus Resep',
                child: _isDeleting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(Icons.delete_rounded),
              )
            : null,
      ),
    );
  }

  // LOADING STATE
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
            'Memuat detail resep...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Color(AppColors.textSecondary),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  // ERROR STATE
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
                  _recipe = null;
                  _category = null;
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

  // EMPTY STATE
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 80,
            color: Color(AppColors.borderColor),
          ),
          SizedBox(height: 16),
          Text(
            'Resep tidak ditemukan',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Color(AppColors.textSecondary),
                ),
          ),
        ],
      ),
    );
  }
}
