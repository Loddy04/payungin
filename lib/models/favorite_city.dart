import 'package:hive/hive.dart';

part 'favorite_city.g.dart';

// Model Kota Favorit dengan typeId 1 sesuai Dokumen Final Bagian 8
@HiveType(typeId: 1)
class FavoriteCity extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String province;

  @HiveField(2)
  double lat;

  @HiveField(3)
  double lon;

  FavoriteCity({
    required this.name,
    required this.province,
    required this.lat,
    required this.lon,
  });
}

