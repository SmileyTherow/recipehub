// screens/recipes/recipe_form_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/recipe_service.dart';
import '../../services/category_service.dart';
import '../../models/recipe.dart';
import '../../models/category.dart';
import '../../utils/local_storage.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';
import '../../utils/platform_image.dart';

class RecipeFormScreen extends StatefulWidget {
  final Recipe? recipe;

  const RecipeFormScreen({
    Key? key,
    this.recipe,
  }) : super(key: key);

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  // STATE VARIABLES

  int? _userId;
  List<Category> _categories = [];
  bool _isLoadingCategories = true;
  bool _isSubmitting = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();

  int? _selectedCategoryId;

  // Image variables: use XFile to store selected image (works on web & mobile)
  XFile? _selectedImageFile;
  String? _oldImageUrl;

  // Mode: true = Edit, false = Tambah
  bool get _isEditMode => widget.recipe != null;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadData();
    if (_isEditMode) {
      _prefillData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cookingTimeController.dispose();
    _servingsController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    super.dispose();
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

      await _loadCategories();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  // LOAD CATEGORIES
  Future<void> _loadCategories() async {
    try {
      if (_userId == null) return;

      final response = await CategoryService.getCategories(userId: _userId!);

      if (response['success'] == true && response['categories'] != null) {
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

  // PREFILL DATA (MODE EDIT)
  void _prefillData() {
    if (widget.recipe == null) return;

    final recipe = widget.recipe!;
    _nameController.text = recipe.name;
    _cookingTimeController.text = recipe.cookingTime.toString();
    _servingsController.text = recipe.servings.toString();
    _descriptionController.text = recipe.description ?? '';
    _ingredientsController.text = recipe.ingredients;
    _stepsController.text = recipe.steps;
    _selectedCategoryId = recipe.categoryId;
    _oldImageUrl = recipe.image; // Simpan URL gambar lama
  }

  // PICK IMAGE FROM GALLERY
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compress image quality to 85%
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = pickedFile;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gambar dipilih: ${pickedFile.name}'),
              backgroundColor: Color(AppColors.successColor),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memilih gambar: ${e.toString()}'),
            backgroundColor: Color(AppColors.errorColor),
            duration: AppConstants.snackBarDuration,
          ),
        );
      }
    }
  }

  // TAKE PHOTO FROM CAMERA
  Future<void> _takePhotoFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Compress image quality to 85%
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = pickedFile;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Foto berhasil diambil'),
              backgroundColor: Color(AppColors.successColor),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mengambil foto: ${e.toString()}'),
            backgroundColor: Color(AppColors.errorColor),
            duration: AppConstants.snackBarDuration,
          ),
        );
      }
    }
  }

  // REMOVE SELECTED IMAGE
  void _removeSelectedImage() {
    setState(() {
      _selectedImageFile = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gambar dihapus'),
        backgroundColor: Color(AppColors.primaryColor),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // SHOW IMAGE PICKER OPTIONS
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Sumber Gambar',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: Color(AppColors.primaryColor),
              ),
              title: Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt_outlined,
                color: Color(AppColors.primaryColor),
              ),
              title: Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _takePhotoFromCamera();
              },
            ),
            if (_selectedImageFile != null)
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Color(AppColors.errorColor),
                ),
                title: Text('Hapus Gambar'),
                onTap: () {
                  Navigator.pop(context);
                  _removeSelectedImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  // HANDLE SUBMIT
  Future<void> _handleSubmit() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validasi kategori dipilih
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih kategori terlebih dahulu'),
          backgroundColor: Color(AppColors.errorColor),
          duration: AppConstants.snackBarDuration,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_isEditMode) {
        await _editRecipe();
      } else {
        await _addRecipe();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ADD RECIPE WITH IMAGE
  Future<void> _addRecipe() async {
    try {
      if (_userId == null) return;

      final response = await RecipeService.addRecipe(
        userId: _userId!,
        categoryId: _selectedCategoryId!,
        name: _nameController.text.trim(),
        ingredients: _ingredientsController.text.trim(),
        steps: _stepsController.text.trim(),
        description: _descriptionController.text.trim(),
        cookingTime: int.parse(_cookingTimeController.text.trim()),
        servings: int.parse(_servingsController.text.trim()),
        imageFile: _selectedImageFile, // Send selected image as XFile (null-ok)
      );

      if (response['success'] == true) {
        _showSuccessDialog(
          'Resep Berhasil Ditambahkan',
          () {
            Navigator.pop(context, true); // Return true untuk refresh
          },
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Gagal menambah resep'),
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

  // EDIT RECIPE WITH IMAGE
  Future<void> _editRecipe() async {
    try {
      if (_userId == null || widget.recipe == null) return;

      final response = await RecipeService.editRecipe(
        recipeId: widget.recipe!.id,
        userId: _userId!,
        name: _nameController.text.trim(),
        categoryId: _selectedCategoryId,
        ingredients: _ingredientsController.text.trim(),
        steps: _stepsController.text.trim(),
        description: _descriptionController.text.trim(),
        cookingTime: int.parse(_cookingTimeController.text.trim()),
        servings: int.parse(_servingsController.text.trim()),
        imageFile: _selectedImageFile, // Send new image as XFile if any
      );

      if (response['success'] == true) {
        _showSuccessDialog(
          'Resep Berhasil Diperbarui',
          () {
            Navigator.pop(context, true); // Return true untuk refresh
          },
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Gagal memperbarui resep'),
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

  // SHOW SUCCESS DIALOG
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

  // LOGOUT
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
          _isEditMode ? 'Edit Resep' : 'Tambah Resep',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE PREVIEW SECTION

            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Color(AppColors.backgroundColor),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(AppColors.borderColor),
                  width: 2,
                ),
              ),
              child: _selectedImageFile != null
                  ? Stack(
                      children: [
                        // Selected Image (platform-aware)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox.expand(
                            child: buildImageFromXFile(
                              _selectedImageFile!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                        // Remove Button
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _removeSelectedImage,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(AppColors.errorColor),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : _oldImageUrl != null && _oldImageUrl!.isNotEmpty
                      ? Stack(
                          children: [
                            // Old Image (network)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _oldImageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Color(AppColors.backgroundColor),
                                    child: Center(
                                      child: Icon(
                                        Icons.restaurant_menu_rounded,
                                        size: 80,
                                        color: Color(AppColors.primaryColor),
                                      ),
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(AppColors.primaryColor),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Badge - Old Image
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(AppColors.primaryColor),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Gambar Lama',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                size: 80,
                                color: Color(AppColors.borderColor),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Tidak ada gambar',
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
            ),

            SizedBox(height: 20),

            // FORM

            Form(
              key: _formKey,
              child: Column(
                children: [
                  // IMAGE PICKER BUTTONS

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _showImagePickerOptions,
                      icon: Icon(Icons.image_outlined),
                      label: Text(
                        _selectedImageFile != null
                            ? 'Ubah Gambar'
                            : _isEditMode
                                ? 'Ubah Gambar (Opsional)'
                                : 'Pilih Gambar (Opsional)',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: AppConstants.labelName,
                      hintText: 'Masukkan nama resep',
                      prefixIcon: Icon(Icons.restaurant_menu_outlined),
                    ),
                    validator: (value) => Validators.validateRecipeName(value),
                  ),

                  SizedBox(height: 16),

                  _isLoadingCategories
                      ? SizedBox(
                          height: 56,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(AppColors.primaryColor),
                              ),
                            ),
                          ),
                        )
                      : Container(
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
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(AppConstants.labelCategory),
                            ),
                            items: _categories.isEmpty
                                ? [
                                    DropdownMenuItem<int?>(
                                      value: null,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Text('Tidak ada kategori'),
                                      ),
                                    ),
                                  ]
                                : [
                                    DropdownMenuItem<int?>(
                                      value: null,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Text('Pilih Kategori'),
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
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryId = value;
                              });
                            },
                          ),
                        ),

                  SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cookingTimeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Waktu (menit)',
                            hintText: '30',
                            prefixIcon: Icon(Icons.access_time_outlined),
                          ),
                          validator: (value) =>
                              Validators.validateCookingTime(value),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _servingsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Porsi',
                            hintText: '4',
                            prefixIcon: Icon(Icons.restaurant_outlined),
                          ),
                          validator: (value) =>
                              Validators.validateServings(value),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi (Opsional)',
                      hintText: 'Masukkan deskripsi tambahan',
                      prefixIcon: Icon(Icons.description_outlined),
                      alignLabelWithHint: true,
                    ),
                  ),

                  SizedBox(height: 16),

                  TextFormField(
                    controller: _ingredientsController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      labelText: AppConstants.labelIngredients,
                      hintText:
                          '- 2 kg daging sapi\n- 1 bawang merah\n- 2 siung bawang putih\n- dst...',
                      prefixIcon: Icon(Icons.list_outlined),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) => Validators.validateIngredients(value),
                  ),

                  SizedBox(height: 16),

                  TextFormField(
                    controller: _stepsController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      labelText: AppConstants.labelSteps,
                      hintText:
                          '1. Potong daging menjadi potongan kecil\n2. Panaskan minyak di wajan\n3. dst...',
                      prefixIcon: Icon(Icons.format_list_numbered_outlined),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) => Validators.validateSteps(value),
                  ),

                  SizedBox(height: 32),

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
                              _isEditMode ? 'Update Resep' : 'Simpan Resep',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
