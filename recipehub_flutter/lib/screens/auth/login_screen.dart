// screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/local_storage.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // CONTROLLER & STATE
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true; // untuk hide/show password

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // HANDLE LOGIN
  Future<void> _handleLogin() async {
    // 1. Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Kirim request ke backend
      final response = await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 4. Handle response
      if (response['success'] == true) {
        // Login berhasil
        // Simpan user data ke local storage
        final user = response['user'];
        final localStorage = LocalStorage();

        await localStorage.saveUserData(
          userId: user.id,
          userName: user.name,
          userEmail: user.email,
        );

        // Tampilkan success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppConstants.successLoggedIn),
            backgroundColor: Color(AppColors.successColor),
            duration: AppConstants.snackBarDuration,
          ),
        );

        // Navigasi ke Dashboard
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      } else {
        // Login gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Login gagal'),
            backgroundColor: Color(AppColors.errorColor),
            duration: AppConstants.snackBarDuration,
          ),
        );
      }
    } catch (e) {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Color(AppColors.errorColor),
          duration: AppConstants.snackBarDuration,
        ),
      );
    } finally {
      // Set loading state back to false
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.backgroundColor),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              SizedBox(height: 40),
              Text(
                'Masuk ke Akun Anda',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.textPrimary),
                    ),
              ),
              SizedBox(height: 8),
              Text(
                'Silakan login untuk melanjutkan',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Color(AppColors.textSecondary),
                    ),
              ),

              SizedBox(height: 40),

              // FORM
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: AppConstants.labelEmail,
                        hintText: AppConstants.placeholderEmail,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) => Validators.validateEmail(value),
                    ),

                    SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: AppConstants.labelPassword,
                        hintText: AppConstants.labelPassword,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) =>
                          Validators.validatePassword(value),
                    ),

                    SizedBox(height: 24),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(AppColors.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
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
                                AppConstants.btnLogin,
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

              SizedBox(height: 24),

              // LINK KE REGISTER
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Color(AppColors.textSecondary),
                        ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/register');
                    },
                    child: Text(
                      'Daftar di sini',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Color(AppColors.primaryColor),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}