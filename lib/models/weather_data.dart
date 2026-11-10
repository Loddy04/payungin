import 'package:flutter/material.dart';

// Model data cuaca dari Open-Meteo (dipakai F2, F3, F9, F14, F15, F16).
// Pemetaan weather_code ditulis sekali di sini dan dipakai semua halaman.
class WeatherData {
  // Suhu saat ini dalam Celsius. Dibuat private agar hanya bisa diubah
  // lewat setter yang memeriksa nilainya (encapsulation).
  double _temperature;

  // Cuaca saat ini (objek "current" pada respons)
  final double feelsLike;
  final int humidity;
  final int weatherCode;
  final double windSpeed;
  final String currentTime;

  // Prakiraan per jam ("hourly"): list paralel, indeks yang sama = jam yang sama
  final List<String> hourlyTime;
  final List<double> hourlyTemp;
  final List<int> hourlyRain;
  final List<int> hourlyCode;

  // Prakiraan harian ("daily"): list paralel, indeks yang sama = hari yang sama
  final List<String> dailyTime;
  final List<int> dailyCode;
  final List<double> dailyMax;
  final List<double> dailyMin;
  final List<int> dailyRain;
  final List<double> dailyUv;

  // true bila data berasal dari cache saat offline (F14)
  final bool isFromCache;

  // Generative constructor utama
  WeatherData({
    required this._temperature,
    required this.feelsLike,
    required this.humidity,
    required this.weatherCode,
    required this.windSpeed,
    required this.currentTime,
    required this.hourlyTime,
    required this.hourlyTemp,
    required this.hourlyRain,
    required this.hourlyCode,
    required this.dailyTime,
    required this.dailyCode,
    required this.dailyMax,
    required this.dailyMin,
    required this.dailyRain,
    required this.dailyUv,
    this.isFromCache = false,
  });

  // Redirecting constructor: data kosong dengan nilai awal, lewat constructor utama
  WeatherData.empty()
      : this(
          temperature: 0,
          feelsLike: 0,
          humidity: 0,
          weatherCode: 0,
          windSpeed: 0,
          currentTime: '',
          hourlyTime: const [],
          hourlyTemp: const [],
          hourlyRain: const [],
          hourlyCode: const [],
          dailyTime: const [],
          dailyCode: const [],
          dailyMax: const [],
          dailyMin: const [],
          dailyRain: const [],
          dailyUv: const [],
        );

  // Factory constructor: mengubah hasil jsonDecode menjadi objek WeatherData.
  // Nilai null pada list diganti 0 agar tidak crash.
  factory WeatherData.fromJson(
    Map<String, dynamic> json, {
    bool fromCache = false,
  }) {
    // "current" wajib ada; bila tidak ada, error ditangkap oleh pemanggil
    final current = json['current'] as Map<String, dynamic>;
    final hourly = (json['hourly'] as Map<String, dynamic>?) ?? {};
    final daily = (json['daily'] as Map<String, dynamic>?) ?? {};

    return WeatherData(
      temperature: _toDouble(current['temperature_2m']),
      feelsLike: _toDouble(current['apparent_temperature']),
      humidity: _toInt(current['relative_humidity_2m']),
      weatherCode: _toInt(current['weather_code']),
      windSpeed: _toDouble(current['wind_speed_10m']),
      currentTime: (current['time'] ?? '').toString(),
      hourlyTime: _toStrings(hourly['time']),
      hourlyTemp: _toDoubles(hourly['temperature_2m']),
      hourlyRain: _toInts(hourly['precipitation_probability']),
      hourlyCode: _toInts(hourly['weather_code']),
      dailyTime: _toStrings(daily['time']),
      dailyCode: _toInts(daily['weather_code']),
      dailyMax: _toDoubles(daily['temperature_2m_max']),
      dailyMin: _toDoubles(daily['temperature_2m_min']),
      dailyRain: _toInts(daily['precipitation_probability_max']),
      dailyUv: _toDoubles(daily['uv_index_max']),
      isFromCache: fromCache,
    );
  }

  // ---- Suhu (encapsulation) ----

  double get tempC => _temperature;

  // Setter menolak suhu yang tidak masuk akal (di luar -90 sampai 60 derajat C)
  set tempC(double value) {
    if (value < -90 || value > 60) return;
    _temperature = value;
  }

  double get tempFahrenheit => _temperature * 9 / 5 + 32;

  // ---- Kondisi cuaca (pemetaan weather_code) ----

  String get condition => conditionOf(weatherCode);

  IconData get icon => iconOf(weatherCode);

  // Static agar bisa dipakai juga untuk kode per jam dan per hari di Detail
  static String conditionOf(int code) {
    if (code == 0) return 'Cerah';
    if (code == 1) return 'Cerah berawan';
    if (code == 2) return 'Berawan sebagian';
    if (code == 3) return 'Berawan';
    if (code == 45 || code == 48) return 'Berkabut';
    if (code >= 51 && code <= 57) return 'Gerimis';
    if (code >= 61 && code <= 67) return 'Hujan';
    if (code >= 80 && code <= 82) return 'Hujan lokal';
    if (code >= 95 && code <= 99) return 'Badai petir';
    return 'Tidak diketahui';
  }

  static IconData iconOf(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code >= 1 && code <= 3) return Icons.wb_cloudy_rounded;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 51 && code <= 57) return Icons.grain_rounded;
    if (code >= 61 && code <= 67) return Icons.water_drop_rounded;
    if (code >= 80 && code <= 82) return Icons.umbrella_rounded;
    if (code >= 95 && code <= 99) return Icons.thunderstorm_rounded;
    return Icons.cloud_rounded;
  }

  // ---- Data turunan untuk Beranda dan Skor Payung ----

  // Indeks UV maksimum hari ini (elemen pertama daftar harian)
  double get uvIndex => dailyUv.isNotEmpty ? dailyUv.first : 0;

  // Peluang hujan terbesar pada jam aktif 06.00 sampai 22.00 hari ini.
  // Dipakai untuk rumus Skor Payung (F9) dan info peluang hujan di Beranda.
  int get maxRainChance {
    if (currentTime.length < 10) return 0;
    final today = currentTime.substring(0, 10);
    var maks = 0;

    for (var i = 0; i < hourlyTime.length && i < hourlyRain.length; i++) {
      final waktu = hourlyTime[i];
      if (waktu.length < 13 || !waktu.startsWith(today)) continue;

      final jam = int.tryParse(waktu.substring(11, 13)) ?? -1;
      if (jam >= 6 && jam <= 22 && hourlyRain[i] > maks) {
        maks = hourlyRain[i];
      }
    }
    return maks;
  }

  // Cuaca ekstrem: badai petir (kode 95-99), angin >= 40 km/jam, atau UV >= 8
  bool get isExtreme =>
      (weatherCode >= 95 && weatherCode <= 99) ||
      windSpeed >= 40 ||
      uvIndex >= 8;

  // ---- Pembantu parsing: nilai null atau tipe lain diganti nilai bawaan ----

  static double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0.0;

  static int _toInt(dynamic v) => (v as num?)?.toInt() ?? 0;

  static List<double> _toDoubles(dynamic list) =>
      ((list as List?) ?? []).map(_toDouble).toList();

  static List<int> _toInts(dynamic list) =>
      ((list as List?) ?? []).map(_toInt).toList();

  static List<String> _toStrings(dynamic list) =>
      ((list as List?) ?? []).map((e) => e.toString()).toList();
}
