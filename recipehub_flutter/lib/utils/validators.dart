// utils/validators.dart
class Validators {
  // VALIDASI EMAIL
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

  // VALIDASI PASSWORD
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (password.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null; // Password valid
  }

  // VALIDASI KONFIRMASI PASSWORD
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

  // VALIDASI NAMA
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

  // VALIDASI NAMA RESEP
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

  // VALIDASI INGREDIENTS & STEPS
  static String? validateIngredients(String? ingredients) {
    if (ingredients == null || ingredients.isEmpty) {
      return 'Bahan tidak boleh kosong';
    }

    if (ingredients.length > 5000) {
      return 'Bahan maksimal 5000 karakter';
    }

    return null;
  }

  static String? validateSteps(String? steps) {
    if (steps == null || steps.isEmpty) {
      return 'Langkah memasak tidak boleh kosong';
    }

    if (steps.length > 5000) {
      return 'Langkah memasak maksimal 5000 karakter';
    }

    return null;
  }

  // VALIDASI COOKING TIME & SERVINGS
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

  // VALIDASI NAMA KATEGORI
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
