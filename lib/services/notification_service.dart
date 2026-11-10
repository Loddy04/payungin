import 'package:flutter/foundation.dart';

import '../models/reminder.dart';

// Layanan notifikasi pengingat cuaca (F16)
// Menerapkan pola OOP Singleton sesuai Dokumen Final Bagian 7
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  // Factory constructor yang selalu mengembalikan satu instans yang sama
  factory NotificationService() => _instance;

  // Constructor privat internal
  NotificationService._internal();

  // Inisialisasi awal layanan notifikasi
  // Isi lengkap (plugin, timezone, channel Android) dikerjakan di PBI-043 (Sprint 4)
  Future<void> init() async {
    debugPrint('[NotificationService Stub] Inisialisasi notifikasi.');
  }

  // Permintaan izin notifikasi Android
  Future<bool> requestPermission() async {
    debugPrint('[NotificationService Stub] Permintaan izin notifikasi disetujui.');
    return true;
  }

  // Menjadwalkan notifikasi pengingat cuaca
  // TODO: ganti Object advice ke WeatherAdvice di PBI-053 (Sprint 5) setelah weather_advice.dart ada
  Future<void> schedule(Reminder r, Object advice) async {
    debugPrint(
      '[NotificationService Stub] Jadwal notifikasi key=${r.key}, judul="${r.title}", jam=${r.time}',
    );
  }

  // Membatalkan notifikasi berdasarkan ID pengingat (key Hive)
  Future<void> cancel(int id) async {
    debugPrint('[NotificationService Stub] Membatalkan notifikasi id=$id');
  }

  // Menampilkan notifikasi instan langsung (demo tombol di Profil)
  Future<void> showNow(String title, String body) async {
    debugPrint('[NotificationService Stub] Notifikasi instan: $title - $body');
  }
}

