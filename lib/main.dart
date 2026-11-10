import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/favorite_city.dart';
import 'models/gear_item.dart';
import 'models/reminder.dart';
import 'screens/login_screen.dart';
import 'services/settings_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // 1. Memastikan binding framework Flutter telah siap
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi penyimpanan lokal Hive untuk Flutter
  await Hive.initFlutter();

  // 3. Registrasi adapter Hive untuk model buatan
  Hive.registerAdapter(ReminderAdapter());
  Hive.registerAdapter(FavoriteCityAdapter());
  Hive.registerAdapter(GearItemAdapter());

  // 4. Membuka box Hive data utama dan box cache cuaca milik Loddy
  await Hive.openBox<Reminder>('reminders');
  await Hive.openBox<FavoriteCity>('favorites');
  await Hive.openBox<GearItem>('gear');
  await Hive.openBox<String>('weather_cache');

  // 5. Inisialisasi layanan pengaturan aplikasi
  await SettingsService.init();

  // 6. Jalankan aplikasi Payungin
  runApp(const PayunginApp());
}

class PayunginApp extends StatelessWidget {
  const PayunginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payungin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      // Layar Login aktif sebagai halaman awal (PBI-006)
      home: const LoginScreen(),
      // Format 24 jam waktu Indonesia (tanpa AM/PM) untuk seluruh aplikasi
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
