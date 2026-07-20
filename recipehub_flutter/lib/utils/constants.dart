// utils/constants.dart
/**
 * File: utils/constants.dart
 * Fungsi: Konstanta global yang digunakan di seluruh aplikasi
 */

class AppConstants {
  // ============================================================
  // APP INFO
  // ============================================================
  static const String appName = 'RecipeHub';
  static const String appVersion = '1.0.0';

  // ============================================================
  // SPLASH SCREEN
  // ============================================================
  static const int splashDuration = 3; // dalam detik

  // ============================================================
  // TIMEOUT DURATIONS
  // ============================================================
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(seconds: 60);

  // ============================================================
  // ERROR MESSAGES
  // ============================================================
  static const String errorNetwork = 'Terjadi kesalahan jaringan. Silakan cek koneksi Anda.';
  static const String errorServer = 'Terjadi kesalahan pada server. Silakan coba lagi.';
  static const String errorTimeout = 'Permintaan timeout. Silakan coba lagi.';
  static const String errorUnknown = 'Terjadi kesalahan yang tidak diketahui.';
  static const String errorValidation = 'Validasi input gagal.';

  // ============================================================
  // SUCCESS MESSAGES
  // ============================================================
  static const String successRegistered = 'Registrasi berhasil! Silakan login.';
  static const String successLoggedIn = 'Login berhasil!';
  static const String successRecipeSaved = 'Resep berhasil disimpan!';
  static const String successRecipeUpdated = 'Resep berhasil diperbarui!';
  static const String successRecipeDeleted = 'Resep berhasil dihapus!';
  static const String successCategorySaved = 'Kategori berhasil disimpan!';
  static const String successCategoryUpdated = 'Kategori berhasil diperbarui!';
  static const String successCategoryDeleted = 'Kategori berhasil dihapus!';
  static const String successLoggedOut = 'Logout berhasil!';

  // ============================================================
  // BUTTON LABELS
  // ============================================================
  static const String btnLogin = 'Masuk';
  static const String btnRegister = 'Daftar';
  static const String btnLogout = 'Keluar';
  static const String btnSave = 'Simpan';
  static const String btnUpdate = 'Perbarui';
  static const String btnDelete = 'Hapus';
  static const String btnCancel = 'Batal';
  static const String btnBack = 'Kembali';
  static const String btnSearch = 'Cari';
  static const String btnReset = 'Reset';
  static const String btnSubmit = 'Kirim';
  static const String btnAdd = 'Tambah';
  static const String btnEdit = 'Edit';
  static const String btnViewAll = 'Lihat Semua';
  static const String btnUploadImage = 'Pilih Gambar';
  static const String btnTakePhoto = 'Ambil Foto';
  static const String btnChangePassword = 'Ubah Password';

  // ============================================================
  // FORM LABELS
  // ============================================================
  static const String labelName = 'Nama';
  static const String labelEmail = 'Email';
  static const String labelPassword = 'Password';
  static const String labelPasswordConfirm = 'Konfirmasi Password';
  static const String labelRecipeName = 'Nama Resep';
  static const String labelCategory = 'Kategori';
  static const String labelIngredients = 'Bahan';
  static const String labelSteps = 'Langkah Memasak';
  static const String labelCookingTime = 'Waktu Memasak (menit)';
  static const String labelServings = 'Porsi';
  static const String labelCategoryName = 'Nama Kategori';
  static const String labelImage = 'Gambar';

  // ============================================================
  // PLACEHOLDER TEXT
  // ============================================================
  static const String placeholderName = 'Masukkan nama';
  static const String placeholderEmail = 'Masukkan email';
  static const String placeholderPassword = 'Masukkan password';
  static const String placeholderSearch = 'Cari resep...';

  // ============================================================
  // DIALOG TEXT
  // ============================================================
  static const String dialogConfirmDelete = 'Anda yakin ingin menghapus?';
  static const String dialogConfirmLogout = 'Anda yakin ingin keluar?';
  static const String dialogWarning = 'Perhatian';
  static const String dialogError = 'Error';
  static const String dialogSuccess = 'Sukses';

  // ============================================================
  // EMPTY STATE MESSAGES
  // ============================================================
  static const String emptyRecipes = 'Belum ada resep. Mulai buat resep Anda sekarang!';
  static const String emptyCategories = 'Belum ada kategori. Buat kategori terlebih dahulu!';
  static const String emptySearch = 'Tidak ada hasil pencarian.';

  // ============================================================
  // NAVIGATION LABELS
  // ============================================================
  static const String navHome = 'Beranda';
  static const String navRecipes = 'Resep';
  static const String navCategories = 'Kategori';
  static const String navProfile = 'Profil';

  // ============================================================
  // DURATION & TIMING
  // ============================================================
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration dialogAnimationDuration = Duration(milliseconds: 300);
}

// ============================================================
// COLOR CONSTANTS (untuk consistency styling)
// ============================================================
class AppColors {
  static const primaryColor = 0xFF6C5CE7; // Purple
  static const secondaryColor = 0xFFA29BFE; // Light Purple
  static const accentColor = 0xFFFF7675; // Red
  static const successColor = 0xFF00B894; // Green
  static const warningColor = 0xFFFDBD15; // Yellow
  static const errorColor = 0xFFD63031; // Dark Red
  static const backgroundColor = 0xFFF5F6FA; // Light Gray
  static const cardColor = 0xFFFFFFFF; // White
  static const textPrimary = 0xFF2D3436; // Dark Gray
  static const textSecondary = 0xFF636E72; // Gray
  static const borderColor = 0xFFDFE6E9; // Light Gray
}