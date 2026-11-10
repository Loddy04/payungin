// Model satu hasil pencarian kota dari Open-Meteo Geocoding (F4).
// Berbeda dengan FavoriteCity (data tersimpan di Hive), CityResult hanya
// hasil sementara dari internet.
class CityResult {
  final String name;
  final String province;
  final String country;
  final double latitude;
  final double longitude;

  const CityResult({
    required this.name,
    required this.province,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  // Factory constructor: mengubah satu item "results" pada respons menjadi objek.
  // Provinsi ada di field "admin1"; bila field kosong dipakai nilai bawaan.
  factory CityResult.fromJson(Map<String, dynamic> json) {
    return CityResult(
      name: (json['name'] ?? '').toString(),
      province: (json['admin1'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
