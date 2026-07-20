// utils/validators.dart
/**
 * File: utils/validators.dart
 * Fungsi: Validasi input form (email, password, nama, dll)
 */

class Validators {
  // ============================================================
  // VALIDASI EMAIL
  // ============================================================
  /**
   * Method: validateEmail()
   * Fungsi: Validasi format email
   * Parameter: email (string)
   * Return: String? (pesan error jika invalid, null jika valid)
   */
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email tidak boleh kosong';
    }

    // Regex untuk validasi email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Format email tidak valid';
    }

    return null; // Email valid
  }

  // ============================================================
  // VALIDASI PASSWORD
  // ============================================================
  /**
   * Method: validatePassword()
   * Fungsi: Validasi password (minimal 6 karakter)
   * Parameter: password (string)
   * Return: String? (pesan error jika invalid, null jika valid)
   */
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (password.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null; // Password valid
  }

  // ============================================================
  // VALIDASI KONFIRMASI PASSWORD
  // ============================================================
  /**
   * Method: validatePasswordConfirm()
   * Fungsi: Validasi konfirmasi password (harus sama dengan password)
   * Parameter: password, passwordConfirm (string)
   * Return: String? (pesan error jika tidak sama)
   */
  static String? validatePasswordConfirm(
    String? password,
    String? passwordConfirm,
  ) {
    if (passwordConfirm == null || passwordConfirm.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }

    if (password != passwordConfirm) {
      return 'Password tidak sesuai';
    }

    return null; // Password cocok
  }

  // ============================================================
  // VALIDASI NAMA
  // ============================================================
  /**
   * Method: validateName()
   * Fungsi: Validasi nama user (tidak boleh kosong)
   * Parameter: name (string)
   * Return: String? (pesan error jika invalid)
   */
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Nama tidak boleh kosong';
    }

    if (name.length < 3) {
      return 'Nama minimal 3 karakter';
    }

    if (name.length > 100) {
      return 'Nama maksimal 100 karakter';
    }

    return null; // Nama valid
  }

  // ============================================================
  // VALIDASI NAMA RESEP
  // ============================================================
  /**
   * Method: validateRecipeName()
   * Fungsi: Validasi nama resep
   * Parameter: name (string)
   * Return: String? (pesan error jika invalid)
   */
  static String? validateRecipeName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Nama resep tidak boleh kosong';
    }

    if (name.length < 3) {
      return 'Nama resep minimal 3 karakter';
    }

    if (name.length > 255) {
      return 'Nama resep maksimal 255 karakter';
    }

    return null;
  }

  // ============================================================
  // VALIDASI INGREDIENTS & STEPS
  // ============================================================
  /**
   * Method: validateIngredients()
   * Fungsi: Validasi ingredients/bahan
   * Parameter: ingredients (string)
   * Return: String? (pesan error jika invalid)
   */
  static String? validateIngredients(String? ingredients) {
    if (ingredients == null || ingredients.isEmpty) {
      return 'Bahan tidak boleh kosong';
    }

    if (ingredients.length > 5000) {
      return 'Bahan maksimal 5000 karakter';
    }

    return null;
  }

  /**
   * Method: validateSteps()
   * Fungsi: Validasi langkah memasak
   * Parameter: steps (string)
   * Return: String? (pesan error jika invalid)
   */
  static String? validateSteps(String? steps) {
    if (steps == null || steps.isEmpty) {
      return 'Langkah memasak tidak boleh kosong';
    }

    if (steps.length > 5000) {
      return 'Langkah memasak maksimal 5000 karakter';
    }

    return null;
  }

  // ============================================================
  // VALIDASI COOKING TIME & SERVINGS
  // ============================================================
  /**
   * Method: validateCookingTime()
   * Fungsi: Validasi waktu memasak (harus angka positif)
   * Parameter: cookingTime (string atau int)
   * Return: String? (pesan error jika invalid)
   */
  static String? validateCookingTime(dynamic cookingTime) {
    if (cookingTime == null || cookingTime.toString().isEmpty) {
      return 'Waktu memasak tidak boleh kosong';
    }

    try {
      final time = int.parse(cookingTime.toString());
      if (time <= 0) {
        return 'Waktu memasak harus lebih dari 0';
      }
    } catch (e) {
      return 'Waktu memasak harus berupa angka';
    }

    return null;
  }

  /**
   * Method: validateServings()
   * Fungsi: Validasi jumlah porsi (harus angka positif)
   * Parameter: servings (string atau int)
   * Return: String? (pesan error jika invalid)
   */
  static String? validateServings(dynamic servings) {
    if (servings == null || servings.toString().isEmpty) {
      return 'Porsi tidak boleh kosong';
    }

    try {
      final serving = int.parse(servings.toString());
      if (serving <= 0) {
        return 'Porsi harus lebih dari 0';
      }
    } catch (e) {
      return 'Porsi harus berupa angka';
    }

    return null;
  }

  // ============================================================
  // VALIDASI NAMA KATEGORI
  // ============================================================
  /**
   * Method: validateCategoryName()
   * Fungsi: Validasi nama kategori
   * Parameter: name (string)
   * Return: String? (pesan error jika invalid)
   */
  static String? validateCategoryName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Nama kategori tidak boleh kosong';
    }

    if (name.length < 2) {
      return 'Nama kategori minimal 2 karakter';
    }

    if (name.length > 100) {
      return 'Nama kategori maksimal 100 karakter';
    }

    return null;
  }
}