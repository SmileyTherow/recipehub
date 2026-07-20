// screens/categories/category_form_screen.dart
/**
 * File: screens/categories/category_form_screen.dart
 * Fungsi: Form untuk tambah kategori baru atau edit kategori yang sudah ada
 * 
 * Mode:
 * - Tambah: Jika parameter category = null
 * - Edit: Jika parameter category = Category object
 * 
 * UPDATED: Tambah return value (true) untuk trigger refresh di list
 */

import 'package:flutter/material.dart';
import '../../services/category_service.dart';
import '../../models/category.dart';
import '../../utils/local_storage.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;

  const CategoryFormScreen({
    Key? key,
    this.category,
  }) : super(key: key);

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  // ============================================================
  // STATE VARIABLES
  // ============================================================
  int? _userId;
  bool _isSubmitting = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // Mode: true = Edit, false = Tambah
  bool get _isEditMode => widget.category != null;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    if (_isEditMode) {
      _prefillData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD USER ID
  // ============================================================
  /**
   * Method: _loadUserId()
   * Fungsi: Load user_id dari local storage
   */
  Future<void> _loadUserId() async {
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
    } catch (e) {
      debugPrint('Error loading user id: $e');
    }
  }

  // ============================================================
  // PREFILL DATA (MODE EDIT)
  // ============================================================
  /**
   * Method: _prefillData()
   * Fungsi: Pre-fill form dengan data kategori lama (mode edit)
   */
  void _prefillData() {
    if (widget.category == null) return;

    final category = widget.category!;
    _nameController.text = category.name;
  }

  // ============================================================
  // HANDLE SUBMIT
  // ============================================================
  /**
   * Method: _handleSubmit()
   * Fungsi: Validasi form dan submit
   */
  Future<void> _handleSubmit() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_isEditMode) {
        await _editCategory();
      } else {
        await _addCategory();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ============================================================
  // ADD CATEGORY
  // ============================================================
  /**
   * Method: _addCategory()
   * Fungsi: Tambah kategori baru
   */
  Future<void> _addCategory() async {
    try {
      if (_userId == null) return;

      final response = await CategoryService.addCategory(
        userId: _userId!,
        name: _nameController.text.trim(),
      );

      if (response['success'] == true) {
        _showSuccessDialog(
          'Kategori Berhasil Ditambahkan',
          () {
            Navigator.pop(context, true); // Return true untuk refresh
          },
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Gagal menambah kategori'),
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
    }
  }

  // ============================================================
  // EDIT CATEGORY
  // ============================================================
  /**
   * Method: _editCategory()
   * Fungsi: Edit kategori yang sudah ada
   */
  Future<void> _editCategory() async {
    try {
      if (_userId == null || widget.category == null) return;

      final response = await CategoryService.editCategory(
        categoryId: widget.category!.id,
        userId: _userId!,
        name: _nameController.text.trim(),
      );

      if (response['success'] == true) {
        _showSuccessDialog(
          'Kategori Berhasil Diperbarui',
          () {
            Navigator.pop(context, true); // Return true untuk refresh
          },
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Gagal memperbarui kategori'),
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
    }
  }

  // ============================================================
  // SHOW SUCCESS DIALOG
  // ============================================================
  /**
   * Method: _showSuccessDialog()
   * Fungsi: Tampilkan dialog sukses dan pop ke screen sebelumnya
   */
  void _showSuccessDialog(String message, VoidCallback onOk) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Sukses'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              onOk(); // Callback untuk pop screen
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
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
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? 'Edit Kategori' : 'Tambah Kategori',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // HEADER
              // ============================================================
              Text(
                _isEditMode ? 'Edit Nama Kategori' : 'Tambah Kategori Baru',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.textPrimary),
                    ),
              ),

              SizedBox(height: 8),

              Text(
                _isEditMode
                    ? 'Ubah nama kategori yang sudah ada'
                    : 'Masukkan nama kategori baru untuk resep Anda',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Color(AppColors.textSecondary),
                    ),
              ),

              SizedBox(height: 32),

              // ============================================================
              // FORM
              // ============================================================
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppConstants.labelCategoryName,
                  hintText: 'Masukkan nama kategori',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                validator: (value) =>
                    Validators.validateCategoryName(value),
              ),

              SizedBox(height: 32),

              // ============================================================
              // SUBMIT BUTTON
              // ============================================================
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
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
                      : Text(
                          _isEditMode ? 'Update Kategori' : 'Simpan Kategori',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}