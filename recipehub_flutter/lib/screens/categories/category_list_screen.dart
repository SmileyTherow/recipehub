// screens/categories/category_list_screen.dart
/**
 * File: screens/categories/category_list_screen.dart
 * Fungsi: Menampilkan daftar semua kategori resep user dengan fitur edit & delete
 * 
 * UPDATED: Menghapus tampilan ID dari card kategori dan merapikan spacing
 */

import 'package:flutter/material.dart';
import '../../services/category_service.dart';
import '../../models/category.dart';
import '../../utils/local_storage.dart';
import '../../utils/constants.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({Key? key}) : super(key: key);

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  int? _userId;
  List<Category> _categories = [];
  List<Category> _filteredCategories = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;
  int _currentNavIndex = 2;
  int? _deletingCategoryId;

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

  // ============================================================
  // LOAD DATA
  // ============================================================
  /**
   * Method: _loadData()
   * Fungsi: Load user_id dan ambil data categories
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

      await _loadCategories();
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // LOAD CATEGORIES
  // ============================================================
  /**
   * Method: _loadCategories()
   * Fungsi: Ambil daftar kategori dari backend
   */
  Future<void> _loadCategories() async {
    try {
      if (_userId == null) return;

      final response = await CategoryService.getCategories(userId: _userId!);

      if (response['success'] == true) {
        setState(() {
          _categories = response['categories'] ?? [];
          _filteredCategories = List.from(_categories);
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Gagal load kategori';
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

  void _searchCategory(String keyword) {
    setState(() {
      if (keyword.trim().isEmpty) {
        _filteredCategories = List.from(_categories);
      } else {
        _filteredCategories = _categories.where((category) {
          return category.name
              .toLowerCase()
              .contains(keyword.toLowerCase());
        }).toList();
      }
    });
  }

  // ============================================================
  // HANDLE ADD CATEGORY
  // ============================================================
  /**
   * Method: _handleAddCategory()
   * Fungsi: Navigate ke add category form
   */
  Future<void> _handleAddCategory() async {
    try {
      final result = await Navigator.pushNamed(
        context,
        '/categories/add',
      );

      // Jika kategori berhasil ditambahkan, reload list
      if (result == true && mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
        await _loadCategories();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kategori berhasil ditambahkan!'),
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
  // HANDLE EDIT CATEGORY
  // ============================================================
  /**
   * Method: _handleEditCategory()
   * Fungsi: Navigate ke edit category form
   */
  Future<void> _handleEditCategory(Category category) async {
    try {
      final result = await Navigator.pushNamed(
        context,
        '/categories/edit',
        arguments: category,
      );

      // Jika kategori berhasil diupdate, reload list
      if (result == true && mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
        await _loadCategories();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kategori berhasil diperbarui!'),
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
  // HANDLE DELETE
  // ============================================================
  /**
   * Method: _handleDelete()
   * Fungsi: Show delete confirmation dialog
   */
  void _handleDelete(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Kategori'),
        content: Text(
            'Apakah Anda yakin ingin menghapus kategori "${category.name}"?\n\nTindakan ini tidak dapat dibatalkan.'),
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
              _deleteCategory(category);
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

  // ============================================================
  // DELETE CATEGORY
  // ============================================================
  /**
   * Method: _deleteCategory()
   * Fungsi: Delete kategori dari backend
   */
  Future<void> _deleteCategory(Category category) async {
    try {
      if (_userId == null) return;

      setState(() {
        _deletingCategoryId = category.id;
      });

      final response = await CategoryService.deleteCategory(
        categoryId: category.id,
        userId: _userId!,
      );

      if (response['success'] == true) {
        if (mounted) {
          setState(() {
            _categories.removeWhere((c) => c.id == category.id);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kategori berhasil dihapus'),
              backgroundColor: Color(AppColors.successColor),
              duration: AppConstants.snackBarDuration,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Gagal hapus kategori'),
              backgroundColor: Color(AppColors.errorColor),
              duration: AppConstants.snackBarDuration,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Color(AppColors.errorColor),
            duration: AppConstants.snackBarDuration,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _deletingCategoryId = null;
        });
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
        // Recipes
        Navigator.of(context).pushReplacementNamed('/recipes');
        break;
      case 2:
        // Categories (stay in categories)
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
          'Daftar Kategori',
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
                  onRefresh: _loadCategories,
                  color: Color(AppColors.primaryColor),
                  child: Column(
                    children: [

                      Padding(
                        padding: EdgeInsets.all(16),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _searchCategory,
                          decoration: InputDecoration(
                            hintText: 'Cari kategori...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: _filteredCategories.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _filteredCategories.length,
                                itemBuilder: (context, index) {

                                  final category = _filteredCategories[index];
                                  final isDeleting =
                                      _deletingCategoryId == category.id;

                                  return _CategoryCard(
                                    category: category,
                                    isDeleting: isDeleting,
                                    onEdit: () => _handleEditCategory(category),
                                    onDelete: () => _handleDelete(category),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(AppColors.primaryColor),
        onPressed: _handleAddCategory,
        tooltip: 'Tambah Kategori',
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
            'Memuat kategori...',
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
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 80,
              color: Color(AppColors.borderColor),
            ),
            SizedBox(height: 16),
            Text(
              'Belum ada kategori',
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
                'Buat kategori terlebih dahulu untuk mengorganisir resep Anda',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Color(AppColors.textSecondary),
                    ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _handleAddCategory,
              icon: Icon(Icons.add),
              label: Text('Buat Kategori'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppColors.primaryColor),
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
// CATEGORY CARD WIDGET
// ============================================================
class _CategoryCard extends StatelessWidget {
  final Category category;
  final bool isDeleting;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CategoryCard({
    required this.category,
    required this.isDeleting,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
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
          // Category Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(AppColors.primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.category_rounded,
              color: Color(AppColors.primaryColor),
            ),
          ),
          SizedBox(width: 16),
          // Category Info (only name - ID removed)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          // Action Icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Color(AppColors.primaryColor)),
                onPressed: isDeleting ? null : onEdit,
                tooltip: 'Edit',
              ),
              if (isDeleting)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(AppColors.errorColor),
                    ),
                  ),
                )
              else
                IconButton(
                  icon: Icon(Icons.delete, color: Color(AppColors.errorColor)),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
            ],
          ),
        ],
      ),
    );
  }
}