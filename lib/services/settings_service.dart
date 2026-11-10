import 'package:shared_preferences/shared_preferences.dart';

// Layanan pengaturan aplikasi (Shared Preferences) - F8 / PBI-021
// Menyediakan getter sinkron untuk Loddy dan Salsabila setelah init() dipanggil di main.dart
class SettingsService {
  static SharedPreferences? _prefs;

  // Inisialisasi instance SharedPreferences saat aplikasi mulai
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Getter satuan suhu ('C' atau 'F'), default 'C'
  static String get unit => _prefs?.getString('tempUnit') ?? 'C';

  // Getter status tema gelap, default false (tema terang)
  static bool get darkMode => _prefs?.getBool('darkMode') ?? false;

  // Getter nama kota utama Beranda, default 'Yogyakarta'
  static String get mainCity => _prefs?.getString('mainCity') ?? 'Yogyakarta';

  // Getter latitude kota utama, default -7.79
  static double get mainLat => _prefs?.getDouble('mainLat') ?? -7.79;

  // Getter longitude kota utama, default 110.36
  static double get mainLon => _prefs?.getDouble('mainLon') ?? 110.36;

  // Setter satuan suhu
  static Future<void> setUnit(String newUnit) async {
    await _prefs?.setString('tempUnit', newUnit);
  }

  // Setter status tema gelap
  static Future<void> setDarkMode(bool isDark) async {
    await _prefs?.setBool('darkMode', isDark);
  }

  // Setter kota utama Beranda beserta koordinatnya
  static Future<void> setMainCity(String city, double lat, double lon) async {
    await _prefs?.setString('mainCity', city);
    await _prefs?.setDouble('mainLat', lat);
    await _prefs?.setDouble('mainLon', lon);
  }
}
