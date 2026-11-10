// Model Pengguna untuk autentikasi akun demo (F1)
class User {
  final String username;
  final String password;

  const User({
    required this.username,
    required this.password,
  });

  // Akun demo tunggal sesuai kesepakatan tim
  static const User demo = User(
    username: 'adminpayungin',
    password: 'payungin123',
  );

  // Method verifikasi kecocokan kredensial pengguna
  bool matches(String inputUsername, String inputPassword) {
    return username == inputUsername.trim() && password == inputPassword;
  }
}
