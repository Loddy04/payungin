import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../widgets/input_field.dart';

// Layar Registrasi Akun Baru (F1 Ekstensi)
// Mendaftarkan Nama Lengkap, Username, dan Password ke SharedPreferences
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  bool _isFullNameError = false;
  bool _isUsernameError = false;
  bool _isPasswordError = false;
  bool _isConfirmError = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Proses validasi dan pendaftaran akun ke SharedPreferences
  Future<void> _handleRegister() async {
    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _isFullNameError = false;
      _isUsernameError = false;
      _isPasswordError = false;
      _isConfirmError = false;
    });

    // Validasi 1: Nama Lengkap minimal 3 karakter
    if (fullName.isEmpty || fullName.length < 3) {
      setState(() => _isFullNameError = true);
      _showErrorSnackBar('Nama Lengkap minimal 3 karakter.');
      return;
    }

    // Validasi 2: Username minimal 3 karakter dan tidak mengandung spasi
    if (username.isEmpty || username.length < 3 || username.contains(' ')) {
      setState(() => _isUsernameError = true);
      _showErrorSnackBar('Username minimal 3 karakter dan tanpa spasi.');
      return;
    }

    // Validasi 3: Password minimal 6 karakter
    if (password.isEmpty || password.length < 6) {
      setState(() => _isPasswordError = true);
      _showErrorSnackBar('Password minimal 6 karakter.');
      return;
    }

    // Validasi 4: Konfirmasi password harus cocok
    if (password != confirmPassword) {
      setState(() => _isConfirmError = true);
      _showErrorSnackBar('Konfirmasi password tidak cocok.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // Simpan data kredensial akun terdaftar ke SharedPreferences
      await prefs.setString('registered_fullName', fullName);
      await prefs.setString('registered_username', username);
      await prefs.setString('registered_password', password);

      if (!mounted) return;

      // Beri notifikasi sukses dan kembali ke Login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan masuk dengan akun baru Anda.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Kembalikan username yang didaftarkan ke layar login
      Navigator.pop(context, username);
    } catch (_) {
      if (!mounted) return;
      _showErrorSnackBar('Terjadi kesalahan saat menyimpan akun. Coba lagi.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.pc.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pc;

    return GlassScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header Registrasi
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: c.accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: c.glassBorder),
                  ),
                  child: Icon(
                    Icons.person_add_rounded,
                    size: 32,
                    color: c.accent,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Daftar Akun Baru',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: c.text,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Lengkapi data diri untuk mulai memantau cuaca',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: c.textMuted),
                ),
                const SizedBox(height: 24),

                // Kartu Formulir
                GlassCard(
                  padding: const EdgeInsets.all(22.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Field 1: Nama Lengkap
                      InputField(
                        controller: _fullNameController,
                        label: 'Nama Lengkap',
                        hint: 'Contoh: Salsabila Putri',
                        prefixIcon: Icons.badge_outlined,
                        isError: _isFullNameError,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) {
                          if (_isFullNameError) setState(() => _isFullNameError = false);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Field 2: Username
                      InputField(
                        controller: _usernameController,
                        label: 'Username',
                        hint: 'Pilih username unik (tanpa spasi)',
                        prefixIcon: Icons.alternate_email_rounded,
                        isError: _isUsernameError,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) {
                          if (_isUsernameError) setState(() => _isUsernameError = false);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Field 3: Password
                      InputField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Minimal 6 karakter',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        isError: _isPasswordError,
                        textInputAction: TextInputAction.next,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: c.textMuted,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        onChanged: (_) {
                          if (_isPasswordError) setState(() => _isPasswordError = false);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Field 4: Konfirmasi Password
                      InputField(
                        controller: _confirmPasswordController,
                        label: 'Konfirmasi Password',
                        hint: 'Ulangi password di atas',
                        prefixIcon: Icons.lock_reset_rounded,
                        obscureText: _obscureConfirm,
                        isError: _isConfirmError,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleRegister(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: c.textMuted,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                        onChanged: (_) {
                          if (_isConfirmError) setState(() => _isConfirmError = false);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Tombol Submit Daftar
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Daftar Sekarang',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Link Kembali ke Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: TextStyle(color: c.textMuted, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Masuk di sini',
                        style: TextStyle(
                          color: c.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

