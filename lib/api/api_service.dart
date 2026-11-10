import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_data.dart';

// Layanan pengambilan data dari internet (Open-Meteo, tanpa API key).
// Semua method static agar bisa dipanggil tanpa membuat objek: ApiService.getWeather(...)
class ApiService {
  // Tiga fase data (Modul V): Fetch (http.get), Parse (jsonDecode lalu fromJson),
  // Render (dilakukan oleh layar yang memanggil).
  static Future<WeatherData> getWeather(double lat, double lon) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': lat.toString(),
      'longitude': lon.toString(),
      'current':
          'temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m',
      'hourly': 'temperature_2m,precipitation_probability,weather_code',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,uv_index_max',
      'timezone': 'auto',
    });

    try {
      // Fetch: batas waktu 10 detik agar loading tidak menggantung
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      // Parse: teks JSON -> Map -> objek WeatherData
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherData.fromJson(json);
    } catch (e) {
      // F14 (Sprint 4): di sini nanti membaca cache terakhir sebelum melempar error
      throw Exception('Gagal mengambil data cuaca: $e');
    }
  }
}
