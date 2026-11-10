import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../theme/app_theme.dart';
import '../widgets/input_field.dart';
import 'register_screen.dart';
import 'root.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk input teks username dan password
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State untuk conditional rendering border merah saat login gagal
  bool _isLoginFailed = false;

  // State untuk menyembunyikan atau menampilkan teks password
  bool _obscurePassword = true;

  // State loading saat memeriksa sesi agar layar tidak berkedip
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Cek sesi pengguna di SharedPreferences (F1)
  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('loginData') ?? false;

    // Jika sudah login, langsung alihkan ke Root
    if (isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RootScreen()),
      );
      return;
    }

    // Jika belum login, hentikan loading dan tampilkan form
    if (mounted) {
      setState(() {
        _isCheckingSession = false;
      });
    }
  }

  // Fungsi validasi login dengan akun demo dan penyimpanan sesi
  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // Sembunyikan keyboard saat tombol ditekan
    FocusScope.of(context).unfocus();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _isLoginFailed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username dan password tidak boleh kosong.'),
          backgroundColor: Color(0xFFD83A3F),
        ),
      );
      return;
    }

    // Periksa kredensial dari akun demo atau akun yang terdaftar di SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final isDemo = User.demo.matches(username, password);

    final regUser = prefs.getString('registered_username');
    final regPass = prefs.getString('registered_password');
    final regFullName = prefs.getString('registered_fullName');
    final isRegistered = regUser != null &&
        regPass != null &&
        regUser == username.toLowerCase() &&
        regPass == password;

    if (isDemo || isRegistered) {
      setState(() {
        _isLoginFailed = false;
      });

      // Simpan status sesi aktif
      await prefs.setBool('loginData', true);
      await prefs.setString('username', username);

      // Simpan atau pertahankan nama lengkap
      if (isRegistered && regFullName != null && regFullName.isNotEmpty) {
        await prefs.setString('fullName', regFullName);
      } else if (prefs.getString('fullName') == null) {
        await prefs.setString('fullName', 'Administrator Payungin');
      }

      if (!mounted) return;

      // Pindah ke Root tanpa menyimpan riwayat Login (pushReplacement)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RootScreen()),
      );
    } else {
      if (!mounted) return;
      setState(() {
        _isLoginFailed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username atau password salah!'),
          backgroundColor: Color(0xFFD83A3F),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pc;

    // Tampilkan indikator loading selama pengecekan sesi aktif
    if (_isCheckingSession) {
      return const GlassScaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return GlassScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kartu utama login dengan efek kaca
              GlassCard(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo aplikasi Payungin
                    Image.asset(
                      'assets/images/logo_mark_blue.png',
                      width: 72,
                      height: 72,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Payungin',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pantau cuaca dan siap sedia sebelum hujan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: c.textMuted,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Input Username
                    InputField(
                      controller: _usernameController,
                      label: 'Username',
                      hint: 'Masukkan username',
                      prefixIcon: Icons.person_outline_rounded,
                      isError: _isLoginFailed,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) {
                        if (_isLoginFailed) {
                          setState(() => _isLoginFailed = false);
                        }
                      },
                    ),
                    const SizedBox(height: 18),

                    // Input Password
                    InputField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Masukkan password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      isError: _isLoginFailed,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _login(),
                      onChanged: (_) {
                        if (_isLoginFailed) {
                          setState(() => _isLoginFailed = false);
                        }
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _isLoginFailed ? c.danger : c.textMuted,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Tombol Masuk
                    ElevatedButton(
                      onPressed: _login,
                      child: const Text('Masuk'),
                    ),
                    const SizedBox(height: 20),

                    // Tautan menuju layar Registrasi Akun Baru
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun? ',
                          style: TextStyle(color: c.textMuted, fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final registeredUser = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                            // Otomatis isi username jika baru saja mendaftar
                            if (registeredUser != null && registeredUser.isNotEmpty) {
                              _usernameController.text = registeredUser;
                              _passwordController.clear();
                            }
                          },
                          child: Text(
                            'Daftar di sini',
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
            ],
          ),
        ),
      ),
    );
  }
}
